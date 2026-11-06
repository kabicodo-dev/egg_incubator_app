# DB-CONTRACT-02 — Proposed additive schema and security

**Revision:** DB-02 `0.1-review` · **Owner:** Cha · **Date:** 2026-10-28
**Status:** PROPOSED / NOT APPROVED / NOT EXECUTED

Companions: [exact API](DB-02_Exact_Bridge_Sync_API.md) and
[conflicts/receipts/recovery](DB-02_Conflict_Receipt_And_Recovery.md).
No migration SQL, Auth provisioning, RLS change, endpoint deployment or database
write was performed. This document is a typed design, not a deployed schema.

## 1. Evidence and compatibility scope

**LIVE VERIFIED (PRIOR INVENTORY):**
[actual inventory](../../SmartHatch_Supabase_Actual_Schema_Inventory.md):68-203,
205-320. Observed 2026-10-27 11:00:42 UTC; not re-queried for DB-02.

| Existing table | Exact existing columns retained |
|---|---|
| `public.incubator_sessions` | `id bigint` identity PK; `egg_type text`; `start_date timestamp without time zone DEFAULT now()`; `status text DEFAULT 'Active'`; `egg_quantity integer NOT NULL DEFAULT 0`; `end_date timestamptz`; `eggs_hatched integer DEFAULT 0`; `temperature numeric` |
| `public.incubator_presets` | `id`, `egg_type`, `target_temperature`, `target_humidity`, `incubation_days` |
| `public.active_settings` | `id`, `egg_type`, `target_temperature`, `target_humidity`, `incubation_days` |
| `public.sensor_readings` | `id bigint` identity PK; `current_temperature numeric`; `current_humidity numeric`; `recorded_at timestamp without time zone DEFAULT now()` |

All application tables have RLS enabled, not forced; owner postgres. Existing
non-id required columns are preset `egg_type` and session `egg_quantity`.
No FKs/CHECKs/standalone UNIQUE constraints; four PK indexes and the global
`incubator_sessions_single_active` partial unique index on exact status `Active`.
No public application routines/triggers and no deployed Edge Functions were
found in that inventory. Managed Supabase schemas were not security-certified.

**SOURCE VERIFIED:** `lib/services/supabase_service.dart:125-167` inserts a cloud
session before getting its ID; :232-245 directly updates completion without
returned-row verification; :287-295 reads the latest global reading. These are
not offline synchronization implementations. Earlier C-02/C-03 ESP8266 assumptions
must not provision a Wi-Fi publisher credential on Android by analogy.

**SOURCE VERIFIED:** HW-02 supplies aliases (`dev`, `iid`) rather than cloud
UUIDs; catalog lines 17-22,95-106. Its authentication/identity/journal remains
proposed. Kath's supplied UI-02 summary:12-21 reports missing bridge/outbox and
needs exact receipts. Full UI-02 documents were unavailable; do not treat the
summary's package/version findings as a newly checked dependency result.

## 2. Candidate relational model

All names/types below are **PROPOSED**. The private namespace is a proposed
non-API-exposed schema. No actual credentials or user IDs are supplied.

### 2.1 Private controller registry: `private.controllers`

This small registry is necessary because HW-02 aliases are not UUIDs, controller
lifetimes outlive installation/session records, and identity must survive phone
replacement without relying on HC-05 name/MAC. No existing table can supply it.

| Candidate field | Type / rule | Purpose / MVP |
|---|---|---|
| `device_id` | uuid PK, admin provisioned | Stable logical controller; required |
| `wire_alias` | text UNIQUE, exact `[0-9A-F]{16}` | Maps HW `dev`; required; SH-prefixed catalog examples remain blocked until corrected or rule revised |
| `active` | boolean NOT NULL | Disable source ingestion without issuing physical Stop; required |
| `catalog_revision` | text NOT NULL | Pins approved adapter/catalog, no default permissive adapter; required |
| `contract_enabled` | boolean NOT NULL DEFAULT false | Fail-closed gate until wire/auth/profile/time review; required |
| `registered_at` | timestamptz, server generated | Provisioning provenance; required |

No controller authentication secret is stored in a public table or Flutter
asset. Offline command/receipt keys, if selected, belong in reviewed protected
server/device storage with separate purpose/key rotation, not this review.
Replacement/EEPROM erasure must never silently reuse old counters under an old
identity. Administrator adjudicates epoch continuity or registers a new logical
controller without rewriting historical device references.

