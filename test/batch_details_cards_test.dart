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

    expect(find.text('Configured Temperature'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('Incubation Progress'), findsOneWidget);
    expect(find.text('Incubator Status'), findsOneWidget);

    // The session setting remains available, but never fills an actual slot.
    expect(find.text('37.7\u00B0C'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(3));
    expect(find.textContaining('target 58%'), findsOneWidget);
    expect(find.text('Set point'), findsNothing);
    expect(find.text('Standby'), findsOneWidget);
    expect(find.text('Waiting for sensor data'), findsOneWidget);

    // A date-only legacy record cannot establish a confirmed Start instant.
    expect(find.text('Waiting for confirmed start'), findsOneWidget);
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
    expect(find.text('Day 0 of 21'), findsNothing);
    expect(find.text('Waiting for confirmed start'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(3));
    expect(find.text('Standby'), findsOneWidget);
  });
}
