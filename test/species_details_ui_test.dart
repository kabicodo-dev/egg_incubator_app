import 'dart:convert';
import 'dart:io';

import 'package:egg_incubator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// All requests terminate here. No production Supabase or hardware is used.
class _ReadOnlyApi extends http.BaseClient {
  final List<http.BaseRequest> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (request.method != 'GET') {
      throw StateError('Species browsing must not write data');
    }
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

      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Hide Details'), findsNothing);
      expect(find.text(species.description), findsNothing);
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
        expect(find.text(species.description), findsNothing);
        await tester.ensureVisible(find.text(species.name));
        final readsBeforeSelection = api.requests.length;
        await tester.tap(find.text(species.name));
        await tester.pumpAndSettle();

        expect(find.byType(SpeciesDetailsScreen), findsOneWidget);
        expect(image(), findsOneWidget);
        expect(find.text(species.description), findsNothing);
        expect(find.text(species.temperature), findsOneWidget);
        expect(find.text('${species.incubationDays} days'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(find.byType(Slider), findsNothing);

        await tester.tap(find.text('View Details'));
        await tester.pumpAndSettle();
        expect(find.text(species.description), findsOneWidget);
        expect(find.text(species.shortDescription), findsNothing);
        expect(image(), findsOneWidget);
        expect(find.text('Hide Details'), findsOneWidget);

        await tester.tap(find.text('Hide Details'));
        await tester.pumpAndSettle();
        expect(find.text(species.description), findsNothing);
        expect(image(), findsOneWidget);
        // Selection and toggles cause no additional API request, even a read.
        expect(api.requests.length, readsBeforeSelection);

        // Continue must also work with the description expanded.
        await tester.tap(find.text('View Details'));
        await tester.pumpAndSettle();
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

  test(
    'species selection/details source has no command or Start dependency',
    () {
      final source = File('lib/main.dart').readAsStringSync();
      final screens = source.substring(
        source.indexOf('class SpeciesScreen'),
        source.indexOf('class IncubationSetupScreen'),
      );
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
