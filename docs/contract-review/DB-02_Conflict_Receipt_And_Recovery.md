# DB-CONTRACT-02 — Conflict, receipt and offline recovery contract

**Revision:** DB-02 `0.1-review` · **Owner:** Cha · **Date:** 2026-10-28
**Status:** PROPOSED / NOT APPROVED / NOT IMPLEMENTED

Companions: [exact API](DB-02_Exact_Bridge_Sync_API.md) and
[schema/security](DB-02_Proposed_Schema_And_Security.md). No cloud operation sends
a physical command. Database receipt is not controller Running/Stopped evidence.

## 1. Actual Flutter evidence and cross-check limits

**SOURCE VERIFIED:** `SmartHatch_v1.2.md:99-126` is the detailed Flutter candidate
available to this task: SQLite initialization before online auth, intent commit,
dispatch-may-occur marker, one local transaction for correlated outcome/evidence/
projection/outbox, read-only recovery, and independent state dimensions.

**SOURCE VERIFIED summary only:**
`SmartHatch_UI_02_Review_Summary.txt:3-5,7-23` identifies:
- `UI-02_Wire_Compatibility_Review.md`;
- `UI-02_Offline_Start_And_Recovery.md`;
- `UI-02_Farmer_UI_State_Specification.md`.

Those full files were not available in this checkout or searched Downloads paths.
Kath's summary says compatibility remains blocked, its review had no HW-02, and
Bluetooth/offline storage remain unimplemented. Direct column/state-by-state
comparison with unseen UI-02 is UNKNOWN/BLOCKED. Kath must compare this document
with her actual files before accepting it; do not claim her approval.

**SOURCE VERIFIED HW mapping:** catalog:60-106 distinguishes STATUS/STATE from
historical EVENT and TEL; :116-138 defines proposed replay/receipt release;
:164-167 leaves split-frame details unresolved. Feasibility:67-88 makes storage
bounded and reinstall recovery conditional. The API cross-check table records
actual oversized/alias/auth/time issues. This is review evidence, not hardware.

## 2. Exact immutable-core proposal

Use typed validation/approved adapter before JCS canonicalization. No raw unknown
fields, secrets, MAC tokens or arbitrary exceptions enter the semantic core.

For **events**, canonicalize exactly this object (values copied from validated
request, not placeholders in an actual upload):

```text
{
  api_version: 1, entity: "event", device_id, event_id, batch_id,
  event_kind, command_id, source_sequence, occurred_at, timestamp_valid,
  data, source_evidence
}
```

For **readings**, canonicalize exactly:

```text
{
  api_version: 1, entity: "reading", device_id, batch_id, sample_id,
  boot_epoch, sample_sequence, measured_at, timestamp_valid,
  current_temperature, temperature_valid, current_humidity, humidity_valid,
  source_evidence
}
```

These are algorithm notation, not alternative wire JSON. `data` is the exact
closed kind-specific API object. For farmer action `source_evidence=null`.
Adapter IDs, original string whitespace and multipart arrival order are not
hashed. Normalize equivalent single/split records to the **same** logical source
object only after all required matching parts arrive and the split schema is
approved. A missing time part is not equivalent to explicit source-invalid time.

Exact candidate normalized source object for EVENT:

```text
{version, family:"EVENT", controller_alias, boot_epoch, source_sequence,
 event_kind, command_id, batch_token, source_epoch_seconds, source_time_valid}
```

For TEL:

```text
{version, family:"TEL", controller_alias, boot_epoch, sample_sequence,
 batch_token, source_epoch_seconds, source_time_valid,
 temperature_c, temperature_valid, humidity_pct, humidity_valid}
```

For STATE:

```text
{version, family:"STATE", query_id, controller_alias, boot_epoch,
 latest_event_sequence, controller_state, batch_token, species_code,
 profile_ref, original_start_epoch_seconds, original_start_valid}
```

`batch_token` is the original 32-hex bid or explicit null for permitted IDLE
observation. Source-invalid time is null, not omitted, zero-filled or repaired.
State `tv/start_s` describes original Start validity, not a new observed UTC
instant. EVENT ep is original event epoch on replay. The single-frame redundant
eid must agree with dev/seq before it is omitted from the normalized object.
Width/padding of eid is a hardware open decision; do not trust it as the sole
event key. Source object values must match cloud typed fields exactly after
defined conversion, including full UUID bytes, not case-insensitive species guesses.

