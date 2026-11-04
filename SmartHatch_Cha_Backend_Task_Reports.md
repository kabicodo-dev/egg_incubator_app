# Completed-task reports embedded in HTML

Open Reports → Completed-task reports — embedded. Full text is included in this HTML; no JSON import or backend is needed to read it. Seven full report/history records cover the three completed audit/review tasks. Four established design decisions retain original source-evidence records, not fabricated execution reports. Five supplied Ally reports labelled Completed are separately viewable with unverified/misfiled warnings; no other member status is changed.

Existing browser reports, statuses, history and import/export controls remain separate and unchanged. Identical saved records are not displayed twice; different/newer browser versions are preserved alongside the distinct published snapshot. The new embedded-export button exports known Cha publication records only, not a backup of saved browser data and not the flagged Ally records.

Original Downloads HTML is preserved. Use the complete SmartHatch_Cha_Backend_Updated.html copy. New archive implementation: completed-report-archive.cjs; index: completed-report-archive-manifest.json. See separate current test results for actual verification; previous browser results are historical.

# Latest independent schema verification and Ally review progress

136 total records: ORIGINAL 32, OCT26 92, CURRENT 7, NEW 5. Mary Charlyn owns 42 (ORIGINAL 9, OCT26 31, CURRENT 2, NEW 0). Published counts: 7 Completed, 9 Partial, 25 Not started, 1 Superseded. 34 noncompleted nonsuperseded source records remain. Completed scope includes four existing architecture decisions, the two C-01 audits, and the independent OCT26:C-03 architecture review with new 13/13 targeted and 83/83 regression results. None of these reviews certifies secure cloud or physical integration. Remaining implementation/team/hardware gates are preserved; queue parking is not bulk status editing.

# ORIGINAL:C-09 — stale readings/disconnection: independent boundary verification

**Owner:** Mary Charlyn (Cha/Mary) · **Date:** 2026-10-30 · **Priority:** P1.
**Status:** Partial → Partial; automated verification progressed, full criterion
not met. No C-02 choice, numerical freshness threshold or source schema selected.

## Why this can proceed while C-02 is parked

The source task requires Fresh/Stale/Unavailable/Unknown classification, with
measured cadence from Ally. Existing backend helper `remoteReadingStates` is
independently callable with explicit policy inputs; it uses no network, DB or
controller. We can test its existing behavior without declaring a particular
cadence, source UTC, wire format or UI policy approved. All 5000/1000/etc values
in these tests are arbitrary TEST inputs, not recommended operating thresholds.

The Superseded task is deliberately not executed. Kath's UI and Ally's firmware
are not changed. Scope is existing backend/helper unit verification, not live
readings or new control behavior.

## Actual changes and results

Added `test/backend/monitoring_boundary_test.mjs`, testing the actual unchanged
backend helpers, not a replacement mock classifier. Added a read-only helper
characterization script and retained its findings in monitoring-boundary-probes.json.

Commands actually executed:

```powershell
node --test --test-timeout=15000 --test-reporter=tap --test-reporter-destination=docs/integration/cha-execution/monitoring-boundary-targeted.tap test/backend/monitoring_boundary_test.mjs
node --test --test-timeout=15000 --test-reporter=tap --test-reporter-destination=docs/integration/cha-execution/monitoring-backend-regression.tap test/integration/int_imp_01.test.cjs test/backend/bridge_sync_http_test.mjs test/backend/bridge_monitoring_test.mjs test/backend/architecture_alignment_test.mjs test/backend/monitoring_boundary_test.mjs
node docs/integration/cha-execution/probe-monitoring-boundaries.cjs
```

- **Targeted: 27/27 passed**, zero failures/skips/cancellations.
- **Regression: 110/110 passed**, zero failures/skips/cancellations, INCLUDING
  those 27 tests. Not 137 distinct tests; historical 83-test run remains historical.
- Characterization probes executed, preserving production source hash
  `863447ee1c8a869cff380a7d55e99d6ce5ae207b9bf8237dc849efbdb0b434ec`.
  Probe observations are limitations, not additional accepted safety cases.

No production module, Flutter/Arduino source, Supabase draft/migration, deployment,
credential, database row, powered setup or old source contract was modified.

## What the tests demonstrate

| Boundary | Actual local evidence |
|---|---|
| Freshness exact threshold | At synthetic threshold remains fresh; one millisecond older becomes stale. No policy default invented |
| Missing/invalid policy | Omitted, nonfinite/coerced or negative relevant budgets produce unknown age, not live data |
| Independent metrics | Invalid temperature does not hide valid humidity, and vice versa |
| Unavailable vs unknown age | Invalid/missing/nonfinite values stay unavailable; otherwise valid metric with no trustworthy age stays unknown_age |
| No numerical coercion/default | Numeric strings/Booleans are not sensor numbers; missing values do not become zero or profile setpoints |
| Original acquisition time | Recent phone/server receipt or reconnect does not refresh an old acquisition |
| Source-clock validity | Unknown/invalid time gives no live value; future time beyond explicit synthetic skew stays unknown |
| Last-known distinction | Stale/unknown_age has null live_value; diagnostic last_value is separate and must not be displayed as live |
| State/connection separation | Cloud Active/relay/stage flags do not validate metrics; helper never claims Stop/Start/Completed/admission |
| Actual input guard | Existing validateSubmission rejects impossible source calendar date and missing batch association in real candidate fixture |
| Stable pure behavior | Repeat classification is stable; neither input nor policy mutated |

These are type/time/freshness unit results, not approved biological sensor ranges,
sensor calibration or authentication. A zero synthetic reading tests presence,
not safe incubation conditions.

## Explicit caller/composition limitations, not claimed fixed defects

1. The helper alone uses Date.parse; an impossible 2026-02-30 normalizes and can
   appear fresh. Existing submission validator strictly rejects that date, newly
   verified here. Every future caller must pass the strict input boundary; this
   work does not prove the full monitoring pipeline uses it correctly.
2. The helper itself accepts metrics without device/batch/sample identities.
   Existing submission validator rejects missing batch, but actual authorized
   source-to-batch selection still needs selected source/registry/mapping evidence.
   Do not choose latest Active or treat pure classification as source acceptance.
3. connected:false does not change per-metric age classification. That is not
   physical Stop. UI must compose a separate disconnected/unknown-current-state
   dimension and label last-known readings non-live as applicable. No real
   transport/widget behavior is proved by toggling a synthetic object field.

Source helper is currently a domain function, not a verified secure ingress,
source selector, firmware state machine or transport watcher. These observations
do not establish a production exploit or justify silently rewriting current code.

## What is still needed for full task completion

- Attributable measured acquisition/transmission cadence and delay information
  for the selected source; existing reported intervals are useful but not fresh
  measured transport evidence. Do not invent a threshold from our TEST constants.
- Exact accepted freshness/skew/unknown-clock/late-acquisition policy, including
  source continuity and reconnect behavior, with relevant Kath/Ally input.
- Approved source association/authorization and actual monitoring caller path.
- Actual connected/disconnected + metric-state composition acceptance tests in
  the compatible app/backend, not inferred physical state from a cloud receipt.

The software boundary test portion is performed. ORIGINAL:C-09 remains Partial.
OCT26:C-09 and related real-time/integration tasks are NOT completed by these tests.
All other task statuses remain unchanged: **7 Completed, 9 Partial, 25 Not started,
1 Superseded**; no new full task or physical/security readiness claimed.


# OCT26:C-02A — independent schema verification while reviews are pending

**Owner:** Mary Charlyn (Cha/Mary) · **Date:** 2026-10-30 · **Priority:** P0.
**Status:** Not started → Partial. Verification deliverable performed; exact
Ally schema/example review remains open. No new full task Completed.

## Actual independent work

Reused the already-installed approved-temporary Ajv 8.17.1 and ajv-formats 3.0.1
with Node v26.4.0. No dependencies installed and no Flutter lockfile/pubspec edits.
Reexecuted the unchanged `docs/validate-c02-provisional.cjs` against the exact
historical provisional schema/examples that Kath reviewed. Also performed
standards-validator checks of the exact already-shared manual-result proposal.

Retained evidence:
- `c02-schema-revalidation.txt`: schema meta-validation/compilation passed;
  **14 positive synthetic examples**, **65 schema-negative mutations**, and
  **11 malformed/unsafe frame fixtures** passed; CRLF/trailing-whitespace and
  two additional status/time combinations passed.
- `manual-result-jsonschema.tap`: **13/13 test groups passed**, zero failures;
  all seven published request/response example objects pass shape validation.
- `manual-result-reference-revalidation.tap`: **21/21 tests passed**, zero
  failures/skips/cancellations; these are the existing pure local reference tests,
  not a deployed API or transaction test.
- `independent-schema-verification.json`: exact schema/fixture/validator hashes,
  installed tool versions, results and limitations. All input hashes unchanged
  before/after; old review bytes were not silently replaced.

Reproduction:

```powershell
node docs/integration/cha-execution/verify-independent-schema-work.cjs
```

Runner reuses the known approved-temp tooling, writes UTF-8 local evidence logs,
and fails if validator execution fails or input bytes change. It does not connect
to a database, internet, serial port or hardware.

## Findings that must remain explicit

Shape validity is not current Flutter/Uno compatibility: the provisional START,
STOP and STATUS examples are still larger than Ally's reported incoming buffer.
The historical transport and identity assumptions still require CHANGE; no source
protocol is selected by a successful schema test.

The manual-result proposal deliberately requires additional relational guards:
original quantity bound, signed-bigint maximum, expected identity/hash/session
and manifest mapping cannot all be proven by a structural JSON Schema. Reference
checks reject representative mismatches, but actual server implementation is absent.

Two concrete hardening gaps were directly demonstrated without editing the
already-shared schema:
1. Outer lookup batch/actor/result fields can be structurally inconsistent with
   the nested receipt. A real response validator must compare the full tuple.
2. NOT_AUTHORIZED with retryable:true currently passes the error shape, though
   documented semantics require controlled authorization recovery, not blind retry.

These are open review/runtime requirements, not claimed fixed. Recommend exact
reconciliation validation and error-code/retryability constraints in a separately
reviewed revision; do not silently overwrite the 0.1 package Kath is reviewing.
Positive schema checks demonstrating these gaps are not successful authorization
or server-acceptance cases. Raw manual-result HTTP duplicate-key/UTF-8 parsing,
real database uniqueness/races, Dart parity and durable storage remain untested.

## Received decisions versus missing inputs

- Mary's M01–M07 personal positions are confirmed, not another member's vote.
- Kath's exact five-input CHANGE review has been received; she need not repeat it.
- Her later storage/workflow/session proposal is received, but new package pins,
  API-30 floor, activation expiry and future finalization machinery remain unapproved.
- Ally's full D02/D04/D06 response and four completion conditions are received.
  His later EML verification is email-draft preparation, not the requested exact
  provisional-schema/example disposition or protocol-supersession selection.

**C-02A now has fresh sample/schema validation evidence and Kath review evidence.**
Still required: Ally's exact same-input capability/schema review and explicit
disposition of genuine gaps. A CHANGE review is legitimate review evidence; it
must not be confused with final protocol approval. C-02B's dependency stays open,
and C-02C still requires shared field/protocol approval.

## Remaining implementation work not executed

All **24 manual-result implementation/acceptance cases remain NOT RUN**. No
actual persistence, token/RLS, Flutter store, new source adapter, hardware command,
deployment, migration, firmware build, flashing or powered test was performed.
Application and database implementation remains outside this verification scope.

Published Cha counts after honest progress: **7 Completed, 9 Partial,
25 Not started, 1 Superseded**; 34 unfinished nonsuperseded source records.
Only C-02A progresses newly to Partial. Other-member statuses and the completed
archive remain unchanged. Browser-saved overrides/reports must not be overwritten.


# OCT26:C-02B — direct Ally packet review and response

**Owner:** Mary Charlyn (Cha/Mary) · **Date:** 2026-10-30 · **Priority:** P1.
**Task status:** Not started → Partial. The document comparison is performed;
the full task is not Completed because its explicit C-02A prerequisite is open.
No other owner's status or completed evidence is changed.

## Input and verification boundary

Received `01-20261030T075957Z-1-001.zip`, SHA-256
`d7657d191f11d18d4e87f803c1314719157bbe7b9f56a184b56e0cde31d15eb2`.
The archive contains 34 Markdown documents, not the referenced source, patch,
raw fixtures, executable models, validation scripts, build logs or ELF/HEX.
It was extracted into a fresh approved temporary directory, not the source tree.
All 34 files are indexed/hashed; this review closely reads the A-01 handoff,
interface, A-04 format options, personal response, parser-patch report and profile
approval section. Other documents are inventoried, not claimed independently
reproduced or all exhaustively reviewed. Reported checks are not new executions.

Comparison inputs: existing `docs/C02-provisional-communication-contract.md`,
the three preserved DB-02 candidates, current D01–D06 ledger/amendment and the
previously supplied Flutter compatibility review. External Flutter findings are
working-tree-specific, not an assertion that every branch is identical.

## Completed review output: provisional C-02 against A-01 findings

| A-01 finding | Provisional contract / current candidate comparison | Disposition |
|---|---|---|
| F-01 missing app-facing sketch in Ally branch | C-02 cannot choose a source from README. Our checkout has a different sketch; missing there is not missing globally. Numeric START candidate and START_BATCH/CONFIRM summary still diverge. | D01 source/supersession open; no baseline selected |
| F-02 USB app, no HC-05/Android SPP | Provisional §§2–3 still mention USB fallback/ESP8266. Those are historical, not current route approval; selected route stays Uno↔HC-05↔Android↔cloud. | Future contract revision required, not a transport implementation pass |
| F-03 no RTC | Provisional §4 proposes source measured_at/boot/sequence; latest response confirms these are absent. Do not promote millis/receipt to source UTC or fabricate Day 1. | Null/false time direction retained; elapsed/outage policy open |
| F-04 no independent fuse/watchdog | Provisional §§1, 5 disclaim safety/physical evidence; physical status VERIFIED cannot be satisfied by relay latch bits. | No safety clearance or independent output feedback inferred |
| F-05 low SRAM | Provisional ID bounds up to 64 chars are proposals, not feasible frame limits. Later parser build reports 266 B remaining. | D03 directional maxima, stack/service and journal encoding required |
| F-06 no physical validation | Provisional synthetic VERIFIED examples test structure only; newer RUNNING is reported controller/latch confirmation. | Source report ≠ physical switching proof; physical tests remain gated |
| F-07 stuck-but-plausible DHT | Provisional validity is reported plausibility, not calibration/authentication. Current pair-valid flag does not supply per-channel provenance or stuck detection. | Keep separate validity/freshness/calibration/safety labels |
| F-08 running overloaded by command | START running is post-confirmation in reports; TURN_NOW running is in-flight. Generic running→batch RUNNING is unsafe. | Must branch on cmd for this candidate; final wire decision not selected |
| F-09 divergent variants | Provisional nested payload/command_id, numeric cmd/id, legacy actuator and DB-02 HW02 adapter shapes are not interchangeable even when v:1. | No permissive fallback or silent alias mapping |
| F-10 nested older copy | An older compilable sketch is only a reference unless jointly selected. | Preserve history; require one matching source/catalog hash |

## Direct responses to Ally's ten A-03 questions

1. **Baseline:** no shared source selected. Keep the reported original `3721bce0…`
   and parser-patched `7106ebfe…` distinct. Ally must deliver existing actual
   source/patch/catalog and state whether START supersedes START_BATCH/CONFIRM.
2. **Family:** HC-05 Android remains selected architecture, not USB farmer
   fallback. Neither legacy actuator-only Flutter nor numeric NDJSON v1 is
   accepted as the final cross-component schema. DB-02 source acceptance stays off.
3. **RUNNING:** for the supplied numeric candidate, interpret START and TURN_NOW
   separately; neither ACK nor a GPIO latch is independent physical feedback.
   This is a review requirement, not selecting a replacement field/type.
4. **Sensor range:** do not choose −20..60 or −20..80 as a biological/safety range
   merely to make parsers agree. Preserve mismatch and source provenance; Ally
   and Kath must accept a version-specific parser policy. Approved incubation
   targets are a different numerical-profile approval.
5. **Identities:** no numeric command/batch→UUID/session cast or phone-invented
   source sequence. Android-origin durable identities are a design direction,
   not current implementation. Preserve lossless bigint session mapping.
6. **States:** cloud Active, command ACK, controller-observed state, independent
   physical feedback, farmer results and synchronization receipts stay distinct.
7. **Day:** trustworthy original Start + elapsed reference are prerequisites.
   Unknown UTC remains null; phone timestamps may be retained separately as phone
   provenance, never placed in source occurred_at to fake controller time.
8. **Evidence:** same source hash/patch/catalog and literal fixtures/build logs
   for software review; actual flashed identity, transport and physical output
   evidence only in separately authorized integration/physical tests.
9. **Reconnect:** no automatic Start replay. Fresh telemetry/RUNNING alone is
   insufficient if uncorrelated or missing original batch/outcome evidence;
   retain unresolved outcome until agreed read-only recovery/adjudication.
10. **Location:** existing CONTRACT-FREEZE-01 ledger and DB-02 consolidated
    amendment carry choices; this report records the attributable C-02B comparison.
    No second competing decision register is created.

## A-04 options: backend review, not a unilateral selection

- **A: numeric v1 unchanged:** does not meet current trusted batch/sample source
  association requirements. Never attach late readings to latest Active by guess.
- **B: versioned provenance:** can address missing fields only after actual
  feasibility, exact schema/identity/time policy and all-owner acceptance. No
  field/size/version is implemented or selected by this review.
- **C: app envelope:** can truthfully add phone receipt/local capture metadata,
  but cannot repair missing controller batch/sample identity, original time or
  authenticate the source. Quarantine/reduced guarantees need explicit approval.

The literal `v:1` is not a common contract identifier across these incompatible
families. A-04's local 'frozen implemented v1' is not joint protocol approval.

## Ally's thirteen dispositions — full text now received

