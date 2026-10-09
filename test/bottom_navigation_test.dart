import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/main.dart';

/// Pushes [destination] the way the app does: the shell on top of the
/// launcher; sections such as History and Species are then pushed on top of
/// the shell.
class _Launcher extends StatelessWidget {
  const _Launcher({required this.destination});

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
          child: const Text('Open'),
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
  // fails immediately (no I/O) and rendering continues. Explicit pumps are
  // used because the loading indicator animates while it is on screen.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
  }

  /// The bottom bar of the screen that is currently on top.
  Finder topBar(WidgetTester tester) => find.byType(NavigationBar).last;

  int selectedIndex(WidgetTester tester) =>
      tester.widget<NavigationBar>(topBar(tester)).selectedIndex;

  Future<void> tapDestination(
      WidgetTester tester, String label) async {
    final bar = topBar(tester);
    await tester.tap(find.descendant(
      of: bar,
      matching: find.widgetWithText(NavigationDestination, label),
    ));
    await settle(tester);
  }

  testWidgets('History opened from Home has the bottom navigation',
      (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
        const MaterialApp(home: _Launcher(destination: MainNavigation())));
    await tester.tap(find.text('Open'));
    await settle(tester);
    expect(find.byType(NavigationBar), findsOneWidget);

    // The TOTAL BATCHES overview card opens History as a route.
    await tester.ensureVisible(find.text('TOTAL BATCHES'));
    await tester.tap(find.text('TOTAL BATCHES'));
    await settle(tester);

    expect(find.text('Incubation History'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(selectedIndex(tester), 2); // History stays selected

    // Home button navigates to Home.
    await tapDestination(tester, 'Home');
    expect(find.text('Incubation History'), findsNothing);
    expect(find.text('TOTAL BATCHES'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(selectedIndex(tester), 0);
  });

  testWidgets('Species opened from Home has the bottom navigation',
      (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
        const MaterialApp(home: _Launcher(destination: MainNavigation())));
    await tester.tap(find.text('Open'));
    await settle(tester);

    // The TOP SPECIES overview card opens Species as a route.
    await tester.ensureVisible(find.text('TOP SPECIES'));
    await tester.tap(find.text('TOP SPECIES'));
    await settle(tester);

    expect(find.text('Egg Species'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(selectedIndex(tester), 1); // Species stays selected

    // History button navigates to History.
    await tapDestination(tester, 'History');
    expect(find.text('Incubation History'), findsOneWidget);
    expect(find.text('Egg Species'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(selectedIndex(tester), 2);
  });

  testWidgets('Sections shown as tabs keep a single bottom navigation bar',
      (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
        const MaterialApp(home: _Launcher(destination: MainNavigation())));
    await tester.tap(find.text('Open'));
    await settle(tester);

    // As a tab the shell owns the bar - the screen must not add a second one.
    await tapDestination(tester, 'History');
    expect(find.text('Incubation History'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(selectedIndex(tester), 2);

    await tapDestination(tester, 'Species');
    expect(find.text('Egg Species'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(selectedIndex(tester), 1);
  });
}