### 2.2 Private pilot authorization: `private.authorized_installations`

No existing private user/profile table was found in application schema.

| Candidate field | Type / rule | Purpose / MVP |
|---|---|---|
| `pilot_slot` | smallint PK, CHECK = 1 | One designated pilot enrollment slot; required |
| `installation_id` | uuid UNIQUE NOT NULL | Android logical identity; required |
| `wire_installation_alias` | text UNIQUE NOT NULL, `[0-9a-f]{16}` | Maps HW START/STOP `iid`; required |
| `auth_user_id` | uuid NOT NULL | Administrator-provisioned non-anonymous Auth subject; FK to supported Auth identity only after environment review; required |
| `authorized_session_id` | uuid NOT NULL | Binds a **verified signed session claim** to the pilot session; fail closed if unavailable; required for this candidate |
| `device_id` | uuid FK controllers NOT NULL | Allowed source; required |
| `active` | boolean NOT NULL DEFAULT false | Server-side revocation; required |
| `authorization_revision` | bigint > 0 NOT NULL | Server-controlled provisioning/replacement audit, not a caller-provided authorization token; required |

Registry row is administrator-only. A client cannot enroll itself or change
Auth metadata to grant access. The signed session claim's actual refresh/re-login
semantics require a test-project check: a client-supplied session/generation
header must never substitute for verified claims. For MVP replacement, enroll
a new pilot session through admin recovery; do not automatically trust a new
login. Before replacing the slot preserve an immutable admin audit of prior
installation/session/alias bindings; uploaded historical farmer namespaces need
explicit recovery permission, not merely the current slot. Reuse server audit
infrastructure if adequate; otherwise a private enrollment-audit table is a
required provisioning implementation detail to review, not silently omitted.

This is logical installation/session authorization, **not hardware attestation**.
Copied live session credentials can still impersonate it; Android secure storage
and any hardware-key possession requirement need Kath/threat-model agreement.

### 2.3 Existing sessions: additive fields only

| Candidate addition | Type / constraint | Need / existing reuse |
|---|---|---|
| `offline_batch_id` | nullable uuid UNIQUE | Required for new managed sessions; server `id` cannot be allocated offline |
| `device_id` | nullable uuid FK controllers | Required for managed sessions and scoped history; none exists |

Both fields are nullable on legacy rows. Proposed pair CHECK: either both null
(legacy) or both non-null (managed). Trusted ingestion requires non-null values
for new managed records, using a unique offline UUID globally; a repeated UUID
from another device conflicts rather than creating a new mapping. Existing PK,
session IDs, records, defaults and names remain preserved.

Reuse `egg_type`, original `egg_quantity`, `eggs_hatched`, `status`, `end_date`,
and settings snapshot `temperature`. No duplicate species/eggs_set/hatched_count
or percentage column is required. New completion is integer `0..original count`
with positive original count, validated in the transaction. Historical invalid
values must be audited before proposing global validated CHECK constraints; do
not delete/fix rows silently to make a migration pass.

Retain existing `incubator_sessions_single_active`. It guards lifecycle records,
not physical regulation or event uniqueness. A Stop leaves lifecycle Active
until validated manual completion; new ordinary batch admission before that
finalization needs explicit team policy. A conflicting hardware fact is retained
in the event ledger, not used to override the safeguard automatically.

Time projection for **new managed** rows: `start_date` is explicitly set from
trusted original Start evidence converted to a UTC wall timestamp; unknown Start
is explicitly SQL NULL, overriding `now()` by supplying null. Authoritative
timezone-aware instant remains in the event ledger. `end_date` uses trusted
farmer action time or null, never fabricated server time. Old rows retain their
unknown historical timezone/provenance; no blanket conversion is proposed.

### 2.4 Private immutable event ledger: `private.incubation_events`

Candidate location is private, not a generally writable public table. Authorized
read views/RPCs can later expose reviewed fields. Required because sessions
alone cannot deduplicate or recover pending/conflicting evidence.

