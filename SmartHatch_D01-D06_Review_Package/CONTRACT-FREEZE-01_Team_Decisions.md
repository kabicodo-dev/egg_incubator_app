# CONTRACT-FREEZE-01 — One-round team decisions

**Coordinator:** Cha · **Backend owner:** Mary · **Date/deadline:** 2026-10-28
**Status:** PARTIAL PERSONAL/DESIGN ANSWERS RECORDED — EXACT SHARED CHOICES OPEN; NOT APPROVED

**Latest consolidation — 30 Oct:** The supplied Ally packet review and Flutter
compatibility review supersede older receipt summaries below. Ally's D02/D04/D06
positions are received, including conditional support for independent manual
results. The user's current message supports design principles only, not the exact
protocol or implementation; its pasted team-addressed wording is not independently
authenticated as Kath's technical sign-off. See [one consolidated update and
DB-02 amendment](DB-02_30Oct_Consolidated_Alignment.md) for only the remaining
choices, owners and closure tests. No full task completion is newly claimed.

**30 Oct response update:** Mary Charlyn's explicit D04/D06 personal backend
answers are now recorded in [D04_D06_Mary_Backend_Position.md](D04_D06_Mary_Backend_Position.md).
D04 cloud authorization/retention and D06 sync invariants are personally accepted;
independent manual completion is a **CHANGE REQUEST**, not joint approval.
Further exact shared choices and implementation gates remain outstanding. No deployment
or code/schema change is authorized. Cha and Mary are the same respondent.

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
| D01 — baseline | HC-05/Android primary; USB diagnostics; no architecture re-vote | Pin one source/catalog/toolchain and explicit supersession answer; flashed image may remain UNKNOWN | Supplied packet review §D01/protocol mismatch: original 3721bce0… vs patched 7106ebfe…; numeric START vs START_BATCH/CONFIRM | Ally supplies source/supersession; Mary + Kath accept same bytes | RECEIVED: Ally reports ally-branch3 / 80971f9… and patched source; architecture retained. No selected common protocol or delivered raw source in reviewed Markdown ZIP. | ANSWERED IN PART; SELECTION OPEN | No adapter/decoder unlocked until matching source/catalog accepted |
| D02 — lifecycle/identity/recovery | Deliberate Start; ACK/state/physical feedback distinct; no automatic physical Start replay | Exact STOP/read-only recovery, IDs, boot/reset/selection/invalid-EEPROM outputs and retained loss boundary | Packet review cites numeric uint32 batch, volatile 8-entry ACK cache, missing STOP and incomplete STATUS; boot descriptions conflict | Ally transition/output table + schemas; Kath + Mary mapping acceptance | RECEIVED: current limitations explicitly answered; user supports deliberate Start/durable original evidence. Blank/corrupt EEPROM fresh-batch/control-resume reports need reconciliation, not an inferred no-auto-heat pass. | ANSWERED IN PART; SEMANTICS OPEN | HW/UI/DB implementations remain dependent on exact accepted facts |
| D03 — bytes/build | Separate software RX ring, parser buffer, TX, Android bounds and HTTP ceilings | Deliver existing raw build/fixtures; approve maxima, delimiters, stack/service and identity/journal byte budget | Reported 21,164 B flash / 1,782 B static SRAM / 266 B remaining; oversized-input LF drain; not reproduced here | Ally AVR/RX/TX/layout; Kath Android framing; Mary adapter bounds | RECEIVED: real build reported, not absent. serialLine[120] is RX application storage, not TX maximum; HTTP 4096 ceiling is not a Uno requirement. Eight-byte command does not fit four-byte AVR long. | BUILD REPORTED; FEASIBILITY BLOCKED | No final byte/schema freeze or safe runtime claim |
| D04 — trust/release | Controlled non-anonymous cloud enrollment; separate controller authority; retention_ack:null; no HTTP-only release | Exact key/provision/revoke threat model, Flutter bootstrap, bounded journal/service/full/corrupt/loss rules | Packet review cites no current wire authorization; four-slot critical journal proposal, not production retention | Ally controller/key/journal; Mary cloud; Kath secure storage/startup; all accept loss limits | RECEIVED: Mary's scoped non-anonymous cloud and fail-closed release positions; Ally retains null/no synthetic release and proposes full/corrupt journal block new Start, not emergency safety action. User supports controlled enrollment. Exact mechanism and loss policy not approved. | PRINCIPLES RECORDED; IMPLEMENTATION BLOCKED | App enrollment is NOT controller authentication; live gates remain off |
| D05 — Chicken/profile/time | Preserve Chicken pilot scope and unknown-clock provenance; no invented settings | Named approver accepts existing candidate values/version/capacity; choose invalid-clock/outage/freshness policy | Packet review cites supplied profile record :335–353 with values and approval state; actual numerical record not attached here | Ally supplies existing record/module facts; designated approver signs values; Kath + Mary time/display mapping | RECEIVED: candidate values exist in Ally packet; do NOT ask Ally to invent/restate them. Approval, RTC identification and physical checks remain missing. Phone receipt is not source occurrence time. | VALUES REPORTED; APPROVAL/TIME BLOCKED | No physical readiness or numeric profile approval inferred |
| D06 — local/cloud mapping | Durable original intent/evidence; idempotent cloud sync; result/ACK/state/lifecycle/receipt/admission distinct | Accept exact amended result/lifecycle/admission policy, selected source adapter, API/hash/dependencies and Kath storage transactions | Packet review cites Ally conditional completion support :235–250; Flutter review reports cloud-success Started UI, legacy parser and missing durable batch intent | Mary DB-02 amendment; Kath UX/transactions; Ally source/admission conditions | RECEIVED: Mary sync invariants and independent manual result request; Ally conditionally supports result recording without Stop, not clearing single-Active guard or admitting a new physical batch. User supports principles, not exact implementation. See DB-02 amendment; original stopped_event_id schemas remain historical candidates, NOT compatible with requested change. | CONDITIONAL DIRECTION RECORDED; EXACT AMENDMENT OPEN | No migration/RPC/adapter activation. Isolated test target unchanged; previous narrow permission not expanded |

