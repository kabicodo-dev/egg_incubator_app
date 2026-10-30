import 'package:egg_incubator_app/models/confirmed_incubation_time.dart';
import 'package:egg_incubator_app/widgets/confirmed_start_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime.utc(2026, 10, 29, 15, 59);

  ConfirmedIncubationTime at(Duration elapsed) =>
      ConfirmedIncubationTime.fromVerifiedInstants(
        confirmedOriginalStartUtc: start,
        trustworthyNowUtc: start.add(elapsed),
      );

  final boundaries = <Duration, int>{
    Duration.zero: 1,
    const Duration(hours: 23, minutes: 59): 1,
    const Duration(hours: 24): 2,
    const Duration(hours: 48): 3,
    const Duration(hours: 24, microseconds: -1): 1,
    const Duration(hours: 24, microseconds: 1): 2,
    const Duration(days: 40): 41,
  };
  for (final entry in boundaries.entries) {
    test('elapsed ${entry.key} gives Day ${entry.value}', () {
      expect(at(entry.key).day, entry.value);
      expect(at(entry.key).dayLabel, 'Day ${entry.value}');
    });
  }

  test('Manila midnight is not a 24-hour rollover', () {
    // 23:59 Manila -> 00:01 Manila, only two elapsed minutes.
    final time = at(const Duration(minutes: 2));
    expect(time.day, 1);
    expect(
      time.manilaStartLabel,
      '2026-10-29 23:59:00 Asia/Manila (UTC+08:00)',
    );
    expect(
      formatProjectManilaInstant(start.add(const Duration(minutes: 2))),
      '2026-10-30 00:01:00 Asia/Manila (UTC+08:00)',
    );
  });

  test('UTC midnight does not advance an elapsed day either', () {
    final time = ConfirmedIncubationTime.fromVerifiedInstants(
      confirmedOriginalStartUtc: DateTime.utc(2026, 10, 29, 23, 59),
      trustworthyNowUtc: DateTime.utc(2026, 10, 30, 0, 1),
    );
    expect(time.day, 1);
  });

  test('missing original Start never becomes Day 1 from a current time', () {
    final time = ConfirmedIncubationTime.fromVerifiedInstants(
      confirmedOriginalStartUtc: null,
      trustworthyNowUtc: start,
    );
    expect(time.day, isNull);
    expect(time.dayLabel, 'Waiting for confirmed start');
    expect(time.manilaStartLabel, isNull);
  });

  test('missing trusted clock or a future Start never clamps to Day 1', () {
    for (final now in [null, start.subtract(const Duration(seconds: 1))]) {
      final time = ConfirmedIncubationTime.fromVerifiedInstants(
        confirmedOriginalStartUtc: start,
        trustworthyNowUtc: now,
      );
      expect(time.day, isNull);
      expect(time.dayLabel, 'Waiting for trustworthy elapsed time');
    }
  });

  test('ambiguous local time inputs are not promoted to trusted UTC', () {
    final local = DateTime(2026, 10, 29, 15, 59);
    final badStart = ConfirmedIncubationTime.fromVerifiedInstants(
      confirmedOriginalStartUtc: local,
      trustworthyNowUtc: start,
    );
    expect(badStart.dayLabel, 'Waiting for confirmed start');
    final badNow = ConfirmedIncubationTime.fromVerifiedInstants(
      confirmedOriginalStartUtc: start,
      trustworthyNowUtc: local,
    );
    expect(badNow.day, isNull);
    expect(() => formatProjectManilaInstant(local), throwsArgumentError);
  });

  test('explicit offset instants normalize without losing original time', () {
    final utc = DateTime.parse('2026-10-29T23:59:00+08:00');
    expect(utc, start);
    expect(formatProjectManilaInstant(utc), at(Duration.zero).manilaStartLabel);
  });

  test('reconnect/receipt metadata cannot reset original Start', () {
    // The API deliberately has no receipt/reconnect/ACK/cloud-status inputs.
    final initial = at(const Duration(hours: 24));
    final later = at(const Duration(hours: 48));
    expect(initial.startUtc, later.startUtc);
    expect(initial.day, 2);
    expect(later.day, 3);
  });

  Future<void> show(WidgetTester tester, ConfirmedIncubationTime? time) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ConfirmedStartProgress(time: time)),
      ),
    );
  }

  testWidgets('unconfirmed progress shows waiting, not Day 1 or a percentage', (
    tester,
  ) async {
    await show(tester, null);
    expect(find.text('Waiting for confirmed start'), findsOneWidget);
    expect(find.text('Day 1'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('trusted snapshots advance at 24h, not midnight; show Manila', (
    tester,
  ) async {
    for (final elapsed in [
      Duration.zero,
      const Duration(minutes: 2),
      const Duration(hours: 23, minutes: 59),
      const Duration(hours: 24),
      const Duration(hours: 48),
    ]) {
      final time = at(elapsed);
      await show(tester, time);
      expect(find.text(time.dayLabel), findsOneWidget);
      expect(find.textContaining('Asia/Manila (UTC+08:00)'), findsOneWidget);
      expect(find.text('Completed'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}
