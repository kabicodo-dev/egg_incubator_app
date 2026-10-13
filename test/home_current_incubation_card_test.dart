import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';

/// The batch that is incubating RIGHT NOW: 12 chicken eggs started two
/// days ago. Built at call time so the "Day N" maths stays stable.
Map<String, dynamic> _activeSession() {
  final start = DateTime.now().subtract(const Duration(days: 2));
  return <String, dynamic>{
    'id': 9,
    'egg_type': 'Chicken',
    'start_date': start.toIso8601String(),
    'end_date': null,
    'egg_quantity': 12,
    'eggs_hatched': 0,
    'temperature': 37.5,
    'status': 'Active',
  };
}

/// A finished quail batch: 6 of 8 eggs hatched (75%).
const _completedSession = <String, dynamic>{
  'id': 3,
  'egg_type': 'Quail',
  'start_date': '2026-08-01T08:00:00',
  'end_date': '2026-08-18T08:00:00',
  'egg_quantity': 8,
  'eggs_hatched': 6,
  'temperature': 37.5,
  'status': 'Completed',
};

/// Stands in for the Supabase REST API. [sessions] is replaced per test and
/// answered in the order a real `order=start_date.desc` query would return
/// it; `status=`, `id=` and `limit=` query parameters are honoured so the
/// same fake also serves `getActiveSession`/`getSessionById`. Everything
/// else (sensor readings, presets) answers empty.
class _FakeSupabaseApi extends http.BaseClient {
  List<Map<String, dynamic>> sessions = [];
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    requests.add(row);

    final wantsSingle =
        (row.headers['Accept'] ?? '').contains('vnd.pgrst.object+json');

    String body;
    if (row.url.path.contains('incubator_sessions')) {
      var rows = sessions;
      final status = row.url.queryParameters['status'];
      if (status != null) {
        final value = status.startsWith('eq.') ? status.substring(3) : status;
        rows = rows.where((s) => '${s['status']}' == value).toList();
      }
      final id = row.url.queryParameters['id'];
      if (id != null) {
        final value = id.startsWith('eq.') ? id.substring(3) : id;
        rows = rows.where((s) => '${s['id']}' == value).toList();
      }
      final limit = row.url.queryParameters['limit'];
      if (limit != null) {
        rows = rows.take(int.tryParse(limit) ?? rows.length).toList();
      }
      body = wantsSingle
          ? (rows.isEmpty ? 'null' : jsonEncode(rows.first))
          : jsonEncode(rows);
    } else {
      body = wantsSingle ? '{"id": 42}' : '[]';
    }

    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      request: row,
      headers: {'content-type': 'application/json'},
    );
  }
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
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
      debug: false,
    );
  });

  /// Pumps Home on a phone-sized surface and waits for the batches to load.
  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(450, 836);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(api.requests, isNotEmpty);
  }

  testWidgets(
      'an active batch shows a Current Incubation card with real data and '
      'no Start button', (tester) async {
    api.sessions = [_activeSession()];
    await pumpHome(tester);

    // The card names the real batch, species, quantity and start date.
    expect(find.text('CURRENT INCUBATION'), findsOneWidget);
    expect(find.text('Batch #9 \u00B7 Chicken'), findsOneWidget);
    expect(find.textContaining('12 eggs \u00B7 Started'), findsOneWidget);
    expect(find.text('Day 3 of 21'), findsOneWidget);
    expect(find.text('18 days left'), findsOneWidget);
    expect(find.text('Incubating'), findsOneWidget);

    // The primary action opens the running batch - Start is not offered.
    expect(find.text('View Active Incubation'), findsOneWidget);
    expect(find.text('Start New Incubation'), findsNothing);

    // No completed batch exists yet, so Last Completed shows an empty state
    // instead of pretending the running batch is a finished result.
    await tester.ensureVisible(
        find.textContaining('No completed batches yet'));
    expect(
      find.textContaining('No completed batches yet'),
      findsOneWidget,
    );
  });

  testWidgets('the Current Incubation card opens the running batch',
      (tester) async {
    api.sessions = [_activeSession()];
    await pumpHome(tester);

    await tester.tap(find.text('Batch #9 \u00B7 Chicken'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(ActiveIncubationScreen), findsOneWidget);
    expect(find.text('Current Incubation'), findsOneWidget);
    expect(find.text('Batch #9'), findsOneWidget);
  });

  testWidgets('with no active batch Home offers Start New Incubation',
      (tester) async {
    api.sessions = [_completedSession];
    await pumpHome(tester);

    expect(find.text('Start New Incubation'), findsOneWidget);
    expect(find.text('View Active Incubation'), findsNothing);
    expect(find.text('CURRENT INCUBATION'), findsNothing);
    expect(find.text('No batches yet. Start your first incubation!'),
        findsNothing);
  });

  testWidgets(
      'Last Completed Batch shows only the completed batch, never the '
      'active one', (tester) async {
    // Newest first, as the real descending query returns it.
    api.sessions = [_activeSession(), _completedSession];
    await pumpHome(tester);

    expect(find.text('Batch #9 \u00B7 Chicken'), findsOneWidget);
    expect(find.text('View Active Incubation'), findsOneWidget);

    await tester.ensureVisible(find.text('View Details'));
    final lastCard = find
        .ancestor(of: find.text('View Details'), matching: find.byType(InkWell))
        .first;

    // The last-batch card holds the COMPLETED quail batch with its result...
    expect(
      find.descendant(of: lastCard, matching: find.text('Batch #3')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: lastCard, matching: find.text('75%')),
      findsOneWidget,
    );
    // ...and never the batch that is still incubating.
    expect(
      find.descendant(of: lastCard, matching: find.text('Batch #9')),
      findsNothing,
    );
  });

  testWidgets('with no batches at all Home offers Start and an empty state',
      (tester) async {
    api.sessions = [];
    await pumpHome(tester);

    expect(find.text('Start New Incubation'), findsOneWidget);
    expect(find.text('View Active Incubation'), findsNothing);
    expect(find.text('CURRENT INCUBATION'), findsNothing);

    await tester.ensureVisible(
        find.text('No batches yet. Start your first incubation!'));
    expect(
      find.text('No batches yet. Start your first incubation!'),
      findsOneWidget,
    );
  });
}
