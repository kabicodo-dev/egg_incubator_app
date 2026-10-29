import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A-02 contract check for lines captured from `SmartHatch_Combined.ino`.
///
/// The fixture is real captured output from the host harness
/// (`arduino/SmartHatch_Combined/host/ndjson_host_sim.cpp`), which compiles the
/// production sketch against shimmed AVR headers. It is software evidence only:
/// it does not prove relay, sensor, HC-05 or incubation behaviour.
void main() {
  const fixture = 'test/fixtures/firmware/combined_a02_capture.ndjson';
  const knownTypes = {'ack', 'running', 'telemetry', 'event'};

  late List<Map<String, dynamic>> frames;

  setUpAll(() {
    final bytes = File(fixture).readAsBytesSync();
    expect(bytes, isNotEmpty, reason: 'capture fixture must not be empty');
    expect(bytes.contains(13), isFalse,
        reason: 'A-02 framing is LF only; a CR byte is a framing regression');
    expect(bytes.last, 10, reason: 'capture must end with a single LF');

    final text = utf8.decode(bytes);
    final lines = text.split('\n')..removeLast();
    frames = <Map<String, dynamic>>[
      for (final line in lines) _decodeObject(line),
    ];
  });

  test('every line is exactly one versioned JSON object', () {
    expect(frames, isNotEmpty);
    for (var i = 0; i < frames.length; i++) {
      final frame = frames[i];
      expect(frame['v'], 1, reason: 'line ${i + 1}: v must be 1');
      expect(knownTypes, contains(frame['type']),
          reason: 'line ${i + 1}: unexpected type ${frame['type']}');
    }
  });

  test('acks are terminal and rejections carry a structured error', () {
    final acks = frames.where((f) => f['type'] == 'ack').toList();
    expect(acks, isNotEmpty);

    for (final ack in acks) {
      expect(ack['id'], isA<int>());
      expect(ack['cmd'], isA<String>());
      expect(ack['status'], anyOf('accepted', 'rejected'));

      if (ack['status'] == 'rejected') {
        final error = ack['error'];
        expect(error, isA<Map<String, dynamic>>(),
            reason: 'rejection must carry an error object');
        final map = error as Map<String, dynamic>;
        expect(map['code'], isA<String>());
        expect(map['code'], isNotEmpty);
        expect(map['message'], isA<String>());
        expect(map['message'], isNotEmpty);
        expect(ack.containsKey('message'), isFalse,
            reason: 'structured error replaces the free-text message');
      } else {
        expect(ack['message'], isA<String>());
        expect(ack.containsKey('error'), isFalse);
      }
    }
  });

  test('running is non-terminal and precedes the ack for the same id', () {
    final running = frames.where((f) => f['type'] == 'running').toList();
    expect(running, isNotEmpty, reason: 'capture must exercise in-flight state');

    for (final frame in running) {
      expect(frame['id'], isA<int>());
      expect(frame['cmd'], isA<String>());
      expect(frame.containsKey('status'), isFalse);
      expect(frame.containsKey('error'), isFalse);

      final runningIndex = frames.indexOf(frame);
      final ackIndex = frames.indexWhere(
        (f) => f['type'] == 'ack' && f['id'] == frame['id'],
        runningIndex + 1,
      );
      expect(ackIndex, greaterThan(runningIndex),
          reason: 'id ${frame['id']} received no terminal ack after running');
    }
  });

  test('a duplicate command id replays the terminal ack', () {
    final acks = frames
        .where((f) => f['type'] == 'ack' && f['id'] == 102)
        .toList();
    expect(acks, hasLength(2));
    expect(acks.every((f) => f['status'] == 'accepted'), isTrue);
    expect(acks.map((f) => f['message']).toSet(), {'turn_completed'});
  });

  test('line_too_long is reported as structured data', () {
    final codes = frames
        .where((f) => f['type'] == 'ack' && f['status'] == 'rejected')
        .map((f) => (f['error'] as Map<String, dynamic>)['code'])
        .toSet();
    expect(codes, contains('line_too_long'));
    expect(codes, contains('unknown_command'));
  });

  test('telemetry keeps day, live values and stale values distinct', () {
    final telemetry = frames.where((f) => f['type'] == 'telemetry').toList();
    expect(telemetry, isNotEmpty);

    for (final frame in telemetry) {
      final elapsed = frame['elapsed_seconds'] as int;
      expect(frame['day'], elapsed ~/ 86400 + 1,
          reason: 'Day N must be floor(elapsed_seconds / 86400) + 1');
      expect(frame['hatch_day'], isA<int>());

      for (final room in ['incubator', 'brooder']) {
        final block = frame[room] as Map<String, dynamic>;
        expect(block['valid'], isA<bool>());
        for (final key in ['temperature_c', 'humidity_percent']) {
          final value = block[key];
          expect(value == null || value is num, isTrue,
              reason: '$room.$key must be a number or null');
          if (block['valid'] == false) {
            expect(value, isNull,
                reason: 'stale $room.$key must not be reported as live');
          }
        }
      }
    }
  });
}

Map<String, dynamic> _decodeObject(String line) {
  expect(line, isNotEmpty, reason: 'blank line inside capture');
  final decoded = jsonDecode(line);
  expect(decoded, isA<Map<String, dynamic>>(),
      reason: 'line is not one JSON object: $line');
  return decoded as Map<String, dynamic>;
}
