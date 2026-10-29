# A-08 — Dated hardware test log and entry format

**Task:** ORIGINAL:A-08 (display A-08)
**Owner:** Ally
**Branch:** `ally-branch3`
**Source revision:** `38232e9d75e0bb602537832fa0d28864b61c7a8c` (HEAD) plus the uncommitted A-02/A-03/A-06/A-08 working-tree changes
**Prepared:** 2026-10-29
**Status:** Entry format and a dated **software-only** evidence bundle prepared. No physical hardware row has been filled; no board was flashed and no load was energised. **Awaiting Cla review and authorized physical results.**
**Evidence bundle:** `docs/evidence/a08/2026-10-29/README.md`

## 1. Scope

This is the dated test-log format for the SmartHatch hardware pilot under K06
v0.5:

> autonomous Uno + RTC + sensors/actuators ↔ HC-05 Classic SPP ↔ Flutter
> Android ↔ authorized Supabase through the phone's internet.

USB is diagnostic. The ESP8266/Wi-Fi path is historical and is not part of this
log. The log records **actual** results only. A software pass is not a hardware
pass.

Physical activation is gated: do not flash, energise a heater/fan/humidifier or
run an egg test without explicit authorization and qualified documented
electrical safety clearance. A row without that reference must be marked
`BLOCKED`, not `PASS`.

## 2. Rules for filling the log

1. **One row per test.** Do not merge several tests into one PASS.
2. **Actual only.** Never copy Expected into Actual. Record what was observed,
   including failed or incomplete outcomes.
3. **A PASS needs evidence.** Link the photo and raw capture. A missing link is
   a missing result.
4. **Do not infer.** If a test was not run, mark `NOT RUN` or `BLOCKED`. Do not
   infer a pass from software, an ACK or a cloud `Active` row.
5. **Distinguish the states:**
   - ACK = command received/processed, **not** proof of physical actuator state.
   - Cloud `Active` ≠ physical RUNNING. Only the separate RUNNING confirmation
     means the controller has confirmed fresh sensors and relay output latches.
   - Original Start ≠ ACK receipt time ≠ cloud row creation time.
   - Live ≠ stale. Stale values must be `null`, never `0` or the last value.
6. **Day N** is `floor(trustworthy elapsed_seconds / 86400) + 1` from the
   substantiated original Start. Do not substitute wall-clock or receipt time.
7. **No automatic replay** of an uncertain Start. Record the uncertainty; do not
   retry it silently.
8. **Approved limits only.** Quote the approved-limit reference for each
   threshold. The values currently in source are candidates, not approved
   incubation values. Do not invent values.
9. **Physical pilot scope:** Chicken only. Three-species software behaviour is
   intended, but physical rows must not claim Duck/Quail runs. Fresh eggs only;
   hatch counts are manual; incubator-only scope.
10. **No credentials.** Do not print Wi-Fi keys, device tokens, Supabase keys or
    passwords in the log or captures.

## 3. Session header (copy for each dated session)

```
Session ID:
Date (ISO 8601, local):
Tester (name / role):
Location:
Supervisor:
Safety clearance reference:
Board / enclosure ID:
Sketch revision (branch + commit + HEX SHA-256):
HC-05 module / baud:
Flutter app build:
Supabase environment:
Approved-limit reference:
Ambient conditions:
```

## 4. Individual entry format (copy for each test)

```
### <TEST-ID> — <short title>

- Date/time:
- Tester:
- Setup/revision:
- Safety clearance:
- Approved-limit reference:
- Expected:
- Actual:
- Result: PASS / FAIL / BLOCKED / NOT RUN
- Photo link:
- Raw capture:
- SHA-256:
- Notes / limitations:
- Reviewer:
```

A completed entry must not contain a `PASS` unless both the Actual and at least
one evidence link are filled. Use `BLOCKED` when a prerequisite (approval,
clearance, working sensor, HC-05, RTC, phone/Supabase access) is missing.

## 5. Hardware test matrix (rows deliberately not filled)

