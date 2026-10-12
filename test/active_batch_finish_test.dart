import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';

/// The batch that is incubating RIGHT NOW: 8 chicken eggs started [daysAgo]
/// days ago. Built at call time so the "Day N" maths stays stable.
Map<String, dynamic> _activeRow({int daysAgo = 0, int quantity = 8}) {
  final start = DateTime.now().subtract(Duration(days: daysAgo));
  return <String, dynamic>{
    'id': 7,
    'egg_type': 'Chicken',
    'start_date': start.toIso8601String(),
    'end_date': null,
    'egg_quantity': quantity,
    'eggs_hatched': 0,
    'temperature': 37.5,
    'status': 'Active',
  };
}

/// Stands in for the Supabase REST API with a STATEFUL session list: session
/// queries honour `status=`, `id=` and `limit=` filters, and the completion
/// PATCH is applied to the stored row exactly like the real database would.
class _FakeSupabaseApi extends http.BaseClient {
  List<Map<String, dynamic>> sessions = [];
  bool failComplete = false;
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    requests.add(row);

    // completeSession: the single completion UPDATE.
    if (row.method == 'PATCH' && row.url.path.contains('incubator_sessions')) {
      if (failComplete) {
        return http.StreamedResponse(
          Stream.value(utf8.encode('{"message":"internal error"}')),
          500,
          request: row,
          headers: {'content-type': 'application/json'},
        );
      }
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
    api.failComplete = false;
    // Each test asserts on the requests made by THAT test only.
    api.requests.clear();
  });

  /// Pumps [home] on a phone-sized surface and waits out the loads.
  Future<void> pumpAt(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(450, 836);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: home));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
      'the incubation day is calculated from the saved start date, '
      'never a default', (tester) async {
    api.sessions = [_activeRow(daysAgo: 3)];
    await pumpAt(tester, activeIncubationScreenFor(api.sessions.first));

    expect(find.text('Day 4 of 21'), findsOneWidget);
    // The farmer can end this batch whenever they choose.
    expect(find.text('Finish Batch'), findsOneWidget);
    expect(
      find.textContaining('Finishing ends this incubation'),
      findsOneWidget,
    );
  });

  testWidgets(
      'finishing saves the exact hatched count and completes the batch',
      (tester) async {
    api.sessions = [_activeRow()];
    await pumpAt(tester, activeIncubationScreenFor(api.sessions.first));

    await tester.ensureVisible(find.text('Finish Batch'));
    await tester.tap(find.text('Finish Batch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The dialog opens with the batch details and a preview placeholder.
    expect(find.text('Finish Batch #7'), findsOneWidget);
    expect(find.textContaining('Chicken \u00B7 8 eggs'), findsOneWidget);
    expect(
      find.textContaining('Enter the hatched count to preview'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), '6');
    await tester.pump();
    expect(find.text('Hatch success: 75%'), findsOneWidget);

    await tester
        .tap(find.widgetWithText(ElevatedButton, 'Finish Batch').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 300));

    // Exactly one UPDATE: the entered count, Completed, a real timestamp.
    final patch =
        api.requests.lastWhere((r) => r.method == 'PATCH');
    final body = jsonDecode(patch.body) as Map<String, dynamic>;
    expect(patch.url.queryParameters['id'], 'eq.7');
    expect(body['status'], 'Completed');
    expect(body['eggs_hatched'], 6);
    expect(body['end_date'], isNotNull);

    // The farmer lands on a fresh dashboard: the batch is finished, so a
    // new incubation may start.
    expect(find.byType(ActiveIncubationScreen), findsNothing);
    expect(find.text('Start New Incubation'), findsOneWidget);

    // Drain the confirmation snackbar's auto-hide timer.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
      'invalid counts are rejected before anything is sent to the database',
      (tester) async {
    api.sessions = [_activeRow()];
    await pumpAt(tester, activeIncubationScreenFor(api.sessions.first));

    await tester.ensureVisible(find.text('Finish Batch'));
    await tester.tap(find.text('Finish Batch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    Future<void> check(String input) async {
      await tester.enterText(find.byType(TextField), input);
      await tester.pump();
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Finish Batch').last,
      );
      expect(button.onPressed, isNull, reason: 'input "$input" must be invalid');
    }

    await check('9'); // above the original 8 eggs
    expect(
      find.text('Enter a whole number from 0 to 8.'),
      findsOneWidget,
    );
    await check('-1'); // negative
    await check('abc'); // not a number
    await check(''); // nothing entered

    // Nothing ever reached the database.
    expect(api.requests.where((r) => r.method == 'PATCH'), isEmpty);
  });

  testWidgets('zero hatched eggs is a valid, saved result', (tester) async {
    api.sessions = [_activeRow()];
    await pumpAt(tester, activeIncubationScreenFor(api.sessions.first));

    await tester.ensureVisible(find.text('Finish Batch'));
    await tester.tap(find.text('Finish Batch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    expect(find.text('Hatch success: 0%'), findsOneWidget);

    await tester
        .tap(find.widgetWithText(ElevatedButton, 'Finish Batch').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final patch = api.requests.lastWhere((r) => r.method == 'PATCH');
    final body = jsonDecode(patch.body) as Map<String, dynamic>;
    expect(body['eggs_hatched'], 0);
    expect(body['status'], 'Completed');

    // Drain the confirmation snackbar's auto-hide timer.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a failed save keeps the batch incubating and explains why',
      (tester) async {
    api.sessions = [_activeRow()];
    api.failComplete = true;
    await pumpAt(tester, activeIncubationScreenFor(api.sessions.first));

    await tester.ensureVisible(find.text('Finish Batch'));
    await tester.tap(find.text('Finish Batch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField), '6');
    await tester.pump();
    await tester
        .tap(find.widgetWithText(ElevatedButton, 'Finish Batch').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // A clear error is shown and the dialog stays open for a retry.
    expect(
      find.textContaining('Could not save the results'),
      findsOneWidget,
    );
    expect(find.text('Finish Batch #7'), findsOneWidget);

    // The stored batch is untouched - still Active.
    expect(api.sessions.single['status'], 'Active');
    expect(api.sessions.single['eggs_hatched'], 0);
  });

  testWidgets(
      'an overdue batch is never completed automatically - only the '
      'farmer ends it', (tester) async {
    // Started 40 days ago: far beyond the 21-day cycle, yet the record is
    // still Active and nothing completes it by itself.
    api.sessions = [_activeRow(daysAgo: 40)];
    await pumpAt(tester, activeIncubationScreenFor(api.sessions.first));

    await tester.ensureVisible(find.text('Finish Batch'));
    expect(find.text('Finish Batch'), findsOneWidget);
    expect(api.requests.where((r) => r.method == 'PATCH'), isEmpty);
    expect(api.sessions.single['status'], 'Active');
  });

  testWidgets(
      'a batch that is already finished cannot be incubated or '
      're-completed', (tester) async {
    final row = _activeRow()
      ..addAll({
        'status': 'Completed',
        'end_date': DateTime.now().toIso8601String(),
        'eggs_hatched': 6,
      });
    api.sessions = [row];
    await pumpAt(tester, activeIncubationScreenFor(row));

    expect(find.text('This batch is no longer incubating'), findsOneWidget);
    expect(find.text('Finish Batch'), findsNothing);
    expect(find.text('Day 1 of 21'), findsNothing);
  });

  testWidgets('after a successful finish a new incubation can start',
      (tester) async {
    api.sessions = [_activeRow()];
    await pumpAt(tester, activeIncubationScreenFor(api.sessions.first));

    await tester.ensureVisible(find.text('Finish Batch'));
    await tester.tap(find.text('Finish Batch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), '7');
    await tester.pump();
    await tester
        .tap(find.widgetWithText(ElevatedButton, 'Finish Batch').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(api.sessions.single['status'], 'Completed');

    // Drain the confirmation snackbar's auto-hide timer.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(seconds: 1));

    // The farmer starts the next batch through Home's primary button, the
    // same path the app offers after a completion.
    await tester.tap(find.text('Start New Incubation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // With no Active row left, setup opens straight to the form.
    expect(find.text('What are you hatching?'), findsOneWidget);
    expect(find.text('A batch is already incubating'), findsNothing);
  });
}
