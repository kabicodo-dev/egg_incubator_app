import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A-06 contract check for START / ACK / RUNNING frames captured from
/// `SmartHatch_Combined.ino`.
///
/// The fixture is real captured output from
/// `arduino/SmartHatch_Combined/host/start_host_sim.cpp`, which compiles the
/// production sketch against shimmed AVR headers. It is software evidence only:
/// it does not prove relay contacts, DHT accuracy, HC-05 transport or physical
/// incubation. No board was flashed and no load was energised.
void main() {
  const fixture = 'test/fixtures/firmware/combined_a06_start_capture.ndjson';
  const acceptedMessages = {'start_received', 'start_already_running'};
  const rejectedCodes = {
    'invalid_batch_id',
    'batch_already_running',
    'batch_already_complete',
  };

  late List<Map<String, dynamic>> frames;
  late List<Map<String, dynamic>> startAcks;
  late List<Map<String, dynamic>> startRunning;

  setUpAll(() {
    final bytes = File(fixture).readAsBytesSync();
    expect(bytes, isNotEmpty, reason: 'capture fixture must not be empty');
    expect(bytes.contains(13), isFalse, reason: 'framing is LF only');
    expect(bytes.last, 10, reason: 'capture must end with a single LF');

    final lines = utf8.decode(bytes).split('\n')..removeLast();
    frames = [for (final line in lines) _decodeObject(line)];
    startAcks = frames
        .where((f) => f['type'] == 'ack' && f['cmd'] == 'START')
        .toList();
    startRunning = frames
        .where((f) => f['type'] == 'running' && f['cmd'] == 'START')
        .toList();
  });

  test('START ack carries command_id and batch_id', () {
    expect(startAcks, isNotEmpty);
    for (final ack in startAcks) {
      expect(ack['id'], isA<int>());
      expect(ack['command_id'], isA<int>());
      expect(ack['batch_id'], isA<int>());
      expect(ack['command_id'], ack['id'],
          reason: 'command_id must echo the command id');
      expect(ack['status'], anyOf('accepted', 'rejected'));

      if (ack['status'] == 'accepted') {
        expect(acceptedMessages, contains(ack['message']));
        expect(ack.containsKey('error'), isFalse);
      } else {
        final error = ack['error'];
        expect(error, isA<Map<String, dynamic>>());
        expect(rejectedCodes, contains((error as Map)['code']));
        expect(ack.containsKey('message'), isFalse);
      }
    }
  });

  test('RUNNING is a separate post-confirmation status with both identities',
      () {
    expect(startRunning, isNotEmpty);
    for (final running in startRunning) {
      expect(running['id'], isA<int>());
      expect(running['command_id'], isA<int>());
      expect(running['batch_id'], isA<int>());
      expect(running['command_id'], running['id']);
      expect(running['status'], 'running');

      final runningIndex = frames.indexOf(running);
      final ackIndex = frames.indexWhere(
        (f) =>
            f['type'] == 'ack' &&
            f['cmd'] == 'START' &&
            f['status'] == 'accepted' &&
            f['command_id'] == running['command_id'] &&
            f['batch_id'] == running['batch_id'],
      );
      expect(ackIndex, greaterThanOrEqualTo(0),
          reason: 'RUNNING must have a prior accepted ACK');
      expect(ackIndex, lessThan(runningIndex),
          reason: 'ACK receipt must precede RUNNING');
    }
  });

  test('first START is ACK receipt only, then RUNNING after confirmation', () {
    final firstAck = startAcks.first;
    expect(firstAck['message'], 'start_received');

    final firstAckIndex = frames.indexOf(firstAck);
    final firstRunningIndex = frames.indexWhere(
      (f) => f['type'] == 'running' && f['cmd'] == 'START',
    );
    expect(firstRunningIndex, greaterThan(firstAckIndex));

    // A batch_started event belongs between receipt and confirmation; it is
    // the proof that the batch timer was not started at ACK time.
    final between = frames.sublist(firstAckIndex + 1, firstRunningIndex);
    expect(between.any((f) => f['event'] == 'batch_started'), isTrue);
  });

  test('duplicate START id is idempotent and re-asserts RUNNING', () {
    final duplicateId = startAcks.first['id'];
    final duplicateAcks = startAcks.where((f) => f['id'] == duplicateId).toList();
    expect(duplicateAcks.length, greaterThanOrEqualTo(2));

    final secondAckIndex = frames.indexOf(duplicateAcks[1]);
    final nextRunningIndex = frames.indexWhere(
      (f) =>
          f['type'] == 'running' &&
          f['cmd'] == 'START' &&
          f['id'] == duplicateId,
      secondAckIndex + 1,
    );
    expect(nextRunningIndex, greaterThan(secondAckIndex));

    final between = frames.sublist(secondAckIndex + 1, nextRunningIndex);
    expect(
      between.any((f) => f['event'] == 'batch_started'),
      isFalse,
      reason: 'a duplicate START must not restart the batch',
    );
  });

  test('explicit rejections are structured and never emit RUNNING', () {
    final rejected =
        startAcks.where((f) => f['status'] == 'rejected').toList();
    expect(rejected, isNotEmpty);
    final codes = rejected
        .map((f) => (f['error'] as Map<String, dynamic>)['code'])
        .toSet();
    expect(codes, containsAll(rejectedCodes));

    for (final ack in rejected) {
      expect(
        startRunning.any((f) => f['id'] == ack['id']),
        isFalse,
        reason: 'rejected START id ${ack['id']} must not emit RUNNING',
      );
    }
  });

  test('RUNNING waits for a fresh valid sensor reading', () {
    const sensorCommandId = 306;
    final ackIndex = frames.indexWhere(
      (f) => f['type'] == 'ack' && f['cmd'] == 'START' && f['id'] == sensorCommandId,
    );
    final runningIndex = frames.indexWhere(
      (f) =>
          f['type'] == 'running' &&
          f['cmd'] == 'START' &&
          f['id'] == sensorCommandId,
    );
    expect(ackIndex, greaterThanOrEqualTo(0));
    expect(runningIndex, greaterThan(ackIndex));

    final invalidBetween = frames
        .sublist(ackIndex + 1, runningIndex)
        .where((f) =>
            f['type'] == 'telemetry' &&
            (f['incubator'] as Map<String, dynamic>)['valid'] == false)
        .toList();
    expect(invalidBetween, isNotEmpty,
        reason: 'RUNNING must not appear while the incubator sensor is invalid');
  });

  test('RUNNING waits for a control/telemetry pass on actuator mismatch', () {
    const actuatorCommandId = 308;
    final ackIndex = frames.indexWhere(
      (f) => f['type'] == 'ack' && f['cmd'] == 'START' && f['id'] == actuatorCommandId,
    );
    final runningIndex = frames.indexWhere(
      (f) =>
          f['type'] == 'running' &&
          f['cmd'] == 'START' &&
          f['id'] == actuatorCommandId,
    );
    expect(ackIndex, greaterThanOrEqualTo(0));
    expect(runningIndex, greaterThan(ackIndex));
    expect(
      frames.sublist(ackIndex + 1, runningIndex).any(
            (f) => f['type'] == 'telemetry',
          ),
      isTrue,
    );
  });

  test('EEPROM reload duplicate reuses batch identity without restart', () {
    const reloadCommandId = 309;
    final ackIndex = frames.indexWhere(
      (f) => f['type'] == 'ack' && f['cmd'] == 'START' && f['id'] == reloadCommandId,
    );
    final runningIndex = frames.indexWhere(
      (f) =>
          f['type'] == 'running' &&
          f['cmd'] == 'START' &&
          f['id'] == reloadCommandId,
    );
    expect(ackIndex, greaterThanOrEqualTo(0));
    expect(runningIndex, greaterThan(ackIndex));
    expect(
      frames
          .sublist(ackIndex + 1, runningIndex)
          .any((f) => f['event'] == 'batch_started'),
      isFalse,
    );
  });

  test('Day N stays tied to elapsed_seconds, not ACK receipt time', () {
    final telemetry =
        frames.where((f) => f['type'] == 'telemetry').toList();
    expect(telemetry, isNotEmpty);
    for (final frame in telemetry) {
      final elapsed = frame['elapsed_seconds'] as int;
      expect(frame['day'], elapsed ~/ 86400 + 1);
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