No physical results have been supplied. Every row below is a placeholder for the
tester to fill after authorization.

| Test ID | Test | Expected (reference required) | Actual | Result | Photo link | Raw capture / SHA-256 |
|---|---|---|---|---|---|---|
| P-01 | Boot / relay polarity, no load | All relays de-energised at boot; active-LOW polarity confirmed against the wiring record; no brief energisation | — | NOT RUN | — | — |
| P-02 | Incubator sensor disconnect / stale | After the approved stale timeout: bulb, humidifier, fan and exhaust OFF; telemetry `valid:false` and `null`, never a stale value | — | NOT RUN | — | — |
| P-03 | Brooder sensor disconnect / stale | Brooder bulb and humidifier OFF; incubator regulation continues; telemetry distinguishes the two chambers | — | NOT RUN | — | — |
| P-04 | Over-temperature cutoff | At the approved over-temperature limit: heater OFF, humidifier OFF, circulation fan ON; recovery only below the approved reset condition | — | NOT RUN | — | — |
| P-05 | Temperature regulation | Heater response follows the approved ON/OFF band with no chatter; actual temperature recorded against target | — | NOT RUN | — | — |
| P-06 | Humidity regulation | Humidifier follows the approved low/high band; actual humidity recorded against target | — | NOT RUN | — | — |
| P-07 | Fan / exhaust response | Circulation fan ON while incubator data is valid; exhaust follows the approved schedule; record actual relay states | — | NOT RUN | — | — |
| P-08 | HC-05 Classic SPP link | Android app receives fresh telemetry over HC-05; local regulation continues without USB/PC; no Wi-Fi path used | — | NOT RUN | — | — |
| P-09 | START ACK vs RUNNING | ACK carries `batch_id`/`command_id` and is receipt only; RUNNING (`status:"running"`) appears only after fresh sensor reads and matching relay latches | — | NOT RUN | — | — |
| P-10 | Duplicate START | Same command id/batch id does not restart the batch; no second `batch_started`; elapsed timer does not reset | — | NOT RUN | — | — |
| P-11 | Original Start / Day N | Day N follows the substantiated elapsed counter from the original Start; ACK receipt and cloud `Active` are not used as the original Start | — | NOT RUN | — | — |
| P-12 | Live vs stale telemetry | Fresh frames show live values; stale frames show `null`/not-live, never old values as current | — | NOT RUN | — | — |
| P-13 | Supervised empty incubator | After written safety clearance: actual temperature/humidity vs approved targets; heater/fan/humidifier response; sensor-disconnect and overheat behaviour; independent thermometer reading | — | NOT RUN | — | — |
| P-14 | RTC / power-off elapsed | If RTC is installed, power-off interval is substantiated; if not, mark BLOCKED and do not infer elapsed time | — | NOT RUN | — | — |
| P-15 | Pilot scope | Chicken-only physical pilot; fresh eggs only; no egg testing without authorization; hatch count recorded manually | — | NOT RUN | — | — |

> P-14 is gated on HW-01: the exact RTC chip/model is currently **UNCONFIRMED**
> (see `docs/hw01_rtc_identification.md`). Do not fill the RTC row from a board
> nickname or an I²C address alone.
>
> P-08 is gated on HW-02: the ZS-040 carrier is identified, but the exact
> Bluetooth module (HC-05 vs HC-06) and firmware are **UNCONFIRMED** (see
> `docs/hw02_bluetooth_module_identification.md`). Do not fill the HC-05 row
> from the carrier name, device name or a working SPP link alone.

## 6. Recorded software verification (2026-10-29)

These rows are **actual results from the repository's software verification**.
They are not hardware tests. They use the same entry fields so the format is
consistent, but the Result column is explicitly `PASS (software)` and the Photo
column is `N/A`.

