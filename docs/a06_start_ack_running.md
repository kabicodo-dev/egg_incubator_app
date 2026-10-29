# A-06 — START ACK / RUNNING separation and hardware confirmation

**Task:** ORIGINAL:A-06 (display A-06)
**Owner:** Ally
**Branch:** `ally-branch3`
**Source revision:** `38232e9d75e0bb602537832fa0d28864b61c7a8c` (HEAD) plus the uncommitted A-02/A-03/A-06 working-tree changes
**Firmware:** `arduino/SmartHatch_Combined/SmartHatch_Combined.ino`
**Status:** Firmware START handshake implemented and host-verified; **not flashed**, **no load energised**, **no physical START/RUNNING test**. The app start handler and cloud `Active` state are not yet wired to this handshake.

## 1. Scope

K06 v0.5 requires an autonomous Uno linked over HC-05 Classic SPP to the
Flutter Android app. This task covers only the **START** handshake on the
`SmartHatch_Combined` controller:

- Receipt ACK is separate from the later RUNNING status.
- RUNNING is emitted only after fresh sensor readings and relay output-latch
  checks.
- Both `command_id` and `batch_id` are carried on START ACK/RUNNING.
- Duplicate START is idempotent and never restarts the batch timer.
- The controller's own substantiated Start is the RUNNING confirmation, not the
  ACK receipt and not the cloud row's creation time.

The app-facing `SmartHatch_Uno` sketch is a separate contract (HW-IMP-01) and is
not changed here. The Flutter `Start Incubation` handler
(`lib/main.dart`, checklist button) still creates the Supabase session and
updates active settings **before** any hardware START. That is the precise
missing integration: cloud `Active` is not the same as physical RUNNING, and
this task does not claim otherwise.

No Wi-Fi code is used or revived. USB is diagnostic; the HC-05 link was not
exercised.

## 2. What changed

1. Added the `START` command with a required `batch_id`.
2. The ACK is receipt-only: `status:"accepted"`, `message:"start_received"`,
   plus `command_id` and `batch_id`. It does not claim sensors, relays or cloud
   state.
3. Added a separate RUNNING frame with `cmd:"START"`, `status:"running"`,
   `command_id` and `batch_id`, emitted only after:
   - a fresh good incubator DHT read after the START request;
   - a fresh good brooder DHT read after the START request;
   - both sensor pairs valid; and
   - all six relay output latches (D10, D12, D6, D9, D11, D5) agree with the
     control law.
4. A START that cannot confirm stays pending. No RUNNING is emitted and the
   request is not automatically replayed.
5. Idempotency:
   - the same `command_id` replays the original ACK and does not repeat the
     start;
   - the same `batch_id` with a new `command_id` returns
     `message:"start_already_running"` and re-asserts RUNNING without resetting
     `elapsed_seconds`;
   - a different batch while one is active is rejected
     `batch_already_running`;
   - a missing/non-positive `batch_id` is rejected `invalid_batch_id`;
   - a completed batch is rejected `batch_already_complete`.
6. Added a durable start-identity record at EEPROM address 32. The existing
   `BatchState` at address 0 is unchanged, so A-03 progress is preserved.
   Confirmation uses a crash-safe order: clear the old identity, write the fresh
   batch state, then publish the new identity. A power cut between steps leaves
   an uncertain batch that START will not silently adopt.
7. A restored batch with no trustworthy start record is treated as
   identity-unknown. START with a different id is rejected until an explicit
   `NEW_BATCH`/`SELECT_*`, so an uncertain Start is never replayed automatically.
8. Added an independent pure-Dart START handshake model
   (`lib/services/start_handshake.dart`) that keeps receipt ACK and RUNNING
   distinct, plus unit tests. It is not yet wired into the Supabase-first start
   handler.
9. Added the A-06 host harness, checker, captured fixture, Flutter contract test
   and this record.

No incubation values, thresholds, servo timing or relay pin map were changed.
The only new wire fields are the mandated `command_id` and `batch_id`, plus
`status:"running"` on the START RUNNING frame.

## 3. Wire contract

The full contract is in `docs/a02_ndjson_serial_protocol.md` §A-06.

START command:

```json
{"id":301,"cmd":"START","batch_id":7001}
```

Receipt ACK:

```json
{"type":"ack","v":1,"id":301,"command_id":301,"batch_id":7001,
 "cmd":"START","status":"accepted","message":"start_received"}
```

Hardware-confirmed RUNNING:

```json
{"type":"running","v":1,"id":301,"command_id":301,"batch_id":7001,
 "cmd":"START","status":"running"}
```

