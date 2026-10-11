import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/main.dart';

/// Stands in for the rest of the app: a screen that pushes [destination]
/// exactly the way the overview cards and the "View History" button do.
class _Launcher extends StatelessWidget {
  const _Launcher({required this.buttonLabel, required this.destination});

  final String buttonLabel;
  final Widget destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push<void>(
            context,
            MaterialPageRoute(builder: (_) => destination),
          ),
          child: Text(buttonLabel),
        ),
      ),
    );
  }
}

void main() {
  // Match the phone-sized viewport the app is designed for.
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(450, 836);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  // The screens start loading from Supabase; without initialisation that
  // fails immediately (no I/O) and the loading spinner disappears again.
  // The spinner animates for as long as it is on screen, so tests advance
  // time with explicit pumps instead of pumpAndSettle(), which would never
  // return while it is visible.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
  }

  testWidgets('History opened from another screen has a back arrow',
      (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MaterialApp(
      home: _Launcher(buttonLabel: 'Go', destination: HistoryScreen()),
    ));

    // Root route: nothing to go back to yet.
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('Go'));
    await settle(tester);

    expect(find.text('Incubation History'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    // The arrow returns to where the screen was opened from.
    await tester.tap(find.byType(BackButton));
    await settle(tester);

    expect(find.text('Go'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('Species opened from another screen has a back arrow',
      (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MaterialApp(
      home: _Launcher(buttonLabel: 'Go', destination: SpeciesScreen()),
    ));

    await tester.tap(find.text('Go'));
    await settle(tester);

    expect(find.text('Egg Species'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('Bottom navigation tabs show no back arrow', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const MaterialApp(
      home: _Launcher(buttonLabel: 'Go', destination: MainNavigation()),
    ));

    await tester.tap(find.text('Go'));
    await settle(tester);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Even though the shell itself sits on top of another route, a tab is
    // switched with the bottom bar, so it must not offer a back arrow.
    await tester.tap(find.widgetWithText(NavigationDestination, 'History'));
    await settle(tester);
    expect(find.text('Incubation History'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Species'));
    await settle(tester);
    expect(find.text('Egg Species'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });
}
