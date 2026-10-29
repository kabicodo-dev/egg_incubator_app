# ORIGINAL:C-02 — K06-aligned communication contract candidate 1

**Task:** ORIGINAL:C-02 — Define JSON telemetry and command contracts  
**Owner:** Mary Charlyn (Cha/Mary: one person)  
**Prepared:** 2026-10-29  
**Document revision:** `ORIGINAL:C-02/candidate-1`  
**Disposition:** PROPOSED / NOT APPROVED / NOT IMPLEMENTATION AUTHORIZATION  
**Task status:** PARTIAL — documentation prepared; validation and acceptance pending

No firmware, Flutter, database, dependency or configuration change is authorized
by this document. No validation, test or build was run to prepare this revision.
The validator alongside this document is an unexecuted documentation tool.

## 1. Authority, provenance and original acceptance

### 1.1 Reference limitation

The requested `index_combined_FINAL_team_details(6).html` was not accessible in
the workspace or Downloads during preparation. The available reference was
`C:\Users\Mary Charlyn\Downloads\index_combined_FINAL_team_details.html`.
It is NOT represented as revision `(6)`. Its embedded K06 v0.5, v1.3,
UI-CONTRACT-03, INTEGRATION-CONTRACT-03 and original task record were reviewed.
The user's explicitly supplied established K06 requirements govern preparation.
Differences specific to `(6)` remain unchecked; record that comparison when the
exact file becomes available. Missing publication access does not reopen design.

The available portal's original `T("C-02",...)` definition is at physical line
364; the preserved `FINAL_DATA.tasks` / `originalRecord` is at physical line 507.
Embedded-source line numbers below refer to the saved Markdown text, not physical
HTML lines. Browser-local reports/statuses were not exported or inspected.
`Original-C02/review-1` was not located; none of its unseen findings is invented.

### 1.2 Exact original task criteria

| Field | Original wording |
|---|---|
| Dependency | A-01 findings |
| Inspect | Existing serial JSON in Flutter |
| Deliverable | Versioned schema doc (telemetry, START/STOP/STATUS, ACK, error) |
| Verification | Validate sample messages |
| Acceptance | Schema reviewed by Ally and Kath |
| Prompt | Draft a versioned JSON contract with device_id, chamber, batch_id, command_id, sample_id, seq, measured_at (nullable), timestamp_valid, validity flags. Propose and ask me before finalizing. |

This is a contract deliverable. Firmware/Flutter implementation, flashing,
physical safety, Bluetooth runtime and database/end-to-end verification remain
separate. Missing core definitions cannot be dismissed as merely missing tests.
No unsupported original requirement is removed by documenting current firmware.

### 1.3 Source identities and evidence scope

| Artifact | Identity / use |
|---|---|
| Firmware | `arduino/SmartHatch_Combined/SmartHatch_Combined.ino` at `80971f902d5634f7fed78ff073fcb78fa31be460`, supplied as ally-branch3 evidence |
| Firmware raw SHA-256 | `3721bce0eb48e654f2116a7ae2faa34d5d6af0bb57a7b1d11224f0ed68fa8dcb` — calculated from the exact remote commit and matched to supplied fingerprint |
| Evidence packet | `docs/evidence/a08/2026-10-29/` at that commit; existing logs/captures inspected, not rerun |
| Host linkage | `arduino/SmartHatch_Combined/host/start_host_sim.cpp:24` includes the actual sketch; other harnesses likewise include it |
| Capture correspondence | A-06 evidence capture and `test/fixtures/firmware/combined_a06_start_capture.ndjson` were byte-identical in read-only inspection |
| Manifest | All 17 entries in the committed `sha256sums.txt` matched calculated raw hashes in the preceding read-only review |
| Current local baseline during review | cha-branch2 / `c7a26cfcaa619708aff4f793e8068ee176a6cf58`; the newer commit was read remotely without fetching/checking out |
| Local older Combined | SHA-256 `a466a868e6c148cf4f9c3230378d5033d81db89dfb77a3e0fa53891d847a9598`; not substituted for the newer commit |

