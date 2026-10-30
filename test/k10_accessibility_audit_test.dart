import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:egg_incubator_app/main.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// Screenshot/audit fixtures only. No real hatch, device, Start or approval.
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
final _active = <String, dynamic>{
  ..._completed,
  'id': 42,
  'end_date': null,
  'status': 'Active',
};

class _ReadOnlyApi extends http.BaseClient {
  bool occupied = true;
  final List<String> methods = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    methods.add(request.method);
    if (request.method != 'GET') throw StateError('Audit cannot write');
    final rows = request.url.path.endsWith('/incubator_sessions')
        ? [if (occupied) _active, _completed].where((row) {
            for (final key in ['id', 'status']) {
              final filter = request.url.queryParameters[key];
              if (filter != null && filter != 'eq.${row[key]}') return false;
            }
            return true;
          }).toList()
        : [];
    final single = (request.headers['Accept'] ?? '').contains(
      'vnd.pgrst.object+json',
    );
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(single
          ? (rows.isEmpty ? null : rows.first)
          : rows))),
      200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }
}

class _MemoryStorage implements GotrueAsyncStorage {
  final Map<String, String> values = {};
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }
  @override
  Future<void> removeItem({required String key}) async => values.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final api = _ReadOnlyApi();
  final findings = <Map<String, Object?>>[];
  final output = Platform.environment['K10_SCREENSHOT_DIR'];

  setUpAll(() async {
    // Use the existing local Poppins font bytes, not the Ahem test placeholder
    // and not a network fetch. Audit alias avoids modifying app/font assets.
    final font = FontLoader('K10Poppins');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      font.addFont(Future.value(ByteData.sublistView(
        await File('docs/video/fonts/Poppins-$weight.ttf').readAsBytes(),
      )));
    }
    await font.load();
    final icons = FontLoader('MaterialIcons')..addFont(Future.value(
      ByteData.sublistView(await File(
        'build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
      ).readAsBytes()),
    ));
    await icons.load();
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
    if (output != null) await Directory(output).create(recursive: true);
  });

  tearDownAll(() async {
    if (output != null) {
      await File('$output/findings.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert(findings),
      );
    }
    expect(api.methods.every((method) => method == 'GET'), isTrue);
  });

  final pages = <String, Widget Function()>{
    'landing': () => const LandingPage(),
    'navigation': () => const MainNavigation(),
    'home': () => const HomeScreen(),
    'species': () => const SpeciesScreen(),
    'species-details': () => SpeciesDetailsScreen(species: defaultSpeciesList[0]),
    'setup': () => const IncubationSetupScreen(),
    'setup-quantity': () => const IncubationSetupScreen(),
    'occupied-setup': () => const IncubationSetupScreen(),
    'checklist': () => IncubationChecklistScreen(
      species: defaultSpeciesList[0], eggCount: 8,
    ),
    'saved-confirmation': () => IncubationStartedScreen(
      species: defaultSpeciesList[0], eggCount: 8, sessionId: 42,
    ),
    'active': () => activeIncubationScreenFor(_active),
    'history': () => const HistoryScreen(),
    'history-filters': () => const HistoryScreen(),
    'completion-form': () => Builder(builder: (context) => ElevatedButton(
      onPressed: () => showFinishBatchDialog(context, session: _active),
      child: const Text('Open completion audit'),
    )),
    'active-details': () => BatchDetailsScreen(batch: BatchData.fromSession(_active)),
    'completed-details': () => BatchDetailsScreen(batch: BatchData.fromSession(_completed)),
    'profile': () => const ProfileScreen(),
    'edit-profile': () => const EditProfileScreen(),
    'account': () => const AccountSettingsScreen(),
    'console': () => const IncubatorDashboardPage(),
    for (final title in ['Notifications', 'Temperature Unit', 'Language', 'Dark Mode'])
      title: () => SettingsPlaceholderScreen(title: title),
  };

  for (final size in [(320.0, 1.0), (320.0, 2.0), (1440.0, 1.0)]) {
    for (final page in pages.entries) {
      testWidgets('record ${page.key} ${size.$1}px ${size.$2}x', (tester) async {
        api.occupied = !page.key.startsWith('setup');
        tester.view.physicalSize = Size(size.$1, size.$1 == 320 ? 640 : 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = size.$2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        final errors = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details.exceptionAsString());
        final capture = GlobalKey();
        final label = '${page.key.replaceAll(' ', '-')}-${size.$1.toInt()}-${size.$2}x';
        Future<void> screenshot(String part) async {
          if (output == null) return;
          await tester.pump();
          final boundary = capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
            await File('$output/$label-$part.png').writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        try {
          await tester.pumpWidget(RepaintBoundary(
            key: capture,
            child: MaterialApp(
              theme: ThemeData(
                useMaterial3: true,
                fontFamily: 'K10Poppins',
                colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
                scaffoldBackgroundColor: AppColors.background,
              ),
              home: Scaffold(body: page.value()),
            ),
          ));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          if (page.key == 'setup-quantity') {
            await tester.tap(find.text('Chicken').first);
            await tester.pump(const Duration(milliseconds: 250));
            await tester.ensureVisible(find.text('Continue'));
            await tester.tap(find.text('Continue'));
            await tester.pump(const Duration(milliseconds: 250));
          }
          if (page.key == 'history-filters') {
            await tester.tap(find.byWidgetPredicate((widget) =>
                widget is Semantics && widget.properties.label == 'Filters'));
            await tester.pump(const Duration(milliseconds: 400));
          }
          if (page.key == 'completion-form') {
            await tester.tap(find.text('Open completion audit'));
            await tester.pump(const Duration(milliseconds: 400));
            await tester.enterText(find.byType(TextField), '5');
            await tester.pump();
          }
          await screenshot('top');
          final vertical = find.byWidgetPredicate((widget) => widget is Scrollable &&
              (widget.axisDirection == AxisDirection.down || widget.axisDirection == AxisDirection.up));
          if (vertical.evaluate().isNotEmpty) {
            final state = tester.state<ScrollableState>(vertical.first);
            state.position.jumpTo(state.position.maxScrollExtent);
            await tester.pump(const Duration(milliseconds: 100));
            await screenshot('bottom');
          }
          findings.add({'screen': page.key, 'width': size.$1, 'scale': size.$2,
            'renderingErrors': List<String>.from(errors)});
          // Exploratory audit: overflow is RECORDED, never called a clean pass.
          // Unexpected exceptions fail this test, rather than being suppressed.
          expect(errors.where((e) => !e.contains('A RenderFlex overflowed')), isEmpty);
          if (['setup', 'setup-quantity', 'occupied-setup', 'checklist',
            'active-details', 'completed-details'].contains(page.key)) {
            expect(errors, isEmpty, reason: 'Regression check for the small layout fixes');
          }
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 7));
          FlutterError.onError = previous;
        }
      });
    }
  }

  testWidgets('History filter and navigation labels expose semantics', (tester) async {
    final handle = tester.ensureSemantics();
    try {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(fontFamily: 'K10Poppins'),
      home: const Scaffold(body: HistoryScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final filters = find.bySemanticsLabel('Filters');
    expect(filters, findsOneWidget);
    expect(tester.getSemantics(filters).getSemanticsData()
        .hasAction(ui.SemanticsAction.tap), isTrue);
    for (final label in ['Home', 'Species', 'History']) {
      expect(find.bySemanticsLabel(RegExp(label)), findsWidgets);
    }
    expect(api.methods.every((method) => method == 'GET'), isTrue);
    } finally {
      handle.dispose();
    }
  });

  test('measure token contrasts against actual paired surfaces', () {
    final pairs = <String, (Color, Color)>{
      'primaryDark/white': (AppColors.primaryDark, Colors.white),
      'secondary/white': (AppColors.textSecondary, Colors.white),
      'warning/white': (AppColors.warning, Colors.white),
      'success/tinted badge': (AppColors.success,
          Color.alphaBlend(AppColors.success.withValues(alpha: 0.06), Colors.white)),
      'success/previous 12% tint (baseline)': (AppColors.success,
          Color.alphaBlend(AppColors.success.withValues(alpha: 0.12), Colors.white)),
      'bright orange/white (legacy text risk)': (const Color(0xFFE8752A), Colors.white),
    };
    for (final entry in pairs.entries) {
      final a = entry.value.$1.computeLuminance();
      final b = entry.value.$2.computeLuminance();
      final ratio = ((a > b ? a : b) + 0.05) / ((a < b ? a : b) + 0.05);
      findings.add({'contrastPair': entry.key, 'ratio': ratio, 'normalTextAA': ratio >= 4.5});
      if (!entry.key.contains('baseline') && !entry.key.contains('legacy')) {
        expect(ratio, greaterThanOrEqualTo(4.5), reason: entry.key);
      }
    }
  });
}