`running` for `TURN_NOW` keeps its A-02 in-flight meaning and carries no
`status`. Consumers must branch on `cmd`; the two `running` uses are not
interchangeable.

The START request is deliberately small: with 10-digit `id` and `batch_id` it is
53 bytes of JSON plus LF (54 bytes), within the Uno 64-byte `Serial` RX ring.
The longer ACK/RUNNING frames are TX only and are not constrained by that RX
ring. This is not the full proposed HW-02 command envelope; it is the selected
A-02/A-06 JSON-Lines command.

## 4. Confirmation criteria and what they prove

The confirmation is deliberately conservative but is **not** independent
hardware feedback:

| Check | Evidence |
|---|---|
| Fresh incubator read after START | `lastIncubatorGoodRead >= startRequestedAt` and `incubatorSensorValid` |
| Fresh brooder read after START | `lastBrooderGoodRead >= startRequestedAt` and `brooderSensorValid` |
| Relay outputs | `digitalRead(pin)` equals the commanded active-LOW level for D10, D12, D6, D9, D11 and D5 |
| Batch timer | reset only on the confirmed original Start; resume/replay never resets it |

This proves the **MCU output latch** and **sensor validity**, not that a relay
contact physically closed, the heater is hot, or the chamber is at target. A
physical relay/load test is still required.

If confirmation is not possible, the START remains pending: no RUNNING, no
automatic retry, and no timer reset. The app must treat absence of RUNNING as
**not confirmed**, never as success.

## 5. Idempotency cases

| Input | Result | Timer |
|---|---|---|
| First `START` with `batch_id` | ACK `start_received`; later RUNNING when confirmed | Starts at RUNNING |
| Same `command_id` again | Original ACK replayed; RUNNING re-asserted if currently confirmed | Unchanged |
| Same `batch_id`, new `command_id` | ACK `start_already_running`; RUNNING re-asserted if confirmed | Unchanged |
| Different `batch_id` while active | ACK rejected `batch_already_running`; no RUNNING | Unchanged |
| Missing/zero `batch_id` | ACK rejected `invalid_batch_id`; no RUNNING | Unchanged |
| Duplicate after reboot with persisted identity | ACK; RUNNING only after a fresh valid read/latch confirmation | Unchanged |
| Duplicate on a completed batch | ACK rejected `batch_already_complete`; no RUNNING | Unchanged |
| Restored batch with no start record | ACK rejected `batch_already_running` until explicit `NEW_BATCH`/`SELECT_*` | Not reset |

## 6. Verification performed

### 6.1 Genuine Arduino compile/link

```
./.arduino/bin/arduino-cli.exe compile \
  --fqbn arduino:avr:uno \
  --build-path .arduino/build_a06 \
  arduino/SmartHatch_Combined
```

Actual output:

```
Sketch uses 21142 bytes (65%) of program storage space. Maximum is 32256 bytes.
Global variables use 1781 bytes (86%) of dynamic memory, leaving 267 bytes for local variables. Maximum is 2048 bytes.
Low memory available, stability problems may occur.
```

Artefacts (build directory untracked):

| Artefact | Size (bytes) | SHA-256 |
|---|---:|---|
| `.arduino/build_a06/SmartHatch_Combined.ino.hex` | 59483 | `ccd8143994c236ba6dce267301f7c3fb1aa891b63b635b2dd483198202884429` |
| `.arduino/build_a06/SmartHatch_Combined.ino.elf` | 122976 | `808a72b7de00bef4dd4c9ea16f1ca1999350dfc26e0066a01dbdcfd4103ceb39` |

The 8-entry ACK cache was compacted (shorter command/status/detail fields) to
absorb the new state without reducing SRAM headroom: 1781 bytes static
(86 %), 267 bytes left for stack.

### 6.2 Host START simulation

Build and run on Windows with MSVC:

```
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%TEMP%\sh_a06" mkdir "%TEMP%\sh_a06"
cl /nologo /EHsc /std:c++14 /W3 ^
   /I arduino\SmartHatch_Combined\host\shim ^
   arduino\SmartHatch_Combined\host\start_host_sim.cpp ^
   /Fo:%TEMP%\sh_a06\ /Fe:%TEMP%\sh_a06\start_host_sim.exe
%TEMP%\sh_a06\start_host_sim.exe > %TEMP%\sh_a06\capture.ndjson
py -3 arduino\SmartHatch_Combined\host\check_start.py %TEMP%\sh_a06\capture.ndjson
```

Actual result:

```
A-06 start_host_sim: checks=48 failures=0 bytes=6836 lines=39 simulated_ms=4000
PASS: A-06 START handshake; 10 START ack(s), 7 RUNNING frame(s), 3 rejection(s);
ACK receipt precedes hardware-confirmed RUNNING; duplicate START idempotent;
sensor and actuator waits observed
```

