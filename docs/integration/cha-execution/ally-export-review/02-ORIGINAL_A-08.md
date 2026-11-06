# 2 ORIGINAL:A-08 — Document sensor and actuator tests
Report ID: R-mvtmy9ex8u5s
Attribution: Ally / Ally
Reported status: Completed; date: 2026-10-29; latest supplied attempt for task: true

## Body

Actual results
The log format contains every requested field.
All 15 physical rows remain NOT RUN; none claims a hardware pass.
All 5 software rows are labelled PASS (software) and are explicitly stated not to be hardware evidence.
The dated evidence bundle contains raw captures and checker outputs.
Compile/link succeeded with 65 % flash and 86 % SRAM usage.

Errors
None in the final verification. No physical test was attempted.

Remaining blockers
Cla review and sign-off.
Written approval of temperature/humidity/overheat/stale-timeout limits.
Explicit authorization and qualified documented electrical safety clearance for physical tests.
Tester-supplied physical observations, dates, tester names, photos and raw captures.
HC-05 module, Android phone and authorized Supabase environment for end-to-end rows.
RTC hardware if P-14 is to be more than BLOCKED.
What still needs verification
Every physical row P-01 through P-15, especially relay polarity, sensor disconnect/stale, overheat, HC-05/app, START ACK versus RUNNING, Day N, live versus stal
e, and the supervised empty-incubator run.
That every future physical PASS has a photo and an unedited raw capture with a matching SHA-256.
That cloud Active is not reported as physical RUNNING.
Recommended next task
Cla review of the A-08 format and the 2026-10-29 software bundle, followed by a supervised unpowered/low-power bench session covering P-01, P-02, P-03, P-09, P-
10 and P-12 after written safety clearance. The empty-incubator rows follow only after separate authorization.

## Evidence links (not supplied files)

Evidence
Log: docs/a08_hardware_test_log.md
Bundle: docs/evidence/a08/2026-10-29/
Integrity checker: docs/evidence/a08/check_a08_log.py
HEX SHA-256: ccd8143994c236ba6dce267301f7c3fb1aa891b63b635b2dd483198202884429
ELF SHA-256: 808a72b7de00bef4dd4c9ea16f1ca1999350dfc26e0066a01dbdcfd4103ceb39
A-06 capture SHA-256: 796ffd184736ed62568b8b97425d0e08b64057d7192f2e19fd50bef15c8fb7c4
A-03 capture SHA-256: eea705b644254aa621b97b017b7e5165e01f960cb8f69fc60a20e1e8ad70924b
A-02 capture SHA-256: 16f1cd92a5b1cf29f7f5d97069b85740ebd2b309b86669e66139985ebb267d11
No commit, merge, push, deployment, database write, flashing or load activation was performed.