| Test ID | Date | Tester | Setup / revision | Expected | Actual | Result | Photo link | Raw capture / SHA-256 |
|---|---|---|---|---|---|---|---|---|
| SW-01 | 2026-10-29 | Ally (software) | `ally-branch3` HEAD + working tree; arduino-cli 1.5.2-rc.1; arduino:avr 1.8.8 | Genuine Uno compile/link succeeds and reports flash/SRAM | 21142 bytes flash (65 %), 1781 bytes SRAM (86 %), 267 bytes free; low-memory warning | PASS (software) | N/A — no physical test | `docs/evidence/a08/2026-10-29/compile_a08.txt`; `toolchain.txt`; HEX SHA-256 `ccd8143994c236ba6dce267301f7c3fb1aa891b63b635b2dd483198202884429` |
| SW-02 | 2026-10-29 | Ally (software) | A-06 host harness compiles the real sketch against AVR shims | ACK receipt precedes RUNNING; RUNNING waits for sensors/actuator latches; duplicates idempotent | 48 checks, 0 failures; `check_start.py` PASS; 10 START ACKs, 7 RUNNING frames, 3 rejections | PASS (software) | N/A — no physical test | `a06_capture.ndjson`, `a06_checks.txt`, `a06_check.txt`; SHA-256 of capture `796ffd184736ed62568b8b97425d0e08b64057d7192f2e19fd50bef15c8fb7c4` |
| SW-03 | 2026-10-29 | Ally (software) | A-03 host harness, same sketch | Temperature/humidity hysteresis; invalid-sensor all-off; overheat heater+humidifier off/fan on; autonomy without serial | 109 checks, 0 failures; `check_control.py` PASS; 59 telemetry frames | PASS (software) | N/A — no physical test | `a03_capture.ndjson`, `a03_checks.txt`, `a03_check.txt`; SHA-256 of capture `eea705b644254aa621b97b017b7e5165e01f960cb8f69fc60a20e1e8ad70924b` |
| SW-04 | 2026-10-29 | Ally (software) | A-02 host harness regression | 19 frames, LF-only, structured rejections | `PASS: 19 frames, 6 acked ids, 1 running frame(s), 3 structured rejection(s), LF-only framing` | PASS (software) | N/A — no physical test | `a02_capture.ndjson`, `a02_check.txt`; SHA-256 `16f1cd92a5b1cf29f7f5d97069b85740ebd2b309b86669e66139985ebb267d11` |
| SW-05 | 2026-10-29 | Ally (software) | Flutter workspace, A-02/A-03/A-06 tests | All tests pass and analyzers are clean | `flutter test`: 209 tests passed; `flutter analyze` on the firmware/handshake tests: no issues | PASS (software) | N/A — no physical test | `flutter_test.txt`, `flutter_analyze.txt` |

**Software rows do not prove** HC-05, sensors, relay contacts, heater/fan/
humidifier power, thermal safety, Supabase, Android or any incubation outcome.
No board was flashed and no load was activated.

Log/evidence integrity check:

```
py -3 docs/evidence/a08/check_a08_log.py
```

Actual result: `PASS: A-08 log format; 15 physical rows NOT RUN; 5 software rows
labelled PASS (software); 17 evidence files match sha256sums.txt`. The checker
fails if a physical row claims PASS, a required field is missing, or any evidence
SHA-256 changes.

## 7. Photo and raw-capture convention

Store physical evidence under:

```
docs/evidence/a08/<YYYY-MM-DD>/<TEST-ID>-setup.jpg
docs/evidence/a08/<YYYY-MM-DD>/<TEST-ID>-meter.jpg
docs/evidence/a08/<YYYY-MM-DD>/<TEST-ID>-capture.ndjson
docs/evidence/a08/<YYYY-MM-DD>/<TEST-ID>-capture.sha256
```

- Photos must show the test ID, date, board/load state and the meter or display
  reading. Do not stage a photo without the actual test in progress.
- Raw captures must be the unedited Serial/NDJSON stream, with the exact command
  or app build that produced them.
- Record the SHA-256 in the row. If a file is replaced, create a new dated entry;
  do not overwrite evidence.
- No physical photos are present in the 2026-10-29 bundle because no physical
  test was authorized or performed.

