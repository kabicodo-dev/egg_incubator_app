# INT-IMP-01 — Integration evidence ledger, message-family matrix and runbook

**Task ID:** CURRENT:INT-IMP-01 · **Display:** INT-IMP-01 · **Source:** CURRENT
**Owner:** Mary Charlyn (Mary / Cha) · **Updated:** 2026-10-29
**Status:** evidence update complete; actual integration acceptance blocked.
**Shared kit:** `INT-IMP-01.mock.1` (unchanged review fixtures).

This is the single dated integration ledger. Current status is below; earlier
execution/handoff notes remain as historical records in this file. No local
implementation rebuild or architecture review was performed in this update.

**Current ownership clarification:** Mary and Cha are the same person, **Mary
Charlyn**, owning backend and integration. Earlier role-separated handoff rows
below describe historical workstreams, not separate people or approval authority.
The original mock-run ledger is retained. The current implementation continuation
and updated multi-species objective coverage are recorded at the end of this file.

## Current ledger — 2026-10-29 evidence-only update

**Subsequent DB-IMP-01 continuation, 2026-10-29:**
[DB-IMP-01 report](DB-IMP-01_Report.md) records a new disabled-registry SQL draft
(not applied), one additional fixture file and six extra closed-gate tests.
[New full TAP log](logs/2026-10-29-db-imp-01-node.tap): **70/70 Node tests passed**
(the original 64 plus six). This is separate new execution; the supplied 20 parser
checks were not rerun. Earlier evidence-only-update statements below describe
INT-IMP-01, not this subsequent DB task. No actual SQL/RPC/security pass is added.
Original shared fixtures/production source remain unchanged; ingestion stays closed.

Evidence sources:
- [S1: supplied verification excerpts](logs/2026-10-29-supplied-checks.md): preceding
  implementation transcript/report, **not rerun now**. Transcribed excerpts, not
  original complete machine logs; no standalone original logs found in checkout.
- [S2: new repository/owner-patch inspection](logs/2026-10-29-repository-inspection.md).
- [Integration runbook](../../supabase/functions/bridge-sync/README.md): separate
  fake-transport and stubbed-HTTP dry-run instructions.