Remote source: <https://github.com/kabicodo-dev/egg_incubator_app/blob/80971f902d5634f7fed78ff073fcb78fa31be460/arduino/SmartHatch_Combined/SmartHatch_Combined.ino>

Historical provisional artifacts remain unchanged:
`../C02-provisional-communication-contract.md`, `../C02-provisional.schema.json`,
`../C02-provisional.examples.json`, `../validate-c02-provisional.cjs`.
They are a different proposal generation, not the implemented wire schema.

## 2. Established K06 requirements — not questions to vote on again

| Reference | Requirement carried forward | Classification |
|---|---|---|
| INT-01 / INT-02 | HC-05 Classic SPP, Android phone bridge, versioned JSON direction; USB diagnostic and ESP8266 historical | ESTABLISHED DESIGN; exact encoding still proposed |
| INT-06 | Uno retains independent immediate control and safety without phone/cloud | ESTABLISHED DESIGN; physical behavior not certified |
| INT-01 / CHA-04 | Selecting/expanding a species card must not initiate incubation | ESTABLISHED DESIGN; current source nonconformity is implementation work |
| OFF-01 | Offline Bluetooth Start with local admission; cloud does not cause/prove Start | ESTABLISHED DESIGN |
| OFF-02 | Durable offline identity/intent before dispatch; confirmed evidence retained; later immutable authorized synchronization; unknown outcome remains unconfirmed | ESTABLISHED DESIGN; storage/identity/recovery representation pending |
| OFF-03 / INT-02 | New live telemetry needs active connected online authorized bridge; retained events can sync later without Bluetooth; no guaranteed every-reading backfill/background bridging | ESTABLISHED DESIGN |
| OFF-04 | Local app startup must not require successful online initialization; local authority is distinct from cloud authority | REQUIRED DESIGN; implementation gap |
| INT-04 / CHA-09 | ACK, pairing, UI animation and cloud Active are not physical Start; no automatic physical START replay | ESTABLISHED INVARIANT, reinforced by user instruction |
| CHA-05 / CHA-06 | Fresh eggs, Chicken-first physical scope; Day 1 at substantiated original Start and subsequent days after 24 valid elapsed hours | ESTABLISHED DESIGN; no invented numerical profile |
| INT-03 | Incubator-only farmer scope; actuals separate from targets; preserve legacy records/hardware | ESTABLISHED DESIGN |
| INT-05 / CHA-07 / CHA-08 | Preserve source/batch/time provenance; invalid, stale and unknown age differ | REQUIRED SEMANTICS; exact flags/time/threshold mechanisms proposed |

Available embedded K06 source: OFF-01–04 lines 58–61; INT-01 lines 72–84;
INT-02 lines 86–98. Shared v1.3 §§1–3 supplies candidate lifecycle/identity/
framing invariants but remains NOT APPROVED. UI-CONTRACT-03 says CHANGES REQUESTED;
INTEGRATION-CONTRACT-03 says REQUEST CHANGE / NOT JOINTLY APPROVED. Their earlier
separate Cha/Mary labels do not create a fourth technical owner. No missing
approval is inferred from their recommendations or from this document.

## 3. Two views within one candidate; never automatic translation

1. **Observed profile:** exact well-formed command/output specimens from the
   pinned source, plus documented parser limitations. Source-shaped schema
   acceptance is not proof of actual parser enforcement or physical safety.
2. **K06 target semantic proposal:** review-only logical records, explicitly
   wrapped as `contract_profile: "K06-target-semantic-proposal"` with `family`
   and `body`. These wrappers and proposed field layouts are NOT serial bytes,
   deployed APIs or a chosen future wire revision. Do not transmit them.

The companion schema's root accepts either view. Validation always uses an
explicit named definition so observed messages cannot masquerade as target
evidence. Target record field names are proposals reusing original C-02 concepts;
ID alphabet/width/allocation, source authenticity, wire compression, capacity,
timeouts, key handling and final enum/code disposition remain PENDING APPROVAL.
No total frame ceiling is selected. No extra dependency or production fallback
is authorized. Target schema bounds are documentation structure only.

