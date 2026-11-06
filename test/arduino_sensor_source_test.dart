import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/controllers/incubator_controller.dart';

void main() {
  group('SensorDataSource tracking (HW-02)', () {
    test('defaults to none with no live reading', () {
      final controller = IncubatorController();
      expect(controller.sensorSource, SensorDataSource.none);
      expect(controller.sensorsAreLive, isFalse);
      expect(controller.sensorsAreSimulated, isFalse);
      controller.dispose();
    });

    test('physical fresh reading is live and mapped to the right chamber', () {
      final controller = IncubatorController();
      controller.updateSensors(
        incTemp: 37.5,
        incHumidity: 50.0,
        broodTemp: 31.0,
        broodHumidity: 55.0,
        source: SensorDataSource.physical,
        receivedAt: DateTime.now(),
      );

      expect(controller.sensorSource, SensorDataSource.physical);
      expect(controller.sensorsAreLive, isTrue);
      expect(controller.sensorsAreSimulated, isFalse);

      // Chamber mapping: incubator vs brooder are distinct.
      expect(controller.incubatorTemperature, 37.5);
      expect(controller.incubatorHumidity, 50.0);
      expect(controller.brooderTemperature, 31.0);
      expect(controller.brooderHumidity, 55.0);

      controller.dispose();
    });

    test('physical reading older than sensorStaleAfter is not live', () {
      final controller = IncubatorController();
      controller.updateSensors(
        incTemp: 37.5,
        source: SensorDataSource.physical,
        receivedAt: DateTime.now().subtract(const Duration(seconds: 7)),
      );

      expect(controller.sensorSource, SensorDataSource.physical);
      expect(controller.sensorsAreLive, isFalse);
      expect(controller.sensorLastReceivedAt, isNotNull);

      controller.dispose();
    });

    test('physical reading well within the staleness window is live', () {
      final controller = IncubatorController();
      controller.updateSensors(
        incTemp: 37.5,
        source: SensorDataSource.physical,
        receivedAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      // 1 s is comfortably inside the 6 s staleness window; the boundary
      // comparison itself is inclusive (<= sensorStaleAfter) and cannot be
      // pinned to an exact instant with a real clock, so we test clear margins
      // instead (1 s live, 7 s stale above).
      expect(controller.sensorsAreLive, isTrue);

      controller.dispose();
    });

    test('simulated readings are never labeled live', () {
      final controller = IncubatorController();
      controller.updateSensors(
        incTemp: 37.5,
        source: SensorDataSource.simulated,
        receivedAt: DateTime.now(),
      );

      expect(controller.sensorSource, SensorDataSource.simulated);
      expect(controller.sensorsAreSimulated, isTrue);
      expect(controller.sensorsAreLive, isFalse);

      controller.dispose();
    });

    test('a fresh physical frame with a null chamber value is live but '
        'flagged as a sensor error (null is never shown as a reading)', () {
      final controller = IncubatorController();
      controller.updateSensors(
        incTemp: null,
        incHumidity: null,
        source: SensorDataSource.physical,
        receivedAt: DateTime.now(),
      );

      expect(controller.sensorsAreLive, isTrue);
      expect(controller.hasIncubatorSensorError, isTrue);
      expect(controller.incubatorTemperature, isNull);
      expect(controller.incubatorHumidity, isNull);

      controller.dispose();
    });

    test('simulated overwrite does not mix with physical (source flips)', () {
      final controller = IncubatorController();
      controller.updateSensors(
        incTemp: 37.5,
        source: SensorDataSource.physical,
        receivedAt: DateTime.now(),
      );
      expect(controller.sensorsAreLive, isTrue);

      // Simulator preview takes over: source flips to simulated, not live.
      controller.updateSensors(
        incTemp: 99.9,
        source: SensorDataSource.simulated,
      );

      expect(controller.sensorSource, SensorDataSource.simulated);
      expect(controller.sensorsAreLive, isFalse);
      expect(controller.incubatorTemperature, 99.9);

      controller.dispose();
    });
  });

  group('Sensor validity and chamber mapping (HW-02)', () {
    test('a null physical value (e.g. out-of-range rejected by the protocol) '
        'is stored as null and flagged as a sensor error', () {
      // Out-of-range → null conversion is performed by
      // ArduinoTelemetry.fromJson (lib/services/arduino_protocol.dart, already
      // covered by arduino_protocol_test.dart). The controller stores what it
      // is given and flags null chambers as sensor errors.
      final controller = IncubatorController();
      controller.updateSensors(
        incTemp: null,
        incHumidity: null,
        source: SensorDataSource.physical,
        receivedAt: DateTime.now(),
      );

      expect(controller.incubatorTemperature, isNull);
      expect(controller.incubatorHumidity, isNull);
      expect(controller.hasIncubatorSensorError, isTrue);

      controller.dispose();
    });

    test('NaN brooder reading triggers safety cutoff and sensor error', () {
      final controller = IncubatorController();
      controller.startBrooding();
      controller.updateSensors(
        broodTemp: double.nan,
        broodHumidity: 50.0,
        source: SensorDataSource.physical,
        receivedAt: DateTime.now(),
      );

      expect(controller.brooderBulbState, isFalse);
      expect(controller.brooderBuzzerAlarm, isTrue);
      expect(controller.hasBrooderSensorError, isTrue);

      controller.dispose();
    });

    test('physical source stays physical across repeated fresh frames', () {
      final controller = IncubatorController();
      final now = DateTime.now();
      controller.updateSensors(
        incTemp: 37.2,
        source: SensorDataSource.physical,
        receivedAt: now,
      );
      controller.updateSensors(
        incTemp: 37.8,
        source: SensorDataSource.physical,
        receivedAt: now.add(const Duration(seconds: 2)),
      );

      expect(controller.sensorSource, SensorDataSource.physical);
      expect(controller.sensorsAreLive, isTrue);
      expect(controller.incubatorTemperature, 37.8);

      controller.dispose();
    });
  });
}
