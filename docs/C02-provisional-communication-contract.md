# C-02 — Provisional communication contract

**Owner:** Cha · **Draft:** `0.1.0-provisional` · **Proposed wire version:** `v: 1`
**Date:** 2026-10-26 · **Status:** PARTIAL — FOR REVIEW, NOT FOR DEPLOYMENT

## 1. Authority, evidence, and scope

Baseline: the complete SmartHatch K06 v0.3 text supplied in the conversation,
explicitly authorized by the user for provisional C-02 drafting. All 17 decisions
were reviewed. The official file
`docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.3.md` is missing;
adding the authoritative copy is a separate documentation setup task.

Primary decisions: INT-01, INT-05, CHA-07. Supporting constraints: INT-02–04,
INT-06–07, CHA-01–06, CHA-08–09, HW-01. Approved design directions are not test
evidence. Proposed K06 details remain proposed.

**Every wire field, command capability, identifier provisioning/persistence rule,
device timestamp, status-evidence mechanism, and transport capability in this
draft is PROPOSED — PENDING A-01 VERIFICATION.** Validation here demonstrates
internal software consistency only. No Arduino, RTC, ESP8266, cloud, electrical,
or physical-control capability is claimed.

Scope: incubator only; fresh eggs for new batches; no brooder payloads, transferred
eggs, previous-incubation offsets, or automatic hatch counts. Uno retains local
control and safety even when communications fail. No profile targets are defined
here. No powered-load testing is authorized by this document.

## 2. Source inspection and compatibility

Inspected `lib/services/arduino_protocol.dart`, `arduino_serial_io.dart`, and the
earlier protocol/controller/test inspection in the task conversation:

| Current Flutter behavior | Draft difference / consequence |
|---|---|
| JSON object plus newline, USB default 9600 baud | Retain NDJSON framing and USB fallback; Wi-Fi framing is separately reviewed |
| `telemetry`, `command`, `ack`, `lcdUpdate`, `lcdAck` | Retain first three type spellings; add `status` and `error`; LCD extension deferred |
| Actuator command `{id, actuator, state}` | Lifecycle command `{command_id, payload: {action, ...}}`; incompatible without future implementation |
| ACK matched by `id` | Match explicit device/chamber/batch/command identity, not just a recent ACK |
| Flat/nested existing readings, brooder fields | Incubator-only typed `payload` with explicit validity |
| Invalid sensors become null; number/string coercion | Strict JSON numbers/booleans; invalid value must be null |
| Missing actuator reports default false | Unknown status is UNKNOWN, never fabricated OFF |
| App `receivedAt`; existing local freshness timeout | Separate source/event time and receiver time; do not reuse USB timeout as cloud threshold |
| No version/device/batch/sample/sequence metadata | Explicit identifiers and reboot epoch proposal |
| ACK model does not prove physical switching | Preserve that limitation; separate reviewed physical evidence gate |

The existing parser dispatches by `type` without checking `v`; feeding new nested
telemetry to it could produce misleading defaults. **Do not send draft frames to
the current app as a compatibility experiment.** Future version-aware parsing
must precede rollout. No Flutter, firmware, database, or production code changes
are part of this draft.

## 3. Transport and versioning

PROPOSED — PENDING A-01 VERIFICATION:

- UTF-8, one compact JSON object per LF-terminated line; receivers may accept
  CRLF. No comments, duplicate JSON keys, arrays as frames, NaN, Infinity, or raw
  text/debug output mixed into the message stream. Blank lines may be ignored.
- USB fallback remains 9600 baud. ESP8266 link/wiring, TLS implementation,
  maximum frame bytes, buffer sizes, cadence, retries, and timeouts are **TBD**.
  The current Flutter buffer limit does not establish Uno capacity.
- HTTP ingestion, if approved later, accepts the same logical single object;
  batch upload/offline queues are not assumed. NDJSON is serial framing, not an
  assertion that HTTP must stream NDJSON.
- `v` is integer 1 for this candidate; draft revision is separate. Strictly
  reject unsupported versions and fields instead of silently falling back to
  the old parser. A bounded recoverable request may get UNSUPPORTED_VERSION;
  malformed/untrusted input must not be echoed or cause an error-response loop.
