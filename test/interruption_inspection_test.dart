import 'dart:async';

import 'package:egg_incubator_app/controllers/interruption_inspection_controller.dart';
import 'package:egg_incubator_app/widgets/interruption_inspection_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// In-memory fake of the proposed interface, NOT a real/approved backend adapter.
class _Store implements InterruptionInspectionStore {
  final Set<String> pending = {'incident-a'};
  final List<String> acknowledgments = [];
  bool failRead = false;
  bool failWrite = false;
  bool failReadAfterWrite = false;
  bool commitWrite = true;
  Completer<void>? writeGate;

  @override
  Future<List<InspectionIncident>> readPending() async {
    if (failRead) throw StateError('mock read failure');
    return pending.map(InspectionIncident.new).toList();
  }

  @override
  Future<void> acknowledgeInspection(InspectionIncident incident) async {
    acknowledgments.add(incident.reference);
    if (writeGate != null) await writeGate!.future;
    if (failWrite) throw StateError('mock write failure');
    if (commitWrite) pending.remove(incident.reference);
    if (failReadAfterWrite) failRead = true;
  }
}

void main() {
  const incident = InspectionIncident('incident-a');

  test('missing adapter stays unverified', () async {
    final controller = InterruptionInspectionController();
    addTearDown(controller.dispose);
    await controller.refresh();
    await controller.confirmInspection(incident);
    expect(controller.statusKnown, isFalse);
    expect(controller.canAcknowledge, isFalse);
  });

  test('read/reconnect never clears observed incident', () async {
    final store = _Store();
    final controller = InterruptionInspectionController(store: store);
    addTearDown(controller.dispose);
    await controller.refresh();
    store.failRead = true;
    await controller.refresh();
    expect(controller.pending.single.reference, incident.reference);
    store.failRead = false;
    store.pending.clear(); // A disappearing row is not this farmer's action.
    await controller.refresh();
    expect(controller.pending.single.reference, incident.reference);
    expect(store.acknowledgments, isEmpty);
  });

  test('restart reloads unresolved incident from store', () async {
    final store = _Store();
    final first = InterruptionInspectionController(store: store);
    await first.refresh();
    first.dispose();
    final restarted = InterruptionInspectionController(store: store);
    addTearDown(restarted.dispose);
    await restarted.refresh();
    expect(restarted.pending.single.reference, incident.reference);
    expect(store.acknowledgments, isEmpty);
    await restarted.confirmInspection(incident);
    final reloaded = InterruptionInspectionController(store: store);
    addTearDown(reloaded.dispose);
    await reloaded.refresh();
    expect(reloaded.pending, isEmpty);
    expect(reloaded.statusKnown, isTrue);
  });

  for (final failure in ['write', 'readback', 'uncommitted']) {
    test('$failure failure cannot clear the warning', () async {
      final store = _Store();
      final controller = InterruptionInspectionController(store: store);
      addTearDown(controller.dispose);
      await controller.refresh();
      store.failWrite = failure == 'write';
      store.failReadAfterWrite = failure == 'readback';
      store.commitWrite = failure != 'uncommitted';
      await controller.confirmInspection(incident);
      expect(controller.pending.single.reference, incident.reference);
      expect(controller.error, contains('not confirmed'));
      expect(store.acknowledgments, [incident.reference]);
    });
  }

  test('acknowledging one incident cannot clear a newer incident', () async {
    final store = _Store();
    final controller = InterruptionInspectionController(store: store);
    addTearDown(controller.dispose);
    await controller.refresh();
    store.pending.add('incident-b');
    await controller.confirmInspection(incident);
    expect(controller.pending.single.reference, 'incident-b');
    expect(store.acknowledgments, ['incident-a']);
    await controller.confirmInspection(const InspectionIncident('wrong-scope'));
    expect(store.acknowledgments, ['incident-a']);
  });

  test('pending save prevents duplicate submission', () async {
    final store = _Store()..writeGate = Completer<void>();
    final controller = InterruptionInspectionController(store: store);
    addTearDown(controller.dispose);
    await controller.refresh();
    final save = controller.confirmInspection(incident);
    await controller.confirmInspection(incident);
    await controller.refresh();
    expect(controller.pending, hasLength(1));
    expect(controller.busy, isTrue);
    expect(store.acknowledgments, ['incident-a']);
    store.writeGate!.complete();
    await save;
    expect(controller.pending, isEmpty);
  });

  Future<void> show(
    WidgetTester tester,
    InterruptionInspectionController controller, {
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InterruptionInspectionWarning(controller: controller),
          ),
        ),
      ),
    );
  }

  testWidgets('outside taps, swipes and rebuilds cannot dismiss warning', (
    tester,
  ) async {
    final store = _Store();
    final controller = InterruptionInspectionController(store: store);
    addTearDown(controller.dispose);
    await controller.refresh();
    await show(tester, controller);
    expect(find.byType(Dismissible), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
    await tester.tapAt(const Offset(380, 900));
    await tester.drag(
      find.text('Inspection required after interruption'),
      const Offset(200, 0),
    );
    await tester.pumpAndSettle();
    await show(tester, controller);
    expect(find.text('Inspection required after interruption'), findsOneWidget);
    expect(store.acknowledgments, isEmpty);
    expect(find.textContaining('survival are not verified'), findsOneWidget);
    await tester.tap(find.text('I inspected the incubator and eggs'));
    await tester.pumpAndSettle();
    expect(store.acknowledgments, ['incident-a']);
    expect(find.text('Inspection required after interruption'), findsNothing);
  });

  testWidgets('failed save retains warning and action', (tester) async {
    final store = _Store()..failWrite = true;
    final controller = InterruptionInspectionController(store: store);
    addTearDown(controller.dispose);
    await controller.refresh();
    await show(tester, controller);
    await tester.tap(find.text('I inspected the incubator and eggs'));
    await tester.pumpAndSettle();
    expect(find.text('Inspection required after interruption'), findsOneWidget);
    expect(find.textContaining('acknowledgment not confirmed'), findsOneWidget);
  });

  testWidgets('without approved adapter no acknowledgment can be invented', (
    tester,
  ) async {
    final controller = InterruptionInspectionController();
    addTearDown(controller.dispose);
    await show(tester, controller);
    expect(find.text('Restart/interruption status unverified'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  for (final width in [320.0, 390.0, 768.0, 1440.0]) {
    testWidgets('warning at $width', (tester) async {
      final controller = InterruptionInspectionController(store: _Store());
      addTearDown(controller.dispose);
      await controller.refresh();
      await show(tester, controller, width: width);
      expect(find.text('I inspected the incubator and eggs'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
