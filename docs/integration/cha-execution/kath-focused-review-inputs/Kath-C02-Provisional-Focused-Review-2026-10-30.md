# Kath — focused C-02 provisional review response

Review date: 2026-10-30.
Prepared for Kath to review/send; not a signature or approval on her behalf.
**Overall disposition: CHANGE; exact shared-wire acceptance BLOCKED.**
No implementation, database, provisioning, deployment, flashing or physical test
is authorized by this response. This answers the ten requested items, not a new
competing contract. Keep the existing D01–D06 ledger as the decision register.

## Exact inputs

ZIP: `one combined review request to both Kath and Ally-20261030T083212Z-1-001.zip`.
Raw SHA-256 fingerprints of the five extracted inputs:

| File | SHA-256 |
|---|---|
| C02-provisional-communication-contract.md | `3559b60ace2b2d12e0a52304ed4ff1d9831a416b9a4edb5478d7ec359a69ddb7` |
| C02-provisional.schema.json | `9e95d34ca160cae8600548c5c4919ece26953d892d77bd786198d9e9e15461dd` |
| C02-provisional.examples.json | `155a44ed24f2c0627481822569c008b1ee332d315d72abe3bf9f09fc584275b5` |
| CONTRACT-FREEZE-01_Team_Decisions.md | `2ecf175119fcff30f512a9988a104c498468205ad1598c36bb147e51eaac60fa` |
| DB-02_30Oct_Consolidated_Alignment.md | `0c66ef938d5fd89628b70b14517f8ba602e766735fb87f381247d4dde4ca66a6` |

The first three are historical `0.1.0-provisional` inputs, not implemented or
selected wire schemas. References below use their actual line numbers.

## 1. Common protocol revision — BLOCKED

The provisional `type/command_id/payload.action` family is incompatible with both
the local actuator-only Flutter protocol and Ally's reported numeric
`id/cmd/START` family. START_BATCH/CONFIRM supersession also remains unanswered.
Do not select a revision merely because all candidates say `v:1`.

**Owner: Ally** supplies the supersession statement and one matching source,
uncommitted patch if applicable, catalog, toolchain/build records and raw fixtures.
**Kath + Cha/Mary** accept the same candidate bytes after review. The existing
packet already records source/build identities and limitations; no repeat audit
or replacement of attributed results is requested.

## 2. Actual schema and examples — CHANGE

### Findings and required revisions

| Reference | Finding | Requested change / owner |
|---|---|---|
| Contract :36,60–65,295–328 | USB fallback/ESP8266/device-publisher assumptions differ from selected Android HC-05 cloud bridge. In particular, denying all Flutter-origin evidence submissions would deny the authorized bridge. | Cha + Kath revise routing: authorized Android may relay captured source evidence but may not invent it. No ESP8266 credential/path assumed; USB diagnostic-only unless separately approved. |
| Contract :103–108 | Backend allocates batch identity before Start. | Change to Android allocating original offline batch UUID and command ID once, with durable pre-dispatch commit. Cloud bigint session is a later separate mapping. Final wire encoding requires Ally's approval. |
| Schema :7–20,85–95 | Mandatory verbose envelope, nested payload and ACK flags do not match local Flutter or reported numeric firmware. START also lacks quantity/original-installation context needed by later designs. | Replace/version-pin against the selected protocol, not a guessed adapter. Define immutable manifest binding/retrieval for original quantity/profile/actor; do not infer missing fields from current settings. |
| Schema :69–72,75,119–121 | ID bounds exist, but fractional UTC length and sensor-number precision/encoded size are not bounded; Unicode detail is bounded in characters, not UTF-8 bytes. | Ally + Kath freeze exact types, units, precision, string alphabet/byte limits and total RX/TX maxima. SQL/cloud bounds do not approve Uno buffers. |
| Schema :97–116; contract :201–212 | VERIFIED is a self-declared wire label, with no implemented independent physical-evidence mechanism. VERIFIED RUNNING requires UTC original Start, which the reported firmware cannot supply. | Keep controller-reported operation, independent physical verification, and clock confidence separate. Define source/correlation policy before a Running UI; never equate a JSON label or GPIO latch with physical relay closure. Do not fabricate UTC to unlock Running/day display. |
| Schema :10,101; contract :184–221 | No retained historical transition/event family or original-command outcome retrieval; current states omit pending/recovery distinctions. Inspection Boolean lacks incident-scoped persistence/acknowledgment semantics. | Ally supplies required lifecycle/recovery facts and schemas; Kath maps them to separate command/operation/evidence/clock/inspection states. Add only jointly approved families, not synthetic events. |
| Schema :71 vs DB-02 0.1 time rules | Provisional UTC permits fractional seconds; DB candidate specifies whole seconds. | Cha + Ally + Kath choose exact precision/conversion. No silent rounding of immutable original evidence or incompatible hash preimages. |

