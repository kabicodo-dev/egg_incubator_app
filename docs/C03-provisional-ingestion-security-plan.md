# C-03 — Provisional trusted telemetry ingestion security plan

**Owner:** Cha · **Revision:** `0.1.0-provisional` · **Date:** 2026-10-26
**Status:** PARTIAL — documentation-only planning; endpoint NOT IMPLEMENTED
**Primary K06 decisions:** CHA-01, INT-02
**Dependencies:** reviewed C-02, A-01 source identity/capability findings, reviewed
persistence design and permission changes. Supporting constraints: INT-01,
INT-03–07, CHA-03–09, HW-01.

## 1. Scope and baseline

The user selected C-03 documentation-only security planning while waiting for
Ally/Kath's review. This document proposes future behavior; it does not authorize
deployment, credential issuance, migrations, permission changes, or powered tests.
C-04's authorized Flutter-installation provisioning is a separate task.

Provisional baseline: complete K06 v0.3 text supplied in the conversation.
The official repository file
`docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.3.md` remains missing:
record this as a documentation setup task, not a claim that a baseline was added.
Payload reference: `C02-provisional-communication-contract.md` and its schema,
revision `0.1.0-provisional`. Neither C-02 nor this design is team-approved yet.

**All security choices below are PROPOSED — PENDING REVIEW. All hardware-dependent
behavior is PROPOSED — PENDING A-01 VERIFICATION.** Do not interpret an expected
test outcome as a measured result. No new targets, readings, hatch counts, or
physical-verification capabilities are specified.

## 2. Inspected implementation and actual evidence

| Evidence | Observation | Limitation |
|---|---|---|
| `supabase/` source listing | Configuration and migrations; no `functions/` directory | Does not independently establish deployed state |
| C-01 live audit in task conversation, 2026-10-26 | Main project `egg incubator`: no deployed Edge Functions; no public RPCs | Dated evidence; not re-queried during this planning task |
| Same C-01 live audit | Public `sensor_readings` INSERT policy, broad grants/default grants; four application tables | No destructive/write enforcement test was run |
| `lib/main.dart:28` | Anonymous sign-in | Not a designated publisher identity |
| `lib/services/supabase_service.dart:290` | Direct sensor table SELECT | No telemetry endpoint invocation found in `lib/` search |
| C-02 draft sections 6–11 | Proposed schema, identity, time, deduplication and review gates | Firmware compatibility and physical evidence remain unverified |

The verified legacy sensor table has only `id`, `current_temperature`,
`current_humidity`, and `recorded_at`. It cannot hold the proposed source/batch/
sample/time provenance without reviewed persistence changes. Do not silently drop
those fields to fit it or insert synthetic test data into the main table.

## 3. Proposed trust boundary

```text
Uno actual capture
  -> ESP8266 transport with narrowly scoped publisher credential
  -> authenticated HTTPS telemetry endpoint
  -> atomic authorization + association + deduplication + persistence
  -> separately authorized Flutter reads
```

Uno retains all immediate regulation and safety decisions. Network failures,
credential revocation, server errors, and disabled ingestion must not become
control commands. USB remains a communication fallback; its publisher bridge
must not gain an unauthenticated alternate database-write path.

A valid publisher credential establishes which publisher sent the request. It
does NOT prove that the number came from a sensor or that the incubator is safe.
Compromised firmware/device credentials can still fabricate a correctly signed-in
payload. Source captures and matching end-to-end tests with Ally remain required.

### Initial endpoint boundary

Candidate: Supabase Edge Function named `ingest-telemetry`, POST with one JSON
object, `Content-Type: application/json`, over HTTPS. No bulk uploads/NDJSON HTTP
streaming until separately reviewed. NDJSON remains the Uno serial framing.

Accept **telemetry only** under a reviewed C-02 version. Reject command, ACK,
status, and error message families for this initial endpoint. In particular,
publishing `verification=VERIFIED` cannot mark a batch Running. A later status/
evidence-ingestion path needs its own reviewed authorization and semantics.