| Position | Disposition (primary) | Scope |
|---|---|---|
| D02-1 | BLOCKED | Design blocked / shape CHANGE; exact identity/byte budget not selected |
| D02-2 | CHANGE | STOP absent; six exact semantic choices supplied |
| D02-3 | ACCEPT | ACK/state/cloud distinction; no independent physical feedback |
| D02-4 | CHANGE | Extend STATUS with agreed recovery data; not invented GET_STATE |
| D02-5 | BLOCKED | Four-slot journal vs explicit narrower loss guarantee remains choice |
| D02-6 | CHANGE | Exact directional bounds required; HTTP ceiling not device size |
| D04-1 | BLOCKED | Controller key/provision/revoke/crypto feasibility absent |
| D04-2 | CHANGE | Bounded critical retention, not telemetry/ACK archive |
| D04-3 | ACCEPT | Full/corrupt blocks new Start, not emergency safety action; unimplemented |
| D04-4 | ACCEPT | retention_ack:null, no HTTP/phone-synthesized release |
| D04-5 | ACCEPT | Offline revocation/clock limits; do not reinterpret phone time as source UTC |
| D06-1 | ACCEPT | Real DB names, bigint, immutable retry/content conflict |
| D06-2 | ACCEPT WITH CONDITIONS | Manual result independent of Stop, subject to four conditions below |

Primary count: 6 ACCEPT (one conditional), 4 CHANGE, 3 BLOCKED. D02-1's secondary
shape CHANGE is retained, not counted as another position.

Exact conditions in the received response :238–245:
1. Completion never commands, implies or records a physical Stop.
2. Completion does not by itself clear the single-Active guard or authorize
   another hardware batch; admission is a separate lifecycle decision.
3. Unknown original completion time stays NULL, not replaced by server receipt.
4. Counts remain manual integers 0..original egg_quantity, not sensor-derived.

These agree with Mary's requested separation and the conservative DB-02 amendment
direction. Exact storage/lifecycle finalization/admission rules and Kath's
transaction/UX acceptance are still open. No removal of stopped_event_id from
code/schema/fixtures is authorized or performed.

## Findings not to propagate from the supplied documents

- A 120-byte RX application buffer does not constrain all outgoing TX frames;
  a 4096-byte HTTP ceiling is not a required Uno frame size.
- AVR long is four bytes; an eight-byte command identity does not fit it unchanged.
- The 64-byte AVR software RX ring is not a hardware whole-frame maximum.
- Same-ID cached ACK replay is not changed-content detection; no fingerprint
  exists in the described RAM cache. It is not durable idempotency across reboot.
- No RUNNING frame or activeBatchId==0 does not prove outputs stay off after
  sensor recovery. Earlier reset/selection/blank-EEPROM control reports still
  require the selected source's transition/output reconciliation.
- Existing profile values are now directly supplied in the profile document
  §8.5, **NOT APPROVED**. Existing Day-7/stage wording in reports does not reopen
  selected Day-1 architecture; numerical approval and compatibility remain gates.

## Actual work, acceptance and remaining tasks

Performed: safe ZIP inventory/extraction; all Markdown file hashes; direct
13-position/four-condition transcription; F-01..F-10 comparison; ten concrete
backend responses; ledger/amendment receipt corrections; Partial task/report
publication. Companion validation checks document integrity and exact source
excerpts only. No Arduino/Flutter build or reported host/JCS test was rerun.

**OCT26:C-02B remains Partial:** its explicit dependencies are OCT26:A-01 and
OCT26:C-02A. A-01's report and A-03 handoff are now delivered here; C-02A still
requires schema reviewed by Ally and Kath, with validated sample messages. The
reviews identify incompatibilities; they do not establish that both reviewed
the exact provisional schema/example bytes. Do not infer that dependency passed.

C-02C explicitly waits for approval/final fields. ORIGINAL:C-02, DB-IMP-01,
secure ingestion, installation authorization, time/batch freshness and integration
still lack their exact criteria. Numerical profile database verification is not
closed by an unsigned source profile. No remaining full task is newly completed.

Cha totals after this progress update: **7 Completed, 8 Partial, 26 Not started,
1 Superseded**; still 34 unfinished nonsuperseded records. The earlier remaining
queue assessment is historical; C-02B now has actual input and review progress,
not an ongoing assertion that the handoff is absent.


---
Earlier updates below are historical snapshots.

# Latest independent task execution

136 total records: ORIGINAL 32, OCT26 92, CURRENT 7, NEW 5. Mary Charlyn owns 42 (ORIGINAL 9, OCT26 31, CURRENT 2, NEW 0). Published counts: 7 Completed, 9 Partial, 25 Not started, 1 Superseded. 34 noncompleted nonsuperseded source records remain. Completed scope includes four existing architecture decisions, the two C-01 audits, and the independent OCT26:C-03 architecture review with new 13/13 targeted and 83/83 regression results. None of these reviews certifies secure cloud or physical integration. Remaining implementation/team/hardware gates are preserved; queue parking is not bulk status editing.

# OCT26:C-03 — backend alignment with the selected HC-05/Android architecture

**Owner:** Mary Charlyn L. Aguirre · **Priority:** P0  
**Review date:** 2026-10-30 (Asia/Manila)  
**Initial status:** Not started → **Final status: Completed (architecture review)**  
**Baseline:** cha-branch2 / `2d2622e`; backup `035e842` preserved.  
**Architecture:** autonomous Uno → HC-05 Bluetooth Classic → Android Flutter
bridge → authorized Supabase through the phone's internet. USB is diagnostic;
ESP8266/Wi-Fi alternatives are historical, not active selections.

## Requirements and eligibility

Source task title: “Review backend design against the final Bluetooth/Wi-Fi
architecture.” The existing portal currentScopeText already normalizes it to
“Align backend with the selected HC-05 / Android bridge architecture.”

Prerequisite: relevant approved architecture inputs, without reopening the
selection. `deps` is empty. Expected deliverable: a backend design review;
verification: dated attributable design/code/automated evidence, keeping unknowns
explicit. Acceptance: demonstrate that exact review requirement, not implement
all dependent firmware, Android, database or physical tests.

The user explicitly authorized other independent work while waiting for Kath and
Ally. Their blocked implementation tasks are parked, not silently completed or
bypassed. This review selects no source catalog, profile, freshness threshold,
provisioning mechanism or new lifecycle contract. No additional team answer is
needed to document alignment and the remaining gaps against an already selected
architecture.

## Existing implementation and actual architecture comparison

| Boundary | Current inspected design/code | Review finding / verification |
|---|---|---|
| Uno controls locally; cloud does not command actuators | bridge-sync accepts candidate event/reading/reconciliation operations; physical START/STOP/STATUS, new-batch, settings and actuator-operation requests are not cloud operations | New test rejects those operations before authorization/persistence. Recording a past `started` event is not sending START. |
| Android is the farmer-facing bridge | Current DB-02 and bridge-sync design describes Android upload and explicit source evidence; existing lib still uses USB serial and direct Supabase tables | Intended design aligns; real Android Classic SPP/decoder/outbox implementation is still Kath-dependent. No USB farmer fallback is approved here. |
| Supabase is a scoped persistence/monitoring boundary | createSupabasePorts has Auth and three named RPC ports; no legacy direct-table write fallback in that adapter | New stub-boundary test verifies exact three RPC paths/argument keys. This does not test deployed RPCs or JWT signatures. |
| Separate cloud authorization from local Bluetooth authority | Local Supabase adapter rejects anonymous Auth responses and requires verified user/session scope in its candidate logic; no implemented Uno-side authority is established | Reuse actual Auth-boundary regression tests as stub evidence only. Cloud auth failure is an upload error, not a physical Stop. Offline command authority remains blocked. |
| Never infer physical state from ACK/cloud persistence | Default source adapter throws CONTRACT_NOT_ENABLED; source evidence/identity is not fabricated to fit known old firmware formats | Six new closed-gate cases prove no receipt or ingestion from accepted Auth/registry stubs, including manual completion. This is fail-closed behavior, not source compatibility. |
| Preserve original event time | immutableCore preserves occurred_at/timestamp_valid and excludes phone receipt time | New unit test shows unknown source Start time stays null/false, not replaced by phone time. RTC, source acquisition time and elapsed-day policy remain unapproved. |
| Cloud receipt is not an authenticated Uno evidence-release artifact | Candidate receipt validator requires retention_ack:null | New test rejects every non-null release value tested. No unlimited retention or production journal guarantee is inferred. |
| Isolated test destination; no application-project fallback | createSupabasePorts refuses application ref suopuhgtwyqkpupzvdng even if passed as its own test pin; nonlocal target must match explicit HTTPS test ref | New tests exercise exact-origin, path/credential/query/fragment rejection with fetch stubs and zero network calls. No environment file is loaded. |
| No source/wire contract invention | Existing default gate remains closed; Ally's supplied newer source hash differs from this checkout and complete packet is absent | No guessed adapter, event/sample IDs, trusted time or frame bound added. Ally report claims remain attributed; see ALLY_REPORT_REVIEW.md. |
| Legacy direct Flutter writes remain a compatibility/security gap | main.dart:28 anonymous sign-in; SupabaseService directly reads/writes settings/sessions and reads sensor rows; no RPC ingestion calls | These routes are not the reviewed secure bridge implementation. Remediation must coordinate with Kath and separate migration approval; no behavior/grants changed here. |

The current test-catalog evidence (four public tables, 22 columns, broad grants/
policies, no bridge-sync RPCs) is reused from the identified prior test run,
**not freshly queried**. It is enough to identify the missing persistence layer
in this review, not a security pass or production-state certification.

## Historical design material — preserved, not revived

`docs/C03-provisional-ingestion-security-plan.md` is an older ESP8266-publisher
proposal, including an ingest-telemetry endpoint and USB fallback wording. It
predates the selected Android bridge and must not drive current implementation.
It is preserved unchanged as history. Current architecture alignment is the
Android bridge with disabled-source bridge-sync seams and the reviewed DB-02
candidate documents; this report neither overwrites old sources nor finalizes
the candidate wire/API revision.

Likewise, old README statements that smarthatch-test was inactive/no test instance
was available describe earlier observations. Later test evidence established an
active isolated target and a small role probe. Neither observation supplies missing
RPC implementation or authorizes deploying drafts.

## D06 completion conflict deliberately not implemented

Mary's personal request is to save manual hatch results independently of physical
Stop. Existing candidate validators/fixtures still require stopped_event_id.
That mismatch is **pending joint review**, not silently repaired here. The source
gate still rejects this path before persistence; the architecture test explicitly
checks default-closed manual completion. Existing candidate fixture regressions
passing do not ratify their Stop requirement or overrule Mary's request.

## Minimal changes made

- Added `test/backend/architecture_alignment_test.mjs`: 13 local boundary tests,
  using existing candidate fixtures and in-memory ports/fetch stubs; no selected
  firmware adapter, external network, credentials or schema modification.
- Added this per-task review, retained actual TAP output, and local acceptance
  validator/queue evidence.
- Publish **only OCT26:C-03** as newly Completed for its review scope. Keep all
  136 source records, ownership, history, other statuses, browser overrides and
  the original Downloads HTML unchanged. Update full portal/report/import/handoff.

No production backend module, Flutter/Arduino file, SQL draft/migration, contract
candidate, Auth setting or database object was changed for this task.

## Actual commands and results

```powershell
node --test --test-timeout=15000 --test-reporter=tap --test-reporter-destination=docs/integration/cha-execution/oct26-c03-architecture-targeted.tap test/backend/architecture_alignment_test.mjs
node --test --test-timeout=15000 --test-reporter=tap --test-reporter-destination=docs/integration/cha-execution/oct26-c03-backend-regression.tap test/integration/int_imp_01.test.cjs test/backend/bridge_sync_http_test.mjs test/backend/bridge_monitoring_test.mjs test/backend/architecture_alignment_test.mjs
node --check test/backend/architecture_alignment_test.mjs
```

- **Targeted: PASSED 13/13**, zero failures/skips/cancellations.
- **Full local regression: PASSED 83/83**, zero failures/skips/cancellations.
  Includes the 13 new tests; do not add 13 + 83 as 96 distinct tests. Unlike the
  historical 64/70 counts, these are newly executed retained logs.
- Syntax check PASSED. Loopback HTTP in existing suites and boundary mocks are
  local software evidence only. No real Supabase/Auth/RLS/transaction result or
  physical transport/control result is inferred from them.
- Flutter/Deno/AVR builds, cloud JWT/registry/RLS tests and hardware checks:
  **NOT RUN** for this architecture-review task. No application code changed.

Errors: no new test failures. An initial read-only Node one-liner for extracting
the portal requirement had a PowerShell quoting error; a corrected PowerShell
JSON read obtained the exact task. No SQL, backend behavior or data was affected.
The earlier interruption's empty patch call failed before any file modification.

## Acceptance assessment

| Criterion | Evidence | Result |
|---|---|---|
| Review backend against the selected transport/authority boundaries without reopening architecture | Comparison matrix above; current core/ports/entrypoint, dev server, Flutter service and historical design reviewed | PASSED |
| Attributable actual software verification | Newly retained 13/13 targeted and 83/83 regression TAP logs; new test file; syntax check | PASSED within local scope |
| Preserve unknowns, missing inputs and untested levels explicitly | Auth/source/RTC/outbox/schema/Stop/profile/physical gaps above; candidate gate unchanged | PASSED for truthful review |
| No implementation/deployment/security/physical completion inferred | No such acceptance claimed; independent tasks retain gates | PASSED for review boundary |

**Conclusion:** the architecture-alignment **review deliverable is Completed**.
Actual secure ingestion, Android transport, durable outbox, source semantics and
physical integration are not completed by this review.

## Dependencies and next task

Kath still owns compatible Android transport/decoder/auth/storage; Ally still
owes the exact matching packet and source/authority/retention/time details.
Formal architecture adoption/distribution requires real attributable records.
The remaining queue is reviewed separately; no subsequent task begins merely
because local mock tests passed. Resume a dependent implementation only when its
specific decisions, evidence and applicable remote-change approvals exist.


# Remaining queue after OCT26:C-03

> Later independent schema verification progresses C-02A to Partial; exact Ally
> review remains open. See INDEPENDENT_SCHEMA_VERIFICATION.md. Latest counts:
> 7 Completed / 9 Partial / 25 Not started / 1 Superseded, still 34 unfinished.
> Older input-absence/status statements below are historical snapshots.

> Historical post-C03 snapshot. Later direct Ally ZIP review supplies the A-01
> handoff and progresses OCT26:C-02B to Partial; see ALLY_ZIP_C02B_REVIEW.md and
> ally-zip-progress.json. Its C-02A prerequisite remains open. Current counts:
> 7 Completed, 8 Partial, 26 Not started, 1 Superseded; 34 unfinished records.
> Do not read the older C-02B input-absence reason below as the latest receipt state.

One independent architecture review completed. No other source record currently has all inputs needed for full completion without shared decisions, actual distribution/participants, implementation approval or hardware evidence. Parked means a queue decision, not changing the published task status to Blocked. Safe draft/test preparation may still be possible; it must not be labelled a completed full ticket.

| Task | Existing status | Reason full completion is parked |
|---|---|---|
| ORIGINAL:C-02 | Not started | Exact selected interface packet and Ally/Kath schema review are missing. |
| ORIGINAL:C-03 | Partial | Secure source ingestion needs the selected source contract, identity scope and separately authorized schema/RPC implementation. |
| ORIGINAL:C-04 | Not started | Actual installation bootstrap/session/Flutter compatibility remains undecided; no pilot enrollment approved. |
| ORIGINAL:C-05 | Not started | Full authorized/other/revoked matrix needs implemented identity/RPC boundaries; the sensor role probe is not that matrix. |
| ORIGINAL:C-06 | Not started | Confirmed source command/batch lifecycle and real Start reconciliation are not pinned/implemented across owners. |
| ORIGINAL:C-07 | Not started | Original source timestamp/identity and batch-association mapping are not finalized. |
| ORIGINAL:C-08 | Not started | Manual completion independent of Stop is a pending shared change; persisted validated completion is not verified. |
| ORIGINAL:C-09 | Partial | Measured cadence/freshness policy required by this task is not approved; do not invent a threshold. |
| OCT26:ARCH-05 | Partial | Formal adoption/repository-baseline evidence is not supplied; a locally drafted amendment is not adoption. |
| OCT26:ARCH-06 | Not started | Actual distribution/recipient/date acknowledgments are missing; preparing a handoff is not sending it. |
| OCT26:C-02A | Not started | Existing provisional schema still lacks the required Ally/Kath review. |
| OCT26:C-02B | Not started | Requires reviewed provisional contract and the actual matching Ally interface/handoff packet, not report path strings. |
| OCT26:C-02C | Not started | Final fields/examples need the preceding reviews and explicit shared selection. |
| OCT26:C-04 | Partial | Actual secure-ingestion acceptance is source/Auth/SQL-dependent; candidate fixture success is not a real secure endpoint. |
| OCT26:C-05 | Not started | Non-anonymous installation setup and Flutter compatibility remain jointly unresolved. |
| OCT26:C-06 | Not started | Approved species-profile input and database values/approval provenance have not been established. |
| OCT26:C-07 | Not started | Depends on species-profile verification; app/profile behavior cannot be finalized from unapproved values. |
| OCT26:C-08 | Not started | Depends on final contract and physical START/STATE implementation; missing cross-owner source and device evidence. |
| OCT26:C-09 | Partial | Source schema/time/cadence and truthful batch/freshness mapping are not finalized. |
| OCT26:C-10 | Not started | Depends on Kath completion flow and the shared completion rule; real persisted result acceptance remains unverified. |
| OCT26:C-11 | Not started | Real secure synchronization/recovery needs DB-IMP-01 and Kath durable outbox implementation. |
| OCT26:TEST-01 | Not started | Actual approved-transport Arduino/Android communication requires source, Android implementation and authorized devices. |
| OCT26:TEST-02 | Not started | Secure Flutter-to-Supabase sync requires actual identities/RPCs/outbox; not established by host fixtures. |
| OCT26:TEST-03 | Not started | Real Bluetooth/internet failure-recovery evidence is missing; mock link tests are not device results. |
| OCT26:TEST-04 | Not started | Physical autonomous-control loss testing requires source, approvals, hardware and qualified clearance. |
| OCT26:TEST-05 | Not started | Real physical Start/Stop/restart remains unimplemented/unverified; safety and shared lifecycle gates outstanding. |
| OCT26:TEST-06 | Not started | Real sensor accuracy/time/freshness checks need attributable source policy and hardware evidence. |
| OCT26:TEST-07 | Not started | Approved species values and actual integrated species-setting behavior are not verified. |
| OCT26:TEST-08 | Not started | Turning/lockdown depends on approved timing/mechanics and shared implementation; do not infer host checks are physical proof. |
| OCT26:TEST-09 | Not started | Real manual-entry/History persistence and approved completion behavior need the compatible app/backend. |
| OCT26:TEST-10 | Not started | Requires actual farmer usability sessions and records; cannot fabricate participant outcomes. |
| OCT26:TEST-11 | Not started | Requires safety-cleared actual pilot/cycle/hatch data; no real results supplied. |
| CURRENT:DB-IMP-01 | Partial | Exact source/API/identity/storage/lifecycle decisions and separately approved remote implementation are missing. |
| CURRENT:INT-IMP-01 | Partial | Exact matching source/decoder/backend packet and full integration acceptance remain missing; review summaries do not finish the ticket. |