- Review corrections may change provisional v1 before approval. After approval,
  incompatible wire changes require a new wire version; never reinterpret saved
  v1 data as v2. Roll back software to a known matching contract, preserving
  records. A version bump alone does not deploy or undo implementation changes.

## 4. Common envelope and identities

All frames require the following keys, including keys whose value is null.
The companion JSON Schema is `C02-provisional.schema.json` (draft 2020-12).

| Field | Type / rule | Meaning |
|---|---|---|
| `v` | integer, exactly 1 | Proposed wire version |
| `type` | telemetry / command / ack / status / error | Message family |
| `device_id` | nonempty bounded string | Stable incubator/controller identity, not phone ID or a secret |
| `chamber` | exactly `incubator` | No brooder messages in this contract |
| `batch_id` | ID or null | Original batch identity; null means unverified/no association, not current batch |
| `command_id` | ID or null | Correlation to one logical request |
| `boot_id` | ID or null | Proposed unique controller boot/epoch identity; needed for safe sequence reset |
| `sample_id` | ID or null | One captured sensor sample, not one upload attempt |
| `seq` | nonnegative integer or null | Uno-origin message sequence within its boot epoch |
| `measured_at` | UTC RFC3339 string ending Z or null | Telemetry acquisition time; for other Uno messages, event observation time |
| `timestamp_valid` | boolean | True iff `measured_at` is present and source clock was verified |
| `payload` | type-specific object | Defined below; no arbitrary extra fields |

IDs: proposed ASCII pattern `[A-Za-z0-9][A-Za-z0-9._:-]*`, maximum 64 characters.
These bounds are schema proposals, not verified firmware limits. Large sequences
must stay within JSON's safe integer range, 0 through 9007199254740991; practical
counter width/wrap must be reviewed with Ally. No ID string is an authorization
credential.

PROPOSED — PENDING A-01 VERIFICATION:

- Backend allocates batch identity once before Start; carry it unchanged to Uno.
  Existing bigint session IDs need an explicit future mapping to wire strings;
  no migration or automatic historical backfill is authorized here.
- App allocates command identity once per logical action and persists it for
  recovery. Retrying the exact same action uses the same ID and unchanged
  payload; reusing an ID with a different request is DUPLICATE_CONFLICT.
- Device ID is provisioned by the team and bound to the ingestion credential.
  Its storage and survival after reflash are unresolved.
- Uno-origin frames require non-null `boot_id` and `seq`. Commands have both
  null: sender command identity is separate from the Uno sequence.
- Sequence increases across ALL newly emitted Uno frames, not just readings.
  Replayed identical frames retain their sequence and IDs. Late frames do not
  overwrite newer state solely because they arrived last.
- Each new boot must have a distinct verified epoch; no claim of reliable Uno
  randomness or durable boot counter is made. If uniqueness cannot be ensured,
  sample identity is unverifiable and must be quarantined; do not invent an
  epoch from upload time. This is a deployment blocker, not a reason to discard
  otherwise useful diagnostic captures.
- Sample identity is unique per device across epochs; a proposed bounded
  encoding combines epoch and sample counter. Retransmission retains identity.
  ACK/STATUS/error have null sample identity; they are not new sensor samples.
- Null batch readings may be retained only as unassociated/quarantined
  diagnostics after a reviewed retention policy; never shown as active-batch data.

## 5. Message definitions

### Telemetry — Uno to receiver

`command_id=null`; `sample_id`, `boot_id`, `seq` required and non-null.
`batch_id` may be null for explicit unknown/idle association.

`payload.temperature_c` and `payload.humidity_pct` each contain
`{value: number|null, valid: boolean}`. True requires a numeric value; false
requires null. Humidity is percent, bounded 0..100 by unit definition. Temperature
sensor bounds and failure diagnostics await the actual sensor audit; no profile
target or unverified sensor model range is imposed. Validity means reported
sensor validity, not calibration, freshness, physical safety, or authenticated
origin. Receivers still verify provenance independently.

No actuator feedback is inferred from a temperature reading. Physical status uses
a separate status frame. Turning counters/relay-pin reports remain deferred until
A-01 confirms their semantics and size. This does not remove existing features.

