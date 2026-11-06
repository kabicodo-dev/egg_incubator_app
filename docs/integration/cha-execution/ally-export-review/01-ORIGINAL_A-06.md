# 1 ORIGINAL:A-06 — Verify physical Start acknowledgment
Report ID: R-mvtml756lyul
Attribution: Ally / Ally
Reported status: Completed; date: 2026-10-29; latest supplied attempt for task: true

## Body

All host/software checks passed:

First START produced ACK start_received with no RUNNING in the receipt pass.
RUNNING appeared only after a fresh valid sensor read and matching relay latches.
With the incubator sensor invalid, no RUNNING appeared until recovery.
With a forced relay readback mismatch, no RUNNING appeared until the latch matched.
A duplicate command id replayed the ACK and re-asserted RUNNING without a new batch_started or timer reset.
Same batch/new command id was accepted as idempotent; different batch and completed batch were rejected.
After an EEPROM reload simulation, the start identity was restored and a duplicate START did not reset elapsed time.

Errors
None in the final run. Earlier harness iterations exposed and fixed two real issues before the final pass:

a fresh auto-started batch was wrongly treated as an uncertain restored batch;
a post-reboot retry could re-assert RUNNING from stale pre-reboot validity.
Remaining blockers
Flutter start handler still creates the Supabase session/cloud Active row before hardware confirmation; it does not send START or consume RUNNING.
Physical verification requires separate authorization and qualified documented electrical safety clearance.
HC-05 Classic SPP and Flutter Android end-to-end are untested.
RUNNING proves MCU output-latch and sensor validity, not physical relay-contact closure.
No RTC and no independent watchdog; 86 % SRAM usage leaves 267 bytes.
START identity uses magic/version but no CRC; EEPROM writes are not atomic.
What still needs verification
Bench observation of START → ACK → RUNNING with a real Uno, HC-05 and app.
Duplicate START and reboot retry on physical hardware.
Relay stuck-closed detection or an independent thermal cutout.
App behaviour when RUNNING never arrives (must stay unconfirmed and never auto-replay).
Cloud Active vs physical RUNNING mapping and the original Start timestamp.

HW-IMP-01 — wire the Flutter start handler and transport to this START/RUNNING contract, keeping cloud Active distinct from physical RUNNING. Then run a supervi
sed unpowered/low-power bench START test before any loaded incubator run.

## Evidence links (not supplied files)

Evidence
Test record: docs/a06_start_ack_running.md
A-06 fixture: test/fixtures/firmware/combined_a06_start_capture.ndjson SHA-256 796ffd184736ed62568b8b97425d0e08b64057d7192f2e19fd50bef15c8fb7c4
HEX: .arduino/build_a06/SmartHatch_Combined.ino.hex (59483 bytes) SHA-256 ccd8143994c236ba6dce267301f7c3fb1aa891b63b635b2dd483198202884429
ELF: .arduino/build_a06/SmartHatch_Combined.ino.elf (122976 bytes) SHA-256 808a72b7de00bef4dd4c9ea16f1ca1999350dfc26e0066a01dbdcfd4103ceb39
No commit, merge, push, deployment, database write, flashing or load activation was performed.
