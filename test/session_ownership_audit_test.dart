// BE-01 — Audit: session ownership and database rules.
//
// Characterization tests: they pin DOWN what ownership means today so that
// changing it becomes a conscious, test-visible decision.
//
//   * "one active batch" is scoped to the whole table - never to a user,
//     device or tab;
//   * a session row carries NO owner or device identity;
//   * reads are unscoped, so every client sees every batch;
//   * active_settings is a single global row shared by all clients;
//   * a completion targets a batch by id only (no status guard).
//
// These assert current behavior, not desired behavior: they are expected to
// fail once per-device ownership (migration M2 in
// docs/BE-01-session-ownership-audit.md) is approved and implemented.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/services/supabase_service.dart';

/// Identity column names that must never appear in today's queries or
/// payloads: their absence is what makes sessions globally owned.
const _identityKeys = ['user_id', 'device_id', 'owner_id', 'auth.uid'];

class _FakeSupabaseApi extends http.BaseClient {
  final List<http.Request> requests = [];

  /// Each active-batch GET shifts the next entry; an exhausted queue answers
  /// "no active batch".
  final List<List<Map<String, dynamic>>> activeResponses = [];

  /// Rows returned by an unscoped sessions read (History / getSessions).
  List<Map<String, dynamic>> sessionRows = const [];

  /// Whether the global settings row exists yet. When false the probe reads
  /// "no row", which is what lets a second first-write INSERT a second row.
  bool settingsRowExists = true;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    requests.add(row);

    if (row.url.path.contains('incubator_sessions')) {
      if (row.method == 'GET') {
        if (row.url.query.contains('status=eq.Active')) {
          final rows = activeResponses.isEmpty
              ? const []
              : activeResponses.removeAt(0);
          return _reply(row, jsonEncode(rows));
        }
        return _reply(row, jsonEncode(sessionRows));
      }
      if (row.method == 'POST') {
        return _reply(row, jsonEncode({'id': 42}));
      }
    }

    if (row.method == 'GET' && row.url.path.contains('active_settings')) {
      // An empty list makes maybeSingle() resolve to null, so the service
      // takes its INSERT branch (postgrest_builder.dart:509-511).
      return _reply(row, settingsRowExists ? '{"id": 42}' : '[]');
    }

    // Everything else (presets, active_settings, auth): benign defaults.
    final wantsSingle =
        (row.headers['Accept'] ?? '').contains('vnd.pgrst.object+json');
    return _reply(row, wantsSingle ? '{"id": 42}' : '[]');
  }

  http.StreamedResponse _reply(
    http.Request row,
    String body, {
    int status = 200,
  }) =>
      http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        status,
        request: row,
        headers: {'content-type': 'application/json'},
      );
}

/// Keeps Supabase's auth storage in memory: the real one needs
/// SharedPreferences, which no plugin channel serves inside a test.
class _MemoryAsyncStorage implements GotrueAsyncStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> getItem({required String key}) async => _store[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _store.remove(key);
  }
}

