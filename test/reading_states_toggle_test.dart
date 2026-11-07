import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../docs/kath_execution/reading_states_preview.dart';

void main() {
  testWidgets(
    'explicit mock controls replace every reading state without live-value leakage',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: ReadingStatesPreview()));

      final cases = <String, String>{
        'Fresh fixture': 'Reading up to date',
        'Not updated fixture': 'Reading not updated',
        'Sensor unavailable fixture': 'Reading unavailable',
        'Unknown fixture': 'Reading time unavailable',
        'Disconnected fixture': 'Incubator disconnected',
        'Receipt only fixture': 'Reading time unavailable',
      };
      for (final entry in cases.entries) {
        await tester.tap(find.widgetWithText(OutlinedButton, entry.key));
        await tester.pump();
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('reading-status-label')))
              .data,
          entry.value,
        );
        for (final metric in ['temperature', 'humidity']) {
          final actual = tester
              .widget<Text>(find.byKey(ValueKey('actual-$metric')))
              .data;
          expect(
            actual,
            entry.key == 'Fresh fixture'
                ? (metric == 'temperature' ? '36.2 °C' : '48.0 %')
                : '—',
          );
          expect(
            tester.widget<Text>(find.byKey(ValueKey('target-$metric'))).data,
            '—',
          );
        }
        expect(find.textContaining('Operation: Unknown'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.widgetWithText(OutlinedButton, 'Fresh fixture'));
      await tester.pump();
      expect(find.text('36.2 °C'), findsOneWidget);
    },
  );
}
