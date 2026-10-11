import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';

/// Stands in for the Supabase REST API so the Start Incubation flow can be
/// tested without a live database. Requests that ask for a single row get an
/// object, everything else an empty list.
class _FakeSupabaseApi extends http.BaseClient {
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    requests.add(row);

    final wantsSingle =
        (row.headers['Accept'] ?? '').contains('vnd.pgrst.object+json');
    return http.StreamedResponse(
      Stream.value(utf8.encode(wantsSingle ? '{"id": 42}' : '[]')),
      200,
      request: row,
      headers: {'content-type': 'application/json'},
    );
  }

  /// The rows the app actually wrote to incubator_sessions.
  List<Map<String, dynamic>> get sessionInserts => requests
      .where((r) =>
          r.method == 'POST' && r.url.path.contains('incubator_sessions'))
      .map((r) => jsonDecode(r.body) as Map<String, dynamic>)
      .toList();

  int get sessionInsertCount => sessionInserts.length;
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

  void useScreen(WidgetTester tester) {
    // A little wider than the other suites: the placeholder test font renders
    // text noticeably wider than the app font, and the confirmation screen's
    // detail rows need the extra room. No production layout is involved.
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  test('a valid quantity is saved to incubator_sessions', () async {
    final sessionId = await SupabaseService().createSession(
      eggType: 'Chicken',
      startDate: DateTime(2026, 10, 2),
      eggQuantity: 12,
      temperature: 37.5,
    );

    expect(sessionId, 42);

    final insert = api.sessionInserts.last;
    expect(insert['egg_quantity'], 12);
    expect(insert['egg_type'], 'Chicken');
    expect(insert['status'], 'Active');
  });

  test('an invalid quantity is never inserted', () async {
    for (final value in [0, 1, 5, 13, 999]) {
      final before = api.sessionInsertCount;

      await expectLater(
        SupabaseService().createSession(
          eggType: 'Chicken',
          startDate: DateTime(2026, 10, 2),
          eggQuantity: value,
          temperature: 37.5,
        ),
        throwsA(isA<EggQuantityException>()),
      );

      expect(api.sessionInsertCount, before,
          reason: '$value eggs must not reach the database');
    }
  });

  testWidgets('the chosen quantity travels from the quantity screen to the '
      'database', (tester) async {
    useScreen(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: IncubationSetupScreen(
          selectedSpecies: SpeciesData(
            name: 'Chicken',
            emoji: '\uD83D\uDC14',
            incubationDays: 21,
            temperature: '37.5\u00B0C',
            targetHumidity: 55,
            description: 'Chicken eggs typically require 21 days.',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Quantity screen: pick the maximum capacity.
    await tester.tap(find.text('12 eggs'));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // 2. Checklist shows the same amount.
    expect(find.text('Incubation Checklist'), findsOneWidget);
    expect(find.text('12 eggs \u2022 21 days'), findsOneWidget);

    // 3. Complete the checklist and start the incubation.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byType(Checkbox).at(i));
      await tester.pump();
    }

    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Incubation'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // 4. The session was created with the chosen quantity.
    expect(find.text('Incubation Started!'), findsOneWidget);
    expect(find.text('Batch #42'), findsOneWidget);

    expect(api.sessionInsertCount, greaterThanOrEqualTo(1));
    expect(api.sessionInserts.last['egg_quantity'], 12);
    expect(api.sessionInserts.last['egg_type'], 'Chicken');
  });
}