---

# Preserved earlier evidence and reports (earlier status snapshots are historical)

# Latest Ally progress-packet review

Task ID: CURRENT:INT-IMP-01
Owner: Mary Charlyn
Priority: P1
Initial/final task status: Partial.
Scope: reviewed the supplied 26 Ally-attributed reports covering 23 outer task IDs, not executing Ally tasks. Six offline integrity/boundary checks passed. No source acceptance, test rerun, report import, task/status change or joint approval.

# Ally's report export — are the outstanding backend questions answered?

## Result: useful progress evidence, but not all questions are resolved

Reviewed **all 26 reports covering 23 outer task IDs** in
`SmartHatch-all-reports-2026-10-30-1.json`, exported
`2026-10-30T02:38:43.020Z`. All are attributed to Ally. Source SHA-256:
`09309a30346acd04b14f4db058d0aa0019dc1a77bbb748535f0b9541b7745da8`.

The JSON is structurally a valid portal report export. It is not a source-code,
full-contract or raw-build-log bundle. Reported results are attributed evidence,
not tests rerun by Mary/the reviewer. The original export remains unchanged and
was **not imported** into browser reports. No task status or sign-off is changed.

## Important filing problems before import

| Report ID | Outer JSON assignment/status | Actual body | Interpretation |
|---|---|---|---|
| `R-mvuclz61hgzq` | OCT26:HW-01, RTC identification, Completed | CURRENT:HW-IMP-01, parser/START/STATUS patch, explicitly PARTIAL; STOP/auth/RTC/durable recovery blocked | This is not evidence that an RTC chip was identified. |
| `R-mvucw1mbzn44` | OCT26:HW-02, Bluetooth identification, Completed | CURRENT:HW-IMP-02, durable recovery host model/design; no production journal/RTC/auth | This is not evidence that an HC-05/module/firmware was identified. |

These two otherwise useful bodies appear to have been saved under the wrong task
selection/status. Preserve the original records; ask Ally to correct their filing
with provenance in their working portal rather than rewriting or deleting their
reports here. Do not infer confirmed RTC/Bluetooth from the latest outer labels.
Other rows also have Not started labels with bodies describing prepared docs:
read their scope, not just the status badge. ORIGINAL:A-06's Completed badge is
not a physical-Start pass: its body explicitly limits the results to host tests.

## D01–D06 comparison

| Decision/question | What Ally's supplied text actually provides | Still required | Result |
|---|---|---|---|
| **D01: canonical source/catalog** | A-01/A-02 identify `ally-branch3`, HEAD `80971f902d5634f7fed78ff073fcb78fa31be460`, Combined sketch; later HW-IMP bodies supply patched source SHA-256 `7106ebfe01d037c95766cd51c43b43fa02f92b922fc5a180770fd27b3822c5ec`. They explicitly disclose an uncommitted patch and an app-facing source gap. | Exact source/patch files, matching complete catalog/manifest/toolchain and a deliberate same-packet choice by owners. Local observation/reporting is not joint selection or flash identity. | **Partially documented; selection unapproved.** |
| **D02: lifecycle, identities, recovery** | START ACK vs RUNNING, duplicate/changed-content/wrong-batch/lost-ACK/split cases and LF overflow drain are reported host-tested. STATUS is read-only in the described fixtures. | STOP is explicitly unimplemented. A-04 says v1 telemetry lacks device_id, batch_id, sample_id, measured_at and timestamp_valid. Exact original event/sample/manifest identities, complete schemas and production retained recovery are not supplied/implemented. | **Partial host evidence; contract gaps remain.** |
| **D03: real build/byte/memory bounds** | Compile/link and avr-size outputs are reported: pre-patch 21,142 B flash / 1,781 B SRAM; patched 21,164 B / 1,782 B, only **266 B** static headroom; source/HEX/ELF hashes listed. | Need actual build logs, pinned toolchain/libraries, maximum permitted RX/TX fixtures, byte bounds/delimiter treatment, stack/service-budget assessment on the selected packet. A low-memory linked build is not proof of safe worst-case runtime capacity. | **Build evidence reported; bounds/feasibility acceptance not closed.** |
| **D04: offline authority and retained-evidence policy** | HW-IMP-01 explicitly says authorization/live admission unimplemented. HW-IMP-02 proposes a host model: 4 × 64 B journal at 0x0200–0x02FF, CRC/commit marker, 64 cut offsets, no overwrite when full. | Actual feasible local provisioning/authentication/revocation design; production journal; exact retention/full/corrupt/accepted-loss policy; explicit response to Mary's retention_ack:null/no HTTP-only release position. A proposed model is not an approved loss guarantee or production durability. | **Blocked/unapproved, with useful design preparation.** |
| **D05: profile/RTC/time/freshness** | No RTC implementation; wall_clock_valid=false/monotonic-only is reported. Profile signature, physical RTC identification/wiring/timekeeping and safety remain pending. Pilot is explicitly NO-GO. | Named profile approver's actual values/signature; real RTC/module information; agreed invalid-clock/outage/freshness policy and attributable source timestamps. Implementation literals are not approved incubation values. | **Explicitly blocked, not answered with approved values.** |
| **D06: source/cloud mapping and independent completion** | A-03 prepares a C-02 handoff; A-04 proposes choices A/B/C (v1, v2, or v1+envelope), with D-01…D-10 and Cha/Kath sign-off pending. Host recovery/model work helps define limitations. | Exact source-to-backend fields/receipts/dependencies, complete proposal files, and Ally's explicit ACCEPT/CHANGE/BLOCKED response to Mary's **manual completion independent of physical Stop** and safe next-batch rule. No such acceptance is recorded in this export. | **Not jointly answered; Mary's requested change remains pending.** |

Ally's A-04 “v1 frozen” means the report's implemented baseline is not being
edited in place. The same report explicitly says the final Cha/Kath format
agreement is pending. It is **not** a jointly signed D01–D06 contract freeze.
Its local D-01…D-10 list is a different scoped decision list from the six shared
D01–D06 rows; the actual decision CSV is needed before mapping them.

## Progress we can reuse without repeating the audits

- A-01 firmware audit and A-02 interface documentation are reported prepared.
- START/ACK/RUNNING separation, null/invalid readings, parser drain and host
  recovery/turning/control checks are reported with limitations, not physical proof.
- Later reported totals include 40 HW-IMP-01 host checks, 31 durability-model
  checks and a pilot summary of 311 host checks. These runs overlap older suites:
  **do not add all report totals as distinct tests**. None was rerun in this review.
- Production journal, STOP, offline authorization, RTC, HC-05/Android and powered
  tests are expressly absent/blocked. No need to ask Ally to pretend they passed.
- The pilot report explicitly records NO-GO, no empty-incubator run, postponed
  eggs, unsigned safety clearance and pending profile approval. Those gates stand.

## Different source snapshots: do not silently merge them

This Cha checkout is still `cha-branch2` at `2d2622e`, not Ally's reported HEAD.
Its Combined source SHA-256 is
`a466a868e6c148cf4f9c3230378d5033d81db89dfb77a3e0fa53891d847a9598`,
not the supplied later `7106…` hash. Our local Uno sketch exists; Ally's audit says
the current app-facing path is missing in their main checkout. Those observations
can both be true for different snapshots; neither proves the other's branch wrong.

The reported `80971…` commit is not available in this local Git object database
(`git cat-file -t` could not resolve it). The seven specifically referenced audit/
interface/format/HW-IMP docs checked by this review are absent from this checkout.
No fetch, branch switch, merge, build, flash, hardware operation or database access
was performed. Path/hash strings in JSON are not a substitute for the file bytes.

## Small, targeted follow-up to Ally — one matching packet, not another audit

Please send a ZIP/source packet containing these existing outputs plus their
matching source/catalog/build evidence (no credentials):

1. `docs/oct26_a02_firmware_interface.md` — exact current interface/catalog.
2. `docs/oct26_a03_a01_findings_for_cha.md` and its `a01_findings_for_c02.csv` — the
   actual ten review questions/findings, not just a report that the memo exists.
3. `docs/oct26_a04_final_ndjson_format_decision.md` and
   `docs/evidence/oct26-a04/2026-10-30/format_decisions.csv` — exact A/B/C proposal,
   fields and pending decisions. Mary should review these before choosing a version.
4. `docs/hwimp01_source_patch_start_stop_status.md`, the exact Combined source or
   patch/manifest at `7106…`, build/avr-size/toolchain logs and matching fixtures.
5. `docs/hwimp02_durable_recovery_design.md` — precise proposed retention/full/loss
   policy and record schema, clearly labelled host-model versus production.

Then answer only the unresolved points:

> **D04:** What offline command-authority/provisioning/revocation and bounded
> retention/full/corrupt/loss policy do you propose? ACCEPT / CHANGE / BLOCKED on
> Mary's retention_ack:null and no automatic evidence release after HTTP success.
> Do not invent guarantees if the design cannot fit; name the exact blocker.
>
> **D06:** ACCEPT / CHANGE / BLOCKED on Mary's proposal to save validated farmer
> hatch results independently of physical Stop, without claiming Stop or allowing
> another hardware batch merely because the cloud row is Completed. What exact
> hardware state/admission/new-batch facts must Kath/backend preserve?

This asks for **Ally's response**, not for them to approve Kath's storage/auth UI
or the adviser's profile values. Kath's own sign-off and the missing byte-level
source/mapping decisions are still separately needed.

## Preservation and portal effect

All report bodies, IDs and source hashes are indexed under `ally-export-review/`.
The two task-ID mismatches are retained as findings; no raw report is reassigned,
overwritten, deleted or silently imported. The main ledger records progress
reports **received**, not an invented Ally approval. The portal gets Mary's
review summary only. Cha counts and all other members' statuses remain unchanged.

Local verification checks the JSON/index integrity, report counts, mismatches,
source preservation and pending approval boundaries. These are document checks,
not a new Arduino compilation, source acceptance, end-to-end or security test.


## Overall task counts (unchanged)

136 total records: ORIGINAL 32, OCT26 92, CURRENT 7, NEW 5. Mary Charlyn owns 42 (ORIGINAL 9, OCT26 31, CURRENT 2, NEW 0). Published counts: 7 Completed, 9 Partial, 25 Not started, 1 Superseded. 34 noncompleted nonsuperseded source records remain. Completed scope includes four existing architecture decisions, the two C-01 audits, and the independent OCT26:C-03 architecture review with new 13/13 targeted and 83/83 regression results. None of these reviews certifies secure cloud or physical integration. Remaining implementation/team/hardware gates are preserved; queue parking is not bulk status editing.

---

# Preserved earlier reports

# Latest D04/D06 personal response update

Task ID: CURRENT:DB-IMP-01
Owner: Mary Charlyn
Priority: P0
Initial/final task status: Partial.
Changes: recorded four actual personal D04/D06 answers, updated current ledger cells; no backend/SQL/Flutter/firmware implementation.
Tests: 7/7 offline answer/permission/hash-boundary checks passed; no new remote/runtime/security tests.
Remaining: Kath/Ally responses, exact identity/source/API/storage/new-batch rules and separate implementation authorization.

# D04 / D06 — Mary Charlyn's actual backend answers

## Latest confirmation — seven remaining Mary/backend positions

**Date:** 2026-10-30 (Asia/Manila). **Exact user answer:** “alright, i confirm”.
This directly follows the assistant's seven numbered recommendations in this
session. Mary confirms those as her **personal backend positions**, not Kath's
or Ally's acceptance, a complete protocol/API revision, or implementation approval.
The earlier four-answer record below remains preserved history.

| ID | Confirmed Mary position | Still required from others / next design work |
|---|---|---|
| M01 — manual-result workflow | Editable draft; Saved locally only after durable commit; missing original batch/quantity stays Pending validation; distinguish saved, waiting to sync, server-recorded and conflict. Failed save preserves inputs and never shows success. | Kath concrete UX/storage/transaction compatibility and confirmation |
| M02 — prototype cloud completion | Recording results does NOT automatically set cloud Completed. Preserve existing Active guard. Defer lifecycle finalization until Mary/Kath/Ally agree the explicit controller-may-still-be-running rule. Truthful proposed presentation: result recorded; lifecycle finalization pending. | Joint finalization/admission rule, not invented Stop or current index bypass |
| M03 — immutable original manifest | Validate against original batch identity/quantity/profile version/farmer-action identity; never current settings/latest Active guesses. Missing association/evidence remains pending. | Kath durable manifest storage/retrieval; selected source/actor binding |
| M04 — corrections deferred | Editable drafts before submission; action identity/content freeze when committed for submission. Identical retry reuses identity; changed immutable content conflicts. Defer submitted-result corrections for prototype; preserve disputed records for a reviewed future correction path. | Exact commit boundary and UX with Kath; no correction API implicitly approved |
| M05 — backend interface ownership | Mary drafts exact versioned request/validation/canonical-hash fixtures/receipt/reconciliation after workflow alignment. Kath reviews the same bytes. Preserve egg_quantity, eggs_hatched and lossless bigint mapping. | Concrete API still to draft; do not silently remove stopped_event_id or call old candidate compatible |
| M06 — local durability requirements | Atomic action/result+outbox and verified receipt+mapping+outbox-state commits; restart-safe recovery; no false success on storage failure; cloud retry queue never contains physical Start commands. | Kath proposes package/version/schema/Android SDK support floor and actual tests; Mary has NOT selected these for her |
| M07 — protected-cloud enrollment | Administrator-controlled non-anonymous enrollment with restricted installation/controller scope, per-operation authorization and no privileged Android credential. Expired/revoked cloud credentials block protected cloud operations, not autonomous controller operation. Preserve committed evidence through agreed logout/replacement recovery. | Kath bootstrap/secure-storage/refresh/recovery proposal; controller-side auth remains Ally/shared decision |

These are design positions only. No concrete new table/event/field/status enum,
final request schema, plugin, identity wire encoding, source adapter, migration,
RLS/Auth change, RPC activation or deployment is approved. Unknown original
completion time remains null and counts remain manual bounded integers, preserving
Ally's four conditions. No new full task is marked Completed by confirmation.
No hardware safety clearance, flashing or powered test is implied.

The single ledger remains CONTRACT-FREEZE-01_Team_Decisions.md. Do not ask Mary
these seven directional questions again; ask only concrete unresolved proposal
details or explicitly requested changes after Kath's next response arrives.

---

> **30 Oct consolidation update:** Ally's conditional support for independent
> manual results and the supplied Flutter compatibility review are now received.
> Earlier pending-Ally wording below preserves this original personal-response
> snapshot, not the latest receipt state. See the existing decision ledger and
> [DB-02 consolidated amendment](DB-02_30Oct_Consolidated_Alignment.md).
> Exact shared lifecycle/admission choices remain open; no implementation change.

**Respondent:** Mary Charlyn L. Aguirre (Cha/Mary: one person)  
**Recorded:** 2026-10-30, Asia/Manila  
**Disposition:** Personal backend positions accepted below; **NOT JOINTLY APPROVED**.  
**Source:** The user's four explicit answers to the D04/D06 review questions in
this session. “Let's proceed” alone was not treated as approval; the answers below
are the actual subsequent selections.

This is a focused answer/change-request record, not a replacement contract or
another general audit. The main ledger remains CONTRACT-FREEZE-01_Team_Decisions.md.
No vote is recorded for Kath, Ally, or a designated numerical-profile approver.

## D04 — cloud authorization: accepted personal position

**Exact answer:** “Accept this position”.

For **protected SmartHatch cloud data**:

- One administrator-provisioned, non-anonymous installation, bound to approved
  user/session/controller scope.
- Recheck scope on each protected operation; deny anonymous, other and revoked
  identities. Identity IDs are identifiers, not authentication credentials.
- No privileged credential in Android.

**Still unresolved:** exact login/bootstrap/enrollment/replacement mechanism,
secure session storage and refresh behavior, Flutter startup/direct-table/History
compatibility, a reviewed credential-copying threat model, migration/registry
implementation and real signed-token/revocation tests. An app UUID/session binding
alone is not proof that credentials cannot be copied to another physical phone.
Whether any presets are intentionally public is not decided by this protected-data
position. No provisioning or Auth-settings change is authorized by this answer.

Cloud authorization is separate from offline Bluetooth command authority.
Cloud failure/revocation must not be described as a physical controller Stop.
Ally/Kath still need to agree local authorization/provisioning and offline
revocation/loss boundaries before live command gates can be enabled.

## D04 — retained-evidence release: accepted personal position

**Exact answer:** “Accept fail-closed release”.

- Keep `retention_ack=null` in the candidate backend response.
- Do not delete/release Arduino's retained critical evidence merely because an
  HTTP request succeeded. Do not invent an authenticated server-release proof.

This is **not** a promise of unlimited retention or zero event loss. Journal
capacity, full/corrupt behavior, offline authority, accepted loss cases, and any
future feasible authenticated release design still need Ally/Kath agreement.
No automatic retention-release path is enabled by this answer.

## D06 — sync invariants and candidate names: accepted personal position

**Exact answer:** “Accept these positions”.

- Preserve real `egg_quantity` and `eggs_hatched` names and lossless bigint
  session mapping.
- Candidate RPC names remain `bridge_sync_authorize_v1`,
  `bridge_sync_ingest_v1`, and `bridge_sync_reconcile_v1`.
- Same original identity plus the same canonical content is an idempotent retry;
  changed content under the same identity conflicts, not a replacement event.
