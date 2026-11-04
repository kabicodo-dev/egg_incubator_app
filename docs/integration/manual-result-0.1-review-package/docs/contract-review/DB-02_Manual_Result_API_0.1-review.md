# DB-02 manual-result API — 0.1-review proposal

**Owner:** Mary Charlyn (Cha/Mary) · **Date:** 2026-10-30.
**Status:** PROPOSED INTERFACE / NOT JOINTLY APPROVED / NOT IMPLEMENTED OR DEPLOYED.

Implements no production behavior. Prepared under Mary's confirmed M01–M07
positions to obtain Kath's exact-byte review. This annex proposes a distinct
cloud-only result interface; it neither selects a firmware protocol nor edits
DB-02 0.1 `farmer_completed`/stopped_event_id schemas or fixtures in place.

Companions in this directory: `manual-result-0.1.schema.json` (proposed structural
schema), `manual-result-0.1.fixtures.json` (synthetic examples and hash vectors),
`manual-result-0.1.closure-matrix.json` (NOT RUN implementation/acceptance cases).
The current decision register remains CONTRACT-FREEZE-01_Team_Decisions.md.

## 1. Scope, version gate and prototype policy

Proposed future HTTPS POST cloud bridge interface, with existing bridge-sync route
as a candidate location only. `api_version:2` and
`contract:"DB02-MANUAL-RESULT-0.1-review"` identify this result-only proposal;
they do not upgrade the old API or enable version 2 in the current handler.
Unknown contract/version must fail closed. Never fall back to old farmer_completed
or send this JSON over HC-05. No START/STOP/RESET, lifecycle-finalize, correction,
enrollment or hardware-release operation is defined.

For the prototype, recording a validated result does not change session status,
end_date, physical state or the single-Active guard. Lifecycle finalization and
new hardware-batch admission remain deferred shared decisions. Unknown original
completion/action time remains unknown; server receipt never repairs it.

## 2. Proposed submit request — exact closed fields

Operation: `submit_manual_result`. All listed fields are required; extra fields
are invalid. IDs are lowercase canonical UUID strings; batch_id and result_id
are UUIDv4. IDs are not credentials. `installation_id` identifies the current
uploader; `actor_installation_id` is the immutable original farmer namespace.
`result_id` is allocated once when a draft is durably frozen for submission.
Earlier draft identity/UI details remain Kath's choice, but submitted identity
and content cannot change on retry.

| Field | Exact candidate rule |
|---|---|
| api_version / contract / operation | 2 / DB02-MANUAL-RESULT-0.1-review / submit_manual_result |
| installation_id | Current authorized uploader UUID; not immutable actor identity |
| device_id | Logical controller UUID matching authorized scope and original manifest |
| batch_id | Original Android batch UUIDv4; never latest Active lookup or numeric cast |
| actor_installation_id | Original actor installation UUID; no JWT or user-supplied authorization claim |
| result_id | Original action UUIDv4; immutable under original actor namespace |
| original_manifest_sha256 | Lowercase 64-hex digest of the agreed trusted original immutable manifest |
| eggs_hatched | Integer 0..2147483647 structurally, then 0..trusted positive original egg_quantity |
| action_time | Closed {value, provenance}; value null + unknown OR valid whole-second UTC value + phone_clock |

The integer maximum is PostgreSQL integer compatibility, not physical capacity
approval. Phone clock provenance is expressly untrusted farmer-action timing,
not controller UTC. The result's action time is not controller Start/Stop time,
not guaranteed time all eggs hatched, and is never copied automatically to end_date.
Fractional timestamps are rejected in this revision, not rounded before hashing.
For precision needs Kath requests a candidate revision rather than silent conversion.

No stopped_event_id, command_id, source sequence, RTC validity assertion, wire
evidence, desired status or session ID is accepted in this request. Their absence
does not manufacture source facts. Actor uploader replacement needs a separately
reviewed administrator recovery grant, not simply knowing the old result ID.

