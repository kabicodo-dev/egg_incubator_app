import 'dart:convert';
import 'dart:io';

import 'package:egg_incubator_app/services/arduino_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

// Characterizations of the ACTUAL current Flutter parser, not a new decoder or
// proof that either review catalog is active/approved. Fixtures are never sent.
List<String> referenceLines(String name) => File(
  'test/fixtures/integration/$name',
).readAsLinesSync().where((line) => line.isNotEmpty).toList();

void main() {
  group('INT-08 actual Flutter parser / unselected review fixtures', () {
    test('all compact t-family review frames remain unsupported today', () {
      final lines = referenceLines('hw02_batch_review.ndjson');
      expect(lines, hasLength(14));
      for (final line in lines) {
        expect(parseArduinoLine(line), isA<ArduinoUnknownMessage>());
      }
    });

    test('corrected status ACK does not imply current parser success', () {
      final lines = referenceLines('hw02_corrected_review.ndjson');
      final parsed = parseArduinoLine(lines[2]) as ArduinoAckMessage;
      expect(parsed.ack.id, 'BBBBBBBBBBBBBBBBBBBBBBB');
      expect(parsed.ack.success, isFalse); // no supported success field
      expect(parsed.ack.hardwareVerified, isFalse);
    });

    test(
      'corrected sensors envelope does not populate actual incubator values',
      () {
        final parsed =
            parseArduinoLine(referenceLines('hw02_corrected_review.ndjson')[1])
                as ArduinoTelemetryMessage;
        expect(parsed.telemetry.incubatorTemperature, isNull);
        expect(parsed.telemetry.incubatorHumidity, isNull);
        expect(parsed.telemetry.hasIncubatorSensorError, isTrue);
      },
    );

    test('hello and event review families have no implemented decoder', () {
      final lines = referenceLines('hw02_corrected_review.ndjson');
      for (final index in [3, 4, 5]) {
        expect(parseArduinoLine(lines[index]), isA<ArduinoUnknownMessage>());
      }
    });

    test('kit cannot assert a selected active firmware or catalog', () {
      final manifest =
          jsonDecode(
                File(
                  'test/fixtures/integration/int_imp_01_sources.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final selected =
          manifest['active_implementation'] as Map<String, dynamic>;
      expect(selected['firmware_commit'], isNull);
      expect(selected['catalog_revision'], isNull);
    });
  });
}
