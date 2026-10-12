// UI-01: hatch results must never appear before the farmer has finished a
// batch. An Active batch's History card reads "Incubation in progress" with
// the chosen egg quantity; a Completed batch keeps its real hatched count
// and success percentage - including a genuine 0% result.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';

/// The batch that is incubating RIGHT NOW: 12 chicken eggs, none hatched
/// because no result has been entered yet.
Map<String, dynamic> _activeRow() {
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
const _completedRow = <String, dynamic>{
  'id': 3,
  'egg_type': 'Quail',
  'start_date': '2026-08-01T08:00:00',
  'end_date': '2026-08-18T08:00:00',
  'egg_quantity': 8,
  'eggs_hatched': 6,
  'temperature': 37.5,
  'status': 'Completed',
};

/// A finished batch where nothing hatched: a REAL 0% result that must be
/// shown, unlike the fake 0% of an incubating batch.
const _zeroHatchedRow = <String, dynamic>{
  'id': 2,
  'egg_type': 'Chicken',
  'start_date': '2026-07-01T08:00:00',
  'end_date': '2026-07-22T08:00:00',
  'egg_quantity': 10,
  'eggs_hatched': 0,
  'temperature': 37.5,
  'status': 'Completed',
};

/// Stands in for the Supabase REST API so the real History screen can be
/// pumped with known batches and no live database. Session queries answer
/// with the configured rows, everything else with an empty result.
class _FakeSupabaseApi extends http.BaseClient {
  List<Map<String, dynamic>> sessions = [];
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    requests.add(row);

    final wantsSingle =
        (row.headers['Accept'] ?? '').contains('vnd.pgrst.object+json');

    final String body;
    if (row.url.path.contains('incubator_sessions')) {
      body = wantsSingle
          ? (sessions.isEmpty ? 'null' : jsonEncode(sessions.first))
          : jsonEncode(sessions);
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

  /// Pumps History on a phone-sized surface and waits out the load.
  Future<void> pumpHistory(WidgetTester tester) async {
    tester.view.physicalSize = const Size(450, 836);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(api.requests, isNotEmpty);
  }

  testWidgets(
      'an active batch reads as incubation in progress, never a 0% result',
      (tester) async {
    api.sessions = [_activeRow()];
    await pumpHistory(tester);

    // The in-progress wording with the chosen egg quantity.
    expect(
      find.text('Incubation in progress \u00B7 12 eggs'),
      findsOneWidget,
    );
    // No result figures exist yet for a running batch.
    expect(find.text('0 / 12 eggs hatched'), findsNothing);
    expect(find.text('0%'), findsNothing);
    // The amber status badge identifies it as running.
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('a completed batch keeps its real hatch result', (tester) async {
    api.sessions = [_completedRow];
    await pumpHistory(tester);

    expect(find.text('6 / 8 eggs hatched'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Incubation in progress'), findsNothing);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('active and completed batches stay clearly distinct together',
      (tester) async {
    // Newest first, as the real descending query returns them.
    api.sessions = [_activeRow(), _completedRow];
    await pumpHistory(tester);

    expect(find.text('Incubation in progress \u00B7 12 eggs'), findsOneWidget);
    expect(find.text('6 / 8 eggs hatched'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets(
      'a completed batch with zero hatched still shows its real 0% result',
      (tester) async {
    api.sessions = [_zeroHatchedRow];
    await pumpHistory(tester);

    // The farmer-entered result of 0 hatched eggs is a genuine outcome and
    // must remain visible - the fix only removes PREMATURE results.
    expect(find.text('0 / 10 eggs hatched'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Incubation in progress'), findsNothing);
    expect(find.text('Completed'), findsOneWidget);
  });
}