- Validate receipts and reconcile uncertain uploads without retrying physical
  Start. Cloud state/HTTP success is not proof of a physical transition.

**Not approved by this answer:** a complete payload/receipt/catalog revision,
exact canonical source adapter/hash implementation, source-field widths,
Kath's storage package/schema/support floor, Android outbox implementation,
transactional projections, persisted receipts, or deployment. Existing API
documents remain candidates; these answers do not ratify every field/paragraph.

The separately verified isolated target remains smarthatch-test
(`zbwntspdecngnicllwlw`). Previous narrow test authorization is preserved; it
does not expand to migrations, RLS changes, RPC activation or production access.

## D06 — completion independent of Stop: Mary's CHANGE REQUEST

**Exact answer:** “Separate completion from Stop”.

**Mary's proposal:** Save validated farmer-entered manual hatch results
independently of Stop evidence, without claiming or commanding physical Stop.

This conflicts with the current candidate in
`DB-02_Conflict_Receipt_And_Recovery.md` section 3: its `farmer_completed` row
requires an applied referenced Stop. The candidate SQL/fixtures/API/UI must not
be silently treated as compatible with Mary's proposed alternative.

**Joint disposition: PENDING KATH + ALLY REVIEW.** No completion behavior was
changed. This proposal does not approve:

- Automatically stopping/starting hardware or fabricating missing Stop evidence.
- Treating cloud `Completed` as proof that the controller is stopped or safe.
- Using a newly Completed cloud row to bypass the current physical-batch guard
  and start another batch while the controller could still be running.
- A concrete new-batch/Active-index, local draft, synchronization dependency,
  original completion-time or incomplete-source recovery rule. These still need
  exact joint lifecycle design and compatibility tests.

The safe action now is to record this as a requested candidate revision, not
remove Stop prerequisites from SQL, code, fixtures or contracts on Mary's behalf.

## Exact requests to Kath and Ally

**Kath:** Accept/change the non-anonymous protected-cloud installation direction;
provide the exact startup, secure-storage/session and direct-table migration
compatibility plan. For Mary's independent completion proposal, specify the
local draft/pending/saved UX and safe active/new-batch semantics with the backend.
No plugin/version or new UI behavior is chosen by this answer record.

**Ally:** Provide the exact controller/source identity and offline authorization,
retention/full-journal feasibility and remaining recovery facts. Review independent
farmer-result completion without interpreting it as physical Stop or admission
of another hardware batch. Do not infer hardware readiness from Mary's vote.

**Mary:** The four personal answers above are recorded. Exact source mapping,
complete API/receipt/hash dependency schema, enrollment mechanism and safe
implementation/migration scope remain to be agreed before implementation.

Ask each owner to reply ACCEPT / CHANGE / BLOCKED to those specific points,
with the actual matching source/catalog/document revision. Do not start another
architecture vote or call these personal responses a full freeze.

## Referenced candidate bytes (not signed/frozen revisions)

| Repository document | SHA-256 at this review |
|---|---|
| DB-02_Proposed_Schema_And_Security.md | `6322985031a82d25184bd0ebefc7e1a9016d74c22b7e8d587e94dafb16d3f230` |
| DB-02_Conflict_Receipt_And_Recovery.md | `08e6f97c7c320769e223218fbea7ce52a1d4a1b0ec5d117a83965d5678f39f06` |
| DB-02_Exact_Bridge_Sync_API.md | `5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab` |

These identify the inspected candidates; they are not a selected firmware packet,
joint acceptance, proof the user reviewed every byte, or approval of the conflicting
Stop prerequisite. Existing candidates are preserved unchanged as review history.

## Changes and verification boundary

Only this answer record, the main decision ledger's current answer cells, local
validation/evidence and full portal/report/handoff/import artifacts are updated.
No Supabase access or writes, Auth provisioning, SQL/Flutter/firmware changes,
deployment, Git commit, or additional task completion. D04 remains blocked in its
joint dependent scope; D06 remains awaiting joint exact mapping/lifecycle review.
Earlier no-answer reports remain historical and must not overwrite these replies.


## Current overall task counts

136 total records: ORIGINAL 32, OCT26 92, CURRENT 7, NEW 5. Mary Charlyn owns 42 (ORIGINAL 9, OCT26 31, CURRENT 2, NEW 0). Published counts: 7 Completed, 9 Partial, 25 Not started, 1 Superseded. 34 noncompleted nonsuperseded source records remain. Completed scope includes four existing architecture decisions, the two C-01 audits, and the independent OCT26:C-03 architecture review with new 13/13 targeted and 83/83 regression results. None of these reviews certifies secure cloud or physical integration. Remaining implementation/team/hardware gates are preserved; queue parking is not bulk status editing.

---

# Preserved preceding audit and execution records

# Supplemental audit evidence — CSVs (15)–(19) and supplied screenshots

**Task:** OCT26:C-01 · **Owner:** Mary Charlyn · **Status:** Completed audit,
with open security findings; no additional task status changed.

All five CSVs and eleven supplied screenshot panels were reviewed. Downloads
originals and screenshots were not edited. CSV bytes, SHA-256 hashes, every row,
checks and screenshot observations are retained in `supplemental-csv-review.json`.
Screenshots were visually reviewed from the conversation; their original image
files/byte hashes are not available to this local report.

## What the additional CSVs establish

| Export | Evidence | Important limitation |
|---|---|---|
| (15) | Four identity sequences owned by postgres; anon/authenticated USAGE and SELECT flags true | Sequence access alone does not prove table writes pass RLS. No sequence was advanced in this review. |
| (16) | Broad default grants for future tables/functions/sequences, including postgres-owned public objects; storage/extensions entries also present | Exactly **100 rows**: the export may be capped. Original SQL/limit must be checked before treating this as exhaustive. Default grants are role/schema/object-type specific and do not certify existing object access. Do not modify Supabase-managed storage defaults based on this sample. |
| (17) | anon/authenticated do not bypass RLS; postgres/service_role/supabase_admin do | Successful SQL Editor queries under postgres cannot establish ordinary-client isolation. These are exported role flags, not a fresh signed-token test. |
| (18) | Nine public objects owned by postgres: one helper function, four sequences and four tables | Ownership matches the independently targeted test catalog; not an installation/device ownership model. |
| (19) | authenticator can SET ROLE to anon/authenticated/service_role; memberships also listed for postgres | A normal platform role arrangement, not proof that any client can select service_role or that real JWT validation/revocation works. |

Five offline interpretation/consistency checks are run by
`review-supplemental-csvs.cjs`. No remote queries, database writes, auth
provisioning, policy/config changes or migrations are performed by this review.

## What the screenshots add

1. The selected project name is visibly **smarthatch-test**, improving context
   beyond the CSV filenames. Exact project ID/URL and execution identity/time
   are not shown; this does not automatically assign every CSV to a verified ref.
   The main-branch **PRODUCTION** badge does not mean the separate application
   project, egg incubator, was accessed.
2. Both private-schema lookups show no rows, including the pg_namespace lookup.
   This supports the observation that the proposed private registry/ledger
   schema was absent in the shown database at the time. Do not confuse the SQL
   Editor sidebar label “PRIVATE (18)” (private saved queries) with a database schema.
3. The corrected RLS query shows all four tables with RLS enabled and FORCE RLS
   false. The earlier error is a catalog-query mistake: pg_tables has no
   forcerowsecurity column. The correct fields are **pg_class.relrowsecurity**
   and **pg_class.relforcerowsecurity**, joined to pg_namespace. It does not
   require a schema migration to fix this inspection query.
4. `rls_auto_enable` is a SECURITY DEFINER event-trigger helper owned by postgres,
   with search_path=pg_catalog. Its null explicit ACL is **not** “no permissions”:
   PostgreSQL default function EXECUTE semantics must be considered. Event-trigger
   return type/context also differs from an ordinary Data API RPC. The screenshot
   showing 0/1 exposed functions is not a direct-RPC success/failure test.
5. The migration-history query returns SQLSTATE 42P01, and the namespace query
   shows no supabase_migrations schema. This establishes no history in that
   location in the shown database—not that no SQL or migration ever ran.
   Manual SQL, cloning/restoration or missing tracking are possible; no cause is
   established. Do not create a migration-history schema just to silence the query.
6. Data API settings show **public + graphql_public** exposed, **4/4 tables**,
   **0/1 functions**, automatic new-table exposure **on**, extra search path
   public/extensions and max rows 1000. This is useful configuration evidence,
   not a successful unauthorized-access test. Max rows 1000 is a Data API setting,
   not proof that the SQL Editor's separate 100-row export limit was absent.

## Effect on tasks and next work

These strengthen the two **already Completed audits**. They do not complete
secure ingestion, authorized installation enrollment, immutable event ledger,
the three RPCs, durable receipts/recovery or physical integration. A namespace
query returning no private schema supports an implementation gap, not completion
of creating that schema.

Keep the existing source/authorization gates disabled. No settings were toggled,
including automatic table exposure; changing that configuration or legacy
grants/policies needs separately scoped approval and compatibility review.
Kath/Ally-dependent decisions remain untouched.

The full HTML/report/handoff and additive import receive this distinct evidence
supplement without replacing earlier reports or changing saved browser statuses.
Existing counts remain 6 Completed, 7 Partial, 28 Not started and 1 Superseded
among 42 Cha-owned source records. New verification here is offline/static only;
earlier browser, live role-probe and physical-testing boundaries are unchanged.


---

# Latest audit completion assessment

LATEST STATUS CORRECTION: two audit tasks Completed; open security findings are not hidden. 136 total records: ORIGINAL 32, OCT26 92, CURRENT 7, NEW 5. Mary Charlyn owns 42 (ORIGINAL 9, OCT26 31, CURRENT 2, NEW 0). Published counts: 7 Completed, 9 Partial, 25 Not started, 1 Superseded. 34 noncompleted nonsuperseded source records remain. Completed scope includes four existing architecture decisions, the two C-01 audits, and the independent OCT26:C-03 architecture review with new 13/13 targeted and 83/83 regression results. None of these reviews certifies secure cloud or physical integration. Remaining implementation/team/hardware gates are preserved; queue parking is not bulk status editing.

# C-01 audit completion review — supplied SQL exports and verified evidence

## Outcome: two audit tasks Completed, not a blanket security pass

The earlier assessment incorrectly kept **audit work** Partial because the
**implementation being audited** still has security/integration problems.
Those are different acceptance criteria. Finding and recording a vulnerability
can complete an audit without fixing the vulnerability or passing deployment gates.

Both audit records below have now been checked individually against their actual
portal requirements. No other task inherits completion from this review.

| Task | Owner / priority | Initial → final | Exact acceptance and evidence |
|---|---|---|---|
| ORIGINAL:C-01 — Audit the current database schema | Mary Charlyn / P1 | Partial → **Completed** | Written audit based on actual schema, listing tables, columns, RLS/policies, grants, routines/RPCs and Edge Functions; risky policies explicitly identified. The independently targeted test catalog, prior application inventory (historical only), fresh test Edge Function listing, and this report meet that inventory/audit scope. |
| OCT26:C-01 — Complete Supabase schema, access-control, and integration audit | Mary Charlyn / P0 | Partial → **Completed** | Actual-schema inventory plus access-control findings and source-based integration gap assessment are documented. Its portal verification is “List tables, columns, policies”; acceptance is “Audit based on real schema”, not successful remediation, deployment or physical end-to-end operation. |

Neither task requires implementing the missing RPCs or obtaining a secure result
from every downstream integration test before the **audit** itself is finished.
Shared decisions remain prerequisites for those implementation tasks, not for
honestly documenting their absence. This is a scope correction, not fabrication.

## Nine supplied CSVs: fully read, hashed and cross-checked

| Supabase Snippet Untitled query export | Contents | Use / limitation |
|---|---|---|
| (6).csv | 13 RLS policies | Public/authenticated permissive policies; matches test catalog. |
| (7).csv | 8 table/role grant rows | Both roles have SELECT/INSERT/UPDATE/DELETE/TRUNCATE grants; privilege flags alone do not establish row-policy outcomes. |
| (8).csv | 1 routine privilege row | `public.rls_auto_enable`, security definer; not a bridge-sync RPC. |
| (9).csv | Function definition | Event-trigger helper enabling RLS on newly created public tables; not ownership restrictions or ingestion implementation. |
| (10).csv | 1 event trigger | `ensure_rls`, ddl_command_end, enabled; this property is supplied export evidence, not freshly re-queried event-trigger catalog proof. |
| (11).csv | 4 primary-key constraints | No extra ownership/batch/hatch-count CHECKs are established by this export. |
| (12).csv | 5 indexes | Includes the single-Active-session unique index; does not make Start physically confirmed/idempotent. |
| (13).csv | 22 columns across 4 tables | Names/types/nullability/defaults match the independently verified test catalog. |
| (14).csv | 4 identity columns | BY DEFAULT bigint IDs; null column_default is not proof that identity generation is absent. |

`supplied-csv-review.json` records every row and SHA-256. Eight offline consistency
checks passed. The original Downloads files were not changed. CSVs contain no
project ref, original executed SQL, execution role, trustworthy observation time,
or CRUD fixture outcomes. Their structural agreement with the test catalog does
**not** identify their original project. No production state is inferred from them.

## Independently verified database scope

TEST: `smarthatch-test`, `zbwntspdecngnicllwlw`,
`https://zbwntspdecngnicllwlw.supabase.co`. Target/isolation and actual catalogs
were verified in the retained approved run. Four public application tables:

- `active_settings`: 5 columns; no singleton/session ownership constraint found.
- `incubator_presets`: 5 columns; audit does not approve numerical profile rows.
- `incubator_sessions`: 8 columns; existing Active guard retained; no original
  controller/batch/command/installation linkage observed in this schema.
- `sensor_readings`: 4 columns; no measured/source/batch/installation identity.

All four application tables have RLS enabled, not forced, and broad client grants.
Thirteen permissive policies and broad default grants were recorded. The
`rls_auto_enable` helper corrects older historical inventory statements claiming
there were no public routines; its existence does not mean RLS is restrictive.

No `bridge_sync_authorize_v1`, `bridge_sync_ingest_v1`, or
`bridge_sync_reconcile_v1` was found in the verified test public/private catalog.
A new **read-only** `supabase.cmd functions list --project-ref
zbwntspdecngnicllwlw --output json` returned `[]`, saved in
`test-edge-functions-audit.json`. No deployments or production queries were made.
Managed Auth/Storage internals and external schemas are outside this audit scope.

The approved live sensor-role probe is separately logged: SELECT/INSERT allowed
for both anon/authenticated; UPDATE/DELETE affected zero rows. Its fixtures were
rolled back and a separate query confirmed zero remaining rows. These are real
database-role results, not JWT/Auth-session/revocation verification.

## Current integration audit: source evidence, not a runtime pass

- `lib/main.dart:16–29`: initializes Supabase and calls signInAnonymously when no
  session exists. No auth change was made.
- `lib/services/supabase_service.dart`: direct preset/session/settings/reading
  calls remain; no `.rpc()` call in the service. Session creation stores Active;
  that is not evidence of a physical controller Start.
- `supabase/functions/_shared/bridge-sync-supabase.mjs:53–64`: local HTTP adapters
  reference the three exact RPC names, not a deployed database implementation.
- `pubspec.yaml:10–17` and AndroidManifest: current direct dependencies lack a
  Classic SPP/SQLite implementation package and the manifest lacks Bluetooth
  permissions. This is source evidence, not an Android device test.
- Firmware variants/local serial formats are not automatically a selected
  canonical producer or a flashed-image identity. ACK/STATE/retained recovery,
  durable outbox, original time/identity mappings and physical end-to-end behavior
  remain unverified. No firmware or Flutter changes were made.

This completes documenting integration readiness/gaps; it does not complete
implementing integration. The approved Uno → HC-05 → Android → Supabase
architecture is preserved.

## Changes, errors, tests, remaining work

Changes: added this completion review, CSV row/hash/consistency evidence, targeted
read-only test Edge Function listing, and two separate Completed audit reports.
Updated only the working portal defaults for these two audit IDs, plus its
report/queue/handoff artifacts. Historical Partial attempts remain unchanged.
Other team members' statuses and saved browser records are not overwritten.

Tests: 8/8 offline CSV consistency checks passed. Read-only test Edge Function
listing succeeded with zero entries. Earlier live role/rollback logs are reused,
not rerun here. Portal syntax/structure/import checks run after publication are
recorded separately. No new Node backend/Flutter/hardware or JWT tests claimed.
One initial PowerShell metadata command had a pipeline syntax error before
reading CSV contents; it was corrected. No SQL failed in this review.

Remaining security remediation and secure-ingestion implementation are **not
Completed**. CURRENT:DB-IMP-01, installation authorization, real RLS/JWT negative
matrices, immutable event ledger/receipts/replay and physical integration retain
their own acceptance criteria. CSV privilege booleans do not satisfy those tasks.
Superseded tasks remain Superseded, not converted to Completed.

Kath/Ally dependencies are unchanged; see TEAM_APPROVALS_AND_LOCAL_PLAN.md.
Recommended next action: resolve the specific shared identity/source/receipt
decisions before dependent backend implementation. No subsequent task is started
by this evidence review.

If an existing browser has a saved Partial override, it remains yours: the
working HTML publishes Completed defaults but does not silently overwrite newer
saved task records. Merge the new reports and update those two task dropdowns
after review if needed. Report import intentionally does not auto-complete tasks.

## New targeted browser verification

An initially empty `http://localhost:8876` test origin displayed both audited
tasks as Completed, with 136 records, all eight tabs, correct source coverage,
and Cha counts of 6 Completed / 7 Partial / 28 Not started / 1 Superseded.
Startup wrote no storage keys. On the separate previously seeded synthetic
`http://127.0.0.1:8876` origin, reload preserved all storage byte-for-byte and
kept its deliberately saved Partial/Needs verification overrides while the task
defaults were Completed. User file-tabs/storage were not touched. Results:
`audit-completion-browser-results.json`. This is new targeted runtime evidence,
not a rerun of all earlier responsive/import tests or any backend integration.


---

# Preserved preceding attempts (statuses below are historical)

# Latest approved security-test result

