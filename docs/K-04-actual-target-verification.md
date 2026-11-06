# ORIGINAL:K-04 — Actual versus Target

- Owner: Kath
- Verification date: October 29, 2026
- Status: PARTIAL overall; local display separation and regression checks pass.
- Source: `feature/kath-k03a-species-details`, HEAD
  `c7a26cfcaa619708aff4f793e8068ee176a6cf58`, plus uncommitted working changes.
  HEAD alone does not contain this implementation.

## Changes reviewed and completed

The interrupted implementation was retained, not restarted. Its files are:

- `lib/widgets/incubator_readings.dart`: read-only Actual/Target presentation and
  receipt-age presentation model. Null/non-finite, stale, unknown-freshness and
  disconnected actuals show a dash rather than a target. Per-sensor failures
  remain independent. No Start, writes or transport commands.
- `lib/main.dart`: Home and active-incubation panels use this presentation;
  gauges hide stale/invalid values; the console separates physical actuals from
  its labeled simulation preview. Batch details no longer substitute set points
  or species humidity for actual measurements, or infer Normal from them.
  The global latest cloud row has unverified age/batch association, so its
  actual display stays unavailable. Home targets remain unavailable rather than
  assuming a species. Existing configured targets elsewhere remain unapproved.
- `test/incubator_readings_test.dart`: 14 presentation/boundary tests, including
  missing, invalid, stale, unknown, disconnected, partial failure, unknown targets,
  and 320/390/768/1440px layouts at 2x text scale.
- `test/batch_details_cards_test.dart`: expectations now require unavailable
  actuals, with settings distinguished from measurements.

The resumed work completed validation and fixed formatting in the two new
widget/test files and a trailing blank line left by the interrupted deletion of
the old metric tile. Earlier species work, artwork, navigation, unrelated Git
changes and untracked files were preserved. No profile numbers, protocol fields,
Start recovery, day calculations or physical-state logic were implemented here.

## Exact verification

Commands used the SDK binaries under `C:\flutter\flutter\bin\`:

```powershell
flutter.bat test --no-pub test/incubator_readings_test.dart test/batch_details_cards_test.dart test/hardware_console_sim_test.dart --reporter expanded
flutter.bat test --no-pub --reporter expanded
flutter.bat analyze --no-pub
dart.bat format --output=none --set-exit-if-changed lib/widgets/incubator_readings.dart test/incubator_readings_test.dart
git diff --check
```

- Targeted final run: `+27: All tests passed!` (exit 0).
- Full suite: `+235: All tests passed!` (exit 0). Final subsequent edits were
  whitespace only and this document; targeted tests were rerun after whitespace fixes.
- Analyzer: `No issues found!` (exit 0).
- Final formatting: `Formatted 2 files (0 changed)` (exit 0).
- Final tracked whitespace check: exit 0, with existing LF/CRLF conversion
  warnings. This Git check does not cover untracked files.
- Initial format and whitespace checks failed on formatting and a trailing blank
  line; these were corrected. No test/analyzer failures were observed.

## Precise remaining blockers and verification

The existing six-second receipt window is reused, not newly approved as an
acquisition-age policy. A recent receipt is labeled as such, explicitly not
verified live. An approved exact-revision decoder and trusted acquisition time,
source identity, batch association and freshness policy are still needed to
establish genuine current sensor measurements. No new wire fields were invented.
Approved species/stage targets and their backend/firmware mappings are missing;
displaying configured legacy values does not approve or physically apply them.
Console targets currently describe its configured simulator profile, not proof
of an applied physical batch profile.

Tests are local software/mock evidence only. They do not establish real Android
permissions/lifecycle, HC-05 SPP, sensor validity, firmware identity, electrical
safety, authorized Supabase/RLS or end-to-end behavior. Existing legacy test
names/assumptions (including Day-7 starts) are not approved by a green suite.
No powered loads, flashing, eggs, cloud production writes, deployment, commit,
merge or push occurred. Intended software supports Chicken/Duck/Quail; physical
pilot scope remains Chicken-only after separate authorization/safety clearance.

Recommended next task: CURRENT:UI-IMP-01 with OCT26:K-04, using supplied exact
source/decoder evidence and approved profile/freshness mappings. Keep K-04
PARTIAL until these dependencies and authorized device checks are satisfied.
