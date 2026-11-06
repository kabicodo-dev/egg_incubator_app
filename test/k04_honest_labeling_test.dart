import 'dart:convert';

import 'package:egg_incubator_app/main.dart';
import 'package:egg_incubator_app/models/app_derived_schedule.dart';
import 'package:egg_incubator_app/widgets/app_derived_schedule.dart';
import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class _ReadOnlyApi extends http.BaseClient {
  Object? start;
  int writes = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method != 'GET') {
      writes++;
      throw StateError('K-04 presentation must not write');
    }
    final sessions = request.url.path.endsWith('incubator_sessions');
    final single = (request.headers['Accept'] ?? '').contains(
      'vnd.pgrst.object+json',
    );
    final rows = sessions
        ? [
            {
              'id': 9,
              'egg_type': 'Chicken',
              'egg_quantity': 8,
              'status': 'Active',
              'start_date': start,
              'end_date': null,
              'eggs_hatched': null,
            },
          ]
        : <Map<String, dynamic>>[];
    return http.StreamedResponse(
      Stream.value(
        utf8.encode(
          jsonEncode(single ? (rows.isEmpty ? null : rows.first) : rows),
        ),
      ),
      200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}

class _MemoryStorage implements GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) async => null;
  @override
  Future<void> setItem({required String key, required String value}) async {}
  @override
  Future<void> removeItem({required String key}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final api = _ReadOnlyApi();
  final start = DateTime.utc(2026, 10, 29, 15, 59);
  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'test-fixture-not-a-credential',
      httpClient: api,
      debug: false,
      authOptions: FlutterAuthClientOptions(
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUri: false,
        pkceAsyncStorage: _MemoryStorage(),
      ),
    );
  });
  setUp(() {
    api.writes = 0;
    api.start = null;
  });
  tearDown(() => expect(api.writes, 0));

  for (final elapsed in [
    Duration.zero,
    const Duration(minutes: 2),
    const Duration(hours: 23, minutes: 59),
    const Duration(hours: 24),
    const Duration(hours: 48),
  ]) {
    test('app schedule uses 24h boundaries: $elapsed', () {
      final schedule = AppDerivedSchedule.fromStoredStart(
        start.toIso8601String(),
        start.add(elapsed),
      );
      expect(schedule.day, elapsed.inSeconds ~/ 86400 + 1);
      expect(schedule.label, startsWith('App-derived'));
    });
  }
  for (final invalid in <Object?>[
    null,
    '',
    'not a date',
    42,
    '2026-10-29',
    '2026-10-29T15:59:00',
    '2026-02-30T15:59:00Z',
    '2026-10-29T25:59:00Z',
    '2026-10-29T15:59:00+25:00',
    '2026-10-30T15:59:00Z',
  ]) {
    test(
      'invalid/missing/ambiguous/future start stays unavailable: $invalid',
      () {
        expect(
          AppDerivedSchedule.fromStoredStart(invalid, start).label,
          'Schedule unavailable',
        );
      },
    );
  }
  test('explicit Manila offset and UTC represent the same app schedule', () {
    expect(
      AppDerivedSchedule.fromStoredStart(
        '2026-10-29T23:59:00+08:00',
        start.add(const Duration(days: 1)),
      ).day,
      2,
    );
  });

  for (final width in [320.0, 390.0, 768.0, 1440.0]) {
    testWidgets('App-derived disclaimer wraps at $width with 2x text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: AppSchedule(
                  storedStart: start.toIso8601String(),
                  now: start.add(const Duration(days: 2)),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Saved start: 2026-10-29'), findsOneWidget);
      expect(
        find.textContaining('needs a confirmed start time'),
        findsOneWidget,
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'receipt-only actuals and unapproved numeric targets remain hidden',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncubatorReadings(
              reading: ActualReadingSnapshot.fromReceipt(
                connected: true,
                temperature: 36.2,
                humidity: 48,
                receivedAt: start,
                now: start,
                staleAfter: const Duration(seconds: 6),
              ), // existing test window, not approval
              targetTemperature: '37.5 °C',
              targetHumidity: '55 %',
            ),
          ),
        ),
      );
      for (final key in [
        'actual-temperature',
        'actual-humidity',
        'target-temperature',
        'target-humidity',
      ]) {
        expect(tester.widget<Text>(find.byKey(ValueKey(key))).data, '—');
      }
      expect(
        find.textContaining('reading time could not be checked'),
        findsOneWidget,
      );
      expect(find.text('Batch settings are not available.'), findsOneWidget);
    },
  );

  Future<void> show(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(450, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: page));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets(
    'console has no fabricated day, live LCD or physical activity claim',
    (tester) async {
      api.start = DateTime.now()
          .toUtc()
          .subtract(const Duration(days: 2))
          .toIso8601String();
      await show(tester, const IncubatorDashboardPage());
      expect(find.textContaining('SAVED APP BATCH'), findsOneWidget);
      expect(find.textContaining('Saved start:'), findsOneWidget);
      expect(find.textContaining('SIMULATION'), findsWidgets);
      expect(find.text('Day 7'), findsNothing);
      expect(find.textContaining('DAY: 7/21'), findsNothing);
      expect(find.textContaining('INCUBATING NOW'), findsNothing);
      expect(find.textContaining('Live physical LCD'), findsNothing);
      expect(find.text('ACTIVE'), findsNothing);
      expect(find.textContaining('not verified physical'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'current screen uses actual saved start, never route fallback date',
    (tester) async {
      api.start = 'bad date';
      await show(
        tester,
        ActiveIncubationScreen(
          species: defaultSpeciesList[0],
          eggCount: 8,
          batchId: 'Batch #9',
          sessionId: 9,
          startDate: start,
        ),
      );
      expect(find.text('—/21'), findsOneWidget);
      expect(find.text('App-derived · Day 1'), findsNothing);
      expect(find.text('No incubator updates'), findsOneWidget);
      expect(find.text('Normal'), findsNothing);
      expect(find.text('Everything looks good'), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'saved record confirmation invents neither Start nor hatch date',
    (tester) async {
      await show(
        tester,
        IncubationStartedScreen(
          species: defaultSpeciesList[0],
          eggCount: 8,
          sessionId: 9,
        ),
      );
      expect(find.text('Batch record saved'), findsOneWidget);
      expect(find.text('Not available yet'), findsOneWidget);
      expect(find.text('Incubation Started!'), findsNothing);
      expect(find.text('Your eggs are now incubating'), findsNothing);
    },
  );
}