The harness records every `digitalWrite()` as a pin level and can override
`digitalRead()` to simulate a relay-latch readback mismatch. The 48 assertions
cover receipt-before-RUNNING, fresh sensor waits, actuator mismatch waits,
duplicate ids, same-batch/new-command id, different-batch rejection, invalid
batch id, completed batch, EEPROM reload, and no timer reset on replay. The
reported `simulated_ms=4000` is measured after the intentional EEPROM-reload
clock reset; the pre-reboot scenario covers about 40 s of simulated time.

### 6.3 Flutter contract and pure-Dart handshake tests

```
flutter test test/firmware_start_ack_running_test.dart
```

Actual result: `All tests passed!` (9 tests).

```
flutter test test/start_handshake_test.dart
```

Actual result: `All tests passed!` (8 tests). This proves the pure-Dart model
keeps an accepted ACK in receipt-only state and only reports running after a
matching RUNNING frame; it also rejects mismatched ids and RUNNING before ACK.

```
flutter analyze lib/services/start_handshake.dart \
  test/start_handshake_test.dart test/firmware_start_ack_running_test.dart
```

Actual result: `No issues found!`.

The targeted firmware suite also passes:

```
flutter test test/firmware_start_ack_running_test.dart \
  test/start_handshake_test.dart \
  test/firmware_ndjson_contract_test.dart \
  test/firmware_control_failsafe_test.dart
```

`All tests passed!` (29 tests).

```
flutter test
```

`All tests passed!` (209 tests).

### 6.4 Regressions

- A-02: `check_ndjson.py` PASS — 19 frames, 6 acked ids, 1 running frame,
  3 structured rejections, LF-only.
- A-03: `control_host_sim` 109 checks, 0 failures; `check_control.py` PASS.
- A-02 and A-03 fixtures were regenerated from the final source and are
  byte-identical to the previous captures.

## 7. Evidence files

| File | Role |
|---|---|
| `arduino/SmartHatch_Combined/host/start_host_sim.cpp` | Compiles real sketch; scripts START, sensor failures, relay readback mismatch, reboot; 48 checks |
| `arduino/SmartHatch_Combined/host/check_start.py` | Independent ACK/RUNNING ordering and schema checker |
| `test/fixtures/firmware/combined_a06_start_capture.ndjson` | Real captured NDJSON from the last run |
| `test/firmware_start_ack_running_test.dart` | CI re-check of the captured handshake evidence |
| `lib/services/start_handshake.dart` | Transport-independent ACK-vs-RUNNING state model for the future app integration |
| `test/start_handshake_test.dart` | Pure-Dart receipt/RUNNING separation and idempotency tests |
| `docs/a02_ndjson_serial_protocol.md` | Wire contract, including §A-06 |
| `docs/a06_start_ack_running.md` | This record |

A-06 fixture SHA-256:
`796ffd184736ed62568b8b97425d0e08b64057d7192f2e19fd50bef15c8fb7c4`.

## 8. Limitations / not proven

- **No physical evidence.** The harness does not model 9600-baud timing, the
  Uno 64-byte RX ring, USB/HC-05 buffering, relay contacts, heater/humidifier
  power, DHT accuracy, thermal behaviour or servo torque. No board was flashed
  and no load was energised.
- RUNNING proves the MCU output latch and sensor validity, not physical relay
  closure or chamber temperature.
- The app start handler still writes the Supabase session and cloud `Active`
  row before any hardware START/RUNNING. Cloud `Active` is not physical
  RUNNING. Wiring the handler to this handshake is the remaining integration
  dependency (HW-IMP-01 / app work).
- A pending START has no timeout. It remains unconfirmed; the app must not
  auto-replay it and must not infer success from an ACK.
- The start record uses magic/version but no CRC. EEPROM `put` is not atomic;
  the write order reduces the consequence of a torn write to an uncertain batch
  that START refuses to adopt automatically, but it is not a durable journal.
- `batch_started` events do not carry `batch_id`; correlation is through the
  START ACK/RUNNING and telemetry.
- No RTC: `elapsed_seconds` is the firmware's millis-based substantiated counter,
  not a wall-clock timestamp. Day N remains `floor(elapsed_seconds/86400)+1`.
- Incubation limits are not formally approved.
- SRAM is 86 % used (267 bytes free); adding RTC/HC-05 code needs a headroom
  review.

## 9. Required report