## 8. Reviewer sign-off (Cla)

```
Reviewed by: Cla
Review date:
Scope reviewed:
Decision: [ ] Approved   [ ] Changes requested   [ ] Not reviewed
Comments:
```

The log is **not** approved until this block is filled. Acceptance for A-08 is
Cla's review, not the presence of this template alone.

## 9. Precise remaining dependencies

- Cla's review of this format and the 2026-10-29 software bundle.
- Written approval of the temperature/humidity/overheat/stale-timeout limits.
- Explicit authorization and qualified documented electrical safety clearance
  for unpowered/low-power bench checks and the supervised empty-incubator run.
- HC-05 module + Android phone + authorized Supabase environment for P-08/P-09.
- RTC hardware if P-14 is to be more than `BLOCKED`.
- A tester-supplied date, tester name, setup and actual observations for every
  physical row.

## 10. Required report

**Task ID:** ORIGINAL:A-08 (display A-08)
**Owner:** Ally
**Status:** Dated entry format and 2026-10-29 software evidence bundle prepared; no physical rows filled; awaiting Cla review.

**What I actually changed:**
- Added the A-08 hardware test-log format with date, tester, setup, approved-limit
  reference, expected, actual, pass/fail/blocked/not-run, photo link, raw capture
  and SHA-256 fields.
- Added a 15-row physical test matrix left as `NOT RUN` because no physical
  results were supplied or authorized.
- Added a dated 2026-10-29 software-only evidence bundle with raw host captures,
  checker outputs, compile output, toolchain inventory, Flutter test output and
  SHA-256 sums.
- Added the reviewer sign-off block for Cla.

**Files modified:**
- `docs/a08_hardware_test_log.md` (new)
- `docs/evidence/a08/2026-10-29/` (new evidence bundle)
- `docs/evidence/a08/check_a08_log.py` (new log/checksum verifier)

**Tests performed:**
- Inspected `arduino-cli` 1.5.2-rc.1 and `arduino:avr` 1.8.8.
- Compiled `arduino/SmartHatch_Combined` for `arduino:avr:uno`.
- Ran A-02, A-03 and A-06 host simulations and checkers.
- Ran `flutter test` and `flutter analyze` on the firmware/handshake tests.
- Ran `py -3 docs/evidence/a08/check_a08_log.py` to verify the log format,
  physical `NOT RUN` rows and every evidence SHA-256.

**Actual results:**
- Compile: 21142 bytes flash (65 %), 1781 bytes SRAM (86 %), 267 bytes free;
  low-memory warning.
- A-06 host: 48 checks, 0 failures; checker PASS (10 ACKs, 7 RUNNING, 3
  rejections).
- A-03 host: 109 checks, 0 failures; checker PASS.
- A-02 host: 19 frames, PASS.
- Flutter: 209 tests passed; analyzer clean.

**Evidence:**
`docs/a08_hardware_test_log.md` and
`docs/evidence/a08/2026-10-29/` (raw captures, checks, compile/toolchain output,
Flutter output, `sha256sums.txt`). HEX SHA-256
`ccd8143994c236ba6dce267301f7c3fb1aa891b63b635b2dd483198202884429`.

**Errors:** No errors in the final verification. No physical test was attempted.

**Remaining blockers:**
- Cla review.
- Approved limits.
- Electrical safety clearance and explicit authorization for physical tests.
- Tester-supplied physical observations, photos and raw captures.
- HC-05/Android/Supabase environment for end-to-end rows.

**What still needs verification:**
- Every row P-01 through P-15, in particular relay polarity, sensor failure,
  overheat, HC-05/app, START/RUNNING, Day N, live/stale, and the supervised empty
  incubator run.
- That any future physical PASS is supported by a photo and an unedited raw
  capture with a matching SHA-256.

**Recommended next task:** Cla review of this log format and the 2026-10-29
software bundle, then a supervised unpowered/low-power bench session (P-01, P-02,
P-03, P-09, P-10, P-12) after written safety clearance; the empty-incubator rows
follow only after authorization.
