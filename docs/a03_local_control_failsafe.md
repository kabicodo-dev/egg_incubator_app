# A-03 — Local regulation and fail-safe test record

**Task:** ORIGINAL:A-03 (display A-03)
**Owner:** Ally
**Branch:** `ally-branch3`
**Source revision:** `38232e9d75e0bb602537832fa0d28864b61c7a8c` (HEAD) plus the uncommitted A-02/A-03 working-tree changes
**Firmware under test:** `arduino/SmartHatch_Combined/SmartHatch_Combined.ino`
**Status:** Control/fail-safe changes implemented and host-verified; **not flashed**, **no load energised**, **no physical incubation test performed**.

## 1. Scope and architecture

K06 v0.5 calls for an **autonomous Uno** (RTC + sensors/actuators) linked over
HC-05 Classic SPP to the Flutter Android app, with Supabase reached through the
phone's internet. This task covers the Uno's local control law and fail-safe
state only.

- The `SmartHatch_Combined` sketch runs `readSensors()`, `controlIncubator()`,
  `controlBrooder()`, `controlEggTurning()` and `updateBuzzers()` from
  `loop()` on every pass. No network call, PC, phone or USB host is needed for
  regulation. USB/Serial is optional and carries commands/telemetry only.
- The app-facing `SmartHatch_Uno.ino` is still command-driven and delegates
  automatic hysteresis to the phone app. It is **not** autonomous and this
  record makes no A-03 claim for it. Aligning that sketch is the separate
  related task **HW-IMP-01**.
- No Wi-Fi code is used or revived. The ESP8266 variant remains historical.
- The HC-05 link, phone app and Supabase were not exercised by this task.

## 2. Configured limits (source values — not formally approved)

These are the values present in the firmware (and the matching app profile).
No approval record for these incubation limits exists in the repository. They
are **candidates for approval**, not approved values, and must be confirmed
before any physical incubation.

| Incubator control | Value in source |
|---|---|
| Heater ON at/below | 37.5 °C |
| Heater OFF at/above | 38.0 °C |
| Over-temperature cutoff | 39.0 °C |
| Active-stage humidity ON below | 45 % |
| Active-stage humidity OFF at/above | 55 % |
| Lockdown humidity ON below | 65 % |
| Lockdown humidity OFF at/above | 70 % |
| Sensor read interval | 2500 ms |
| Sensor stale timeout | 10000 ms |
| Circulation fan | ON whenever incubator data is valid |
| Exhaust fan | 30 min OFF / 30 s ON, disabled in lockdown/complete |
| Brooder heater ON / OFF | 30.0 °C / 32.0 °C |
| Brooder humidity ON / OFF | 45 % / 60 % |

The over-temperature cutoff is a **software** comparison on the same DHT11. It
is not an independent hardware thermal fuse, and it cannot detect a DHT11 that
is stuck at a plausible low reading.

## 3. What changed

1. `allIncubatorControlledOutputsOff()` now also de-energises the D12
   circulation-fan relay and clears `incubatorFanState`. Previously an invalid
   incubator reading left the fan energised and telemetry reported
   `fan_on:true` alongside `valid:false`.
2. Over-temperature now also forces the D6 humidifier OFF, not just the D10
   heater. The circulation fan stays ON. Humidity control resumes when the
   chamber falls below 39.0 °C.
3. The sketch header documents local-only regulation, the invalid/stale
   all-off state, and the software-only overheat cutoff.
4. Added the A-03 host harness, checker, captured fixture, Flutter regression
   test and this record. **No wire-protocol fields, framing, command names,
   thresholds, EEPROM layout or servo timing were changed.**

## 4. Fail-safe case results (host simulation only)

The scenario is compiled from the real sketch by
`arduino/SmartHatch_Combined/host/control_host_sim.cpp`, which records every
`digitalWrite()` as a pin level. All checks passed; see §5 for the exact run.

