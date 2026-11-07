import 'dart:convert';

import 'package:egg_incubator_app/controllers/arduino_controller.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/models/confirmed_incubation_time.dart';
import 'package:egg_incubator_app/models/egg_turning_progress.dart';
import 'package:egg_incubator_app/models/farmer_notice.dart';
import 'package:egg_incubator_app/widgets/current_batch_overview.dart';
import 'package:egg_incubator_app/widgets/common/farmer_notice_card.dart';
import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:egg_incubator_app/screens/history/history_screen.dart';
import 'package:egg_incubator_app/screens/incubation/active_incubation_screen.dart';
import 'package:egg_incubator_app/screens/incubation/incubation_setup_screen.dart';
import 'package:egg_incubator_app/screens/incubation/incubation_checklist_screen.dart';
import 'package:egg_incubator_app/screens/species/species_screen.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/widgets/hardware/arduino_connection_card.dart';
import 'package:egg_incubator_app/widgets/hardware/live_incubator_status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryStorage implements GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) async => null;
  @override
  Future<void> setItem({required String key, required String value}) async {}
  @override
  Future<void> removeItem({required String key}) async {}
}

const _active = <String, dynamic>{
  'id': 91,
  'egg_type': 'Chicken',
  'egg_quantity': 12,
  'start_date': '2026-10-01T00:00:00Z',
  'end_date': null,
  'eggs_hatched': null,
  'temperature': 37.5,
  'status': 'Active',
};
const _completed = <String, dynamic>{
  'id': 90,
  'egg_type': 'Quail',
  'egg_quantity': 8,
  'start_date': '2026-08-01T00:00:00Z',
  'end_date': '2026-08-19T00:00:00Z',
  'eggs_hatched': 6,
  'temperature': 37.5,
  'status': 'Completed',
};

class _ReadOnlyApi extends http.BaseClient {
  List<Map<String, dynamic>> sessions = [];
  final requests = <http.BaseRequest>[];
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (request.method != 'GET') throw StateError('No writes allowed');
    var rows = <Map<String, dynamic>>[];
    if (request.url.path.endsWith('incubator_sessions')) {
      rows = List.of(sessions);
      for (final key in ['id', 'status']) {
        final filter = request.url.queryParameters[key];
        if (filter != null && filter.startsWith('eq.')) {
          rows = rows.where((r) => '${r[key]}' == filter.substring(3)).toList();
        }
      }
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '');
      if (limit != null) rows = rows.take(limit).toList();
    }
    final single = request.headers.entries.any(
      (e) =>
          e.key.toLowerCase() == 'accept' &&
          e.value.contains('vnd.pgrst.object+json'),
    );
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

