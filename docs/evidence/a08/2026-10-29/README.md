# A-08 evidence bundle — 2026-10-29

**Task:** ORIGINAL:A-08 (dated test log with photos and raw captures)
**Owner:** Ally · **Branch:** `ally-branch3` · **HEAD:** `38232e9d75e0bb602537832fa0d28864b61c7a8c`
**Nature:** **software-only verification evidence**. No board was flashed, no
relay/load was energised, no sensor or HC-05 was physically exercised, and no
egg test was performed. There are therefore **no hardware photos** in this
bundle. Do not treat any file here as a physical pass.

## Contents

| File | What it is |
|---|---|
| `toolchain.txt` | Installed `arduino-cli`, AVR core and library versions |
| `compile_a08.txt` | Genuine Uno compile/link output for `SmartHatch_Combined` |
| `a02_capture.ndjson` | A-02 host-simulation Serial capture (19 frames) |
| `a02_capture.stderr.txt` | A-02 host diagnostic line |
| `a02_check.txt` | A-02 strict framing/schema checker result |
| `a03_capture.ndjson` | A-03 control/fail-safe host capture (91 frames) |
| `a03_checks.txt` | A-03 per-assertion PASS/FAIL output (109 checks) |
| `a03_check.txt` | A-03 telemetry invariant checker result |
| `a06_capture.ndjson` | A-06 START/ACK/RUNNING host capture (39 frames) |
| `a06_checks.txt` | A-06 per-assertion PASS/FAIL output (48 checks) |
| `a06_check.txt` | A-06 START handshake checker result |
| `build_a02_host.txt` | A-02 host harness MSVC build output |
| `build_a03_host.txt` | A-03 host harness MSVC build output |
| `build_a06_host.txt` | A-06 host harness MSVC build output |
| `flutter_test.txt` | Full `flutter test` output (209 tests) |
| `flutter_analyze.txt` | `flutter analyze` output for the A-06/A-02/A-03 firmware tests |
| `sha256sums.txt` | SHA-256 of every capture/check/artifact in this bundle |
| `../check_a08_log.py` | Verifies the log format, `NOT RUN` physical rows and every SHA-256 |

The three `.ndjson` captures are raw Serial byte streams emitted by the real
firmware source compiled against host shims. They are not physical captures.

## Exact reproduction commands

```bat
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
```

```bat
cl /nologo /EHsc /std:c++14 /W3 ^
   /I arduino\SmartHatch_Combined\host\shim ^
   arduino\SmartHatch_Combined\host\ndjson_host_sim.cpp ^
   /Fo:%TEMP%\sh_a02\ /Fe:%TEMP%\sh_a02\ndjson_host_sim.exe
%TEMP%\sh_a02\ndjson_host_sim.exe > a02_capture.ndjson
py -3 arduino\SmartHatch_Combined\host\check_ndjson.py a02_capture.ndjson
```

```bat
cl /nologo /EHsc /std:c++14 /W3 ^
   /I arduino\SmartHatch_Combined\host\shim ^
   arduino\SmartHatch_Combined\host\control_host_sim.cpp ^
   /Fo:%TEMP%\sh_a03\ /Fe:%TEMP%\sh_a03\control_host_sim.exe
%TEMP%\sh_a03\control_host_sim.exe > a03_capture.ndjson 2> a03_checks.txt
py -3 arduino\SmartHatch_Combined\host\check_control.py a03_capture.ndjson
```

```bat
cl /nologo /EHsc /std:c++14 /W3 ^
   /I arduino\SmartHatch_Combined\host\shim ^
   arduino\SmartHatch_Combined\host\start_host_sim.cpp ^
   /Fo:%TEMP%\sh_a06\ /Fe:%TEMP%\sh_a06\start_host_sim.exe
%TEMP%\sh_a06\start_host_sim.exe > a06_capture.ndjson 2> a06_checks.txt
py -3 arduino\SmartHatch_Combined\host\check_start.py a06_capture.ndjson
```

```bat
arduino-cli compile --fqbn arduino:avr:uno --build-path .arduino\build_a08 arduino\SmartHatch_Combined
```

## Physical evidence convention (future, after authorization)

When a supervised physical test is authorized, store files under:

```
docs/evidence/a08/<YYYY-MM-DD>/<TEST-ID>-setup.jpg
docs/evidence/a08/<YYYY-MM-DD>/<TEST-ID>-meter.jpg
docs/evidence/a08/<YYYY-MM-DD>/<TEST-ID>-capture.ndjson
docs/evidence/a08/<YYYY-MM-DD>/<TEST-ID>-capture.sha256
```

Each photo should show the test ID, date, board/load state and meter reading.
Each raw capture must be unedited and hashed. The A-08 log links to these paths
and records the SHA-256. No physical file is fabricated in this bundle.

## What this bundle does not prove

- HC-05 Classic SPP, Flutter Android, Supabase or end-to-end operation.
- Relay polarity/contact closure, heater/fan/humidifier power, DHT accuracy,
  overheat behaviour or thermal safety.
- Any incubation result, hatch count or species-specific physical behaviour.
- That the software build was flashed to a board.

Physical activation still requires explicit authorization and qualified
documented electrical safety clearance.
