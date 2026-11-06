# ORIGINAL:C-02 — Flutter compatibility review

Date: 2026-10-29

**Disposition: REQUEST CHANGE — current Flutter is not compatible with the reported revised batch-command flow. Final revised-wire compatibility is BLOCKED pending Ally's updated source and exact response examples.**

This is a review artifact, not protocol sign-off or implementation authorization.

## Scope and evidence

- Inspected the current working tree in `C:\egg_incubator_app`, based on HEAD `c7a26cfcaa619708aff4f793e8068ee176a6cf58`. Pre-existing modified and untracked files were included as current source, not attributed to this review.
- Reviewed the reported changes: species selection and RESET do not start incubation; NEW_BATCH is a deprecated START_BATCH alias; START_BATCH, RESUME_BATCH, COMMISSION_START, ACK_POWER_LOSS and SET_ELAPSED require explicit confirmation; no automatic heating after boot/reset.
- Those revised firmware behaviors are supplied requirements, not independently verified firmware observations.
- The checked-in combined sketch is older: RESET and species selection still invoke `startNewBatch()` (`arduino/SmartHatch_Combined/SmartHatch_Combined.ino:419–426`). It cannot stand in for Ally's revised firmware.
- Source references below identify the inspected working-tree version. No physical board, serial port, cloud service or deployment was exercised.

## 1. Does Flutter assume selection or RESET starts incubation?

**No wire implementation of SELECT_CHICKEN or RESET was found in `lib/`. However, Flutter currently presents a successful cloud operation as a successful incubation Start.**

- `lib/main.dart:2790–2828`: creates a cloud session, updates cloud settings and navigates to `IncubationStartedScreen`. There is no MCU command or MCU confirmation in that handler.
- `lib/main.dart:2960–2971`: displays “Incubation Started!” and “Your eggs are now incubating”.
- `lib/services/supabase_service.dart:144–154`: inserts the cloud session as `Active`, with a phone-supplied start date.

Consequently, the app can claim incubation started even when the revised MCU remains stopped. Updating `active_settings` is a cloud write, not evidence of a physical controller transition; any external consumer of that table was not verified here.

The local simulator starts a timer on construction (`lib/controllers/incubator_controller.dart:218–225`) and resets its local start time through `startNewBatch()` (`:263–305`). Hardware-console initialization and telemetry mirroring are in `lib/main.dart:7354–7368,7395–7433`. These local calculations are not physical Start commands and must not be promoted to MCU lifecycle evidence.

## 2. Does Flutter send required confirmation?

**Not implemented.**

- `lib/services/arduino_protocol.dart:191–211`: `ArduinoCommand` only serializes `type`, string `id`, `actuator` and `state`. It has no `cmd` or `confirm` field.
- `lib/controllers/arduino_controller.dart:183–229`: only implements validated actuator commands.
- `lib/services/arduino_serial_io.dart:128–159`: accepts that actuator-command model and writes its JSON representation.
- No occurrences of the named revised batch commands were found in `lib/` or `test/`.

Required: approved, command-specific serialization and deliberate user confirmation. Do not attach CONFIRM globally, silently translate deprecated NEW_BATCH, or invent batch commands from existing actuator toggles. Confirm whether each sensitive operation should be exposed in the farmer UI or restricted to authorized maintenance.

## 3. Can the parser interpret revised responses?

**Not established for the revised firmware; known incompatibilities already exist with the checked-in combined sketch.**

| Family | Current Flutter behavior | Finding |
|---|---|---|
| ACK | Requires string `id`; reads `success`, `actuator`, `state`, `error` (`lib/services/arduino_protocol.dart:265–275`) | Checked-in combined sketch emits numeric `id`, `cmd`, `status`, `message` (`arduino/SmartHatch_Combined/SmartHatch_Combined.ino:392–396`). Its ID becomes null and success defaults false in Flutter. |
| Telemetry | Reads chamber `temperature`/`humidity`, top-level `actuators`, and `turning` (`arduino_protocol.dart:147–175`) | Combined sketch emits `temperature_c`/`humidity_percent` and chamber-level relay fields (`SmartHatch_Combined.ino:358–375`). Sensor values become unavailable and absent actuator entries default false. |
| Lifecycle/event | Decoder only dispatches `telemetry`, `ack`, `lcdAck` (`arduino_protocol.dart:330–353`) | No typed batch lifecycle/event response model. Other types become unknown. |
| Standalone error | No dedicated error envelope | Unknown frames are reported as ignored (`lib/services/arduino_serial_io.dart:195–216`), not interpreted as correlated batch outcomes. Legacy ACK error text is supported, but does not establish revised error compatibility. |

The transport matches pending commands using the parsed ACK ID (`arduino_serial_io.dart:202–207`); a missing or incompatible ID cannot complete the intended pending operation.

Do not use the separate proposed compact protocol described in other design documents as if it were the revised ORIGINAL:C-02 schema. Ally must identify the exact protocol/version being reviewed.

## 4. Are batch lifecycle states distinguished?

**No MCU-backed batch lifecycle state machine is implemented.**

- `lib/controllers/arduino_controller.dart:10–11,183–229`: pending/confirmed/rejected/failed apply to individual actuator commands, not batch Start/Stop/Resume.
- `lib/main.dart:2640–2642,2767–2788`: `_starting` is a repeated-tap gate for the cloud handler, not MCU START pending.
- `lib/main.dart:3148–3153`: active status is derived from the cloud session, with a parameter-based fallback when unavailable.
- `lib/models/confirmed_incubation_time.dart:1–32`: conservative verified-time presentation exists, but does not parse controller messages or implement a verified-source adapter.
- `lib/controllers/interruption_inspection_controller.dart:11–17,72–96`: backend inspection acknowledgment is a separate abstraction; it does not send or implement firmware ACK_POWER_LOSS.

