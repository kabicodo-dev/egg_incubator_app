// Independent parsed-object REVIEW MODEL only. Not a production/schema/parser implementation.
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

const contract = 'DB02-MANUAL-RESULT-0.2-review';
const tuple = ['device_id', 'batch_id', 'actor_installation_id', 'result_id'];
const coreFields = [...tuple, 'contract', 'original_manifest_sha256', 'eggs_hatched', 'action_time'];
const codes = ['INVALID_REQUEST', 'AUTHENTICATION_REQUIRED', 'NOT_AUTHORIZED', 'MANIFEST_REQUIRED', 'BATCH_MAPPING_REQUIRED', 'COUNT_OUT_OF_RANGE', 'MANIFEST_CONFLICT', 'LIFECYCLE_CONFLICT', 'IDENTITY_CONTENT_CONFLICT', 'RESULT_ALREADY_RECORDED', 'CONTRACT_NOT_ENABLED', 'SERVICE_UNAVAILABLE', 'COMMIT_UNKNOWN'];
int checks = 0;
void require(bool b) { if (!b) throw FormatException('Rejected review object'); }
void test(String name, bool Function() fn) { require(fn()); checks++; print('PASS $name'); }
void rejects(String name, void Function() fn) {
  bool rejected = false;
  try { fn(); } on FormatException { rejected = true; }
  test(name, () => rejected);
}
dynamic copy(dynamic x) => jsonDecode(jsonEncode(x));
Map<String, dynamic> obj(dynamic x) { require(x is Map<String, dynamic>); return x as Map<String, dynamic>; }
void keys(dynamic x, List<String> fields) {
  final m = obj(x); require(m.length == fields.length && fields.every(m.containsKey));
}
void base(dynamic x) { require(x['api_version'] is int && x['api_version'] == 2 && x['contract'] == contract); }
void uuid(dynamic x, [bool v4 = false]) {
  require(x is String && RegExp(v4 ? r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' : r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$').hasMatch(x));
}
void hash(dynamic x) { require(x is String && RegExp(r'^[0-9a-f]{64}$').hasMatch(x)); }
void count(dynamic x, [int min = 0]) { require(x is int && x >= min && x <= 2147483647); }
void utc(dynamic x) {
  require(x is String && RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$').hasMatch(x));
  final d = DateTime.tryParse(x); require(d != null && d.toIso8601String().replaceFirst('.000Z', 'Z') == x);
}
void request(dynamic x, bool submit) {
  keys(x, ['api_version', 'contract', 'operation', 'installation_id', ...tuple, if (submit) ...['original_manifest_sha256', 'eggs_hatched', 'action_time']]);
  base(x); uuid(x['installation_id']);
  for (final k in tuple) { uuid(x[k], k == 'batch_id' || k == 'result_id'); }
  require(x['operation'] == (submit ? 'submit_manual_result' : 'get_manual_result'));
  if (submit) {
    hash(x['original_manifest_sha256']); count(x['eggs_hatched']);
    final t = x['action_time']; keys(t, ['value', 'provenance']);
    if (t['provenance'] == 'unknown') { require(t['value'] == null); }
    else { require(t['provenance'] == 'phone_clock'); utc(t['value']); }
  }
}
String canonical(dynamic x) {
  if (x == null || x is int) return jsonEncode(x);
  if (x is String) { require(RegExp(r'^[\x20-\x7e]*$').hasMatch(x)); return jsonEncode(x); }
  final m = obj(x), ks = obj(x).keys.toList()..sort();
  return '{${ks.map((k) => '${jsonEncode(k)}:${canonical(m[k])}').join(',')}}';
}
String core(dynamic x) { request(x, true); return canonical({for (final k in coreFields) k: x[k]}); }
String digest(dynamic x) => sha256.convert(utf8.encode(core(x))).toString();
void receiptShape(dynamic r) {
  keys(r, ['api_version', 'contract', 'receipt_id', 'receipt_revision', ...tuple, 'original_manifest_sha256', 'content_sha256', 'egg_quantity', 'eggs_hatched', 'session_id', 'received_at', 'outcome', 'lifecycle_effect', 'physical_admission_effect', 'retention_ack']);
  base(r); uuid(r['receipt_id']); require(r['receipt_revision'] is int && r['receipt_revision'] == 1);
  for (final k in tuple) { uuid(r[k], k == 'batch_id' || k == 'result_id'); }
  hash(r['original_manifest_sha256']); hash(r['content_sha256']); count(r['egg_quantity'], 1); count(r['eggs_hatched']);
  require(r['session_id'] is String && RegExp(r'^[1-9][0-9]{0,18}$').hasMatch(r['session_id']));
  utc(r['received_at']);
  require(r['outcome'] == 'result_recorded' && r['lifecycle_effect'] == 'none' && r['physical_admission_effect'] == 'none' && r['retention_ack'] == null);
}
void lookupShape(dynamic r) {
  keys(r, ['api_version', 'contract', 'request_id', ...tuple, 'found', 'receipt']); base(r); uuid(r['request_id']);
  for (final k in tuple) { uuid(r[k], k == 'batch_id' || k == 'result_id'); }
  require(r['found'] is bool);
  if (r['found']) { receiptShape(r['receipt']); } else { require(r['receipt'] == null); }
}
void lookupGuard(dynamic r, dynamic q, dynamic original, dynamic context, [dynamic previous]) {
  lookupShape(r); request(q, false); request(original, true);
  for (final k in tuple) { require(q[k] == original[k] && r[k] == q[k]); }
  if (!r['found']) return; // Observation only: grants NO retry or persistence inference.
  final n = r['receipt'];
  for (final k in [...tuple, 'original_manifest_sha256', 'eggs_hatched']) { require(n[k] == original[k]); }
  require(n['content_sha256'] == digest(original));
  require(n['egg_quantity'] == context['manifest']['egg_quantity'] && n['eggs_hatched'] <= n['egg_quantity']);
  require(n['session_id'] == context['session']['id'] && BigInt.parse(n['session_id']) <= BigInt.parse('9223372036854775807'));
  if (previous != null) require(canonical(n) == canonical(previous));
}
void errorGuard(dynamic r) {
  keys(r, ['api_version', 'contract', 'request_id', 'error']); base(r); uuid(r['request_id']);
  final e = r['error']; keys(e, ['code', 'retryable', 'commit_status']); require(codes.contains(e['code']));
  require(e['retryable'] is bool && e['retryable'] == ['SERVICE_UNAVAILABLE', 'COMMIT_UNKNOWN'].contains(e['code']));
  require(e['commit_status'] == (e['code'] == 'COMMIT_UNKNOWN' ? 'unknown' : 'not_persisted'));
}
void main(List<String> args) {
  final f = jsonDecode(File(args.single).readAsStringSync());
  print('REVIEW ONLY: parsed-object model; no raw parser/schema/Auth/storage/integration proof');
  for (final v in f['hashVectors']) {
    final x = f['requests'][v['name']], text = core(x);
    test('${v['name']} canonical', () => text == v['canonical']);
    test('${v['name']} bytes', () => utf8.encode(text).length == v['utf8Bytes']);
    test('${v['name']} digest', () => digest(x) == v['sha256']);
    print('CANONICAL ${v['name']} $text');
    print('VECTOR ${v['name']} ${utf8.encode(text).length} ${digest(x)}');
  }
  final q = f['requests']['lookup'], s = f['requests']['unknown_time_zero'], c = f['context'];
  final found = f['responses']['found'], absent = f['responses']['absent'];
  void check(dynamic r, [dynamic prev]) => lookupGuard(r, q, s, c, prev);
  test('found accepted', () { check(found); return true; });
  test('absent accepted observation only', () { check(absent); return true; });
  test('unchanged receipt continuity', () { check(found, found['receipt']); return true; });
  final other = '99999999-9999-4999-8999-999999999999';
  for (final k in tuple) {
    for (final variant in ['found outer', 'absent outer', 'nested', 'outstanding', 'original']) {
      final r = copy(variant == 'absent outer' ? absent : found), a = copy(q), b = copy(s);
      if (variant.endsWith('outer')) r[k] = other;
      if (variant == 'nested') r['receipt'][k] = other;
      if (variant == 'outstanding') a[k] = other;
      if (variant == 'original') b[k] = other;
      rejects('$variant $k mismatch', () => lookupGuard(r, a, b, c));
    }
  }
  final mutations = <String, dynamic>{'content_sha256': 'b' * 64, 'original_manifest_sha256': 'b' * 64, 'egg_quantity': 13, 'eggs_hatched': 1, 'session_id': '9007199254740992', 'outcome': 'completed', 'receipt_revision': 2, 'lifecycle_effect': 'completed', 'physical_admission_effect': 'released', 'retention_ack': {}, 'received_at': '2026-02-30T00:00:00Z', 'receipt_id': 'bad', 'contract': 'DB02-MANUAL-RESULT-0.1-review', 'api_version': 1};
  for (final e in mutations.entries) {
    final r = copy(found); r['receipt'][e.key] = e.value;
    rejects('receipt ${e.key}', () => check(r));
  }
  for (final e in {'receipt_id': other, 'received_at': '2026-10-31T00:00:00Z'}.entries) {
    final r = copy(found); r['receipt'][e.key] = e.value;
    rejects('continuity ${e.key}', () => check(r, found['receipt']));
  }
  for (final n in ['outer extra', 'nested extra', 'missing receipt', 'false receipt', 'true null', 'found type', 'old contract', 'bad request_id', 'wrong api_version']) {
    final r = copy(found);
    switch (n) {
      case 'outer extra': r['extra'] = 1;
      case 'nested extra': r['receipt']['extra'] = 1;
      case 'missing receipt': r.remove('receipt');
      case 'false receipt': r['found'] = false;
      case 'true null': r['receipt'] = null;
      case 'found type': r['found'] = 'true';
      case 'old contract': r['contract'] = 'DB02-MANUAL-RESULT-0.1-review';
      case 'bad request_id': r['request_id'] = 'bad';
      case 'wrong api_version': r['api_version'] = 1;
    }
    rejects(n, () => check(r));
  }
  final maxContext = copy(c), maxFound = copy(found);
  maxContext['session']['id'] = maxFound['receipt']['session_id'] = '9223372036854775807';
  test('signed bigint max lossless', () { lookupGuard(maxFound, q, s, maxContext); return true; });
  maxContext['session']['id'] = maxFound['receipt']['session_id'] = '9223372036854775808';
  rejects('signed bigint overflow', () => lookupGuard(maxFound, q, s, maxContext));
  for (final code in codes) {
    final r = copy(f['responses']['unknown_commit']);
    r['error'] = {'code': code, 'retryable': ['SERVICE_UNAVAILABLE', 'COMMIT_UNKNOWN'].contains(code), 'commit_status': code == 'COMMIT_UNKNOWN' ? 'unknown' : 'not_persisted'};
    test('valid error $code', () { errorGuard(r); return true; });
    final badRetry = copy(r); badRetry['error']['retryable'] = !r['error']['retryable'];
    rejects('contradictory retry $code', () => errorGuard(badRetry));
    final badCommit = copy(r); badCommit['error']['commit_status'] = code == 'COMMIT_UNKNOWN' ? 'not_persisted' : 'unknown';
    rejects('contradictory commit $code', () => errorGuard(badCommit));
  }
  for (final n in ['unknown code', 'extra error', 'extra outer', 'missing retry', 'string retry', 'old contract', 'bad request_id', 'wrong api_version', 'null error']) {
    final r = copy(f['responses']['unknown_commit']);
    switch (n) {
      case 'unknown code': r['error']['code'] = 'NEW_UNKNOWN';
      case 'extra error': r['error']['extra'] = 1;
      case 'extra outer': r['extra'] = 1;
      case 'missing retry': r['error'].remove('retryable');
      case 'string retry': r['error']['retryable'] = 'true';
      case 'old contract': r['contract'] = 'DB02-MANUAL-RESULT-0.1-review';
      case 'bad request_id': r['request_id'] = 'bad';
      case 'wrong api_version': r['api_version'] = 1;
      case 'null error': r['error'] = null;
    }
    rejects('malformed error $n: no retry/commit inference', () => errorGuard(r));
  }
  final s2 = f['requests']['phone_time_upper'];
  test('same identity different content requires conflict', () => tuple.every((k) => s[k] == s2[k]) && digest(s) != digest(s2) && f['scenarioRelationship']['independentAlternatives'] == true && f['scenarioRelationship']['sequentialChangedContentExpected'] == 'IDENTITY_CONTENT_CONFLICT');
  test('M08 fixture reservation correspondence only', () => f['draftIdentity']['reservedAtFirstDurableDraft'] == s['result_id'] && f['draftIdentity']['reusedAtSeal'] == s['result_id']);
  print('REVIEW-ONLY PASS checks=$checks vectors=2; implementation acceptance NOT RUN');
}
