import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases = <BackendReadingFreshness?, String>{
    BackendReadingFreshness.fresh: 'Reading up to date',
    BackendReadingFreshness.notUpdated: 'Reading not updated',
    BackendReadingFreshness.sensorUnavailable: 'Reading unavailable',
    BackendReadingFreshness.unknown: 'Reading time unavailable',
    null: 'Reading time unavailable',
  };

  Future<void> show(WidgetTester tester, ActualReadingSnapshot snapshot) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IncubatorReadings(
            reading: snapshot,
            // Synthetic test settings, not approved profiles.
            targetTemperature: 'target temperature fixture',
            targetHumidity: 'target humidity fixture',
          ),
        ),
      ),
    );
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(ValueKey(key))).data!;

  for (final entry in cases.entries) {
    testWidgets('backend ${entry.key} has distinct safe presentation', (
      tester,
    ) async {
      await show(
        tester,
        ActualReadingSnapshot.fromBackendClassification(
          freshness: entry.key,
          temperature: 36.2,
          humidity: 48,
        ),
      );
      expect(text(tester, 'reading-status-label'), entry.value);
      final fresh = entry.key == BackendReadingFreshness.fresh;
      expect(text(tester, 'actual-temperature'), fresh ? '36.2 °C' : '—');
      expect(text(tester, 'actual-humidity'), fresh ? '48.0 %' : '—');
      expect(text(tester, 'target-temperature'), '—');
      expect(find.text('Incubator disconnected'), findsNothing);
      expect(find.text('LIVE'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('verified disconnection is not Stop', (tester) async {
    await show(
      tester,
      ActualReadingSnapshot.fromBackendClassification(
        freshness: BackendReadingFreshness.fresh,
        temperature: 36.2,
        humidity: 48,
        verifiedIncubatorDisconnected: true,
      ),
    );
    expect(text(tester, 'reading-status-label'), 'Incubator disconnected');
    expect(text(tester, 'actual-temperature'), '—');
    expect(text(tester, 'actual-humidity'), '—');
    expect(find.textContaining('may still be running'), findsOneWidget);
  });

  testWidgets('mock transitions replace old values without replay or writes', (
    tester,
  ) async {
    for (final freshness in [
      BackendReadingFreshness.fresh,
      BackendReadingFreshness.notUpdated,
      BackendReadingFreshness.sensorUnavailable,
      BackendReadingFreshness.unknown,
      BackendReadingFreshness.fresh,
    ]) {
      await show(
        tester,
        ActualReadingSnapshot.fromBackendClassification(
          freshness: freshness,
          temperature: 36.2,
          humidity: 48,
        ),
      );
      expect(text(tester, 'reading-status-label'), cases[freshness]);
      expect(
        text(tester, 'actual-temperature'),
        freshness == BackendReadingFreshness.fresh ? '36.2 °C' : '—',
      );
      expect(find.byType(ElevatedButton), findsNothing);
    }
  });

  testWidgets('backend Fresh cannot make invalid measurements valid', (
    tester,
  ) async {
    await show(
      tester,
      ActualReadingSnapshot.fromBackendClassification(
        freshness: BackendReadingFreshness.fresh,
        temperature: double.nan,
        humidity: double.infinity,
      ),
    );
    expect(text(tester, 'actual-temperature'), '—');
    expect(text(tester, 'actual-humidity'), '—');
    expect(find.text('Some sensor readings are unavailable.'), findsOneWidget);
  });

  test('unverified transport loss and receipt age never establish Fresh', () {
    final reading = ActualReadingSnapshot.fromReceipt(
      connected: false,
      temperature: 36.2,
      humidity: 48,
      receivedAt: DateTime.utc(2026),
      now: DateTime.utc(2026),
      staleAfter: Duration.zero,
    );
    expect(reading.label, 'Reading unavailable');
    expect(
      const ActualReadingSnapshot(
        state: ActualReadingState.recentReceipt,
      ).label,
      'Reading time unavailable',
    );
  });
}
