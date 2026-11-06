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
