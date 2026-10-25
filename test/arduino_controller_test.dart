import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/controllers/arduino_controller.dart';
import 'package:egg_incubator_app/services/arduino_protocol.dart';
import 'package:egg_incubator_app/services/arduino_readiness.dart';
import 'package:egg_incubator_app/services/arduino_serial_service.dart';

/// Fake transport: the controller under test drives readiness purely from the
/// connection and telemetry streams, so no real serial port is needed.
class _FakeSerialService implements ArduinoSerialService {
  final _connection = StreamController<ArduinoConnectionState>();
  final _telemetry = StreamController<ArduinoTelemetry>();
  final _ack = StreamController<ArduinoAck>();
  final _error = StreamController<String>();

  ArduinoConnectionStatus status = ArduinoConnectionStatus.disconnected;
  String? portName;

  @override
  Stream<ArduinoConnectionState> get connectionStream => _connection.stream;
  @override
  Stream<ArduinoTelemetry> get telemetryStream => _telemetry.stream;
  @override
  Stream<ArduinoAck> get ackStream => _ack.stream;
  @override
  Stream<String> get errorStream => _error.stream;
  @override
  bool get isConnected => status == ArduinoConnectionStatus.connected;

  @override
  Future<List<String>> listPorts() async => const [];

  @override
  Future<void> connect({
    required String portName,
    int baudRate = 9600,
  }) async {
    this.portName = portName;
    status = ArduinoConnectionStatus.connecting;
    _connection.add(
      ArduinoConnectionState(status: ArduinoConnectionStatus.connecting, portName: portName),
    );
    // Simulate a successful port open.
    status = ArduinoConnectionStatus.connected;
    _connection.add(
      ArduinoConnectionState(status: ArduinoConnectionStatus.connected, portName: portName),
    );
  }

  @override
  Future<void> disconnect() async {
    status = ArduinoConnectionStatus.disconnected;
    portName = null;
    _connection.add(const ArduinoConnectionState.disconnected());
  }

  @override
  Future<ArduinoAck> sendCommand(
    ArduinoCommand command, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    return ArduinoAck(id: command.id, success: true, actuator: command.actuator, state: command.state);
  }

  @override
  Future<void> sendLcdUpdate(LcdUpdateCommand lcdCommand) async {}

  @override
  Future<void> dispose() async {
    await _connection.close();
    await _telemetry.close();
    await _ack.close();
    await _error.close();
  }

  void emitConnected([String? port]) {
    portName = port;
    status = ArduinoConnectionStatus.connected;
    _connection.add(ArduinoConnectionState(status: ArduinoConnectionStatus.connected, portName: port));
  }

  void emitDisconnected() {
    status = ArduinoConnectionStatus.disconnected;
    _connection.add(const ArduinoConnectionState.disconnected());
  }

  void emitError(String message) {
    status = ArduinoConnectionStatus.error;
    _connection.add(
      ArduinoConnectionState(status: ArduinoConnectionStatus.error, message: message),
    );
  }

  void emitTelemetry({required DateTime receivedAt}) {
    _telemetry.add(
      ArduinoTelemetry.fromJson(
        {'type': 'telemetry', 'incubator': {'temperature': 37.5, 'humidity': 50.0}},
        receivedAt: receivedAt,
      ),
    );
  }
}

ArduinoTelemetry _staleTelemetry() => ArduinoTelemetry.fromJson(
      {'type': 'telemetry'},
      receivedAt: DateTime.now().subtract(const Duration(seconds: 10)),
    );

/// Lets the controller process stream events delivered by the fake service.
Future<void> drain() async {
  for (var i = 0; i < 5; i++) {
    await Future.delayed(Duration.zero);
  }
}

void main() {
  group('ArduinoController.readiness (HW-01)', () {
    test('starts disconnected and is not ready', () {
      final service = _FakeSerialService();
      final controller = ArduinoController(service: service);
      expect(controller.readiness, ArduinoReadinessState.disconnected);
      expect(controller.isReady, isFalse);
      expect(controller.isConnected, isFalse);
      controller.dispose();
      service.dispose();
    });

    test('connecting then connected-not-ready before any telemetry', () async {
      final service = _FakeSerialService();
      final controller = ArduinoController(service: service);

      await service.connect(portName: 'COM3');
      await drain();

      expect(controller.status, ArduinoConnectionStatus.connected);
      expect(controller.readiness, ArduinoReadinessState.connectedNotReady);
      expect(controller.isReady, isFalse);
      expect(controller.readinessMessage, contains('waiting for first telemetry'));

      controller.dispose();
      service.dispose();
    });

    test('fresh telemetry makes it ready', () async {
      final service = _FakeSerialService();
      final controller = ArduinoController(service: service);

      await service.connect(portName: 'COM3');
      await drain();
      service.emitTelemetry(receivedAt: DateTime.now());
      await drain();

      expect(controller.readiness, ArduinoReadinessState.ready);
      expect(controller.isReady, isTrue);
      expect(controller.isLive, isTrue);
      expect(controller.incubatorTemperature, 37.5);

      controller.dispose();
      service.dispose();
    });

    test('stale telemetry makes it timeout while still connected', () async {
      final service = _FakeSerialService();
      final controller = ArduinoController(service: service);

      await service.connect(portName: 'COM3');
      await drain();
      service.emitTelemetry(receivedAt: _staleTelemetry().receivedAt);
      await drain();

      expect(controller.readiness, ArduinoReadinessState.timeout);
      expect(controller.isReady, isFalse);
      expect(controller.isConnected, isTrue);
      expect(controller.isLive, isFalse);

      controller.dispose();
      service.dispose();
    });

    test('transport error transitions to error', () async {
      final service = _FakeSerialService();
      final controller = ArduinoController(service: service);

      await service.connect(portName: 'COM3');
      await drain();
      service.emitTelemetry(receivedAt: DateTime.now());
      await drain();
      expect(controller.readiness, ArduinoReadinessState.ready);

      service.emitError('Serial read error');
      await drain();
      expect(controller.readiness, ArduinoReadinessState.error);
      expect(controller.lastError, 'Serial read error');

      controller.dispose();
      service.dispose();
    });

    test('disconnect returns to disconnected and is not ready', () async {
      final service = _FakeSerialService();
      final controller = ArduinoController(service: service);

      await service.connect(portName: 'COM3');
      await drain();
      service.emitTelemetry(receivedAt: DateTime.now());
      await drain();
      expect(controller.readiness, ArduinoReadinessState.ready);

      await service.disconnect();
      await drain();
      expect(controller.readiness, ArduinoReadinessState.disconnected);
      expect(controller.isReady, isFalse);
      expect(controller.isConnected, isFalse);

      controller.dispose();
      service.dispose();
    });

    test('reconnect awaits a fresh heartbeat (stale reading is not reused)', () async {
      final service = _FakeSerialService();
      final controller = ArduinoController(service: service);

      await service.connect(portName: 'COM3');
      await drain();
      service.emitTelemetry(receivedAt: DateTime.now());
      await drain();
      expect(controller.readiness, ArduinoReadinessState.ready);

      // Reconnect via the controller: it resets telemetry, so the old reading
      // must not count as a heartbeat on the new connection.
      await controller.connect('COM4');
      await drain();
      expect(controller.readiness, ArduinoReadinessState.connectedNotReady);
      expect(controller.portName, 'COM4');

      service.emitTelemetry(receivedAt: DateTime.now());
      await drain();
      expect(controller.readiness, ArduinoReadinessState.ready);

      controller.dispose();
      service.dispose();
    });
  });
}
