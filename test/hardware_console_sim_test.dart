import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';

/// The batch that is incubating RIGHT NOW: 12 chicken eggs started two
/// days ago. Built at call time so the "Day N" maths stays stable.
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

/// Stands in for the Supabase REST API with a STATEFUL session list: reads
/// honour `status=`, `id=` and `limit=` filters, and the completion PATCH is
/// applied to the stored row exactly like the real database would.
class _FakeSupabaseApi extends http.BaseClient {
  List<Map<String, dynamic>> sessions = [];
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    requests.add(row);

    if (row.method == 'PATCH' && row.url.path.contains('incubator_sessions')) {
      final id = row.url.queryParameters['id'];
      final value = id != null && id.startsWith('eq.') ? id.substring(3) : id;
      final body = jsonDecode(row.body) as Map<String, dynamic>;
      for (final s in sessions) {
        if ('${s['id']}' == value) s.addAll(body);
      }
      return http.StreamedResponse(
        const Stream.empty(),
        204,
        request: row,
        headers: {'content-type': 'application/json'},
      );
    }

    final wantsSingle =
        (row.headers['Accept'] ?? '').contains('vnd.pgrst.object+json');

    String body;
    if (row.url.path.contains('incubator_sessions')) {
      var rows = sessions;
      final status = row.url.queryParameters['status'];
      if (status != null) {
        final v = status.startsWith('eq.') ? status.substring(3) : status;
        rows = rows.where((s) => '${s['status']}' == v).toList();
      }
      final id = row.url.queryParameters['id'];
      if (id != null) {
        final v = id.startsWith('eq.') ? id.substring(3) : id;
        rows = rows.where((s) => '${s['id']}' == v).toList();
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

  setUp(() {
    // Each test asserts on the requests made by THAT test only.
    api.requests.clear();
  });

  /// Pumps [home] on a phone-sized surface and waits out the loads. Bounded
  /// pumps only: the console runs a 1s ticker that pumpAndSettle would chase.
  Future<void> pumpAt(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(450, 836);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: home));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
      'the console names the real batch and labels the simulator as '
      'simulation', (tester) async {
    api.sessions = [_activeRow()];
    await pumpAt(tester, const IncubatorDashboardPage());

    expect(find.text('Hardware Console'), findsOneWidget);

    // The ONE real batch is identified first, with its calculated day.
    expect(
      find.text('INCUBATING NOW \u00B7 Batch #9 \u00B7 Chicken'),
      findsOneWidget,
    );
    expect(find.text('Day 3 of 21 \u00B7 real saved batch'), findsOneWidget);

    // The simulator is labeled everywhere and its phase never claims to be
    // a real incubation.
    expect(find.text('SIMULATION'), findsOneWidget);
    expect(find.text('SIMULATOR PROFILE'), findsOneWidget);
    expect(find.text('ACTIVE PHASE'), findsOneWidget);
    expect(find.text('ACTIVE INCUBATION'), findsNothing);
    expect(find.text('Profile: Chicken'), findsOneWidget);
    expect(find.text('Species: Chicken'), findsNothing);
  });

  testWidgets(
      'with no real batch the console states that progress is simulated',
      (tester) async {
    api.sessions = [];
    await pumpAt(tester, const IncubatorDashboardPage());

    expect(
      find.textContaining('No real batch incubating'),
      findsOneWidget,
    );
    expect(find.textContaining('INCUBATING NOW'), findsNothing);
    expect(find.text('SIMULATION'), findsOneWidget);
    expect(find.text('SIMULATOR PROFILE'), findsOneWidget);
  });