Required: distinguish pending intent, accepted command, confirmed lifecycle transition, stopped, resumed, unresolved outcome and power-loss acknowledgment according to the approved firmware semantics. These are conceptual review requirements, not newly adopted wire enum values. Acknowledging power loss must not be assumed to resume operation unless the contract explicitly says so. A relay being off does not by itself prove a stopped batch.

Existing ACK documentation correctly distinguishes command processing from independent physical hardware verification (`arduino_protocol.dart:241–254`); preserve that distinction.

## 5. Is automatic physical START replay prevented?

**No automatic physical START replay path was found, but physical START itself is absent. Replay safety is therefore not implemented or proven end-to-end.**

- Connect opens/configures the port and reader; it does not send a batch Start (`lib/services/arduino_serial_io.dart:67–106`).
- The actuator send path writes once and waits for an ACK, with no automatic resend on timeout (`:128–159`).
- Teardown clears pending in-memory operations (`:242–256,272–279`).
- Controller reconnect clears telemetry before awaiting a new heartbeat (`lib/controllers/arduino_controller.dart:148–156`).
- The reviewed cloud service has no physical command dispatch (`lib/services/supabase_service.dart`).

Still required: a durable original intent before dispatch, retained immutable command identity and content, restart-safe unresolved outcomes, read-only reconciliation, and a cloud evidence outbox that cannot dispatch physical Start. Timeout or missing ACK must not be treated as proof that Start did not occur, or permission to create a replacement Start automatically.

## 6. Exact implementation touchpoints

These are proposed changes only; scope must be approved after the wire contract is frozen.

| Existing file | Required work |
|---|---|
| `lib/services/arduino_protocol.dart` | Batch commands, per-command confirmation, approved response schemas, validation and lifecycle models. |
| `lib/services/arduino_serial_service.dart` | Typed batch command/lifecycle interfaces, beyond actuator ACKs. |
| `lib/services/arduino_serial_io.dart` | Revised dispatch, response correlation, unresolved-outcome handling and read-only reconciliation support; agreed framing limits. |
| `lib/services/arduino_serial_stub.dart` | Keep unsupported-platform implementation consistent with changed service interfaces. |
| `lib/controllers/arduino_controller.dart` | Batch lifecycle projection, deliberate actions, pending/unresolved handling and reconnect reconciliation without Start replay. |
| `lib/main.dart` | Remove cloud-success-as-physical-Started behavior; add lifecycle-aware actions and presentation; maintain simulator separation. |
| `lib/services/supabase_service.dart` | Separate cloud persistence/evidence synchronization from physical Start authority, subject to the approved backend design. |

A durable local intent/evidence store is also missing. Its design, dependency and filename are not prescribed by this review. SQL/RLS changes are not authorized.

Supporting review after schema finalization: `lib/services/arduino_readiness.dart` must continue to distinguish a heartbeat from operational readiness/Start authority. `lib/models/confirmed_incubation_time.dart` needs a verified evidence source, not phone-time or cloud-Active substitution. Backend inspection acknowledgment must remain separate from MCU power-loss commands.

## Tests performed

Executed:

```text
flutter test test/arduino_protocol_test.dart test/arduino_controller_test.dart test/arduino_readiness_test.dart test/confirmed_incubation_time_test.dart test/interruption_inspection_test.dart --reporter compact
```

**Result: 63 tests passed.** These cover existing legacy protocol/readiness and presentation behavior, not revised firmware compatibility. No new test fixtures were added; no named revised batch-command fixtures were found in `test/`. This was not a full-suite run, release build, hardware test or independent repetition of Ally's firmware compilation.

Existing tests needing extension include `test/arduino_protocol_test.dart`, `test/arduino_controller_test.dart`, `test/arduino_readiness_test.dart` and `test/hardware_console_sim_test.dart`. Durable storage, restart/reconciliation and batch command integration also need new tests once their approved interfaces exist.

## Approval blockers and required acceptance evidence

1. **Ally:** supply exact revised source/version or commit and literal request/response fixtures for all affected commands; define IDs, ACK statuses, terminal rejections, errors, lifecycle fields and whether ACK means acceptance or completed transition.
2. **Ally + Kath:** freeze behavior for omitted/wrong confirmation, deprecated alias, species selection during a batch, RESET during a batch, duplicate command, lost ACK, resume, commissioning and elapsed-time adjustment. Do not infer these from command names.
3. **Cha + Kath:** approve durable intent/evidence handling and cloud projection rules. Cloud session creation or retry cannot confer controller authority or trigger a physical Start.
4. **Host acceptance tests:** prove exact serialization; revised ACK/telemetry/error parsing; no Started UI from cloud success alone; unrelated/duplicate/late responses cannot confirm another command; timeout remains unresolved; reconnect, process restart and cloud retries never dispatch Start automatically. Test chunked/coalesced/malformed frames and approved length limits.
5. **Physical-board integration:** identify the flashed image and verify boot/reset without automatic heating; species selection without Start; confirmation enforcement; deliberate Start and Resume; power-loss acknowledgment behavior; lost ACK/reconnect and power interruption around command dispatch. Coordinate hardware actions under a separately authorized test plan.

## Message summary for Cha

The current Flutter working tree is not ready for ORIGINAL:C-02 approval. It has legacy actuator-only commands, no required batch confirmation field, no MCU batch lifecycle state machine and a cloud-first Start screen that can claim incubation started without controller evidence. Existing parser mismatches are source-verified; final compatibility with Ally's revised response schema remains blocked until her updated source and exact fixtures are supplied. Five existing test files passed (63 tests), but they do not validate the revised protocol. No application source, firmware, SQL, RLS or deployment changes were made for this review.