### Commands — authorized sender to Uno

All commands require a non-null `command_id`; `boot_id`, `sample_id`, `seq`, and
`measured_at` are null and `timestamp_valid=false`. Command issuance time belongs
in a separate sender audit record, not a fabricated device timestamp.

| Action | Batch rule | Payload | Intended semantics, pending A-01 |
|---|---|---|---|
| START | Non-null | `action`, `profile_id`, `profile_version` | Request safe initiation of this fresh batch using an approved profile reference |
| STOP | Non-null | `action` only | Request batch control transition; NOT an unconditional all-relays-off instruction |
| STATUS | Nullable | `action` only | Read-only reconciliation; null asks what batch the controller actually holds |

Approved profile IDs/versions and their Uno mapping are not yet supplied. Schema
acceptance of a string is not proof it names an approved profile. Device/backend
must reject unknown profiles. Synthetic fixtures use `TEST_ONLY_NOT_APPROVED`;
it is never a deployable species profile or a target. No settings values or
previous-incubation fields are transmitted here. GET_READINGS is reserved for
review, not enabled by this draft. Species selection never emits START.

STOP output behavior, stages, and cooling/ventilation requirements must be agreed
with Ally; completion of a database record is not proof STOP physically occurred.
Batch mismatch must not stop another batch. A STATUS command must not start,
stop, reset progress, change profile, or create a new batch.

### ACK — Uno to sender

Echo exact `device_id`, `chamber`, `batch_id`, and `command_id` from the request;
`sample_id=null`. Payload:

`{received: true, accepted: boolean, code: null|error_code}`

Accepted means the request passed preliminary validation and entered controller
evaluation; it does not mean completed, applied, safe, or physically running.
Accepted requires null code; rejected requires a code. Subsequent failure can
still produce an error. ACK timeout means unknown outcome, not failure or success.
Replays may return a cached ACK plus current status without repeating actuation.
Cache scope/retention across resets is unresolved.

### STATUS — Uno to receiver

`sample_id=null`; `command_id` is the triggering request or null for unsolicited
status. `batch_id` is the controller's actual association, which may differ from
a STATUS query's requested batch. Never relabel it to match a request.

Payload fields, all required:

| Field | Values / meaning |
|---|---|
| `state` | UNKNOWN / STOPPED / RUNNING / ERROR — controller-reported state |
| `verification` | UNKNOWN / CONTROLLER_REPORTED / VERIFIED |
| `evidence_id` | ID or null referencing independently reviewable status evidence |
| `original_start_at` | Original verified UTC physical Start instant or null |
| `original_start_valid` | Boolean, true iff that original instant is present and trustworthy |
| `inspection_required` | Boolean or null; null explicitly means unknown |

VERIFIED requires non-null batch, command, and evidence identities, plus non-null
inspection flag; UNKNOWN state cannot be VERIFIED. VERIFIED RUNNING additionally
requires trusted original Start. These structural checks are necessary, **not
sufficient**. The receiver must authenticate the source and match the evidence
to this device/batch/command/boot and the team-approved physical observation
method before displaying confirmed Running/Stopped. A boolean, GPIO output bit,
cached Active row, sensor presence, or receipt of this JSON is insufficient.

If physical evidence is unavailable, use CONTROLLER_REPORTED or UNKNOWN, keep
Start Pending/Unconfirmed, and do not calculate a verified incubation day. No
physical-evidence mechanism is selected by this draft. A synthetic VERIFIED
example tests structure only; it is not status evidence.

`original_start_at` and `measured_at` have separate validity: a current valid
clock cannot prove restored original Start, and a stored trusted Start does not
prove today's clock. Never replace original Start with reconnect/upload time.
Day N = floor(elapsed_seconds / 86400) + 1 only with trustworthy original Start
and present elapsed-time reference. Negative/unknown elapsed time is unknown,
not silently Day 1. Backend UTC, UI Asia/Manila. Restarts retain inspection
warnings until affirmative farmer acknowledgment through a separately reviewed
path. No acknowledgment command for that workflow is invented here.

### Error — Uno to receiver