**Version lineage:** `ORIGINAL:C-02/candidate-1` is a document revision, not a
wire version. Implemented outgoing `v:1`, the historical provisional `v:1` and
v1.3 examples are different layouts. Do not silently reinterpret them. The target
record's `protocol_revision` names this proposal only; a final wire-version value
and rollout policy await D04 below.

## 4. Observed committed-wire contract

References `FW:n` below identify lines of the pinned firmware, not local old code.

### 4.1 Commands: implemented in source, selected scenarios software-tested

JSON input is `id` (numeric long), `cmd` (string), plus `batch_id` for START.
`processLine` is FW:816–838; `handleCommand` is FW:696–789. The schema describes
well-formed known command specimens, NOT every malformed string accepted by
substring extraction. Signed-32-bit schema bounds model nominal AVR long values;
the source does not comprehensively reject numeric overflow/invalid suffixes.

| Command | Current action | Evidence / restriction |
|---|---|---|
| STATUS | ACK then telemetry on first processing | FW:722–723,788; cached duplicate returns ACK only, no correlated snapshot |
| START | Positive batch id required; receipt ACK then conditional asynchronous RUNNING | FW:736–762,512–534; no confirmation-token field |
| NEW_BATCH / RESET | Clear Start record and create/reset batch state | FW:724–726; NOT STOP and not a deprecated confirmed alias of START |
| SELECT_CHICKEN / SELECT_DUCK / SELECT_QUAIL | Clear identity, apply profile, create/reset batch state | FW:727–735; conflicts with settled selection-not-Start requirement |
| TURN_NOW | Reject invalid incubator sensor or stage; otherwise emit progress, turn event and ACK | FW:763–770; not physical servo verification |
| STOP / RESUME / START_BATCH / commissioning/recovery command set | Unsupported in this revision | Do not import withdrawn claims or make them aliases |
| Unknown command | Rejected `unknown_command` | FW:771–772 |

Plain text is retained for serial-monitor diagnostics with synthetic IDs and no
batch argument. It cannot express a valid batch-bound START through this parser.
There is no incoming `v` check, authorization, strict unknown-key rejection or
`confirm` field. A public ID or a confirmation string would not authenticate.

### 4.2 ACK, RUNNING and errors

Common ACK: `type:"ack"`, `v:1`, numeric `id`, `cmd`, `status`.
Accepted adds `message`; rejected adds `error:{code,message}` and omits top-level
`message`. START additionally emits `command_id` equal to `id` and numeric
`batch_id`; zero is used for missing/invalid batch. Error sentinel id is -1.
See FW:618–661. State/correlation consistency is not fully expressible in JSON
Schema alone; the documentation validator adds narrow relational checks.

| Command / frame | Meaning and ordering |
|---|---|
| START ACK `start_received` | Receipt/admission only; sensors may still be invalid; outcome remains unconfirmed |
| START ACK `start_already_running` | Existing batch association, not independent physical proof |
| START `running` with `status:"running"` | After receipt ACK and producer confirmation; source/controller report only |
| TURN_NOW `running`, no status | In-flight progress BEFORE terminal turn ACK; not batch Running |

START confirmation requires valid incubator AND brooder readings at/after the
request reference and six output-latch comparisons (FW:493–534). It resets new
batch runtime at confirmation, associates batch id and saves the separate record.
It does not establish relay contact closure, thermal response or authorized
source provenance. Both-chamber coupling remains an internal implementation
dependency, not a new farmer-facing brooder requirement.

Errors: `unknown_command`, `incubator_sensor_invalid`,
`turning_disabled_for_stage`, `line_too_long`, `required_id_or_cmd_missing`,
`invalid_batch_id`, `batch_already_running`, `batch_already_complete`.
There is no standalone `type:error` family. START rejects missing/nonpositive id,
different active/pending batch, completed batch or unresolved restored identity.
If sensor/latch conditions cannot confirm, it remains pending indefinitely;
absence of RUNNING is neither success nor a known failed actuation.