### Fixture disposition

- All four telemetry fixtures: **CHANGE** for selected schema/identity/size;
  **ACCEPT semantic rules** that invalid metrics are null, validity is independent
  per metric, and unknown source time stays null/false. Unassociated diagnostics
  must not populate an active batch.
- command-start/stop/status: **CHANGE**; not implemented command literals. No
  reviewed replacement STOP or complete STATUS exists yet, so do not invent them.
- Both ACK fixtures: **CHANGE** wire shape; **ACCEPT** ACK-not-Running meaning.
- All three status fixtures: **CHANGE** lifecycle/correlation/evidence definition;
  the VERIFIED fixture remains synthetic, not a physical pass.
- Both error fixtures: **CHANGE** to selected exact envelope/codes/correlation;
  **ACCEPT** bounded, safe diagnostics without secrets/raw-input echo.

Already documented report literals (diagnostic references, NOT approved live
instructions) illustrate the incompatibility:

```json
{"id":301,"cmd":"START","batch_id":7001}
{"type":"ack","v":1,"id":301,"command_id":301,"batch_id":7001,"cmd":"START","status":"accepted","message":"start_received"}
{"type":"running","v":1,"id":301,"command_id":301,"batch_id":7001,"cmd":"START","status":"running"}
```

Source: Ally's previously supplied `a02_ndjson_serial_protocol.md:79–100`.
These numeric IDs do not satisfy the preferred UUID/16-hex design; they are not
replacement production examples. Ally must provide the selected corrected
literal catalog, including STOP, recovery and confirmation rules.

## 3. Identities and duplicate handling — ACCEPT design; CHANGE contract

- Proposed Android design: batch UUIDv4 and 16-lowercase-hex command identity
  generated with a cryptographically secure source, once per deliberate action;
  uniqueness checked locally and identity/content retained durably before dispatch.
  Not implemented by the current local app; not approval of final Uno encoding.
- Administrator-provisioned installation/controller IDs remain distinct. An
  authorized relay uploader is not the original farmer actor or source controller.
- Source owns transition/boot/sample identities. Android must not synthesize
  controller event IDs/counters to satisfy a cloud adapter.
- Identical identity/content cloud submission is retry-safe; changed immutable
  content conflicts. This never authorizes automatic retransmission of physical
  START. Cache hits alone do not establish changed-content rejection.
- Late/foreign/mismatched controller, batch, command or connection-generation
  observations cannot confirm a current operation. Preserve evidence under the
  approved bounded policy without applying it to another batch.
- Reboot, counter exhaustion, reinstall and corruption cannot silently recycle
  source identities. Exact persistence and recovery rules remain Ally/shared work.

## 4. START, STOP and read-only recovery — CHANGE / BLOCKED

**Proposed Flutter presentation decision:** before transport, save original
intent (T1), then a conservative dispatch-may-have-occurred marker (T2). Show
Start pending/unconfirmed. ACK acceptance stays pending. Promote operation only
from matching approved controller evidence, labeled controller-reported rather
than independently physically verified. Missing/rejected/unrelated/late evidence
does not manufacture Running, Stopped or a new Start.

Timeout/disconnect/restart: retain unresolved operation and block replacement
Start; read-only reconciliation must retrieve original outcome and current
matching-batch state separately. Do not require receipt ACK to have survived if
later approved correlated outcome evidence can resolve it; recovery must cover
lost ACK, not enforce arrival-order artifacts.

**Owner: Ally** defines admitted/rejected STOP states, output safety policy,
timer handling, retained identity, fault/idle/full/corrupt storage behavior and
outcome evidence. Kath will not prescribe unsafe relay shutdown or invent STOP.
Pending START must have an explicit lifetime/cancel/recovery rule; a late sensor
recovery causing admission must not surprise a user who thinks the request ended.
UI timeout alone cannot cancel a pending MCU action.

## 5. Boot/reset and outputs — BLOCKED, Ally evidence

