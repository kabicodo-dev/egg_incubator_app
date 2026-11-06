sealed class FramingEvent {
  const FramingEvent();
}

class FramedBytes extends FramingEvent {
  FramedBytes(List<int> bytes) : bytes = List.unmodifiable(bytes);
  final List<int> bytes;
}

enum FramingFault { payloadTooLong, invalidByte }

class FramingFailure extends FramingEvent {
  const FramingFailure(this.fault);
  final FramingFault fault;
}

/// Generic LF byte framing only: no JSON decoding, inferred IDs, ACK handling,
/// source trust, commands, timestamps or production connection.
///
/// [maxPayloadBytes] excludes LF and MUST be supplied by the caller. This class
/// selects no device limit; tests use arbitrary small fixture budgets. CR and
/// every other in-range byte are retained verbatim for a future selected-schema
/// decoder. Corrupt/overflow input is discarded through LF, not parsed as a tail.
class BoundedLfFramer {
  BoundedLfFramer({required this.maxPayloadBytes}) {
    if (maxPayloadBytes <= 0) {
      throw ArgumentError.value(
        maxPayloadBytes,
        'maxPayloadBytes',
        'Must be positive',
      );
    }
  }

  final int maxPayloadBytes;
  final List<int> _pending = [];
  bool _discarding = false;

  int get pendingByteCount => _pending.length;

  List<FramingEvent> add(List<int> chunk) {
    final events = <FramingEvent>[];
    for (final byte in chunk) {
      if (byte == 10) {
        if (!_discarding) events.add(FramedBytes(_pending));
        reset();
      } else if (!_discarding) {
        final fault = byte < 0 || byte > 255
            ? FramingFault.invalidByte
            : _pending.length >= maxPayloadBytes
            ? FramingFault.payloadTooLong
            : null;
        if (fault != null) {
          _pending.clear();
          _discarding = true;
          events.add(FramingFailure(fault));
        } else {
          _pending.add(byte);
        }
      }
    }
    return List.unmodifiable(events);
  }

  /// Explicit connection-boundary reset. Never emits an incomplete old line.
  void reset() {
    _pending.clear();
    _discarding = false;
  }
}
