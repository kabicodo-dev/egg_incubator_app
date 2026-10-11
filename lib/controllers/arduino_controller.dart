import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/arduino_protocol.dart';
import '../services/arduino_serial_factory.dart';
import '../services/arduino_serial_service.dart';

/// UI-facing status of a single actuator command.
enum ActuatorCommandStatus { idle, pending, confirmed, rejected, failed }

/// Application-wide Arduino connection state.
///
/// This is the bridge between the [ArduinoSerialService] transport and the
/// existing screens: it holds the latest telemetry, port list, per-actuator
/// command status, and sends validated commands. It never reports an actuator
/// change as successful until the Arduino acknowledges it.
///
/// A single instance is shared across screens via [ArduinoController.instance];
/// tests may inject a fake [ArduinoSerialService].
class ArduinoController extends ChangeNotifier {
  ArduinoController({ArduinoSerialService? service})
      : _service = service ?? createArduinoSerialService() {
    _connectionSub = _service.connectionStream.listen(_onConnection);
    _telemetrySub = _service.telemetryStream.listen(_onTelemetry);
    _ackSub = _service.ackStream.listen(_onAck);
    _errorSub = _service.errorStream.listen(_onError);
  }

  /// Shared instance used by the app screens.
  static final ArduinoController instance = ArduinoController();

  /// Telemetry older than this is treated as stale and not shown as live.
  static const Duration staleAfter = Duration(seconds: 6);

  final ArduinoSerialService _service;
  late final StreamSubscription<ArduinoConnectionState> _connectionSub;
  late final StreamSubscription<ArduinoTelemetry> _telemetrySub;
  late final StreamSubscription<ArduinoAck> _ackSub;
  late final StreamSubscription<String> _errorSub;
  Timer? _freshnessTimer;

  ArduinoConnectionState _connection = const ArduinoConnectionState.disconnected();
  ArduinoTelemetry? _telemetry;
  final Map<String, ActuatorCommandStatus> _commandStatus = {};
  final Map<String, bool> _actuatorStates = {};
  List<String> _ports = const [];
  String? _lastError;
  int _commandCounter = 0;
  bool _disposed = false;

  // ── Connection ──

  ArduinoConnectionStatus get status => _connection.status;
  bool get isConnected => _connection.isConnected;
  bool get isConnecting => status == ArduinoConnectionStatus.connecting;
  String? get portName => _connection.portName;
  String? get connectionMessage => _connection.message;
  String? get lastError => _lastError;
  List<String> get ports => List.unmodifiable(_ports);

  // ── Telemetry ──

  ArduinoTelemetry? get telemetry => _telemetry;

  /// Whether the last reading is recent enough to be shown as live.
  bool get isLive {
    final reading = _telemetry;
    if (!isConnected || reading == null) return false;
    return DateTime.now().difference(reading.receivedAt) <= staleAfter;
  }

  bool get isStale => _telemetry != null && !isLive;

  /// Live sensor values (null when disconnected, stale, or sensor error).
  double? get incubatorTemperature => isLive ? _telemetry!.incubatorTemperature : null;
  double? get incubatorHumidity => isLive ? _telemetry!.incubatorHumidity : null;
  double? get brooderTemperature => isLive ? _telemetry!.brooderTemperature : null;
  double? get brooderHumidity => isLive ? _telemetry!.brooderHumidity : null;

  bool get hasIncubatorSensorError =>
      isLive && (_telemetry!.incubatorTemperature == null || _telemetry!.incubatorHumidity == null);
  bool get hasBrooderSensorError =>
      isLive && (_telemetry!.brooderTemperature == null || _telemetry!.brooderHumidity == null);

  // ── Actuators ──

  bool actuatorOn(String name) => _actuatorStates[name] ?? false;

  ActuatorCommandStatus commandStatus(String name) =>
      _commandStatus[name] ?? ActuatorCommandStatus.idle;

  bool get turningActive => _telemetry?.turningActive ?? false;
  int? get turnsToday => _telemetry?.turnsToday;
  int? get secondsSinceLastTurn => _telemetry?.secondsSinceLastTurn;

  /// Turns per day derived from the Arduino-reported interval (0 when the
  /// turning system reports itself disabled).
  int get scheduledTurnsPerDay {
    final reading = _telemetry;
    if (reading == null) return 6;
    return reading.turningActive ? reading.scheduledTurnsPerDay : 0;
  }