`sample_id=null`; use original command identity when parseable/trustworthy,
otherwise null. `batch_id` is known association or null. Payload:
`{code, detail}` with a fixed safe human-readable detail (1..160 characters).

Proposed codes: UNSUPPORTED_VERSION, INVALID_MESSAGE, WRONG_DEVICE,
BATCH_MISMATCH, DUPLICATE_CONFLICT, SENSOR_INVALID, CLOCK_INVALID,
UNSUPPORTED_COMMAND, UNSAFE_TO_START, INTERNAL_ERROR. Do not echo raw input,
credentials, exception traces, URLs containing tokens, or privileged settings.
No error response may implicitly change the active batch. Ingestion errors
belong to a separate HTTP/authentication layer; do not forge an Uno error frame
from server activity. Devices should not answer received errors with new errors.

## 6. Runtime validation and lifecycle (not enforced by JSON Schema alone)

PROPOSED — PENDING A-01 VERIFICATION:

1. Validate transport bounds, strict JSON, supported version, and structural
   schema before processing. Never coerce string sensor values or missing flags.
2. Authenticate the path; bind credential to allowed device and chamber. App
   identity cannot publish sensor/status evidence. Device identity cannot act as
   an administrator or arbitrarily create/complete batches.
3. Resolve original batch/device association. Wrong/unknown association is
   rejected or quarantined by a reviewed policy, never attached to current batch
   using receipt time. Reading A uploaded during B remains A's reading.
4. Deduplicate sample IDs. Exact retransmission may return already-received
   acknowledgment at transport level with no extra row; conflicting content is
   rejected. This is a proposed reconciliation of K06 duplicate rejection with
   safe retries, requiring team approval. Do not execute duplicate commands.
5. Sequence ordering is per verified boot. Out-of-order diagnostic data may be
   retained by policy, but cannot roll back current displayed state. Missing
   sequence values need not mean lost samples because ACK/status/error also
   consume sequence values. Counter wrap and new epoch handling await A-01.
6. Verify timestamps, future skew, clock trust and original Start separately.
   Allowed skew and freshness durations remain TBD; JSON format validation
   cannot establish source-clock accuracy. Server assigns `received_at`; device
   cannot override it. Record gateway/app receipt separately if needed.
7. Save once -> Start Pending -> ACK still Pending -> accepted authenticated,
   correlated, reviewed physical evidence -> confirmed Running. On timeout or
   restart query STATUS before any retry; preserve batch and command identities.
   Across reboot, do not replay START until persistence/idempotency is verified.
8. No cloud/serial connection is required for Uno's local safety loop. Unknown
   cloud state is not permission to change physical control. Safe restart and
   resume require verified sensors, persistent batch/profile, and safety checks.
9. Manual completion remains a separate backend workflow: required integer hatch
   count including zero, validate against original eggs set, calculate only with
   valid nonzero denominator, idempotently save exactly the intended batch, and
   verify persisted results. No wire hatch-count command or fabricated result.
   Physical STOP, batch lifecycle, and saved hatch results are separate facts.
10. Preserve historical records. Existing Active/start_date values cannot be
    automatically reclassified as physically confirmed evidence.

## 7. Freshness proposal

Sensor validity and time validity are independent. Proposed per-metric states:

| Condition after provenance/batch checks | Classification / live display |
|---|---|
| Invalid sensor flag | Sensor Unavailable; dash |
| Valid reading but untrusted/missing time or age rule not configured | Unknown Freshness; dash in live slot |
| Valid trusted measurement older than reviewed threshold | Stale / Reading Not Updated; dash |
| Valid trusted recent measurement within reviewed threshold | Fresh |
| Proven transport disconnect | Separate Incubator Disconnected indication; not proof local regulation stopped |

Timestamp-invalid telemetry retention is still a PROPOSED K06 choice requiring
Kath's approval. It may be useful diagnostically but is never fresh merely
because upload was recent. A last-known value must be separately labeled non-live
with its source/time. Numeric thresholds and future-skew tolerance await measured
cadence, delays, RTC drift, and Ally/Kath review. Do not adopt existing USB timing
as an ESP8266/cloud guarantee.

## 8. Communication/security boundaries and proposed test matrix