  testWidgets(
      'switching the simulator profile never touches the real batch or '
      'the database', (tester) async {
    api.sessions = [_activeRow()];
    await pumpAt(tester, const IncubatorDashboardPage());

    // Change the simulated profile to Duck. (The chip label carries the
    // merged Day-7 candling suffix from development's controller work.)
    await tester.ensureVisible(find.text('28 Days (Day 7+)'));
    await tester.tap(find.text('28 Days (Day 7+)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The real batch is still the same chicken batch, untouched...
    expect(
      find.text('INCUBATING NOW \u00B7 Batch #9 \u00B7 Chicken'),
      findsOneWidget,
    );
    // ...while only the simulator preview switched.
    expect(find.text('Profile: Duck'), findsOneWidget);

    // Switching is purely local: not a single write left the app.
    expect(api.requests.where((r) => r.method != 'GET'), isEmpty);
    expect(api.sessions.single['status'], 'Active');
    expect(api.sessions.single['egg_type'], 'Chicken');
  });

  testWidgets('the real batch band opens the actual incubation screen',
      (tester) async {
    api.sessions = [_activeRow()];
    await pumpAt(tester, const IncubatorDashboardPage());

    await tester.ensureVisible(find.textContaining('INCUBATING NOW'));
    await tester.tap(find.textContaining('INCUBATING NOW'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ActiveIncubationScreen), findsOneWidget);
    expect(find.text('Batch #9'), findsOneWidget);
  });

  testWidgets('the profile dialog is clearly a simulator control',
      (tester) async {
    api.sessions = [];
    await pumpAt(tester, const IncubatorDashboardPage());

    await tester.tap(find.widgetWithText(TextButton, 'Chicken'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Simulator Profile'), findsOneWidget);
    expect(
      find.textContaining('changes the simulator only'),
      findsOneWidget,
    );
    expect(find.text('Select Species & Start Batch'), findsNothing);
  });

  testWidgets(
      'a batch finished from History details uses the same validated '
      'completion flow', (tester) async {
    api.sessions = [_activeRow()];
    await pumpAt(tester, const HistoryScreen());

    // The running batch is clearly identified in History: the amber Active
    // badge plus the in-progress wording, never a fabricated result line.
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Incubation in progress \u00B7 12 eggs'), findsOneWidget);
    expect(find.text('0 / 12 eggs hatched'), findsNothing);

    await tester.ensureVisible(find.text('View details'));
    await tester.tap(find.text('View details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The details screen offers the SAME finish flow as the active screen.
    expect(find.byType(BatchDetailsScreen), findsOneWidget);
    expect(find.text('View Current Incubation'), findsOneWidget);
    expect(find.text('Finish Batch'), findsOneWidget);
    // An incubating batch shows no fabricated results.
    expect(find.text('Hatched'), findsNothing);
    expect(find.text('Success Rate'), findsNothing);

    await tester.tap(find.text('Finish Batch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The validated dialog asks for the real hatched count.
    expect(find.text('Finish Batch #9'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    expect(find.text('Hatch success: 100%'), findsOneWidget);

    await tester
        .tap(find.widgetWithText(ElevatedButton, 'Finish Batch').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 300));

    // Exactly one completion UPDATE reached the database.
    final patch = api.requests.lastWhere((r) => r.method == 'PATCH');
    final body = jsonDecode(patch.body) as Map<String, dynamic>;
    expect(patch.url.queryParameters['id'], 'eq.9');
    expect(body['status'], 'Completed');
    expect(body['eggs_hatched'], 12);

    // Back on History, the reload shows the saved result immediately.
    expect(find.byType(BatchDetailsScreen), findsNothing);
    expect(find.text('12 / 12 eggs hatched'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Active'), findsNothing);
  });

  testWidgets('a completed batch offers no incubation controls',
      (tester) async {
    const completed = BatchData(
      id: 3,
      batchNumber: 'Batch #3',
      species: 'Quail',
      startDate: '2026-08-01',
      endDate: '2026-08-18',
      eggsTotal: 8,
      eggsHatched: 6,
      temperature: '37.5\u00B0C',
      status: 'Completed',
      isSuccess: true,
    );
    await pumpAt(tester, const BatchDetailsScreen(batch: completed));

    // Results are shown, but nothing can reopen or re-finish the batch.
    expect(find.text('Hatched'), findsOneWidget);
    expect(find.text('Success Rate'), findsOneWidget);
    expect(find.text('Finish Batch'), findsNothing);
    expect(find.text('View Current Incubation'), findsNothing);
  });

  group('Hardware Console across phone and desktop widths', () {
    for (final w in [320.0, 360.0, 412.0, 1024.0]) {
      testWidgets('real batch band and simulator labels@$w', (tester) async {
        api.sessions = [_activeRow()];
        tester.view.physicalSize = Size(w, 836);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Render the console while collecting any rendering errors so they
        // can be classified individually (same policy as
        // responsive_smoke_test.dart).
        final errors = <FlutterErrorDetails>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (d) => errors.add(d);
        try {
          await tester.pumpWidget(
              const MaterialApp(home: IncubatorDashboardPage()));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        } finally {
          FlutterError.onError = previous;
        }

        expect(find.text('Hardware Console'), findsOneWidget);
        expect(find.textContaining('INCUBATING NOW'), findsOneWidget);
        expect(find.text('SIMULATION'), findsOneWidget);
        expect(find.text('SIMULATOR PROFILE'), findsOneWidget);

        // Tolerate ONLY the documented 2x-placeholder-font overflow
        // warnings on untouched legacy rows (the Day row and chamber
        // headers fit comfortably in real Poppins - see the P3 findings in
        // responsive_smoke_test.dart's header). Every other rendering error
        // fails the test.
        for (final e in errors) {
          expect(
            e.exception.toString(),
            contains('A RenderFlex overflowed'),
            reason: '@$w: unexpected rendering error: ${e.exception}',
          );
        }
      });
    }
  });
}