  // ── Actions ──

  Future<void> refreshPorts() async {
    _ports = await _service.listPorts();
    _notify();
  }

  Future<void> connect(String port, {int baudRate = 9600}) async {
    _lastError = null;
    _notify();
    try {
      await _service.connect(portName: port, baudRate: baudRate);
    } catch (e) {
      _lastError = '$e';
      _notify();
      rethrow;
    }
  }

  /// Convenience: connect to the first enumerated port if any.
  Future<bool> connectFirstAvailable() async {
    await refreshPorts();
    if (_ports.isEmpty) {
      _lastError = 'No serial ports found. Is the Arduino plugged in?';
      _notify();
      return false;
    }
    await connect(_ports.first);
    return isConnected;
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    _actuatorStates.clear();
    _commandStatus.clear();
    _notify();
  }

  /// Sends a validated actuator command.
  ///
  /// Returns `true` only after a successful acknowledgement. Ignores the request
  /// (returns `false`) when disconnected, when the actuator is invalid, or when
  /// another command for the same actuator is still pending.
  Future<bool> setActuator(String actuator, bool state) async {
    if (!isValidActuator(actuator)) {
      _lastError = 'Invalid actuator: $actuator';
      _notify();
      return false;
    }
    if (!isConnected) {
      _lastError = 'Arduino is not connected';
      _notify();
      return false;
    }
    if (commandStatus(actuator) == ActuatorCommandStatus.pending) {
      return false;
    }

    final id = 'cmd-${DateTime.now().millisecondsSinceEpoch}-${++_commandCounter}';
    _commandStatus[actuator] = ActuatorCommandStatus.pending;
    _notify();

    try {
      final ack = await _service.sendCommand(ArduinoCommand(
        id: id,
        actuator: actuator,
        state: state,
      ));
      if (ack.success) {
        _actuatorStates[actuator] = ack.state ?? state;
        _commandStatus[actuator] = ActuatorCommandStatus.confirmed;
        _lastError = null;
        _notify();
        return true;
      }
      _commandStatus[actuator] = ActuatorCommandStatus.rejected;
      _lastError = ack.error ?? 'Command rejected by Arduino';
      _notify();
      return false;
    } on ArduinoCommandException catch (e) {
      _commandStatus[actuator] = ActuatorCommandStatus.failed;
      _lastError = e.message;
      _notify();
      return false;
    }
  }

  // ── Stream handlers ──

  void _onConnection(ArduinoConnectionState state) {
    _connection = state;
    if (state.status == ArduinoConnectionStatus.error) {
      _lastError = state.message;
    }
    if (state.status == ArduinoConnectionStatus.connected) {
      _ensureFreshnessTimer();
    } else {
      // While disconnected there is nothing to refresh; stopping the single
      // shared timer also keeps widget tests free of lingering timers.
      _stopFreshnessTimer();
      if (state.status == ArduinoConnectionStatus.disconnected) {
        _actuatorStates.clear();
        _commandStatus.clear();
      }
    }
    _notify();
  }

  void _ensureFreshnessTimer() {
    if (_freshnessTimer != null) return;
    _freshnessTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_disposed) notifyListeners();
    });
  }

  void _stopFreshnessTimer() {
    _freshnessTimer?.cancel();
    _freshnessTimer = null;
  }

  void _onTelemetry(ArduinoTelemetry reading) {
    _telemetry = reading;
    // Adopt reported relay states, except actuators with a command in flight.
    for (final entry in reading.actuators.entries) {
      if (commandStatus(entry.key) != ActuatorCommandStatus.pending) {
        _actuatorStates[entry.key] = entry.value;
      }
    }
    _notify();
  }

  void _onAck(ArduinoAck ack) {
    // Ack futures are resolved by the service; this only records late acks.
    if (ack.success && ack.actuator != null) {
      _actuatorStates[ack.actuator!] = ack.state ?? actuatorOn(ack.actuator!);
    }
  }

  void _onError(String message) {
    _lastError = message;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _freshnessTimer?.cancel();
    _connectionSub.cancel();
    _telemetrySub.cancel();
    _ackSub.cancel();
    _errorSub.cancel();
    _service.dispose();
    super.dispose();
  }
}
