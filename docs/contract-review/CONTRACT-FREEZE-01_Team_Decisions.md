# CONTRACT-FREEZE-01 — One-round team decisions

**Coordinator:** Cha · **Backend owner:** Mary · **Date/deadline:** 2026-10-28
**Status:** ANSWERS REQUIRED — NOT A FROZEN OR APPROVED CONTRACT

Purpose: ratify v1.3 section 4 defaults once, record actual answers, then unlock
only the corresponding implementation slices. This sheet is not a new contract
or compatibility audit. No code, firmware, SQL, Auth, deployment or portal changes.

## 1. Same-revision inputs

External root **Downloads**: `C:\Users\Mary Charlyn\Downloads\`.
All four required documents were read in full; existing findings were reused.

| Source | Decision evidence used |
|---|---|
| Downloads / `SmartHatch_Shared_Communication_Contract_v1.3_DECISION_READY_DRAFT.md` | v1.3 candidate, 2026-10-28: section 4 lines 76–102 defaults and PENDING answers; section 5 lines 104–116 task IDs; sections 6–7 fallback/separate gates |
| [INTEGRATION-CONTRACT-03_Shared_Decision_Register.md](INTEGRATION-CONTRACT-03_Shared_Decision_Register.md) | 0.1-review: section 6 D01–D06, sections 5/8 existing technical limitations and owner actions; no new audit |
| Downloads / `UI-CONTRACT-03_Final_Compatibility_Decisions.md` | Kath, 2026-10-28: CHANGES REQUESTED; sections 6/10 cloud/local choices and required answers; not an approval |
| Downloads / `SmartHatch_Oct28-30_Implementation_Handoff.md` | lines 7–16 one 45-minute round; owner prompts lines 18–56; evidence-limited fallback lines 58–63 |

**Calculated input fingerprints, not approved/frozen revision hashes:**

| Read source | Raw SHA-256 calculated locally |
|---|---|
| v1.3 draft | `70987831890edb16daaccfb47f7188061b41c5ea66658ac45fe4866cd1074f66` |
| Integration register | `9ff4344b72c6005053ce0221212ca09806fc45466b0f9acbfc85f6d63643d2ec` |
| UI-CONTRACT-03 | `de32c32521e1c1503d78d013e2ff3ecf91de1c8dcf2e2ed20cb3f1c3eff50c2c` |
| Oct28–30 handoff | `15b0caf6a517153d7fb14cc5743737aae9c1e36ce5852cbdf640698ab807fa26` |

v1.3 is the source of defaults. Its references to K06 v0.5 or another catalog
are not proof those artifacts/values were ratified. No source manifest/sketch,
build, physical flashed identity, profile value or author sign-off is selected
by this sheet. Record selected files/hashes only from actual team answers.

## 2. Six decisions — fill actual answers, not inferred approval

**AGREED:** exact choice/required values and revision accepted by responsible
members, with attributable answers. **NEEDS ANSWER:** team selection/sign-off
missing. **BLOCKED:** required technical value/evidence or policy is missing;
record the owner, deliverable and reduced demo scope instead of pretending it
passed. Agreement with a general direction does not settle an unresolved exact
schema/limit/key/profile. No automatic AGREED on accepting OpenCode's suggestion.

| ID/topic | Recommended default already in v1.3 | Exact choice/values required in this round | Existing evidence / limitation | Responsible answer/sign-off | Team's actual answer | Status | Implementation unlocked after sufficient agreement |
|---|---|---|---|---|---|---|---|
| D01 — baseline | HC-05/Android primary, USB diagnostics; prefer earlier batch-aware catalog, not actuator-only replacement | Select canonical remote, development branch/commit/sketch, actual sketch SHA-256, core/toolchain and catalog revision/hash. Flashed identity may honestly be UNKNOWN. Confirm same source packet for all owners. | v1.3:82; UI-03 §1/§9 and Integration B01: sketch/catalog lineage differs; README is not selection or flash proof. | Ally supplies manifest; Kath + Mary accept; Cha records | PENDING — no D01 team answer supplied | NEEDS ANSWER | HW-IMP-01 baseline/build setup; schema pin for UI-IMP-01, DB-IMP-01 and INT-IMP-01 |
| D02 — lifecycle/identity/recovery | Explicit START/STOP, read-only STATUS/STATE, original batch/command/event IDs, ACK not transition, no blind retry; bounded recovery if feasible | Accept earlier batch-aware basis or identify a complete alternative; attach exact fields/types/ID widths, duplicate-content and rejection rules, persistent original manifest, current-vs-history recovery and replay scope. If replay infeasible, state exact lost-event cases accepted by all. | v1.3:83; Integration B02–B05/B08 and UI-03 R08–R18: missing/contradictory exact messages and retained recovery. A policy yes without catalog is not a byte-level freeze. | Ally leads; Kath + Mary accept; Cha records exact revision | PENDING — no D02 team answer supplied | NEEDS ANSWER | HW-IMP-01 behavior, UI-IMP-01 decoder, HW-IMP-02 recovery and DB-IMP-01 source adapter; remaining gates still apply |
| D03 — bytes/build | JSON-LF only if actual memory/service feasibility supports it; ring64 is not complete-frame limit; no arbitrary binary switch | Supply or assign exact missing proof: full maximum fixtures, RX/TX/parse bounds including delimiter treatment, widths, service budget, true compile/link/ELF/HEX/size and stack estimate. Choose a bounded multi-frame alternative only if evidence requires it, with exact approved schema. | v1.3:84; Integration B06/B07; UI-03 §5: counts are literals, memory unverified, exit0/unused input is not a build. No new measurements here. | Ally provides proof; Kath validates Android bounds; Mary accepts mapping | PENDING — no D03 team answer or new build/limit evidence supplied | BLOCKED | HW-IMP-01 parser/build and UI-IMP-01 real byte bounds; HW-IMP-02 memory budget. A failing build becomes a named blocker, not another broad review |
| D04 — trust/release | One provisioned Android installation; separate offline command authority and authenticated cloud uploader; retention_ack:null; no auto-release | Agree feasible local provisioning/revocation/threat model and online authorization/session scope; choose bounded journal/service retention + exact accepted loss cases OR feasible verified server release. Specify journal-full safe behavior and demo restriction when unavailable. Never use placeholder MAC/phone HTTP result as source release. | v1.3:85 and C-07/C-08; Integration B09/B10: offline auth and Uno-verifiable receipt proof not supplied. Online revocation cannot instantly reach an offline link. | Ally local + Mary cloud; Kath setup/storage/UX; Cha records loss guarantee | PENDING — no D04 team answer or accepted authority/loss policy supplied | BLOCKED | HW-IMP-01/02 authority/retention and DB-IMP-01 auth tests; live Start/ingestion stay disabled until implementation/security gates pass |
| D05 — Chicken/profile/time | Chicken fresh-egg physical pilot only; manual hatch count; unknown RTC remains unknown; no invented numeric profile | Name designated approver and exact approved Chicken profile/version (heat/humidity/stages/turning/safety values), real quantity bounds, RTC/module, invalid-clock Start rule, outage elapsed-day rule and sensor validity/freshness. If unavailable, choose mock/non-powered demo, not guessed settings. | v1.3:86,31–34; Integration B11; UI-03 R19–R21/R30: UI6..12 is source behavior, not approved capacity; profile/RTC/skew/cadence unapproved. | Ally + named profile approver sign; Kath + Mary acknowledge mappings; Cha records | PENDING — approver/name/values and D05 team answer not supplied | BLOCKED | HW-IMP-01 readiness, HW-IMP-02 clock policy, UI day/reading display, DB time/profile validation. Powered/egg tests still need separate clearance |
| D06 — local/cloud mapping | SQLite intent/dispatch/evidence/outbox; Mary's idempotent bridge-sync candidate; preserve real DB names; cloud cannot initiate physical Start | Confirm source adapter/catalog revision, exact API/receipt/hash/dependency/session mapping, approved local package/support floor and online auth/RLS test scope. Decide Stop prerequisite vs local manual-count draft/pending handling and new-batch lifecycle. Name isolated test destination and choose mocked/read-only fallback if migrations/security are not ready. | v1.3:87; UI-03 §6/R25–R29 and Integration B12: source adapter mismatch; manual completion's Stop dependency needs explicit choice. No test project or migration authorization inferred. | Mary + Kath lead; Ally checks source facts; Cha records | PENDING — no D06 team answer supplied | NEEDS ANSWER | UI-IMP-02 durable transactions, DB-IMP-01 adapter/receipts/security, INT-IMP-01 shared fixtures. Deployments remain separately gated |

**Actual D01–D06 agreements recorded: NONE.** Existing architecture/scope directions
are carried forward as requested, not reopened; they are not new answers to the
six exact freeze choices. No v1.3 approval or successful technical test is inferred.

## 3. Copy/paste: one focused group-chat round

**Team: please answer these six questions against the SAME v1.3 draft in one
45-minute session today.** Reply `ACCEPT DEFAULT + exact details/attachment`,
`CHANGE + exact replacement`, or `BLOCKED + missing item + owner + next delivery
time + smaller demo scope`. Do not send credentials or a new general audit.

1. **D01 — All; Ally supplies details:** Keep HC-05/Android, USB diagnostics and
   the earlier batch-aware catalog as our basis? Ally: name the exact sketch,
   branch/commit, core/toolchain and attach its source/catalog hash manifest;
   mark flashed firmware UNKNOWN if unproven. Kath/Mary: accept the same packet?
2. **D02 — Ally, Kath, Mary:** Agree deliberate Start/Stop, read-only check,
   original IDs, ACK not Running and no blind retry? Which exact catalog/schema
   revision implements that? Choose bounded retained recovery, or explicitly list
   which lost events/reinstall cases we accept if it cannot fit.
3. **D03 — Ally, checked by Kath/Mary:** Can JSON-LF fit the selected firmware
   with exact maximum RX/TX frames and a genuine linked build? Give measured
   limits/artifact, or the precise failed/missing proof and owner. No automatic
   64-byte frame limit or binary switch; mock demo if feasibility remains blocked.
4. **D04 — Ally + Mary + Kath:** How is this phone authorized locally and online?
   Keep retention_ack:null and no automatic event erasure? Name the feasible
   provisioning/revocation and bounded retention/service or verified-release
   choice, including exact accepted loss limits. If absent, live Start/ingest off.
5. **D05 — Ally + designated profile approver; Kath/Mary acknowledge:** Who signs
   the Chicken profile/version and actual quantity/safety limits? Attach approved
   values and RTC/invalid-clock/outage-day/reading-age policy. If not ready, which
   non-powered/mock scope will we demonstrate instead? Do not guess the values.
6. **D06 — Mary + Kath; Ally checks evidence:** Accept the SQLite outbox plus
   idempotent bridge-sync direction? Pin exact adapter/API/receipt revisions,
   storage package/support floor, isolated test destination/auth scope, and the
   Stop-versus-manual-count draft/completion rule. If cloud security/migrations
   are not ready, confirm the mocked/read-only demo scope.

**Reply header:** member / date-time-timezone / exact v1.3 revision or input hash.
Each responsible member must answer their rows. A lead's recommendation does not
supply another member's sign-off. Cha will consolidate exact answers here; no
fresh general review document is requested from anyone.

## 4. Actual answer and sign-off capture — fill only from received replies

Meeting date/time/timezone: **PENDING** · Attendees: **PENDING**
Selected contract/catalog revision and raw SHA-256: **PENDING — not selected**
Selected source manifest: **PENDING** · Actual flashed firmware: **UNKNOWN**
Design-freeze disposition: **NOT APPROVED**

| Member | Decisions requiring their answer | Actual reply / source link / date | Sign-off |
|---|---|---|---|
| Ally | D01–D06 firmware/source/safety feasibility | PENDING — no reply supplied | PENDING |
| Kath | D01–D06 Android/compatibility/local recovery | PENDING — no reply supplied | PENDING |
| Mary | D01–D06 backend/source/security/data mapping | PENDING — no reply supplied | PENDING |
| Designated profile approver (name required) | D05 exact numerical profile/capacity/safety values | PENDING — person/values not supplied | PENDING |
| Cha | D01–D06 coordination acknowledgment and revision record | Sheet prepared; no team answers received | PENDING — no ratification recorded |

After the user supplies the actual replies, Cha updates section 2's answer/status
cells and this record with exact agreed choices/values, source revisions, named
sign-offs and any remaining owner-specific technical gate. Capture partial
acceptance explicitly without marking the whole row AGREED. For a conflict,
ask only the unanswered specific choice in the same round, not another audit.

Keep the original review documents unchanged. This sheet is the answer ledger;
once accepted, mirror/reference its recorded results into v1.3 section 4 through
an explicitly authorized document-control update. Do not independently rewrite
or approve v1.3 now. Compute the final selected revision's hash from actual bytes
after authorized edits; an input draft fingerprint is not a freeze signature.

## 5. Coding handoff — immediate safe slices versus dependent work

These are recommendations scoped by v1.3 section 5 and the handoff, **not code
changes performed or new deployment authorization**. No full wire/API implementation
ticket is unlocked by a missing answer. Owners may progress the protocol-independent
source-only preparation below using fake transport/storage/backend; do not claim
an agreed decoder, real source event, live command, authorized endpoint or physical
readiness. Within each row, move to implementation only after its exact dependencies
are answered/approved; work in the correct isolated branch/worktree.

| Task ID | Owner | Can start now? | Dependencies for contract-dependent part | Expected code change / scope | Test required (NOT RUN here) |
|---|---|---|---|---|---|
| HW-IMP-01 | Ally | Preparation only: select source and establish genuine build tooling; no frozen parser yet | D01/D02 exact source/schema; D03 bounds; D04/D05 gates for live admission | Explicit Start/Stop/read-only Status, correlated ACK/state, no auto-start, strict bounded parser; fail closed for missing clauses | Genuine compile/link/ELF/HEX + size; normal/duplicate/changed-content/wrong-batch/overflow fixtures |
| HW-IMP-02 | Ally | No contract-dependent persistence change yet | D01/D02/D03; D04 retained/loss boundary; D05 time policy | Durable original identities/intent/occurred phases; bounded replay/recovery and time validity | Nonoverlapping byte map, CRC/torn-write/power-cut simulation and journal-full behavior; physical reliability not inferred |
| UI-IMP-01 | Kath | YES — isolated interface/fake transport, generic byte-framer and truthful mocked UI only; production Start disabled | D01/D02 decoder schema; D03 negotiated bounds; D04/D05 readiness | LF framing/state separation; version-pinned strict decoder only once selected; no guessed legacy fallback | Analyzer + split/coalesced/overflow and widget state tests; no production commands |
| UI-IMP-02 | Kath | Preparation only: offline startup/storage seam and tests without claiming durable implementation | D04 provisioning boundaries; D06 approved storage version/transactions; D02 original evidence | Decouple recovery UI from online login; T1 intent/T2 dispatch/T3 evidence+outbox/T4 receipt, no hardware retry queue | No-internet cold start, crash boundaries, save failure, restart and lost-response tests with fakes |
| DB-IMP-01 | Mary | YES — local isolated test harness/fixtures only, ingestion disabled; no real source adapter yet | D01/D02 exact evidence; D04 auth; D06 API/mapping/test scope; D05 profile/time for live acceptance | Pinned bridge-sync adapter, canonical dedup, exact receipts/reconciliation/security; no production migration/endpoint | Authorized/unauthorized/duplicate/conflicting-content/wrong-source/revocation/retry tests in separately approved environment |
| INT-IMP-01 | Cha | YES — evidence-ledger/runbook skeleton and fixture inventory only; not another audit | D01 source pin, D02/D06 shared fixtures, D03 limits and D04/D05 gates for real dry run | Message-to-producer/consumer/DB-adapter/test-ID matrix; collect exact patches/test logs; no backend implementation on Mary's behalf | Fake-transport/test-backend dry run after relevant decisions; every actual result PASS/FAIL/NOT TESTED with log |

Portal DOC-IMP-01 stays after the decision pass and separate documentation-owner
authorization; it is not executed here. Branch commits/merges, test-project
resumption/provisioning, migrations/deployment, flashing/wiring/powered-load tests
all need their applicable authorization. Design approval is not safety clearance.

## 6. Stop the review loop: owners' next actions and fallback

- **Ally:** answer D01–D05 firmware details and D06 source linkage; give actual
  selected manifest and build/limit result or a specific failed prerequisite.
- **Kath:** answer D01/D02 compatibility, D04 setup, D05 display/time and D06
  package/outbox/receipt choice; progress isolated UI-IMP-01 mocks, not live Start.
- **Mary:** answer D01/D02 source mapping, D04 authorization/retention, D05 data
  validity and D06 API/test scope/completion rule; progress local test fixtures
  with source ingestion disabled. No open anonymous write fallback.
- **Designated profile approver:** provide name, role and exact approved D05
  profile/version/capacity/safety values. If absent, physical pilot stays blocked.
- **Cha:** post the six questions once, collect attributable responses, fill this
  sheet and task gates, pin the accepted revision after authorized update and
  coordinate only the resulting specific implementation/test work.

If required answers/proof cannot be settled in the October 28 round, record a
named blocker, next deliverable/time and the team's chosen **evidence-limited
demo that day**. Follow v1.3 fallback: labeled mock UI/transport and mocked or
authorized read-only cloud; real hardware/cloud segments only when their gates
and tests pass. No fake telemetry/physical Start/security/hatchability claim to
meet October 30. Do not create another competing contract or general audit.

## 7. This task's actual verification

Prepared from the four requested documents only; no new compatibility, live
schema, hardware or application audit. Input SHA-256 values were computed, not
invented or treated as selected source approvals. No team answers were supplied;
no D01–D06 decision or member sign-off was marked AGREED.

Actual documentation checks passed: six decision rows and six matching group-chat
questions; six existing implementation IDs with owner/start/dependency/code/test
columns; all four input fingerprints match the actual files; relative source
link resolves and code fences balance; no decision answer was inferred as AGREED.
Git whitespace check found no whitespace errors (LF-to-CRLF warning only), and
Git status adds only this sheet beyond the initial pending-work snapshot.

Checks used Node read-only file/hash/structure assertions and Git inspection.
No firmware build, application test, SQLite/security/API test, database operation
or physical test is claimed. The sheet is untracked/uncommitted on `cha-branch2`
in `C:\EggIncubator\egg_incubator_app`; existing worktree/work remains active and
preserved. No staging, commits, pushes, merges, deployment or cleanup occurred.
Task follow-up is waiting for the user's actual team answers, not another audit.
