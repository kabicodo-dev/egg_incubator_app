import 'package:egg_incubator_app/models/confirmed_incubation_time.dart';
import 'package:egg_incubator_app/models/egg_turning_progress.dart';
import 'package:egg_incubator_app/models/farmer_notice.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/widgets/common/farmer_notice_card.dart';
import 'package:egg_incubator_app/widgets/current_batch_overview.dart';
import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime.utc(2026, 11, 1);
  ConfirmedIncubationTime at(Duration elapsed) =>
      ConfirmedIncubationTime.fromVerifiedInstants(
        confirmedOriginalStartUtc: start,
        trustworthyNowUtc: start.add(elapsed),
      );
  const readings = ActualReadingSnapshot(
    state: ActualReadingState.fresh,
    temperature: 37.4,
    humidity: 55,
  );
  const turns = EggTurningProgress(
    completedTurns: 1,
    plannedTurns: 6,
    interval: Duration(hours: 4),
    untilNextTurn: Duration(hours: 2, minutes: 15),
  );

  Future<void> show(
    WidgetTester tester,
    Widget child, {
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
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 390.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('all metrics in one card at $width / $scale', (tester) async {
        final overview = CurrentBatchOverview(
          species: defaultSpeciesList.first,
          batchId: 'Batch #91',
          eggCount: 12,
          reading: readings,
          time: at(const Duration(days: 7)),
          turning: turns,
        );
        await show(tester, overview, width: width, scale: scale);
        final card = find.byKey(const ValueKey('current-batch-overview'));
        for (final label in ['Chicken', 'Batch #91', '12 eggs set']) {
          expect(
            tester.getCenter(find.text(label)).dx,
            closeTo(tester.getCenter(card).dx, 1),
            reason: 'Batch identity is centered',
          );
          expect(
            tester.widget<Text>(find.text(label)).textAlign,
            TextAlign.center,
          );
        }
        for (final value in [
          '8/21',
          '37.4 °C',
          '55.0 %',
          '1/6',
          '22 Nov 2026 · 8:00 AM',
        ]) {
          expect(
            find.descendant(of: card, matching: find.text(value)),
            findsOneWidget,
          );
        }
        expect(find.textContaining('Every 4 hours'), findsOneWidget);
        if (width >= 390 && scale == 1) {
          expect(
            tester.getTopLeft(find.text('Incubation day')).dy,
            tester.getTopLeft(find.text('Egg turning')).dy,
          );
          expect(
            tester.getCenter(find.text('Incubation day')).dx,
            lessThan(tester.getCenter(find.text('Egg turning')).dx),
          );
        }
        expect(find.text('Reading up to date'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('Reading up to date')).dy,
          lessThan(tester.getTopLeft(find.text('Temperature')).dy),
        );
        expect(find.textContaining('Next in 2 h 15 min'), findsOneWidget);
        expect(overview.notices, isEmpty);
        expect(find.byType(Switch), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final state in ActualReadingState.values) {
    testWidgets('Overview shows $state freshness directly above readings', (
      tester,
    ) async {
      final snapshot = ActualReadingSnapshot(
        state: state,
        temperature: 37.4,
        humidity: 55,
      );
      final overview = CurrentBatchOverview(
        species: defaultSpeciesList.first,
        batchId: 'Batch #91',
        eggCount: 12,
        reading: snapshot,
        time: at(const Duration(days: 7)),
        turning: turns,
      );
      await show(
        tester,
        Column(
          children: [
            overview,
            for (final notice in overview.notices)
              FarmerNoticeCard(notice: notice),
          ],
        ),
      );
      final status = find.byKey(const ValueKey('overview-reading-freshness'));
      expect(
        find.descendant(of: status, matching: find.text(snapshot.label)),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(status).dy,
        lessThan(tester.getTopLeft(find.text('Temperature')).dy),
      );
      if (state != ActualReadingState.fresh) {
        expect(
          find.descendant(
            of: status,
            matching: find.byIcon(Icons.warning_amber_rounded),
          ),
          findsOneWidget,
        );
        expect(find.text('37.4 °C'), findsNothing);
        expect(find.byType(FarmerNoticeCard), findsWidgets);
        expect(
          tester.getTopLeft(find.byType(FarmerNoticeCard).first).dy,
          greaterThanOrEqualTo(
            tester.getBottomLeft(find.byType(CurrentBatchOverview)).dy,
          ),
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('unknowns are dashes with a separate actionable warning', (
    tester,
  ) async {
    final overview = CurrentBatchOverview(
      species: defaultSpeciesList.first,
      batchId: 'Batch #91',
      eggCount: 12,
      reading: const ActualReadingSnapshot(
        state: ActualReadingState.unknown,
        temperature: 37.5,
        humidity: 55,
      ),
    );
    await show(
      tester,
      Column(
        children: [
          overview,
          ...overview.notices.map((n) => FarmerNoticeCard(notice: n)),
        ],
      ),
    );
    expect(find.text('—/21'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(4));
    expect(find.text('37.5 °C'), findsNothing);
    expect(find.text('0/6'), findsNothing);
    expect(find.text('No incubator updates'), findsOneWidget);
    expect(
      find.textContaining('Check the incubator and Bluetooth connection'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(CurrentBatchOverview),
        matching: find.byType(FarmerNoticeCard),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(FarmerNoticeCard),
        matching: find.byIcon(Icons.warning_amber_rounded),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
  });

  testWidgets('missing temperature does not hide valid humidity', (
    tester,
  ) async {
    final overview = CurrentBatchOverview(
      species: defaultSpeciesList.first,
      batchId: 'Batch #91',
      eggCount: 12,
      reading: const ActualReadingSnapshot(
        state: ActualReadingState.fresh,
        temperature: double.nan,
        humidity: 55,
      ),
      time: at(const Duration(days: 7)),
      turning: turns,
    );
    await show(tester, overview);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('actual-temperature')))
          .data,
      '—',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('actual-humidity'))).data,
      '55.0 %',
    );
    expect(overview.notices.single.title, 'Sensor readings unavailable');
  });

  testWidgets('days stay uncapped and a full time bar never means Completed', (
    tester,
  ) async {
    await show(
      tester,
      CurrentBatchOverview(
        species: defaultSpeciesList.first,
        batchId: 'Batch #91',
        eggCount: 12,
        reading: readings,
        time: at(const Duration(days: 25)),
        turning: turns,
      ),
    );
    expect(find.text('26/21'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, 1);
    expect(bar.color, AppColors.primaryDark);
    expect(find.text('Completed'), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
  });

  test(
    'confirmed start is needed for a hatch estimate; elapsed time for Day N',
    () {
      final unknown = CurrentBatchOverview(
        species: defaultSpeciesList.first,
        batchId: 'B',
        eggCount: 12,
        reading: readings,
      );
      expect(unknown.expectedHatchUtc, isNull);
      final knownStartOnly = CurrentBatchOverview(
        species: defaultSpeciesList.first,
        batchId: 'B',
        eggCount: 12,
        reading: readings,
        time: ConfirmedIncubationTime.fromVerifiedInstants(
          confirmedOriginalStartUtc: start,
          trustworthyNowUtc: null,
        ),
      );
      expect(knownStartOnly.dayText, '—/21');
      expect(
        knownStartOnly.expectedHatchUtc,
        start.add(const Duration(days: 21)),
      );
    },
  );

  test(
    'four-hour interval is six schedule slots, not four completed turns',
    () {
      expect(
        const Duration(days: 1).inHours ~/ const Duration(hours: 4).inHours,
        6,
      );
      expect(turns.countLabel, '1/6');
      expect(turns.intervalLabel, 'Every 4 hours');
      expect(
        const EggTurningProgress(interval: Duration(hours: 4)).countLabel,
        '—',
      );
    },
  );

  for (final counts in [(null, 6), (1, null), (-1, 6), (7, 6), (0, 0)]) {
    test('invalid/missing turning count $counts is not a made-up ratio', () {
      final input = EggTurningProgress(
        completedTurns: counts.$1,
        plannedTurns: counts.$2,
      );
      expect(input.hasValidCounts, isFalse);
      expect(input.countLabel, '—');
    });
  }

  for (final entry in <FarmerNoticeTone, (Color, IconData)>{
    FarmerNoticeTone.warning: (AppColors.warning, Icons.warning_amber_rounded),
    FarmerNoticeTone.error: (AppColors.danger, Icons.error_outline),
    FarmerNoticeTone.success: (AppColors.success, Icons.check_circle_outline),
    FarmerNoticeTone.information: (AppColors.textSecondary, Icons.info_outline),
  }.entries) {
    testWidgets('${entry.key} has a matching colour, icon and clear message', (
      tester,
    ) async {
      await show(
        tester,
        FarmerNoticeCard(
          notice: FarmerNotice(
            title: 'Example status',
            message: 'What happened. What to do next.',
            tone: entry.key,
          ),
        ),
        width: 320,
        scale: 2,
      );
      expect(
        tester.widget<Icon>(find.byIcon(entry.value.$2)).color,
        entry.value.$1,
      );
      expect(find.text('What happened. What to do next.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