## 3. Preconditions and trusted dependencies

Before any lookup/submit, authenticate a real non-anonymous signed session and
recheck current protected controller/installation/actor scope. Exact enrollment,
signed claims, revocation/refresh/storage behavior and copied-credential threat
model still await Kath/shared design. UUIDs, client hashes or local eligibility
alone never authenticate. No privileged credential belongs in Android.

Backend must already possess an accepted immutable original manifest and a real
batch-to-session mapping, with original positive egg_quantity. The referenced
manifest digest must match that exact controller/batch/actor/profile/quantity
binding. A locally created manifest or unapproved profile is not automatically
trusted merely because its bytes hash correctly.

**Manifest encoding/trust establishment is not selected by this annex.** The
fixture's 64-hex manifest value is an opaque synthetic reference, not a claimed
source-derived digest. The complete original manifest contract, Start/source
binding and profile policies remain explicit blockers before acceptance is enabled.

If manifest/mapping is missing, accept no validated server result: return proposed
422 MANIFEST_REQUIRED or BATCH_MAPPING_REQUIRED, not_persisted. App retains local
Pending validation/evidence; it does not invent a session/Stop/manifest. Changed
manifest or inconsistent controller/batch/actor returns 409 MANIFEST_CONFLICT
without changing original evidence. Structural failures return 400 INVALID_REQUEST.

The initial new-result path requires the trusted managed session be Active;
otherwise return 409 LIFECYCLE_CONFLICT, never reopen historical Completed rows.
An already committed identical retry is resolved first (after authorization and
core comparison) and returns its original receipt even if lifecycle subsequently
changes. Never make old idempotent evidence disappear because current state changed.

## 4. Immutable identity, singleton result and canonical core

Primary action identity: `(actor_installation_id, result_id)`. Also enforce one
ordinary immutable accepted result per original `(device_id,batch_id)`. Concurrent
different result IDs for the same batch cannot create two results; losing request
gets 409 RESULT_ALREADY_RECORDED. Do not leak another actor's details in errors.
Corrections to committed results are deferred, not alternate-ID upserts.

Canonicalize exactly these eight fields (not uploader/operation):

```text
{contract, device_id, batch_id, actor_installation_id, result_id,
 original_manifest_sha256, eggs_hatched, action_time}
```

Use RFC 8785 JCS UTF-8 → SHA-256 lowercase hex after strict typed validation.
This revision's core contains only closed ASCII-string/null/Boolean-free objects
and safe integers; general Unicode/floating-point canonicalization is not needed
for these particular vectors. Parser rejects duplicate keys/nonfinite values and
unsafe/coerced types before producing the object. The local reference checks
operate on parsed objects, not raw HTTP, and do NOT test duplicate-key parsing.

Exclude current installation/session/token, transport operation, retry/receipt
time, server metadata and mutable UI labels. Actor, manifest, count, action_time
and original IDs are immutable facts; changed content under same identity is
409 IDENTITY_CONTENT_CONFLICT. Compare canonical content as well as digest;
hashes alone are neither authorization nor independent source proof.

## 5. Proposed recorded receipt and local commit

Successful first commit: HTTP 201; exact duplicate: HTTP 200, identical semantic
receipt. Receipt is an exact closed object in the schema, `receipt_revision:1`;
it is immutable for this prototype (no correction or mutable disposition path).

Receipt contains original result/actor/device/batch IDs, original manifest digest,
canonical content digest, trusted original egg_quantity and eggs_hatched, real
session_id as positive decimal STRING ≤9223372036854775807, stable receipt UUID,
and first server received_at (whole-second UTC). `outcome:"result_recorded"`,
`lifecycle_effect:"none"`, `physical_admission_effect:"none"`, retention_ack:null.
These effects are not permission checks or claims about current controller state.

Server result commit must atomically persist immutable result, singleton-batch
binding, stable receipt/mapping and any result-only display projection. Any
permitted projection must NOT change lifecycle/guard/end_date. No concrete table,
migration, RLS, RPC name or trigger is selected or created by this proposal.

