import 'dart:async';

import 'package:egg_incubator_app/services/bounded_lf_framer.dart';
import 'package:egg_incubator_app/services/classic_spp_byte_transport.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake only: no plugin, device, production command, or protocol family.
class _FakeTransport implements ClassicSppByteTransport {
  final input = StreamController<List<int>>();
  final writes = <List<int>>[];
  @override
  Stream<List<int>> get incomingBytes => input.stream;
  @override
  Future<void> writeBytes(List<int> bytes) async => writes.add(List.of(bytes));
  @override
  Future<void> close() => input.close();
}

void main() {
  // All byte budgets below are test parameters, never approved Uno limits.
  test('caller must provide a positive bound', () {
    for (final bound in [0, -1]) {
      expect(
        () => BoundedLfFramer(maxPayloadBytes: bound),
        throwsArgumentError,
      );
    }
  });

  test('fragmented chunks and bytes form one unchanged payload', () {
    final framer = BoundedLfFramer(maxPayloadBytes: 3);
    expect(framer.add([65]), isEmpty);
    expect(framer.add([66]), isEmpty);
    expect((framer.add([67, 10]).single as FramedBytes).bytes, [65, 66, 67]);
    expect(framer.pendingByteCount, 0);
  });

  test('coalesced lines and empty payload retain exact boundaries', () {
    final framer = BoundedLfFramer(maxPayloadBytes: 3);
    final result = framer.add([65, 10, 10, 66, 10]).cast<FramedBytes>();
    expect(result.map((e) => e.bytes), [
      [65],
      [],
      [66],
    ]);
  });

  test('limit excludes LF and no payload is truncated into success', () {
    final framer = BoundedLfFramer(maxPayloadBytes: 2);
    expect((framer.add([65, 66, 10]).single as FramedBytes).bytes, [65, 66]);
    expect(
      (framer.add([65, 66, 67]).single as FramingFailure).fault,
      FramingFault.payloadTooLong,
    );
    expect(framer.pendingByteCount, 0);
    expect(framer.add([68, 69]), isEmpty);
    expect(framer.add([10]), isEmpty);
    expect((framer.add([70, 10]).single as FramedBytes).bytes, [70]);
  });

  for (final invalid in [-1, 256]) {
    test('invalid byte $invalid discards complete damaged line', () {
      final framer = BoundedLfFramer(maxPayloadBytes: 8);
      expect(
        (framer.add([65, invalid]).single as FramingFailure).fault,
        FramingFault.invalidByte,
      );
      expect(framer.add([66, 10]), isEmpty);
      expect((framer.add([67, 10]).single as FramedBytes).bytes, [67]);
    });
  }

  test('CR/high bytes are not silently normalized or decoded', () {
    final result = BoundedLfFramer(maxPayloadBytes: 3).add([13, 255, 10]);
    expect((result.single as FramedBytes).bytes, [13, 255]);
  });

  test('reconnect reset cannot leak a partial old line', () {
    final framer = BoundedLfFramer(maxPayloadBytes: 3)..add([65, 66]);
    framer.reset();
    expect((framer.add([67, 10]).single as FramedBytes).bytes, [67]);
  });

  test('overflow cannot grow buffered memory or produce suffix frames', () {
    final framer = BoundedLfFramer(maxPayloadBytes: 8);
    expect(framer.add(List.filled(100000, 65)).single, isA<FramingFailure>());
    expect(framer.pendingByteCount, 0);
    expect(framer.add([66, 10]), isEmpty);
  });

  test('emitted bytes cannot mutate or share the pending buffer', () {
    final framer = BoundedLfFramer(maxPayloadBytes: 2);
    final line = framer.add([65, 10]).single as FramedBytes;
    framer.add([66, 10]);
    expect(line.bytes, [65]);
    expect(() => line.bytes.add(67), throwsUnsupportedError);
  });

  test('fake stream framing performs no writes or automatic retry', () async {
    final transport = _FakeTransport();
    final framer = BoundedLfFramer(maxPayloadBytes: 3);
    final result = <FramingEvent>[];
    final done = Completer<void>();
    transport.incomingBytes.listen(
      (chunk) => result.addAll(framer.add(chunk)),
      onDone: done.complete,
    );
    transport.input.add([65]);
    transport.input.add([66, 10]);
    await transport.close();
    await done.future;
    expect((result.single as FramedBytes).bytes, [65, 66]);
    expect(transport.writes, isEmpty);
  });
}