This restriction is an ingress subset of C-02, not a new wire version or a
firmware claim. No START, STOP, completion, profile update, inspection-warning
clearance, or arbitrary table/SQL action is exposed here.

## 4. Proposed per-device credential lifecycle

Candidate mechanism: an opaque bearer credential, separate from Supabase client
keys and Flutter identity. Proposed token structure contains a non-secret lookup
identifier and a cryptographically random secret generated at provisioning.
Use at least 32 random bytes for the secret; do not use device IDs, passwords,
MAC addresses, firmware constants, or timestamps as secrets.

1. **Provision:** an administrator creates the credential outside Flutter and
   firmware source. Bind it to exactly one provisioned device, chamber incubator,
   and telemetry-write scope. Credentials do not authorize arbitrary payload IDs.
2. **Store server-side:** retain a cryptographic verifier (proposed SHA-256 of
   the high-entropy secret), credential ID, device mapping, scope, enabled/revoked
   state, issue time, and any reviewed expiry. No raw publisher secret in DB logs
   or application tables. This is not password hashing; low-entropy user passwords
   must not be substituted into this design.
3. **Deliver:** transfer the secret through a team-approved secure provisioning
   channel. It is available only to the provisioner and assigned publisher;
   never paste it into portal reports, chat, source, example payloads or screenshots.
4. **Device storage:** runtime provisioning/storage and physical extraction risk
   require Ally review; no claim of secure-element or tamper resistance. No
   firmware-embedded service-role key, Supabase administrator credential or
   hardcoded real publisher token.
5. **Check every request:** fixed-format parsing, safe constant-time verifier
   comparison, active/expiry/scope/device checks. Unknown, malformed, wrong and
   revoked credentials produce the same generic unauthenticated response.
6. **Revoke:** authenticated administrator disables the publisher credential in
   a private registry, independent of changing device ID or recompiling the app.
   Never rely only on a long-lived cached allow decision. New ingest transactions
   must consult authoritative revocation state; registry failure denies ingestion.
7. **Race semantics:** serialize revocation and ingest authorization at commit
   (e.g. an appropriate registry-row lock/transaction). A write committed before
   revocation may remain; after revocation commits, no newly authorized write may
   commit with that credential. Exact transaction implementation awaits review.
8. **Rotate:** provision replacement, validate in test environment, revoke old
   credential, verify old denied/new accepted. Overlap duration, expiry and recovery
   process require explicit approval; no numeric lifetime is invented here.

Only administrator tooling may provision/revoke credentials. Neither ESP8266 nor
Flutter may list credential records, mint tokens, change scope or revoke other
publishers. A lookup ID alone has no authentication power. Missing/unconfigured
registry or pepper/configuration, if selected later, must fail closed.

Supabase gateway JWT behavior must be reviewed for custom opaque authentication:
do not blindly disable gateway verification or mistake the public anon key for
publisher authentication. Any route configuration permitting custom auth must
have mandatory handler authentication before all processing/persistence and be
covered by actual rejected-request tests. No config change is authorized here.

## 5. Proposed persistence boundary and least privilege

Logical design only; these are NOT actual table/RPC names or migration SQL:

- Private publisher-credential registry, inaccessible to client roles.
- Trusted batch-to-device association source; association must be explicitly
  provisioned/reviewed, not inferred from the latest global Active row.
- Telemetry store preserving original C-02 source fields and server receipt time,
  with atomic uniqueness for `(device_id, sample_id)` and appropriate boot/seq
  conflict handling. Preserve legacy records; no automatic ownership backfill.
- A narrow server-owned persistence operation, not a client-chosen table or SQL.
  It rechecks credential status, batch association and duplicate content within
  the same transaction. Request body cannot select DB roles or bypass policy.

Preferred DB capability: only the operations needed for credential verification,
association lookup and atomic telemetry ingestion. No rights to profiles,
completion, command creation, historical deletion, or administrative grants.
If a service-role credential is required by the eventual Edge implementation,
it remains server-side only. Its RLS bypass is a risk, not proof of least
privilege: review narrow interfaces, validate every untrusted field, and pursue
a narrower DB principal/capability where feasible. No client-executable elevated
RPC or default PUBLIC/anon/authenticated EXECUTE grant may remain on the trusted
persistence path. Any security-definer function requires owner/ACL/search_path
and SQL-injection review.