**Task ID:** ORIGINAL:A-06 (display A-06)
**Owner:** Ally
**Status:** Firmware START handshake implemented and host-verified; not flashed; no powered or physical test; app/cloud integration outstanding.

**What I actually changed:**
- Added `START` with a required `batch_id`; ACK is receipt-only with
  `command_id`/`batch_id` and `message:"start_received"`.
- Added a separate RUNNING frame (`status:"running"`) emitted only after fresh
  valid incubator + brooder readings and matching relay output latches.
- Added pending-start handling with no automatic replay; duplicates and
  same-batch retries are idempotent and never reset `elapsed_seconds`.
- Added durable start identity at EEPROM address 32, preserving the existing
  batch layout at address 0, with a crash-safe clear→batch-state→identity order.
- Added an independent pure-Dart START handshake model and unit tests; it is
  not yet wired into the Supabase-first start handler.
- Added the A-06 host harness, checker, fixture, Flutter contract test and this
  record.
- Compacted the ACK cache fields to keep SRAM at 86 % with 267 bytes free.

**Files modified:**
- `arduino/SmartHatch_Combined/SmartHatch_Combined.ino`
- `arduino/SmartHatch_Combined/host/start_host_sim.cpp` (new)
- `arduino/SmartHatch_Combined/host/check_start.py` (new)
- `arduino/SmartHatch_Combined/host/check_ndjson.py` (scope note for A-06)
- `arduino/SmartHatch_Combined/host/README.md`
- `lib/services/start_handshake.dart` (new)
- `test/start_handshake_test.dart` (new)
- `test/fixtures/firmware/combined_a06_start_capture.ndjson` (new)
- `test/firmware_start_ack_running_test.dart` (new)
- `docs/a02_ndjson_serial_protocol.md` (A-06 section)
- `docs/a06_start_ack_running.md` (new)

**Tests performed:**
- `arduino-cli compile` for `SmartHatch_Combined` (Uno): 21142 bytes flash
  (65 %), 1781 bytes SRAM (86 %), 267 bytes free; HEX/ELF produced.
- A-06 host simulation: 48 assertions, 0 failures, 39 output lines.
- `check_start.py`: PASS — 10 START ACKs, 7 RUNNING frames, 3 rejections.
- `flutter test test/firmware_start_ack_running_test.dart`: 9 tests passed.
- `flutter test test/start_handshake_test.dart`: 8 tests passed.
- Targeted firmware/handshake suite: 29 tests passed.
- `flutter test`: 209 tests passed.
- A-02 and A-03 regressions: PASS.

**Actual results:** All host/software checks passed. ACK receipt precedes
RUNNING; RUNNING is withheld while the incubator sensor is invalid or a relay
latch mismatches; duplicate START replays without resetting the timer; a
different batch and a completed batch are rejected.

**Evidence:** See §6. HEX SHA-256
`ccd8143994c236ba6dce267301f7c3fb1aa891b63b635b2dd483198202884429`;
ELF SHA-256
`808a72b7de00bef4dd4c9ea16f1ca1999350dfc26e0066a01dbdcfd4103ceb39`;
A-06 fixture SHA-256
`796ffd184736ed62568b8b97425d0e08b64057d7192f2e19fd50bef15c8fb7c4`.

**Errors:** None in the final run. Earlier harness iterations exposed and fixed
two real issues before the final pass: a fresh auto-started batch was wrongly
treated as an uncertain restored batch, and a post-reboot retry could re-assert
RUNNING from stale pre-reboot validity.

**Remaining blockers:**
- Flutter start handler still creates the Supabase session/cloud `Active` row
  before hardware confirmation; it does not send START or consume RUNNING.
- Physical verification requires separate authorization and qualified
  documented electrical safety clearance.
- HC-05 Classic SPP transport and Flutter Android end-to-end are not tested.
- RUNNING is MCU-latch/sensor evidence, not relay-contact feedback.
- No RTC and no independent watchdog; SRAM headroom is tight.

**What still needs verification:**
- Bench observation of START → ACK → RUNNING with a real Uno, HC-05 and app.
- Duplicate START and reboot retry on physical hardware.
- Whether a relay can be stuck while its MCU latch reads correct; this needs
  physical feedback or an independent cutout.
- App behavior when RUNNING never arrives (must stay unconfirmed, never
  auto-replay).
- Cloud `Active` vs physical RUNNING mapping and the original Start timestamp.

**Recommended next task:** **HW-IMP-01** — wire the Flutter start handler and
transport to this START/RUNNING contract, keeping cloud `Active` distinct from
physical RUNNING. Then run a supervised, unpowered/low-power bench START test
before any loaded incubator run; A-03 physical verification follows after
safety clearance.