LATEST APPROVED TEST: eight actual PostgreSQL role/RLS probes on smarthatch-test sensor fixtures. Both anon/authenticated SELECT and INSERT succeeded (security gap); UPDATE/DELETE affected zero rows. ROLLBACK and a separate zero-fixture check passed. No Auth users, schema/RLS changes, RPC activation, production access, deployment or commits. Task remains Partial; shared decisions unresolved. Earlier local-only reports below are historical and superseded as authorization restrictions for this narrow test only.

# Approved test-project security probe — OCT26:C-01

**Owner:** Mary Charlyn L. Aguirre · **Priority:** P0  
**Initial/final task status:** Partial → Partial; security acceptance **not met**.  
**Run:** `2026-10-29T19-29-38-293Z` (October 30 in Asia/Manila).

## Latest approval and stopping point

The user's explicit approval supersedes the earlier **local-preparation-only**
restriction for this narrowly scoped test. It does **not** approve schema/policy
changes, RPC activation, deployments, production access, commits, or decisions
owned jointly with Kath/Ally. Earlier reports are retained as historical attempts.

No further task was started. The audit remains Partial because intended secure
installation access is not implemented/verified. After observing the current
security gap, testing stopped without changing its policies or enrolling a
pretend authorized installation.

## Target and current implementation

- Reverified using current CLI account metadata: TEST `smarthatch-test`,
  `zbwntspdecngnicllwlw`, `https://zbwntspdecngnicllwlw.supabase.co`, ACTIVE_HEALTHY,
  not linked. The application project remains separately linked; no relinking or
  application SQL was performed.
- Fresh test-project catalog matched the earlier snapshot for application tables,
  columns, policies, grants, default ACLs, constraints and indexes. No unreviewed
  drift was adopted. Read-only preflight passed before writing fixtures.
- Four application tables/22 columns/13 policies remain in the catalog. The
  three `bridge_sync_*_v1` RPCs are still absent. Existing Flutter anonymous
  auth/direct-table behavior and source-ingestion gate were not changed.

## Actual remote test

One transaction acquired a NOWAIT write-conflicting lock on `sensor_readings`;
used a two-second lock timeout and twenty-second statement timeout; checked for
unknown noninternal triggers, foreign keys and exact fixture-ID collisions;
and tested only synthetic rows at explicit negative IDs. No sequence values,
session/Active records, settings, existing sensor values or Auth users were used.

`SET LOCAL ROLE` selected real PostgreSQL `anon` / `authenticated` roles.
`request.jwt.claims` contained a synthetic UUID, **not a signed JWT**. This is a
real database role/RLS exercise, not a real login, token validation, anonymous
Auth session, designated-installation, revocation or Android integration test.

| PostgreSQL role | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| `anon` | 2 fixture rows readable | 1 fixture inserted | 0 rows affected | 0 rows affected |
| `authenticated` | 2 fixture rows readable | 1 fixture inserted | 0 rows affected | 0 rows affected |

- **8 probes executed**, zero unexpected SQL errors.
- **4 allowed operations** (SELECT/INSERT for both roles) demonstrate the missing
  installation restriction on these tested sensor-row operations. This is a
  security finding against the intended scoped model, not a newly introduced
  regression or a claim about all tables.
- Four UPDATE/DELETE probes affected zero rows. No SQLSTATE 42501 was returned;
  do not describe them as privilege exceptions or a complete security pass.
- **Unconditional ROLLBACK executed.** A separate read-only exact-ID query
  confirmed **0 remaining fixture rows**.
- **Auth users created: 0.** No end-user/installation provisioning was necessary.
- No migrations, schema/RLS/grant changes, RPC activation, deployments, firmware,
  Flutter edits or Git commits.

Exact transaction fixture IDs are in the log; cleanup touched only this
transaction's three generated IDs. No broad deletion or cleanup of other work.

## Files, commands, evidence

New runner: `docs/integration/cha-execution/run-approved-security-test.cjs`.
It requires an explicit execute flag, hard-pins/excludes project refs, refreshes
catalogs, stops on schema drift, and logs sanitized results without credentials.

```powershell
node --check docs/integration/cha-execution/run-approved-security-test.cjs
node docs/integration/cha-execution/run-approved-security-test.cjs
node docs/integration/cha-execution/run-approved-security-test.cjs --execute-approved-probe
```

Actual evidence under
`docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/`:

- `verified-target.json`: current target/isolation metadata and approval boundary.
- `fresh-catalog.json`: actual preflight catalog response.
- `probe.sql` / `probe-results.json`: full rolled-back transaction and eight results.
- `verify-cleanup.sql` / `cleanup-results.json`: independent exact-ID absence check.
- `status.json`: SECURITY_GAPS_OBSERVED; eight probes, four allowed, four zero-row,
  no unexpected errors, verified rollback and no Auth users created.
- `cli-role-initialization-note.txt`: CLI emits “Initialising login role”. Its
  internal administrative role initialization is not independently audited;
  this is not a claim that absolutely no platform-side effect occurred.

The preceding successful preflight-only run is preserved in
`security-run-2026-10-29T19-29-18-577Z/`. An initial runner invocation failed while
quoting CLI arguments through cmd.exe and produced CLI help, not a SQL result.
The launcher was corrected to invoke the `.cmd` shim through PowerShell, without
changing execution policy; the failed log is preserved in its original run folder.

## Acceptance and what remains

| Acceptance area | Result |
|---|---|
| Fresh test target and schema verification | PASSED within logged catalog scope |
| Narrow real role/RLS fixture matrix | EXECUTED; sensor SELECT/INSERT security gap observed |
| Rollback of this probe and exact-ID absence | PASSED; not a transaction-safe bridge-sync implementation test |
| Intended installation-scoped security | FAILED / not implemented |
| Real signed JWT/Auth/revocation/authorized installation | NOT RUN / shared identity decisions unresolved |
| Other three application tables and ownership isolation | NOT RUN |
| Real RPCs, ledger, idempotency/concurrency/receipt recovery | BLOCKED; routines absent, contracts/implementation unresolved |
| New backend Node/Flutter regression suites | NOT RUN; no application/backend implementation changed |
| Physical HC-05/Uno/Android integration | REQUIRES PHYSICAL HARDWARE TESTING |

Kath must agree the concrete authentication/direct-table compatibility transition;
Ally must supply the canonical source identities/catalog and retained evidence.
Use `TEAM_APPROVALS_AND_LOCAL_PLAN.md` for the exact file/decision map. No missing
team answer was fabricated or replaced by this user's test authorization.

**Next:** obtain those specific shared decisions and review a separate security
remediation/test design. Do not silently apply SQL drafts or skip to another
task. The current approval does not authorize fixing permissive policies.

The complete HTML, task reports, handoff and additive report JSON are updated with
this separate stable-ID attempt; prior reports/statuses are preserved. Subsequent
portal checks are static unless explicitly recorded as new browser tests.


---

# Preserved earlier reports and handoff

# SmartHatch Cha backend task reports

Report date: 2026-10-30 (Asia/Manila). Database UTC observation: 2026-10-29T19:02:15.757871+00:00.

## Checkpoint and stopping point

Verified cha-branch2, clean initial worktree, HEAD 2d2622e; 035e842 immediately preceding. No commit, push, merge, stash, reset, deployment or application change.

136 total records: ORIGINAL 32, OCT26 92, CURRENT 7, NEW 5. Mary Charlyn owns 42 (ORIGINAL 9, OCT26 31, CURRENT 2, NEW 0). Published counts: 7 Completed, 9 Partial, 25 Not started, 1 Superseded. 34 noncompleted nonsuperseded source records remain. Completed scope includes four existing architecture decisions, the two C-01 audits, and the independent OCT26:C-03 architecture review with new 13/13 targeted and 83/83 regression results. None of these reviews certifies secure cloud or physical integration. Remaining implementation/team/hardware gates are preserved; queue parking is not bulk status editing.

## Execution queue

| ID | Priority | Published runtime status | Execution queue | Title |
|---|---|---|---|---|
| ORIGINAL:C-01 | P1 | Completed | Completed audit — open findings retained | Audit the current database schema |
| ORIGINAL:C-02 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Define JSON telemetry and command contracts |
| ORIGINAL:C-03 | P0 | Partial | Partial — remaining scope gated | Secure ESP8266 data ingestion |
| ORIGINAL:C-04 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Configure one authorized application device |
| ORIGINAL:C-05 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Test RLS and permission boundaries |
| ORIGINAL:C-06 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Prevent duplicate Start requests |
| ORIGINAL:C-07 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Preserve accurate timestamps and associations |
| ORIGINAL:C-08 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Save manual hatch counts and hatchability |
| ORIGINAL:C-09 | P1 | Partial | Partial — remaining scope gated | Handle stale readings and disconnections |
| OCT26:ARCH-01 | P0 | Completed | Completed (existing design evidence) | Confirm with adviser whether Bluetooth is the final communication module or only an alternative to Wi-Fi. |
| OCT26:ARCH-02 | P0 | Completed | Completed (existing design evidence) | Decide whether SmartHatch must upload readings to Supabase without the farmer's phone nearby. |
| OCT26:ARCH-03 | P0 | Completed | Completed (existing design evidence) | Agree on the final communication path: Bluetooth with phone bridge, ESP8266 Wi-Fi, or another approved gateway. |
| OCT26:ARCH-04 | P0 | Completed | Completed (existing design evidence) | Confirm that Arduino Uno remains responsible for independent incubation control. |
| OCT26:ARCH-05 | P1 | Partial | Partial — remaining scope gated | Record the architecture decision as a formal amendment to the K06 v0.3 contract. |
| OCT26:ARCH-06 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Share the updated K06 decision with all team members and their OpenCode sessions. |
| OCT26:C-01 | P0 | Completed | Completed audit — open findings retained | Complete Supabase schema, access-control, and integration audit. |
| OCT26:C-02A | P0 | Partial | Partial — remaining scope gated | Prepare provisional JSON/NDJSON communication contract. |
| OCT26:C-02B | P1 | Partial | Partial — remaining scope gated | Review provisional contract against Ally's A-01 findings. |
| OCT26:C-02C | P0 | Not started | Queued, not started — acceptance/dependencies gated | Finalize communication fields, validation rules, and message examples after team approval. |
| OCT26:C-03 | P0 | Completed | Completed independent local review | Review backend design against the final Bluetooth/Wi-Fi architecture. |
| OCT26:C-04 | P0 | Partial | Partial — remaining scope gated | Design secure telemetry ingestion without exposing privileged Supabase keys. |
| OCT26:C-05 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Confirm how one authorized Flutter installation will access SmartHatch data. |
| OCT26:C-06 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Verify species-specific incubation profiles in the database. |
| OCT26:C-07 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Fix or safely handle missing species-profile values; do not silently use Chicken defaults. |
| OCT26:C-08 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Implement or verify Start Pending, physical Start confirmation, and retry protection. |
| OCT26:C-09 | P0 | Partial | Partial — remaining scope gated | Verify correct timestamps, batch association, and stale sensor handling. |
| OCT26:C-10 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Verify manual hatch-count storage and hatchability calculation. |
| OCT26:C-11 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Test cloud synchronization, security rules, and disconnection recovery. |
| OCT26:TEST-01 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Test Arduino-to-Flutter communication using the approved transport. |
| OCT26:TEST-02 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Test secure Flutter/gateway-to-Supabase synchronization. |
| OCT26:TEST-03 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Test loss of Bluetooth/Wi-Fi and internet connections. |
| OCT26:TEST-04 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Confirm Arduino maintains safe independent operation during communication loss. |
| OCT26:TEST-05 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Test real physical Start, Stop, and restart behavior. |
| OCT26:TEST-06 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Test accurate sensor readings, timestamps, and freshness labels. |
| OCT26:TEST-07 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Test species-specific incubation settings. |
| OCT26:TEST-08 | P0 | Not started | Queued, not started — acceptance/dependencies gated | Test egg turning and hatching-stage transitions. |
| OCT26:TEST-09 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Test manual hatch-count entry and History persistence. |
| OCT26:TEST-10 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Complete farmer usability testing. |
| OCT26:TEST-11 | P1 | Not started | Queued, not started — acceptance/dependencies gated | Record genuine incubation and hatchability results without fabricated data. |
| OCT26:TEST-12 | P1 | Superseded | Superseded — do not execute | Prepare evidence for the comparative manual-versus-automated hatchability objective. |
| CURRENT:DB-IMP-01 | P0 | Partial | Partial — remaining scope gated | Implement DB-IMP-01: version-pinned bridge-sync adapter in an isolated environment |
| CURRENT:INT-IMP-01 | P1 | Partial | Partial — remaining scope gated | Coordinate INT-IMP-01: single evidence ledger and integration runbook |

Highest-priority readiness task selected: OCT26:C-01. Security/permission acceptance is blocked, so no subsequent task executed. Safe local preparation is not full eligibility or permission to bypass this stop.

## Actual audit attempt

Task ID: OCT26:C-01
Title: Complete Supabase schema, access-control, and integration audit.
Owner: Mary Charlyn L. Aguirre (Cha)
Priority: P0
Initial status: Partial
Final status: Partial — required real permission/integration tests BLOCKED; sequential execution STOPPED.

Existing implementation: preserved cha-branch2 HEAD 2d2622e and backup 035e842. Local bridge-sync HTTP ports, disabled source adapter, SQL drafts and fixtures exist; these are not deployed database implementation. Portal runtime already changes six supplied-evidence tasks to Partial; raw FINAL_DATA alone is not the displayed baseline.

Database environment: authenticated Supabase CLI projects list verified distinct refs: smarthatch-test zbwntspdecngnicllwlw (ACTIVE_HEALTHY), https://zbwntspdecngnicllwlw.supabase.co; application egg incubator suopuhgtwyqkpupzvdng (ACTIVE_HEALTHY), https://suopuhgtwyqkpupzvdng.supabase.co. Local .env URL host and linked project still point to the application project; neither was changed. All catalog SQL explicitly targeted the TEST ref. No application-project SQL or application/Auth row retrieval.

Tests/actual results: a BEGIN TRANSACTION READ ONLY / catalog SELECT / ROLLBACK query executed successfully via Management API, observed 2026-10-29T19:02:15.757871+00:00, transaction_read_only=on. Four public application tables, 22 columns, 13 policies, four identity sequences, five indexes and one public routine. No public/private bridge-sync RPC, event ledger or registry was observed. Table RLS is enabled but not forced; broad anon/authenticated grants and permissive policies remain. Session authenticated ALL and public insert/read/update policies are not installation-scoped. Broad default ACLs also remain. The single-active-session unique index exists; active_settings is not a singleton and is not linked to a session. Source/service still accesses tables directly; main.dart calls signInAnonymously; no lib RPC call found.

Acceptance: actual catalog inventory PASSED (test project only). Full access-control/integration acceptance NOT MET: no real authorized/anonymous/other-user/revoked-identity negative tests, rollback-write/concurrency/idempotency tests or Android integration. RLS enabled is not security verification. No security fix, migration, RPC activation or physical test performed.

Changes/files: added read-only catalog SQL/JSON, this execution report and generated full HTML/JSON/handoff plus local portal build/verification harness. No existing Flutter, firmware, SQL draft, migration, secret or historical report changed. Working portal adds this evidence without automatically importing reports or writing saved statuses.

Errors: first CLI query rejected --project-ref without --linked (no SQL ran); corrected command used BOTH --linked and explicit TEST --project-ref. PowerShell CLI shim was blocked; .cmd invocation required no execution-policy change. Docker engine is unavailable. CLI printed "Initialising login role..." before the successful query: no user/installation provisioning was requested, but CLI-internal role initialization side effects have NOT been independently audited; do not claim zero platform/auth side effects. No explicit data/schema/Auth provisioning SQL was submitted.

Blockers/remaining: security unresolved; real negative/write tests need explicit test-project approval and approved test identities. Do not auto-apply drafts or change legacy grants: current Flutter anonymous/direct-write compatibility requires Kath coordination. Exact producer/catalog/IDs/recovery, authorization and completion/Stop decisions remain unratified in local decision records. Ally must supply canonical firmware/catalog/build/time/profile evidence; Kath must supply matching Android HC-05, auth and durable outbox implementation. Hardware tests require separate safety clearance.

Recommended next action: approve a narrowly scoped isolated security-test plan and supply actual team decisions, then resume THIS audit. Do not skip to another task. Historical Node/Flutter counts remain prior evidence, not newly executed tests.

### Commands and results

- PASSED: supabase.cmd projects list --output json (distinct projects and active status; existing CLI account can list/query test catalogs). Account ownership/role scope beyond this access was not audited.
- PASSED: supabase.cmd db query --linked --project-ref zbwntspdecngnicllwlw --file docs/integration/cha-execution/2026-10-30-test-catalog.sql --output json
- NOT RUN/BLOCKED: actual role/JWT/RLS permission matrix, writes, concurrent duplicate/conflict, transaction-write rollback, RPCs, Auth provisioning. Query ROLLBACK is NOT a transactional write-rollback test.
- NOT RUN: new Node backend and Flutter suites (no backend/application source changed). Prior 64/64, 70/70 Node and 20/20 Flutter reports remain historical.
- REQUIRES PHYSICAL HARDWARE TESTING: HC-05/Uno/Android, RTC, actuators, recovery, end-to-end.
- Portal checks: see docs/integration/cha-execution/portal-static-results.json and portal-browser-results.json when present. Historical HTML verification is preserved as historical, not asserted for this new copy.

## Catalog findings

- public.active_settings: RLS=true, FORCE=false; owner=postgres
- public.incubator_presets: RLS=true, FORCE=false; owner=postgres
- public.incubator_sessions: RLS=true, FORCE=false; owner=postgres
- public.sensor_readings: RLS=true, FORCE=false; owner=postgres

All 13 catalog policies:

