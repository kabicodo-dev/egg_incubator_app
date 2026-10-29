import 'dart:convert';

/// A-06 START / ACK / RUNNING contract.
///
/// The firmware ACK is a **receipt** acknowledgement only. The separate
/// RUNNING frame is emitted after the controller has confirmed fresh sensor
/// readings and relay output latches. This file is transport-independent so it
/// can be unit-tested and used by the future HC-05/app integration without
/// changing the current Supabase-first start flow.
///
/// The wire contract is `docs/a02_ndjson_serial_protocol.md` §A-06.
class StartCommand {
  final int commandId;
  final int batchId;

  const StartCommand({required this.commandId, required this.batchId});

  Map<String, dynamic> toJson() => {
        'id': commandId,
        'cmd': 'START',
        'batch_id': batchId,
      };

  String toJsonLine() => '${jsonEncode(toJson())}\n';
}

/// A receipt ACK for a START command.
///
/// [accepted] only means the firmware received/processed the START request. It
/// does not mean the batch is physically running; wait for [StartRunning].
class StartAck {
  final int commandId;
  final int batchId;
  final bool accepted;
  final String? message;
  final String? errorCode;

  const StartAck({
    required this.commandId,
    required this.batchId,
    required this.accepted,
    this.message,
    this.errorCode,
  });

  factory StartAck.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'ack' || json['cmd'] != 'START') {
      throw const FormatException('not a START ack');
    }
    final commandId = _requiredInt(json, 'command_id');
    final batchId = _requiredInt(json, 'batch_id');
    final id = _requiredInt(json, 'id');
    if (id != commandId) {
      throw const FormatException('command_id does not echo id');
    }
    final status = json['status'];
    if (status == 'accepted') {
      return StartAck(
        commandId: commandId,
        batchId: batchId,
        accepted: true,
        message: json['message'] as String?,
      );
    }
    if (status == 'rejected') {
      final error = json['error'];
      final code = error is Map ? error['code'] as String? : null;
      return StartAck(
        commandId: commandId,
        batchId: batchId,
        accepted: false,
        errorCode: code,
      );
    }
    throw const FormatException('START ack status must be accepted or rejected');
  }
}

/// A hardware-confirmed RUNNING status for a START command.
class StartRunning {
  final int commandId;
  final int batchId;

  const StartRunning({required this.commandId, required this.batchId});

  factory StartRunning.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'running' ||
        json['cmd'] != 'START' ||
        json['status'] != 'running') {
      throw const FormatException('not a confirmed START running frame');
    }
    final commandId = _requiredInt(json, 'command_id');
    final batchId = _requiredInt(json, 'batch_id');
    final id = _requiredInt(json, 'id');
    if (id != commandId) {
      throw const FormatException('command_id does not echo id');
    }
    return StartRunning(commandId: commandId, batchId: batchId);
  }
}

/// Tracks one START attempt.
///
/// [isRunning] is true only after a matching [StartRunning] has been received.
/// An accepted [StartAck] leaves the handshake in [isReceiptOnly]; that state
/// must never be reported to the user as running or as cloud `Active`.
class StartHandshake {
  final StartCommand command;

  bool _ackReceived = false;
  bool _running = false;
  String? _errorCode;

  StartHandshake(this.command);

  bool get ackReceived => _ackReceived;
  bool get isReceiptOnly => _ackReceived && !_running && _errorCode == null;
  bool get isRunning => _running;
  bool get failed => _errorCode != null;
  String? get errorCode => _errorCode;

  void onAck(StartAck ack) {
    if (ack.commandId != command.commandId) {
      throw StateError(
          'START command_id mismatch: expected ${command.commandId}, got ${ack.commandId}');
    }
    if (!ack.accepted) {
      // A rejection has no trustworthy running state; a missing/invalid
      // batch_id is reported as 0 by the firmware.
      _ackReceived = false;
      _running = false;
      _errorCode = ack.errorCode ?? 'start_rejected';
      return;
    }
    if (ack.batchId != command.batchId) {
      throw StateError(
          'START batch_id mismatch: expected ${command.batchId}, got ${ack.batchId}');
    }
    // A duplicate ACK for the same command id is idempotent.
    _ackReceived = true;
    _errorCode = null;
  }

  void onRunning(StartRunning running) {
    _checkIds(running.commandId, running.batchId);
    if (!_ackReceived || _errorCode != null) {
      throw StateError('START RUNNING arrived before an accepted receipt ACK');
    }
    _running = true;
  }

  void _checkIds(int commandId, int batchId) {
    if (commandId != command.commandId) {
      throw StateError(
          'START command_id mismatch: expected ${command.commandId}, got $commandId');
    }
    if (batchId != command.batchId) {
      throw StateError(
          'START batch_id mismatch: expected ${command.batchId}, got $batchId');
    }
  }
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw FormatException('$key must be an int');
}
