import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/main.dart';

void main() {
  for (final count in [6, 0, null]) {
    testWidgets(
      'Completed record count=$count is results only, not live monitoring',
      (tester) async {
        final completed = BatchData(
          id: 25,
          batchNumber: 'Batch #25',
          species: 'Chicken',
          startDate: '2026-09-01',
          endDate: '2026-09-22',
          eggsTotal: 8,
          eggsHatched: count ?? 0,
          hasRecordedHatchCount: count != null,
          temperature: '37.5°C',
          status: 'Completed',
          isSuccess: count != null && count > 0,
        );
        await tester.pumpWidget(
          MaterialApp(home: BatchDetailsScreen(batch: completed)),
        );
        await tester.pumpAndSettle();
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('Hatched'), findsOneWidget);
        expect(find.text('Hatchability'), findsOneWidget);
        expect(find.text('2026-09-22'), findsOneWidget);
        expect(find.text('Saved temperature setting'), findsOneWidget);
        expect(find.text('Temperature'), findsNothing);
        expect(find.text('Humidity'), findsNothing);
        expect(find.text('BATCH STATUS'), findsNothing);
        expect(find.text('Incubation Progress'), findsNothing);
        expect(find.textContaining('Check the incubator'), findsNothing);
        expect(find.textContaining('No verified reading'), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.text('Finish Batch'), findsNothing);
        expect(find.text('View Current Incubation'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
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

    expect(find.text('Saved temperature setting'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('Incubation Progress'), findsOneWidget);
    expect(find.text('Batch record'), findsOneWidget);

    // The session setting remains available, but never fills an actual slot.
    expect(find.text('37.7\u00B0C'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('No verified reading for this batch'), findsNWidgets(2));
    expect(find.text('Set point'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
    expect(
      find.text('The app cannot confirm whether the incubator is running.'),
      findsOneWidget,
    );

    // A date-only legacy record cannot establish a confirmed Start instant.
    expect(find.text('Day count unavailable'), findsOneWidget);
  });

  testWidgets('Batch details handles a species without a preset match', (
    tester,
  ) async {
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
    expect(find.text('Day count unavailable'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('Open'), findsOneWidget);
  });
}
