import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/services/arduino_protocol.dart';

void main() {
  group('parseArduinoLine', () {
    test('parses a full telemetry frame', () {
      final message = parseArduinoLine(jsonEncode({
        'type': 'telemetry',
        'incubator': {'temperature': 37.6, 'humidity': 51.4},
        'brooder': {'temperature': 31.2, 'humidity': 49.0},
        'actuators': {
          'incubatorBulb': true,
          'incubatorHumidifier': false,
          'eggTurningServo': true,
        },
        'turning': {
          'active': true,
          'intervalMinutes': 240,
          'turnsToday': 3,
          'secondsSinceLastTurn': 812,
        },
      }));

      expect(message, isA<ArduinoTelemetryMessage>());
      final telemetry = (message as ArduinoTelemetryMessage).telemetry;
      expect(telemetry.incubatorTemperature, 37.6);
      expect(telemetry.incubatorHumidity, 51.4);
      expect(telemetry.brooderTemperature, 31.2);
      expect(telemetry.brooderHumidity, 49.0);
      expect(telemetry.actuators['incubatorBulb'], isTrue);
      expect(telemetry.actuators['exhaustFan'], isFalse);
      expect(telemetry.turningActive, isTrue);
      expect(telemetry.turnIntervalMinutes, 240);
      expect(telemetry.turnsToday, 3);
      expect(telemetry.secondsSinceLastTurn, 812);
    });

    test('treats out-of-range sensor values as unavailable', () {
      final message = parseArduinoLine(jsonEncode({
        'type': 'telemetry',
        'incubator': {'temperature': 250, 'humidity': -5},
        'brooder': {'temperature': 37.0, 'humidity': 50.0},
      }));
      final telemetry = (message! as ArduinoTelemetryMessage).telemetry;
      expect(telemetry.incubatorTemperature, isNull);
      expect(telemetry.incubatorHumidity, isNull);
      expect(telemetry.hasIncubatorSensorError, isTrue);
      expect(telemetry.brooderTemperature, 37.0);
      expect(telemetry.hasBrooderSensorError, isFalse);
    });

    test('parses sensor numbers given as strings', () {
      final message = parseArduinoLine(jsonEncode({
        'type': 'telemetry',
        'incubator': {'temperature': '37.5', 'humidity': '52'},
        'brooder': {'temperature': 30.0, 'humidity': 50.0},
      }));
      final telemetry = (message! as ArduinoTelemetryMessage).telemetry;
      expect(telemetry.incubatorTemperature, 37.5);
      expect(telemetry.incubatorHumidity, 52.0);
    });

    test('absent actuators default to false', () {
      final message =
          parseArduinoLine(jsonEncode({'type': 'telemetry'}));
      final telemetry = (message! as ArduinoTelemetryMessage).telemetry;
      expect(telemetry.actuators.keys, unorderedEquals(kActuatorNames));
      expect(telemetry.actuators.values.every((v) => v == false), isTrue);
      expect(telemetry.actuators['eggTurningServo'], isFalse);
      expect(telemetry.turningActive, isFalse);
      expect(telemetry.turnIntervalMinutes, 240);
    });

    test('scheduledTurnsPerDay derives from the reported interval', () {
      ArduinoTelemetry frame(int minutes) => ArduinoTelemetry.fromJson({
            'type': 'telemetry',
            'turning': {
              'active': true,
              'intervalMinutes': minutes,
            },
          });
      expect(frame(240).scheduledTurnsPerDay, 6);
      expect(frame(120).scheduledTurnsPerDay, 12);
      expect(frame(480).scheduledTurnsPerDay, 3);
    });

    test('parses an acknowledgement', () {
      final message = parseArduinoLine(jsonEncode({
        'type': 'ack',
        'id': 'cmd-123',
        'success': true,
        'actuator': 'incubatorBulb',
        'state': true,
      }));
      expect(message, isA<ArduinoAckMessage>());
      final ack = (message as ArduinoAckMessage).ack;
      expect(ack.id, 'cmd-123');
      expect(ack.success, isTrue);
      expect(ack.actuator, 'incubatorBulb');
      expect(ack.state, isTrue);
      expect(ack.hardwareVerified, isFalse);
    });

    test('rejects an unknown actuator in an ack', () {
      final message = parseArduinoLine(jsonEncode({
        'type': 'ack',
        'id': 'cmd-9',
        'success': true,
        'actuator': 'notAnActuator',
      }));
      expect((message! as ArduinoAckMessage).ack.actuator, isNull);
    });

    test('an ack without success is treated as a failure', () {
      final message = parseArduinoLine(jsonEncode({
        'type': 'ack',
        'id': 'cmd-1',
        'success': false,
        'error': 'Servo busy',
      }));
      final ack = (message! as ArduinoAckMessage).ack;
      expect(ack.success, isFalse);
      expect(ack.error, 'Servo busy');
    });

    test('returns unknown for an unrecognized message type', () {
      final message = parseArduinoLine(
          jsonEncode({'type': 'ping', 'value': 1}));
      expect(message, isA<ArduinoUnknownMessage>());
      expect((message as ArduinoUnknownMessage).type, 'ping');
    });

    test('returns malformed for invalid JSON', () {
      final message = parseArduinoLine('{this is not json');
      expect(message, isA<ArduinoMalformedMessage>());
    });

    test('returns malformed for a JSON array', () {
      final message = parseArduinoLine('[1, 2, 3]');
      expect(message, isA<ArduinoMalformedMessage>());
    });

    test('ignores blank lines', () {
      expect(parseArduinoLine(''), isNull);
      expect(parseArduinoLine('   '), isNull);
      expect(parseArduinoLine('\t\r\n'), isNull);
    });

    test('trims surrounding whitespace before parsing', () {
      final message =
          parseArduinoLine('  ${jsonEncode({'type': 'ack', 'success': true})}  ');
      expect(message, isA<ArduinoAckMessage>());
    });
  });

  group('ArduinoCommand', () {
    test('serializes to a single JSON line', () {
      const command = ArduinoCommand(
        id: 'cmd-42',
        actuator: 'exhaustFan',
        state: true,
      );
      final line = command.toJsonLine();
      expect(line.endsWith('\n'), isTrue);
      final decoded = jsonDecode(line.trim()) as Map<String, dynamic>;
      expect(decoded['type'], 'command');
      expect(decoded['id'], 'cmd-42');
      expect(decoded['actuator'], 'exhaustFan');
      expect(decoded['state'], isTrue);
    });
  });

  group('actuator registry', () {
    test('knows every canonical actuator and its pin', () {
      expect(kActuatorNames, hasLength(kActuatorLabels.length));
      expect(kActuatorNames, hasLength(kActuatorPins.length));
      for (final name in kActuatorNames) {
        expect(isValidActuator(name), isTrue, reason: name);
        expect(kActuatorPins, contains(name));
        expect(kActuatorLabels, contains(name));
      }
      expect(isValidActuator('warpCore'), isFalse);
    });
  });
}