- Uno: local authority; validates target device/batch/profile and safety locally.
- ESP8266: proposed transport with separately provisioned revocable device
  credential; secure transport required. Never a service-role key or TLS bypass.
- Trusted server ingestion: authenticates device, validates schema and approved
  association, deduplicates atomically, supplies receipt time. If privileged DB
  access is necessary it stays server-side and narrowly scoped; least-privilege
  DB identity is preferred. Exact credential/provisioning/revocation design is
  C-03, not approved by this document.
- Flutter: one authorized revocable installation, approved reads/actions only;
  no general registration/pairing workflow. It cannot forge telemetry or status.
- USB: physical connection does not inherently authenticate the board. Prevent
  a competing USB/cloud command writer; cross-route deduplication and authorized
  operator access need review. Keep fallback until verified replacement.
- No authentication material in wire examples, payloads, source, or logs.
  Authentication headers/provisioning are outside the logical sensor envelope.
  Copying a device ID or setting validity/evidence flags must never authenticate.
- Current main-database open writes found by C-01 must be addressed before a
  restricted endpoint can be considered the sole ingress. No fixes/deployments
  are part of C-02; use smarthatch-test for later authorized security tests.

| Later security/runtime test | Expected result | Current evidence |
|---|---|---|
| Missing/forged/revoked device credential | Denied, no row/state change | NOT RUN |
| Correct device credential, well-formed associated sample | One accepted test row | NOT RUN |
| Flutter identity submits telemetry/status evidence | Denied | NOT RUN |
| Other/unauthenticated app reads/writes | Denied | NOT RUN |
| Payload device differs from credential | Denied | NOT RUN |
| Direct table INSERT bypass | Denied by reviewed grants/RLS | NOT RUN |
| Late A reading while B active | Never displayed as B | NOT RUN |
| Exact sample replay / altered replay | No duplicate row / conflict rejected | NOT RUN |
| Save-only, ACK-only, forged VERIFIED flag | Never confirmed Running | NOT RUN |
| START repeated via USB and Wi-Fi | No repeated action/batch | NOT RUN |
| Unknown RTC, delayed upload, future timestamp | No unsupported live claim | NOT RUN |
| Revocation while a connection/session exists | New protected operation denied | NOT RUN |

## 9. Synthetic examples and software-only checks

`C02-provisional.examples.json` contains complete example frames, each labeled
SYNTHETIC TEST FIXTURE. Numeric values are arbitrary parser inputs, not targets,
sensor captures, hatch results, or approved profiles. No fixture is for upload.
The examples cover telemetry with known/unknown time and invalid sensors; START,
STOP, STATUS; accepted/rejected ACK; unconfirmed/structurally verified status;
command-related and unsolicited errors.

Validation helper: `node docs/validate-c02-provisional.cjs` with an external
`NODE_PATH` supplying Ajv 8 and ajv-formats. No application dependency is added.
It checks the schema itself, valid examples, and expected-invalid mutations;
includes strict frame parsing, timestamps, required fields, enums, flags, and
cross-field structure. Results actually run are recorded in section 12.

Can be tested without hardware: structure, strict JSON/NDJSON framing fixtures,
date syntax, conditional fields, future parser unit tests, modeled correlation,
deduplication/retry/freshness logic with synthetic state. Modeling does not verify
Uno behavior or real RLS. Actual runtime services are not implemented here.

Cannot be verified by these fixtures: physical Start/Stop, electrical safety,
autonomous control, true clock accuracy, persistent identity/restart recovery,
Uno RAM/frame capacity, actual baud/wiring, device authentication/TLS, revoked
credential rejection, latency/cadence, real ingestion/DB matching, or a hatch.

## 10. Questions/evidence required from Ally (A-01)

All unresolved items below are PROPOSED — PENDING A-01 VERIFICATION.

- [ ] Exact flashed sketch, source commit/checksum, upload proof, libraries and
      hardware model IDs; which text/JSON protocol is actually emitted?
- [ ] Raw sanitized 9600-baud serial captures: readings, invalid sensors, ACK,
      error, STATUS, START, STOP (only commands actually supported).
