# Mary's backend checklist — independent preparation

**Date:** 2026-11-01 · **Workstream:** Mary Charlyn (Cha/Mary), backend/integration
**Classification:** automated local source review and conditional test planning;
not a new personal vote, selected-source acceptance or implementation permission.

## Outcome and checklist status

The available checkout can be mapped now; acceptance of Ally's forthcoming packet
and agreement with Kath cannot be completed on their behalf.

**Subsequent acknowledgment, relayed by Mary on 2026-11-01:** Kath received the
request and is awaiting Ally's matching source/catalog/hash packet before scoped
decoder findings. No compatibility pass is claimed; Android/storage/enrollment/
session choices remain open and manual-result 0.2 ACCEPT is unchanged. Exact text
is retained in the [existing ledger](CONTRACT-FREEZE-01_Team_Decisions.md).
The table below describes the earlier preparation, not an assertion that Kath
has supplied no acknowledgment. No matching new source packet has been supplied.

| Mary's checklist item | Work performed now | Remaining gate |
|---|---|---|
| Verify delivered hashes/provenance | Fingerprinted 13 available local source/review inputs in the companion manifest; originals untouched | No new Ally/Kath reply or matching source packet supplied in this turn; delivery integrity still pending |
| Compare actual source fields with DB-02 | Field matrix below completed for current checkout only | Final mapping must use the delivered and jointly identified source/catalog bytes |
| Record scoped findings in existing ledger | Linked this preparation and user-reported message delivery; no owner vote invented | Actual ACCEPT/CHANGE/BLOCKED answers must identify responder, scope and reviewed hashes |
| Agree Q06/Q07 with Kath | Existing Mary positions retained; compatibility/gap list prepared below | Concrete storage/enrollment/session decisions still require Kath/Mary agreement |
| Prepare next isolated security slice | Conditional acceptance matrix and permission boundary prepared below | No executable mutation patch or remote run until its prerequisites and exact authorization are satisfied |

User reports sending the request to Ally and Kath. Message delivery is
**user-reported**; Kath's later acknowledgment is user-relayed as noted above.
Neither establishes architecture-document distribution, independent identity
verification or technical sign-off.

## 1. Evidence identity — do not confuse local with delivered

[Local input fingerprints](MARY_Backend_Preparation_2026-11-01.inputs.json)
record raw-byte SHA-256, not normalized content, selected-source hashes or signatures.
Line-ending changes can legitimately change these fingerprints; review the diff
rather than silently updating expected values. These paths contain no requested
credentials; no `.env`, CLI link metadata or account records were read for this work.

Current Combined source hashes to `a466a868e6c148cf4f9c3230378d5033d81db89dfb77a3e0fa53891d847a9598`.
The existing received report identifies a different patched source, `7106ebfe…`.
The local file is not a replacement for that missing raw-source delivery. Neither
source is selected or claimed flashed by this preparation.

## 2. Provisional field mapping — inspected checkout, not an enabled adapter

References: `arduino/SmartHatch_Combined/SmartHatch_Combined.ino` telemetry and
command handlers; `lib/services/arduino_protocol.dart`; `supabase/functions/_shared/bridge-sync-core.mjs`;
[candidate DB-02 API §§3/5](DB-02_Exact_Bridge_Sync_API.md).
All BLOCKED labels below are technical findings, not new task-status edits.

