# ORIGINAL:K-05 — Reading status labels

- Owner: Kath
- Date: October 29, 2026
- Status: PARTIAL — local presentation/interface tested; real classification
  adapter and device verification are blocked.
- Branch: `feature/kath-k03a-species-details`
- HEAD: `c7a26cfcaa619708aff4f793e8068ee176a6cf58`, plus existing and new
  uncommitted working changes. HEAD alone is not the tested implementation.

## What actually changed / files modified

- `lib/widgets/incubator_readings.dart`: added exact, separately identifiable
  labels Fresh, Reading Not Updated, Sensor Unavailable, Unknown Freshness,
  Incubator Disconnected to the existing dashboard panel. Added a typed
  `fromBackendClassification` interface which consumes a supplied classification,
  without computing age or introducing a threshold. These enum names are internal
  UI inputs, not invented backend fields or wire values.
- Disconnection defaults to unverified. Only the explicit
  `verifiedIncubatorDisconnected` input selects Incubator Disconnected; it
  overrides a retained Fresh classification and hides actual numbers. Its message
  states autonomous incubation may continue and Stop is not confirmed.
- Missing classification maps to Unknown Freshness. Non-fresh backend states hide
  retained actuals; targets never replace them. Even a Fresh classification cannot
  display null/non-finite values as valid readings. Fresh describes the backend's
  classification, not physical Running or applied targets.
- Existing K-04 recent-receipt preview now explicitly bears Unknown Freshness,
  while retaining the recently-received/not-verified-live explanation. Existing
  receipt-age behavior is preserved, not approved as a backend policy.
- `test/reading_status_states_test.dart`: nine tests for every classification,
  missing classification, verified disconnect, mock transitions, invalid values,
  and unverified transport/receipt evidence. The mock transition is automated
  widget evidence, not a manually operated real device.
- `test/incubator_readings_test.dart`: one assertion now targets the exact label
  instead of a substring duplicated by the explanatory message.
- This document records evidence, limitations and pending work.

No edits to `lib/main.dart`, backend/transport controllers, profiles, assets,
navigation, history or unrelated user files were made for K-05. Existing
uncommitted K-03/K-04 and other work were preserved. No Start replay, day logic,
actuator commands, protocol fields, numerical profiles or network writes added.

## Tests performed / actual results / errors

Commands used binaries under `C:\flutter\flutter\bin\`:

```powershell
flutter.bat test --no-pub test/reading_status_states_test.dart test/incubator_readings_test.dart test/batch_details_cards_test.dart --reporter expanded
flutter.bat test --no-pub --reporter expanded
flutter.bat analyze --no-pub
dart.bat format --output=none --set-exit-if-changed lib/widgets/incubator_readings.dart test/reading_status_states_test.dart test/incubator_readings_test.dart
git diff --check
```

- Targeted first and final runs: `+25: All tests passed!`, exit 0.
- Full suite: `+244: All tests passed!`, exit 0. Subsequent source edits were
  formatting/test-title only; targeted tests were rerun afterward.
- Analyzer: `No issues found!`, exit 0.
- Final formatter: `Formatted 3 files (0 changed)`, exit 0.
- Tracked whitespace check: exit 0, existing LF/CRLF conversion warnings only;
  this Git check excludes untracked files.
- Initial formatter checks returned exit 1 for style differences; corrected.
  No test/analyzer failures observed. No manual visual toggle claimed.

## Remaining blockers / what still needs verification

`SupabaseService.getLatestReading()` currently returns the global latest
`sensor_readings` map ordered by `recorded_at`. It does not expose an approved
typed freshness classifier or verified link-disconnection evidence. The existing
dashboard `_actualReadings` still uses K-04's receipt-only path, NOT the new backend
adapter. Thus Fresh and verified-disconnect branches are software-fixture proven
only; they are not claimed connected to real backend data. No raw JSON field
mapping or new threshold has been guessed. The existing receipt timeout remains
legacy presentation behavior, not fulfillment of backend classification wiring.

Required input: selected same-revision backend classification contract and
approved adapter mapping, including validity/expiry of that classification,
source/batch association, and separately verified incubator-link disconnection
evidence. A default phone transport state or Wi-Fi/cloud outage is insufficient.
Then wire the adapter and verify transitions with authorized isolated data.

Actual Android/HC-05 SPP pairing/lifecycle, sensors, firmware identity, safety and
end-to-end behavior remain unverified. These local tests do not authorize physical
activation or approve legacy profiles/day assumptions in the full suite.
Architecture remains autonomous Uno + RTC + sensors/actuators, HC-05 Classic SPP,
Flutter Android, and authorized Supabase through phone internet; USB diagnostic
only. Intended software covers Chicken/Duck/Quail; physical pilot is Chicken-only
after separate authorization and qualified documented safety clearance. No hatch
outcome or completed-cycle evidence is claimed.

No commit, merge, push, deployment, migration, production write, flashing,
powered load or egg test occurred.

## Recommended next task

CURRENT:UI-IMP-01 / OCT26:K-05: obtain the precise backend classifier and verified
link evidence mapping, wire the tested interface, and perform authorized
integration/device checks. Related-task coverage is not completion.