| Candidate field | Type / rule | Purpose |
|---|---|---|
| `event_id` | text PK, canonical API key | Permanent deduplication identity |
| `receipt_id` | uuid UNIQUE NOT NULL, server generated | Stable committed receipt, no second receipt table required |
| `device_id` | uuid FK controllers NOT NULL | Source scope |
| `offline_batch_id` | uuid nullable | Original batch; null only unassociated status observation |
| `session_id` | bigint nullable FK sessions | Set only when an actual mapped session exists; may be null for conflict/dependencies |
| `event_kind` | constrained text | Exact candidate API semantic enum; not arbitrary client table/action |
| `command_id` | nullable text fixed hex | Original command or correlated STATUS query, never a numeric cast |
| `source_sequence` | nullable bigint, CHECK uint32 | Controller critical ordering; uint32 exceeds signed PostgreSQL integer |
| `occurred_at` | nullable timestamptz | Source occurrence time, not persistence time |
| `timestamp_valid` | boolean NOT NULL | Consistency CHECK: valid iff source time non-null |
| `canonical_event` | jsonb NOT NULL | Strictly validated semantic core and normalized source evidence, immutable |
| `content_sha256` | text, 64 lowercase hex NOT NULL | Server JCS/SHA-256 fingerprint; equality also verifies canonical data |
| `wire_evidence` | protected jsonb nullable | Original source-frame evidence only, no command MAC/token/secret |
| `first_phone_received_at` | nullable timestamptz | Untrusted clock diagnostic; not source-time repair |
| `first_submitted_by` | uuid NOT NULL, server derived | Initial authenticated uploader; not from body |
| `first_installation_id` | uuid NOT NULL, server derived | Initial authorized enrollment; not source device identity |
| `received_at` | timestamptz NOT NULL, server now at first ingest | Stable first persistence/receipt |
| `disposition` | applied / waiting_dependencies / conflict | Processing state, not physical state |
| `code` | constrained API receipt code | Why pending/conflicted |
| `receipt_revision` | integer NOT NULL >= 1 | Monotonic, changes only on committed processing changes |

Event kind/context conditional CHECKs mirror the API. A partial unique key on
`(device_id,source_sequence)` for controller transition kinds prevents a caller
renaming an existing source event. Observations/farmer actions have null source
sequence and separate identity namespaces. Command-context comparison prevents
reusing a command for different batch/action even under a different event ID;
do not make command_id globally unique across observation versus transition
families without the required semantics. One accepted Start projection per
offline batch and one manual completion per batch; duplicate semantic starts
under new source IDs are conflicts, not new sessions.

New managed events preserve original source and dependency IDs inside
`canonical_event`; JSONB contents are constrained/validated by trusted ingest,
not an open arbitrary blob. `offline_batch_id` cannot always FK to sessions while
evidence precedes projection; match its controller/identity transactionally and
add `session_id` only after verified mapping. Do not create dummy sessions for FK.

Immutable fields never change after acceptance. Disposition/session mapping/code/
revision are controlled processing metadata. Each metadata transition needs an
append-only audit containing old/new revision, reason, server actor and time.
Candidate `private.sync_processing_history`: event_id FK, revision, previous
revision, disposition, code, session_id, actor, changed_at; UNIQUE event_id/revision.
Required for controlled reprocessing/adjudication; it is not a second editable
source fact. Preserve original receipt time, identity and hash.

### 2.5 Reading provenance on existing `public.sensor_readings`

| Addition | Type / constraint | Why needed |
|---|---|---|
| `session_id` | nullable bigint FK sessions | Existing readings cannot identify a batch |
| `device_id` | nullable uuid FK controllers | Source attribution and sample uniqueness |
| `sample_id` | nullable text | Acquisition identity, unlike row PK |
| `boot_epoch`, `sample_sequence` | nullable bigint, uint32 CHECK | Lossless HW `ep,n`; recompute sample key |
| `measured_at` | nullable timestamptz | Original acquisition time, separate from legacy recording time |
| `timestamp_valid` | nullable boolean | Explicit validity for managed samples; null only legacy |
| `temperature_valid`, `humidity_valid` | nullable boolean | False requires null value; true requires finite validated value |
| `phone_received_at` | nullable timestamptz | First bridge receipt, optional diagnostic |
| `server_received_at` | nullable timestamptz | Exact timezone-aware new receipt instant without reinterpreting legacy recorded_at |
| `content_sha256` | nullable fixed hex text | Stable canonical duplicate comparison |
| `receipt_id`, `receipt_revision` | nullable UUID UNIQUE, integer >= 1 | Committed reading receipt; no duplicate sample creates a new row |
| `source_evidence` | protected nullable jsonb | Normalized reviewed TEL frame; not ordinary logs |
| `first_submitted_by`, `first_installation_id` | nullable UUID | Initial uploader provenance |