| Case | Stimulus | Expected safe behaviour | Observed | Result |
|---|---|---|---|---|
| F0 | Boot with valid 37.6 °C / 51.4 % | Local control starts with no serial command; heater ON, humidifier OFF, fan ON | Heater D10 LOW, humidifier D6 HIGH, fan D12 LOW; telemetry emitted | **PASS (software)** |
| F1 | Temperature 37.4 → 37.9 → 38.0 → 38.3 → 37.6 → 37.5 °C | ON at ≤37.5; OFF at ≥38.0; no re-enable at 37.6 after an OFF | ON, ON, OFF, OFF, OFF, ON | **PASS (software)** |
| F2 | Humidity 44.9 → 45.0 → 54.9 → 55.0 → 50.0 → 44.9 % | ON below 45; hold between limits; OFF at ≥55; restart below 45 | ON, ON, ON, OFF, OFF, ON | **PASS (software)** |
| F3 | 39.0 °C and 39.5 °C | Heater OFF, humidifier OFF, circulation fan ON | D10 HIGH, D6 HIGH, D12 LOW at both points | **PASS (software)** |
| F4 | Heater OFF at 38.5 °C after overheat | Heater remains OFF above 38.0; humidifier may resume below 39.0 | Heater OFF; humidifier resumed at 44.9 % | **PASS (software)** |
| F5 | Heater re-enable after overheat | Heater ON only at/below 37.5 | ON at 37.5 °C | **PASS (software)** |
| F6 | Incubator DHT returns NaN and stays stale >10 s | `valid:false`; bulb, humidifier, fan and exhaust all OFF; telemetry values `null` | All four incubator relays HIGH; flags false; `valid:false`, `temperature_c:null`, `humidity_percent:null` | **PASS (software)** |
| F7 | Overheat (39.5 °C) followed by sensor loss | Still ends in all-off state | All incubator relays OFF | **PASS (software)** |
| F8 | Sensor recovers at 37.0 °C / 44.0 % | Validity returns; heater, humidifier and fan re-initialise | `valid:true`, heater ON, humidifier ON, fan ON | **PASS (software)** |
| F9 | Brooder DHT fails >10 s while incubator stays healthy | Brooder bulb and humidifier OFF; incubator continues | Both brooder relays OFF; incubator `valid:true`, fan ON | **PASS (software)** |
| F10 | Brooder 29.5 → 31.0 → 32.0 °C; humidity 44.9 → 60.0 % | ON ≤30, hold, OFF ≥32; humidifier ON <45, OFF ≥60 | ON, ON, OFF; humidifier ON, OFF | **PASS (software)** |
| F11 | 20 s with **no serial input**, temperature 37.4 then 38.0 °C | Regulation continues autonomously | Heater ON then OFF; fan ON; serial input queue empty | **PASS (software)** |

No physical relay, heater, fan, humidifier, sensor or HC-05 behaviour was
observed. The table is a software control-law result only.

## 5. Verification performed

### 5.1 Genuine Arduino compile/link for the Uno

Toolchain found in the repository workspace:

```
./.arduino/bin/arduino-cli.exe version
arduino-cli  Version: 1.5.2-rc.1 Commit: fef6e48df Date: 2026-07-23T11:13:25Z

./.arduino/bin/arduino-cli.exe core list
arduino:avr 1.8.8  Installed 1.8.8  Arduino AVR Boards
```

The `Servo` library was missing from the user library set; it was installed
from the already-downloaded `.arduino/downloads/libraries/Servo-1.3.0.zip`
(user library `C:\Users\celine\Documents\Arduino\libraries`). This is a local
build-environment setup step, not a firmware change.

Exact build command:

```
./.arduino/bin/arduino-cli.exe compile \
  --fqbn arduino:avr:uno \
  --build-path .arduino/build_a03 \
  arduino/SmartHatch_Combined
```

Actual output:

```
Sketch uses 18804 bytes (58%) of program storage space. Maximum is 32256 bytes.
Global variables use 1768 bytes (86%) of dynamic memory, leaving 280 bytes for local variables. Maximum is 2048 bytes.
Low memory available, stability problems may occur.
```

Artefacts (build directory is untracked):

| Artefact | Size (bytes) | SHA-256 |
|---|---:|---|
| `.arduino/build_a03/SmartHatch_Combined.ino.hex` | 52909 | `5e43ffd944c75da77e458c9a2aed87b2588f90e4c822911a6682f258abb7b795` |
| `.arduino/build_a03/SmartHatch_Combined.ino.elf` | 113060 | `11124704e3e8b48713826cebc45483546ec2140995d823058c85112191b3efb7` |
| `.arduino/build_a03/SmartHatch_Combined.ino.eep` | 13 | — |

The app-facing `SmartHatch_Uno` sketch was compiled for comparison only:

```
./.arduino/bin/arduino-cli.exe compile \
  --fqbn arduino:avr:uno \
  --build-path .arduino/build_a03_uno \
  arduino/SmartHatch_Uno
```

```
Sketch uses 15620 bytes (48%) of program storage space. Maximum is 32256 bytes.
Global variables use 1662 bytes (81%) of dynamic memory, leaving 386 bytes for local variables. Maximum is 2048 bytes.
Low memory available, stability problems may occur.
```

Both builds link successfully, but the **86 % SRAM** figure for the control
sketch is a risk: only 280 bytes remain for stack/local variables. This must be
watched before adding RTC, HC-05 or alarm code.

### 5.2 Host control simulation

Build with MSVC (no board attached):

