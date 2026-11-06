# ORIGINAL:K-06 — Confirmed-Start elapsed day

- Owner: Kath
- Date: October 29, 2026
- Status: PARTIAL overall. Local counter, display gating and regression tests
  pass; Cha/Mary's verified original-Start/time adapter is still required.
- Branch: `feature/kath-k03a-species-details`
- HEAD: `c7a26cfcaa619708aff4f793e8068ee176a6cf58`, plus uncommitted working
  changes. HEAD alone does not contain the tested UI implementation.

## Inspected source / precise dependency

Git status, branch and HEAD were checked before edits. Existing modified and
untracked user work was preserved. No AGENTS.md was found in the workspace.

`SupabaseService.createSession()` writes the caller's `startDate` into
`incubator_sessions.start_date` alongside cloud `Active`. This is not evidence
of confirmed original physical Start. `BatchData.fromSession()` also truncates
that date to ten characters for legacy presentation, losing the instant. The
old active progress widgets used these saved dates or a phone-now fallback,
clamped days to the species duration, and could imply completion from time.
No approved same-revision verified Start field/mapping was supplied for K-06.
The new code deliberately does not promote these values to confirmation.

## What actually changed / files modified

- `lib/models/confirmed_incubation_time.dart`: pure, immutable presentation
  snapshot from explicitly supplied confirmed original Start and trustworthy
  current UTC instants. Day N is `elapsed.inSeconds ~/ 86400 + 1` for nonnegative
  elapsed time; no species cap, calendar-midnight rollover, or auto-completion.
  Missing/unconfirmed/ambiguous local Start produces no day and
  `Waiting for confirmed start`. Missing/untrusted current time or a future Start
  produces no day and `Waiting for trustworthy elapsed time`, not Day 1.
- Modern project dates display as Asia/Manila UTC+08:00, using explicit UTC input
  and display-only conversion independent of the device's local timezone. This
  helper is not a general historical Philippine timezone database. It never
  feeds Manila calendar dates back into the elapsed calculation.
- `lib/widgets/confirmed_start_progress.dart`: read-only Day N / confirmed Start
  display. No implicit phone clock, receipt-time fallback, Start command, writes,
  timers or control actions. The future approved adapter owns refreshing and
  invalidating snapshots; this does not claim a running real-device clock.
- `lib/main.dart`: active screen accepts an optional typed confirmed-time input.
  Existing production entry points have no approved mapping and therefore show
  waiting. Home active progress, active batch details and the console's saved-real-
  batch band likewise wait instead of treating a legacy date as physical Start.
  Active screen's Start display is confirmed Manila time only; hatch estimates
  wait for confirmed Start and approved profiles. Removed date-derived On track /
  Completed / hatching-day assertions from the active screen. Physical state is
  explicitly unverified. Connected/non-simulation LCD preview no longer borrows
  the simulator's day/stage; labeled local simulation retains its existing logic.
- `test/confirmed_incubation_time_test.dart`: 16 new unit/widget tests.
- Updated affected legacy expectations only in:
  - `test/active_batch_finish_test.dart`
  - `test/home_current_incubation_card_test.dart`
  - `test/batch_details_cards_test.dart`
  - `test/hardware_console_sim_test.dart`
- This evidence document.

Navigation, species artwork, saved metadata, completed historical records,
manual hatch counts and existing Finish persistence behavior were preserved.
Completed legacy history calculations remain legacy reporting, not confirmed
Start evidence. The existing simulator's Day-7/profile assumptions were not
rewritten or approved; its tests passing do not approve physical fresh-egg scope.
No numerical profiles, backend schema, wire fields or controller timing behavior
were invented or modified. K-03/K-04/K-05 work remains intact.

## Tests performed / actual results

SDK binary directory: `C:\flutter\flutter\bin\`.

```powershell
flutter.bat test --no-pub test/confirmed_incubation_time_test.dart test/active_batch_finish_test.dart test/home_current_incubation_card_test.dart test/batch_details_cards_test.dart test/hardware_console_sim_test.dart --reporter expanded
flutter.bat test --no-pub --reporter expanded
flutter.bat analyze --no-pub
dart.bat format --output=none --set-exit-if-changed lib/models/confirmed_incubation_time.dart lib/widgets/confirmed_start_progress.dart test/confirmed_incubation_time_test.dart
git diff --check
```

- Targeted first and final runs: `+42: All tests passed!`, exit 0.
- Full suite, including final code: `+260: All tests passed!`, exit 0.
- Final analyzer: `No issues found!`, exit 0.
- Final format check: `Formatted 3 files (0 changed)`, exit 0.
- Tracked whitespace check: exit 0; existing LF/CRLF conversion warnings.
  Git's check does not cover untracked additions, which were compiled/tested and
  checked with the formatter separately.

### Boundary evidence (synthetic UTC instants, not hardware captures)

| Elapsed | Result |
| --- | --- |
| 0h | Day 1 |
| 23h59m | Day 1 |
| 24h minus 1 microsecond | Day 1 |
| 24h | Day 2 |
| 24h plus 1 microsecond | Day 2 |
| 48h | Day 3 |
| 40 days | Day 41, no automatic Completed |
| Manila 23:59 to 00:01, two elapsed minutes | Day 1 |
| UTC 23:59 to 00:01, two elapsed minutes | Day 1 |

Other tests cover absent Start, absent trusted current time, future Start,
rejected local DateTime inputs, explicit offset normalization, unchanged original
Start across later snapshots, waiting widget without a progress percentage, and
Manila display across boundary updates. Existing Finish/navigation/responsive
regressions passed with mock/in-memory services.

## Errors

No test/analyzer failures observed. An initial formatting-only check returned
exit 1 for a multiline helper signature; patched and final check passed.

## Remaining blockers / what still needs verification

Cha/Mary must supply the exact selected-revision verified original-Start field
and its provenance/confirmation rules, timezone encoding, source/session binding,
and a trustworthy elapsed/current-time source with clock-correction, offline and
recovery policy. UTC syntax alone does not establish trust; callers must use the
new API only after that evidence is substantiated. No real backend adapter is
claimed implemented. Home/real-band/active-details remain safely waiting until
that integration is supplied. The optional Active screen snapshot is an interface,
not proof of live clock refresh, expiry handling or persisted recovery.

Real authorized Android/HC-05 SPP, RTC, firmware source identity, phone clock
changes, reconnect, restart, isolated Supabase and end-to-end verification remain
separate. Never substitute cloud receipt/reconnect/ACK/Active time or automatically
replay an uncertain Start. Elapsed time does not verify physical Running/Stop,
turning or target application. Physical safety clearance remains required.

Architecture remains autonomous Uno + RTC + sensors/actuators via HC-05 Classic
SPP to Flutter Android and authorized Supabase through phone internet; USB is
diagnostic only. Intended software supports Chicken/Duck/Quail; physical pilot
remains Chicken-only using fresh fertile eggs after approval. No hatch outcome or
completed-cycle hatchability by November 3/4 is claimed.

No commit, merge, push, deployment, production writes/migration, deletion,
flashing, powered loads or egg tests occurred.

## Recommended next task

CURRENT:UI-IMP-01 / OCT26:K-07: obtain Cha/Mary's verified Start/time mapping,
implement its adapter and clock refresh/invalidation/recovery integration, then
perform authorized device checks. Related-task coverage is not completion.
