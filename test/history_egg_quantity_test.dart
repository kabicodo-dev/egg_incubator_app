import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';

/// A saved incubation session exactly as Supabase returns it: the farmer
/// chose 8 eggs when the batch was created, none have hatched yet.
const _savedSession = <String, dynamic>{
  'id': 7,
  'egg_type': 'Chicken',
  'start_date': '2026-09-19T10:00:00',
  'end_date': '2026-10-10T10:00:00',
  'egg_quantity': 8,
  'eggs_hatched': 0,
  'temperature': 37.5,
  'status': 'Active',
};

/// Stands in for the Supabase REST API so the real History screen can be
/// pumped with a known batch and no live database.
///
/// Session queries answer with the saved batch, everything else (live sensor
/// readings, species presets) with an empty result.
class _FakeSupabaseApi extends http.BaseClient {
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    requests.add(row);

    final wantsSingle =
        (row.headers['Accept'] ?? '').contains('vnd.pgrst.object+json');

    final String body;
    if (row.url.path.contains('incubator_sessions')) {
      body =
          wantsSingle ? jsonEncode(_savedSession) : jsonEncode([_savedSession]);
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
        // The default storage needs SharedPreferences, which no plugin
        // channel serves inside a test.
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
      debug: false,
    );
  });

  testWidgets('the History screen shows the saved egg quantity of a batch',
      (tester) async {
    // Phone-sized surface, same as the other suites.
    tester.view.physicalSize = const Size(450, 836);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The screen really fetched its batches instead of showing a mock.
    expect(api.requests, isNotEmpty);

    // The saved amount (egg_quantity = 8) is visible on the batch card.
    expect(find.text('Incubation History'), findsOneWidget);
    expect(find.text('Batch #7'), findsOneWidget);
    expect(find.text('Chicken'), findsOneWidget);
    expect(find.text('0 / 8 eggs hatched'), findsOneWidget);
    expect(find.text('No batches yet'), findsNothing);

    // The batch details screen belongs to the History flow and repeats the
    // saved quantity as the total eggs of the batch.
    await tester.tap(find.text('View details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Total Eggs'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });
}
