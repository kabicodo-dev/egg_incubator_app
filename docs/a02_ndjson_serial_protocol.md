# A-02 — NDJSON serial output contract

**Owner:** Ally · **Branch:** `ally-branch3` · **Sketch:** `arduino/SmartHatch_Combined/SmartHatch_Combined.ino`
**Status:** Firmware output implemented and host-verified; **not flashed**, not hardware-verified.
This documents the A-02 wire contract only. It is not a claim of joint HW-02
protocol approval, physical capture or end-to-end HC-05 operation.

## Scope

A-02 changes only the bytes the Uno writes to `Serial`. Control thresholds,
EEPROM layout, servo timing and the batch timer are unchanged. A-03 later
changed fail-safe relay handling only (invalid sensor now also de-energises the
circulation fan; overheat also de-energises the humidifier). A-06 later added
the `START` two-phase handshake and a separate durable start-identity EEPROM
record at address 32; the existing batch layout at address 0 is unchanged. This
is the `SmartHatch_Combined` controller variant; the app-facing
`SmartHatch_Uno` sketch and its JSON parser remain a separate contract
(HW-IMP-01).

## Framing

- 9600 baud, 8-N-1 (configured by `Serial.begin(9600)`).
- One JSON object per line, terminated by a single **LF** (`0x0A`).
- No CR, no pretty-printing, no multi-line objects.
- Arduino `println()` would emit CRLF, so every frame ends through `endFrame()`.

## Envelope

Every frame starts with `"type"` and carries `"v": 1`:

| `type` | Terminal? | Meaning |
|---|---|---|
| `ack` | yes | Outcome for one command `id`. Confirms processing, **not** physical relay state. |
| `running` | no | For `TURN_NOW`: the same command `id` is still in flight; the later `ack` completes it. For `START`: a separate post-confirmation message carrying `status:"running"` (see A-06 below). |
| `telemetry` | — | Periodic snapshot. |
| `event` | — | Unsolicited lifecycle notice; carries no command id. |

`v` is a single integer wire version. A consumer must refuse a version it was
not built for rather than guess field meanings. There is no minor version and
no per-field negotiation.

## Accepted ack

```json
{"type":"ack","v":1,"id":102,"cmd":"TURN_NOW","status":"accepted","message":"turn_completed"}
```

## Rejected ack (structured error)

```json
{"type":"ack","v":1,"id":103,"cmd":"NOPE","status":"rejected",
 "error":{"code":"unknown_command","message":"unknown command"}}
```

- Branch on `error.code`; `error.message` is prose for humans.
- A rejected ack has no top-level `message`; an accepted ack has no `error`.
- Codes currently emitted: `unknown_command`, `incubator_sensor_invalid`,
  `turning_disabled_for_stage`, `line_too_long`, `required_id_or_cmd_missing`,
  `invalid_batch_id`, `batch_already_running`, `batch_already_complete`.
- Unknown codes must be tolerated and surfaced verbatim.

## Running vs ack

`TURN_NOW` performs a blocking servo sweep. The sequence for one id is:

```json
{"type":"running","v":1,"id":102,"cmd":"TURN_NOW"}
{"type":"event","v":1,"event":"egg_turn_completed"}
{"type":"ack","v":1,"id":102,"cmd":"TURN_NOW","status":"accepted","message":"turn_completed"}
```

`running` never carries `status` or `error` for `TURN_NOW`. A timeout waiting for
`ack` must be reported as *unknown outcome*, never as success or failure.
Duplicate ids replay the cached terminal ack without repeating the side effect;
that cache is RAM-only (8 entries) and is **not** durable recovery.

## A-06 START / ACK / RUNNING

`START` is the only command with a two-phase handshake. It requires both
`command_id` (the existing `id`) and `batch_id` (the app/cloud batch identity).

```json
{"id":301,"cmd":"START","batch_id":7001}
```

Receipt ack — **terminal for receipt only**, not proof of hardware:

```json
{"type":"ack","v":1,"id":301,"command_id":301,"batch_id":7001,
 "cmd":"START","status":"accepted","message":"start_received"}
```

Separate hardware-confirmed status:

```json
{"type":"running","v":1,"id":301,"command_id":301,"batch_id":7001,
 "cmd":"START","status":"running"}
```

- `command_id` echoes `id`; `batch_id` is the app/cloud session id.
- The ACK does **not** assert that sensors are valid, relays are closed or the
  cloud row is `Active`.
- `RUNNING` is emitted only after: a fresh good incubator read and a fresh good
  brooder read after the START request; both sensor pairs valid; and every relay
  output latch agrees with the control law. This is MCU output-latch plus sensor
  validity evidence, **not** independent relay-contact feedback.