### Direct-write bypass gate

C-01 found an unrestricted sensor INSERT policy and excess table/sequence/default
grants. A protected endpoint does not fix those. Before calling ingestion secured:

- Review all existing sensor writers/readers and preserve approved reads.
- Review removal of unintended direct INSERT/UPDATE/DELETE and destructive
  privileges from client roles on the chosen telemetry store.
- Review RLS for authorized reads; C-04 supplies the designated Flutter identity,
  but C-03 does not implement its onboarding or provision it.
- Review default privileges so new telemetry/credential objects and RPCs do not
  inherit public write/execute access.
- Test attempted direct writes as anon, Flutter and unrelated identities.

Apply only approved changes to `smarthatch-test` first. Main-database migration
and permission changes require separate review. No historical deletion or schema
change is part of this task. Simply dropping one permissive policy is insufficient
if another permissive policy or elevated callable function still permits writes.

## 6. Proposed request processing order

1. Enforce reviewed method, content type and bounded request/header/body size;
   rate-limit credential/IP abuse. Exact limits await measured frame size/cadence;
   unset required bounds must block deployment, not default to unlimited.
2. Authenticate using the dedicated publisher credential before expensive payload
   processing; do not log Authorization headers, credentials, or raw bodies.
3. Decode a single strict JSON object; reject duplicate keys, invalid UTF-8,
   non-finite numbers, unsupported versions/types and unexpected fields. Do not
   assume the platform's default JSON parser rejects duplicate keys.
4. Validate against the reviewed C-02 telemetry schema without type coercion.
   Bind payload device/chamber to credential. No device-supplied `received_at`.
5. Resolve original batch-device association from trusted state. For the initial
   proposal, null/unknown/mismatched association is rejected with no telemetry row.
   Do not silently replace batch A with active batch B. Quarantine/diagnostic
   retention is deferred until its access/retention policy is reviewed.
6. Verify timestamp flag consistency and clock provenance. Timestamp-invalid
   retention is pending Kath/C-02 approval; deployment must choose an explicit
   rule. Format-valid timestamps do not prove trustworthy time. Future-skew and
   freshness limits await measurements; recent upload never makes stale data live.
7. Execute atomic credential recheck + association + deduplication + insert.
   Exact duplicate returns an already-stored result without another row;
   changed content with the same identity is conflict. Proposed equivalence uses
   validated canonical field values excluding receiver-generated times, not raw
   JSON text; review number normalization and timestamp precision before coding.
8. Store first server receipt/persistence time separately from source time. A
   retry must not overwrite original time or make an old sample look fresh.
   Delayed valid A data may be stored against A under the retention policy, not B.
9. Report success only after confirmed commit. An ambiguous DB timeout is not
   success; preserve IDs and reconcile/retry idempotently. Never invent a saved
   row, firmware ACK, physical state, hatch result, or measurement time.

Invalid sensor values must follow reviewed C-02 null/validity rules; an unavailable
sensor report may be useful data, but does not mean fresh measurement or safe
operation. No parsing rule may substitute profile targets for actual readings.

## 7. Proposed HTTP results (not Arduino ACKs)

| HTTP | Meaning | Stored effect |
|---|---|---|
| 201 | New authorized sample committed | Exactly one telemetry row |
| 200 | Identical already-stored sample | No second row; preserve original receipt |
| 400 | Malformed JSON/schema/version/type | No row |
| 401 | Missing/invalid/unknown/expired/revoked credential | No row; generic message |
| 403 | Authenticated credential lacks scope or device/chamber binding | No row |
| 405 / 413 / 415 | Method / size / media type disallowed | No row |
| 409 | Sample identity/content or boot/sequence conflict | No new row |
| 422 | Unverifiable batch association or rejected time provenance | No row |
| 429 | Request rate exceeded | No row |
| 503 | Required registry/storage unavailable or outcome uncertain | Do not claim success; reconcile by stable sample identity |

