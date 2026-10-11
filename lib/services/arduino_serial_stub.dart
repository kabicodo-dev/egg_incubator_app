import 'dart:async';

import 'arduino_protocol.dart';
import 'arduino_serial_service.dart';

/// Entry point used by `arduino_serial_factory.dart` on platforms without
/// `dart:io` (e.g. Flutter web). Serial hardware is only supported on desktop.
ArduinoSerialService createSerialServiceImpl() => UnsupportedArduinoSerialService();

/// A safe no-op implementation so the app still builds and runs on web/other
/// platforms; every operation reports a clear "unsupported" error instead of
/// crashing.
class UnsupportedArduinoSerialService implements ArduinoSerialService {
  static const String _message =
      'Arduino USB serial is only supported on the Windows desktop build.';

  final StreamController<ArduinoConnectionState> _connectionController =
      StreamController<ArduinoConnectionState>.broadcast();

  @override
  Stream<ArduinoConnectionState> get connectionStream =>
      _connectionController.stream;

  @override
  Stream<ArduinoTelemetry> get telemetryStream =>
      const Stream<ArduinoTelemetry>.empty();

  @override
  Stream<ArduinoAck> get ackStream => const Stream<ArduinoAck>.empty();

  @override
  Stream<String> get errorStream => const Stream<String>.empty();

  @override
  bool get isConnected => false;

  @override
  Future<List<String>> listPorts() async => const [];

  @override
  Future<void> connect({
    required String portName,
    int baudRate = 9600,
  }) async {
    throw const ArduinoCommandException(_message);
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<ArduinoAck> sendCommand(
    ArduinoCommand command, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    throw const ArduinoCommandException(_message);
  }

  @override
  Future<void> dispose() async {
    await _connectionController.close();
  }
}