| Field/boundary | Available source / current behavior | Candidate requirement and finding | Missing owner/input |
|---|---|---|---|
| Controller identity | Combined telemetry has no provisioned `dev`/device UUID | Registry-backed immutable source binding; BLOCKED, not derived from COM port/name | Ally identity/auth facts; Mary registry design; Kath binding |
| Installation/actor | Legacy app uses anonymous Auth; telemetry has no original installation binding | Current uploader scope differs from original actor; IDs alone are not credentials; BLOCKED | Mary/Kath Q07; Ally original-source association |
| Batch | Local Combined persists species/elapsed runtime, not offline batch UUID | Original UUIDv4/batch mapping cannot be inferred from latest Active; BLOCKED | Ally exact identity/catalog; Kath original manifest |
| Command/query | Combined accepts numeric `long id`; Flutter actuator ACK expects string ID | Candidate `command_id` is 16 lowercase hex characters; numeric-to-text alias is not accepted; BLOCKED | Ally supersession/width; Kath decoder; Mary mapping |
| Lifecycle event | Local events/ACKs do not carry the candidate durable global transition sequence | Candidate `controller:<device>:<sequence>` needs persistent source evidence; BLOCKED | Ally lifecycle/recovery/counter policy |
| Sample/boot | No candidate boot epoch/sample sequence in local Combined telemetry | Candidate sample key requires both uint32 components plus device; BLOCKED; phone counter cannot repair source provenance | Ally exact sample identities |
| Acquisition/original Start time | Elapsed runtime exists; no RTC-backed UTC validity in inspected output | Unknown remains null/false where permitted; receipt time is separate; trusted time/continuity policy BLOCKED | Ally clock/outage evidence; Mary/Kath policy |
| Actual metrics | Combined uses `incubator.temperature_c`, `humidity_percent`, shared `valid`; Flutter parses different metric keys | No targets-as-readings; independent validity/source semantics and compatible parser need agreement; BLOCKED as ingestion | Ally validity/catalog; Kath parser; Mary adapter |
| Species/profile | Combined emits `egg_type`/stage/day; app profile/settings literals exist | Original approved profile version/quantity must be substantiated, not current settings guessed; BLOCKED | Named profile approver, Ally and Kath manifest |
| Quantity/manifest | App validates 6–12 and stores `egg_quantity`; Combined output does not substantiate an original immutable quantity/manifest | Manual-result 0.2 requires a trusted original manifest hash/quantity; BLOCKED. A synthetic hash is not trust | Kath durable original intent; Ally source correlation; Mary verification |
| Database session | Legacy service casts DB ID to Dart `int` | Candidate responses require decimal string within signed-bigint maximum; no numeric cast at a future API boundary; mapping BLOCKED | Mary real transactional mapping; Kath lossless consumer |
| Manual result | `completeSession` changes status/end_date/count; old v1 core requires `stopped_event_id` | Result-only 0.2 is a separate reviewed proposal, not implemented by v1; CHANGE needed in future coordinated implementation, not silent field removal | Mary/Kath implementation; source/manifest prerequisites |
| Receipt/release | Candidate core checks receipt identity/hash and `retention_ack:null` | Local/stubbed checks exist; real persistence/reconciliation and controller release remain BLOCKED | Mary DB transaction layer; Ally retention/auth |

Local Combined `SELECT_*` calls `startNewBatch`; its volatile ACK cache replays by
ID without checking changed content. These are observations about these exact
bytes, not the later patched source. They cannot substantiate deliberate Start,
durable idempotency or safe boot/recovery for the selected implementation.

**Boundary:** no adapter, decoder fallback, invented batch/event/time/manifest,
source alias or accepted numerical freshness threshold is introduced.

## 3. Q06/Q07 — backend constraints ready for Kath's concrete response

