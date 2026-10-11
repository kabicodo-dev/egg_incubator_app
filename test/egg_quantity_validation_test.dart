import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/main.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';

void main() {
  // Match the phone-sized viewport the app is designed for.
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(450, 836);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  // The screen tries to load its species presets from Supabase, which fails
  // straight away in tests and puts up a SnackBar at the bottom of the screen.
  // Advance time until it has disappeared so taps reach the buttons instead
  // of landing on the snack bar.
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pump();
    for (var i = 0;
        i < 20 && find.byType(SnackBar).evaluate().isNotEmpty;
        i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  const chicken = SpeciesData(
    name: 'Chicken',
    emoji: '\uD83D\uDC14',
    incubationDays: 21,
    temperature: '37.5\u00B0C',
    targetHumidity: 55,
    description: 'Chicken eggs typically require 21 days of incubation.',
  );

  Finder continueButton() => find.widgetWithText(ElevatedButton, 'Continue');

  bool canContinue(WidgetTester tester) =>
      tester.widget<ElevatedButton>(continueButton()).onPressed != null;

  Future<void> openQuantityScreen(WidgetTester tester) async {
    usePhoneScreen(tester);
    await pumpScreen(
      tester,
      const IncubationSetupScreen(selectedSpecies: chicken),
    );
  }

  Future<void> openCustomChoice(WidgetTester tester) async {
    await tester.tap(find.text('Custom'));
    await tester.pump();
  }

  // ── The rule itself ──────────────────────────────────────────────────────
  //
  // SmartHatch: minimum batch size 6 eggs, maximum capacity 12 eggs.

  group('egg quantity rule -6 eggs is the minimum', () {
    for (final value in [0, 1, 5]) {
      test('$value eggs is rejected', () {
        final error = SupabaseService.eggQuantityError(value);

        expect(error, isNotNull, reason: '$value eggs must not be allowed');
        expect(error, contains('6 to 12'), reason: 'farmer-friendly range');
        expect(error, isNot(contains('Exception')), reason: 'no jargon');
      });
    }
  });

  group('egg quantity rule -6 to 12 eggs is accepted', () {
    for (final value in [6, 7, 8, 9, 10, 11, 12]) {
      test('$value eggs is accepted', () {
        expect(SupabaseService.eggQuantityError(value), isNull,
            reason: '$value eggs fits the incubator');
      });
    }
  });

  group('egg quantity rule -above capacity is rejected', () {
    for (final value in [13, 999]) {
      test('$value eggs is rejected', () {
        final error = SupabaseService.eggQuantityError(value);

        expect(error, isNotNull, reason: '$value eggs exceeds 12 eggs');
        expect(error, contains('6 to 12'), reason: 'farmer-friendly range');
      });
    }
  });

  test('a saved session keeps its egg quantity for history', () {
    final batch = BatchData.fromSession({
      'id': 24,
      'egg_type': 'Chicken',
      'start_date': '2026-09-19T10:00:00',
      'egg_quantity': 12,
      'status': 'Active',
    });

    expect(batch.eggsTotal, 12);
  });

  // ── Quick choices ────────────────────────────────────────────────────────

  group('quick choices', () {
    testWidgets('quick choice 6 eggs works', (tester) async {
      await openQuantityScreen(tester);

      expect(find.text('How many eggs?'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(canContinue(tester), isTrue);

      await tester.tap(find.text('6 eggs'));
      await tester.pump();

      expect(find.text('6'), findsOneWidget);
      expect(find.text('5'), findsNothing);
      expect(canContinue(tester), isTrue);
    });

    testWidgets('quick choice 12 eggs works', (tester) async {
      await openQuantityScreen(tester);

      await tester.tap(find.text('12 eggs'));
      await tester.pump();

      expect(find.text('12'), findsOneWidget);
      expect(find.text('13'), findsNothing);
      // The typed entry only appears for Custom.
      expect(find.byType(TextField), findsNothing);
      expect(canContinue(tester), isTrue);
    });

    testWidgets('the +/− counter cannot leave 6 to 12', (tester) async {
      await openQuantityScreen(tester);

      // Below the minimum batch size.
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('6'), findsOneWidget);
      expect(find.text('5'), findsNothing);

      // Above the maximum capacity.
      for (var i = 0; i < 15; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
      }
      expect(find.text('12'), findsWidgets);
      expect(find.text('13'), findsNothing);
      expect(canContinue(tester), isTrue);

      // Coming back down stops at the minimum too.
      for (var i = 0; i < 15; i++) {
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();
      }
      expect(find.text('6'), findsWidgets);
      expect(find.text('5'), findsNothing);
      expect(canContinue(tester), isTrue);
    });

    testWidgets('a valid quantity reaches the checklist', (tester) async {
      await openQuantityScreen(tester);

      await tester.tap(find.text('12 eggs'));
      await tester.pump();
      await tester.tap(continueButton());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Incubation Checklist'), findsOneWidget);
      expect(find.text('12 eggs \u2022 21 days'), findsOneWidget);
    });
  });

  // ── Custom choice ────────────────────────────────────────────────────────

  group('custom quantity', () {
    testWidgets('custom 6 eggs works', (tester) async {
      await openQuantityScreen(tester);
      await openCustomChoice(tester);

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), '6');
      await tester.pump();

      expect(find.textContaining('at least 6'), findsNothing);
      expect(find.textContaining('no more than 12'), findsNothing);
      expect(canContinue(tester), isTrue);
    });

    testWidgets('custom 12 eggs works', (tester) async {
      await openQuantityScreen(tester);
      await openCustomChoice(tester);

      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();

      expect(find.textContaining('no more than 12'), findsNothing);
      expect(canContinue(tester), isTrue);
    });

    testWidgets('custom amounts between 6 and 12 work', (tester) async {
      await openQuantityScreen(tester);
      await openCustomChoice(tester);

      for (final value in ['8', '10', '7']) {
        await tester.enterText(find.byType(TextField), value);
        await tester.pump();

        expect(
          find.textContaining('eggs. SmartHatch'),
          findsNothing,
          reason: '$value eggs is a valid amount',
        );
        expect(canContinue(tester), isTrue, reason: '$value eggs can continue');
      }
    });

    testWidgets('custom 5 eggs is rejected', (tester) async {
      await openQuantityScreen(tester);
      await openCustomChoice(tester);

      await tester.enterText(find.byType(TextField), '5');
      await tester.pump();

      expect(find.textContaining('at least 6 eggs'), findsOneWidget);
      expect(canContinue(tester), isFalse);
    });

    testWidgets('custom 13 eggs is rejected', (tester) async {
      await openQuantityScreen(tester);
      await openCustomChoice(tester);

      await tester.enterText(find.byType(TextField), '13');
      await tester.pump();

      expect(find.textContaining('no more than 12 eggs'), findsOneWidget);
      expect(canContinue(tester), isFalse);
    });

    testWidgets('custom 0 eggs is rejected', (tester) async {
      await openQuantityScreen(tester);
      await openCustomChoice(tester);

      await tester.enterText(find.byType(TextField), '0');
      await tester.pump();

      expect(find.textContaining('at least 6 eggs'), findsOneWidget);
      expect(canContinue(tester), isFalse);
    });

    testWidgets('an emptied custom field is rejected', (tester) async {
      await openQuantityScreen(tester);
      await openCustomChoice(tester);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.text('Please enter the number of eggs.'), findsOneWidget);
      expect(canContinue(tester), isFalse);
    });

    testWidgets('a valid custom amount reaches the checklist',
        (tester) async {
      await openQuantityScreen(tester);
      await openCustomChoice(tester);

      await tester.enterText(find.byType(TextField), '9');
      await tester.pump();
      expect(canContinue(tester), isTrue);

      await tester.tap(continueButton());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Incubation Checklist'), findsOneWidget);
      expect(find.text('9 eggs \u2022 21 days'), findsOneWidget);
    });

    testWidgets('the +/− buttons keep the cursor in the custom field',
        (tester) async {
      await openQuantityScreen(tester);
      await openCustomChoice(tester);

      final field = find.byType(TextField);
      final controller = tester.widget<TextField>(field).controller!;

      // Type at the end of the field, the way a farmer would.
      await tester.enterText(field, '10');
      await tester.pump();
      expect(controller.selection.baseOffset, controller.text.length);

      // Stepping down rewrites the amount from 10 to 9: the caret follows the
      // text instead of being dropped and jumping back to position zero.
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(controller.text, '9');
      expect(controller.selection.isValid, isTrue,
          reason: 'the caret must stay in the field');
      expect(controller.selection.baseOffset, controller.text.length,
          reason: 'the caret must follow the text, not reset to position 0');

      // Stepping back up grows the amount to two digits again.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(controller.text, '10');
      expect(controller.selection.baseOffset, controller.text.length);

      // An emptied field stays safe: the counter puts a valid amount back,
      // with a valid caret and the usual 6 to 12 rule applied.
      await tester.enterText(field, '');
      await tester.pump();
      expect(find.text('Please enter the number of eggs.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(controller.text, '6');
      expect(controller.selection.isValid, isTrue);
      expect(controller.selection.baseOffset, controller.text.length);
      expect(canContinue(tester), isTrue);
    });
  });

  // ── Species selection is untouched ───────────────────────────────────────

  testWidgets('Chicken, Duck and Quail are still selectable', (tester) async {
    usePhoneScreen(tester);
    await pumpScreen(tester, const IncubationSetupScreen());

    expect(find.text('Select Species'), findsOneWidget);
    expect(find.text('Chicken'), findsOneWidget);
    expect(find.text('Duck'), findsOneWidget);
    expect(find.text('Quail'), findsOneWidget);

    await tester.tap(find.text('Chicken'));
    await tester.pump();

    expect(
      tester.widget<ElevatedButton>(continueButton()).onPressed,
      isNotNull,
    );

    await tester.tap(continueButton());
    await tester.pump();

    expect(find.text('How many eggs?'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(canContinue(tester), isTrue);
  });
}