- [ ] Can the Uno parse/emit this envelope within RAM and line buffers? Agree
      maximum frame bytes, number precision, counter width and malformed-frame
      resynchronization. Can debug output be kept out of NDJSON?
- [ ] Provisioned device identity, reboot-epoch generation, sample identity,
      duplicate cache, sequence wrap, persistence lifetime/EEPROM wear; what
      survives unplug, firmware upload, Uno/ESP reboot, and app restart?
- [ ] Exact START/STOP/STATUS semantics, wrong-batch behavior, duplicate/rejected
      requests, interlocks, and USB/Wi-Fi competing-writer policy.
- [ ] What independent physical feedback exists? Which observations establish
      Running/Stopped, who verifies them, how are evidence IDs resolved and
      bound to request/boot, and what cannot be verified by this hardware?
- [ ] Exact RTC model, initial clock setting, UTC/timezone conversion, validity
      checks, drift, Wi-Fi independence, backup battery/restart results; can
      original Start be trusted independently from current clock?
- [ ] Separate persistent batch/profile/original Start storage; corruption and
      unsafe-recovery handling, inspection warning/acknowledgment persistence.
- [ ] Actual sensor models, per-metric invalid/error rules, calibration limits,
      acquisition/send cadence, measured delays; do not invent freshness limits.
- [ ] Approved Chicken/Duck/Quail profile IDs/versions and mapping, supplied by
      the team; no new targets may be inferred from fixture values.
- [ ] Exact ESP8266 model, safe level shifting/power evidence, physical link,
      TLS/provisioning feasibility, reconnect and buffering behavior; do not
      assume offline durable queue or a deployed bidirectional command path.
- [ ] Documented qualified electrical clearance before any powered-load or egg
      test. Collect safe, authorized physical/end-to-end evidence separately.

## 11. Review and finalization gates

| Reviewer | Required decision | Status |
|---|---|---|
| User / Cha | Accept or revise provisional names, IDs, strictness and runtime rules | PENDING; drafting authorized, contents not approved |
| Ally | A-01 capability review, frame feasibility, command semantics, timestamps, identity and physical evidence | PENDING |
| Kath | Flutter mapping, farmer labels, null/unknown time policy, Start/completion distinctions | PENDING |

Before final contract: resolve or explicitly defer each blocking A-01 question,
agree approved profile references and limits, decide invalid-RTC retention,
agree evidence mechanism and review status fields, then revalidate revised
examples. Record reviewer/date/exact draft revision and corrections. No person
is marked approved by inference from the K06 design agreement.

Future implementation order: reviewed C-02 -> version-aware firmware/Flutter
changes in their own tasks -> test-only ingestion/identity/RLS implementation ->
positive/negative security tests -> safe authorized hardware/end-to-end tests ->
explicit integration/deployment review. Preserve Windows fallback and historical
records throughout. Stop after this draft; do not implement its runtime rules.

## 12. Actual validation record

Executed on 2026-10-26 with Node v26.4.0, Ajv 8.17.1 and ajv-formats 3.0.1.
Validator dependencies were installed in the approved external temporary directory,
not in the Flutter project. No Flutter dependencies or lockfiles changed.

PowerShell command used (the temporary path is tooling only, not a credential):

```powershell
$env:NODE_PATH = 'C:\Users\MARYCH~1\AppData\Local\Temp\opencode\node_modules'; node "docs/validate-c02-provisional.cjs"
```

Actual output:

```text
PASS: draft 2020-12 schema meta-validation and compilation
PASS: 14 labeled synthetic messages accepted
PASS: 65 schema-negative mutations rejected
PASS: 11 malformed/unsafe frame fixtures rejected
PASS: CRLF, trailing whitespace, and 2 status/time edge cases
NOT TESTED: firmware, physical Start/Stop, clocks, identity persistence, authentication, RLS, network, or hardware.
```

Initial tooling discovery found no usable Python executable and no preinstalled
Ajv module; Node and externally installed validator dependencies provided the
checks above. Nothing was uploaded or sent to a device. Stateful rules in
section 6 and the security matrix remain proposed and NOT TESTED. Review by
Ally and Kath is still pending: C-02 is Partial, not Completed.