**Actual D01–D06 agreements recorded: NONE.** Existing architecture/scope directions
are carried forward as requested, not reopened; they are not new answers to the
six exact freeze choices. No v1.3 approval or successful technical test is inferred.

**Earlier individual response (superseded by the latest consolidation above):** Mary's four explicit D04/D06 selections are now
recorded; “NONE” above means no complete **joint D01–D06 agreement**, not no
individual replies. D01/D02/D03/D05 exact approvals remain unrecorded. Her
independent-completion choice requests a revision rather than accepting the
candidate's existing Stop prerequisite.

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
| Ally | D01–D06 firmware/source/safety feasibility | 30 Oct: personal response summary and supplied Ally-2026-10-30-Packet-Review.md crosswalk received; explicit current limitations, fail-closed release and conditional independent-result support recorded above. Full 13-position text/four verbatim conditions and raw source evidence not delivered here. | PERSONAL POSITIONS RECEIVED IN PART; NOT JOINT SIGN-OFF |
| Kath / Flutter reviewer | D01–D06 Android/compatibility/local recovery | Supplied ORIGINAL-C-02-Flutter-Compatibility-Review.md: REQUEST CHANGE, legacy/current-source mismatches and 63 existing tests reported; Ally packet review supplies further constraints. Authorship/sign-off not independently authenticated from the attachments. | REVIEW RECEIVED; EXACT REVISION ACCEPTANCE OPEN |
| Mary | D01–D06 backend/source/security/data mapping | Four D04/D06 selections recorded in D04_D06_Mary_Backend_Position.md; later consolidated DB-02 amendment separates result/lifecycle/admission and records Ally conditional support. D01/D02/D03/D05 and exact remaining mappings not signed. | PERSONAL POSITIONS ACCEPTED IN PART; EXACT D06 AMENDMENT OPEN; NOT FULL SIGN-OFF |
| Designated profile approver (name required) | D05 exact numerical profile/capacity/safety values | PENDING — person/values not supplied | PENDING |
| Cha | D01–D06 coordination acknowledgment and revision record | Same person as Mary above; recorded her actual D04/D06 answers on 2026-10-30, no separate technical vote or other-member response inferred | COORDINATION RECORD UPDATED; JOINT RATIFICATION PENDING |

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

## 7. Historical 28 Oct preparation verification (before actual replies)

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

## 8. 30 Oct actual Mary response update

The historical no-answer statements in section 7 describe preparation on 28 Oct.
They are not the current response state. Mary's D04 cloud identity and
fail-closed retained-evidence release positions, and D06 sync invariants, are
now personally accepted. Her D06 independent-completion choice is a requested
change to the candidate, pending Kath/Ally and safe lifecycle agreement.

See [the exact response record](D04_D06_Mary_Backend_Position.md) and
`../integration/cha-execution/mary-d04-d06-answers.json`. The input candidate
hashes identify reviewed context only, not a jointly selected/frozen revision.
No full member sign-off or code/deployment authorization was inferred. D04 stays
BLOCKED and D06 NEEDS ANSWER in their joint scope. No SQL/Flutter/firmware or
remote operation occurred in this response-recording update.

## 9. Historical receipt of earlier 30 Oct Ally progress-report packet

Received `SmartHatch-all-reports-2026-10-30-1.json` (26 records, 23 outer task IDs).
This is useful attributed source/build/host/model progress, **not** a complete
formal answer/sign-off packet. In particular, STOP/admission/RTC/production
durability and joint source/mapping decisions remain blocked; no explicit response
to Mary's independent-completion change request is present. Do not reuse the
earlier “no reply supplied” preparation wording as though no evidence was received.

See `../integration/cha-execution/ALLY_REPORT_REVIEW.md` for the D01–D06 matrix,
exact source differences, two misfiled HW-IMP bodies and the small follow-up packet.
The later personal-response and supplied reviews supersede this earlier missing-response
finding; conditional support is now recorded in section 2. No Ally task/status,
report attribution or joint approval was changed. Original
export and browser data are preserved; reported tests were not rerun here.