These are required **if cloud readings are enabled**, not prerequisites for
critical-only offline Start pilot. Managed samples require all identity/validity/
receipt fields except genuinely nullable source/phone times; legacy rows keep
null provenance. Unique `(device_id,sample_id)` and `(device_id,boot_epoch,
sample_sequence)` for non-null managed rows; transaction verifies session's
device agrees. A reading never creates or reassigns a batch.

`current_temperature`/`current_humidity` remain actual values. `recorded_at` is
preserved; new managed writes use server UTC recording time explicitly, with
`server_received_at` authoritative. No legacy time backfill. Receipt disposition
is always applied for stored readings; samples whose session mapping is missing
are rejected for later identical retry, not queued as complete rows.

Separate reading-backfill archive, latest-status table, stored hatchability,
dynamic profile editor and general multi-user/pairing tables are deferred. No
numerical target or new brooder/previous-incubation field is introduced.

## 3. Canonical data and transaction design

Detailed immutable-core algorithm is in the recovery document. Server derives
IDs from registry/wire components, translates bid losslessly, parses source UTC,
compares typed normalized data, computes JCS SHA-256 and then checks identity.
Do not trust a client hash or upload timestamp. Reordered keys/numeric formatting
must not create a second sample. A changed original source fact/count/profile/time
is a conflict, even if the server's previous projection is waiting.

Proposed transaction lock order: current pilot authorization row, controller
row, batch/session mapping, then affected event/dependency/receipt rows in stable
key order. All administrative revocation/adjudication operations use compatible
order. Lock the controller registry row even for a new batch whose session does
not yet exist: this serializes concurrent per-controller admission. Retain the
global existing Active unique index to settle conflicts with another controller
or legacy writer; catch/reclassify that specific conflict without losing valid
evidence. Never swallow unrelated DB errors as successful persistence.

After schema/auth/adapter checks:
1. Recheck active authorization/session/device under lock.
2. Find the identity. If same core/hash, return same receipt/current revision;
   changed core returns 409, original untouched. Authorization precedes lookup
   disclosure so revoked clients cannot read receipts.
3. Validate approved manifest and source/dependency constraints. Unknown batch
   metadata is not guessed from the current settings or current Active record.
4. Insert immutable valid event with receipt; project permitted lifecycle values
   only when dependencies/conflicts permit. Evidence may commit waiting/conflicted
   with no projected session change. Observations/fault events are evidence only,
   not physical commands or automatic Completed transitions.
5. Persist disposition/revision/history/mapping in the same transaction.
6. Commit before responding. Connection/commit ambiguity yields no success claim.

Dependency scheduler is server-side, bounded, idempotent and authorized service
work; not a hidden Flutter operation. Later dependencies may advance a waiting
receipt atomically. Conflict resolution requires admin evidence review; there is
no app operation for automatic override/delete/reassignment.

An offline Start->Stop->farmer-completed batch can be projected directly to final
Completed state once the whole valid chain is available. If an unrelated Active
row exists, do not insert an intermediate Active and then delete the safeguard:
retain conflicting evidence, wait for a complete chain and reviewed reconciliation.
No arbitrary timestamps decide which Active row is real.

## 4. Provisioning, authorization and revocation proposal

1. Admin retains independent dashboard/database recovery access and verifies it
   before restrictions. No admin/service key goes to Android.
2. Admin creates the non-anonymous pilot Auth subject through supported secure
   tooling. No public signup workflow is added; hosted Auth settings are not
   changed by this review. Do not read/print production users or tokens.
3. Provision Android's installation UUID and wire alias, and the controller UUID/
   alias binding through reviewed secure setup. Device/installation IDs are public
   identifiers, not credentials. Android stores session material using the reviewed
   platform secure-storage path, not Flutter assets, source or portal reports.
4. Authenticate and verify the actual signed session identifier on server. Admin
   pins that session in the private registry and enables only approved capabilities.
   Test refresh preserves authorized identity as expected; a new session must be
   reviewed, not automatically promoted by a supplied installation_id.
5. Every protected query/transaction rechecks private active subject/session/
   controller scope. A short token lifetime alone is not revocation.
6. Revoke registry row under lock, commit, then revoke refresh/session credentials
   using supported Auth operations. New protected reads/writes/replays after
   revocation commit must fail even with an otherwise unexpired JWT. An operation
   serialized/committed before revocation may remain; disclose this race boundary.
7. Replacement phone gets controlled new authorization and explicitly reviewed
   recovery scopes. No silent adoption of old unsynced farmer identities or new
   batch creation. Local lost data cannot be reconstructed from ID guesses.

