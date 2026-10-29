import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/services/start_handshake.dart';

/// A-06 pure-Dart handshake tests. These prove the app-side state model keeps
/// ACK receipt separate from RUNNING. They do not prove hardware behaviour;
/// the firmware host capture is in `firmware_start_ack_running_test.dart`.
void main() {
  const command = StartCommand(commandId: 301, batchId: 7001);

  test('START serializes command_id and batch_id', () {
    expect(command.toJson(), {
      'id': 301,
      'cmd': 'START',
      'batch_id': 7001,
    });
    expect(command.toJsonLine(), endsWith('\n'));
    expect(jsonDecode(command.toJsonLine()), command.toJson());
  });

  test('accepted ACK is receipt only, never running', () {
    final handshake = StartHandshake(command);
    handshake.onAck(StartAck.fromJson({
      'type': 'ack',
      'v': 1,
      'id': 301,
      'command_id': 301,
      'batch_id': 7001,
      'cmd': 'START',
      'status': 'accepted',
      'message': 'start_received',
    }));

    expect(handshake.ackReceived, isTrue);
    expect(handshake.isReceiptOnly, isTrue);
    expect(handshake.isRunning, isFalse);
    expect(handshake.failed, isFalse);
  });

  test('RUNNING only becomes running after a matching receipt ACK', () {
    final handshake = StartHandshake(command);
    expect(
      () => handshake.onRunning(
        StartRunning.fromJson({
          'type': 'running',
          'v': 1,
          'id': 301,
          'command_id': 301,
          'batch_id': 7001,
          'cmd': 'START',
          'status': 'running',
        }),
      ),
      throwsStateError,
    );

    handshake.onAck(StartAck.fromJson({
      'type': 'ack',
      'v': 1,
      'id': 301,
      'command_id': 301,
      'batch_id': 7001,
      'cmd': 'START',
      'status': 'accepted',
      'message': 'start_received',
    }));
    handshake.onRunning(StartRunning.fromJson({
      'type': 'running',
      'v': 1,
      'id': 301,
      'command_id': 301,
      'batch_id': 7001,
      'cmd': 'START',
      'status': 'running',
    }));

    expect(handshake.isRunning, isTrue);
    expect(handshake.isReceiptOnly, isFalse);
  });

  test('duplicate ACK is idempotent', () {
    final handshake = StartHandshake(command);
    final ack = StartAck.fromJson({
      'type': 'ack',
      'v': 1,
      'id': 301,
      'command_id': 301,
      'batch_id': 7001,
      'cmd': 'START',
      'status': 'accepted',
      'message': 'start_received',
    });
    handshake.onAck(ack);
    handshake.onAck(ack);
    expect(handshake.ackReceived, isTrue);
    expect(handshake.isRunning, isFalse);
  });

  test('rejected ACK reports failure and forbids RUNNING', () {
    final handshake = StartHandshake(command);
    handshake.onAck(StartAck.fromJson({
      'type': 'ack',
      'v': 1,
      'id': 301,
      'command_id': 301,
      'batch_id': 7001,
      'cmd': 'START',
      'status': 'rejected',
      'error': {'code': 'batch_already_running', 'message': 'busy'},
    }));

    expect(handshake.failed, isTrue);
    expect(handshake.errorCode, 'batch_already_running');
    expect(handshake.isRunning, isFalse);
    expect(
      () => handshake.onRunning(const StartRunning(commandId: 301, batchId: 7001)),
      throwsStateError,
    );
  });

  test('rejected invalid_batch_id may carry batch_id 0', () {
    final handshake = StartHandshake(command);
    handshake.onAck(StartAck.fromJson({
      'type': 'ack',
      'v': 1,
      'id': 301,
      'command_id': 301,
      'batch_id': 0,
      'cmd': 'START',
      'status': 'rejected',
      'error': {'code': 'invalid_batch_id', 'message': 'bad id'},
    }));
    expect(handshake.failed, isTrue);
    expect(handshake.errorCode, 'invalid_batch_id');
    expect(handshake.isRunning, isFalse);
  });

  test('mismatched command_id or batch_id is rejected', () {
    final handshake = StartHandshake(command);
    expect(
      () => handshake.onAck(const StartAck(
        commandId: 999,
        batchId: 7001,
        accepted: true,
      )),
      throwsStateError,
    );
    expect(
      () => handshake.onAck(const StartAck(
        commandId: 301,
        batchId: 999,
        accepted: true,
      )),
      throwsStateError,
    );
  });

  test('wire parsers reject the wrong message role', () {
    expect(
      () => StartAck.fromJson({
        'type': 'running',
        'id': 301,
        'command_id': 301,
        'batch_id': 7001,
        'cmd': 'START',
        'status': 'running',
      }),
      throwsFormatException,
    );
    expect(
      () => StartRunning.fromJson({
        'type': 'ack',
        'id': 301,
        'command_id': 301,
        'batch_id': 7001,
        'cmd': 'START',
        'status': 'accepted',
      }),
      throwsFormatException,
    );
  });
}