void main() {
  final api = _ReadOnlyApi();
  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'test-placeholder-not-a-credential',
      httpClient: api,
      authOptions: FlutterAuthClientOptions(
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUri: false,
        pkceAsyncStorage: _MemoryStorage(),
      ),
    );
  });
  setUp(() {
    api.sessions = [];
    api.requests.clear();
  });

  Future<void> show(
    WidgetTester tester,
    Widget page, {
    double width = 390,
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 1400),
            textScaler: TextScaler.linear(scale),
          ),
          child: page,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Widget current() => ActiveIncubationScreen(
    species: defaultSpeciesList.first,
    eggCount: 12,
    batchId: 'Batch #91',
    sessionId: 91,
    startDate: DateTime.utc(2026, 10, 1),
  );

  for (final width in [320.0, 390.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('monitor is read-only and neutral at $width / $scale', (
        tester,
      ) async {
        api.sessions = [_active];
        await show(tester, current(), width: width, scale: scale);
        expect(find.byType(Switch), findsNothing);
        expect(find.byType(ArduinoConnectionCard), findsNothing);
        expect(find.text('INCUBATION CONTROLS'), findsNothing);
        expect(find.text('Open Hardware Console'), findsNothing);
        expect(find.byIcon(Icons.check_circle), findsNothing);
        expect(find.text('No incubator updates'), findsOneWidget);
        expect(find.text('—/21'), findsOneWidget);
        expect(find.textContaining('Day 31'), findsNothing);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('turning-progress')))
              .data,
          '—',
        );
        expect(
          find.descendant(
            of: find.byType(FarmerNoticeCard),
            matching: find.byIcon(Icons.warning_amber_rounded),
          ),
          findsOneWidget,
        );
        final finish = find.widgetWithText(ElevatedButton, 'Finish Batch');
        expect(
          tester
              .widget<ElevatedButton>(finish)
              .style!
              .backgroundColor!
              .resolve({}),
          AppColors.primaryDark,
        );
        expect(find.textContaining('does not switch off'), findsOneWidget);
        expect(api.requests.every((r) => r.method == 'GET'), isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'occupied setup has no New Incubation heading or forced-finish advice',
    (tester) async {
      api.sessions = [_active];
      await show(tester, const IncubationSetupScreen());
      expect(find.text('Your batch'), findsOneWidget);
      expect(find.text('Review your current batch'), findsOneWidget);
      expect(find.text('New Incubation'), findsNothing);
      expect(find.textContaining('Finish this record'), findsNothing);
      expect(find.textContaining('saved Active app record'), findsNothing);
    },
  );

  testWidgets('missing record does not get a completed/success check', (
    tester,
  ) async {
    await show(tester, current());
    expect(find.text('Batch record unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    expect(find.text('Finish Batch'), findsNothing);
  });

  testWidgets(
    'active screen groups metrics and keeps a warning outside the summary',
    (tester) async {
      api.sessions = [_active];
      final start = DateTime.utc(2026, 11, 1);
      await show(
        tester,
        ActiveIncubationScreen(
          species: defaultSpeciesList.first,
          eggCount: 12,
          batchId: 'Batch #91',
          sessionId: 91,
          startDate: start,
          confirmedTime: ConfirmedIncubationTime.fromVerifiedInstants(
            confirmedOriginalStartUtc: start,
            trustworthyNowUtc: start.add(const Duration(days: 7)),
          ),
          readingSnapshot: const ActualReadingSnapshot(
            state: ActualReadingState.fresh,
            temperature: 37.4,
            humidity: 55,
          ),
          turningProgress: const EggTurningProgress(
            completedTurns: 1,
            plannedTurns: 6,
            interval: Duration(hours: 4),
          ),
          notices: const [
            FarmerNotice(
              title: 'Test warning',
              message: 'Check the incubator.',
              tone: FarmerNoticeTone.warning,
            ),
          ],
        ),
      );
      expect(find.byType(CurrentBatchOverview), findsOneWidget);
      expect(find.text('8/21'), findsOneWidget);
      expect(find.text('1/6'), findsOneWidget);
      expect(find.text('37.4 °C'), findsOneWidget);
      expect(find.text('55.0 %'), findsOneWidget);
      expect(find.text('22 Nov 2026 · 8:00 AM'), findsOneWidget);
      expect(find.byType(FarmerNoticeCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CurrentBatchOverview),
          matching: find.byType(FarmerNoticeCard),
        ),
        findsNothing,
      );
      expect(api.requests.every((r) => r.method == 'GET'), isTrue);
    },
  );

  testWidgets('only a stored Completed outcome gets the green completed icon', (
    tester,
  ) async {
    api.sessions = [
      {..._active, 'status': 'Completed', 'eggs_hatched': 9},
    ];
    await show(tester, current());
    expect(find.text('This batch record is closed'), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.check_circle_outline)).color,
      AppColors.success,
    );
    expect(find.text('Finish Batch'), findsNothing);
  });

  testWidgets(
    'Change preset preserves egg quantity and resets only the manual checklist',
    (tester) async {
      await show(
        tester,
        IncubationSetupScreen(selectedSpecies: defaultSpeciesList.first),
      );
      await tester.ensureVisible(find.text('12 eggs'));
      await tester.tap(find.text('12 eggs'));
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('12 eggs • 21 days'), findsOneWidget);
      final tiles = find.byType(CheckboxListTile);
      for (var index = 0; index < 4; index++) {
        await tester.ensureVisible(tiles.at(index));
        await tester.tap(tiles.at(index));
        await tester.pump();
      }
      expect(find.text('Your checks are complete.'), findsOneWidget);
      expect(
        find.textContaining(
          'This version cannot send a Start command to the incubator.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Do not restart an incubation that is already running.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Start Incubation'),
            )
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.text('Change'));
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();
      expect(find.text('What are you hatching?'), findsOneWidget);
      await tester.ensureVisible(find.text('Duck'));
      await tester.tap(find.text('Duck'));
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      final checklist = tester.widget<IncubationChecklistScreen>(
        find.byType(IncubationChecklistScreen),
      );
      expect(checklist.species.name, 'Duck');
      expect(checklist.eggCount, 12);
      expect(
        tester
            .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
            .every((tile) => tile.value == false),
        isTrue,
      );
      expect(api.requests.every((r) => r.method == 'GET'), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Home reading summary offers no USB or manual-control shortcut', (
    tester,
  ) async {
    await show(
      tester,
      Scaffold(
        body: LiveIncubatorStatusCard(controller: ArduinoController.instance),
      ),
    );
    expect(find.textContaining('Bluetooth'), findsOneWidget);
    expect(find.byIcon(Icons.usb), findsNothing);
    expect(find.byIcon(Icons.usb_off), findsNothing);
    expect(find.text('Open Hardware Console'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets(
    'History expands locally and preserves counts/artwork without writes',
    (tester) async {
      api.sessions = [_active, _completed];
      await show(tester, const HistoryScreen(), width: 320, scale: 2);
      expect(find.text('6 / 8 eggs hatched'), findsNothing);
      await tester.ensureVisible(find.text('Batch #90'));
      await tester.tap(find.text('Batch #90'));
      await tester.pumpAndSettle();
      expect(find.text('6 / 8 eggs hatched'), findsOneWidget);
      expect(find.text('Hatchability: 75.0%'), findsOneWidget);
      expect(find.textContaining('Average'), findsNothing);
      expect(api.requests.every((r) => r.method == 'GET'), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  for (final species in defaultSpeciesList) {
    testWidgets(
      '${species.name} preset uses the same artwork and navigates without Start',
      (tester) async {
        await show(tester, const SpeciesScreen(), width: 320, scale: 2);
        final use = find.text('Use ${species.name} preset');
        await tester.ensureVisible(use);
        final art = find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName ==
                  'assets/species/${species.name.toLowerCase()}.png',
        );
        expect(art, findsOneWidget);
        await tester.tap(use);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<IncubationSetupScreen>(find.byType(IncubationSetupScreen))
              .selectedSpecies
              ?.name,
          species.name,
        );
        expect(api.requests.every((r) => r.method == 'GET'), isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
