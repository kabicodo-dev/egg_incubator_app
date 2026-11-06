import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const targetTemperature = '37.5 °C';
  const targetHumidity = '55 %';
  final now = DateTime.utc(2026, 10, 29, 12);

  Future<void> showReading(
    WidgetTester tester,
    ActualReadingSnapshot reading, {
    String? temperatureTarget = targetTemperature,
    String? humidityTarget = targetHumidity,
    double width = 390,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: IncubatorReadings(
                reading: reading,
                targetTemperature: temperatureTarget,
                targetHumidity: humidityTarget,
                // Synthetic approval input; not a real species approval.
                targetsApproved: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String value(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(ValueKey(key))).data!;

  testWidgets(
    'classified fixture actuals and approved-fixture targets stay separate',
    (tester) async {
      await showReading(
        tester,
        const ActualReadingSnapshot(
          state: ActualReadingState.fresh,
          temperature: 36.2,
          humidity: 48,
        ),
      );
      expect(value(tester, 'actual-temperature'), '36.2 °C');
      expect(value(tester, 'actual-humidity'), '48.0 %');
      expect(value(tester, 'target-temperature'), targetTemperature);
      expect(value(tester, 'target-humidity'), targetHumidity);
      expect(find.textContaining('not confirmation'), findsOneWidget);
      expect(find.text('Current readings'), findsOneWidget);
      expect(find.text('Batch settings'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(Slider), findsNothing);
    },
  );

  for (final state in [
    ActualReadingState.stale,
    ActualReadingState.unknown,
    ActualReadingState.unavailable,
  ]) {
    testWidgets('$state hides retained numbers without substituting targets', (
      tester,
    ) async {
      await showReading(
        tester,
        ActualReadingSnapshot(state: state, temperature: 36.2, humidity: 48),
      );
      expect(value(tester, 'actual-temperature'), '—');
      expect(value(tester, 'actual-humidity'), '—');
      expect(value(tester, 'target-temperature'), targetTemperature);
      expect(value(tester, 'target-humidity'), targetHumidity);
      expect(find.text('36.2 °C'), findsNothing);
      expect(find.text('48.0 %'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final invalid in <double?>[null, double.nan, double.infinity]) {
    testWidgets('invalid actual $invalid never falls back to a target', (
      tester,
    ) async {
      await showReading(
        tester,
        ActualReadingSnapshot(
          state: ActualReadingState.fresh,
          temperature: invalid,
          humidity: invalid,
        ),
      );
      expect(value(tester, 'actual-temperature'), '—');
      expect(value(tester, 'actual-humidity'), '—');
      expect(
        find.text('Some sensor readings are unavailable.'),
        findsOneWidget,
      );
      expect(value(tester, 'target-temperature'), targetTemperature);
    });
  }

  testWidgets('one sensor failure leaves the other actual unchanged', (
    tester,
  ) async {
    await showReading(
      tester,
      const ActualReadingSnapshot(
        state: ActualReadingState.fresh,
        temperature: null,
        humidity: 0,
      ),
    );
    expect(value(tester, 'actual-temperature'), '—');
    expect(value(tester, 'actual-humidity'), '0.0 %');
  });

  testWidgets('unknown targets stay unknown, not copied from actuals', (
    tester,
  ) async {
    await showReading(
      tester,
      const ActualReadingSnapshot(
        state: ActualReadingState.fresh,
        temperature: 36.2,
        humidity: 48,
      ),
      temperatureTarget: null,
      humidityTarget: null,
    );
    expect(value(tester, 'target-temperature'), '—');
    expect(value(tester, 'target-humidity'), '—');
    expect(find.text('Batch settings are not available.'), findsOneWidget);
  });

  for (final width in [320.0, 390.0, 768.0, 1440.0]) {
    testWidgets('Actual/Target layout at $width and large text', (
      tester,
    ) async {
      await showReading(
        tester,
        const ActualReadingSnapshot(state: ActualReadingState.stale),
        width: width,
        textScale: 2,
      );
      expect(find.text('Reading not updated'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  ActualReadingSnapshot receipt({
    bool connected = true,
    DateTime? receivedAt,
  }) => ActualReadingSnapshot.fromReceipt(
    connected: connected,
    temperature: 36.2,
    humidity: 48,
    receivedAt: receivedAt,
    now: now,
    // Synthetic test parameter, not a proposed device/profile policy.
    staleAfter: const Duration(seconds: 6),
  );

  test('receipt time boundaries never become acquisition-time evidence', () {
    expect(receipt().state, ActualReadingState.unknown);
    expect(
      receipt(receivedAt: now.add(const Duration(seconds: 1))).state,
      ActualReadingState.unknown,
    );
    expect(receipt(receivedAt: now).state, ActualReadingState.recentReceipt);
    expect(
      receipt(receivedAt: now.subtract(const Duration(seconds: 6))).state,
      ActualReadingState.recentReceipt,
    );
    expect(
      receipt(receivedAt: now.subtract(const Duration(seconds: 7))).state,
      ActualReadingState.stale,
    );
    expect(
      receipt(connected: false, receivedAt: now).state,
      ActualReadingState.unavailable,
    );
  });
}