Kath validates receipt identity/content/manifest/count, trusted original quantity,
original session mapping and fixed effects before atomically committing receipt
and corresponding outbox state (T4). A receipt alone never marks the whole batch
Completed or source journal releasable. Reject inconsistent same-ID receipt UUID,
first received_at, revision, mapping or effects; preserve pending evidence.

## 6. Read-only reconciliation, errors and unknown commit

Operation `get_manual_result` carries the same api_version/contract/current
installation/device/batch/original actor/result IDs, but no count/content update.
It rechecks authorization exactly like submit. Response has fresh request_id and
the requested tuple, found Boolean, and the full receipt or null; found:false is
a lookup observation, not proof a concurrent request cannot later commit.
Never issue another physical Start or mint a new result ID because of a timeout.

On unknown outcome, reconcile original identity. If absent and still eligible,
replay the original immutable submission; singleton/idempotency guards must make
in-flight concurrency safe. Found receipt must match the submitted core. A
mismatch pauses synchronization for help; no automatic overwrite or correction.

Error shape: api_version, contract, request_id, error{code,retryable,commit_status}.
Codes: INVALID_REQUEST; AUTHENTICATION_REQUIRED (401); NOT_AUTHORIZED (403);
MANIFEST_REQUIRED/BATCH_MAPPING_REQUIRED/COUNT_OUT_OF_RANGE (422);
MANIFEST_CONFLICT/LIFECYCLE_CONFLICT/IDENTITY_CONTENT_CONFLICT/
RESULT_ALREADY_RECORDED (409); CONTRACT_NOT_ENABLED/SERVICE_UNAVAILABLE/
COMMIT_UNKNOWN (503). All known failures use not_persisted; COMMIT_UNKNOWN uses
unknown. Only service-unavailable/unknown-commit retry automatically with the
original immutable identity and bounded backoff, or reconcile as appropriate.
Reauthentication after 401 is a separate approved action, not blind repeated login.

Errors never echo secrets, raw frames, SQL or other users' records. Proposed HTTP
resource limits, rate limits and exact HTTP-parser behavior require production
design review; structural fixture checks do not prove raw-byte/parser safety.

## 7. T1–T4 / result freeze requirements for Kath review

- Original hardware-command T1 intent and T2 dispatch marker remain independent;
  this proposal has no transport capable of physical dispatch.
- Editable result draft may change. Durable freeze transaction allocates/checks
  original action identity and commits immutable result + required outbox together
  only after local validation. Missing manifest/quantity stays Pending validation.
- Freeze/save failure does not show submitted/saved success or generate endless
  replacement IDs. Crash/restart preserves the same committed action where present.
- Server T4 receipt/mapping/outbox-state commit is atomic. Failure to commit keeps
  local pending state and reconciles later; no false server/lifecycle completion.
- Logout/replacement preserves protected committed evidence under agreed recovery
  rules; no START/STOP/RESET is dispatched. Concrete package/schema/SDK is Kath's
  proposal, not prescribed by this annex.

## 8. Exactly what needs review, and what is not completed

**Kath:** accept/change exact result request, time precision/provenance, eight-field
hash core, immutable receipt and lookup; demonstrate Dart canonical/hash parity
against supplied vectors; propose concrete durable freeze/T4/store and SDK behavior.
**Ally:** confirms this adds no controller command/Stop proof/release/admission,
and supplies source identity/recovery facts for trusted manifest mapping.
**Mary + Kath:** approve precondition behavior, one-result-per-batch, deferred
corrections and current Active-only new-result path; choose any new lifecycle
finalization rule separately with Ally. No general architecture review requested.

All closure-matrix entries begin NOT RUN. Local contract/vector checks may pass
without an actual server, storage, token, Dart decoder or physical device. They
do not complete C-02A/B/C, DB-IMP-01, hatch-result persistence, security or physical
integration. Other owners' acceptance is never inferred from generated fixtures.
