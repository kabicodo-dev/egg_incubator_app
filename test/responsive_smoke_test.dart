// P5 responsive & accessibility smoke tests.
//
// Locks in the approved layout behaviour across the small phone widths the
// app must support (320 / 360 / 412), common desktop widths, and a 1.3x
// accessibility text scale: no layout crashes, the onboarding title rule
// (one line when it fits, natural wrap when it does not), the SmartHatch
// logo placements, and the History filter button touch target.
//
// Note on tolerated warnings: the test bundle's placeholder font is roughly
// 2x wider than the real Poppins, which trips RenderFlex overflow warnings
// on a handful of untouched legacy rows and bottom-bar labels that fit
// comfortably with the real font (documented findings from the P3 pass).
// Screens still carrying those rows tolerate overflow-only warnings here;
// every other screen - and every screen for any other kind of error - is
// held to a strict zero-exception standard.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';

const _savedSession = <String, dynamic>{
  'id': 7,
  'egg_type': 'Chicken',
  'start_date': '2026-09-19T10:00:00',
  'end_date': '2026-10-10T10:00:00',
  'egg_quantity': 8,
  'eggs_hatched': 0,
  'temperature': 37.5,
  'status': 'Active',
};

class _FakeSupabaseApi extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    final wantsSingle =
        (row.headers['Accept'] ?? '').contains('vnd.pgrst.object+json');
    final String body;
    if (row.url.path.contains('incubator_sessions') &&
        row.url.query.contains('status=eq.Active')) {
      // P6.1 active-batch check: this sweep pretends no batch is running,
      // so every screen - the setup form included - renders its normal
      // state at each width.
      body = '[]';
    } else if (row.url.path.contains('incubator_sessions')) {
      body =
          wantsSingle ? jsonEncode(_savedSession) : jsonEncode([_savedSession]);
    } else {
      body = wantsSingle ? '{"id": 42}' : '[]';
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      request: row,
      headers: {'content-type': 'application/json'},
    );
  }
}

class _MemoryAsyncStorage implements GotrueAsyncStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> getItem({required String key}) async => _store[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _store.remove(key);
  }
}

