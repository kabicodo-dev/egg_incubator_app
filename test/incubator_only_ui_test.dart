import 'dart:convert';
import 'dart:io';

import 'package:egg_incubator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// Test fixtures only: these are not readings or physical hatch results.
const _completed = <String, dynamic>{
  'id': 41,
  'egg_type': 'Chicken',
  'start_date': '2026-01-01T10:00:00',
  'end_date': '2026-01-22T10:00:00',
  'egg_quantity': 8,
  'eggs_hatched': 5,
  'temperature': 37.5,
  'status': 'Completed',
};

Map<String, dynamic> _active() => {
  ..._completed,
  'id': 42,
  'start_date': DateTime.now().toIso8601String(),
  'end_date': null,
  'eggs_hatched': 0,
  'status': 'Active',
};

class _ReadOnlyApi extends http.BaseClient {
  List<Map<String, dynamic>> sessions = [];
  final List<http.BaseRequest> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (request.method != 'GET') {
      throw StateError('This route audit must not write data');
    }
    final single = (request.headers['Accept'] ?? '').contains(
      'vnd.pgrst.object+json',
    );
    List<Map<String, dynamic>> rows = [];
    if (request.url.path.endsWith('/incubator_sessions')) {
      rows = sessions.where((row) {
        for (final key in ['id', 'status']) {
          final filter = request.url.queryParameters[key];
          if (filter != null && filter != 'eq.${row[key]}') return false;
        }
        return true;
      }).toList();
    }
    final body = single ? (rows.isEmpty ? null : rows.first) : rows;
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(body))),
      200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}

class _MemoryStorage implements GotrueAsyncStorage {
  final Map<String, String> _values = {};

  @override
  Future<String?> getItem({required String key}) async => _values[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _values.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final api = _ReadOnlyApi();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'test-anon-key',
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

  setUp(() {
    api.sessions = [_active(), _completed];
    api.requests.clear();
  });

  tearDown(() {
    expect(api.requests.every((request) => request.method == 'GET'), isTrue);
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> open(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(450, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: page));
    await settle(tester);
  }

  void expectIncubatorOnly() {
    expect(
      find.textContaining(
        RegExp('brood', caseSensitive: false),
        skipOffstage: false,
      ),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            RegExp(
              'brood',
              caseSensitive: false,
            ).hasMatch(widget.properties.label ?? ''),
        skipOffstage: false,
      ),
      findsNothing,
    );
  }

  final pages = <String, Widget Function()>{
    'Landing': () => const LandingPage(),
    'Navigation shell': () => const MainNavigation(),
    'Home': () => const HomeScreen(),
    'Species': () => const SpeciesScreen(),
    'Species details': () =>
        SpeciesDetailsScreen(species: defaultSpeciesList[0]),
    'Occupied setup': () => const IncubationSetupScreen(),
    'Checklist': () =>
        IncubationChecklistScreen(species: defaultSpeciesList[0], eggCount: 8),
    'Saved confirmation': () => IncubationStartedScreen(
      species: defaultSpeciesList[0],
      eggCount: 8,
      sessionId: 42,
    ),
    'Current incubation': () => activeIncubationScreenFor(_active()),
    'History': () => const HistoryScreen(),
    'Active details': () =>
        BatchDetailsScreen(batch: BatchData.fromSession(_active())),
    'Completed details': () =>
        BatchDetailsScreen(batch: BatchData.fromSession(_completed)),
    'Profile': () => const ProfileScreen(),
    'Edit profile': () => const EditProfileScreen(),
    'Account': () => const AccountSettingsScreen(),
    'Hardware console': () => const IncubatorDashboardPage(),
    for (final title in [
      'Notifications',
      'Temperature Unit',
      'Language',
      'Dark Mode',
    ])
      title: () => SettingsPlaceholderScreen(title: title),
  };

  for (final entry in pages.entries) {
    testWidgets('${entry.key} has no brooder widgets or labels', (
      tester,
    ) async {
      await open(tester, entry.value());
      expectIncubatorOnly();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('unoccupied setup keeps species and quantity navigation', (
    tester,
  ) async {
    api.sessions = [_completed];
    await open(
      tester,
      IncubationSetupScreen(selectedSpecies: defaultSpeciesList[0]),
    );
    expect(find.text('Egg Quantity'), findsOneWidget);
    expectIncubatorOnly();
    await tester.tap(find.text('Continue'));
    await settle(tester);
    expect(find.byType(IncubationChecklistScreen), findsOneWidget);
    expectIncubatorOnly();
  });

  testWidgets('History loads saved rows and opens the saved manual result', (
    tester,
  ) async {
    await open(tester, const HistoryScreen());
    expect(find.text('Batch #41'), findsOneWidget);
    expect(find.text('5 / 8 eggs hatched'), findsOneWidget);
    await tester.tap(find.text('Batch #41'));
    await settle(tester);
    expect(find.byType(BatchDetailsScreen), findsOneWidget);
    expect(find.text('Hatched'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expectIncubatorOnly();
  });

  testWidgets('manual Finish dialog remains reachable without brooder UI', (
    tester,
  ) async {
    await open(tester, activeIncubationScreenFor(_active()));
    await tester.ensureVisible(find.text('Finish Batch'));
    await tester.tap(find.text('Finish Batch'));
    await settle(tester);
    expect(find.text('Eggs hatched'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expectIncubatorOnly();
  });

  test(
    'remaining brooder string literals are internal telemetry keys only',
    () {
      final source = File('lib/main.dart').readAsStringSync();
      final literals = RegExp(
        r'''['"][^'"\n]*brood[^'"\n]*['"]''',
        caseSensitive: false,
      ).allMatches(source);
      expect(literals, isNotEmpty);
      for (final literal in literals) {
        expect([
          "'brooderBulb'",
          "'brooderHumidifier'",
        ], contains(literal.group(0)));
      }
    },
  );
}
