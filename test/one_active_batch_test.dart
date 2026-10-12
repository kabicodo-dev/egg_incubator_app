// P6.1 - ONE active incubation at a time, ONE fixed species per batch.
//
// Locks in the three enforcement layers of the one-active rule:
//   1. the service pre-check (a running batch of ANY species refuses a new
//      start before anything is written),
//   2. the database unique-index mapping (a lost race between devices or
//      tabs reads as the same farmer-friendly refusal, never a crash),
//   3. the UI guards (the Start button cannot double-submit, and the setup
//      screen blocks while a batch runs and guides the farmer to it).
//
// The egg-quantity rule stays untouched and still runs first.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';

/// A running batch exactly as Supabase returns it.
Map<String, dynamic> _activeRow({
  int id = 5,
  String species = 'Chicken',
  int quantity = 12,
}) =>
    {
      'id': id,
      'egg_type': species,
      'start_date': '2026-10-11T10:58:51',
      'end_date': null,
      'egg_quantity': quantity,
      'eggs_hatched': 0,
      'temperature': 37.5,
      'status': 'Active',
    };

/// Stands in for the Supabase REST API so the one-active rule can be tested
/// without a live database.
///
/// Active-batch checks are answered from a queue of responses (an exhausted
/// queue means "no active batch"), so a test can stage the exact sequence
/// behind a pre-check, a race, or a blocked screen.
class _FakeSupabaseApi extends http.BaseClient {
  final List<http.Request> requests = [];

  /// Each active-batch GET shifts the next entry; an exhausted queue (or an
  /// empty one) answers "no active batch".
  final List<List<Map<String, dynamic>>> activeResponses = [];

  /// When set, the session INSERT fails with this PostgREST error.
  ({int status, Map<String, dynamic> body})? insertError;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    requests.add(row);

    final isSessions = row.url.path.contains('incubator_sessions');
    final isActiveCheck = isSessions &&
        row.method == 'GET' &&
        row.url.query.contains('status=eq.Active');