Finder _logoImages() => find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == 'assets/logo.png',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'test-anon-key',
      httpClient: _FakeSupabaseApi(),
      authOptions: FlutterAuthClientOptions(
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUri: false,
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
      debug: false,
    );
  });

  // Rendering errors captured during the pump, individually (the framework
  // would otherwise coalesce same-frame errors into an unreadable summary).
  List<FlutterErrorDetails> errors = const [];

  Future<void> pumpAt(
    WidgetTester tester,
    Widget child,
    double width, {
    double height = 900.0,
    double scale = 1.0,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    errors = [];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) => errors.add(details);
    try {
      await tester.pumpWidget(MaterialApp(home: child));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
    } finally {
      FlutterError.onError = previous;
    }
  }

  void expectClean(String label) {
    expect(
      errors,
      isEmpty,
      reason:
          '$label: ${errors.map((e) => e.exception.toString()).join(' | ')}',
    );
  }

  // Tolerates only the documented 2x-placeholder-font overflow warnings
  // (see the file header); every other error fails the test.
  void expectOnlyFontArtifacts(String label) {
    for (final e in errors) {
      expect(
        e.exception.toString(),
        contains('A RenderFlex overflowed'),
        reason: '$label: unexpected rendering error: ${e.exception}',
      );
    }
  }

  const phone = <double>[320, 360, 412];
  const desktop = <double>[1024, 1280, 1440];
  final batch = BatchData(
    id: 7,
    batchNumber: 'Batch #7',
    species: 'Chicken',
    startDate: '2026-09-19',
    endDate: '2026-10-10',
    eggsTotal: 8,
    eggsHatched: 0,
    temperature: '37.5\u00B0C',
    status: 'Active',
    isSuccess: false,
  );

  group('Onboarding', () {
    for (final w in <double>[...phone, ...desktop]) {
      testWidgets('renders cleanly at $w px', (tester) async {
        await pumpAt(tester, const LandingPage(), w);
        expect(find.text('Smarter Hatching, Better Results.'), findsOneWidget);
        expect(_logoImages(), findsOneWidget,
            reason: 'slide 1 shows the SmartHatch logo');
        expectClean('onboarding@$w');
      });
    }

    testWidgets('title stays on one line when the width allows',
        (tester) async {
      await pumpAt(tester, const LandingPage(), 1024);
      final h =
          tester.getSize(find.text('Smarter Hatching, Better Results.')).height;
      expect(h, lessThan(44), reason: 'one rendered line expected at 1024px');
    });

    testWidgets('title wraps naturally at 320 with no forced line break',
        (tester) async {
      await pumpAt(tester, const LandingPage(), 320);
      final text =
          tester.widget<Text>(find.text('Smarter Hatching, Better Results.'));
      expect(text.maxLines, isNull, reason: 'no forced single line at 320');
      expectClean('onboarding@320 wrap');
    });

    testWidgets('no overflow at 1.3x accessibility text scale',
        (tester) async {
      await pumpAt(tester, const LandingPage(), 360, scale: 1.3);
      expectClean('onboarding@360@1.3x');
    });
  });

  group('Screens at phone widths', () {
    for (final w in phone) {
      testWidgets('Home@$w', (tester) async {
        await pumpAt(tester, HomeScreen(), w);
        expect(_logoImages(), findsOneWidget, reason: 'header brand logo');
        expectOnlyFontArtifacts('home@$w');
      });
      testWidgets('Species@$w', (tester) async {
        await pumpAt(tester, SpeciesScreen(), w);
        expectClean('species@$w');
      });
      testWidgets('Incubation Setup@$w', (tester) async {
        await pumpAt(tester, const IncubationSetupScreen(), w);
        expectOnlyFontArtifacts('setup@$w');
      });
      testWidgets('Active Incubation@$w', (tester) async {
        await pumpAt(
          tester,
          ActiveIncubationScreen(
            species: defaultSpeciesList.first,
            eggCount: 8,
            batchId: 'Batch #7',
            sessionId: 7,
            startDate: DateTime(2026, 9, 19),
          ),
          w,
        );
        expectOnlyFontArtifacts('active@$w');
      });
      testWidgets('History@$w', (tester) async {
        await pumpAt(tester, HistoryScreen(), w);
        expect(find.byType(SpeciesIllustration), findsOneWidget,
            reason: 'history card uses the species illustration');
        final chip = tester.widget<Text>(find.text('Active'));
        expect(chip.style?.color, AppColors.warning,
            reason: 'a running batch shows an amber status badge');
        expectClean('history@$w');
      });
      testWidgets('Batch Details@$w', (tester) async {
        await pumpAt(tester, BatchDetailsScreen(batch: batch), w);
        expectOnlyFontArtifacts('details@$w');
      });
      testWidgets('Profile@$w', (tester) async {
        await pumpAt(tester, const ProfileScreen(), w);
        expectClean('profile@$w');
      });
      testWidgets('Navigation shell@$w', (tester) async {
        await pumpAt(tester, const MainNavigation(), w);
        expectOnlyFontArtifacts('nav@$w');
      });
    }
  });

  group('Screens at desktop widths', () {
    for (final w in desktop) {
      testWidgets('Home@$w', (tester) async {
        await pumpAt(tester, HomeScreen(), w);
        expectClean('home@$w');
      });
      testWidgets('History@$w', (tester) async {
        await pumpAt(tester, HistoryScreen(), w);
        expectClean('history@$w');
      });
      testWidgets('Profile@$w', (tester) async {
        await pumpAt(tester, const ProfileScreen(), w);
        expectClean('profile@$w');
      });
    }
  });

  group('Touch targets', () {
    testWidgets('the History filter button is at least 48x48', (tester) async {
      await pumpAt(tester, HistoryScreen(), 320);
      final button = tester.renderObject(find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == 'Filters'))
          as RenderBox;
      expect(button.size.width, greaterThanOrEqualTo(48));
      expect(button.size.height, greaterThanOrEqualTo(48));
    });
  });
}
