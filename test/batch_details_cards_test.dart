import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/main.dart';

void main() {
  const batch = BatchData(
    id: 24,
    batchNumber: 'Batch #24',
    species: 'Quail',
    startDate: '2026-09-19',
    endDate: '',
    eggsTotal: 20,
    eggsHatched: 0,
    temperature: '37.7\u00B0C',
    status: 'Active',
    isSuccess: false,
  );

  testWidgets('Batch details shows the four status cards', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BatchDetailsScreen(batch: batch)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(find.text('BATCH STATUS'), findsOneWidget);

    // Card titles: two "Temperature" labels exist (summary row + card).
    expect(find.text('Temperature'), findsNWidgets(2));
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('Incubation Progress'), findsOneWidget);
    expect(find.text('Incubator Status'), findsOneWidget);

    // Every card always carries a value, even without sensor readings.
    expect(find.text('37.7\u00B0C'), findsNWidgets(2)); // session set point
    expect(find.text('58%'), findsOneWidget); // species target humidity
    expect(find.text('Set point'), findsOneWidget);
    expect(find.text('Standby'), findsOneWidget);
    expect(find.text('Waiting for sensor data'), findsOneWidget);

    // Incubation progress is derived from the start date (17-day species).
    final start = DateTime.parse(batch.startDate);
    var day = DateTime.now().difference(start).inDays;
    if (day < 0) day = 0;
    if (day > 17) day = 17;
    final percent = ((day / 17) * 100).round();

    expect(find.text('Day $day of 17'), findsOneWidget);
    expect(
      find.text('$percent%'),
      percent == 0 ? findsWidgets : findsOneWidget,
    );
  });

  testWidgets('Batch details handles a species without a preset match',
      (tester) async {
    const unknownSpecies = BatchData(
      id: 2,
      batchNumber: 'Batch #2',
      species: 'Goose',
      startDate: 'not-a-date',
      endDate: '',
      eggsTotal: 10,
      eggsHatched: 4,
      temperature: '',
      status: 'Active',
      isSuccess: false,
    );

    await tester.pumpWidget(
      const MaterialApp(home: BatchDetailsScreen(batch: unknownSpecies)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Incubation Progress'), findsOneWidget);
    expect(find.text('Day 0 of 21'), findsOneWidget);
    expect(find.text('37.5\u00B0C'), findsWidgets);
    expect(find.text('Standby'), findsOneWidget);
  });
}