### 4.3 Telemetry and events

FW:570–594 emits `type:telemetry`, `v:1`, `uptime_ms`, `egg_type`, `day`,
`hatch_day`, `elapsed_seconds`, `stage`, `batch_complete`, `incubator`, `brooder`.
Each chamber has pair-level `valid`, `temperature_c`, `humidity_percent`,
`bulb_on`, `humidifier_on`; incubator additionally has `fan_on`, `exhaust_fan_on`.

- False validity emits both values as null, not stale numeric values.
- Pair validity is not independently established per metric. Last good values
  can remain valid internally until timeout; emission uptime is not acquisition
  time. Source cadence/timeout constants are behavior, not measured relay age.
- Booleans are commanded software output states, not physical feedback.
- `day = floor(elapsed_seconds/86400)+1`; powered runtime is not verified UTC
  or outage-inclusive calendar time. Stage/duration completion is not Stop or
  farmer hatch completion. Existing profile values are not approved by this task.
- Telemetry lacks `device_id`, stable `batch_id`, sample/boot identity, sequence,
  source timestamp and `timestamp_valid`. Do not invent them on receipt.

Events: `batch_started` with species/day; `controller_ready` with protocol/baud;
`batch_state_restored` with species/day/runtime; `egg_turn_completed`.
No event ID or batch ID is carried. Invalid EEPROM/selection/reset can emit
`batch_started` without deliberate START, so that event alone cannot prove a
K06-compliant original Start. The boot restoration label is emitted even on a
fresh initialization path; it is not independent proof a valid batch was restored.

### 4.4 Framing, capacities and recovery limitations

Outgoing JSON ends in a single LF using `endFrame()` (FW:614). RX ignores CR
anywhere and accumulates into `serialLine[120]` (FW:154,840–854): up to 119
non-CR content bytes plus NUL fit the array. This does not prove UART service
capacity. No approved 63-byte or under-64 limit exists. The RX software ring is
a queue, not an immutable complete-frame ceiling. TX is streamed and separately
bounded by the future accepted Android/producer contract.

The current overflow branch clears accumulation rather than draining through LF;
suffix bytes can be interpreted subsequently. JSON extraction is substring-based;
unknown/duplicate keys and numeric suffix/overflow are not comprehensively
validated. The observed schema must not be advertised as enforced firmware.

Eight RAM ACK entries are looked up by numeric id before comparing changed
content (FW:685–719). Same-ID/same-content replay is software-tested; changed
content conflict and durable command recovery are not implemented. Same batch
with a new command can reassert RUNNING without resetting time. Batch identity
uses magic/version EEPROM at address 32, not a CRC-protected atomic event journal.
Host EEPROM memcpy/reload is not a torn-write/power-loss proof. Pending START has
no timeout. Internal re-confirmation is not an implemented public RESUME command.

## 5. K06 target semantic proposal — specified, not implemented

These clauses are the target contract requirements, not claims about the pinned
firmware. The companion `targetRecord` schema represents logical review records,
not a final byte-level wire format. Structural acceptance never grants authority.

### 5.1 Common identity, validity and time

Proposed review body: `protocol_revision`, `device_id`, `chamber`, `batch_id`,
`command_id`, `boot_id`, `sample_id`, `seq`, `measured_at`, `timestamp_valid`,
`payload`. All are explicit (nullable where specified), avoiding silent defaults.
`chamber` is `incubator`. Nonempty string identities are placeholder structure,
not selected UUID/token lengths, trusted credentials or an offline mapping.

`measured_at` means acquisition instant for TELEMETRY, current observation for
STATE, and occurrence instant for EVENT. Commands carry null/false source time.
Original Start is separately represented in STATE. Unknown source time stays
null/false; receipt time remains separate local metadata, never source repair.
The target proposes UTC RFC3339 when known; invalid-clock admission, retention,
age/skew and outage rules remain D05. No freshness number/profile value is chosen.

