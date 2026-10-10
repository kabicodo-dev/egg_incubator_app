import 'arduino_protocol.dart';

/// Connection lifecycle states reported by [ArduinoSerialService].
enum ArduinoConnectionStatus { disconnected, connecting, connected, error }

/// Immutable connection snapshot.
class ArduinoConnectionState {
  final ArduinoConnectionStatus status;
  final String? portName;
  final String? message;

  const ArduinoConnectionState({
    required this.status,
    this.portName,
    this.message,
  });

  const ArduinoConnectionState.disconnected()
      : status = ArduinoConnectionStatus.disconnected,
        portName = null,
        message = null;

  bool get isConnected => status == ArduinoConnectionStatus.connected;

  @override
  String toString() => 'ArduinoConnectionState($status, port: $portName)';
}

/// Thrown when a command cannot be sent or is rejected/times out.
class ArduinoCommandException implements Exception {
  final String message;
  const ArduinoCommandException(this.message);

  @override
  String toString() => message;
}

/// Transport-agnostic Arduino serial contract.
///
/// The concrete implementation lives in `arduino_serial_io.dart` (desktop, uses
/// libserialport) with a no-op stub for unsupported platforms, selected through
/// `arduino_serial_factory.dart`.
abstract class ArduinoSerialService {
  /// Current connection status, plus future transitions.
  Stream<ArduinoConnectionState> get connectionStream;

  /// Decoded telemetry messages.
  Stream<ArduinoTelemetry> get telemetryStream;

  /// Every acknowledgement received (including for commands nothing is waiting
  /// on). Useful for logging/diagnostics.
  Stream<ArduinoAck> get ackStream;

  /// Non-fatal protocol/transport errors (malformed lines, read errors, ...).
  Stream<String> get errorStream;

  /// Whether a port is currently open.
  bool get isConnected;

  /// Enumerates the serial ports available on the host (e.g. `COM3`).
  Future<List<String>> listPorts();

  /// Opens [portName] (e.g. `COM3`) at [baudRate] (default 9600).
  Future<void> connect({required String portName, int baudRate = 9600});

  /// Closes the connection and releases all resources.
  Future<void> disconnect();

  /// Sends [command] and completes with the matching acknowledgement, or throws
  /// [ArduinoCommandException] on timeout/disconnect.
  Future<ArduinoAck> sendCommand(
    ArduinoCommand command, {
    Duration timeout = const Duration(seconds: 3),
  });

  /// Releases every reader/writer/listener.
  Future<void> dispose();
}