    if (isActiveCheck) {
      final rows =
          activeResponses.isEmpty ? const [] : activeResponses.removeAt(0);
      return _reply(row, jsonEncode(rows));
    }
    if (isSessions && row.method == 'GET') {
      return _reply(row, '[]');
    }
    if (isSessions && row.method == 'POST') {
      final error = insertError;
      if (error != null) {
        return _reply(row, jsonEncode(error.body), status: error.status);
      }
      return _reply(row, jsonEncode({'id': 42}));
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

  int get sessionInserts => requests
      .where((r) =>
          r.method == 'POST' && r.url.path.contains('incubator_sessions'))
      .length;
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
        // The default storage needs SharedPreferences, which no plugin
        // channel serves inside a test.
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
      debug: false,
    );
  });

  setUp(() {
    api.requests.clear();
    api.activeResponses.clear();
    api.insertError = null;
  });

  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(450, 836);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> tickChecklist(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byType(Checkbox).at(i));
      await tester.pump();
    }
  }

  // ── Service layer ────────────────────────────────────────────────────────

  test('starting is refused while a batch of ANY species is incubating',
      () async {
    // A Chicken batch is running; the farmer tries to start a Duck batch.
    api.activeResponses.add([_activeRow(id: 3, species: 'Chicken')]);

    await expectLater(
      SupabaseService().createSession(
        eggType: 'Duck',
        startDate: DateTime(2026, 10, 11),
        eggQuantity: 8,
        temperature: 37.5,
      ),
      throwsA(isA<ActiveBatchException>().having(
        (e) => e.message,
        'message',
        allOf(contains('Batch #3 (Chicken)'), contains('still incubating')),
      )),
    );

    expect(api.sessionInserts, 0, reason: 'no session row may be written');
  });

  test('the egg quantity rule still runs before anything else', () async {
    await expectLater(
      SupabaseService().createSession(
        eggType: 'Chicken',
        startDate: DateTime(2026, 10, 11),
        eggQuantity: 3,
        temperature: 37.5,
      ),
      throwsA(isA<EggQuantityException>()),
    );
    expect(api.sessionInserts, 0);
  });

  test(
      'a lost one-active race (database unique index) reads as the same '
      'friendly refusal', () async {
    // The pre-check passes, another device inserts first, the database
    // unique index rejects the second insert with 23505, and the follow-up
    // read names the winning batch.
    api.activeResponses
      ..add([]) // pre-check: nothing running yet
      ..add([
        _activeRow(id: 9, species: 'Quail')
      ]); // the race winner, read back for the message
    api.insertError = (
      status: 409,
      body: {
        'code': '23505',
        'message':
            'duplicate key value violates unique constraint "incubator_sessions_single_active"',
        'details': 'Key (status)=(Active) already exists.',
        'hint': null,
      },
    );

    await expectLater(
      SupabaseService().createSession(
        eggType: 'Duck',
        startDate: DateTime(2026, 10, 11),
        eggQuantity: 8,
        temperature: 37.5,
      ),
      throwsA(isA<ActiveBatchException>().having(
        (e) => e.message,
        'message',
        contains('Batch #9 (Quail)'),
      )),
    );
  });

  test('a lost race without a readable winner still refuses cleanly',
      () async {
    api.activeResponses.add([]); // pre-check passes
    // No second entry: the follow-up read answers "no active batch".
    api.insertError = (
      status: 409,
      body: {'code': '23505', 'message': 'duplicate key', 'details': '', 'hint': null},
    );

    await expectLater(
      SupabaseService().createSession(
        eggType: 'Chicken',
        startDate: DateTime(2026, 10, 11),
        eggQuantity: 8,
        temperature: 37.5,
      ),
      throwsA(isA<ActiveBatchException>().having(
        (e) => e.message,
        'message',
        contains('another screen'),
      )),
    );
  });

  test('getActiveSession reads only the newest Active batch, at most one row',
      () async {
    api.activeResponses.add([_activeRow(id: 12, species: 'Duck')]);

    final active = await SupabaseService().getActiveSession();
    expect(active?['id'], 12);
    expect(active?['egg_type'], 'Duck');

    final check = api.requests.last;
    expect(check.url.query, contains('status=eq.Active'),
        reason: 'only the Active batch is considered');
    expect(check.url.query, contains('limit=1'),
        reason: 'never more than one row');

    expect(await SupabaseService().getActiveSession(), isNull,
        reason: 'an empty table means no batch is running');
  });

  // ── UI guards ────────────────────────────────────────────────────────────

  testWidgets('setup is blocked while a batch runs and guides the farmer to it',
      (tester) async {
    usePhoneScreen(tester);
    api.activeResponses.add([_activeRow(id: 5, species: 'Chicken')]);

    await tester.pumpWidget(const MaterialApp(home: IncubationSetupScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('A batch is already incubating'), findsOneWidget);
    expect(find.textContaining('Batch #5 (Chicken)'), findsOneWidget);
    expect(find.text('What are you hatching?'), findsNothing,
        reason: 'the setup form stays hidden');
    expect(find.text('Start Incubation'), findsNothing,
        reason: 'no start is offered while a batch runs');

    await tester
        .tap(find.widgetWithText(ElevatedButton, 'View Current Incubation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Current Incubation'), findsOneWidget,
        reason: 'the farmer lands on the running batch');
  });

  testWidgets('double-tapping Start creates exactly one session',
      (tester) async {
    usePhoneScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: IncubationChecklistScreen(
          species: chicken,
          eggCount: 8,
        ),
      ),
    );
    await tester.pump();
    await tickChecklist(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Incubation'));
    // Second tap while the first request is still in flight: the button is
    // already disabled, so the tap must be ignored.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Incubation'),
        warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(api.sessionInserts, 1, reason: 'one tap in flight - one session');
    expect(find.text('Incubation Started!'), findsOneWidget);

    // Hardware targets were written only AFTER the session row existed, so
    // a refused start can never overwrite a running batch's settings.
    final calls = api.requests
        .map((r) => '${r.method} ${r.url.path}')
        .toList(growable: false);
    final sessionPost = calls.indexOf('POST /rest/v1/incubator_sessions');
    final settingsWrite = calls.indexWhere((c) =>
        c.startsWith('PATCH /rest/v1/active_settings') ||
        c.startsWith('POST /rest/v1/active_settings'));
    expect(sessionPost, greaterThanOrEqualTo(0));
    expect(settingsWrite, greaterThan(sessionPost),
        reason: 'settings follow the successful insert');
  });

  testWidgets('a blocked Start shows the farmer-friendly refusal',
      (tester) async {
    usePhoneScreen(tester);
    api.activeResponses.add([_activeRow(id: 5, species: 'Chicken')]);

    await tester.pumpWidget(
      const MaterialApp(
        home: IncubationChecklistScreen(
          species: chicken,
          eggCount: 8,
        ),
      ),
    );
    await tester.pump();
    await tickChecklist(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Incubation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('is still incubating'), findsOneWidget,
        reason: 'the refusal reads as a plain sentence');
    expect(api.sessionInserts, 0,
        reason: 'the pre-check refused before any write');
  });
}

/// A fixed chicken description for the checklist tests; the screens render
/// species by name, so the shared default value is enough.
const chicken = SpeciesData(
  name: 'Chicken',
  emoji: '\uD83D\uDC14',
  incubationDays: 21,
  temperature: '37.5\u00B0C',
  targetHumidity: 55,
  description: 'Chicken eggs typically require 21 days of incubation.',
);