- active_settings: Anyone can insert active settings; roles=["public"]; INSERT; USING=null; CHECK=true
- active_settings: Anyone can read active settings; roles=["public"]; SELECT; USING=true; CHECK=null
- active_settings: Anyone can update active settings; roles=["public"]; UPDATE; USING=true; CHECK=null
- active_settings: Authenticated users can insert settings; roles=["authenticated"]; INSERT; USING=null; CHECK=true
- active_settings: Authenticated users can read settings; roles=["authenticated"]; SELECT; USING=true; CHECK=null
- active_settings: Authenticated users can update settings; roles=["authenticated"]; UPDATE; USING=true; CHECK=null
- incubator_presets: Anyone can read presets; roles=["public"]; SELECT; USING=true; CHECK=null
- incubator_sessions: Allow all for authenticated users; roles=["authenticated"]; ALL; USING=true; CHECK=true
- incubator_sessions: Anyone can insert sessions; roles=["public"]; INSERT; USING=null; CHECK=true
- incubator_sessions: Anyone can read sessions; roles=["public"]; SELECT; USING=true; CHECK=null
- incubator_sessions: Anyone can update sessions; roles=["public"]; UPDATE; USING=true; CHECK=null
- sensor_readings: Anyone can insert sensor readings; roles=["public"]; INSERT; USING=null; CHECK=true
- sensor_readings: Anyone can read sensor readings; roles=["public"]; SELECT; USING=true; CHECK=null

Public/private functions: public.rls_auto_enable. Exact RPCs absent: bridge_sync_authorize_v1, bridge_sync_ingest_v1, bridge_sync_reconcile_v1. This scope does not inventory managed Auth/Storage internals, Edge Function deployments or all external schemas.

## Complete Cha task inventory (source requirements preserved)

The embedded 29 Oct update affects runtime statuses/evidence after FINAL_DATA loads. The table above applies its six exact Partial overrides; detailed published requirements below preserve original data, with that baseline status correction. For the full supplied prompt/report additions, use the unchanged source library and task cards in the complete HTML.

## ORIGINAL:C-01 — Audit the current database schema

- Owner: Mary Charlyn; priority: P1; source: ORIGINAL; Current published status: Completed.
- Dependencies: []; linked requirements: ["CHA-01","CHA-04"]
- Preconditions: Supabase project access
- Acceptance: Audit based on real schema
- Verification: List tables, columns, policies
- Expected: Written audit of ACTUAL schema, RLS, grants
- Prompt: READ-ONLY audit of the actual Supabase schema, policies, grants, RPCs and edge functions. List risky open policies. Do not change anything or print secrets.
- Published evidence: Read-only Supabase catalog/source inventory reported 2026-10-27 in K06 v0.5. This does not establish full access-control/security/integration completion.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Verify remaining RLS, grants, identity, security and integration acceptance with isolated negative tests.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01","OCT26:C-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## ORIGINAL:C-02 — Define JSON telemetry and command contracts