Map<String, dynamic> _sessionRow({
  required int id,
  required String species,
  required String status,
}) =>
    {
      'id': id,
      'egg_type': species,
      'start_date': '2026-10-11T10:58:51',
      'end_date': null,
      'egg_quantity': 8,
      'eggs_hatched': 0,
      'temperature': 37.5,
      'status': status,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final api = _FakeSupabaseApi();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'test-anon-key',
      httpClient: api,
      authOptions: FlutterAuthClientOptions(
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUri: false,
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
      debug: false,
    );
  });

  setUp(() {
    api.requests.clear();
    api.activeResponses.clear();
    api.sessionRows = const [];
    api.settingsRowExists = true;
  });

  group('BE-01 ownership characterization', () {
    test('the one-active check is scoped only by status, never by an owner',
        () async {
      api.activeResponses.add([
        _sessionRow(id: 7, species: 'Chicken', status: 'Active'),
      ]);

      final active = await SupabaseService().getActiveSession();
      expect(active?['id'], 7);

      final query = api.requests.last.url.query;
      expect(query, contains('status=eq.Active'),
          reason: 'only Active batches are considered');
      expect(query, contains('limit=1'),
          reason: 'the rule assumes at most one row');
      for (final key in _identityKeys) {
        expect(query, isNot(contains(key)),
            reason: 'today there is no owner to filter by: the rule is global');
      }
    });

    test('a session insert carries no owner or device identity', () async {
      api.activeResponses.add(const []);

      await SupabaseService().createSession(
        eggType: 'Duck',
        startDate: DateTime(2026, 10, 11),
        eggQuantity: 8,
        temperature: 37.5,
      );

      final insert = api.requests.firstWhere((r) =>
          r.method == 'POST' && r.url.path.contains('incubator_sessions'));
      final body = jsonDecode(insert.body) as Map<String, dynamic>;

      expect(
        body.keys,
        unorderedEquals(
            ['egg_type', 'start_date', 'egg_quantity', 'temperature', 'status']),
        reason: 'a row identifies its batch, not who or what started it',
      );
      for (final key in _identityKeys) {
        expect(body.containsKey(key), isFalse);
      }
    });

    test('History reads every batch regardless of who created it', () async {
      api.sessionRows = [
        _sessionRow(id: 1, species: 'Chicken', status: 'Completed'),
        _sessionRow(id: 2, species: 'Quail', status: 'Active'),
      ];

      final rows = await SupabaseService().getSessions();

      expect(rows, hasLength(2),
          reason: 'one shared history: nothing is filtered by owner');
      final query = api.requests.last.url.query;
      expect(query, contains('order=start_date.desc'));
      for (final key in _identityKeys) {
        expect(query, isNot(contains(key)));
      }
    });

    test('active_settings is a single global row shared by every client',
        () async {
      await SupabaseService().updateActiveSettings(
        eggType: 'Chicken',
        temperature: 37.5,
        humidity: 55,
        incubationDays: 21,
      );

      final probe = api.requests.first;
      expect(probe.method, 'GET');
      expect(probe.url.path, contains('active_settings'));
      expect(probe.url.query, contains('limit=1'),
          reason: 'there is exactly one row, and anyone may claim it');
      for (final key in _identityKeys) {
        expect(probe.url.query, isNot(contains(key)));
      }

      final writes =
          api.requests.where((r) => r.method != 'GET').toList(growable: false);
      expect(writes, hasLength(1),
          reason: 'one probe, then one write to that same global row');
      expect(writes.single.url.path, contains('active_settings'));
    });

    test('a second installation overwrites that same row (last writer wins)',
        () async {
      await SupabaseService().updateActiveSettings(
        eggType: 'Chicken',
        temperature: 37.5,
        humidity: 55,
        incubationDays: 21,
      );
      await SupabaseService().updateActiveSettings(
        eggType: 'Quail',
        temperature: 37.8,
        humidity: 50,
        incubationDays: 28,
      );

      final writes =
          api.requests.where((r) => r.method != 'GET').toList(growable: false);
      expect(writes, hasLength(2),
          reason: 'both installations update; neither creates a row');
      for (final write in writes) {
        expect(write.url.query, contains('id=eq.42'),
            reason: 'every installation writes ONE shared row - D3');
      }
      expect(
        utf8.decode(writes.last.bodyBytes),
        contains('Quail'),
        reason: 'the later write is the one that survives',
      );
    });

    test('two concurrent first-writes both INSERT (G2: no singleton '
        'constraint)', () async {
      // Neither installation has ever written settings, so both probes read
      // "no row" and both fall through to INSERT - there is no unique
      // constraint on active_settings to stop the second one.
      api.settingsRowExists = false;

      await SupabaseService().updateActiveSettings(
        eggType: 'Chicken',
        temperature: 37.5,
        humidity: 55,
        incubationDays: 21,
      );
      await SupabaseService().updateActiveSettings(
        eggType: 'Duck',
        temperature: 37.6,
        humidity: 50,
        incubationDays: 28,
      );

      final inserts = api.requests
          .where((r) =>
              r.method == 'POST' && r.url.path.contains('active_settings'))
          .toList(growable: false);
      expect(inserts, hasLength(2),
          reason: 'known gap G2: two rows can exist, so limit(1) becomes '
              'nondeterministic once anything reads them back');
    });

    test('a completion targets a batch by id only, with no status guard',
        () async {
      await SupabaseService().completeSession(sessionId: 5, eggsHatched: 10);

      final patch = api.requests.last;
      expect(patch.method, 'PATCH');
      expect(patch.url.query, contains('id=eq.5'));
      expect(patch.url.query, isNot(contains('status=eq')),
          reason: 'known gap G5: any row can be rewritten, not just Active');

      final body = jsonDecode(patch.body) as Map<String, dynamic>;
      expect(body['status'], 'Completed');
      expect(body['eggs_hatched'], 10);
    });
  });
}