Source generation plus sequence/sample identity must have an accepted reset/
wrap/persistence policy. An adapter cannot label generated phone IDs as source
acquisitions. Original source and batch association survive delayed sync; do not
attach an old sample to whichever batch is currently Active.

### 5.2 Message families

| Family | Proposed logical payload | Required semantics | Implementation status |
|---|---|---|---|
| TELEMETRY | `temperature_c:{value,valid}`, `humidity_pct:{value,valid}` | Measured, not target; independent metric validity proposed; provenance/age distinct | Current different layout; target not implemented |
| START | `profile_id`, `profile_version`, `egg_quantity` | Explicit farmer action; original intent and dispatch marker durable before send; approved local authority/admission; no selection/boot start | Limited current START only; metadata/security/offline mapping absent |
| STOP | `reason` candidate `farmer_requested` | Match original batch; deliberate safe output transition; separate from lockdown/cycling/completion; retain truthful outcome | Unsupported; exact safe behavior D02 |
| STATUS | Empty payload, command_id is query identity | Read-only, no reset/settings/output mutation; obtain fresh matching observation and original outcome/gaps | Diagnostic current STATUS insufficient |
| ACK | `accepted`, `code` | Receipt/admission/rejection/prior outcome only; correlate original request; not Running/Stopped | Current other shape; target not implemented |
| STATE | `query_id`, `state`, `original_start_at`, `original_start_valid`, `evidence_scope`, `evidence_gap` | Fresh correlated controller report; original Start distinct; unknown remains unknown | Unsupported target exchange |
| EVENT | `event_id`, `kind` | Immutable original occurred transition/fault evidence; retention/recovery gap honest; never prepared intent as occurrence | Current one-shot events insufficient |
| ERROR | `code`, `detail` | Bounded typed diagnostics; no raw input/secrets, error loops or implicit lifecycle action | Current rejected ACKs only |

STATE candidate enum: IDLE, STARTING, RUNNING, STOPPED, FAULT, RECOVERY, UNKNOWN.
`evidence_scope` is `controller_report_only`; no software fixture certifies
independent physical feedback. EVENT kinds proposed: started, stopped,
fault_entered, fault_cleared. ACK codes and enum spellings remain proposed.
Profile references, positive count and safe integer schema constraints do not
approve numerical targets, biological capacity or a wire range on the Uno.

### 5.3 Lifecycle and recovery requirements

1. Local app bootstrap and offline intent precede cloud access; online refresh
   is separate. Do not use server bigint session identity as the only offline id.
2. Explicit START is sent only after durable intent/dispatch uncertainty and
   accepted local authority/admission. Pairing alone is insufficient.
3. ACK remains pending. A correlated controller report establishes only the
   evidence actually provided. Independent relay/thermal verification is separate.
4. Unknown outcome never becomes an automatic hardware resend/new id/new batch.
   Read-only reconcile; if original facts unavailable, retain Start Unconfirmed
   and block replacement Start until defined authorized recovery.
5. STATE current report and EVENT historical occurrence are not interchangeable.
   Same-ID/same-content no reexecution; changed content conflicts; original content
   and outcome scope must be recoverable or a precise narrower guarantee accepted.
6. Source retention must be bounded with explicit full/corrupt/gap policy; a
   stored intent is not an occurred transition. No auto batch from corrupt state.
7. Save confirmed original events locally and retry cloud submissions immutably
   later when authorized. Cloud retries are not physical command retries.
8. Disconnect/cloud rejection does not cause physical Stop. Only active bridge
   produces new live cloud telemetry; retained event sync needs no current BT.
9. No source erasure on generic ACK/HTTP success/phone hash. Accepted retention/
   release boundary remains D03/D06, without implementing DB-IMP-01 here.
10. Day 1 is original substantiated Start; 24-hour elapsed convention, trustworthy
    time reference and original identity persist. Unknown elapsed is not Day 1.

