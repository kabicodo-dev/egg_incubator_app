import 'arduino_protocol.dart';
import 'arduino_serial_service.dart';

/// Hardware readiness states for the SmartHatch incubator (HW-01).
///
/// A serial port being open is *not* sufficient proof that the incubator is
/// ready. Readiness additionally requires live telemetry: the Arduino must be
/// sending heartbeat frames (telemetry lines) within [heartbeatTimeout].
///
/// State machine (each transition is driven by the transport layer or by a
/// newly received telemetry frame — there is no background polling):
///
///   disconnected ── connect() ──► connecting ── port opened ──►
///       connectedNotReady ── first telemetry within timeout ──► ready
///             ▲                                                          │
///             │ disconnect() / transport failure                        │ heartbeatTimeout elapsed
///             └────────────────────── error ────────────────────────────┘
///                                  ▲
///                                  │ transport failure at any time
///                                  └─────────────────────────────────────┘
///
///   ready ── heartbeatTimeout elapsed ──► timeout ── next telemetry ──► ready
///
/// Only [ready] entitles the UI to show live readings as live.
enum ArduinoReadinessState {
  /// No serial port open.
  disconnected,
  /// `connect()` is in progress (port is being opened); nothing is known about
  /// the device yet.
  connecting,
  /// Port is open but no telemetry frame has been received yet (awaiting the
  /// first heartbeat).
  connectedNotReady,
  /// Port is open and a telemetry frame was received within
  /// `heartbeatTimeout` — live readings may be shown.
  ready,
  /// Port is open but silence has exceeded `heartbeatTimeout` — the device is
  /// present but not responding.
  timeout,
  /// Connection failed, a read error occurred, or the device closed the port.
  error,
}

/// Immutable snapshot of hardware readiness. Side-effect free and platform
/// independent so it can be unit-tested without a serial port or Flutter.
class ArduinoReadiness {
  const ArduinoReadiness({
    required this.state,
    this.portName,
    this.message,
    this.lastTelemetryAt,
    required this.heartbeating,
  });

  final ArduinoReadinessState state;
  final String? portName;
  /// Human-readable status text suitable for a status badge.
  final String? message;
  /// App-side receipt time of the last telemetry frame (`receivedAt`).
  final DateTime? lastTelemetryAt;
  /// True when a telemetry frame arrived within `heartbeatTimeout`.
  final bool heartbeating;

  bool get isReady => state == ArduinoReadinessState.ready;

  @override
  String toString() =>
      'ArduinoReadiness($state, port: $portName, heartbeating: $heartbeating)';
}

/// Default heartbeat timeout: how long the app waits for a telemetry frame
/// before the incubator is treated as not responding.
///
/// The Arduino sends telemetry every `TELEMETRY_INTERVAL_MS` (2 s). This
/// tolerance covers a few missed frames and matches the controller's existing
/// staleness window (`staleAfter`).
const Duration kDefaultHeartbeatTimeout = Duration(seconds: 6);

/// Pure computation of readiness from connection state and the last telemetry
/// frame. No serial port, no Flutter, and the clock is injected via [now] so
/// every transition is deterministic under test.
ArduinoReadiness computeHardwareReadiness({
  required ArduinoConnectionStatus connection,
  required String? portName,
  required ArduinoTelemetry? telemetry,
  /// Whether at least one telemetry frame has been received on this
  /// connection (distinguishes "awaiting first heartbeat" from "silence after
  /// heartbeat").
  required bool telemetryReceived,
  required DateTime now,
  Duration heartbeatTimeout = kDefaultHeartbeatTimeout,
}) {
  switch (connection) {
    case ArduinoConnectionStatus.disconnected:
      return const ArduinoReadiness(
        state: ArduinoReadinessState.disconnected,
        heartbeating: false,
      );
    case ArduinoConnectionStatus.connecting:
      return ArduinoReadiness(
        state: ArduinoReadinessState.connecting,
        portName: portName,
        message: 'Connecting to $portName…',
        heartbeating: false,
      );
    case ArduinoConnectionStatus.error:
      return const ArduinoReadiness(
        state: ArduinoReadinessState.error,
        heartbeating: false,
      );
    case ArduinoConnectionStatus.connected:
      if (!telemetryReceived) {
        return ArduinoReadiness(
          state: ArduinoReadinessState.connectedNotReady,
          portName: portName,
          message:
              portName == null
                  ? 'Connected — waiting for first telemetry…'
                  : 'Connected to $portName — waiting for first telemetry…',
          heartbeating: false,
        );
      }
      final age = now.difference(telemetry!.receivedAt);
      if (age > heartbeatTimeout) {
        return ArduinoReadiness(
          state: ArduinoReadinessState.timeout,
          portName: portName,
          lastTelemetryAt: telemetry.receivedAt,
          message:
              'No telemetry for ${age.inSeconds}s — incubator not responding',
          heartbeating: false,
        );
      }
      return ArduinoReadiness(
        state: ArduinoReadinessState.ready,
        portName: portName,
        lastTelemetryAt: telemetry.receivedAt,
        message: portName == null ? 'Live' : 'Live on $portName',
        heartbeating: true,
      );
  }
}