Accept no new batch merely from boot, RESET, selection, reconnect or sensor
recovery. This is distinct from approved safe continuation of a legitimately
existing batch. Require the selected source's transition/output table and checks
after valid sensor recovery, not just setup or absence of RUNNING. Blank/corrupt
EEPROM must not masquerade as a fresh trustworthy Day 1. No new physical test is
authorized by this response.

## 6. Frames and memory — CHANGE / BLOCKED

Actual compact UTF-8 counts calculated from the fourteen supplied messages:

| Example | Content bytes | With LF |
|---|---:|---:|
| telemetry-known-time | 334 | 335 |
| telemetry-unknown-time | 317 | 318 |
| telemetry-invalid-sensors | 323 | 324 |
| telemetry-unassociated-diagnostic | 310 | 311 |
| command-start | 314 | 315 |
| command-stop | 243 | 244 |
| command-status | 237 | 238 |
| ack-accepted-not-running-proof | 274 | 275 |
| ack-rejected | 291 | 292 |
| status-controller-reported-unconfirmed | 388 | 389 |
| status-verified-shape-only-not-real-evidence | 436 | 437 |
| status-unknown-after-restart | 367 | 368 |
| error-command-correlated | 329 | 330 |
| error-unsolicited | 299 | 300 |

The three app-to-Uno command examples exceed Ally's reported 119-content-byte
RX capacity (`serialLine[120]` including NUL). TX examples being larger than that
buffer is not itself an RX failure. These are literal counts, not maxima or
runtime feasibility proofs. No automatic buffer enlargement or binary switch.

**Proposed Android framing decision:** explicit LF; accept CRLF only if frozen by
the selected catalog; strict UTF-8/schema/version/types; reject duplicate keys;
bounded byte accumulation and discard-through-LF on overflow; clear incomplete
bytes on disconnect. Split/coalesced frames and exact limit/limit+1 require tests.
No final numerical Android/Uno limit is accepted until directional maxima and
Ally's service/stack/layout evidence exist. Keep cloud HTTP ceilings separate.

## 7. Authorization and retained evidence — ACCEPT scoped direction; BLOCKED mechanism

- Accept administrator-provisioned non-anonymous restricted cloud account plus
  separately approved installation/controller binding. Login alone does not enroll.
- Protected session material/local authorization secrets use reviewed Keystore-
  backed Android storage, excluded from ordinary preferences/logs/backups. Plugin,
  key behavior, protected evidence encryption and SDK floor require verification.
- Proposed startup: initialize/read local committed recovery state before online
  authentication; allow appropriately protected recovery display offline. Logged-
  out/revoked/expired/unknown eligibility blocks new sensitive commands and cloud
  sync as applicable, not autonomous controller continuation.
- Logout preserves committed evidence and recovery keys, checkpoints and closes
  Bluetooth; never sends STOP/RESET/START. Online revocation and offline pending
  revocation must be distinguished. Reinstall/replacement needs controlled enrollment.
- Accept null retention release and no HTTP-only/phone-forged source release.
  Do not approve a four-record journal's loss guarantees or erasure procedure
  before exact identity-aware layout/full/corrupt/service policy is supplied.
- Controller key/provisioning/replay/expiry/replacement mechanism remains Ally's
  feasibility work with shared acceptance. App checks are not controller auth.

## 8. Manual result versus lifecycle/admission — ACCEPT design amendment A/B/C

Reference: `DB-02_30Oct_Consolidated_Alignment.md:72–110`.

Accept manual bounded integer results independently of STOP; no Stop implication,
no automatic guard/admission release, unknown completion time remains null, no
sensor-derived hatch count. Preserve all four already supplied Ally conditions.

**Proposed concrete local decisions for recording:**

1. Editable draft belongs to the original batch/actor; display "Saved locally"
   only after durable commit. Save failure retains entered values and reports
   failure; never navigate to a false success.
2. If original quantity/batch validation is unavailable, preserve "Pending
   validation" rather than a validated result or guessed cloud session.
3. Once submitted, freeze action identity/content. Corrections use a separately
   reviewed correction path; do not mint replacement IDs to hide edits.
4. T3 commits accepted source evidence, projection and immutable upload outbox
   together. Manual validated-result/outbox commits likewise cannot split into
   "saved" without the required durable records. T4 commits verified receipt,
   original mapping and corresponding outbox state together.
5. Separate labels: local saved, waiting to sync, server result recorded,
   needs-help/conflict, cloud lifecycle and current controller observation.