- Owner: Mary Charlyn; priority: P1; source: ORIGINAL; Current published status: Not started.
- Dependencies: ["ORIGINAL:A-01"]; linked requirements: ["INT-01","INT-05","CHA-07"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Schema reviewed by Ally and Kath
- Verification: Validate sample messages
- Expected: Versioned schema doc (telemetry, START/STOP/STATUS, ACK, error)
- Prompt: Draft a versioned JSON contract with device_id, chamber, batch_id, command_id, sample_id, seq, measured_at (nullable), timestamp_valid, validity flags. Propose and ask me before finalizing.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Versioned schema doc (telemetry, START/STOP/STATUS, ACK, error)
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01","OCT26:C-02A"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## ORIGINAL:C-03 — Secure ESP8266 data ingestion

- Owner: Mary Charlyn; priority: P0; source: ORIGINAL; Current published status: Partial.
- Dependencies: ["ORIGINAL:C-01","ORIGINAL:C-02"]; linked requirements: ["CHA-01","INT-02"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Forged request rejected; valid accepted
- Verification: Valid vs forged requests
- Expected: Implement authorized Android bridge ingestion only in an approved isolated test environment; ESP8266 attribution is historical.
- Prompt: Implement secure Android bridge ingestion against the selected exact source contract; do not add ESP8266 firmware or privilege credentials in the app.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Authenticated ingestion path; no service-role key on device.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01","OCT26:C-04"]
- Reports: 29 Oct embedded local implementation report; supplied, not rerun. Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## ORIGINAL:C-04 — Configure one authorized application device

- Owner: Mary Charlyn; priority: P0; source: ORIGINAL; Current published status: Not started.
- Dependencies: ["ORIGINAL:C-01"]; linked requirements: ["CHA-01"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Second identity denied; revocation works
- Verification: Attempt access from a second identity
- Expected: One revocable app identity with least privilege.
- Prompt: Set up one authorized installation identity with least-privilege access. Not anonymous public access. Document how to revoke it.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: One revocable app identity with least privilege.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01","OCT26:C-05"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## ORIGINAL:C-05 — Test RLS and permission boundaries

- Owner: Mary Charlyn; priority: P0; source: ORIGINAL; Current published status: Not started.
- Dependencies: ["ORIGINAL:C-03","ORIGINAL:C-04"]; linked requirements: ["CHA-01"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Sanitized logs show allowed and denied
- Verification: Run each case as authorized, anon, other user
- Expected: SELECT/INSERT/UPDATE/DELETE matrix with real tests
- Prompt: Build and run an RLS test matrix against a TEST project. Report real results with sanitized logs.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: SELECT/INSERT/UPDATE/DELETE matrix with real tests
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## ORIGINAL:C-06 — Prevent duplicate Start requests

- Owner: Mary Charlyn; priority: P1; source: ORIGINAL; Current published status: Not started.
- Dependencies: ["ORIGINAL:C-02"]; linked requirements: ["CHA-03","INT-04","CHA-09"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Exactly one batch/Start
- Verification: Simulate double tap, timeout, restart
- Expected: Unique batch/command identity; pending state kept.
- Prompt: Make Start idempotent using batch_id/command_id. Keep Start Pending when hardware confirmation is missing and query status before retry.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Unique batch/command identity; pending state kept.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01","OCT26:C-08"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## ORIGINAL:C-07 — Preserve accurate timestamps and associations

- Owner: Mary Charlyn; priority: P1; source: ORIGINAL; Current published status: Not started.
- Dependencies: ["ORIGINAL:C-02"]; linked requirements: ["INT-05","CHA-07","CHA-06"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Never appears as B current
- Verification: Late batch A reading after B starts
- Expected: measured_at vs received_at separate; quarantine unknown batch.
- Prompt: Store measured_at (nullable), timestamp_valid, server received_at, device_id, batch_id. Quarantine unverifiable association.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: measured_at vs received_at separate; quarantine unknown batch.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01","OCT26:C-09"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## ORIGINAL:C-08 — Save manual hatch counts and hatchability

- Owner: Mary Charlyn; priority: P1; source: ORIGINAL; Current published status: Not started.
- Dependencies: ["ORIGINAL:C-02"]; linked requirements: ["CHA-02"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Failed saves leave batch active
- Verification: Test boundaries and duplicates
- Expected: Validated, idempotent completion; reread to confirm.
- Prompt: Implement completion: validate integer 0..eggs_set, compute hatchability server-side, update exactly the intended batch, return persisted values.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Validated, idempotent completion; reread to confirm.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01","OCT26:C-10"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## ORIGINAL:C-09 — Handle stale readings and disconnections

- Owner: Mary Charlyn; priority: P1; source: ORIGINAL; Current published status: Partial.
- Dependencies: []; linked requirements: ["CHA-08"]
- Preconditions: Measured cadence from Ally
- Acceptance: Each case classified correctly
- Verification: Fresh, late, invalid, missing cases
- Expected: Classification Fresh/Stale/Unavailable/Unknown.
- Prompt: Create the freshness classification. Threshold stays configurable until real cadence is measured; ask me for it.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Classification Fresh/Stale/Unavailable/Unknown.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01"]
- Reports: 29 Oct embedded local implementation report; supplied, not rerun. Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:ARCH-01 — Confirm with adviser whether Bluetooth is the final communication module or only an alternative to Wi-Fi.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Completed.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Preserve the established decision; do not reopen architecture. Verify physical implementation in the linked hardware/Android tasks.
- Prompt: Record the established K06 v0.5 design decision and link actual implementation evidence without reopening the decision.
- Published evidence: K06 v0.5 change-control table: design approved, 2026-10-27. DESIGN ONLY; not implementation or hardware verification.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: No architecture re-selection. Physical implementation verification remains separate.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DOC-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DOC-IMP-01; related=["CURRENT:DOC-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:ARCH-02 — Decide whether SmartHatch must upload readings to Supabase without the farmer's phone nearby.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Completed.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Preserve the established decision; do not reopen architecture. Verify physical implementation in the linked hardware/Android tasks.
- Prompt: Record the established K06 v0.5 design decision and link actual implementation evidence without reopening the decision.
- Published evidence: K06 v0.5 change-control table: design approved, 2026-10-27. DESIGN ONLY; not implementation or hardware verification.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: No architecture re-selection. Physical implementation verification remains separate.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DOC-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DOC-IMP-01; related=["CURRENT:DOC-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:ARCH-03 — Agree on the final communication path: Bluetooth with phone bridge, ESP8266 Wi-Fi, or another approved gateway.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Completed.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Preserve the established decision; do not reopen architecture. Verify physical implementation in the linked hardware/Android tasks.
- Prompt: Record the established K06 v0.5 design decision and link actual implementation evidence without reopening the decision.
- Published evidence: K06 v0.5 change-control table: design approved, 2026-10-27. DESIGN ONLY; not implementation or hardware verification.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: No architecture re-selection. Physical implementation verification remains separate.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DOC-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DOC-IMP-01; related=["CURRENT:DOC-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:ARCH-04 — Confirm that Arduino Uno remains responsible for independent incubation control.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Completed.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Preserve the established decision; do not reopen architecture. Verify physical implementation in the linked hardware/Android tasks.
- Prompt: Record the established K06 v0.5 design decision and link actual implementation evidence without reopening the decision.
- Published evidence: K06 v0.5 change-control table: design approved, 2026-10-27. DESIGN ONLY; not implementation or hardware verification.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: No architecture re-selection. Physical implementation verification remains separate.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DOC-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DOC-IMP-01; related=["CURRENT:DOC-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:ARCH-05 — Record the architecture decision as a formal amendment to the K06 v0.3 contract.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Partial.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Record the architecture decision as a formal amendment to the K06 v0.3 contract.
- Prompt: Record the architecture decision as a formal amendment to the K06 v0.3 contract.
- Published evidence: K06 v0.5 draft prepared; formal review/adoption/repository placement pending.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Record actual adoption/repository placement; no new architecture vote.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DOC-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DOC-IMP-01; related=["CURRENT:DOC-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:ARCH-06 — Share the updated K06 decision with all team members and their OpenCode sessions.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Not started.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Share the updated K06 decision with all team members and their OpenCode sessions.
- Prompt: Share the updated K06 decision with all team members and their OpenCode sessions.
- Published evidence: K06 v0.5: distribution pending; no newer distribution evidence supplied.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Distribute the actual baseline and portal with backup instructions; record recipients/date.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DOC-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DOC-IMP-01; related=["CURRENT:DOC-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-01 — Complete Supabase schema, access-control, and integration audit.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Completed.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: Audit based on real schema
- Verification: List tables, columns, policies
- Expected: Complete Supabase schema, access-control, and integration audit.
- Prompt: Complete Supabase schema, access-control, and integration audit.
- Published evidence: Read-only Supabase catalog/source inventory reported 2026-10-27 in K06 v0.5. This does not establish full access-control/security/integration completion.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Verify remaining RLS, grants, identity, security and integration acceptance with isolated negative tests.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["ORIGINAL:C-01","CURRENT:DB-IMP-01"]
- Reports: New 30 Oct audit below. Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-02A — Prepare provisional JSON/NDJSON communication contract.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Partial.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: Schema reviewed by Ally and Kath
- Verification: Validate sample messages
- Expected: Prepare provisional JSON/NDJSON communication contract.
- Prompt: Prepare provisional JSON/NDJSON communication contract.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Prepare provisional JSON/NDJSON communication contract.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["ORIGINAL:C-02","CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-02B — Review provisional contract against Ally's A-01 findings.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Partial.
- Dependencies: ["OCT26:A-01","OCT26:C-02A"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Review provisional contract against Ally's A-01 findings.
- Prompt: Review provisional contract against Ally's A-01 findings.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Review provisional contract against Ally's A-01 findings.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-02C — Finalize communication fields, validation rules, and message examples after team approval.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: ["OCT26:C-02B"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Finalize communication fields, validation rules, and message examples after team approval.
- Prompt: Finalize communication fields, validation rules, and message examples after team approval.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Finalize communication fields, validation rules, and message examples after team approval.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-03 — Review backend design against the final Bluetooth/Wi-Fi architecture.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Completed.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Review backend design against the final Bluetooth/Wi-Fi architecture.
- Prompt: Review backend design against the final Bluetooth/Wi-Fi architecture.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Review backend design against the final Bluetooth/Wi-Fi architecture.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-04 — Design secure telemetry ingestion without exposing privileged Supabase keys.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Partial.
- Dependencies: ["OCT26:C-01"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Forged request rejected; valid accepted
- Verification: Valid vs forged requests
- Expected: Design secure telemetry ingestion without exposing privileged Supabase keys.
- Prompt: Design secure telemetry ingestion without exposing privileged Supabase keys.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Design secure telemetry ingestion without exposing privileged Supabase keys.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["ORIGINAL:C-03","CURRENT:DB-IMP-01"]
- Reports: 29 Oct embedded local implementation report; supplied, not rerun. Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-05 — Confirm how one authorized Flutter installation will access SmartHatch data.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: ["OCT26:C-01"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Second identity denied; revocation works
- Verification: Attempt access from a second identity
- Expected: Confirm how one authorized Flutter installation will access SmartHatch data.
- Prompt: Confirm how one authorized Flutter installation will access SmartHatch data.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Confirm how one authorized Flutter installation will access SmartHatch data.
- Supersession/coverage: Equivalent execution scope; both source records retained; coveredBy=CURRENT:DB-IMP-01; related=["ORIGINAL:C-04","CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-06 — Verify species-specific incubation profiles in the database.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Not started.
- Dependencies: ["OCT26:SP-05"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Verify species-specific incubation profiles in the database.
- Prompt: Verify species-specific incubation profiles in the database.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Verify species-specific incubation profiles in the database.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-07 — Fix or safely handle missing species-profile values; do not silently use Chicken defaults.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Not started.
- Dependencies: ["OCT26:C-06"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Fix or safely handle missing species-profile values; do not silently use Chicken defaults.
- Prompt: Fix or safely handle missing species-profile values; do not silently use Chicken defaults.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Fix or safely handle missing species-profile values; do not silently use Chicken defaults.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-08 — Implement or verify Start Pending, physical Start confirmation, and retry protection.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: ["OCT26:C-02C","CURRENT:HW-IMP-01"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Exactly one batch/Start
- Verification: Simulate double tap, timeout, restart
- Expected: Implement or verify Start Pending, physical Start confirmation, and retry protection.
- Prompt: Implement or verify Start Pending, physical Start confirmation, and retry protection.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Implement or verify Start Pending, physical Start confirmation, and retry protection.
- Supersession/coverage: Equivalent execution scope; both source records retained; coveredBy=CURRENT:DB-IMP-01; related=["ORIGINAL:C-06","CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-09 — Verify correct timestamps, batch association, and stale sensor handling.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Partial.
- Dependencies: ["OCT26:C-02C"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Never appears as B current
- Verification: Late batch A reading after B starts
- Expected: Verify correct timestamps, batch association, and stale sensor handling.
- Prompt: Verify correct timestamps, batch association, and stale sensor handling.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Verify correct timestamps, batch association, and stale sensor handling.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["ORIGINAL:C-07","CURRENT:DB-IMP-01"]
- Reports: 29 Oct embedded local implementation report; supplied, not rerun. Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-10 — Verify manual hatch-count storage and hatchability calculation.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Not started.
- Dependencies: ["ORIGINAL:K-07"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: Failed saves leave batch active
- Verification: Test boundaries and duplicates
- Expected: Verify manual hatch-count storage and hatchability calculation.
- Prompt: Verify manual hatch-count storage and hatchability calculation.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Verify manual hatch-count storage and hatchability calculation.
- Supersession/coverage: Equivalent execution scope; both source records retained; coveredBy=CURRENT:DB-IMP-01; related=["ORIGINAL:C-08","CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:C-11 — Test cloud synchronization, security rules, and disconnection recovery.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: ["CURRENT:DB-IMP-01","CURRENT:UI-IMP-02"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Test cloud synchronization, security rules, and disconnection recovery.
- Prompt: Test cloud synchronization, security rules, and disconnection recovery.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Test cloud synchronization, security rules, and disconnection recovery.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY DB-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:DB-IMP-01; related=["CURRENT:DB-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-01 — Test Arduino-to-Flutter communication using the approved transport.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: ["OCT26:HW-08","CURRENT:UI-IMP-01","CURRENT:HW-IMP-01"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Test Arduino-to-Flutter communication using the approved transport.
- Prompt: Test Arduino-to-Flutter communication using the approved transport.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Test Arduino-to-Flutter communication using the approved transport.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-02 — Test secure Flutter/gateway-to-Supabase synchronization.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: ["CURRENT:DB-IMP-01","CURRENT:UI-IMP-02"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Test secure Flutter/gateway-to-Supabase synchronization.
- Prompt: Test secure Flutter/gateway-to-Supabase synchronization.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Test secure Flutter/gateway-to-Supabase synchronization.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-03 — Test loss of Bluetooth/Wi-Fi and internet connections.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Test loss of Bluetooth/Wi-Fi and internet connections.
- Prompt: Test loss of Bluetooth/Wi-Fi and internet connections.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Test loss of Bluetooth/Wi-Fi and internet connections.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-04 — Confirm Arduino maintains safe independent operation during communication loss.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: ["OCT26:HW-10","OCT26:A-06"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Confirm Arduino maintains safe independent operation during communication loss.
- Prompt: Confirm Arduino maintains safe independent operation during communication loss.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Confirm Arduino maintains safe independent operation during communication loss.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-05 — Test real physical Start, Stop, and restart behavior.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: ["OCT26:HW-10","CURRENT:HW-IMP-02"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Test real physical Start, Stop, and restart behavior.
- Prompt: Test real physical Start, Stop, and restart behavior.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Test real physical Start, Stop, and restart behavior.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-06 — Test accurate sensor readings, timestamps, and freshness labels.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Test accurate sensor readings, timestamps, and freshness labels.
- Prompt: Test accurate sensor readings, timestamps, and freshness labels.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Test accurate sensor readings, timestamps, and freshness labels.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-07 — Test species-specific incubation settings.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Not started.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Test species-specific incubation settings.
- Prompt: Test species-specific incubation settings.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Test species-specific incubation settings.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-08 — Test egg turning and hatching-stage transitions.

- Owner: Mary Charlyn; priority: P0; source: OCT26; Current published status: Not started.
- Dependencies: ["OCT26:HW-10","OCT26:A-08","OCT26:SP-05"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending. Verify scheduled turning and automatic species-specific lockdown with safe simulated transitions; approved timing/mechanical limits only. Simulation is not a completed incubation cycle.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Test egg turning and hatching-stage transitions.
- Prompt: Test egg turning and hatching-stage transitions.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Test egg turning and hatching-stage transitions.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-09 — Test manual hatch-count entry and History persistence.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Not started.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Test manual hatch-count entry and History persistence.
- Prompt: Test manual hatch-count entry and History persistence.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Test manual hatch-count entry and History persistence.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-10 — Complete farmer usability testing.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Not started.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Complete farmer usability testing.
- Prompt: Complete farmer usability testing.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Complete farmer usability testing.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-11 — Record genuine incubation and hatchability results without fabricated data.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Not started.
- Dependencies: ["NEW:PILOT-GATE-01","NEW:PILOT-LOG-01"]; linked requirements: ["K06 v0.5"]
- Preconditions: Required linked inputs below; source/test access and explicit authorization for live operations. Safe independent preparation can proceed in parallel.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Record genuine incubation and hatchability results without fabricated data.
- Prompt: Record genuine incubation and hatchability results without fabricated data.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Record genuine incubation and hatchability results without fabricated data.
- Supersession/coverage: Related work; not completion · COVERED IN PART BY INT-IMP-01; source acceptance still requires verification; coveredBy=CURRENT:INT-IMP-01; related=["CURRENT:INT-IMP-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## OCT26:TEST-12 — Prepare evidence for the comparative manual-versus-automated hatchability objective.

- Owner: Mary Charlyn; priority: P1; source: OCT26; Current published status: Superseded.
- Dependencies: []; linked requirements: ["K06 v0.5"]
- Preconditions: Only the relevant approved inputs; do not reopen selected HC-05/Android architecture.
- Acceptance: The exact requirement above is demonstrated by attributable evidence; unresolved inputs and untested cases remain explicitly pending.
- Verification: Record dated actual output and evidence at design, code, automated, physical or end-to-end level; no inferred PASS.
- Expected: Retired comparative objective; retain exact historical requirement. NEW:RESEARCH-OBJ-01 owns the updated objectives/methodology.
- Prompt: Preserve the original comparison wording as historical; use the current exact objectives and automation-evidence methodology.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Approved values and relevant source/test access must be available. Physical activation requires separate authorization and qualified safety clearance.
- Remaining: Do not execute an obsolete comparison as a current objective.
- Supersession/coverage: Superseded objective, not completed; coveredBy=none; related=["NEW:RESEARCH-OBJ-01"]
- Reports: Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## CURRENT:DB-IMP-01 — Implement DB-IMP-01: version-pinned bridge-sync adapter in an isolated environment

- Owner: Mary Charlyn; priority: P0; source: CURRENT; Current published status: Partial.
- Dependencies: []; linked requirements: ["v1.3 D02","v1.3 D04","v1.3 D06"]
- Preconditions: Team-filled D01–D06 record (currently PENDING); exact wire schema pinned; isolated test project approved
- Acceptance: Test logs plus explicit deployment blockers; no service-role key in Flutter; validation not weakened to fit incomplete firmware events
- Verification: Authorized, unauthorized, duplicate, content-conflict, wrong-source and retry fixture logs
- Expected: Migration/Edge Function patch (not deployed to production), test fixtures, ingestion stays CONTRACT_NOT_ENABLED until security and source-mapping gates pass
- Prompt: Mary Charlyn (Cha/Mary), BACKEND workstream: implement ONLY the approved version-pinned bridge-sync adapter/immutable receipt/reconciliation/security slice in separately authorized isolated test scope. Local fixtures/harness may prepare now with ingestion disabled. Exact source evidence depends on D01/D02, authority on D04, API/storage/dependency mapping on D06. No invented IDs/time/Start or permissive fallback. Preserve deployed egg_quantity/eggs_hatched and bigint session mapping. Test authorized/unauthorized/revoked/duplicate/changed-content/wrong-source/retry/lost-response cases. No production migration or deployment. INT-IMP-01 is your separate integration workstream, not a different teammate.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Exact source/catalog and typed lifecycle/recovery definitions; actual compile/memory/frame limits; offline authorization/retention boundary; approved profile/RTC policy; approved isolated test destination. Implement safe independent seams now; do not invent missing protocol.
- Remaining: Migration/Edge Function patch (not deployed to production), test fixtures, ingestion stays CONTRACT_NOT_ENABLED until security and source-mapping gates pass Safe independent preparation remains actionable.
- Supersession/coverage: Related work; not completion; coveredBy=none; related=["ORIGINAL:A-04","ORIGINAL:C-01","ORIGINAL:C-02","ORIGINAL:C-03","ORIGINAL:C-04","ORIGINAL:C-05","ORIGINAL:C-06","ORIGINAL:C-07","ORIGINAL:C-08","ORIGINAL:C-09","OCT26:C-01","OCT26:C-02A","OCT26:C-02B","OCT26:C-02C","OCT26:C-03","OCT26:C-04","OCT26:C-05","OCT26:C-06","OCT26:C-07","OCT26:C-08","OCT26:C-09","OCT26:C-10","OCT26:C-11"]
- Reports: 29 Oct embedded local implementation report; supplied, not rerun. Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.

## CURRENT:INT-IMP-01 — Coordinate INT-IMP-01: single evidence ledger and integration runbook

- Owner: Mary Charlyn; priority: P1; source: CURRENT; Current published status: Partial.
- Dependencies: []; linked requirements: ["v1.3 D01","v1.3 D06"]
- Preconditions: D01 record; each owner's commit and test log
- Acceptance: Failing tests each assigned to one owner; nothing marked passed without logs; no merge of incompatible branches
- Verification: Every PASS links to a log; one dry run with fake transport and test backend before any physical test
- Expected: One dated evidence ledger and message-family matrix (PASS / FAIL / NOT TESTED), integration runbook, shared fixture files
- Prompt: Mary Charlyn (Cha/Mary), INTEGRATION workstream: prepare one evidence-ledger/runbook and shared-fixture matrix, not another general audit. You also own DB-02/DB-IMP-01; there is no separate Cha or Mary to approve on behalf of. Pin actual D01 source/catalog/revision, collect Ally/Kath/your backend patches and real test output, align D02/D06 fixtures and coordinate a fake-transport/test-backend dry run after applicable gates. Every PASS needs command/source/log/limitation; otherwise NOT TESTED. Real hardware/cloud use needs D03/D04/D05 and separately authorized safety/test destination. Do not merge, deploy, flash or invent approvals.
- Published evidence: No completion evidence supplied for this exact scope.
- Blockers: Exact source/catalog and typed lifecycle/recovery definitions; actual compile/memory/frame limits; offline authorization/retention boundary; approved profile/RTC policy; approved isolated test destination. Implement safe independent seams now; do not invent missing protocol.
- Remaining: One dated evidence ledger and message-family matrix (PASS / FAIL / NOT TESTED), integration runbook, shared fixture files Safe independent preparation remains actionable.
- Supersession/coverage: Related work; not completion; coveredBy=none; related=["OCT26:TEST-01","OCT26:TEST-02","OCT26:TEST-03","OCT26:TEST-04","OCT26:TEST-05","OCT26:TEST-06","OCT26:TEST-07","OCT26:TEST-08","OCT26:TEST-09","OCT26:TEST-10","OCT26:TEST-11"]
- Reports: 29 Oct embedded local implementation report; supplied, not rerun. Browser-saved reports are not accessible from the HTML file and have not been read, replaced or migrated.


## Source integrity

Original HTML SHA-256: 06feb8b430c40438df8ba301f466eef5657807345fba49cc943875619ad428e4. Original remains unchanged. All sources in FINAL_DATA.sources are retained byte-for-byte in the working HTML. Generated artifacts are uncommitted. Browser backups are still necessary: a local HTML copy cannot package unseen browser localStorage.

## Follow-up: local preparation authorized; teammate decisions left untouched

Task ID: OCT26:C-01
Owner: Mary Charlyn
Initial/final status: Partial.
Follow-up scope selected by user: LOCAL PREPARATION ONLY. No new remote actions.
Prepared local security-test-plan.json and offline validator; 7/7 plan-safety assertions PASSED, plus Node syntax check. These are NOT real Auth/RLS/RPC tests. No team decision finalized and no SQL/Flutter/firmware changed. No new task started.

# Cha local preparation and targeted team approvals

## Current authorization

The user selected **Local preparation only**. This follow-up makes no remote
queries/writes, Auth provisioning, cleanup, migrations, RLS changes, activation,
deployment, commits or hardware changes. Earlier catalog evidence is reused,
not re-queried. OCT26:C-01 stays **Partial**; no next portal task is started.

Prepared `security-test-plan.json` and its offline safety validator. The plan
covers read/write identity boundaries, exact RPC names, disabled gates, and
future transaction/duplicate/conflict checks. It contains no runnable remote
test or credential. Validation proves only that the plan's safety constraints
are internally consistent—not that database security passes.

Run locally:

```powershell
node docs/integration/cha-execution/validate-security-test-plan.cjs
```

Results: `security-test-plan-validation.json`. Live cases remain NOT RUN or
BLOCKED_BY_TEAM_DECISIONS. No approved authorized-installation fixture is invented.

## Files needing Kath/Ally review of specific decisions

These are existing documents, not new implementation assignments. Do not ask them
to approve all files indiscriminately; record their attributable answer to the
specific interface/behavior they own. Mary also reviews backend decisions.

| Existing file | Who must review | What remains to agree |
|---|---|---|
| `docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md` | Kath + Ally + Mary | Record actual D01–D06 answers: canonical source/catalog, lifecycle/recovery, real byte/build limits, local/online authorization and retention, profile/time policy, and Android/cloud mapping. Existing pending rows were not filled here. |
| `docs/contract-review/INTEGRATION-CONTRACT-03_Shared_Decision_Register.md` | Kath + Ally + Mary | Close specific cross-component conflicts against one selected revision; no independent architecture re-selection. |
| `docs/contract-review/DB-02_Exact_Bridge_Sync_API.md` | Kath + Ally + Mary | Kath: request/receipt compatibility; Ally: original event/batch/command/sample identities and actual source fields. Preserve the exact three RPC names; unresolved wire mappings stay disabled. |
| `docs/contract-review/DB-02_Conflict_Receipt_And_Recovery.md` | Kath + Ally + Mary | Kath: immutable outbox, receipt reconciliation, local draft/completion handling; Ally: retained source evidence, replay and feasible retention/loss guarantee. Stop-versus-completion prerequisites need an explicit shared decision. |
| `docs/contract-review/DB-02_Proposed_Schema_And_Security.md` | Kath + Mary; Ally for source/local authority assumptions | Kath: transition from anonymous/direct-table access to scoped installation identity, startup and History compatibility. Ally: controller identity/provenance and offline command authority. SQL security remains Mary's implementation/review responsibility. |
| `docs/contract-review/K-03B-02_Chicken_Profile_Record.md` | Named profile approver + Ally, with Kath/Mary acknowledging mappings | Exact approved profile/capacity/clock/freshness values and source evidence. Kath/Ally agreement alone is not a substitute for the designated numerical-profile approver or physical safety clearance. |

The local `docs/C02-provisional-communication-contract.md` and
`docs/contract-review/Original-C02-candidate-1.md` are historical/provisional
contract candidates. Related JSON schemas/examples must match whichever exact
revision the team selects. Do not request blanket approval of conflicting
candidates or treat an old candidate as the chosen active wire catalog.

Some source packet names are references to Downloads attachments, not repository
files: `SmartHatch_Shared_Communication_Contract_v1.3_DECISION_READY_DRAFT.md`,
`UI-CONTRACT-03_Final_Compatibility_Decisions.md`, and
`HW-02_Exact_Wire_Message_Catalog.md`. The table above identifies actual repository
paths. External filenames alone do not establish the approved revision/hash or
that the file is currently present; request the exact matching packet from its owner.

## SQL drafts: review versus execution approval

- `supabase/drafts/DB-IMP-01_disabled_registry.sql`
- `supabase/drafts/DB-IMP-01_authorization_schema_draft.sql`
- `supabase/drafts/DB-IMP-01_bridge_sync_rpcs_draft.sql`

These stay **DO NOT APPLY**. Kath/Ally need to review their relevant assumptions
above, not author or approve every backend SQL line. Applying any draft also
requires Mary's explicit environment/action authorization and real isolated SQL
validation; teammate contract acceptance does not authorize deployment. Local
draft preparation is permitted, but unresolved identity/source/receipt semantics
are not finalized in this follow-up. No existing SQL draft was changed.

## Next action

Share the targeted table with Kath and Ally and obtain exact replies/attachments
for the unresolved interfaces. Until those replies and separately scoped remote
test authorization exist, retain the local test plan, keep ingestion disabled,
and leave the audit Partial. Do not skip to another task or mark mock/static
checks as real permission/integration acceptance.


The prior browser results describe the preceding copy. This follow-up adds read-only text and a second stable-ID report; rerun the structural verifier after generation.

## New portal verification · 2026-10-30

Actual desktop Chromium checks: PASSED after scoped portal fixes. 136 runtime tasks and unique task IDs; 42 Mary Charlyn tasks; effective statuses 4 Completed, 9 Partial, 28 Not started, 1 Superseded; Runtime DOM IDs unique and all internal hash links resolve; All eight tabs activate and show the corresponding panel; Startup/reload preserves synthetic newer own/team statuses, notes, legacy sh_status and saved reports; Owner filter shows 42 Cha tasks with Hide finished off; priority filter and selected-task search work; All 136 Copy Prompt handlers return the matching task ID; superseded TEST-12 returns historical notice; Report editor saves a synthetic report without changing task status; editing a report preserves identity; JSON file input preview and Merge import the generated report; repeated identical import skips it; Newer local report with conflicting stable ID preserved; one imported copy retained; repeated conflict import does not duplicate it; After fix, reports-only merge leaves sh_state_v2, sh_status, sh_ev, sh_readiness_final_v1 and sh_last_export byte-identical; Full-backup Blob payload has expected app/type/version, reports, state/notes, evidence and readiness; Reload retains the three synthetic test reports without startup duplication; All eight tabs at 320, 390, 768 and 1440 CSS-pixel iframe widths: 32/32 synchronous layout measurements with no page-wide overflow after scoped wrapping fix.

Errors/fixes (not hidden):
- First owner-filter assertion expected 42 while default Hide finished was on; observed 37 (4 Completed and 1 Superseded hidden). Harness corrected to disable Hide finished; 42 observed. Not an application defect.
- Initial reports-only import rewrote sh_state_v2 by persisting existing in-memory legacy alias normalization. Existing statuses/notes were not overwritten, but byte-identical check failed. Working copy now persists state/evidence only when incoming payload includes those fields; retest passed.
- Existing conflict-import logic could add another copy on each repeat. Working copy now recognizes a matching copyOf report and skips repeated identical conflict content; actual import/edit/reimport tests passed.
- requestAnimationFrame-based iframe harness timed out at 60 seconds. Its page was inspected, then reloaded to abandon pending harness; synchronous forced-layout checks used instead.
- Initial 320px evidence tab overflowed by 7px due to new unbroken queue-summary content. Scoped overflow-wrap:anywhere added to new execution section; all 32 width/tab checks passed afterward.

Boundaries:
- DOM-driven browser interaction, not a physical Android or real-phone usability test
- Clipboard handler payload captured, not OS clipboard persistence
- Export Blob payload inspected, not an operating-system download test
- Destructive Replace and report deletion deliberately not exercised
- No real user's browser storage inspected, cleared, imported into or changed
- Synthetic data retained on the isolated origin; no storage.clear or deletion used
- No backend Node/Flutter suites, SQL drafts, real JWT/RLS negative tests, migrations or hardware tests executed by these portal checks


# All remaining task preparation

# Remaining task workqueue — all 34 preparation workstreams opened

Generated by build-remaining-workqueue.cjs; preparation only

**Not a claim all 34 implementations were started or completed.** All 34 now have a task-specific preparation card, exact source acceptance/dependencies, evidence fingerprints, named decision links and three NOT RUN acceptance cases.

Published counts stay **7 Completed / 9 Partial / 25 Not started / 1 Superseded**. Preparation status and task completion are separate. Superseded task is excluded. No actual result, approval, external delivery or participant outcome is invented.

Read REMAINING_DECISIONS_ALL_OWNERS.md once; answer only applicable unresolved Q-IDs. See task cards for exact task closure. planned-test-records.json contains 102 NOT RUN cases, not 102 passes. CURRENT INT-IMP-01 still needs the specified actual fake-transport/test-backend dry run after matching inputs; this portfolio index is not that dry run.

| Task | Retained status | Work stage | Decisions | Artifact |
|---|---|---|---|---|
| ORIGINAL:C-02 | Not started | Preparation prepared; implementation gated | Q01, Q02, Q03 | [Task card](tasks/ORIGINAL_C-02.md) |
| ORIGINAL:C-03 | Partial | Preparation prepared; implementation gated | Q01, Q04, Q07, Q12 | [Task card](tasks/ORIGINAL_C-03.md) |
| ORIGINAL:C-04 | Not started | Preparation prepared; implementation gated | Q06, Q07, Q12 | [Task card](tasks/ORIGINAL_C-04.md) |
| ORIGINAL:C-05 | Not started | Preparation prepared; implementation gated | Q07, Q12 | [Task card](tasks/ORIGINAL_C-05.md) |
| ORIGINAL:C-06 | Not started | Preparation prepared; implementation gated | Q02, Q03, Q06 | [Task card](tasks/ORIGINAL_C-06.md) |
| ORIGINAL:C-07 | Not started | Preparation prepared; implementation gated | Q01, Q03, Q08 | [Task card](tasks/ORIGINAL_C-07.md) |
| ORIGINAL:C-08 | Not started | Preparation prepared; implementation gated | Q05, Q06, Q12 | [Task card](tasks/ORIGINAL_C-08.md) |
| ORIGINAL:C-09 | Partial | Preparation prepared; implementation gated | Q08 | [Task card](tasks/ORIGINAL_C-09.md) |
| OCT26:ARCH-05 | Partial | Preparation prepared; implementation gated | Q10 | [Task card](tasks/OCT26_ARCH-05.md) |
| OCT26:ARCH-06 | Not started | Preparation prepared; implementation gated | Q10, Q11 | [Task card](tasks/OCT26_ARCH-06.md) |
| OCT26:C-02A | Partial | Preparation prepared; implementation gated | Q01, Q03 | [Task card](tasks/OCT26_C-02A.md) |
| OCT26:C-02B | Partial | Preparation prepared; implementation gated | Q01, Q02, Q03 | [Task card](tasks/OCT26_C-02B.md) |
| OCT26:C-02C | Not started | Preparation prepared; implementation gated | Q01, Q02, Q03, Q04, Q05 | [Task card](tasks/OCT26_C-02C.md) |
| OCT26:C-04 | Partial | Preparation prepared; implementation gated | Q01, Q04, Q07, Q12 | [Task card](tasks/OCT26_C-04.md) |
| OCT26:C-05 | Not started | Preparation prepared; implementation gated | Q06, Q07, Q12 | [Task card](tasks/OCT26_C-05.md) |
| OCT26:C-06 | Not started | Preparation prepared; implementation gated | Q09, Q12 | [Task card](tasks/OCT26_C-06.md) |
| OCT26:C-07 | Not started | Preparation prepared; implementation gated | Q09, Q12 | [Task card](tasks/OCT26_C-07.md) |
| OCT26:C-08 | Not started | Preparation prepared; implementation gated | Q01, Q02, Q03, Q06 | [Task card](tasks/OCT26_C-08.md) |
| OCT26:C-09 | Partial | Preparation prepared; implementation gated | Q01, Q03, Q08 | [Task card](tasks/OCT26_C-09.md) |
| OCT26:C-10 | Not started | Preparation prepared; implementation gated | Q05, Q06, Q12 | [Task card](tasks/OCT26_C-10.md) |
| OCT26:C-11 | Not started | Preparation prepared; implementation gated | Q01, Q05, Q06, Q07, Q12 | [Task card](tasks/OCT26_C-11.md) |
| OCT26:TEST-01 | Not started | Preparation prepared; implementation gated | Q01, Q03, Q13 | [Task card](tasks/OCT26_TEST-01.md) |
| OCT26:TEST-02 | Not started | Preparation prepared; implementation gated | Q05, Q06, Q07, Q12, Q13 | [Task card](tasks/OCT26_TEST-02.md) |
| OCT26:TEST-03 | Not started | Preparation prepared; implementation gated | Q02, Q06, Q08, Q13 | [Task card](tasks/OCT26_TEST-03.md) |
| OCT26:TEST-04 | Not started | Preparation prepared; implementation gated | Q02, Q09, Q13 | [Task card](tasks/OCT26_TEST-04.md) |
| OCT26:TEST-05 | Not started | Preparation prepared; implementation gated | Q01, Q02, Q04, Q13 | [Task card](tasks/OCT26_TEST-05.md) |
| OCT26:TEST-06 | Not started | Preparation prepared; implementation gated | Q08, Q09, Q13 | [Task card](tasks/OCT26_TEST-06.md) |
| OCT26:TEST-07 | Not started | Preparation prepared; implementation gated | Q09, Q13 | [Task card](tasks/OCT26_TEST-07.md) |
| OCT26:TEST-08 | Not started | Preparation prepared; implementation gated | Q02, Q09, Q13 | [Task card](tasks/OCT26_TEST-08.md) |
| OCT26:TEST-09 | Not started | Preparation prepared; implementation gated | Q05, Q06, Q12, Q13 | [Task card](tasks/OCT26_TEST-09.md) |
| OCT26:TEST-10 | Not started | Preparation prepared; implementation gated | Q14 | [Task card](tasks/OCT26_TEST-10.md) |
| OCT26:TEST-11 | Not started | Preparation prepared; implementation gated | Q09, Q13, Q14 | [Task card](tasks/OCT26_TEST-11.md) |
| CURRENT:DB-IMP-01 | Partial | Preparation prepared; implementation gated | Q01, Q03, Q04, Q05, Q07, Q12 | [Task card](tasks/CURRENT_DB-IMP-01.md) |
| CURRENT:INT-IMP-01 | Partial | Preparation prepared; implementation gated | Q01, Q05, Q06, Q12, Q13 | [Task card](tasks/CURRENT_INT-IMP-01.md) |

## Real local checks

Fresh backend/fixture regression: 110/110 passed (includes 27 monitoring tests). C-02: 14 positive/65 negative/11 malformed-frame checks passed; manual-result 13 Ajv groups and 21 reference tests passed. These are local, overlapping software checks, not end-to-end/hardware/security completion. Logs and scope are in the retained evidence. No stand-alone full task became eligible for completion in this pass.

## Current source issues identified, not silently patched

- SRC-01 lib/services/supabase_service.dart:232–247 — Current completion path writes Completed and defaults end_date to DateTime.now; no returned-row confirmation in this method. Not the new result-only API and not proof of accepted original time. Coordinate with Kath; do not patch her Flutter here.
- SRC-02 lib/services/supabase_service.dart:287–295 — Current method selects global newest recorded_at with no controller/batch filter in this method. Caller/system acceptance must not assume original batch/source selection is implemented.
- SRC-03 lib/main.dart:207–221 — Unknown/legacy species display helper uses fixed temperature/humidity/day fallback values. This is local UI/source observation, not an authorized profile default or biological approval; unknown-target behavior requires Kath review.
- SRC-04 lib/main.dart:224–237 — Current helper substitutes DateTime.now for an unparseable session start_date. Do not call this preserved original Start or a completed truthful-time implementation; coordinated UI change remains pending.

## Blank collection forms

Use forms only after their scope/authorization is satisfied. Leave unknown/missing observations empty. consent/clearance and real source identity are required before applicable research/physical collection.


# One consolidated remaining-decision packet

Generated by build-remaining-workqueue.cjs; preparation only

## Read first

This is one batch for Mary, Kath, Ally and the named documentation/safety/research reviewers where needed. Do not send another general audit or SMTP/email draft. Preserve actual prior answers; respond only to missing choices/artifacts below. A forwarded proposal is not a signature or implementation permission. Cha and Mary are one person.

Mary M01–M07, Ally thirteen positions/four completion conditions, Kath exact C-02 CHANGE review, K06 classification/labels and selected HC-05/Android/Uno architecture are already recorded. ARCH-05 was explicitly confirmed NOT YET ADOPTED; request the actual scoped adoption action, not whether evidence already exists.

## Response format

For each applicable Q-ID: responder/role, date, exact input revision/hash, ACCEPT / CHANGE / BLOCKED, exact replacement or supplied artifact, scope, next owner. No implementation/physical pass inferred. Do not include credentials or personal participant data.

## Q01 — Existing artifacts and source selection

**Owners:** Ally / Kath / Mary

**Affects:** ORIGINAL:C-02, ORIGINAL:C-03, ORIGINAL:C-07, OCT26:C-02A, OCT26:C-02B, OCT26:C-02C, OCT26:C-04, OCT26:C-08, OCT26:C-09, OCT26:C-11, OCT26:TEST-01, OCT26:TEST-05, CURRENT:DB-IMP-01, CURRENT:INT-IMP-01

**Already answered — do not repeat:** HC-05/Android architecture selected; original/patched source identities and current limitations reported. Ally's thirteen positions/four completion conditions and Kath reviews are already received.

**Only needed now:** Ally states numeric START versus START_BATCH/CONFIRM supersession and sends ONE matching actual source/patch/catalog, raw fixtures/build/toolchain logs and reported Dart model. Ally supplies exact provisional-schema/example disposition; Kath reviews selected same bytes. Do not prepare another email draft or request SMTP.

## Q02 — Concrete lifecycle/recovery semantics

**Owners:** Ally / Kath / Mary

**Affects:** ORIGINAL:C-02, ORIGINAL:C-06, OCT26:C-02B, OCT26:C-02C, OCT26:C-08, OCT26:TEST-03, OCT26:TEST-04, OCT26:TEST-05, OCT26:TEST-08

**Already answered — do not repeat:** Deliberate Start; ACK/controller report/independent physical feedback/cloud/receipt distinct; no automatic physical Start replay.

**Only needed now:** Exact STOP admitted states/output/timer/identity/emergency behavior; read-only original outcome/current-state recovery; pending-Start lifetime/cancel rule; boot/RESET/selection/blank-corrupt-EEPROM and sensor-recovery transition/output table. Preserve legitimate existing-batch continuation separately from fresh-batch creation.

## Q03 — Identity/frame/layout feasibility

**Owners:** Ally / Kath / Mary

**Affects:** ORIGINAL:C-02, ORIGINAL:C-06, ORIGINAL:C-07, OCT26:C-02A, OCT26:C-02B, OCT26:C-02C, OCT26:C-08, OCT26:C-09, OCT26:TEST-01, CURRENT:DB-IMP-01

**Already answered — do not repeat:** Distinct original controller/installation/batch/command/event/sample identities; Android-generated original batch/command direction; measured example byte sizes supplied.

**Only needed now:** Exact encoding/width/generation/persistence/exhaustion and manifest binding; maximum RX/TX/parser/queue/service/stack budgets and fixtures. Reconcile uint32 host journal versus 16-byte batch/8-byte command layout; eight bytes do not fit four-byte AVR long. Do not treat RX ring, application buffer and HTTP ceiling as one limit.

## Q04 — Controller authority and bounded retention

**Owners:** Ally / Kath / Mary

**Affects:** ORIGINAL:C-03, OCT26:C-02C, OCT26:C-04, OCT26:TEST-05, CURRENT:DB-IMP-01

**Already answered — do not repeat:** No current controller auth; retention_ack:null; no HTTP/phone-forged release; proposed full/corrupt journal blocks new Start, not emergency safe action.

**Only needed now:** Feasible controller provisioning/key/replay/revocation/replacement threat model and measured crypto resources; exact critical-record retention/layout/full-corrupt/service-erasure/loss guarantee. Four-slot journal remains proposal/host-model only; app enrollment is not controller authentication.

## Q05 — Exact prepared manual-result API review

**Owners:** Kath / Mary

**Affects:** ORIGINAL:C-08, OCT26:C-02C, OCT26:C-10, OCT26:C-11, OCT26:TEST-02, OCT26:TEST-09, CURRENT:DB-IMP-01, CURRENT:INT-IMP-01

**Already answered — do not repeat:** Mary M01–M07 confirmed; Ally's four conditions received; result alone retains Active and does not set Completed. Corrections/finalization deferred for prototype.

**Only needed now:** Kath returns actual ACCEPT/CHANGE/BLOCKED against DB02 manual-result 0.1 fields/time/eight-field core/fixtures/receipt/lookup, not another promise or duplicate seven-item proposal. Resolve result_recorded vs event-applied, fixed revision 1 vs mutable receipt, real-mapping precondition vs waiting/null mapping, and draft action identity reuse at seal. Confirm future outer/nested receipt tuple guard and retryable-by-code hardening without silently replacing shared 0.1 bytes. Mary answers only concrete changes, not repeats confirmed principles.

## Q06 — Concrete local storage and test scope

**Owners:** Kath / Mary

**Affects:** ORIGINAL:C-04, ORIGINAL:C-06, ORIGINAL:C-08, OCT26:C-05, OCT26:C-08, OCT26:C-10, OCT26:C-11, OCT26:TEST-02, OCT26:TEST-03, OCT26:TEST-09, CURRENT:INT-IMP-01

**Already answered — do not repeat:** Durable original intent; atomic result/outbox and receipt/mapping commits; no destructive recovery; no hardware commands in cloud outbox.

**Only needed now:** Explicit selection or replacement of candidate sqflite_sqlcipher 3.4.1 / flutter_secure_storage 11.2.0 and API-30 pilot floor after actual device/SDK inventory. Proposed schema, key/device-auth/backup/migration policy and native compatibility/security test scope; no installation or Flutter edits inferred. Exact failure handling/lease ownership/actor singleton behavior required.

## Q07 — Enrollment/session/recovery mechanism

**Owners:** Mary / Kath

**Affects:** ORIGINAL:C-03, ORIGINAL:C-04, ORIGINAL:C-05, OCT26:C-04, OCT26:C-05, OCT26:C-11, OCT26:TEST-02, CURRENT:DB-IMP-01

**Already answered — do not repeat:** Admin-controlled non-anonymous restricted cloud enrollment, per-operation scope, no privileged Android key; preserve committed evidence; cloud revocation not physical Stop.

**Only needed now:** Real admin/support recipient; supported bootstrap/activation and whether proposed 30-minute expiry is accepted; verified session/refresh/relogin reapproval semantics; separate evidence/session keys; local-owner authenticated offline access; logout-in-flight, replacement/uninstall/key-loss behavior and scoped historical grants. No real account provisioned until separately approved.

## Q08 — Measured cadence and exact numerical policy

**Owners:** Ally / Mary / Kath

**Affects:** ORIGINAL:C-07, ORIGINAL:C-09, OCT26:C-09, OCT26:TEST-03, OCT26:TEST-06

**Already answered — do not repeat:** K06 INT-05/CHA-07/CHA-08 already define classes/labels, no receipt-time repair, correct batch association, non-live last-known and disconnection separate from Stop. Local monitoring 27/110 tests exist.

**Only needed now:** Ally supplies attributable selected-source acquisition/send/transport-delay/clock evidence. Mary proposes exact numerical stale/skew policy from that evidence; Kath confirms composition/display tests. Set source elapsed/outage/invalid-clock continuity without inventing UTC. Do not repeat labels or treat arbitrary TEST budgets as agreed policy.

## Q09 — Profile/capacity approval

**Owners:** Named profile/adviser approver (not yet identified) / Ally / Mary / Kath

**Affects:** OCT26:C-06, OCT26:C-07, OCT26:TEST-04, OCT26:TEST-06, OCT26:TEST-07, OCT26:TEST-08, OCT26:TEST-11

**Already answered — do not repeat:** Candidate Chicken values/version already supplied; no need for Ally to restate or invent values. Physical scope Chicken-first; other species not biological verification.

**Only needed now:** Identify authorized numerical approver and obtain actual existing profile/version/capacity/stage/safety acceptance with provenance. Resolve stated humidity-source conflict. Then compare actual DB/settings/firmware values in separately approved scope; do not silently correct production rows or adopt UI 6–12 as physical proof.

## Q10 — Formal amendment adoption

**Owners:** Mary / Kath / Ally / Cla / responsible document reviewers

**Affects:** OCT26:ARCH-05, OCT26:ARCH-06

**Already answered — do not repeat:** ARCH-01–04 are reported design-approved. Actual v0.3/v0.4 now byte-preserved in repository. User explicitly answered Not yet adopted.

**Only needed now:** Perform the missing scoped review/adoption of identified K06 amendment bytes; record actual reviewer names/date/revision and any requested changes. Do not ask again whether old approval exists, reopen HC-05 architecture, or call prepared record adopted.

## Q11 — Delivery/session acknowledgment

**Owners:** Mary / Kath / Ally / Cla

**Affects:** OCT26:ARCH-06

**Already answered — do not repeat:** User reports files sent to Kath and Ally. ZIP preparation and an email draft are not external delivery; not all architecture/adoption distribution is established.

**Only needed now:** Record actual adopted architecture document/version sent to all required recipients and their AI sessions, including Cla, with actual acknowledgment where required. No email addresses or SMTP secrets requested by this packet.

## Q12 — Separately scoped database/security implementation permission

**Owners:** Mary / authorized test-project owner / Kath

**Affects:** ORIGINAL:C-03, ORIGINAL:C-04, ORIGINAL:C-05, ORIGINAL:C-08, OCT26:C-04, OCT26:C-05, OCT26:C-06, OCT26:C-07, OCT26:C-10, OCT26:C-11, OCT26:TEST-02, OCT26:TEST-09, CURRENT:DB-IMP-01, CURRENT:INT-IMP-01

**Already answered — do not repeat:** Isolated target smarthatch-test zbwntspdecngnicllwlw; prior narrow role probe allowed. Main-project protection and existing data preservation remain.

**Only needed now:** After exact choices, explicitly approve only the named test identity/fixture/migration/RLS/RPC/endpoint operations actually needed, with rollback/cleanup and readback proof. Existing narrow probe permission does not authorize schema changes, new account provisioning, enabling ingestion or production access. Until then use local tests/plans only.

## Q13 — Actual integration/physical test prerequisites

**Owners:** Qualified electrical/safety reviewer / Ally / Cla / Mary / Kath

**Affects:** OCT26:TEST-01, OCT26:TEST-02, OCT26:TEST-03, OCT26:TEST-04, OCT26:TEST-05, OCT26:TEST-06, OCT26:TEST-07, OCT26:TEST-08, OCT26:TEST-09, OCT26:TEST-11, CURRENT:INT-IMP-01

**Already answered — do not repeat:** Pilot NO-GO; no verified flashed image/empty-incubator run; egg loading postponed. Software/build/model is not physical proof.

**Only needed now:** Identify real board/flashed image/HC-05/RTC/reference instruments/Android device and responsible operator; approved test plan, qualified clearance and controlled scope before any wiring/flashing/energized loads/power-cut/egg test. Prepare but do not execute physical steps from this packet.

## Q14 — Usability and real outcomes

**Owners:** Mary / Cla / research lead / Adviser / required research approver

**Affects:** OCT26:TEST-10, OCT26:TEST-11

**Already answered — do not repeat:** No real participant sessions or incubation outcomes can be fabricated; safe simulator work must be labelled.

**Only needed now:** Name research owner, obtain applicable participant/consent/study approval and schedule actual sessions; separately approve actual-cycle observation method after physical gates. Supply actual observations/data when collected. Blank forms and synthetic arithmetic are not usability or hatchability results.

## Authorization boundary

This packet authorizes no package installation, Flutter/firmware edits, account provisioning, database operation, migration/RLS/RPC activation, deployment, flashing, wiring, energized-load/egg test or study participation. Approval requests require separate exact scoped consent and prerequisites. Actual adoption, delivery and participant records cannot be simulated.
