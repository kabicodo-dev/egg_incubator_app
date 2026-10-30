# K-03 — Species UI and profile approval audit

Owner: Kath. Related decision: CHA-04. Date: 2026-10-26.

## Scope and status

- K-03A: **Completed — UI-only**, with software verification below.
- K-03B: **Pending approval** by Ally and the adviser/designated reviewer.
- Overall K-03 is not complete until both parts are verified.

No listed numerical value or description is approved by this audit. These are
existing source values, not advice, physical measurements, or flashed-firmware
verification. No profiles or descriptions were changed.

## Inspected UI and change

In `lib/main.dart`, `SpeciesScreen` loads Supabase presets or retains local
defaults. A card opens `SpeciesDetailsScreen`; Continue opens
`IncubationSetupScreen(selectedSpecies: species)`. Neither callback starts a
batch. Targets on the details page are text, not editable controls.

The details page previously always displayed the full description. It now
starts collapsed with a 48-pixel-minimum View Details button. The button toggles
only local visibility and reports expanded state to accessibility services.
Hide Details collapses it. Continue remains outside the disclosure and retains
its existing callback and styling. Card previews and navigation are unchanged.

Images remain `assets/species/chicken.png`, `duck.png`, and `quail.png`, selected
by `SpeciesIllustration`. No artwork or asset paths were edited.

## Existing values — ALL PENDING TEAM APPROVAL

### Local UI defaults

Source: `lib/main.dart:120–147` (`defaultSpeciesList`).

| Species | Temperature | Stored target humidity | Incubation duration |
| --- | --- | --- | --- |
| Chicken | 37.5 °C | 55% | 21 days |
| Duck | 37.5 °C | 65% | 28 days |
| Quail | 37.5 °C | 58% | 17 days |

### Existing descriptions

Source: `lib/main.dart:98–105` and `127–146` (duplicated text).

- Chicken: 21 days, 37.5 °C, humidity 50–55%; regular turning.
- Duck: about 28 days, 37.5 °C, humidity 60–65%; increase humidity in last 3 days
  without specifying the increased value.
- Quail: about **17–18 days**, 37.5 °C, humidity 55–60%; careful handling.

### Local controller profiles (not changed or physically verified)

Source: `lib/controllers/incubator_controller.dart:34–80`.

| Species | Target °C | Active humidity | Lockdown humidity | Hatch day | Lockdown starts |
| --- | --- | --- | --- | --- | --- |
| Chicken | 37.5 | 45–55% | 65–70% | 21 | Day 19 |
| Duck | 37.5 | 55–60% | 70–75% | 28 | Day 26 |
| Quail | 37.5 | 45–55% | 65–70% | **18** | Day 15 |

All three controller profiles contain heater thresholds of 37.5 °C on and
38.0 °C off, and a four-hour egg-turn interval. These are inventory, not approved
control instructions. Controller code was not edited.

### Conflicts and additional sources

- Quail duration: UI default **17** (`main.dart:142`), description **17–18**
  (`main.dart:104,146`), controller **18** (`incubator_controller.dart:69`).
- Humidity definitions differ across descriptions, UI targets and controller
  active/lockdown ranges. Do not silently choose one as authoritative.
- `SpeciesData.fromPreset` (`main.dart:91–116`) reads database
  `target_temperature`, `target_humidity`, and `incubation_days`. Missing values
  fall back to 37.5 °C, 55%, and 21 days regardless of species. Its description
  remains hardcoded and may disagree with the loaded preset.
- Start's existing `updateActiveSettings` call in the checklist still passes
  humidity **55% for every species**. This is not changed by K-03A.
- Deployed preset values were not queried. Source values are not evidence of
  approved backend values or actual hardware settings.

## Validation boundaries

`test/species_details_ui_test.dart` uses an in-memory read-only HTTP client.
Six widget tests tap all three species at 320- and 450-pixel widths, expand and
collapse descriptions, check the same image asset remains, check targets remain
text-only, and tap Continue to verify the original species reaches egg quantity.
Selection and toggles make no additional API request; the complete tested path
makes GET requests only. A seventh source-boundary test checks the selection and
details screens contain no controller/Start/settings-write dependencies.

This is software verification, not a serial command capture or physical Start
test. No production app startup, Supabase access, serial connection, powered-load
test, firmware edit, database change, commit, push, merge, or deployment is part
of K-03A.

## K-03B approval request

Ally and the adviser/designated reviewer must confirm the descriptions and
species/stage values, explicitly resolve Quail duration and humidity differences,
and identify the approved profile source. Cha must confirm backend mapping and
authority before any later schema/settings integration changes. Do not treat
this UI-only work as approval of existing values.

## Actual check results

- Targeted `flutter test --no-pub test/species_details_ui_test.dart --reporter
  expanded`: 7/7 passed.