JCS UTF-8 -> SHA-256 hex. Compare both canonical data and fingerprint on duplicate
key to guard implementation errors; hash is not authentication. Numeric 54/54.0
are the same JSON number. Source ep/count/profile/validity/time differences are
different facts. Refresh token, authorized replacement uploader, request ID,
current upload time and `phone_received_at` are not immutable source facts.

Retain first uploader/phone receipt separately. If replay has a different phone
receipt, do not overwrite the first or treat it as source measurement time;
record needed diagnostics separately with authorization/redaction/retention.
Original event evidence is immutable; an accepted corrected count/time/profile
requires an explicit future administrator correction path, never silent edits.

## 3. Event dependencies and legal projection

| Kind | Required dependency / permitted effect |
|---|---|
| `started` | Verified original manifest/controller source and approved profile/time policy; create/map exactly one session if no lifecycle conflict. Records past transition, not continuously current Running. |
| `stopped` | Applied matching Start event in `data.started_event_id`, same device/batch, permissible sequence; retain physical Stop evidence. Does not set Completed or count. |
| `farmer_completed` | Applied referenced Stop and original positive egg quantity; integer manual `eggs_hatched` within quantity; set Completed/count/end_date from truthful time. No auto counting/physical Stop command. |
| `status_observed` | Reviewed STATUS query/binding/current-state exchange; may be unassociated IDLE observation; persist observation only. Never invent missing Start/Stop or let recent upload relabel old state as current. |
| `fault_entered` / `fault_cleared` | Explicit catalog evidence tied to known batch where present; safety-clearing policy must be approved. Evidence recording does not restart, stop, complete or clear a physical fault. |
| Reading | Existing session mapping and source batch/device; store one acquisition. No session creation, no latest-active reassignment. |

Partial causal chains receive `waiting_dependencies` and no fabricated mapping.
Do not require sequence numbers to be consecutive without a reviewed retained-
event/gap model: other event kinds may intervene. Use explicit predecessor IDs,
verified batch manifest, source ordering and replay completeness; never upload
order or an untrusted clock alone. Missing predecessors must not trigger physical
replay. Dependency reevaluation occurs only in a trusted bounded server process.

An offline batch may arrive with its completion before Start/Stop. Record valid
events waiting, then project one consistent batch after dependencies. If all
valid lifecycle facts are available, final Completed projection can avoid a
spurious committed Active intermediate. An unrelated Active row is preserved;
review conflict before overwriting/reopening/closing any record. A null original
completion time stays null; received_at is not end_date. Unknown source clock
does not by itself invalidate a known physical fact, but acceptance/projection
requires the team's explicit invalid-time policy. No accurate Day N without
trusted original Start and elapsed reference.

## 4. Receipt identity, revision and disposition

Every committed event/reading has one stable receipt UUID, original first server
`received_at`, entity identity and immutable `content_sha256`. Session mapping and
processing state are controlled mutable metadata, versioned by positive integer
`receipt_revision`. No projection update may commit without its corresponding
receipt revision/audit transition in the same transaction.

| Transition | Rule |
|---|---|
| New accepted event -> applied/waiting/conflict | Revision 1; commit evidence/receipt/projection outcome atomically |
| waiting -> applied | Only after valid dependencies; same receipt, revision +1 |
| waiting -> conflict | New evaluated conflict; same receipt, revision +1 |
| conflict -> waiting/applied | Explicit audited admin adjudication, never a normal app upload override |
| applied -> applied | No-op replay keeps revision; no reopening/completion overwrite |
| applied -> conflict/waiting | Not an ordinary transition; future separately reviewed correction workflow |
| Mapping null -> numeric session ID | Atomic verified mapping, revision +1 if processing changes |
| Numeric mapping -> different ID | Prohibited ordinary operation; manual corruption/identity recovery review |

Revision cannot wrap. If representation reaches its agreed maximum, require
controlled service repair/version review, not reset to 1. Replays always recheck
authorization and compare canonical core before returning the existing receipt.
Same key + changed core is HTTP 409 and **not a new conflicted receipt**; preserve
the original. This differs from a new valid event whose lifecycle projection
conflicts with existing state: that evidence may commit with conflict disposition.

`applied` is scoped to one entity: observation/fault receipt means evidence was
recorded, not a machine state was physically verified; Stop applied does not mean
farmer completion. Whole-batch synced requires all required relevant events at
applied disposition, not simply the last HTTP response.

## 5. Exact Android local contract (candidate, not existing tables)

Kath chooses concrete SQLite schema/plugin compatible with the project's actual
SDK; no plugin or Dart constraint is changed here. Required local semantic records:

| Local record | Minimum saved information / transaction |
|---|---|
| Enrollment | Installation UUID/alias, controller binding, reviewed offline authority reference; secrets in approved secure storage, not plain event rows |
| Batch draft | Original batch UUID, species, quantity, immutable approved profile reference, local eligibility/confirmation input; not synced evidence |
| Command intent | Full immutable semantic request + command ID and target batch/device; durable commit BEFORE transport; dispatch-may-occur marker committed before write |
| Captured critical event | Original source parts, correlation, original time/validity, immutable cloud event and canonical hash; commit with resolved intent and outbox atomically |
| Cloud outbox | Stable entity ID/type, immutable body/core/hash, first phone receipt, mutable retry state/count and next attempt; contains cloud submissions, not replayable actuator commands |
| Receipt/mapping | Stable receipt/hash/first time, highest revision, disposition/code, exact numeric session string; commit with matching outbox state |
| Partial wire assembly | Safely bounded parts keyed by agreed complete correlation; not yet a confirmed event or uploadable outbox fact |

Recommended local workflow labels are internal candidates, not farmer message
names or a new wire protocol:

| Backend result / failure | Exact local action | Farmer-facing interpretation |
|---|---|---|
| Matching applied receipt | Verify authenticated response, IDs/hash/session/revision, commit receipt/mapping/outbox outcome | Entity synced; whole batch only when all required facts applied |
| Waiting receipt | Store receipt/revision; preserve immutable event, poll reconciliation at bounded rate; do not repeatedly reinsert | Saved to server; processing pending |
| Committed conflict receipt | Preserve evidence and receipt, pause automatic application; request reviewed help | Needs help syncing |
| 409 changed-content error | Preserve original local/server evidence, do not replace content or invent a new ID | Needs help; identity/content disagreement |
| 400/422 permanent rejection | Preserve local evidence, stop automatic retries until correction/review; do not call server-persisted | Saved locally if local commit exists, upload rejected |
| 401 expired credential | Reauthenticate through approved path then replay identical immutable entity if authorized | Sync authorization needed; physical controller state independent |
| 403 revoked/scope denial | Stop protected uploads/read retries; retain evidence for controlled recovery | Cloud sync unavailable; never imply incubator stopped |
| Timeout/503 COMMIT_UNKNOWN | Outcome unknown; query by original key; if not found replay same immutable submission | Waiting to confirm synchronization |
| 429/transient pre-commit service failure | Bounded backoff, same identity/body; do not repeatedly send Bluetooth Start | Waiting to sync |
| Response validation/hash mismatch | Do not mark synced or release source; retain, reconcile/audit | Sync response needs review |

The source frame, logical event and semantic hash must survive app restart.
Reauthentication/current installation envelope may change only through approved
recovery; source event data stays fixed. If local schema conversion changes the
meaning of a pending event, migrate explicitly with review; do not regenerate IDs.

On receipt handling, require device/entity/batch equality, expected canonical hash,
non-regressing revision, same receipt UUID/first received_at, legal disposition
and stable session mapping. Ignore an older response without rolling back state.
Same revision with conflicting receipt metadata is a protocol error, not last-
writer-wins. Store bigint mapping as string or a verified lossless integer type;
never use a floating-point intermediary. Sync failure must not reset Day 1.

## 6. Lost response reconciliation

1. Keep immutable event and original identity in the local outbox.
2. POST `get_reconciliation` with explicit entity lookups and optional known batch
   UUID. This is a DB query, not a Bluetooth STATUS or physical command.
3. Each result says found/absent and returns the exact current receipt if found.
   Validate hash/identity/revision/mapping before accepting it.
4. If absent, no inference about hardware or permanent database failure: the
   original transaction may still be resolving. Replay the same submission;
   atomic uniqueness serializes it against an in-flight original.
5. If unauthorized, do not use another installation/anonymous key to bypass it.
6. Commit received mapping/receipt locally before reducing evidence retention.
   If this local commit fails, repeat reconciliation rather than hardware Start.

Foreground-only sync is the baseline. No auto-background execution or missed-
reading backfill is promised. The phone may continue an authorized local Bluetooth
workflow when offline, but the precise cached local-authority/revocation policy
remains blocked; online Auth is not allowed to gate display of recovery UI.

## 7. Receipt-to-Arduino retention acknowledgment — BLOCKED, fail closed

HW-02 catalog:132-138 proposes RCPT_ACK with eid/rev/dis/mac. It is NOT sufficient
as supplied to authenticate a server commit or bind full immutable content. An
authorized phone can forge plain JSON and may possess a command MAC key.
HTTPS verification by Android does not prove a receipt to Uno.

