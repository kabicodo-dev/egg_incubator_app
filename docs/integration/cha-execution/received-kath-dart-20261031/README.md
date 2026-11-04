# Existing manual-result Dart review evidence — delivery copy

Prepared for the requested evidence handoff on 2026-10-31. This is not a new test run or implementation.

- `dart_manual_result_review.dart` is a byte-for-byte copy of the existing temporary review script. Expected SHA-256: `bcb7ab832eabd97092e6d22a983910cd4e32288e5777f3cd79adbbd1ee57b45e`.
- `dart_manual_result_review.recorded-stdout.txt` exports the console stdout already retained in this session from the original run. There was no separately saved original stdout file. This delivery file was transcribed from the recorded tool output without a repeat run; it must not be represented as a newly captured native log or an independently timestamped original log file.
- The 41 assertions are review-only model checks, including two canonical byte/hash vectors and prospective receipt/error guards. They are not production Flutter, general JSON Schema/JCS, persistence, Auth/RLS, network, controller or physical integration tests.
- Existing cached `crypto` was used. No dependency was installed and no application/firmware/backend code was changed.

Original command (the temporary script and fixture paths belong to the original local review environment):

```powershell
dart --packages="C:\egg_incubator_app\.dart_tool\package_config.json" `
  "C:\Users\ACER\AppData\Local\Temp\opencode\manual-result-01-review-20261031\dart_manual_result_review.dart" `
  "C:\Users\ACER\AppData\Local\Temp\opencode\manual-result-01-review-20261031\docs\contract-review\manual-result-0.1.fixtures.json"
```

Input fixture SHA-256: `a92cba4f788eb844bd04824db3fa14c8c963dc57397299a7ae4d624bc8952f77`. The fixture is already supplied in Mary's full packet at `docs/contract-review/manual-result-0.1.fixtures.json`; it is not recreated or modified here.

Results preserved:

- unknown_time_zero: 422 UTF-8 bytes; `cf269394b7cd7bb037116a8ce7a2f3f56b821e17ef59a836d225ba866f4cd1ac`.
- phone_time_upper: 445 UTF-8 bytes; `61e883f2826e65a1d41715a4f8ea226845e06be3dc3070ed4dae02f21b902bf5`.
- REVIEW-ONLY PASS checks=41; vectors=2; no application/DB/security integration.

Draft-UUID reservation remains a specific Mary decision, not automatically accepted. Lookup tuple matching, retryability-by-code and fixture-scenario clarification remain explicit next-candidate changes. Reviewed 0.1 bytes are unchanged. No task or planned acceptance-case status is changed by this evidence delivery.
