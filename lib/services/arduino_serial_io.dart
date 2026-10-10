import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

import 'arduino_protocol.dart';
import 'arduino_serial_service.dart';

/// Entry point used by `arduino_serial_factory.dart` on platforms with `dart:io`.
ArduinoSerialService createSerialServiceImpl() => LibSerialPortArduinoService();

/// USB serial implementation built on `flutter_libserialport`.
///
/// Owns at most one open port and one reader at a time (duplicate connections
/// are rejected). Reads bytes continuously, splits them into newline-delimited
/// JSON lines, and matches acknowledgements back to pending commands.
class LibSerialPortArduinoService implements ArduinoSerialService {
  static const int _maxLineLength = 8192;

  final StreamController<ArduinoConnectionState> _connectionController =
      StreamController<ArduinoConnectionState>.broadcast();
  final StreamController<ArduinoTelemetry> _telemetryController =
      StreamController<ArduinoTelemetry>.broadcast();
  final StreamController<ArduinoAck> _ackController =
      StreamController<ArduinoAck>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  final Map<String, Completer<ArduinoAck>> _pending = {};
  final List<int> _rxBuffer = [];

  SerialPort? _port;
  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _subscription;
  bool _connected = false;
  String? _portName;

  @override
  Stream<ArduinoConnectionState> get connectionStream =>
      _connectionController.stream;

  @override
  Stream<ArduinoTelemetry> get telemetryStream => _telemetryController.stream;

  @override
  Stream<ArduinoAck> get ackStream => _ackController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<List<String>> listPorts() async {
    try {
      final ports = SerialPort.availablePorts.toList()..sort();
      return ports;
    } catch (e) {
      _emitError('Could not enumerate serial ports: $e');
      return const [];
    }
  }

  @override
  Future<void> connect({
    required String portName,
    int baudRate = 9600,
  }) async {
    if (_connected) {
      throw const ArduinoCommandException('Already connected to a serial port');
    }
    _emitConnection(ArduinoConnectionStatus.connecting, portName: portName);

    final port = SerialPort(portName);
    try {
      if (!port.openReadWrite()) {
        throw ArduinoCommandException(
          'Could not open $portName. ${SerialPort.lastError?.message ?? ''}',
        );
      }

      final config = port.config;
      config.baudRate = baudRate;
      config.bits = 8;
      config.parity = SerialPortParity.none;
      config.stopBits = 1;
      config.setFlowControl(SerialPortFlowControl.none);
      port.config = config;
      port.flush();

      final reader = SerialPortReader(port);
      _subscription = reader.stream.listen(
        _onData,
        onError: _onStreamError,
        onDone: _onStreamDone,
        cancelOnError: false,
      );

      _port = port;
      _reader = reader;
      _portName = portName;
      _connected = true;
      _rxBuffer.clear();
      _emitConnection(ArduinoConnectionStatus.connected, portName: portName);
    } catch (e) {
      _safeClose(port);
      _emitConnection(
        ArduinoConnectionStatus.error,
        portName: portName,
        message: '$e',
      );
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    if (!_connected && _port == null) {
      _emitConnection(ArduinoConnectionStatus.disconnected);
      return;
    }
    await _teardown();
    _emitConnection(ArduinoConnectionStatus.disconnected);
  }

  @override
  Future<ArduinoAck> sendCommand(
    ArduinoCommand command, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!isValidActuator(command.actuator)) {
      throw ArduinoCommandException('Invalid actuator: ${command.actuator}');
    }
    final port = _port;
    if (!_connected || port == null) {
      throw const ArduinoCommandException('Not connected to an Arduino');
    }

    final completer = Completer<ArduinoAck>();
    _pending[command.id] = completer;

    try {
      final bytes = Uint8List.fromList(utf8.encode(command.toJsonLine()));
      port.write(bytes, timeout: 1000);
    } catch (e) {
      _pending.remove(command.id);
      throw ArduinoCommandException('Failed to write command: $e');
    }

    try {
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      _pending.remove(command.id);
      throw ArduinoCommandException(
        'No acknowledgement for "${command.actuator}" (${command.id})',
      );
    }
  }

  // ── Internals ──

  void _onData(Uint8List chunk) {
    _rxBuffer.addAll(chunk);
    while (true) {
      final newline = _rxBuffer.indexOf(0x0A); // '\n'
      if (newline < 0) break;
      final lineBytes = _rxBuffer.sublist(0, newline);
      _rxBuffer.removeRange(0, newline + 1);
      final line = utf8.decode(lineBytes, allowMalformed: true).trim();
      if (line.isEmpty) continue;
      _handleLine(line);
    }
    if (_rxBuffer.length > _maxLineLength) {
      _rxBuffer.clear();
      _emitError('Incoming serial buffer overflowed; resetting buffer');
    }
  }

  void _handleLine(String line) {
    final message = parseArduinoLine(line);
    switch (message) {
      case null:
        return;
      case ArduinoTelemetryMessage(:final telemetry):
        _telemetryController.add(telemetry);
      case ArduinoAckMessage(:final ack):
        _ackController.add(ack);
        final id = ack.id;
        final completer = id == null ? null : _pending.remove(id);
        if (completer != null && !completer.isCompleted) {
          completer.complete(ack);
        }
      case ArduinoMalformedMessage():
        _emitError('Ignored malformed serial line');
      case ArduinoUnknownMessage(:final type):
        _emitError('Ignored unknown message type: ${type ?? '(none)'}');
    }
  }

  void _onStreamError(Object error) {
    _emitError('Serial read error: $error');
    if (_connected) {
      _emitConnection(
        ArduinoConnectionStatus.error,
        portName: _portName,
        message: '$error',
      );
    }
  }

  void _onStreamDone() {
    if (_connected) {
      _emitError('Serial connection closed by the device');
      _emitConnection(
        ArduinoConnectionStatus.disconnected,
        message: 'Device disconnected',
      );
      _connected = false;
      _failPending('Serial connection closed');
    }
  }

  Future<void> _teardown() async {
    _subscription?.cancel();
    _subscription = null;
    _reader?.close();
    _reader = null;

    final port = _port;
    _port = null;
    if (port != null) {
      _safeClose(port);
    }

    _connected = false;
    _rxBuffer.clear();
    _failPending('Serial connection closed');
  }

  void _safeClose(SerialPort port) {
    try {
      if (port.isOpen) port.close();
    } catch (_) {
      // Ignore: the OS may already have released the handle.
    }
    try {
      port.dispose();
    } catch (_) {
      // Ignore.
    }
  }

  void _failPending(String reason) {
    final pending = Map<String, Completer<ArduinoAck>>.from(_pending);
    _pending.clear();
    for (final completer in pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(ArduinoCommandException(reason));
      }
    }
  }

  void _emitConnection(
    ArduinoConnectionStatus status, {
    String? portName,
    String? message,
  }) {
    if (_connectionController.isClosed) return;
    _connectionController.add(ArduinoConnectionState(
      status: status,
      portName: portName ?? _portName,
      message: message,
    ));
  }

  void _emitError(String message) {
    if (!_errorController.isClosed) _errorController.add(message);
  }

  @override
  Future<void> dispose() async {
    await _teardown();
    await _connectionController.close();
    await _telemetryController.close();
    await _ackController.close();
    await _errorController.close();
  }
}