### 5.4 Target framing and parser requirements

Versioned JSON-LF over HC-05 Classic SPP. Exact CR/encoding/whitespace/extension
policy and RX/TX/Android caps await D04. Bound before processing; reject duplicate
keys, wrong types, unsupported versions, overflow and nonfinite values. Drain a
bad/oversized frame through delimiter; no suffix action or permissive text bypass.
Support arbitrary split/coalesced reads. Freeze all permitted field widths,
precision, optional/null variants and total maxima before claiming frame fit.
No binary/chunking redesign follows automatically from the software RX ring.

## 6. Source-to-contract compatibility and requirement disposition

Generic Flutter files at the pinned commit match local source after CRLF
normalization. `lib/services/start_handshake.dart` is a committed isolated helper,
not a replacement for the existing production sender/parser.

| Requirement | Source evidence | Gap / required disposition | Owner |
|---|---|---|---|
| General commands | `arduino_protocol.dart:191–211` sends string id/actuator/state; FW:816–826 expects numeric id/cmd | Exact selected producer/consumer schema, no silent name-only conversion | Ally/Kath/Mary |
| ACK fields | Flutter:265–275 reads success/string id/error; FW:633–661 uses status/numeric ids/nested error | Existing generic parser incompatible | Kath |
| START helper | `start_handshake.dart:18–24,46–99,122–150` serializes/parses/matches receipt then Running | Useful software model, no version enforcement/durable storage/transport hookup | Kath |
| Farmer Start | `lib/main.dart:2709–2747,2880–2889` saves cloud/settings then Started screen | Does not send START or consume RUNNING; K06 workflow correction required, not new architecture vote | Kath; backend handoff external |
| running variants | FW:666–682,763–779; generic parser:330–353 has no running case | Conditional order and routing required | Kath |
| Actuals/validity | FW:570–594; Flutter:151–175 reads temperature/humidity and top-level actuators | Key mismatch, pair validity not interpreted; missing false defaults must not mean Stopped | Kath |
| Telemetry identity/time | FW:574–594 has none of original device/sample/UTC fields | Explicit target identity/time disposition; cannot synthesize source evidence | Ally/Kath/Mary |
| STOP | FW:696–789 has none; provisional schema defines STOP | Retain original requirement; exact safe transition D02, not rename RESET | Ally; Kath/Mary review |
| STATUS recovery | FW:697–719,722–723,788 | No correlated current STATE/original outcome/gap response | Ally/Kath |
| Selection/boot/reset | FW:357–369,724–735 | Nonconforming batch creation; must change in later firmware task, not approved by this doc | Ally |
| Independent control | FW:427–491,903–911 runs without START | Autonomy is required; distinguish admission/occurrence from already-active regulation | Ally/Kath |
| Source persistence | FW:285–315,685–719; host EEPROM shim memcpy | No durable command/event journal/CRC/power-cut proof; guarantee needs D03 | Ally/Kath/Mary |
| Transport | `arduino_serial_io.dart:5–19,178–192` is libserialport, permissive decoding/residual clear | Actual Android SPP and bounded drain policy not demonstrated | Kath/Ally |
| Provisional artifacts | `../C02-provisional.schema.json:7–20,85–121` requires other envelope/strings/payload/status/error | Different proposal generation; keep history; never call observed fixtures valid against it by weakening provenance | Mary |

## 7. Existing evidence ledger — NOT a validation run for this candidate

