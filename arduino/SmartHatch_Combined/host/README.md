# A-02 NDJSON host capture harness

This harness compiles the **real** `SmartHatch_Combined.ino` source against
shimmed AVR headers and drives `setup()` / `loop()` with scripted input and
simulated time. stdout is the exact byte stream the sketch wrote to `Serial`.
The captured lines therefore come from the production emit functions, not from
hand-written examples.

It is **software evidence only**. It does not model 9600-baud timing, the Uno's
64-byte RX ring, USB buffering, DHT electrical behaviour, relay polarity, servo
torque, sensor accuracy or any incubation/safety property. No board is flashed
and no load is activated.

## Files

| File | Purpose |
|---|---|
| `shim/` | Minimal `Arduino.h`, `DHT.h`, `Servo.h`, `LiquidCrystal_I2C.h`, `EEPROM.h`, `Wire.h` host stand-ins |
| `ndjson_host_sim.cpp` | A-02 scenario driver; includes `../SmartHatch_Combined.ino` |
| `check_ndjson.py` | Strict framing/schema checker for an A-02 capture |
| `control_host_sim.cpp` | A-03 control/fail-safe driver; records relay pin levels and asserts safe-state transitions |
| `check_control.py` | A-03 telemetry invariant checker |
| `start_host_sim.cpp` | A-06 START/ACK/RUNNING driver; scripts sensor loss, relay readback mismatch and reboot |
| `check_start.py` | A-06 START handshake / ordering checker |

## Reproduce

Build on Windows with MSVC (no Arduino board needed):

```bat
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%TEMP%\sh_a02" mkdir "%TEMP%\sh_a02"
cl /nologo /EHsc /std:c++14 /W3 ^
   /I arduino\SmartHatch_Combined\host\shim ^
   arduino\SmartHatch_Combined\host\ndjson_host_sim.cpp ^
   /Fo:%TEMP%\sh_a02\ /Fe:%TEMP%\sh_a02\ndjson_host_sim.exe
%TEMP%\sh_a02\ndjson_host_sim.exe > %TEMP%\sh_a02\capture.ndjson
py -3 arduino\SmartHatch_Combined\host\check_ndjson.py %TEMP%\sh_a02\capture.ndjson
```

The committed fixture `test/fixtures/firmware/combined_a02_capture.ndjson` is a
byte-for-byte copy of the last real run, and
`test/firmware_ndjson_contract_test.dart` re-checks it with `flutter test`.

## Scenario in the harness

1. Boot with blank EEPROM: `batch_started`, `controller_ready`,
   `batch_state_restored` events.
2. `STATUS` before the first valid DHT read: telemetry reports `null`, not `0`.
3. `TURN_NOW` after a valid read: `running` → `egg_turn_completed` → terminal
   `ack`.
4. Unknown command: `ack` with `error.code = unknown_command`.
5. Duplicate `TURN_NOW` id: the original terminal ack is replayed and the servo
   is not moved again.
6. `NEW_BATCH`, malformed command, and an over-length line:
   `required_id_or_cmd_missing` and `line_too_long` structured errors.
7. Scripted incubator sensor failure after the stale timeout: telemetry keeps
   `valid:false` and `temperature_c:null` / `humidity_percent:null`.

The shim readings (37.6 °C / 51.4 % and 31.2 °C / 49.0 %) are scripted inputs,
not measurements of any physical incubator.

## A-03 control / fail-safe harness

`control_host_sim.cpp` compiles the same production sketch, scripts sensor
values and time, and records every `digitalWrite()` as a relay pin level. It
asserts the temperature/humidity hysteresis bands, overheat response, invalid
and stale sensor fail-safes, recovery, and a no-serial-input autonomy phase.
stdout is the NDJSON capture; human-readable PASS/FAIL checks go to stderr and
the process exits non-zero on any failure.

Build and run on Windows with MSVC:

```bat
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%TEMP%\sh_a03" mkdir "%TEMP%\sh_a03"
cl /nologo /EHsc /std:c++14 /W3 ^
   /I arduino\SmartHatch_Combined\host\shim ^
   arduino\SmartHatch_Combined\host\control_host_sim.cpp ^
   /Fo:%TEMP%\sh_a03\ /Fe:%TEMP%\sh_a03\control_host_sim.exe
%TEMP%\sh_a03\control_host_sim.exe > %TEMP%\sh_a03\capture.ndjson
py -3 arduino\SmartHatch_Combined\host\check_control.py %TEMP%\sh_a03\capture.ndjson
```

The committed fixture
`test/fixtures/firmware/combined_a03_control_capture.ndjson` is a byte-for-byte
copy of the last real run, and `test/firmware_control_failsafe_test.dart`
re-checks it with `flutter test`.

This is **software evidence only**. It does not prove relay polarity, heater or
humidifier power, DHT accuracy, thermal behaviour, HC-05 operation or any
incubation outcome. No board is flashed and no load is activated.

## A-06 START / ACK / RUNNING harness

`start_host_sim.cpp` compiles the same production sketch and scripts the START
handshake: receipt ACK first, RUNNING only after fresh valid readings and relay
output-latch checks, duplicate command/batch ids, sensor loss, a forced relay
readback mismatch, an EEPROM reload, and a completed-batch rejection. It writes
NDJSON to stdout, PASS/FAIL checks to stderr, and exits non-zero on failure.

Build and run on Windows with MSVC:

```bat
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if not exist "%TEMP%\sh_a06" mkdir "%TEMP%\sh_a06"
cl /nologo /EHsc /std:c++14 /W3 ^
   /I arduino\SmartHatch_Combined\host\shim ^
   arduino\SmartHatch_Combined\host\start_host_sim.cpp ^
   /Fo:%TEMP%\sh_a06\ /Fe:%TEMP%\sh_a06\start_host_sim.exe
%TEMP%\sh_a06\start_host_sim.exe > %TEMP%\sh_a06\capture.ndjson
py -3 arduino\SmartHatch_Combined\host\check_start.py %TEMP%\sh_a06\capture.ndjson
```

The committed fixture
`test/fixtures/firmware/combined_a06_start_capture.ndjson` is a byte-for-byte
copy of the last real run, and `test/firmware_start_ack_running_test.dart`
re-checks it with `flutter test`.

RUNNING here means the MCU output latch and sensor validity, not physical
relay-contact feedback. No board is flashed and no load is activated.