6. Result alone leaves existing cloud Active guard intact. Finalization
   prerequisites are still a specific Cha/Ally/Kath decision, not implicitly
   "remove STOP requirement and set Completed". Unknown physical outcome blocks
   another Start until approved read-only recovery/adjudication.

No concrete amended API/result event/schema/plugin is approved by these design
choices. Cha supplies its versioned proposal and shared literal/hash fixtures.

## 9. Profile/time/freshness — ACCEPT truthfulness; BLOCKED numerical policy

- Retain existing candidate Chicken profile and seek the designated numerical
  approver; no restatement/new target values needed from Ally. Software sensor
  plausibility ranges are not incubation settings or calibration proof.
- Known original Start/elapsed basis, current clock and outage treatment are
  independent. No controller UTC becomes available merely because Android has a
  clock. Never fill original unknown time from receipt or reset Day 1 on reconnect.
- Unknown source UTC does not logically prevent controller-reported operation or
  all elapsed counters; any accepted monotonic-age/elapsed policy needs source
  continuity, freshness, reboot/outage rules and explicit labels. Do not require
  an independent relay sensor simply to display a truthful controller report.
- Accept display precedence by independent dimensions: invalid metric shows
  unavailable/dash; valid with unestablished age shows Unknown Freshness/dash in
  live slot; stale shows Reading Not Updated/dash; transport disconnect is separate.
  Any permitted diagnostic/last-known value must be explicitly non-live.
- Propose fail-closed **new Start eligibility** while required time/profile rules
  cannot be established, without stopping a running batch. No unapproved numerical
  freshness/skew/expiry lifetime or outage-counting rule is selected here.

## 10. Existing implementation and closure tests

**Source rechecked:** `lib/services/arduino_protocol.dart:191–211,265–275,330–353`:
actuator-only sender; legacy ACK shape; no version check or status/error dispatch.
`pubspec.yaml:7–17`: Dart floor 3.11, serial dependency, no direct SQLite/protected-
storage/Bluetooth dependency. Reported standalone handshake on Ally's branch is
not available here and is not current app integration.

### Actually performed in this focused review

- SHA-256/byte inventory for the five exact inputs; JSON syntax parse of schema
  and fourteen examples; compact UTF-8/LF byte counts above.
- Ran a temporary Dart probe importing the actual local `arduino_protocol.dart`
  and passing **all fourteen** supplied message objects to `parseArduinoLine`:
  - Four telemetry objects decode to **null incubator values** and all-false
    legacy actuator defaults, regardless of nested valid values.
  - Two ACK objects decode to **id:null, success:false, error:null**, including
    the accepted fixture; command correlation is lost.
  - Three status and two error fixtures are unknown incoming types.
  - Three outgoing command fixtures are also unknown to the *incoming* parser;
    that is not itself an incoming-parser bug. Sender incompatibility is separately
    established by the actuator-only serialization source.
- No new full JSON Schema validation was run: Ajv 2020/ajv-formats and Python
  jsonschema are unavailable locally; no dependencies were installed. Historical
  14-fixture/65-negative checks in the contract are attributed, not rerun here.
- No transport/build/hardware/security tests. Earlier 63 passing Flutter tests
  remain existing-behavior evidence, not revised-schema acceptance.

### Required closure checks, not claimed performed

Selected literal serializer/decoder and canonical hash fixtures; unknown version;
duplicate keys; UTF-8 and split/coalesced/exact-size/overflow streams; wrong and
late identities; independent validity/age; lost ACK and read-only reconciliation;
T1–T4 crash/disk-full/commit-failure/restart boundaries; no-internet startup;
logout/revocation/replacement scope; duplicate/cloud lost-response/conflict and
receipt regressions; manual result before Stop and occupancy races; login/restart/
reconnect/cloud retries never dispatch physical Start. Physical transport,
relay/load/sensor/RTC/EEPROM/power-cut evidence remains separately authorized.

## Minimal ledger entry requested

Record Kath's proposed positions item by item after she confirms them: CHANGE
historical wire/identity/transport assumptions; ACCEPT A/B/C independent-result
design and the concrete local rules above; ACCEPT no-replay/null-release/truthful-
state requirements; BLOCKED final source/schema/bounds/controller-auth/profile-
time and package/API choices pending named deliverables. Do not mark whole D01–D06
AGREED or tasks complete merely because this review response was prepared.