```
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%TEMP%\sh_a03" mkdir "%TEMP%\sh_a03"
cl /nologo /EHsc /std:c++14 /W3 ^
   /I arduino\SmartHatch_Combined\host\shim ^
   arduino\SmartHatch_Combined\host\control_host_sim.cpp ^
   /Fo:%TEMP%\sh_a03\ /Fe:%TEMP%\sh_a03\control_host_sim.exe
%TEMP%\sh_a03\control_host_sim.exe > %TEMP%\sh_a03\capture.ndjson
py -3 arduino\SmartHatch_Combined\host\check_control.py %TEMP%\sh_a03\capture.ndjson
```

Actual result:

```
A-03 control_host_sim: checks=109 failures=0 bytes=26876 lines=91 simulated_ms=151000
PASS: A-03 control/fail-safe invariants; 59 telemetry frame(s);
valid=56 invalid=3 overheat=6 brooder_invalid=1;
invalid=>all incubator outputs off, overheat=>heater+humidifier off/fan on,
recovery observed
```

The process exit code was `0`. Every one of the 109 assertions passed,
including relay-pin versus firmware-flag consistency.

### 5.3 A-02 regression

The A-02 capture was regenerated from the changed firmware. The only difference
is the intended safety fix: the post-sensor-failure telemetry frame changed
from `"fan_on":true` to `"fan_on":false`. The A-02 checker still passes.

```
host_sim: bytes=3364 lines=19 simulated_ms=19100
PASS: 19 frames, 6 acked ids, 1 running frame(s), 3 structured rejection(s), LF-only framing
```

Fixture:
`test/fixtures/firmware/combined_a02_capture.ndjson`
SHA-256 `16f1cd92a5b1cf29f7f5d97069b85740ebd2b309b86669e66139985ebb267d11`.

### 5.4 Flutter tests

```
flutter test test/firmware_control_failsafe_test.dart test/firmware_ndjson_contract_test.dart
```

Actual result: `All tests passed!` (12 tests).

```
flutter analyze test/firmware_control_failsafe_test.dart test/firmware_ndjson_contract_test.dart
```

Actual result: `No issues found!`.

```
flutter test
```

Actual result: `All tests passed!` (192 tests).

A-03 fixture:
`test/fixtures/firmware/combined_a03_control_capture.ndjson`
SHA-256 `eea705b644254aa621b97b017b7e5165e01f960cb8f69fc60a20e1e8ad70924b`.

## 6. Evidence files

| File | Role |
|---|---|
| `arduino/SmartHatch_Combined/host/control_host_sim.cpp` | Compiles real sketch; scripts sensors/time; records relay pins; asserts 109 checks |
| `arduino/SmartHatch_Combined/host/check_control.py` | Independent telemetry invariant checker |
| `test/fixtures/firmware/combined_a03_control_capture.ndjson` | Real captured NDJSON from the last run |
| `test/firmware_control_failsafe_test.dart` | CI re-check of the captured fail-safe evidence |
| `test/fixtures/firmware/combined_a02_capture.ndjson` | A-02 regression fixture, regenerated for the fan fix |
| `docs/a03_local_control_failsafe.md` | This record |

## 7. Errors and limitations

- No compile or test errors in the final run.
- **No physical evidence.** The host harness does not model relay polarity,
  relay contact behaviour, heater/humidifier power, DHT electrical faults,
  thermal inertia, sensor accuracy, 9600-baud timing or HC-05.
- The overheat cutoff is not independent: it reads the same DHT11 that drives
  the heater. A stuck-but-plausible low reading can still command heat. An
  independent hardware thermal fuse/cutout is still required.
- No independent watchdog is configured. A firmware hang is not covered.
- A DHT11 that keeps returning the same plausible value is treated as valid;
  staleness is detected only when reads fail, not when values are frozen.
- Over-temperature has no distinct telemetry flag and no local buzzer alarm;
  the buzzer currently alarms only on sensor invalidity. Observability is
  therefore limited to `bulb_on:false`/`humidifier_on:false`.
- The exhaust fan keeps its normal 30 min OFF / 30 s ON schedule during
  overheat; it is not forced ON for cooling.
- `SmartHatch_Uno` (app-facing sketch) remains command-driven; it does not
  provide local regulation without the phone. That is a known HW-IMP-01 gap,
  not a pass for A-03 on that sketch.
- The configured thresholds are not formally approved.
- SRAM usage is 86 %, with the compiler's low-memory warning.

## 8. What still needs verification

1. **Approved limits** for temperature, humidity, overheat cutoff and stale
   timeout, signed off by the responsible project owner.
2. **Unpowered/low-power bench checks** with a qualified supervisor:
   relay polarity (active-LOW), D10 heater, D12 fan, D6 humidifier, D9 exhaust,
   D5/D11 brooder, and D7/D8 buzzers.
