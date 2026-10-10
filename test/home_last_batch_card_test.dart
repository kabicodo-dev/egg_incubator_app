import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';

/// A saved incubation session exactly as Supabase returns it: 8 eggs, none
/// hatched yet, batch still active.
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

/// Stands in for the Supabase REST API so the Home screen can be pumped with
/// a known batch and no live database.
///
/// Session queries answer with the saved batch, everything else (live sensor
/// readings, species presets) with an empty result.
class _FakeSupabaseApi extends http.BaseClient {
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final row = request as http.Request;
    requests.add(row);

    final wantsSingle =
        (row.headers['Accept'] ?? '').contains('vnd.pgrst.object+json');

    final String body;
    if (row.url.path.contains('incubator_sessions')) {
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

/// Keeps Supabase's auth storage in memory: the real one needs
/// SharedPreferences, which no plugin channel serves inside a test.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final api = _FakeSupabaseApi();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'http://localhost:54321',
      publishableKey: 'test-anon-key',
      httpClient: api,
      authOptions: FlutterAuthClientOptions(
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUri: false,
        // The default storage needs SharedPreferences, which no plugin
        // channel serves inside a test.
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
      debug: false,
    );
  });

  /// The tappable surface of the last-batch card: the `InkWell` that wraps
  /// the whole card, including the "View Details" footer.
  final card = find
      .ancestor(of: find.text('View Details'), matching: find.byType(InkWell))
      .first;

  /// Pumps the Home screen with a phone-sized surface, waits for the batch to
  /// load and scrolls the last-batch card into view.
  Future<void> showLastBatchCard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(450, 836);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The screen really fetched its batches instead of showing a mock.
    expect(api.requests, isNotEmpty);

    // The card sits below the overview cards and may start off screen.
    await tester.ensureVisible(find.text('View Details'));
  }

  testWidgets('the last-batch card keeps its batch info and shows a link',
      (tester) async {
    // Enabled before the first frame so the card's semantics are built.
    final semantics = tester.ensureSemantics();
    await showLastBatchCard(tester);

    // Everything the card showed before is still there.
    expect(
      find.descendant(of: card, matching: find.text('Batch #7')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: card,
        matching: find.text('CHICKEN \u2022 2026-09-19'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('0%')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('0/8 hatched')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('37.5\u00B0C')),
      findsOneWidget,
    );

    // The navigation affordance: "View Details" in the SmartHatch orange with
    // a right-facing chevron, on one row.
    expect(find.text('View Details'), findsOneWidget);
    final link = tester.widget<Text>(find.text('View Details'));
    expect(link.style?.color, const Color(0xFFE8752A));

    final footerRow = find
        .ancestor(of: find.text('View Details'), matching: find.byType(Row))
        .first;
    expect(
      find.descendant(of: footerRow, matching: find.byIcon(Icons.chevron_right)),
      findsOneWidget,
    );

    // The card is one tappable surface with a visible ink response, not just
    // a link: a single InkWell covers the whole card.
    expect(
      find.ancestor(of: find.text('Batch #7'), matching: find.byType(InkWell)),
      findsOneWidget,
    );

    // Screen readers get one labelled button with a tap action. The framework
    // merges the card's texts into that single node, so the label is matched
    // by prefix instead of by exact string.
    final label = find.bySemanticsLabel(RegExp('^View details for Batch #7'));
    expect(label, findsOneWidget);

    final node = tester.getSemantics(label);
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    semantics.dispose();
  });

  testWidgets('tapping View Details opens the batch details screen',
      (tester) async {
    await showLastBatchCard(tester);

    await tester.tap(find.text('View Details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(BatchDetailsScreen), findsOneWidget);
    expect(find.text('Total Eggs'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('tapping the card itself opens the batch details screen',
      (tester) async {
    await showLastBatchCard(tester);

    await tester.tap(find.text('Batch #7'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(BatchDetailsScreen), findsOneWidget);
    expect(find.text('Total Eggs'), findsOneWidget);
  });
}