- Full `flutter test --no-pub --reporter expanded`: 218/218 passed, exit 0.
- `flutter analyze --no-pub`: no issues found, exit 0.
- `git diff --check`: passed; existing LF/CRLF notices observed.
- `git diff --exit-code -- assets lib/controllers lib/services arduino supabase`:
  no changes, exit 0.
- Full test log: `C:\Users\ACER\AppData\Local\Temp\opencode\k-03a-flutter-tests.log`.
- Analyzer log: `C:\Users\ACER\AppData\Local\Temp\opencode\k-03a-analyze.log`.

For a later visual walkthrough in an approved isolated environment: open each
species card, tap View Details then Hide Details, check that the image remains,
and tap Continue to check the selected species reaches Egg Quantity. Do not
 press Start for this UI check. No browser/manual-device walkthrough or assistive
 technology test was performed for K-03A.

## ORIGINAL:K-03 verification continuation — 2026-10-29

**Task ID:** ORIGINAL:K-03 (original display ID K-03).  
**Owner:** Kath.  
**Status:** PARTIAL — existing UI behavior verified in software; approved
descriptions/profile provenance remains unresolved. This is not K-03B approval.

**What I actually changed:** Preserved the existing uncommitted View Details /
Hide Details implementation. Added one collapsed-details Continue regression
test for each of Chicken, Duck and Quail at 320 pixels. These tests verify the
original species reaches Egg Quantity without expanding the description,
selection makes no additional HTTP requests, and navigation uses GET requests
only. Applied current Dart formatter layout to this test file only. No app,
asset, controller, service, Arduino, Supabase or portal changes were made in
this continuation.

**Files modified:** `test/species_details_ui_test.dart`; this evidence document.
Both already existed as untracked user work and were extended, not replaced.
Other pre-existing tracked/untracked changes were preserved.

**Source revision:** `feature/kath-k03a-species-details`, HEAD
`c7a26cfcaa619708aff4f793e8068ee176a6cf58`, plus the inspected uncommitted
working tree. The HEAD alone does not include that UI implementation or tests.
SDK: `C:\flutter\flutter`, Flutter 3.47.3 / Dart 3.13.3; no upgrade/install.

**Tests performed / actual results:**

- `C:\flutter\flutter\bin\flutter.bat test --no-pub test/species_details_ui_test.dart --reporter expanded`:
  **10/10 passed**, exit 0 (six expanded/collapsed interaction cases at 320/450
  pixels, three collapsed Continue cases, one source-boundary check).
- `C:\flutter\flutter\bin\flutter.bat test --no-pub --reporter expanded`:
  **221/221 passed**, exit 0, including the extended species file.
- `C:\flutter\flutter\bin\flutter.bat analyze --no-pub`:
  **No issues found**, exit 0.
- `C:\flutter\flutter\bin\dart.bat format --output=none --set-exit-if-changed test/species_details_ui_test.dart`:
  **0 files changed**, exit 0 on final check.
- `git diff --check`: exit 0; existing LF/CRLF warnings remain. This tracked-diff
  check does not cover untracked additions; the test file was separately parsed
  and run by Flutter and checked with Dart format.
- `git diff --exit-code -- assets/species`: exit 0; tracked species artwork
  unchanged. Source inspection confirms selection only navigates, the disclosure
  changes local widget state only, Continue navigates to setup, and target rows
  are text rather than editing controls.

**Evidence:** Actual command output from this continuation, the added regression
assertions, existing six interaction tests, and source-boundary assertions.
The species tests use an in-memory read-only HTTP client, not a real Supabase
server. The source-boundary check is not a physical transport capture. Existing
full-suite legacy scenarios are regression evidence, not approval of their
historical product assumptions or numerical settings.

**Errors:** Initial parallel full-suite/analyzer/formatter attempts exceeded
120-second tool limits and supplied no successful completion result. Sequential
reruns completed successfully (300-second limits for full suite/analyzer).
The initial formatter check reported formatting differences; these were patched
and the final check passed. No failing assertions remain in the completed runs.

**Remaining blockers:** No new approved descriptions or profile-source approval
was supplied. Existing hardcoded descriptions/defaults and the profile conflicts
inventoried above remain unchanged and must not be treated as approved guidance.
Mary Charlyn (historical Cha/Mary aliases) owns backend consistency; Ally and the
adviser/designated reviewer must supply the authoritative approvals.

**What still needs verification:** Approved content/profile provenance, actual
Android/HC-05 command capture, physical hardware and integration, and real-device
accessibility. No hardware commands, cloud writes, flashing, powered tests,
commits, merges, pushes or deployments were performed.

**Recommended next task:** OCT26:K-03B-01 / OCT26:K-03B-02 and the remaining
species-profile approvals, followed by K-03B-07/08 consistency work using the
actual approved content. Do not repeat the completed UI disclosure implementation
or treat its passing tests as permission to Start incubation.