| Slice | Status | Evidence / precise limitation | Accountable owner |
|---|---|---|---|
| 33 original mocks + 31 HTTP/core/monitoring tests | PASS (supplied software only) | [S1-node](logs/2026-10-29-supplied-checks.md#s1-node--supplied-combined-run): 64 passed, zero fail/skip/cancel | Mary Charlyn |
| Targeted current-parser tests | PASS (supplied characterization only) | [S1-parser](logs/2026-10-29-supplied-checks.md#s1-parser--supplied-targeted-parser-run): 20 passed; incompatibilities below remain | Mary Charlyn (evidence); decoder fixes Kath |
| Four JavaScript syntax checks; selected tracked whitespace check | PASS (supplied limited checks) | [S1-static](logs/2026-10-29-supplied-checks.md#s1-static--supplied-checks-not-new-runs); not Deno/full Flutter/untracked-file coverage | Mary Charlyn |
| Documentation whitespace and reference verification | PASS (new documentation check only) | [S2-doc-check](logs/2026-10-29-repository-inspection.md#s2-doc-check--new-documentation-verification); all four updated/added Markdown files | Mary Charlyn |
| Fake transport + FakeCloud software dry run | PASS (supplied mock layer only) | [S1-node](logs/2026-10-29-supplied-checks.md#s1-node--supplied-combined-run), INT-03–07 logical calls/offline/retry/receipts; no selected wire/device | Mary Charlyn |
| Active sketch/catalog/implementing commit-path; actual source validator | NOT TESTED | Exact producer set not supplied; observed branches are not selection. Source ingestion remains DISABLED/default closed | Ally supplies producer; Mary Charlyn implements validator afterward |
| Isolated RPC/Auth/RLS/signature/transactions/concurrency/persistence | NOT TESTED | Three required RPCs unimplemented; authorized running isolated instance absent. Docker unavailable/test project INACTIVE are supplied observations, not rechecked remotely | Mary Charlyn |
| Android selected-schema decoder/SPP permissions/pairing/lifecycle/transactional storage | NOT TESTED | No compatible implementing patch/device logs supplied; current parser gaps below | Kath |
| Real notification delivery/background operation | NOT TESTED | Condition data helper only, no delivery service evidence | Mary Charlyn |
| Original Start/RTC-based Day N; physical regulation/turning/lockdown/end-to-end | NOT TESTED | Need substantiated source time and safety-cleared device evidence; ACK/cloud Active/receipt time do not establish operation | Ally (controller); Kath (Android presentation) |

Source context: `cha-branch2`, HEAD `c7a26cfcaa619708aff4f793e8068ee176a6cf58`,
origin `https://github.com/kabicodo-dev/egg_incubator_app.git`. Backend/kit additions
remain uncommitted/untracked; HEAD is not their implementing revision.
[S2](logs/2026-10-29-repository-inspection.md) records owner patch observations,
stale cached branch distinctions and preserved user changes. No branches merged,
switched, fetched or reset. No code/config/fixtures changed in this update.

### Message-family matrix — separate reference generations

PASS is scoped to the stated software assertion and linked supplied log. FAIL is
an observed interoperability gap against an **unselected review reference**, not
a failing test or finding against a selected active producer. Each FAIL has one
fix owner. Actual producer/device/database acceptance stays NOT TESTED.

| Family / exact reference | Software assertion | Interoperability / actual acceptance | Log / fix owner |
|---|---|---|---|
| Compact `t`: HELLO query/reply, batch fixture lines 1–2 | PASS: framing/pinning | FAIL: reply returns Unknown in current parser; outbound query/active producer NOT TESTED | [S1-node/parser](logs/2026-10-29-supplied-checks.md); Kath |
| Compact START / STOP, lines 3–4 | PASS: byte preservation; logical Start/Stop mocks are separate | NOT TESTED: outbound encoding/controller admission/physical commands; incoming-parser Unknown does not establish an outbound defect | [S1-node/parser](logs/2026-10-29-supplied-checks.md); Kath (encoder), Ally (producer) |
| Compact STATUS / STATE, lines 5,8 | PASS: logical read-only/current-state assertions | FAIL: STATE reply unsupported; outbound STATUS query and actual source state NOT TESTED | [S1-node/parser](logs/2026-10-29-supplied-checks.md); Kath |
| Compact ACK / ERROR, lines 6–7,11 | PASS: mock ACK-only remains unknown | FAIL: compact messages unsupported; ACK never proves Running | [S1-node/parser](logs/2026-10-29-supplied-checks.md); Kath |
| Compact EVENT / TEL, lines 9–10 | PASS: byte preservation/mock immutable facts | FAIL: compact messages unsupported; real source attribution NOT TESTED | [S1-node/parser](logs/2026-10-29-supplied-checks.md); Kath |
| Compact REPLAY / REPLAY_END / RCPT_ACK, lines 12–14 | PASS: logical retained-outcome/receipt/revision scenarios | FAIL: REPLAY_END reply unsupported; outbound REPLAY/RCPT_ACK and durable producer replay/release NOT TESTED (`retention_ack` null) | [S1-node/parser](logs/2026-10-29-supplied-checks.md); Kath |
| Corrected `type:command`, corrected fixture line 1 | PASS: framing/size only | NOT TESTED: encoder/controller admission; not batch Start contract | [S1-node](logs/2026-10-29-supplied-checks.md#s1-node--supplied-combined-run); Ally |
| Corrected `type:telemetry` / `sensors`, line 2 | PASS: characterization detects missing incubator values | FAIL: actual parser returns null incubator values/sensor error; physical readings NOT TESTED | [S1-parser](logs/2026-10-29-supplied-checks.md#s1-parser--supplied-targeted-parser-run); Kath |
| Corrected `type:ack` / `status`, line 3 | PASS: characterization reads unsuccessful ACK without `success` | FAIL: envelope lacks supported success semantics; physical state NOT TESTED | [S1-parser](logs/2026-10-29-supplied-checks.md#s1-parser--supplied-targeted-parser-run); Kath |
| Corrected hello / hello_ack / event SENSOR_INVALID, lines 4–6 | PASS: characterization records Unknown | FAIL: actual parser has no decoder for these families | [S1-parser](logs/2026-10-29-supplied-checks.md#s1-parser--supplied-targeted-parser-run); Kath |
| DB-02 candidate submit_event | PASS: seven request-shape corpus, strict negatives, hash and scoped HTTP receipts with stubs | NOT TESTED: actual source, database RPC, Auth/RLS or cloud persistence | [S1-node](logs/2026-10-29-supplied-checks.md#s1-node--supplied-combined-run); Mary Charlyn |
| DB-02 submit_reading | PASS: source values/fingerprint, independent metric validity/age, no target substitution | NOT TESTED: real sensor source/clock/RPC persistence | [S1-node](logs/2026-10-29-supplied-checks.md#s1-node--supplied-combined-run); Mary Charlyn |
| DB-02 reconciliation / receipts | PASS: socket loss, duplicates/conflicts/waiting/scope/hash/revision with stub storage | NOT TESTED: database atomicity/concurrency, cloud receipts or Uno release | [S1-node](logs/2026-10-29-supplied-checks.md#s1-node--supplied-combined-run); Mary Charlyn |
| Observed Combined turning / lockdown / sensor diagnostics | PASS: helpers retain lockdown alongside error; never sync-eligible or Start proof | NOT TESTED: active source attribution/physical actuation | [S1-node](logs/2026-10-29-supplied-checks.md#s1-node--supplied-combined-run); Ally |

Unchanged shared files:
- [Manifest/observed hashes](../../test/fixtures/integration/int_imp_01_sources.json).
- [Earlier compact reference](../../test/fixtures/integration/hw02_batch_review.ndjson).
- [Corrected six literals](../../test/fixtures/integration/hw02_corrected_review.ndjson).
- [Pinned DB-02 requests/responses](../contract-review/DB-02_Exact_Bridge_Sync_API.md),
  consumed by the [read-only exporter](../../test/integration/export_int_imp_01_fixtures.cjs).

Never merge these generations into a presumed selected decoder. Same-revision
producer/catalog/consumer acceptance stays NOT TESTED until the exact set arrives.

### Related OCT26 tasks — coverage is not completion

Related: OCT26:TEST-01, OCT26:TEST-02, OCT26:TEST-03, OCT26:TEST-04,
OCT26:TEST-05, OCT26:TEST-06, OCT26:TEST-07, OCT26:TEST-08,
OCT26:TEST-09, OCT26:TEST-10, OCT26:TEST-11.
**Each is NOT TESTED at its own task-acceptance level in this ledger**: exact
criteria, owner mapping and task-specific acceptance logs were not supplied/found.
INT-01–08 below are kit scenario IDs, not a mapping onto these eleven OCT26 tasks.
Mary Charlyn coordinates attachment of actual owner logs. No completion inferred
from “COVERED BY” or passing local scenarios.

### Errors, remaining gates and scope

No tests rerun or new test failures observed during this evidence update. Supplied
final run has zero failing tests. Historical wrong-scope fixture/socket failures
belong to Mary Charlyn and are reported resolved; original failure logs unavailable.
Current interoperability FAIL rows have one fix owner, **Kath**, pending Ally's
exact producer set. Passing characterizations do not turn those gaps into PASS.

Next: Ally supplies exact active `.ino`, matching catalog, implementing commit and
paths (or exact files); Mary Charlyn pins these and implements/tests the validator.
Independently, Mary Charlyn needs an approved running isolated database for actual
RPC/security/transaction implementation/tests. Kath supplies the compatible Android
decoder/transport/storage patch and logs. Before separately authorized physical
tests, rerun the fake-transport/test-backend dry run, then compatible selected-schema
software integration. Physical acceptance needs explicit authorization and qualified
documented safety clearance; this evidence provides neither.

K06 v0.5 remains autonomous Uno + RTC + sensors/actuators ↔ HC-05 Classic SPP ↔
Flutter Android ↔ authorized Supabase through phone internet. USB is diagnostic;
ESP8266 historical. Incubator-only, fresh eggs, manual hatch counts; three-species
software intent, Chicken-only physical pilot. No numerical targets or completed
hatch by November 3/4 asserted. Day N is
`floor(trustworthy elapsed_seconds / 86400) + 1` from a substantiated original Start;
phone/cloud receipt time cannot replace unknown original time. No automatic
uncertain Start replay. No deployment, hardware activation or production write
authorized. App data/images/navigation/History and local implementation preserved.

---

## Historical kit record — 2026-10-28

Commands/results and role labels below are provenance. Current scope, ownership,
log attribution and acceptance status are above. Original mock-only “no backend
implementation” statements do not describe the later local code continuation.

## Run now from the repository root

No new dependencies or npm/pub install are required for the Node tests.

```powershell
node --test test/integration/int_imp_01.test.cjs
```

Portable JSON export for firmware host tests, Flutter and backend fixture consumers
(stdout only; nothing uploaded or sent to serial/Bluetooth):

```powershell
node test/integration/export_int_imp_01_fixtures.cjs
```

The export contains raw ASCII review frames plus the exact request/response
examples read from Mary's pinned DB-02 document. It is explicitly SYNTHETIC /
MOCK USE ONLY. Original uint64 digits and number spellings remain in raw strings;
do not decode/re-encode them through a lossy Number. Source MAC/deviceToken/profile
examples are nonfunctional placeholders, never credentials/approved settings.
Do not replace them with real secrets, captures or production records in Git.

Actual SDK discovered from `.dart_tool/package_config.json`: Flutter 3.47.2,
Dart 3.13.2, `C:\EggIncubator\flutter`. It is available even though flutter/dart
were absent from this shell's PATH. Targeted real-parser checks:

```powershell
& "C:\EggIncubator\flutter\bin\flutter.bat" test --no-pub "test/int_imp_01_parser_compatibility_test.dart" "test/arduino_protocol_test.dart"
```

Use your own existing SDK path on another machine. No SDK upgrade, pubspec,
lockfile, CI workflow or project configuration was changed. Node tested here:
26.4.0. Node tests use only built-in modules.

## Exact source observation, not selection

- Remote: `https://github.com/kabicodo-dev/egg_incubator_app.git`.
- Current branch: `cha-branch2`; HEAD:
  `c7a26cfcaa619708aff4f793e8068ee176a6cf58`.
- Read-only `git ls-remote origin refs/heads/ally-branch3` returned:
  `d97d6af68118a175d99b1f61747c52b082bc15ec`.
- Observed sketches and SHA-256:
  - `arduino/SmartHatch_Uno/SmartHatch_Uno.ino`:
    `0365b18bc969d36547440b5e4299b946da03fa5aeccdbff0fff8dc8efeef01fc`.
  - `arduino/SmartHatch_Combined/SmartHatch_Combined.ino`:
    `a466a868e6c148cf4f9c3230378d5033d81db89dfb77a3e0fa53891d847a9598`.
- Neither is confirmed to be Ally's active implementation or flashed image.
  `active_implementation` in the manifest is explicitly null/BLOCKED. The observed
  remote head is not permission to select a catalog or reinterpret its messages.

**Only source request to Ally:** supply the exact currently implemented `.ino`
and matching selected catalog file, or the commit containing them with paths.
No D01–D06 question round is requested. Once supplied, pin the source/revision,
add an owner-approved adapter/fixture revision and run the same matrix.

K06 v0.5 architecture directions from the user's instruction are the established
baseline: HC-05 Classic/Android bridge, Uno autonomy, offline Start, Chicken-first
fresh eggs, manual count. No local v0.5 file was located; this kit does not invent
a hash or unseen clauses and does not reopen those architecture choices.

## Fixture provenance and compatibility boundaries

Manifest: `test/fixtures/integration/int_imp_01_sources.json`.

| Reference | Source / exact SHA-256 | Use |
|---|---|---|
| Earlier batch-aware HW-02 | `HW-02_Exact_Wire_Message_Catalog.md` / `b43da3e1a42d3a2a2a0c5b5455d4dfa713b4d36ac409ae08a5925bd9acd5327d` | 14 exact literals in `hw02_batch_review.ndjson`; unselected and synthetically invalid in known ways |
| Corrected script's six literals | `HW-02_count_frames.py` / `b2bc944b46bb1535c7a181c8984a3b6cc99a28fb56df9beca9f9924e831fcb0b` | Six exact serialized literals in `hw02_corrected_review.ndjson`; not a batch lifecycle contract |
| Mary's DB-02 candidate | `docs/contract-review/DB-02_Exact_Bridge_Sync_API.md` / `5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab` | Read existing complete request/response JSON blocks; no change to her implementation or documents |

The loader checks the DB source hash before extracting examples. The manifest
also records LF-normalized text hashes so Windows CRLF versus Linux LF checkout
does not masquerade as protocol drift; only newline equivalence is accepted, not
changed content. Raw observed hashes remain provenance. NDJSON checkout delimiters
are normalized to the explicit LF wire convention before framing/export.
If Mary changes her candidate, review/revise the fixture-kit version; never
silently disable hash checking. Wire reference files are separate generations,
not one merged decoder.
No final wire fields are invented to fill absent Start/state/event/authentication.

Mock transport only frames bytes; it does not claim a protocol is approved.
`FakeController` uses **logical in-process calls**, not a new serialized Start/
Stop schema. It returns canned source records and a separate current mock status.
`FakeCloud` accepts recorded candidate examples and models key/content/receipt/
dependency outcomes; it is not Mary's API, JCS implementation, SQL transaction,
JWT/RLS enforcement or scheduler. Its authorization Boolean is a fake decision,
not a security proof. Known source-invalid aliases and oversized frames remain
visible in the shared corpus, not relabeled as genuine accepted evidence.

The host file-backed JSON checkpoint tests reopen and failed-commit boundaries
in a temporary directory. It is **not Android SQLite**, fsync/power-cut proof,
EEPROM, uninstall-safe retention or an implementation of Kath's local store.
Each run creates/cleans only its own `opencode/int-imp-01-*` temporary directory.
No production transport/backend implementation is imported by the Node harness.
The Dart characterization file imports the actual current Flutter protocol parser.

## Integration test matrix

`MOCK PASS` means only the runnable double/fixture scenario passed. Real link/API/
storage tests remain NOT TESTED/BLOCKED where an owner dependency is listed.
All supplied INT-01–08 mock PASS assertions below link to
[S1-node](logs/2026-10-29-supplied-checks.md#s1-node--supplied-combined-run);
actual-parser characterization PASS links to
[S1-parser](logs/2026-10-29-supplied-checks.md#s1-parser--supplied-targeted-parser-run).
Older one-off analysis/format/version statements in the historical execution
ledger lack standalone retained logs and are not new current acceptance PASSes.

| ID | Capability / executable assertions | Evidence scope | Real integration dependency / owner |
|---|---|---|---|
| INT-01 | Connect/disconnect; every split boundary for 20 frames; coalesced/one-byte input; exact test bounds, discard overflow suffix through LF; invalid byte rejection | MOCK PASS: host framer/link | Kath actual RFCOMM/permission/lifecycle; Ally identified HC-05/baud and actual RX/TX implementation |
| INT-02 | Fresh read-only logical status requests neither actuate nor create outbox events | MOCK PASS: controller callbacks, no wire query invented | Ally exact active read-only query/response; Kath actual matching parser |
| INT-03 | Explicit logical Start/Stop, ACK-only unknown, Stop separate from cloud Active/manual zero-count completion | MOCK PASS: controller + host ledger + canned cloud | Ally actual admitted/occurred/current-state and safe outputs; Kath decoder; Mary receipt projection |
| INT-04 | Lost ACK/outcome, reconnect/app reopen, retained original mock event, current Stop beats historical Start, wrong-source binding rejected | MOCK PASS: retention/current observation + checkpoint | Ally bounded persistent retained outcomes and source identity; Kath actual reconnect/SQLite |
| INT-05 | Duplicate same command/event, changed-content rejection, wrong-batch Stop and second-batch Start do not replace state | MOCK PASS: content-aware controller/ledger | Ally persistent dedup across boot; Mary source identity and real atomicity |
| INT-06 | Failed T1 prevents dispatch; event-save failure differs from known Running report; offline outbox survives healthy-host reopen | MOCK PASS: file store, not power-loss/SQLite | Kath real transactions/crash/storage budgets; Ally source evidence survives missing local commit |
| INT-07 | Duplicate prevention, completed batch not reopened, lost cloud reply/reconciliation, waiting dependency/conflict, fake auth denial, receipt hash/revision/no-release checks | MOCK PASS: fake cloud/client/ledger, no HTTP/DB | Mary isolated real adapter/Auth/RLS/transactions and dependencies; Kath receipt/outbox code |
| INT-08 | Source hashes/corpus sizes/export pinned; selected source remains null; real Flutter parser rejects/misreads current review envelopes as characterized | PASS: fixtures and actual parser characterizations; compatibility remains blocked | Ally active source/catalog; Kath approved decoder; Mary matching source adapter |

## Actual execution ledger — 2026-10-28

| Command/check actually run | Result |
|---|---|
| `flutter.bat --version` at discovered SDK | Flutter3.47.2 / Dart3.13.2 confirmed; no upgrade |
| Initial `node --test test/integration/int_imp_01.test.cjs` | 30 passed, 0 failed before two extra recovery assertions were added |
| Targeted Flutter command above | **20 passed**, 0 failed: five new current-parser characterization tests plus 15 existing protocol tests |
| Final `node --test test/integration/int_imp_01.test.cjs` after recovery/checkout-portability additions | **33 passed, 0 failed, 0 skipped**; exporter also exercised as a subprocess |
| `flutter.bat analyze --no-pub test/int_imp_01_parser_compatibility_test.dart` | **No issues found** (new characterization file only) |
| Dart format `--output=none --set-exit-if-changed` on new characterization file | **0 files changed** on final check; initial formatting differences corrected via patch |

Source/fixture pinning preserves raw observation hashes while accepting recorded
LF/CRLF text equivalence for cross-platform checkouts. A deliberate content drift
mutation is rejected. The framer's limits remain host-test parameters, never an
approved Uno buffer or Bluetooth maximum. The test kit's storage, retained mock
controller memory and canned receipts do not establish the same capabilities in
the real components.

Final scope/whitespace check: only the eight kit/test/evidence files are newly
added beyond the initial Git snapshot. Git whitespace checks found no errors;
existing LF-to-CRLF warnings were left alone. Existing environment/workflow/docs
changes and Mary's DB files were preserved. No branch change/reset/merge/fetch,
staging/commit/push, worktree cleanup, backend implementation or production edits.

No full application suite, release build, remote CI, Bluetooth/Arduino operation,
physical Start/Stop, EEPROM/RTC test, database or Auth/RLS/concurrency test is
claimed. Passing unsupported-parser characterizations confirms a gap; it does
not turn unsupported messages into working integration.

## Specific handoff — coding dependencies, not another decision round

| Owner | Ready now | Specific dependency still needed |
|---|---|---|
| Kath | Run actual-parser characterizations; consume raw byte fixtures/export; use failure/reconnect/outbox assertions with fake transport | Implement approved current-catalog decoder, real Android transport and SQLite; do not wire review bytes into live Start. Supply her implementing patch/commit for adapter tests. |
| Ally | Consume pinned raw frames for host parser/count tests and use duplicate/lost-outcome cases | Send exact active `.ino` + catalog or commit; update producer against that version, not generic source branch assumption. Build/memory/retention/time/auth feasibility is hers to demonstrate. |
| Mary | Export exact current candidate DB requests/responses unchanged; port duplicate/waiting/conflict/receipt cases into her isolated endpoint tests | Actual backend patch/test environment and approved source adapter. FakeCloud proves none of her server enforcement. No production migration or alternate backend added here. |
| Cha | Run this kit, keep provenance/active-source distinction, collect owner patches and actual logs | Pin active source once supplied, attach each real producer/consumer/adapter result to the matrix, coordinate mock dry run before separately authorized device tests. |

No journal release artifact is supplied: `retention_ack` remains null in fixtures.
No auto Start replay during reconnect/cloud retry. Phone-away/connection loss
does not claim Stop; historical events do not claim current operation. Readings
in fixture files are synthetic inputs, not measurements or approved targets.

## Portal corrections for Claude — inspect only, no portal edits made

Observed downloaded copies; Claude must identify the actual portal deployment
source before editing it. Preserve layout, existing report/evidence storage and
historical v0.3 material; current status must not fabricate approvals or passes.

| Concrete reference | Correction needed |
|---|---|
| `Downloads/index.html:154,159,165-177,253,256`; `index-3.html:136,141,147-159,212,215` | Current architecture/banner/data-flow must use K06 v0.5 established HC-05/Android bridge; ESP8266/v0.3 retained as historical, not current instruction. |
| `index.html:163,267-276,302-308,336`; `index-3.html:145,226-235,261-267,295` | Mary owns backend/API/security; Cha coordinates integration. Replace old C-03 ESP8266 publisher task and incorrect role labels without inventing backend completion. |
| `index.html:177`; `index-3.html:159`; both CHA-03 entries | Replace cloud-save-before-Start flow with local intent -> Uno confirmation -> durable local event/outbox -> authorized later sync. ACK/cloud Active are not physical Running. |
| `index.html:247`; `index-3.html:206`; C-01/C-02 task entries | Retire obsolete ESP8266 interface/missing-full-UI questions. Actual-schema inventory and full compatibility reviews exist; source selection, identity/auth, real adapter, retained recovery, RTC/profile/electrical evidence remain specific unresolved implementation dependencies. |
| `index.html:188,208,300-307,315`; `index-3.html:170,190,259-266,274` | Link the actual fixture kit/run command/results and current implementation tickets; distinguish MOCK PASS, parser characterization, NOT TESTED and physical verification. Do not repeat completed general audits. |

Source selection is not permission to send hardware commands. Keep safety and
source-authentication limitations explicit and reflect only attributable test logs.

## Supplied implementation continuation — local first, 2026-10-29

User authorized reuse of the existing eight kit files rather than ZIP extraction;
no INT-IMP ZIP was located/claimed compared. Original Node and Flutter commands
were rerun in the earlier implementation task: **33 Node mock tests passed; 20 targeted Flutter tests
passed**. Existing kit/production sources were preserved, not replaced blindly.

Added real backend source under `supabase/functions/_shared/` plus candidate
`bridge-sync/index.ts` and the actual loopback server
`supabase/dev/serve-bridge-sync.mjs`. See the concise implementation runbook:
`supabase/functions/bridge-sync/README.md`. No main-project or cloud data was used.

Smallest compatible slice is implemented:

| Existing component | Exact mismatch / integration decision |
|---|---|
| Local Combined sketch `:14-28,82-87,358-375,392-436` | Numeric id/cmd, lowercase egg_type/stage, incubator temperature_c/humidity_percent/valid, one-shot egg_turn_completed; no selected durable batch/sample/event source contract or verified RTC. Not inferred to be active/flashed. |
| Flutter protocol `:147-175,191-211,265-275,330-354` | String id/actuator/state and success ACK; compact t messages unsupported, corrected sensors envelope unpopulated. Kath needs actual chosen producer schemas, not automatic legacy translation. |
| DB-02 candidate | Full source identities, original time validity, exact receipts and canonical core. New handler validates these; it does not invent missing firmware fields. |

Implemented real code: strict HTTP/JSON/candidate payload validation, species
identity mapping, canonical SHA-256 and receipt/scope checks, actual Supabase
Auth/RPC fetch ports, default closed source gate and error sanitization. No
production route/deployment, selected wire decoder or PostgreSQL ingestion/RLS
implementation exists merely because those ports are coded.

Updated objectives now have software tests for **Chicken, Duck and Quail** profile
identity/propagation (not numerical target approval), independent temperature and
humidity validity/age, egg-turn diagnostics, lockdown reports including simultaneous
sensor error, stable error-condition notification data, offline replay and stale
remote receipt handling. Notification delivery/background service, source event
attribution and physical regulation/turning/lockdown remain unverified. Old kit's
Chicken-first label is historical reference, not a new limitation on software
identity support or approval of Duck/Quail physical behavior.

Supplied final continuation checks (2026-10-29), not rerun in this evidence update;
see [S1 excerpts and attribution](logs/2026-10-29-supplied-checks.md):

```powershell
node --test --test-timeout=15000 "test/integration/int_imp_01.test.cjs" "test/backend/bridge_sync_http_test.mjs" "test/backend/bridge_monitoring_test.mjs"
$env:CI='true'; & "C:\EggIncubator\flutter\bin\flutter.bat" test --no-pub "test/int_imp_01_parser_compatibility_test.dart" "test/arduino_protocol_test.dart"
```

- **64/64 Node tests passed**, zero failures/skips/cancellations: 33 original mock
  tests plus 31 backend HTTP/core/monitoring tests.
- **20/20 targeted Flutter tests passed**, using the existing production parser.
- `node --check` passed for `bridge-sync-core.mjs`, `bridge-sync-supabase.mjs`,
  `bridge-monitoring.mjs` and `supabase/dev/serve-bridge-sync.mjs`.
- `git diff --check` returned success for tracked changes; Git emitted an existing
  deploy workflow LF/CRLF normalization warning. Untracked additions are not covered
  by that Git command. No staging/commit/push occurred.
- Deno entrypoint was source-reviewed, not runtime/type-checked; Deno is unavailable.

Auth/RPC storage in new HTTP tests is stubbed: actual Supabase signatures, RLS,
database concurrency/transactions and persisted cloud receipts are NOT TESTED.
Local Docker API is unavailable; hosted `smarthatch-test` is INACTIVE. User chose
code locally first; neither environment was resumed or modified.

Actual source request remains ONLY Ally's active sketch, matching catalog and
implementing commit/paths. Supabase source adapters stay closed until available.
Mary Charlyn/Cha next needs the running isolated database for actual RPC/Auth/RLS
implementation and tests; Kath can consume the handler/fixture interfaces now.
No live Start/Stop, firmware flash, powered test or production deployment occurred.