| Reference at pinned commit | Existing recorded result | Evidence limit |
|---|---|---|
| `a02_check.txt:1` | 19 frames, 6 acked ids, 1 running, 3 structured rejections, LF-only | Capture/output shape, not strict input validation |
| `a03_checks.txt:110` | 109 host checks, 0 failures | Simulated control/pin transitions only |
| `a03_check.txt:1` | 59 telemetry: 56 valid, 3 invalid, 6 overheat, 1 brooder invalid | Chosen scenario invariants, not physical safety |
| `a06_checks.txt:49` | 48 checks, 0 failures, 39 lines | Selected Start/duplicate/sensor/latch/reload scenarios |
| `a06_check.txt:1` | 10 START ACKs, 7 RUNNING, 3 START rejections | MCU simulation; hardware-confirmed wording must not imply contacts/heat |
| `flutter_test.txt:214` | 209 tests passed | Reported full software suite; not production protocol compatibility |
| `flutter_analyze.txt:1–2` | Five items; no issues | Selected-file analysis, not whole project |
| `compile_a08.txt:1–3` | Flash 21142, globals 1781, static remainder 267 bytes | Low-memory warning; not runtime stack margin |
| `docs/a06_start_ack_running.md:207–245` | Reports 9 fixture, 8 handshake, 29 targeted, 209 total tests | Overlapping totals; no separate targeted log asserted here |

Build summary/compiler and documented ELF/HEX hashes are recorded evidence,
not independent reproduction. The manifest hashes captures/logs, not a signed
run-to-source attestation. Documentation still names older HEAD plus working-tree
changes; distinguish test-time provenance from the later committed packet.
`build_a06_host.txt` contains a source filename, not a full compiler transcript.

Assertions reviewed: accepted ACK is receipt-only; later matching RUNNING;
invalid/different/completed batch rejection; selected duplicate/no-reset cases;
sensor/latch waits; healthy-memory EEPROM reload; telemetry nulls and day formula.
Not covered: changed-content conflict, cache eviction guarantees, torn writes,
arbitrary corruption, real UART/HC-05, RTC/outage time, physical feedback, secure
local authority, production Flutter dispatch/outbox, DB transactions or E2E.
JSON parsers in capture checkers do not prove duplicate-key rejection by firmware.

### 7.1 Previous read-only byte calculations

| Exact specimen | UTF-8 content | With LF |
|---|---:|---:|
| `{"id":101,"cmd":"STATUS"}` | 25 | 26 |
| `{"id":102,"cmd":"TURN_NOW"}` | 27 | 28 |
| `{"id":301,"cmd":"START","batch_id":7001}` | 40 | 41 |
| START id/batch both 2147483647 | 53 | 54 |
| A-06 capture line 4 START ACK | 123 | 124 |
| A-06 capture line 6 RUNNING | 99 | 100 |
| A-06 capture line 7 telemetry | 401 | 402 |
| Largest observed frame in the inspected A-02/03/06 corpora | 406 | 407 |

These calculations predate candidate creation and concern exact specimens, not
accepted maxima. Outbound frames are not restricted by an inbound ring size.
The companion examples retain exact serialized specimens for future checks;
JSON numeric spelling (e.g. 49.0) is preserved separately from decoded objects.

## 8. Genuine unresolved decisions (no repeated K06 questionnaire)

| ID / clause | Exact missing decision | Why not derivable | Responsible acceptance |
|---|---|---|---|
| D01 Identity / §5.1 | Offline allocation, binding, representation, widths and reset/persistence of source/batch/command/sample/event identities | K06 establishes properties; numeric Start record does not implement full namespace | Ally/Kath/Mary |
| D02 STOP / §5.2 | Output-specific transition, allowed predecessor states, rejection/already-stopped behavior and retained outcome | No STOP handler exists; RESET is not substitute | Ally producer; Kath/Mary interpretation |
| D03 STATUS/retention / §5.3 | Correlated current/original evidence exchange, bounded retention/gap/full/corrupt policy and accepted loss cases | Diagnostic STATUS/volatile ACK/one-shot event cannot answer recovery guarantees | Ally/Kath/Mary |
| D04 Version/framing/capacity / §5.4 | Exact wire revision, aliases/types, supported alphabet/CR/extension policy, widths and separate limits/service budget | Multiple v1 layouts; source array/examples are not universal capacity proof | Ally/Kath; Mary consistency |
| D05 Time/confirmation / §5.1–3 | Accepted report evidence/labels; invalid-clock admission/retention; elapsed/outage/skew/age policy | No RTC; latch report does not establish physical actuation or elapsed calendar time | Ally; Kath/Mary map |
| D06 Local authority / §5.3 | Provisioning/session/replay/revocation boundary and required wire/session encoding | Pairing/public identifiers insufficient; implementation absent | Ally/Kath/Mary interface; DB implementation external |