This candidate API returns `retention_ack:null` even when applied. Android MUST
NOT fabricate RCPT_ACK from HTTP 2xx, receipt text, code, a Bluetooth ACK or a
phone-owned command MAC. Retain source evidence until an approved mechanism or
explicit physical/service reconciliation/loss boundary exists. Queue exhaustion
must not block emergency local safety actions.

Required joint design before enabling release:
- Server-only receipt signing authority, or per-controller server/Uno key whose
  secret is not available to the bridge; key ID, secure provisioning/rotation and
  physical extraction threat model documented. Do not guess a feasible algorithm.
- Domain-separated receipt purpose distinct from command authorization. A tag
  valid for START must not be reusable as a server commit proof.
- Authenticated content binds controller identity/provisioning generation,
  exact retained source event identity AND its locally verifiable immutable
  fingerprint, stable server receipt identity, revision, applied disposition,
  receipt protocol/domain/version and issuer/key identity.
- Uno compares these to its retained record, validates tag/signature, rejects
  altered/foreign/regressing receipts, and atomically releases only that event.
  No cumulative release/cursor advance over missing/conflicted events.
- Backend cloud JCS core also contains Android manifest fields that Uno may not
  retain; do not assume its SHA-256 alone is locally comparable. Agree a source-
  only canonical binary/fingerprint preimage and authenticated linkage to the
  server event core before designing compact split receipt frames.
- Ally supplies code/RAM/EEPROM/frame feasibility and power-cut tests; Kath
  relays the signed artifact unchanged and records release acknowledgment.

No cryptographic wire algorithm, key, tag length or new receipt frame is frozen
here. If infeasible, explicitly approve narrower bounded retention and loss cases;
do not label ordinary phone acknowledgment as authenticated server release.

## 8. Failure/recovery matrix

| Scenario | Required candidate behavior |
|---|---|
| Uno starts, reply lost | Original intent and ID retained; STATUS/REPLAY read-only reconciliation; no fresh Start |
| Evidence received, SQLite commit fails | Keep available memory evidence, retry local commit/read retained source; report running evidence received but record not saved |
| Phone dies before saving evidence | Recover only from surviving intent/controller journal; if absent, state unknown, not fabricated proof |
| Server commit succeeds, response lost | Reconcile/replay original event; same receipt/mapping, no duplicated row/action |
| Internet lost after Start | Critical outbox retains data; Uno intended autonomous; sync pending independent from physical state |
| Bluetooth lost while running | Last-known state ages; readings no longer live; never infer power loss/Stop |
| Uno reboot during batch | Restore only verified persistent identity/evidence; safe recovery gates; original Start unchanged, no fresh Chicken reset |
| A completes offline, B starts | Retain distinct original IDs and causal chains; no last-upload-wins or cloud-active reassignment |
| Unrelated cloud Active exists | Commit valid conflict evidence, preserve old session, admin reconciliation; no automatic stop/delete/complete |
| Unauthorized/revoked/stale phone uploads | Deny unauthorized access; authorized late facts remain historical, not fresh current state |
| Two different new Start IDs | Controller admission rejects replacement; cloud UUID/event uniqueness and conflict logic independently protect projection |
| Invalid RTC | Source time null/false; known facts may be retained under reviewed policy; no receipt-time Start or false incubation day |
| Stop confirmed, count not entered | Physical Stop evidence separate; no auto Completed/count |
| App reinstalled, unsynced counts lost | Recover source/cloud facts only; farmer count cannot be inferred from sensors; explicit recovery/help |
| Journal full | Ordinary new Start may be blocked; no overwrite of sole unacknowledged proof; emergency local safe Stop still possible |
| One split event part missing | Partial assembly only; no upload/completion receipt; request missing/replayed parts |
| Old EVENT replayed after newer STATE | Retain past transition; do not override latest substantiated local controller observation |
| Replayed event ep changes to new boot | Source content conflict; preserve original epoch, never mint another event identity to bypass |

## 9. Acceptance and validation handoff

Required before joint freeze: exact full UI-02 review, HW alias/null/eid width/
split/counter ordering, profile/time policy, source authentication threat model,
offline provisioning and revocation, qualifying receipt verification/loss boundary.
All remain pending; request/response schemas do not resolve Uno feasibility.

Host-only structural examples/canonical invariance can be checked now; actual
atomic dedup, Auth/RLS/revocation races, SQLite crashes, receipt signatures and
physical Start/Stop need separate implementations and authorized tests. No such
checks were claimed performed in this documentation task. API document contains
the actual validation record and observed HW example lengths.