JWT issuer/audience/signature/expiry and anonymous-user status must be verified
cryptographically, not by decoding unverified JSON. A bearer/client key without
approved subject/session registry membership is insufficient. If a verified
session claim or registry lookup cannot be established, fail closed.

The private registry must not be exposed through writable user metadata or an
unauthenticated function. Initial enrollment, registry writes, conflict resolution
and key rotation remain admin-only and are not bridge-sync operations.

## 5. Least-privilege matrix and bypass remediation proposal

| Actor | Read approved records | Direct session/settings writes | Direct readings/events writes | Bridge sync | Admin registry/adjudication |
|---|---|---|---|---|---|
| Unauthenticated anon | Deny protected data | Deny | Deny | Deny | Deny |
| Anonymous Auth user | Deny protected data | Deny | Deny | Deny | Deny |
| Other/revoked user/session | Deny | Deny | Deny | Deny | Deny |
| Designated authorized session | Scoped History/profiles/results | Deny direct; reviewed actions through sync only | Deny direct | Only allowed operation/source/device | Deny |
| Trusted ingest DB capability | Narrow lookups/projection | Narrow validated projection | Atomic insert/dedup, not arbitrary tables | Server-side execution | No provisioning/grant administration |
| Separate administrator | Governed recovery | Governed recovery | Governed recovery | Governed diagnostics | Allowed and audited |

Preset lookup may be intentionally public, but that must be an explicit reviewed
exception; this pilot proposal does not infer public visibility from current
grants. Historical rows with no device need an explicit legacy-read decision,
not automatic ownership assignment. Preserve data even when access is withheld.

LIVE VERIFIED prior inventory has permissive policies including `Anyone can
insert sensor readings` and authenticated `ALL` on sessions. A new restrictive-
looking permissive policy does not cancel existing true policies. Review the
whole matrix, remove excess client grants (including TRUNCATE, not governed by
RLS), lock sequences, and correct default privileges for new objects/functions.

RLS is mandatory for any exposed tables/views. Private tables are non-API-exposed,
schema/table grants deny client access, and reviewed policies/functions enforce
scope. If a security-definer helper is required, use a nonlogin least-privilege
owner, fixed safe search_path, qualified objects, no unsafe dynamic SQL, and
explicit EXECUTE ACLs. No default PUBLIC/anon/authenticated elevated execution.

Edge may require server-only elevated credentials in deployment-managed secrets;
never in source or on phone. RLS bypass makes validated server authorization,
transaction scope and narrow persistence interfaces essential. A truly narrower
DB role/capability is preferred; deployment choice requires operational review.

## 6. Security boundaries that remain unresolved

- Offline Bluetooth command authorization and MAC/key provisioning remain
  HW-02-05 BLOCKED. Registry/JWT checks do not solve an offline local link.
- A valid Android credential plus parsed source frames does not prove genuine
  Uno origin; retained source method and threat model need joint acceptance.
- RCPT_ACK's illustrative mac is not verifiable commit evidence as supplied;
  no plaintext receipt release is allowed. See recovery document.
- Full UI-02 secure-storage/session/outbox details are unavailable; summary only
  reviewed. Do not choose a plugin or change advertised Dart minimum here.
- Frame splitting, alias rules, RTC policy, approved profiles and journal bounds
  must be resolved before enabling adapters. No backend proposal relaxes them.

## 7. Test/review/deployment order (not executed)

Review additive schema and legacy compatibility first; only separately authorized
test-project migrations/identity provisioning may follow. Preserve admin recovery
before any RLS restriction. Test authorized/anon/other/revoked identities including
already-issued tokens, direct-write/RPC bypass, concurrent deduplication/revocation,
zero/max/invalid counts, missing dependencies, old Active conflicts and lost replies.
Compare original source, stored evidence and returned receipt. No synthetic record
goes into main data. Test project availability/resumption requires authorization.

Rollback is reviewed route disable + registry revoke + restrict ingest capability;
do not restore public write policies as a shortcut or delete evidence/History.
Verify denial after containment; Uno local regulation must remain independent.

## 8. Actual checks

Documentation/source review only here. Structural request/response and synthetic
canonicalization validation is recorded in the API document; that is not a SQL,
RLS, Auth, deployment, concurrency or hardware test. No SQL files were added or
run. This artifact is ready for joint review, not migration approval.