3. **Supervised empty-incubator run** after documented electrical safety
   clearance and explicit authorization: verify real temperature/humidity
   regulation, heater/fan/humidifier response, sensor-disconnect fail-safe and
   overheat cutoff with an independent thermometer.
4. **HC-05 Classic SPP** link and Flutter Android end-to-end behaviour
   (A-06 / integration), including stale/live and ACK-versus-physical-state
   distinctions.
5. **Watchdog and independent thermal cutout** design review; confirm SRAM
   headroom before adding RTC/HC-05/alarm code.
6. **HW-IMP-01**: decide whether the app-facing `SmartHatch_Uno` sketch gets
   the same local control law or is retired in favour of the combined
   controller.

## 9. Required report

**Task ID:** ORIGINAL:A-03 (display A-03)
**Owner:** Ally
**Status:** Implemented and host-verified; not flashed; no powered or physical test.

**What I actually changed:**
- Fixed the invalid-sensor safe state so the incubator circulation fan is also
  de-energised (D12 HIGH) and `incubatorFanState` is false.
- Forced the incubator humidifier OFF during over-temperature, in addition to
  the existing heater cutoff; circulation fan remains ON.
- Documented the local-only/software-cutoff behaviour in the sketch header.
- Added a host control/fail-safe harness, an independent telemetry checker, a
  captured fixture, a Flutter regression test and this record.
- Regenerated the A-02 fixture for the one intended telemetry change
  (`fan_on:false` after sensor loss).

**Files modified:**
- `arduino/SmartHatch_Combined/SmartHatch_Combined.ino`
- `arduino/SmartHatch_Combined/host/README.md`
- `arduino/SmartHatch_Combined/host/control_host_sim.cpp` (new)
- `arduino/SmartHatch_Combined/host/check_control.py` (new)
- `test/fixtures/firmware/combined_a03_control_capture.ndjson` (new)
- `test/firmware_control_failsafe_test.dart` (new)
- `test/fixtures/firmware/combined_a02_capture.ndjson` (regenerated)
- `docs/a02_ndjson_serial_protocol.md` (scope note: A-03 relay-only change)
- `docs/a03_local_control_failsafe.md` (new)

**Tests performed:**
- `arduino-cli compile` for `SmartHatch_Combined` (Uno) and `SmartHatch_Uno`
  (comparison).
- A-03 host simulation: 109 assertions, 0 failures, 151 s simulated time,
  91 output lines.
- `check_control.py` on the captured telemetry: PASS.
- A-02 host capture + `check_ndjson.py`: PASS.
- `flutter test test/firmware_control_failsafe_test.dart test/firmware_ndjson_contract_test.dart`:
  12 tests passed.

**Actual results:** All host/software checks passed. Compile/link succeeded:
18 804 bytes flash (58 %), 1 768 bytes SRAM (86 %), 280 bytes free for
`SmartHatch_Combined`; 15 620 bytes flash (48 %), 1 662 bytes SRAM (81 %) for
`SmartHatch_Uno`.

**Evidence:** See §5. Hex SHA-256
`5e43ffd944c75da77e458c9a2aed87b2588f90e4c822911a6682f258abb7b795`;
ELF SHA-256
`11124704e3e8b48713826cebc45483546ec2140995d823058c85112191b3efb7`;
A-03 fixture SHA-256
`eea705b644254aa621b97b017b7e5165e01f960cb8f69fc60a20e1e8ad70924b`.

**Errors:** None in the final run. The only environment error encountered was
`Servo.h` missing from the user library set; it was installed from the
already-downloaded Servo 1.3.0 zip.

**Remaining blockers:**
- Formal approval of incubation/fail-safe limits.
- Qualified documented electrical safety clearance and explicit authorization
  before any powered or empty-incubator test.
- Physical relay/sensor/HC-05 verification.
- HW-IMP-01 decision/alignment for the app-facing sketch.
- Independent thermal cutout and watchdog are not implemented.

**What still needs verification:**
- Real heater/fan/humidifier response under load.
- Real DHT11 failure modes, including stuck-but-plausible readings.
- Overheat cutoff on a supervised empty incubator with an independent
  thermometer.
- HC-05 SPP + Flutter Android + Supabase end-to-end latency/staleness and
  ACK-versus-physical-state behaviour.
- SRAM stability at 86 % with the full integrated firmware.

**Recommended next task:** **HW-IMP-01** — align the app-facing firmware with
the autonomous local-control/protocol contract; then schedule the supervised
empty-incubator A-03 physical run after safety clearance. **A-06** (HC-05
end-to-end) follows once the local controller is the agreed single firmware.