Carry forward [Mary's M01–M08 positions](D04_D06_Mary_Backend_Position.md)
and [Kath's scoped 0.2 ACCEPT](../integration/cha-execution/KATH_02_DELTA_ACCEPT_RECEIPT.md).
No repeat Q05 review or M08 confirmation is needed.

| Boundary | Existing backend requirement | Concrete choice still open |
|---|---|---|
| Durable original action | Reserve identity at first durable draft; preserve committed identity/content on retry and ambiguous commit | Native store/package/device floor, schema and transaction/lease ownership |
| Sync commit | Atomic action/outbox and validated receipt/mapping/outbox commits; no hardware commands in cloud retry queue | Exact client commit/restart/key-loss tests and recovery behavior |
| Enrollment | Admin-controlled non-anonymous protected operations, no privileged Android key | Named admin, bootstrap/activation, secure storage, credential-copying threat model |
| Session change | Recheck scoped authorization on each protected request | Refresh/relogin/reapproval, logout in flight, replacement and historical grants |
| Revocation | Block protected cloud operations; preserve original evidence; never claim physical Stop | Exact client offline owner access and subsequent authorized recovery |

Do not select proposed package pins, API-30 minimum or 30-minute activation expiry
by default. No new member decision is recorded by this table.

### Legacy compatibility inventory for the future migration plan

- `main.dart` startup anonymously signs in before `runApp`: plan truthful offline/
  unauthorized startup with Kath before replacing it.
- `getPresets` reads presets: public-vs-protected classification is still a decision.
- `updateActiveSettings` directly inserts/updates a global row: do not treat saving
  it as proof that hardware applied a profile.
- `createSession` inserts Active, then UI separately updates settings: reconcile
  partial saves and controller-confirmed Start rather than adding a new ID/retry.
- Session/history/stat reads are currently global; `getLatestReading` is not
  device/batch-scoped. Approved identity and source mapping must precede scoped reads.
- `completeSession` directly marks Completed: cannot be relabelled result-only 0.2.
  Preserve Active/admission rules in a coordinated replacement.

No legacy grants, client methods or SQL drafts are changed here. Merely adding
RPCs would leave direct-table bypasses; future security acceptance must test both.

## 4. Conditional next slice — authorization before persistence

**Not implementation-ready or remotely authorized.** Plan only; do not execute
these cases or create identities from this document. Existing draft hard locks
must not be bypassed just to obtain a positive result.

Preconditions: exact Q07 identity/session/admin mechanism; Q06 client compatibility
for the slice; verified isolated target/catalog and inspected role ownership;
reviewed exact patch and affected-object list; explicit account/fixture/schema/
RLS/RPC permissions as applicable, with rollback/cleanup/readback procedure.
Source ingestion stays disabled; a test authorization success is not source approval.

| Future case | Required outcome/evidence | Current execution |
|---|---|---|
| Missing/forged/expired token or anonymous Auth user | Denied before protected read/write; real signed-token and Auth boundary evidence | NOT RUN here |
| Designated identity, permitted session/device and operation | Only explicitly allowed test capability succeeds; no inference of physical-phone exclusivity | NOT RUN here |
| Other/revoked installation, wrong device or expired scope | Submission AND receipt/reconciliation reads denied, including previously known IDs | NOT RUN here |
| Refresh/relogin/replacement | Matches reviewed reapproval/grant rule; old actor/source identity not rewritten | NOT RUN here |
| Direct REST table access | Agreed unauthorized operations denied despite RPC protection; preserve intentionally public classifications only | NOT RUN here |
| Revocation concurrent with write | Transaction recheck prevents stale authorization from committing protected mutation | NOT RUN here |
| Missing registry/RPC, disabled contract, unsupported ledger | Fails closed, sanitized error; permanent unimplemented condition not blind endless retry | NOT RUN here |
| Evidence/cleanup | Sanitized target/tool/patch/command/results and exact run-owned cleanup verified; existing records untouched | NOT RUN here |

Do not write a new SQL deployment patch until these inputs are sufficient.
Existing drafts intentionally do not implement the ledger or result-only 0.2.
Refer to [staged Q12 plan](../integration/cha-execution/Q12_Test_Project_Approval_Plan.md)
and its later [current status](../integration/cha-execution/q12-phase-a-status.json):
phase-A read-only approval exists, recorded attempt is Partial/Blocked, remote retry
requires specific approval, and mutation/deployment phases remain excluded.

## 5. Verification and next handoff

Use the companion read-only verifier from repository root:

```powershell
node docs/contract-review/verify-mary-backend-preparation.cjs
```

It checks all 13 input hashes/sizes and report links, writing nothing and importing
no application or firmware module. It verifies this local snapshot, not a member's
signature, physical implementation, remote database state or packet delivery.
Backend and result-reference regressions may be rerun locally; their results must
remain separate from the NOT RUN remote cases above.

### Actual local checks executed for this preparation

- Snapshot/link verifier: **PASSED**, 13/13 input hashes and sizes, 6/6 report links.
- `node --test --test-timeout=15000 test/integration/int_imp_01.test.cjs test/backend/bridge_sync_http_test.mjs test/backend/bridge_monitoring_test.mjs test/backend/architecture_alignment_test.mjs test/backend/monitoring_boundary_test.mjs`:
  **110/110 passed**, zero failures/skips/cancellations; existing local mocks,
  boundary stubs and loopback HTTP, not a live database or controller test.
- With existing temporary Ajv tooling in `NODE_PATH`,
  `node --test --test-timeout=15000 docs/integration/cha-execution/manual-result-0.2.test.cjs`:
  **27/27 passed**, zero failures/skips/cancellations; schema/reference scope only.
- Results observed in this session's command output. No new Flutter/Dart, AVR,
  real JWT/Auth/RLS, remote SQL, physical or implementation-acceptance run claimed.
  No dependency installation or prior evidence-log overwrite was performed.

**On replies:** verify the new packet against its supplied manifest without
overwriting this snapshot; revise only changed mapping rows, record actual answers
in the existing ledger and choose only the implementation slice whose gates close.
No task-card completion, portal status change, deployment, account provisioning,
remote retry, package installation or physical operation is performed by this work.