Responses use small fixed machine codes and a server request ID; no echoed token,
raw body, DB exception, verifier or stack trace. Suggested success fields:
`result` (stored/already_stored), `sample_id`, `received_at`, `request_id`.
These are a PROPOSED HTTP contract, separate from Uno's wire ACK; no `Running`,
`Completed` or `fresh=true` result is returned by this endpoint.

Authenticated requests may be logged using credential lookup ID (never verifier),
request ID, outcome and bounded source IDs where needed. Avoid attacker-controlled
log injection and redact proxy/platform HTTP traces too. Do not put bearer tokens
in URLs, query strings, crash reports or metrics labels. Retention and authorized
log access require review. Browser CORS is not authentication; Flutter need not
call this publisher-only route.

## 8. Test plan — every row NOT RUN

Local tests must generate temporary synthetic credentials at runtime, never
commit real or static usable credentials. Use C-02 synthetic payloads in isolated
memory/test storage; never upload them as genuine readings. Mocked persistence
proves handler logic only. Test-project tests require authorized setup and actual
identities, grants and persisted-row checks. Evidence records test ID, date,
environment, expected/actual HTTP result, row delta, pass/fail and sanitized log.

| ID | Scenario | Expected result / evidence | Planned environment | Result |
|---|---|---|---|---|
| C03-T01 | Valid credential, bound device, valid sample | 201; one committed row matching source | Local then test project | NOT RUN |
| C03-T02 | Missing credential | 401; zero writes | Local then test project | NOT RUN |
| C03-T03 | Random forged secret / wrong verifier | Generic 401; zero writes | Local then test project | NOT RUN |
| C03-T04 | Unknown lookup ID | Same generic 401 as T03 | Local then test project | NOT RUN |
| C03-T05 | Revoked credential | 401; zero writes | Local then test project | NOT RUN |
| C03-T06 | Expired credential, if expiry selected | 401; no grace-period guess | Local then test project | NOT RUN |
| C03-T07 | Valid credential, wrong device or non-incubator chamber | Device binding mismatch: 403; invalid chamber enum: 400; zero writes | Local then test project | NOT RUN |
| C03-T08 | Flutter JWT / anon key used as publisher credential | 401; zero writes | Local then test project | NOT RUN |
| C03-T09 | Valid credential with command/ACK/status/error body | 400; no lifecycle/state change | Local then test project | NOT RUN |
| C03-T10 | Malformed/duplicate-key JSON, NaN, wrong types/version | 400; no writes/coercion | Local then test project | NOT RUN |
| C03-T11 | Unsupported method/media type/oversized body | 405/415/413 before persistence | Local then test project | NOT RUN |
| C03-T12 | Unknown/null/mismatched batch | 422; no reassignment to active batch | Local then test project | NOT RUN |
| C03-T13 | Late A sample after B starts | Only A association; never B current | Local then test project | NOT RUN |
| C03-T14 | Exact repeated sample | 200; original row/time unchanged | Local then test project | NOT RUN |
| C03-T15 | Same sample ID, changed value/batch | 409; original row unchanged | Local then test project | NOT RUN |
| C03-T16 | Simultaneous duplicate requests | One row, consistent replay/conflict result | Transaction-capable test project | NOT RUN |
| C03-T17 | Changed sequence payload / reboot epoch collision | Conflict or reviewed quarantine; no false freshness | Local then test project | NOT RUN |
| C03-T18 | Invalid sensor with null / contradiction | Allowed unavailable report under policy / reject contradiction | Local then test project | NOT RUN |
| C03-T19 | Unknown RTC / future time / delayed upload | Reviewed time rule; never recent-upload-as-live | Local then test project | NOT RUN |
| C03-T20 | Client supplies server receipt time or extra fields | Reject; cannot override receipt/provenance | Local then test project | NOT RUN |
| C03-T21 | Registry or DB unavailable | 503; no false persisted-success claim | Local then test project | NOT RUN |
| C03-T22 | Commit succeeds but response lost | Retry has one row and original receipt | Test project with fault injection | NOT RUN |
| C03-T23 | Revoke racing ingestion | Commit ordering as section 4; post-revocation writes denied | Transaction-capable test project | NOT RUN |
| C03-T24 | Rotate old/new credentials | Old denied, replacement scoped/accepted | Test project | NOT RUN |
| C03-T25 | Direct table/RPC write bypass as anon/Flutter/other user | Denied by actual grants/RLS/ACLs | Test project; C-04 identity dependency | NOT RUN |
| C03-T26 | Publisher attempts profile/completion/admin/read mutation | Denied; no unrelated row change | Test project | NOT RUN |
| C03-T27 | Exceed approved rate limit | 429; no unauthorized writes | Local then test project | NOT RUN |
| C03-T28 | Inspect normal/error/proxy logs | No secrets, verifiers, raw headers/bodies or unsafe trace | Local then test project | NOT RUN |
| C03-T29 | Genuine Uno reading through ESP8266 | Capture matches stored row/provenance | Ally-authorized hardware + test project | NOT RUN |
| C03-T30 | Ingestion disabled/network lost | No cloud writes; Uno remains local controller | Software + separately cleared hardware test | NOT RUN |

