import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

// Review-only, closed ASCII/integer fixture subset; not a general JCS library,
// raw JSON validator, Flutter service, database implementation or security test.
const fields = ['contract', 'device_id', 'batch_id', 'actor_installation_id',
  'result_id', 'original_manifest_sha256', 'eggs_hatched', 'action_time'];
const tuple = ['device_id', 'batch_id', 'actor_installation_id', 'result_id'];
int checks = 0;
void check(bool condition, String name) {
  if (!condition) throw StateError('FAIL: $name');
  checks++;
  print('PASS $name');
}
Map<String, dynamic> clone(Map value) =>
    Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);
String canonical(Object? x) {
  if (x == null) return 'null';
  if (x is String) {
    if (x.codeUnits.any((c) => c < 32 || c > 126)) {
      throw FormatException('Outside reviewed ASCII subset');
    }
    return jsonEncode(x);
  }
  if (x is int && x >= 0 && x <= 2147483647) return '$x';
  if (x is Map<String, dynamic>) {
    final keys = x.keys.toList()..sort();
    return '{${keys.map((k) => '${jsonEncode(k)}:${canonical(x[k])}').join(',')}}';
  }
  throw FormatException('Outside reviewed fixture subset');
}
Map<String, dynamic> core(Map x) => {for (final k in fields) k: x[k]};
String digest(Map x) => sha256.convert(utf8.encode(canonical(core(x)))).toString();
bool guard(Map response, Map request, Map ctx) {
  if (response['api_version'] != 2 || response['contract'] != request['contract']) return false;
  for (final k in tuple) {
    if (response[k] != request[k]) return false;
  }
  if (response['found'] is! bool) return false;
  if (response['found'] == false) return response['receipt'] == null;
  final r = response['receipt'];
  if (r is! Map) return false;
  for (final k in tuple) {
    if (r[k] != response[k] || r[k] != request[k]) return false;
  }
  final id = r['session_id'];
  return r['api_version'] == 2 && r['contract'] == request['contract'] &&
      r['receipt_revision'] == 1 && r['outcome'] == 'result_recorded' &&
      r['content_sha256'] == digest(request) &&
      r['original_manifest_sha256'] == request['original_manifest_sha256'] &&
      r['egg_quantity'] == ctx['manifest']['egg_quantity'] &&
      r['eggs_hatched'] == request['eggs_hatched'] &&
      r['lifecycle_effect'] == 'none' && r['physical_admission_effect'] == 'none' &&
      r['retention_ack'] == null && id is String &&
      RegExp(r'^[1-9][0-9]{0,18}$').hasMatch(id) &&
      BigInt.parse(id) <= BigInt.parse('9223372036854775807') &&
      id == ctx['session']['id'];
}
bool retryGuard(String code, bool retryable, String commitStatus) {
  final mayRetry = code == 'SERVICE_UNAVAILABLE' || code == 'COMMIT_UNKNOWN';
  return retryable == mayRetry &&
      commitStatus == (code == 'COMMIT_UNKNOWN' ? 'unknown' : 'not_persisted');
}
void main(List<String> args) {
  final f = jsonDecode(File(args.single).readAsStringSync()) as Map;
  final requests = f['requests'] as Map;
  for (final v in f['hashVectors'] as List) {
    final request = requests[v['name']] as Map;
    final bytes = utf8.encode(canonical(core(request)));
    check(utf8.decode(bytes) == v['canonical'], '${v['name']} canonical bytes');
    check(bytes.length == v['utf8Bytes'], '${v['name']} byte length');
    check(sha256.convert(bytes).toString() == v['sha256'], '${v['name']} SHA-256');
    print('VECTOR ${v['name']}: ${bytes.length} ${sha256.convert(bytes)}');
  }
  final original = requests['unknown_time_zero'] as Map;
  final uploader = clone(original)..['installation_id'] = '33333333-3333-4333-8333-333333333333';
  check(digest(uploader) == digest(original), 'uploader excluded from immutable hash');
  for (final k in ['eggs_hatched', 'actor_installation_id', 'original_manifest_sha256', 'action_time']) {
    final changed = clone(original);
    changed[k] = switch(k) {
      'eggs_hatched' => 1,
      'action_time' => {'value': '2026-10-30T00:00:00Z', 'provenance': 'phone_clock'},
      'original_manifest_sha256' => List.filled(64, 'b').join(),
      _ => '33333333-3333-4333-8333-333333333333',
    };
    check(digest(changed) != digest(original), '$k changes immutable hash');
  }
  final found = f['responses']['found'] as Map;
  final ctx = f['context'] as Map;
  check(guard(found, original, ctx), 'valid lookup and nested receipt');
  check(guard(f['responses']['absent'] as Map, original, ctx), 'valid absent lookup');
  for (final k in tuple) {
    final outer = clone(found)..[k] = 'ffffffff-ffff-4fff-8fff-ffffffffffff';
    check(!guard(outer, original, ctx), 'reject outer $k mismatch');
    final nested = clone(found);
    nested['receipt'][k] = 'ffffffff-ffff-4fff-8fff-ffffffffffff';
    check(!guard(nested, original, ctx), 'reject nested $k mismatch');
  }
  for (final entry in {
    'outcome': 'applied', 'receipt_revision': 2, 'session_id': null,
    'lifecycle_effect': 'Completed', 'physical_admission_effect': 'allowed',
    'content_sha256': List.filled(64, '0').join(),
  }.entries) {
    final wrong = clone(found);
    wrong['receipt'][entry.key] = entry.value;
    check(!guard(wrong, original, ctx), 'reject receipt ${entry.key}');
  }
  for (final code in ['INVALID_REQUEST','AUTHENTICATION_REQUIRED','NOT_AUTHORIZED',
      'MANIFEST_REQUIRED','BATCH_MAPPING_REQUIRED','COUNT_OUT_OF_RANGE',
      'MANIFEST_CONFLICT','LIFECYCLE_CONFLICT','IDENTITY_CONTENT_CONFLICT',
      'RESULT_ALREADY_RECORDED','CONTRACT_NOT_ENABLED']) {
    check(!retryGuard(code, true, 'not_persisted'), 'reject automatic retry for $code');
  }
  check(retryGuard('SERVICE_UNAVAILABLE', true, 'not_persisted'), 'service retry allowed');
  check(retryGuard('COMMIT_UNKNOWN', true, 'unknown'), 'unknown commit requires reconcile');
  check(!retryGuard('COMMIT_UNKNOWN', true, 'not_persisted'), 'reject false no-commit claim');
  print('REVIEW-ONLY PASS checks=$checks; vectors=2; no application/DB/security integration');
}