Selection-not-Start, offline Start, Uno authority, no replay, cloud limitations,
fresh eggs and incubator scope are corrective requirements, not choices in D01–06.
These IDs are local candidate decision IDs, NOT historical freeze D01–D06 or
DB-IMP-01 subtasks. No answer, vote or sign-off is inferred.

## 9. Validation requirements and later authorized procedure

**Current candidate validation status: NOT RUN.** No output below is a PASS claim.
The `.schema.json`, `.examples.json` and `.cjs` are newly prepared and unverified.

The tool uses Node plus externally supplied Ajv 8 / ajv-formats, following the
older documentation validator pattern. Do not install dependencies or change
package/lock files as part of this task. After separate authorization, ensure
those modules are available through existing approved tooling, then invoke:

```text
node docs/contract-review/validate-original-c02-candidate-1.cjs
```

The script reads only these candidate schema/example files and prints results.
It does not run application/firmware, use network/serial/database, write files,
or rerun committed harnesses. Its execution still needs separate authorization.

Required coverage: schema compilation; every listed positive/negative fixture;
required/extra/wrong-type/version/identity/time/validity checks; duplicate JSON
keys (including escaped spelling); strict UTF-8 and LF fixture checks; narrow
ACK/RUNNING matching/order cases; exact specimen bytes; documentation-only target
roles and unknown-time/state cases. Observed vs target negative cross-profile
cases prevent accidental conflation. All target test data is synthetic, not an
approved profile, authority proof, hardware observation or uploadable event.

Still needed after decisions: exhaustive permitted-set maximum generator;
encoding/extension policy cases; every stream split/coalescing/overflow-resync
case for actual consumer; durable same-id/content/conflict/eviction/corruption
state modeling and later actual implementations. The current tool does NOT model
those runtime behaviors, authenticate frames or certify actual source acquisition.
Record actual command/tool versions, outputs and final artifact hashes later.
Any accepted revision change needs corresponding examples/checks and review.

## 10. Completion checklist and owner capture

| Criterion | Preparation status |
|---|---|
| Original criteria / K06 traceability | Prepared in this document |
| Existing Flutter inspected | Source-inspected; incompatibilities recorded |
| Exact committed producer and evidence | Source/hash and existing software packet inspected |
| Current telemetry/START/ACK/errors catalog | Prepared, software evidence scope explicit |
| STOP / complete STATUS / original identity-time requirements | Retained; target choices and implementation gaps outstanding |
| Candidate schema/examples/validator | Prepared; NOT RUN, not approved |
| Exact `(6)` portal comparison | Missing input, not silently substituted |
| D01–D06 candidate decisions | PENDING APPROVAL |
| Final-revision sample/boundary validation | NOT RUN; separate authorization required |
| Ally and Kath same-revision review | PENDING |
| Mary/user finalization acceptance | PENDING |
| ORIGINAL:C-02 completion | PARTIAL; not marked completed |

Capture reviewer/role, date-time-timezone, exact revision/artifact hashes,
ACCEPT or precise change, accepted restrictions and remaining contract blockers.
Ally supplies producer feasibility; Kath consumer/framing/recovery mapping;
Mary (Cha/Mary) artifact/provenance and external interface consistency. User
acceptance is required before finalizing. No review signature exists here.

Next within C-02: receive exact portal if available; obtain only D01–D06 technical
answers; authorize artifact revisions; separately authorize documentation
validation; capture actual results and same-revision acceptance. Contract-only
completion must explicitly leave firmware/Flutter implementation, physical
Bluetooth/safety and database/E2E tests separate. Do not advance another task.
