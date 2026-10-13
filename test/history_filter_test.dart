// P5: History filtering.
//
// Locks in the filter bottom sheet behaviour: status/species/date filters
// combine with the search text, selections are staged until the user
// confirms, the smart empty state appears when nothing matches, and
// resetting restores the full list. Filtering is a purely local view over
// the loaded batches - stored records are never changed.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:egg_incubator_app/main.dart';

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

Finder _filtersButton() => find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == 'Filters');

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

  Future<void> pumpHistory(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  testWidgets('status and species filters combine with the search text',
      (tester) async {
    await pumpHistory(tester);
    expect(find.text('Batch #7'), findsOneWidget);

    // Status: Active matches the saved batch, Completed does not.
    // (.last: the card behind the sheet shows the same words.)
    await tester.tap(_filtersButton());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Active').last);
    await tester.pumpAndSettle();
    expect(find.text('Show 1 batch'), findsOneWidget);
    await tester.tap(find.text('Show 1 batch'));
    await tester.pumpAndSettle();
    expect(find.text('Batch #7'), findsOneWidget);

    await tester.tap(_filtersButton());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    expect(find.text('Show 0 batches'), findsOneWidget);
    await tester.tap(find.text('Show 0 batches'));
    await tester.pumpAndSettle();
    expect(find.text('No batches match your search or filters'),
        findsOneWidget);

    // Species: reset, then keep only a species that has no batches.
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('Batch #7'), findsOneWidget);

    await tester.tap(_filtersButton());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duck'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show 0 batches'));
    await tester.pumpAndSettle();
    expect(find.text('No batches match your search or filters'),
        findsOneWidget);

    // Reset restores the list; the matching species keeps it visible.
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('Batch #7'), findsOneWidget);

    await tester.tap(_filtersButton());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chicken').last);
    await tester.pumpAndSettle();
    expect(find.text('Show 1 batch'), findsOneWidget);
    await tester.tap(find.text('Show 1 batch'));
    await tester.pumpAndSettle();
    expect(find.text('Batch #7'), findsOneWidget);

    // A search that matches nothing shows the same smart empty state.
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No batches match your search or filters'),
        findsOneWidget);
  });

  testWidgets('closing the sheet without applying keeps the old filters',
      (tester) async {
    await pumpHistory(tester);

    await tester.tap(_filtersButton());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duck'));
    await tester.pumpAndSettle();
    // Dismiss instead of applying.
    await tester.tap(find.byTooltip('Close filters'));
    await tester.pumpAndSettle();

    expect(find.text('Batch #7'), findsOneWidget,
        reason: 'staged selections are discarded on close');
  });

  testWidgets('filter chips keep the 48px touch minimum', (tester) async {
    await pumpHistory(tester);
    await tester.tap(_filtersButton());
    await tester.pumpAndSettle();

    for (final label in [
      'Active',
      'Completed',
      'Chicken',
      'Duck',
      'Quail',
      'Any time',
      'Last 7 days',
      'Last 30 days',
    ]) {
      final chip = find.byWidgetPredicate((w) =>
          w is Semantics &&
          w.properties.button == true &&
          w.properties.label == label);
      final box = tester.renderObject(chip) as RenderBox;
      expect(box.size.height, greaterThanOrEqualTo(48),
          reason: '$label chip height');
    }

    // The confirm and reset buttons are 48px tall as well.
    final apply = tester.getSize(find
        .ancestor(
            of: find.text('Show 1 batch'), matching: find.byType(ElevatedButton))
        .first);
    expect(apply.height, greaterThanOrEqualTo(48),
        reason: 'apply button height');
    final reset = tester.getSize(find
        .ancestor(
            of: find.text('Reset'), matching: find.byType(OutlinedButton))
        .first);
    expect(reset.height, greaterThanOrEqualTo(48),
        reason: 'reset button height');
  });
}