- If those conditions are not met, no `RUNNING` is emitted. The request stays
  pending; it is not auto-replayed. A later fresh valid control pass may confirm
  it. Absence of `RUNNING` must not be treated as a successful start.
- Duplicate `command_id`: the original ACK is replayed and no side effect is
  repeated. The same `batch_id` with a new `command_id` is idempotent:
  `ack.message = "start_already_running"` and, if current hardware still
  confirms, `RUNNING` is re-asserted without resetting `elapsed_seconds`.
- A different `batch_id` while one is active: rejected `batch_already_running`.
- Missing or non-positive `batch_id`: rejected `invalid_batch_id`.
- A completed batch: rejected `batch_already_complete`; it is never restarted by
  a duplicate START.
- The original Start is the `RUNNING` confirmation, **not** the ACK receipt.
  `elapsed_seconds` is the firmware's substantiated counter; Day N remains
  `floor(elapsed_seconds / 86400) + 1`.
- Start identity is persisted in a separate EEPROM record at address 32, so the
  existing batch layout at address 0 is preserved. On boot a valid start record
  restores `batch_id`. A restored batch without a trustworthy start record is
  not silently reset: START with a different id is rejected until an explicit
  `NEW_BATCH`/`SELECT_*`.
- After a reboot, a duplicate START re-confirms current sensors/actuators before
  re-asserting `RUNNING`; it does not reset elapsed time.
- For `TURN_NOW`, `running` keeps the A-02 in-flight meaning and carries no
  `status`. For `START`, `running` carries `status:"running"` and is
  post-confirmation. Consumers must branch on `cmd` and must not apply the
  `TURN_NOW` ordering rule to `START`.

## Telemetry

```json
{"type":"telemetry","v":1,"uptime_ms":5000,"egg_type":"chicken","day":1,
 "hatch_day":21,"elapsed_seconds":0,"stage":"active","batch_complete":false,
 "incubator":{"valid":true,"temperature_c":37.6,"humidity_percent":51.4,
 "bulb_on":true,"humidifier_on":false,"fan_on":true,"exhaust_fan_on":false},
 "brooder":{"valid":true,"temperature_c":31.2,"humidity_percent":49.0,
 "bulb_on":false,"humidifier_on":false}}
```

- `day = floor(elapsed_seconds / 86400) + 1` (Day 1 is the first 24 h). This is
  uncapped: once `stage` is `complete`, `day` may be `hatch_day + 1`. The LCD's
  separate display day may still cap at `hatch_day`. `elapsed_seconds` is the
  firmware's own substantiated counter, not a wall-clock or cloud receipt time.
- `valid:false` forces both readings in that room to JSON `null`. A stale value
  is never serialized as current. `null` is "unavailable", never `0`.
- Relay booleans are the firmware's commanded state, not an independent
  measurement of the physical load.

## Events

`batch_started`, `controller_ready`, `batch_state_restored`,
`egg_turn_completed`. `batch_state_restored` reports what EEPROM actually
supplied; the earlier unconditional claim `new_batch_on_first_boot_only` was
removed because it was printed on every boot.

## Evidence (this revision, A-06 state)

- AVR compile: `Sketch uses 21142 bytes (65%)`, globals `1781 bytes (86%)`,
  267 bytes left for stack (`Low memory available` warning). Hex/ELF produced.
- A-02 host harness compiles the same source with shimmed AVR headers and
  captured **19 real frames**, LF-only.
- `check_ndjson.py`: `PASS: 19 frames, 6 acked ids, 1 running frame(s),
  3 structured rejection(s), LF-only framing`.
- A-06 host harness: 48 checks, 0 failures; `check_start.py`: PASS with 10
  START ACKs, 7 RUNNING frames and 3 structured rejections.
- `flutter test test/firmware_ndjson_contract_test.dart`: 6/6 passed.
- `flutter test test/firmware_start_ack_running_test.dart`: 9/9 passed.

## Limitations / not proven

- Host simulation does not exercise 9600-baud timing, the Uno 64-byte RX ring,
  USB loss, EEPROM wear, DHT timing, relay polarity, servo limits or safety.
- No physical capture exists and no board was flashed.
- 280 bytes of stack headroom after 86% static allocation is tight; the
  telemetry emitter streams (no 400-byte stack buffer), but this needs bench
  validation with the LCD/DHT/Servo libraries linked.
- `RTC`, HC-05 transport, cloud `Active` state and durable command recovery are
  out of scope for A-02.