Passing local T01/T03 alone does not complete C-03 security acceptance. Real
authenticated write, forged rejection, revocation and direct-bypass evidence are
needed before claiming a secured deployed path. A genuine-reading proof is a
separate integration gate, not satisfied by synthetic payloads.

## 9. Decisions needed before source implementation

- [ ] Cha/user reviews telemetry-only scope, opaque-token approach, private
      credential registry and commit-ordered revocation design.
- [ ] C-02 reviewed by Ally/Kath, or explicit authorization for changeable local
      implementation against its draft; no implication of final payload approval.
- [ ] Approve exact persistence design and mapping to verified batch/device IDs;
      no automatic ownership assignment or legacy-data deletion.
- [ ] Decide invalid RTC, unknown association, replay and timestamp precision
      policy with C-02/C-07/C-09; define configured size/rate/clock bounds.
- [ ] Ally reviews device provisioning/storage, ID/boot/sample feasibility, TLS
      certificate validation, actual frame sizes/cadence and source captures.
- [ ] Review Supabase gateway auth, server credential storage, least-privilege DB
      interface, default grants/RLS, logging and test-only rollback.
- [ ] Explicitly authorize test-project setup/deployment/permission changes;
      confirm smarthatch-test availability. No main-database deployment inferred.

C-04 remains separate: this plan needs its approved Flutter identity only for
cross-boundary tests; it does not add farmer login, registration or pairing.

## 10. Implementation order and rollback proposal

1. Review this design and C-02; resolve blocking choices above.
2. Implement local credential/validation/persistence interfaces and generated-
   credential tests. Report local outcomes distinctly from DB behavior.
3. Review test-only migrations/grants/credential provisioning and rollback, then
   apply only after authorization to the confirmed test project.
4. Test actual accepted/forged/revoked requests, direct bypasses and concurrency;
   check stored records and sanitized logs.
5. With Ally, verify genuine capture -> ESP8266 -> restricted test destination.
   No powered-load or egg testing without documented electrical clearance.
6. Review evidence and separately authorize integration into the main database.

Rollback/containment: disable route, revoke publisher credentials, and disable
server persistence capability using an approved operational path. Verify requests
are rejected afterwards. Endpoint removal alone does not close direct DB writes;
never restore an open INSERT policy as a rollback shortcut. Preserve historical
and ingested data. Required application reads/local Uno safety should continue.
Exact commands depend on the approved implementation; none are executed here.

## 11. Actual verification for this planning task

Source inspection and document consistency review only. No new live Supabase
queries, endpoint/auth tests, synthetic request execution, migrations, secrets,
deployments, firmware changes, Flutter changes or hardware operations.

The C-01 results cited above and C-02 validator results are prior evidence, not
C-03 test results. This plan is ready for review; C-03 remains Partial because
its endpoint implementation and accepted/rejected-request acceptance tests have
not been performed. The official K06 file still needs repository setup.
