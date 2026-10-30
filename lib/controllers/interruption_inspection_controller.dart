import 'package:flutter/foundation.dart';

/// Opaque incident identity from an authorized source/batch-scoped adapter.
/// Internal presentation input, not a proposed protocol or database field.
class InspectionIncident {
  const InspectionIncident(this.reference);

  final String reference;
}

/// Implement only against the approved, authenticated backend path. Reads must
/// be authoritative and writes idempotent, scoped to this exact incident and
/// farmer. A device ACK, transport reconnection or local flag is insufficient.
abstract interface class InterruptionInspectionStore {
  Future<List<InspectionIncident>> readPending();
  Future<void> acknowledgeInspection(InspectionIncident incident);
}

class InterruptionInspectionController extends ChangeNotifier {
  InterruptionInspectionController({InterruptionInspectionStore? store})
    : _store = store;

  final InterruptionInspectionStore? _store;
  final Map<String, InspectionIncident> _pending = {};
  bool _disposed = false;
  bool _busy = false;
  bool _statusKnown = false;
  String? _error;

  List<InspectionIncident> get pending => List.unmodifiable(_pending.values);
  bool get busy => _busy;
  bool get statusKnown => _statusKnown;
  String? get error => _error;
  bool get canAcknowledge => _store != null && !_busy;

  // Once observed, incidents stay pinned through refresh, reconnect or read
  // failure. Only the explicit action plus successful write/readback removes
  // that incident. Newly observed incidents are never cleared by another's ACK.
  void _remember(List<InspectionIncident> incidents) {
    for (final incident in incidents) {
      if (incident.reference.isEmpty) {
        throw StateError('Missing incident scope');
      }
      _pending[incident.reference] = incident;
    }
  }

  Future<void> refresh() async {
    if (_busy || _disposed) return;
    if (_store == null) {
      _statusKnown = false;
      _notify();
      return;
    }
    _busy = true;
    _notify();
    try {
      final incidents = await _store.readPending();
      if (_disposed) return;
      _remember(incidents);
      _statusKnown = true;
      _error = null;
    } catch (_) {
      _statusKnown = false;
      _error = 'Inspection status could not be verified. Warning retained.';
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<void> confirmInspection(InspectionIncident incident) async {
    final store = _store;
    if (store == null ||
        !canAcknowledge ||
        _disposed ||
        !_pending.containsKey(incident.reference)) {
      return;
    }
    _busy = true;
    _error = null;
    _notify();
    try {
      await store.acknowledgeInspection(incident);
      final remaining = await store.readPending();
      if (_disposed) return;
      _remember(remaining);
      if (remaining.any((item) => item.reference == incident.reference)) {
        throw StateError('Inspection acknowledgment not confirmed');
      }
      _pending.remove(incident.reference);
      _statusKnown = true;
    } catch (_) {
      _error =
          'Inspection acknowledgment not confirmed. Warning retained; '
          'check the saved inspection status before retrying.';
    } finally {
      _busy = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
