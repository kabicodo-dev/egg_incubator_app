# SmartHatch HW-01 — Connection and readiness protocol

**Owner:** Hardware
**Branch:** `ally-branch3` (feature branch — do not merge without approval)
**Status:** Code + tests implemented; firmware changes NOT implemented (pending contract approval)

## Problem

A serial port being open does not prove the incubator is alive. The app must
distinguish "port open" from "device actually responding with live telemetry"
before showing readings or allowing actuator commands to be interpreted as live.

## Testable readiness definition (shared by all branches)

> **Ready ⇔ serial port is open AND at least one telemetry frame has been
> received on this connection AND the most recent frame arrived within
> `heartbeatTimeout` (default 6 s).**

Only in the `ready` state may the UI show live temperature/humidity/relay
readings. Every other state means "not ready to incubate against live
hardware."

This is implemented as pure, platform-independent Dart:

- `lib/services/arduino_readiness.dart` — `ArduinoReadinessState` enum,
  `ArduinoReadiness` snapshot, and the deterministic `computeHardwareReadiness()`
  function (injected clock, no serial port, no Flutter).
- `lib/controllers/arduino_controller.dart` — `readiness`, `isReady`, and
  `readinessMessage` getters on `ArduinoController`; telemetry bookkeeping
  reset on (re)connect so a new connection awaits a fresh heartbeat.
- `test/arduino_readiness_test.dart` — state-machine unit tests.
- `test/arduino_controller_test.dart` — controller integration tests with a
  fake serial service.

## States and transitions

| State | Meaning | Entry condition | Exit condition |
|-------|---------|-----------------|----------------|
| `disconnected` | No serial port open. | App start / `disconnect()` | `connect()` → `connecting` |
| `connecting` | Port is being opened; nothing known about device. | `connect()` called | port opened → `connectedNotReady`; failure → `error`; cancel → `disconnected` |
| `connectedNotReady` | Port open, awaiting first heartbeat frame. | Port opened, no telemetry yet | first telemetry in window → `ready`; timeout → `timeout`; failure → `error` / `disconnected` |
| `ready` | Live telemetry within `heartbeatTimeout`. | First (or subsequent) in-window frame | heartbeat elapses → `timeout`; failure → `error`; next frame resets window → `ready` |
| `timeout` | Port open but device silent beyond `heartbeatTimeout`. | No frame within `heartbeatTimeout` | next telemetry frame → `ready`; failure → `error` / `disconnected` |
| `error` | Connection/read failure or device closed port. | Transport failure at any point | `disconnect()` → `disconnected` |

The ready → timeout transition is observed as time passes while connected:
`ArduinoController` runs a 1 s freshness timer while connected, so `readiness`
is recomputed at least once per second.

## Heartbeat

- **Source:** Arduino `telemetry` frames, newline-delimited JSON at 9600 baud,
  every `TELEMETRY_INTERVAL_MS` = 2000 ms (firmware).
- **Interval:** 2 s nominal. `heartbeatTimeout` default = 6 s (≈ 3 missed
  frames), matching the existing `ArduinoController.staleAfter` window.
- **Timestamp:** The firmware does **not** embed a clock timestamp. The app
  stamps each frame with `receivedAt` (`DateTime.now()` at receipt) in
  `ArduinoTelemetry`. Staleness and readiness are computed against
  `receivedAt`, never against a device clock.

## Device identity (contract — pending approval, NOT implemented)

The reference firmware (Uno) currently sends **no identity/hello message**. The
following contract is proposed and must be agreed with Cha (backend) and the
UI/UX owner before any firmware change:

```json
{"type":"hello","hardware":"SmartHatch Uno","board":"Uno R3",
 "firmwareVer":"1.0.0","protocolVersion":1,"baudRate":9600}
```

- Sent once after `Serial.begin()` + `initAllHardware()` completes.
- `hardwareVerified` in `ack` remains `false` on the reference hardware: an
  acknowledgement confirms the command was *processed*, not that a relay
  physically switched.
- Any `hello` support (parsing, `kTypeHello`, identity tracking) is **not**
  present in this branch. Firmware changes require explicit approval.

## Timestamps and message fields

| Field | Owner | Meaning | Validity rule |
|-------|-------|---------|---------------|
| `telemetry.receivedAt` | App | Receipt time of the last telemetry frame | Stamped on receipt; null never; staleness = `now - receivedAt` |
| `command.id` | App | Unique request id (`cmd-<ms>-<counter>`) | Matched to `ack.id` |
| `ack.id` | Arduino | Echo of the command id | Nullable; absent for unsolicited frames |
| `ack.hardwareVerified` | Arduino | Always `false` on reference HW | Not physical proof of relay state |
| Telemetry `incubator/brooder.temperature/humidity` | Arduino | DHT11 readings | Nullable; out of plausible range → `null` |
| `turning.*` | Arduino | Turning schedule state | Nullable fields default as documented |

## Sensor validity

DHT11 plausible ranges (enforced in `ArduinoTelemetry.fromJson`):

- Temperature: −20 .. 60 °C
- Humidity: 0 .. 100 %

A field that is missing, non-numeric, out of range, or `null` is reported as
`null` — **never** as `0`, never as a stale value. `hasIncubatorSensorError` /
`hasBrooderSensorError` are true when either half of a pair is unavailable.

The UI must never render `null` as a reading; render `—`, "Sensor error", or
the appropriate not-ready badge instead.

## Message contract (unchanged by this branch)

`lib/services/arduino_protocol.dart` is the single source of truth for the
JSON Lines protocol (`telemetry`, `command`, `ack`, `lcdUpdate`, `lcdAck`) and
canonical actuator names. This branch adds no new message types and changes no
serial bytes on the wire.

## Tests

- `flutter test test/arduino_readiness_test.dart` — pure state machine
  (disconnected / connecting / connectedNotReady / ready / timeout / error,
  timeout boundary, custom heartbeat, heartbeating flag, messages).
- `flutter test test/arduino_controller_test.dart` — controller readiness
  through a fake `ArduinoSerialService` (connect → connectedNotReady → ready
  on fresh telemetry → timeout on stale telemetry → error).

## Contract agreement (required before firmware changes)

1. Hardware (this branch): readiness definition + tests + docs — done.
2. Cha (backend): agree `hello` identity fields and any Supabase sync of
   device identity / heartbeat health.
3. UI/UX owner: agree readiness badges ("NOT CONNECTED", "CONNECTING",
   "LIVE", "TIMEOUT") and which actions are gated on `ready`.

**No firmware change, no database change, and no UI behavior change is made
in this branch.** Review and approval required before merging.
