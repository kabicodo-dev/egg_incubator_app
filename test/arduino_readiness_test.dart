import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/services/arduino_protocol.dart';
import 'package:egg_incubator_app/services/arduino_readiness.dart';
import 'package:egg_incubator_app/services/arduino_serial_service.dart';

ArduinoTelemetry _telemetry({required DateTime receivedAt}) =>
    ArduinoTelemetry.fromJson(
      {'type': 'telemetry'},
      receivedAt: receivedAt,
    );

void main() {
  group('computeHardwareReadiness', () {
    test('disconnected regardless of telemetry', () {
      final now = DateTime.now();
      final r = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.disconnected,
        portName: 'COM3',
        telemetry: _telemetry(receivedAt: now),
        telemetryReceived: true,
        now: now,
      );
      expect(r.state, ArduinoReadinessState.disconnected);
      expect(r.heartbeating, isFalse);
      expect(r.lastTelemetryAt, isNull);
    });

    test('connecting reports the port and is not heartbeating', () {
      final r = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.connecting,
        portName: 'COM3',
        telemetry: null,
        telemetryReceived: false,
        now: DateTime.now(),
      );
      expect(r.state, ArduinoReadinessState.connecting);
      expect(r.portName, 'COM3');
      expect(r.message, contains('COM3'));
      expect(r.heartbeating, isFalse);
    });

    test('error is not heartbeating', () {
      final r = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.error,
        portName: 'COM3',
        telemetry: null,
        telemetryReceived: false,
        now: DateTime.now(),
      );
      expect(r.state, ArduinoReadinessState.error);
      expect(r.heartbeating, isFalse);
    });

    test('connected with no telemetry yet is connectedNotReady', () {
      final r = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.connected,
        portName: 'COM3',
        telemetry: null,
        telemetryReceived: false,
        now: DateTime.now(),
      );
      expect(r.state, ArduinoReadinessState.connectedNotReady);
      expect(r.heartbeating, isFalse);
      expect(r.message, contains('waiting for first telemetry'));
    });

    test('connected with fresh telemetry is ready', () {
      final now = DateTime.now();
      final r = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.connected,
        portName: 'COM3',
        telemetry: _telemetry(receivedAt: now),
        telemetryReceived: true,
        now: now,
      );
      expect(r.state, ArduinoReadinessState.ready);
      expect(r.heartbeating, isTrue);
      expect(r.lastTelemetryAt, now);
      expect(r.message, contains('Live'));
    });

    test('connected with telemetry older than the timeout is timeout', () {
      final r = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.connected,
        portName: 'COM3',
        telemetry: _telemetry(
          receivedAt: DateTime.now().subtract(const Duration(seconds: 10)),
        ),
        telemetryReceived: true,
        now: DateTime.now(),
      );
      expect(r.state, ArduinoReadinessState.timeout);
      expect(r.heartbeating, isFalse);
      expect(r.message, contains('not responding'));
    });

    test('exactly at the heartbeat boundary is still ready (not >)', () {
      final now = DateTime.now();
      final r = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.connected,
        portName: 'COM3',
        telemetry: _telemetry(
          receivedAt: now.subtract(const Duration(seconds: 6)),
        ),
        telemetryReceived: true,
        now: now,
      );
      expect(r.state, ArduinoReadinessState.ready);
    });

    test('custom heartbeat timeout applies', () {
      final now = DateTime.now();
      final tight = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.connected,
        portName: null,
        telemetry: _telemetry(receivedAt: now.subtract(const Duration(seconds: 2))),
        telemetryReceived: true,
        now: now,
        heartbeatTimeout: const Duration(seconds: 1),
      );
      expect(tight.state, ArduinoReadinessState.timeout);

      final lax = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.connected,
        portName: null,
        telemetry: _telemetry(receivedAt: now.subtract(const Duration(seconds: 2))),
        telemetryReceived: true,
        now: now,
        heartbeatTimeout: const Duration(seconds: 6),
      );
      expect(lax.state, ArduinoReadinessState.ready);
    });

    test('no telemetry received yet stays connectedNotReady even when stale', () {
      final now = DateTime.now();
      final r = computeHardwareReadiness(
        connection: ArduinoConnectionStatus.connected,
        portName: null,
        telemetry: null,
        telemetryReceived: false,
        now: now,
      );
      expect(r.state, ArduinoReadinessState.connectedNotReady);
    });
  });

  group('ArduinoReadiness.isReady', () {
    test('is true only in the ready state', () {
      final ready = ArduinoReadiness(
        state: ArduinoReadinessState.ready,
        heartbeating: true,
      );
      expect(ready.isReady, isTrue);
      for (final state in ArduinoReadinessState.values) {
        if (state == ArduinoReadinessState.ready) continue;
        expect(
          ArduinoReadiness(state: state, heartbeating: false).isReady,
          isFalse,
          reason: state.toString(),
        );
      }
    });
  });
}
