import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:egg_incubator_app/admin_preview.dart';

void main() {
  testWidgets('preview shares the main SmartHatch component theme', (tester) async {
    await tester.pumpWidget(const AdminPreviewApp());
    final context = tester.element(find.text('Registered users'));
    final theme = Theme.of(context);
    expect(theme.appBarTheme.centerTitle, isTrue);
    expect(theme.textTheme.bodyMedium?.fontFamily, contains('Poppins'));
    expect(theme.elevatedButtonTheme.style, isNotNull);
    expect(theme.outlinedButtonTheme.style, isNotNull);
  });

  testWidgets('demo users can be searched without backend startup', (
    tester,
  ) async {
    await tester.pumpWidget(const AdminPreviewApp());
    expect(find.textContaining('Demo only'), findsOneWidget);
    expect(find.text('Demo Farmer A'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no match');
    await tester.pump();
    expect(find.text('No demo users match your search.'), findsOneWidget);
    expect(find.text('Demo Farmer A'), findsNothing);
  });

  testWidgets(
    'assignment requires confirmation; removal preserves demo record',
    (tester) async {
      await tester.pumpWidget(const AdminPreviewApp());
      await tester.tap(find.text('Access'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Assign to Demo Farmer A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Assigned account: None'), findsOneWidget);
      await tester.tap(find.text('Assign to Demo Farmer A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Assign in preview'));
      await tester.pumpAndSettle();
      expect(find.text('Assigned account: Demo Farmer A'), findsOneWidget);
      // The trigger sits below the fold on the default test surface; scroll it
      // into view so the tap reaches the button instead of missing.
      await tester.ensureVisible(find.text('Remove demo access'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove demo access'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove demo access'));
      await tester.pumpAndSettle();
      expect(find.text('Assigned account: None'), findsOneWidget);
      expect(find.text('Demo Batch A'), findsOneWidget);
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Demo admin removed'), findsOneWidget);
      expect(find.textContaining('Demo admin assigned'), findsOneWidget);
    },
  );

  testWidgets('narrow screen with large text does not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const AdminPreviewApp(),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
