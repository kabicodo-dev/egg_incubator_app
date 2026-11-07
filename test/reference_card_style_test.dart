import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/widgets/selected_species_preset_card.dart';
import 'package:egg_incubator_app/widgets/reading_dial_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> show(
    WidgetTester tester,
    Widget child, {
    double scale = 1,
  }) async {
    tester.view.physicalSize = const Size(320, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(320, 1200),
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final species in defaultSpeciesList) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        '${species.name} compact preset remains readable at 320px / $scale',
        (tester) async {
          var changes = 0;
          await show(
            tester,
            SelectedSpeciesPresetCard(
              species: species,
              onChange: () => changes++,
            ),
            scale: scale,
          );
          expect(find.text(species.temperature), findsOneWidget);
          expect(find.text('${species.targetHumidity}% RH'), findsOneWidget);
          expect(find.text('${species.incubationDays} days'), findsOneWidget);
          expect(find.text('Duration'), findsOneWidget);
          await tester.tap(find.text('Change'));
          expect(changes, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final value in <double?>[null, 0, 37.4, 61, double.nan]) {
    testWidgets(
      'reading dial $value is a chart scale, not a health or target classifier',
      (tester) async {
        final valid = value?.isFinite == true;
        final formatted = valid ? '${value!.toStringAsFixed(1)} °C' : '—';
        await show(
          tester,
          ReadingDialTile(
            label: 'Temperature',
            formattedValue: formatted,
            valueKey: 'test-actual',
            value: value,
            scaleMaximum: 50,
            scaleUnit: '°C',
          ),
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('test-actual'))).data,
          formatted,
        );
        final paint = tester.widget<CustomPaint>(
          find.byWidgetPredicate(
            (widget) =>
                widget is CustomPaint && widget.painter is ReadingDialPainter,
          ),
        );
        expect(
          (paint.painter as ReadingDialPainter).fraction,
          valid ? (value! / 50).clamp(0.0, 1.0) : null,
        );
        expect(find.text('0–50 °C scale'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsNothing);
        expect(find.text('Normal'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
