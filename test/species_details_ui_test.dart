import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:egg_incubator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// All requests terminate here. No production Supabase or hardware is used.
class _ReadOnlyApi extends http.BaseClient {
  final List<http.BaseRequest> requests = [];
  Completer<void>? readGate;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (request.method != 'GET') {
      throw StateError('Species browsing must not write data');
    }
    await readGate?.future;
    return http.StreamedResponse(
      Stream.value(utf8.encode('[]')),
      200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}

class _MemoryStorage implements GotrueAsyncStorage {
  @override
  Future<String?> getItem({required String key}) async => null;
  @override
  Future<void> setItem({required String key, required String value}) async {}
  @override
  Future<void> removeItem({required String key}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final api = _ReadOnlyApi();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'test-placeholder-not-a-credential',
      httpClient: api,
      authOptions: FlutterAuthClientOptions(
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUri: false,
        pkceAsyncStorage: _MemoryStorage(),
      ),
      debug: false,
    );
  });

  setUp(api.requests.clear);

  testWidgets('species browsing stays visible while preset read is pending', (
    tester,
  ) async {
    final gate = Completer<void>();
    api.readGate = gate;
    addTearDown(() {
      api.readGate = null;
      if (!gate.isCompleted) gate.complete();
    });
    await tester.pumpWidget(const MaterialApp(home: SpeciesScreen()));
    await tester.pump();
    expect(find.text('Chicken'), findsOneWidget);
    expect(find.text('Duck'), findsOneWidget);
    expect(find.text('Quail'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('tab return retains species state without another preset read', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
    await tester.pumpAndSettle();
    Future<void> tab(int index) async {
      tester
          .widget<NavigationBar>(find.byType(NavigationBar))
          .onDestinationSelected!(index);
      await tester.pumpAndSettle();
    }

    await tab(1);
    final speciesState = tester.state(find.byType(SpeciesScreen));
    final reads = api.requests
        .where((r) => r.url.path.contains('incubator_presets'))
        .length;
    expect(reads, 1);
    await tab(0);
    await tab(1);
    expect(
      identical(tester.state(find.byType(SpeciesScreen)), speciesState),
      isTrue,
    );
    expect(
      api.requests
          .where((r) => r.url.path.contains('incubator_presets'))
          .length,
      reads,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final species in defaultSpeciesList) {
    testWidgets('${species.name} Continue works without expanding details', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: SpeciesScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(species.name));
      final readsBeforeSelection = api.requests.length;
      await tester.tap(find.text(species.name));
      await tester.pumpAndSettle();

      expect(find.text('View Details'), findsNothing);
      expect(find.text('Hide Details'), findsNothing);
      expect(find.text(species.description), findsOneWidget);
      expect(api.requests.length, readsBeforeSelection);

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final setup = tester.widget<IncubationSetupScreen>(
        find.byType(IncubationSetupScreen),
      );
      expect(identical(setup.selectedSpecies, species), isTrue);
      expect(find.text('Egg Quantity'), findsOneWidget);
      expect(find.text('Start Incubation'), findsNothing);
      expect(api.requests.every((request) => request.method == 'GET'), isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    for (final width in [320.0, 450.0]) {
      testWidgets('${species.name} selection, details and Continue at $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(const MaterialApp(home: SpeciesScreen()));
        await tester.pumpAndSettle();

        final asset = 'assets/species/${species.name.toLowerCase()}.png';
        Finder image() => find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == asset,
        );
        expect(image(), findsOneWidget);
        expect(find.text(species.shortDescription), findsOneWidget);
        expect(find.text(species.description), findsOneWidget);
        await tester.ensureVisible(find.text(species.name));
        final readsBeforeSelection = api.requests.length;
        await tester.tap(find.text(species.name));
        await tester.pumpAndSettle();

        expect(find.byType(SpeciesDetailsScreen), findsOneWidget);
        expect(image(), findsOneWidget);
        expect(find.text(species.description), findsOneWidget);
        expect(find.text(species.temperature), findsOneWidget);
        expect(find.text('${species.incubationDays} days'), findsOneWidget);
        if (species.name == 'Quail') {
          expect(find.text('18 days'), findsOneWidget);
          expect(find.text('17 days'), findsNothing);
          expect(find.text('Approved incubation duration'), findsNothing);
        }
        expect(find.byType(TextField), findsNothing);
        expect(find.byType(Slider), findsNothing);

        expect(find.text('Incubation Duration'), findsOneWidget);
        expect(find.text('Temperature'), findsOneWidget);
        expect(find.text('Humidity'), findsOneWidget);
        expect(find.text('${species.targetHumidity}% RH'), findsOneWidget);
        expect(find.text(species.description), findsOneWidget);
        expect(find.text(species.shortDescription), findsNothing);
        expect(image(), findsOneWidget);
        expect(find.text('Hide Details'), findsNothing);
        expect(find.text('View Details'), findsNothing);
        expect(image(), findsOneWidget);
        // Selection and toggles cause no additional API request, even a read.
        expect(api.requests.length, readsBeforeSelection);

        // Continue works directly below the always-visible information.
        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        final setup = tester.widget<IncubationSetupScreen>(
          find.byType(IncubationSetupScreen),
        );
        expect(identical(setup.selectedSpecies, species), isTrue);
        expect(find.text('Egg Quantity'), findsOneWidget);
        expect(api.requests.every((r) => r.method == 'GET'), isTrue);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  for (final species in defaultSpeciesList) {
    testWidgets(
      '${species.name} setup and checklist explicitly exclude transferred eggs',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(home: IncubationSetupScreen(selectedSpecies: species)),
        );
        await tester.pumpAndSettle();
        expect(find.text(freshEggsOnlyNotice), findsOneWidget);
        expect(find.textContaining('previous incubation days'), findsNothing);
        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.byType(IncubationChecklistScreen), findsOneWidget);
        expect(find.text(freshEggsOnlyNotice), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        final readsBeforeChecklist = api.requests.length;
        for (var index = 0; index < 4; index++) {
          final checkbox = find.byType(CheckboxListTile).at(index);
          await tester.ensureVisible(checkbox);
          await tester.tap(checkbox);
          await tester.pump();
        }
        final start = find.widgetWithText(ElevatedButton, 'Start Incubation');
        await tester.ensureVisible(start);
        expect(tester.widget<ElevatedButton>(start).onPressed, isNull);
        await tester.tap(start);
        await tester.pumpAndSettle();
        expect(api.requests.length, readsBeforeChecklist);
        expect(
          find.textContaining(
            'This version cannot send a Start command to the incubator.',
          ),
          findsOneWidget,
        );
        expect(find.text('Batch record saved'), findsNothing);
        expect(api.requests.every((r) => r.method == 'GET'), isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'species selection/details source has no command or Start dependency',
    () {
      final screens = [
        'lib/screens/species/species_screen.dart',
        'lib/screens/species/species_details_screen.dart',
      ].map((path) => File(path).readAsStringSync()).join('\n');
      // A source-boundary check, not a physical serial transport test.
      expect(screens, isNot(contains('ArduinoController')));
      expect(screens, isNot(contains('IncubatorController')));
      expect(screens, isNot(contains('sendCommand')));
      expect(screens, isNot(contains('startNewBatch')));
      expect(screens, isNot(contains('createSession')));
      expect(screens, isNot(contains('updateActiveSettings')));
    },
  );
}
