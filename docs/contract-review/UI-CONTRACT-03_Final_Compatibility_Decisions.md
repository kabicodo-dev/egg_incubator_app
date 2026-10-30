# UI-CONTRACT-03 — Final Cross-Component Compatibility Decisions

Reviewer: Kath — Flutter UI/UX and Bluetooth communication. Date: 2026-10-28.

**Decision: CHANGES REQUESTED. End-to-end compatibility BLOCKED; no joint approval.** “Final” names this review deliverable, not a frozen protocol. No replacement wire schema is defined here.

## 1. Outcome and revision mismatch

The supplied latest HW-02 is **not a compatible correction of the catalog previously reviewed by UI-02 and DB-02**. It replaces the earlier `v/t/cid/bid/seq` batch protocol with a `type/id/actuator/state` or `payload` proposal, specifies USB rather than the HC-05 Android path, omits a defined explicit batch Stop, removes read-only STATUS and retained event replay, and supplies no original batch/Start identity on its example telemetry/events.

DB-02 is a useful concrete cloud candidate, with immutable canonical content, scoped authorization and committed receipts. It explicitly gates ingestion until source adapters are approved. However, its adapters/fixtures still target the **earlier** HW catalog, not the newly supplied files with suffix `(3)`. Flutter must not relabel the new messages as old `HW02-EVENT/STATE/TEL` evidence, invent missing IDs/times, or weaken DB validation to make them pass.

**Answers to the principal questions:**

- Flutter can encode the script's actuator Command shape, but that is not a defined offline batch START/STOP. Today's Flutter decoder cannot correctly interpret all latest responses. A future strict decoder is possible only after the ambiguities are resolved.
- There is no complete, correlated, durable batch Start/Stop and current-state recovery exchange in the latest packet. A separate top-level START message is not mandatory, but an exact explicit START operation with full semantics is; generic relay commands/species selection are not an equivalent.
- ACK is processing confirmation only. “Incubator reports Running” requires current correlated controller-state evidence, not relay flags, stopped turning, a sensor reading, a historical event or cloud Active. None independently proves actual load/relay response.
- A lost ACK must leave the command outcome unknown and must never cause automatic Start retry. The proposed duplicate-ID/commandAckSeq descriptions do not prove durable content-aware deduplication across reboot, eviction, new batch or corrupted storage.
- The latest no-retained-events design cannot guarantee recovery after phone crash/reinstall or a lost transition event. Mary cannot reliably deduplicate source transitions/samples without stable source identities and retained evidence. Cloud idempotency cannot recreate a missing hardware fact.

## 2. Inputs and evidence boundaries

All requested documents were available and read in full, including Mary's actual JSON schemas, examples and recovery/security text—not just summaries.

### Input key used in citations

| Key | Actual file | Review citation convention |
|---|---|---|
| V12 | `C:\Users\ACER\Downloads\SmartHatch_v1.2.md` | Original shared candidate, 255 lines; sections/J-issues |
| UI-W | [UI-02_Wire_Compatibility_Review.md](UI-02_Wire_Compatibility_Review.md) | Existing follow-up, 163 lines; earlier HW catalog, preserved unchanged |
| UI-R | [UI-02_Offline_Start_And_Recovery.md](UI-02_Offline_Start_And_Recovery.md) | Existing follow-up, 160 lines; local transactions/recovery |
| UI-U | [UI-02_Farmer_UI_State_Specification.md](UI-02_Farmer_UI_State_Specification.md) | Existing follow-up, 102 lines; independent farmer statuses |
| H-C | `C:\Users\ACER\Downloads\HW-02_Exact_Wire_Message_Catalog (3).md` | Latest supplied catalog; sections A–E |
| H-F | `C:\Users\ACER\Downloads\HW-02_Uno_Feasibility_And_Recovery (3).md` | Latest supplied feasibility; sections 1–6 |
| H-O | `C:\Users\ACER\Downloads\HW-02_Open_Decisions (2).md` | Latest Open Decisions, 61 physical lines; decision IDs |
| H-P | `C:\Users\ACER\Downloads\HW-02_count_frames (2).py` | Actual 189-line script inspected before execution |
| D-A | `C:\Users\ACER\Downloads\DB-02_Exact_Bridge_Sync_API.md` | DB-02 0.1-review, 407 lines; schemas/fixtures/adapter mapping |
| D-R | `C:\Users\ACER\Downloads\DB-02_Conflict_Receipt_And_Recovery.md` | DB-02 0.1-review, 305 lines; canonical core/receipts/recovery |
| D-S | `C:\Users\ACER\Downloads\DB-02_Proposed_Schema_And_Security.md` | DB-02 0.1-review, 363 lines; typed additive model/security |

H-C and H-F each have five physical lines because most Markdown contains literal `\n` escapes. Their complete contents were inspected using a display-only expansion of these escapes. No input was rewritten. Expansion also affects quoted newline notation, so wire LF bytes/counts were verified from H-P rather than inferred from display formatting. Section citations avoid misleading physical line references.

User calls the DB bundle Mary's proposals; all three documents label the owner **Cha**. “Backend (Mary/Cha)” below refers to that supplied bundle, not an invented separate approval. Confirm the named backend signatory before recording team approval.

### Evidence levels

- **SOURCE VERIFIED:** inspected local files and document contents; not physical behavior or the exact source from Ally's branch.
- **CALCULATED:** six supplied script fixtures reproduced, additional length counterexamples, DB JSON-block parsing and UART arithmetic. These are not maximum proofs or integration tests.
- **REPORTED ONLY:** DB-02's Ajv/JCS/model checks and earlier schema inventory; not rerun/live-queried here. Its prior live database statements are attributed to D-S, not newly verified.
- **BUILD NOT VERIFIED / PHYSICALLY UNKNOWN:** no AVR/Flutter build, memory measurement, firmware upload, physical Start/Stop, HC-05 exchange, RTC/power-loss or backend transaction/auth test performed.
- **PROPOSED:** all correction requests below. ACCEPT applies only to the named design invariant; it does not enable a source adapter or approve the whole contract.

Input revision fingerprints (SHA-256 of original bytes):

| Input | SHA-256 |
|---|---|
| V12 | `6814dc872f18ab1b54488c25ac1c4df7ae433c7bf62e5ba389262ee0a009bf47` |
| H-C | `37afae0d57277a22521450119ceb00382467caf1a58f03628cd8afc5bec89640` |
| H-F | `1dea144aea7dbbfdbd9fbb4d67057aa3af179f52e889933010e2ee09f2119ed5` |
| H-O | `b445c4b373cc79f1fede3068ba118f695db1c67d17bb557c380c0b7380d7acb8` |
| H-P | `b2bc944b46bb1535c7a181c8984a3b6cc99a28fb56df9beca9f9924e831fcb0b` |
| D-A | `5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab` |
| D-R | `08e6f97c7c320769e223218fbea7ce52a1d4a1b0ec5d117a83965d5678f39f06` |
| D-S | `6322985031a82d25184bd0ebefc7e1a9016d74c22b7e8d587e94dafb16d3f230` |

## 3. Cross-component decision table

**ACCEPT** = compatible design direction only. **REQUEST CHANGE** = concrete omission, contradiction or regression. **BLOCKED** = unresolved shared choice or insufficient feasibility/security evidence. No row invents a missing schema.

| Requirement | Ally's proposed behavior | Flutter requirement | Mary's backend requirement | Decision | Exact correction needed | Responsible owner |
|---|---|---|---|---|---|---|
| R01 — One shared revision (V12 approval gate) | H-C replaces prior batch catalog; H-O calls it only controlled contract | Match decoder/state machine to reviewed exact revision | D-A §§1,5 still references old aliases, START/STATUS/REPLAY/splits | REQUEST CHANGE | Declare latest H-C a competing revision, not jointly accepted replacement. Agree one catalog, then update UI/DB mappings/fixtures and pin content hash/revision. Preserve old reviews as revision-specific evidence | All three; backend signatory confirmed |
| R02 — HC-05 Android path, J-01 | H-C A.1 says USB serial; H-F labels HC-05 “USB serial” | RFCOMM Classic SPP to correct controller, with Android permissions/lifecycle | Cloud bridge depends on Android, not a Windows/USB controller | REQUEST CHANGE | Restore V12 HC-05 Android command path; label USB diagnostic only. Specify real HC-05 UART/rate/pins separately. Do not treat USB availability as Bluetooth verification | Ally + Kath |
| R03 — Firmware baseline and feasibility | H-F names Uno rather than candidate Combined; cites another branch and abbreviated hashes | Negotiate approved build/capabilities; do not guess flashed sketch | Pin catalog/source association; contract gate disabled until approved | BLOCKED | Team selects source baseline deliberately; supply exact revision, complete source hashes/toolchain and separately identify flashed firmware. Local source is not evidence of Ally's newer branch. Correct compile/memory evidence labels (§5 below) | Ally; Kath/backend review |
| R04 — LF JSON streaming | H-C proposes one object + LF; rejects CR as legacy | Byte framing across fragmented/coalesced reads, bounded queues | Strict ASCII evidence and independent HTTP ceiling | ACCEPT | Retain LF-only candidate; pin CR/NUL handling and supported character subset together. Acceptance is framing direction, not current parser implementation/size proof | Ally + Kath; backend adapter |
| R05 — Serial ring vs frame limits, J-02 | H-C A.1/A.8/D; H-O BYT-01/RCL-04 claim any frame >64 B inevitably overruns | Actual Uno RX line capacity/service budget, separate TX and Android RX limits | D-A HTTP caps must not become Uno limits | REQUEST CHANGE | Remove automatic 64-byte frame-ceiling claim. Assess software ring occupancy, interrupt blackout/consumer service, app line capacity, back-to-back burst and direction separately. No binary switch or arbitrary chunk size follows from ring capacity | Ally + Kath |
| R06 — Complete permitted-message size proof | Six fixtures labelled maxima/pass; declared actuator/device maxima not exercised | Worst-case escaped strings, Booleans, metrics, optional fields and every family | Versioned adapter enforces true wire limits | REQUEST CHANGE | Retitle fixtures as exact examples. Freeze field widths/alphabet/ranges and generate maxima including false, longest actuator, device31, rejection text, all events/optional fields. See concrete 93/97/209/115-byte counterexamples (§5) | Ally; Kath checks; backend pins limits |
| R07 — Strict parser and overflow recovery | H-F drops on timeout/overrun and says “no frame consumed”; exact strict schema absent | Reject duplicate keys/types/versions; drain bad frame through LF; no suffix execution | D-A §2 duplicate-aware validation before normalized evidence | REQUEST CHANGE | State exact required/optional/unknown-key/types/enums/version policy for every variant; drain invalid/oversized frame through delimiter, bounded timeout/error behavior, no unauthenticated legacy text fallback. Do not simply clear buffer and parse its suffix | Ally + Kath/backend |
| R08 — Command shape | H-C A.2 requires payload, A.4/H-P use actuator/state; key list chosenEgg/incubationDay/etc does not match actuator enum | Serialize one exact closed shape with explicit operation semantics | D-A requires batch/command/source metadata, not arbitrary actuator writes | REQUEST CHANGE | Reconcile payload vs flat command in one schema and fixtures. Define allowed fields/enums/types and explicit lifecycle operations; raw relay commands cannot stand in for Start/Stop. Don't add brooderStart to incubator pilot | Ally; Kath/backend review |
| R09 — Explicit deliberate batch START, J-04 | Selecting batch via generic command; no exact Start operation/preconditions/result | Immutable batch/command/profile/quantity and explicit farmer action, no start on selection | D-A started needs accepted transition evidence and original metadata | REQUEST CHANGE | Supply exact explicit batch START operation (may be a command subtype), admission/rejection/duplicate rules and durable correlated occurrence evidence. Selection/reset/boot must not start. Do not invent missing keys in Flutter | Ally; Kath/backend; profile approver |
| R10 — Explicit matching-batch STOP | H-F §5.2 equates false actuators/turning inactive or TURN_STOPPED lockdown with stopped incubation | Deliberate batch Stop; separate from lockdown and farmer completion | D-A stopped requires real stopped event, original command and predecessor Start | REQUEST CHANGE | Define exact matching-batch Stop operation/result and safe shutdown semantics. Turning stops at lockdown while incubation continues; thermostat off is not stopped. Include journal-full safety behavior without falsely claiming persistence | Ally; Kath/backend |
| R11 — Current state after reconnect/reboot | No read-only status; periodic sensors/events allegedly reconstruct state; GET_STATE mentioned but undefined | Fresh correlated query/snapshot with identity, batch, state and observation recency | D-A STATE adapter/query_id; observations never create missing Start | REQUEST CHANGE | Restore exact read-only current-status exchange or jointly specified equivalent meeting V12. Define GET_STATE if retained; include original batch evidence and version/binding, not reset/selection. Periodic sample alone cannot reconcile unknown Start | Ally + Kath; backend mapping |
| R12 — HELLO/capability/identity binding | APP sends hardware/fw/deviceToken; hello_ack only accepted/rejected text; no query echo or returned source identity | Controller reports/verifies its identity/version/capabilities; match fresh exchange | D-S registry dev alias/device UUID; iid/installation UUID distinct | REQUEST CHANGE | Resolve who generates/reports token and identity, exact lengths, provisioning and handshake correlation. An app's claim of firmware identity is not firmware proof. Map public controller identity separately from install credential; add real compatibility/auth result before commands | Ally + backend; Kath |
| R13 — ACK versus physical evidence | H-C correctly says ACK not relay verification, but sole command-processing confirmation; status type ambiguous | Match immutable command; never Running/Stopped from ACK | D-A ACK alone not source transition evidence | REQUEST CHANGE | Preserve no-physical-proof rule; freeze status as exact typed enum and map admitted/rejected/prior outcome. `status:replay` must return original immutable outcome/content association, not a substitute Start event; resolve H-C replay flag vs status inconsistency | Ally + Kath; backend |
| R14 — Lost ACK / duplicate Start | Duplicate in-flight ID returns replay; commandAckSeq proposed; consumer reset at BATCH_START | No automatic actuator replay; read-only reconciliation across reboot/eviction | D-S command-context and source-event comparison; same ID changed content conflicts | BLOCKED | Persist command ID + immutable command content/outcome/batch linkage and scope; same ID/same content no re-execution; changed content conflicts; new ID while active cannot replace batch. Define retention/exhaustion/corrupt recovery. Numeric ACK sequence alone is insufficient | Ally; Kath/backend |
| R15 — Batch/quantity/species/profile preserved, J-03/J-11 | Latest wire lacks bid/qty/profile version; manifest only eggType/epoch/day/commandAckSeq | Stable original batch plus quantity/species/approved profile across crashes/reinstall | D-A startedData + original positive count + immutable profile; one UUID→one session | REQUEST CHANGE | Specify durable manifest and authenticated/recoverable evidence linking original command, batch UUID/token, quantity, species/profile snapshot/version and Start. Do not infer from latest settings or attach current batch to old sample. Approve quantity rule (app6..12 vs DB structural1..intmax is not hardware capacity) | Ally + backend + Kath; profile approver |
| R16 — Stable event/sample identities | Event code+payload; no durable event seq; telemetry device UNO_R3+uptime u, no boot/sample ID | Lossless original event/sample identity, original epoch, replay dedup | D-A controller:UUID:seq / sample:UUID:ep:n require non-reused source components | REQUEST CHANGE | Supply persistent source/event and reboot-safe sample identity/counter semantics or jointly revise all three contracts. Board model/uptime/phone-generated event IDs do not authenticate or uniquely identify a source acquisition | Ally + backend; Kath |
| R17 — Retained critical evidence, J-05 | One-shot EVENT, no firmware replay; power cycle discards events | Recover lost confirmation/partial evidence via read-only retained result | D-R §8 assumes retained journal and STATUS/REPLAY; source proof before projection | REQUEST CHANGE | Restore bounded retained critical-event/outcome recovery with explicit gap/full/corrupt policy, or request explicit team-approved narrower loss guarantee. Do not call command ACK replay equivalent to critical event replay | Ally; all approve loss boundary |
| R18 — Corrupted EEPROM/power loss | H-F resets corrupt commandAckSeq to BATCH_START, app GET_STATE undefined; token and manifest address descriptions overlap | No new batch/time/ID from reset; mark RECOVERY/unknown until evidence reconciled | D-S no reused counters or automatic device rotation; D-R original Start unchanged | REQUEST CHANGE | Replace BATCH_START reset with defined safe recovery without fabricated Start; byte-level nonoverlapping journal/config map, generations/CRC/commit markers, phase and power-cut table. Two update calls not atomic; committed intent ≠ occurred transition | Ally; Kath/backend |
| R19 — RTC/source time/day, J-06 | millis/monotonic µs only; RTC called optional if wall time needed | Verified original Start + reliable elapsed reference; day unknown if unreliable | D-A UTC source instant or null/false, separate phone/server receipt | REQUEST CHANGE | Preserve V12 RTC design and explicitly decide invalid-time admission/outage policy; no µs→UTC reinterpretation or receipt-time Start. Define acquisition/event units/ranges and trustworthy original Start recovery. No app-set day repairing missing physical evidence | Ally + Kath + backend |
| R20 — uint64 accuracy | u/time max 18446744073709551615 in script | Lossless typed parsing; no float intermediary | D-A uint32 epoch/counters and JCS IEEE754-safe normalization; no u64 adapter | REQUEST CHANGE | Freeze a lossless cross-runtime representation/range and reset/overflow rules; do not cast uint64 max into signed Dart int/double or JCS Number. Restrict range or adopt a jointly approved representation; current u64 fixture is not compatibility proof | All three |
| R21 — Reading validity/freshness, J-10 | Sensor-wide valid and null invalid values; “fresh within threshold” conflated with false iff NaN/out-of-range; u timestamp semantics unclear | Independent metric validity and acquisition age; duplicates/delays don't become fresh on arrival | D-A per-channel flags, measured_at validity, boot/sample IDs | REQUEST CHANGE | Keep null for invalid actuals; define each metric validity, stale behavior, source acquisition vs emit uptime, clock validity/age, cadence/skew/threshold. If joint sensor validity intentionally retained, team must approve reduced semantics; no fabricated per-channel success | Ally + Kath + backend |
| R22 — Target ≠ measured; cloud Active ≠ Running | Relay/setPoint proposal and missing operation snapshot invite inference | Separate target, actual, operation, connection, storage and cloud badges | D-S existing temperature is setpoint; status lifecycle only | ACCEPT | Preserve separation already required by V12/UI-02/DB-02. Correct existing Flutter fallbacks later; this rule supplies no missing controller-state proof | Kath; Ally/backend evidence |
| R23 — Phone offline/closed; durable intent/outbox, J-12 | Firmware one-shot events; no phone crash-resend policy made concrete | Local startup before online auth; T1 intent, T2 dispatch marker, T3 event+outbox, no hardware retries | D-R §5 explicitly aligns with these local transactions | ACCEPT | Accept UI/DB local design invariant; do not claim implemented. Fail closed on insufficient authority/store; show unknown outcome vs known report/save failure separately. Source recovery remains blocked by R17 | Kath; Ally retained evidence; backend |
| R24 — Offline local authorization, J-08 | Explicitly not supplied; deviceToken identity only | Authorized designated phone without mandatory online login; revocation/lost-phone policy | D-S says server JWT registry does not authenticate Bluetooth/source | BLOCKED | Agree offline owner/provisioning/key/session/replay design and threat model feasible on Uno; public token/name/MAC/hello accepted cannot authorize. Online revocation is not immediately knowable offline | Ally + backend; Kath UX |
| R25 — DB source adapters | Latest messages type/ack/event/sensors, no old v/t/dev/seq | Cannot silently translate absent facts | D-A schema evidence enum and semantics expect old EVENT/STATE/TEL, splits disabled | REQUEST CHANGE | Backend stays CONTRACT_NOT_ENABLED; jointly revise adapter revision/schemas only after canonical hardware decision. No permissive fallback, generated source IDs, fake null-time complete records or reinterpretation of SENSOR_INVALID as started/stopped | Backend + Ally; Kath |
| R26 — Canonical dedup/transaction design, J-09 | No matching source identity in latest wire | Immutable same-event retries, hash validation and stable session mapping | D-A §7; D-R §§2–4; D-S §3 JCS/SHA256, same-key conflict, atomic receipts/projection | ACCEPT | Accept cloud design direction subject to valid source contract/runtime tests. Keep identity+canonical-content comparison; don't claim deployed reliability or source authenticity from hash. Pin normalized object/adapter and original manifest facts | Backend; Kath + Ally source linkage |
| R27 — Applied/waiting/conflict receipts | H-F says backend signs receipts, without delivered channel | Synced only exact applied receipt/hash/identity/revision; no release on HTTP success | D-A retention_ack always null; response is not a signed Uno-release artifact | REQUEST CHANGE | Correct “backend signs receipts” as not supplied by DB-02. Preserve DB receipt schema and null retention_ack; specify separate verifiable release if feasible or approved loss boundary. Do not create a phone-authored server proof | Backend + Ally; Kath relays only approved artifact |
| R28 — Lost cloud response and revoked upload | No defined cloud protocol in latest H-C | Reconcile by original entity key, same content; auth failure not physical Stop | D-R §§5–6 defines hash/revision checks, 409 distinction, 401/403 and commit unknown | ACCEPT | Accept this explicit UI/DB alignment. On same revision changed metadata reject; retain local evidence; no new event ID/Start for sync failure. Ingestion remains gated without source adapter | Kath + backend |
| R29 — Manual count vs physical Stop | TURN_STOPPED would not establish required actual batch Stop | Preserve manual count and separate physical Stop; local draft may survive offline | D-A requires stopped_event_id/applied Stop before farmer_completed; Stop leaves Active | REQUEST CHANGE | Team must explicitly approve this added completion prerequisite (not required by V12 separation alone), local draft/UI handling and zero-count case; define new-batch policy while cloud Active awaits completion. Never synthesize Stop or auto-count to satisfy dependency | Backend + Kath + Ally/product reviewer |
| R30 — Profile/pilot and brooder scope | Command keys include brooderStart; telemetry includes b sensor; no approved profile version | Preserve three species cards, Chicken-only fresh-egg physical pilot, no brooder controls | D-S defers brooder fields; profile approval/time gates | REQUEST CHANGE | Remove brooder command authority from pilot allowlist or explicitly separate disabled diagnostic scope; do not let brooder state affect incubator safety. Approve canonical Chicken profile/version, stage/lockdown and quantity; informational Duck/Quail is not physical approval | Ally + profile approver; Kath/backend |
| R31 — Controller authority/local safety | H-F requires local control but lacks reviewed transition/safety matrix | No phone connection/timeout/cloud event drives implicit Stop/Start/reset | D-R faults/observations don't automatically Stop/Complete | BLOCKED | Supply output-specific safety/readiness/FAULT/RECOVERY and full-journal shutdown policy; autonomous operation through phone loss is required but cannot continue during actual unpowered controller. Keep physical feedback limits explicit | Ally; Kath/backend wording |
| R32 — No fabricated state after reboot | Latest H-C suggests telemetry reconstruction; schemas lack actuator/turning fields claimed by prose | Last-known/unknown until real state; no false Running after replay or no-readings Stop | D-R observations/source fact distinction | REQUEST CHANGE | Align state fields, enums and scope in literal schema, not prose claims. Do not treat false/default/missing relay state as STOPPED, nor BATCH_STARTED as current Running | Ally + Kath/backend |

## 4. Per-family wire and backend translation findings

These are the latest six families in H-C/H-P, not the superseded split catalog. Their omission of split frames is not itself a defect: single frames are acceptable **only if complete required semantics and proven bounds survive**.

| Latest family | Existing Flutter behavior / actual schema problem | DB-02 mapping | Disposition |
|---|---|---|---|
| Command | `ArduinoCommand.toJson()` (`arduino_protocol.dart:191–211`) emits flat actuator/state, matching H-P but not H-C A.2 required payload or A.4 allowed key set. It is only an actuator command, not approved batch lifecycle | No cloud physical-command operation. Start metadata/transition dependency cannot be inferred from relay write | REQUEST CHANGE: one exact lifecycle-aware shape and field/type/ID policy; no implementation change here |
| Ack | Flutter reads string id and Boolean-like success (`:265–275`); latest sends status:"400"/"replay", no success. It parses as an ACK but success defaults false, so it is not semantically compatible. H-C prose also lists status values without one fixed type | ACK cannot satisfy started/stopped evidence or event identity | REQUEST CHANGE: exact status type/enum/result/replay content and immutable original operation correlation |
| Telemetry | Flutter reads incubator/brooder/actuators/turning (`:147–175`), not sensors.i/b. Latest valid values become unavailable in current model; absent relay fields default false. H-C A.7 claims actuators/turning/device/u for state, but example/schema has sensors only | DB expects TEL dev/ep/n/bid/ts/tv/tc/rh/flags; no validated translation for source/batch/sample identity or source time | REQUEST CHANGE: exact complete acquisition/state schemas and backend revision; no name-only adapter |
| Hello | H-C APP→FW contains firmware identity and purported controller token that should originate on FW; no id/query correlation. `deviceToken` describes both 32-byte nonce and 16-byte nonce/32 hex, and EEPROM0x100..0x10F is16 bytes | D-S expects distinct registry/controller UUID and alias; token/UNO_R3 cannot be silently converted to assigned dev/iid | REQUEST CHANGE: define identity origin, length/storage/provisioning, read-only version/capability reply and correlation |
| Hello-ack | Current Flutter dispatch has no hello_ack case (`:330–353`); accepted string contains no controller identity/capabilities/auth proof or query association | Cannot enable source adapter or grant registry authority | REQUEST CHANGE: jointly specify compatibility/binding proof and bounded rejection enum; no authorization from “accepted” |
| Event | Current Flutter dispatch has no event case. H-P SENSOR_INVALID payload carries sensor/time but no original command/batch/event ID. H-C A.7 claims events carry device/u, which the literal does not | DB started/stopped/fault/status-observed classes require specific evidence; TURN_STOPPED is lockdown, not stopped; SENSOR_INVALID may be diagnostic, not automatically fault_entered | REQUEST CHANGE: exact kind-specific fields, source identity/occurrence/persistence and safe mapping; no fabricated transition |
| Missing status/replay/receipt release | H-C A.7 explicitly removes STATUS/STATE and retained EVENT replay, but C diagram/H-F corrupt-recovery calls undefined GET_STATE | DB needs current query observations and original retained transition evidence; retention_ack:null | BLOCKED until same shared revision restores required semantics or explicitly changes guarantees through team review |

### Parsing/framing corrections retained from UI-02

New type names must not be silently treated as legacy/current models. Negotiate a pinned protocol/capability revision; reject unsupported versions without physical actions. Restrict accepted fields/types/ranges/alphabet, reject duplicate keys/invalid encoding/nonfinite values and avoid permissive coercion. Ordinary jsonDecode is not a duplicate-key enforcement policy.

Frame bytes across arbitrary RFCOMM chunks. Enforce approved direction-specific limits **before** processing complete lines; on overflow, drain through LF. Current `arduino_serial_io.dart:178–192` parses complete lines before checking residual buffer, allows malformed UTF-8 and clears instead of maintaining drain state. Clear partial wire bytes on disconnect; retained logical evidence must keep immutable source identity. Single-frame schema does not remove byte-fragment handling or lost-frame recovery requirements.

Do not implement old STATE_PROFILE/EVENT_CORE/TIME assemblers against the new packet by assumption. If team selects the earlier split option, approve its exact schemas, sizes, join keys and duplicate/conflict/gap/null rules; DB-02 correctly leaves split adapters disabled. If single messages are chosen, preserve all equivalent identity, original evidence and reconciliation semantics. No unconditional split/binary redesign is mandated here.

## 5. Calculation and feasibility evidence — what the tests do not prove

### 5.1 Script inspected and actually executed

Command: `python -B "C:\Users\ACER\Downloads\HW-02_count_frames (2).py"`.

Result: six fixture equality assertions PASS, exit0. Exact sizes **including one LF**:

| Fixture | Bytes |
|---|---:|
| Command | 92 |
| Telemetry | 184 |
| Ack | 128 |
| Hello | 191 |
| Hello-ack | 42 |
| Event | 94 |

The script asserts equality to six declared literal lengths, not `all_allowed_frames <= proven_rx_or_tx_capacity`. It exercises neither a real parser nor buffering/handshake. Its diagnostic text conflates a failed length assertion with exceeding capacity, and its final BUILD NOT VERIFIED branch is not a build test. No Python imports installed, no production code run, no hardware touched.

Independent host-side counterexamples, using the script's compact JSON+LF helper without changing the script:

| Change from fixture | Measured bytes | Why a claimed maximum fails |
|---|---:|---|
| Command state:false instead of true | 93 | false is one byte longer |
| Command id23, actuator incubatorHumidifier, state:false | 97 | canonical app actuator is19 chars; script uses eggTurningServo15, not asserted “max18” |
| Telemetry device31 instead of UNO_R3 six chars | 209 | script's MAX_DEVICE_LENGTH31 is never exercised |
| Command id of23 quote characters, state:true | 115 | “any string ≤23 chars” permits escaping growth unless alphabet is restricted |

Hello-ack rejected:<reason> is not bounded/measured; BATCH_STARTED/RELAY_STATE event payload schemas are absent; ACK optional fields/status/replay combinations are not fully bounded; metric precision/magnitude can change lengths. The full permitted-set maximum is therefore **UNKNOWN** even though all six fixtures PASS. Do not replace fixture maxima with these probes as new universal maxima.

### 5.2 RX ring correction, supported by core source

ArduinoCore-avr `HardwareSerial.h` defines a default `SERIAL_RX_BUFFER_SIZE` of64 for the larger-memory AVR configuration, guarded by `#if !defined(...)`. `_rx_buffer` is a **software array in SRAM**, not an immutable64-byte MCU hardware FIFO. `HardwareSerial_private.h::_rx_complete_irq` enqueues a received byte if next head differs from tail; one slot remains unused in this implementation. `Serial.read()` drains the ring while the application can build a longer line in a separate bounded buffer.

Therefore a frame longer than64 bytes does **not** inevitably overrun. Overrun depends on unread occupancy, service rate, interrupt-disabled periods and burst behavior. A larger ring may be a build-time option with SRAM costs, not an automatic recommendation. A blocking loop or DHT/SoftwareSerial/interrupt blackout can still cause loss even for shorter messages. Host buffering/chunking alone is not proof that UART service is timely; RFCOMM write chunks need not map to paced UART chunks.

At9600baud 8N1, approximately960 bytes/sec arrive. A nominal64-byte interval is about66.7ms, or about65.6ms for63 usable slots from empty. These are arithmetic illustrations only, **not a safe service deadline**, because prior occupancy, ISR delays and actual HC-05 buffering/rate remain unknown.

Direction matters: proposed Command and Hello are Uno RX; Telemetry/Ack/Hello-ack/Event are Uno TX and Android RX. Uno's RX ring does not impose its frame limit on its outgoing messages. Even H-C's “every frame exceeds64” statement contradicts its own42-byte hello_ack.

Separate genuine capacity issue: if Ally's claimed160-byte line buffer stores stripped content + NUL, it permits159 content bytes. H-P Hello191 including LF is190 content bytes and **would not fit** that buffer as written. This conclusion is conditional on exact implementation/terminator handling, not the ring argument. Current local Uno actually has serialLine48 (47 content + NUL), Combined has120 (119 content + NUL); neither is evidence of the claimed160-byte version on Ally's branch. Actual approved RX/TX caps and SRAM/stack feasibility remain BLOCKED.

External source inspected 2026-10-28:

- https://raw.githubusercontent.com/arduino/ArduinoCore-avr/master/cores/arduino/HardwareSerial.h — buffer macros and arrays.
- https://raw.githubusercontent.com/arduino/ArduinoCore-avr/master/cores/arduino/HardwareSerial_private.h — ring enqueue and full condition.

These upstream master files explain the architecture; they do not identify the target core version, build configuration or physical MCU. Ally must pin/inspect those separately.

### 5.3 Build and memory claims

H-F §3.1 reports no object/ELF/HEX/avr-size artifact and warning **“linker input file unused because linking not done”** for `avr-g++ -c ... SmartHatch_Uno.ino`. Exit0 with that warning does not establish that the `.ino` translation unit was compiled or syntax-checked. It must not be described as “toolchain accepted the sketch” evidence. Request a real pinned Arduino CLI build or correctly preprocessed/language-selected translation and link; record all outputs, libraries, board/core and measured memory.

Static+stack estimate1550–1600 with remaining450–490 is not measured SRAM headroom, nor stack-safety proof. v1.2's earlier1794/2048 figure also belongs to a different reported build/baseline. Do not compare them as demonstrated memory improvements. No new build was attempted in UI-03.

## 6. Full UI-02 ↔ DB-02 comparison now possible

D-A/D-R/D-S explicitly said the full UI files were unavailable to the backend review. They are available in this workspace and were compared directly here. This clears **this review's** missing-UI-input problem, not the backend author's approval or source-adapter gate.

| UI-02 requirement | DB-02 actual position | Kath's decision |
|---|---|---|
| Local display/recovery not gated by online sign-in | D-R §6 keeps offline UI available; current anonymous app startup is not compatible with new provisioning | ACCEPT design; future Kath startup/auth work required, no current implementation claim |
| Durable intent and dispatch-may-occur before write | D-R §5 same ordering | ACCEPT invariant; persist immutable target/content/IDs, never a reconnect actuator queue |
| Critical event + local projection + outbox atomic transaction | D-R §5 includes captured original source/partial parts; body/hash retained | ACCEPT invariant; missing source evidence cannot be papered over by SQLite |
| Partial record not complete event | D-R §2/D-A W3 require all matching parts, distinguish absent part from explicit unknown time | ACCEPT; earlier UI split logic remains conditional on exact agreed catalog |
| Immutable retry/hash/canonicalization | D-R §§2,5 specifies typed normalized source, JCS SHA256, excludes retry/uploader/receipt/arrival order | ACCEPT direction; pin exact normalized object and canonicalization implementation, no round-trip through lossy uint64 |
| Validate exact receipt and monotonic processing | D-A §6; D-R §§4–6 supplies content_sha256, entity/IDs, receipt/revision/first time/session string and legal transitions | ACCEPT direction; enforce runtime relational checks as well as shape, no Synced on2xx alone |
| Waiting vs conflict vs rejection vs uncertain commit | D-A §7/D-R §5 makes committed conflict distinct from409 changed-content not-persisted | ACCEPT; preserve original content/outbox, pause permanent failures, bounded foreground retries |
| Original source time and unknown day | D-A STATE observation has null occurred_at; original_start fields separate, D-R §3 retains unknown time | ACCEPT direction; HW current uptime-only evidence cannot fill trusted Start/source UTC |
| Quantity/profile from original intent vs source proof | D-A §5 explicitly admits EVENT does not echo sp/qty/pv; source admission must substantiate link | BLOCKED until retained manifest/admission linkage exists, especially after phone reinstall |
| Stop versus farmer completion | D-R §3 makes completion depend on applied Stop, D-S leaves session Active after Stop | REQUEST CHANGE/team decision: explicit extra prerequisite and new-batch/lifecycle policy, not implicit reinterpretation of v1.2 |
| One authorized installation, no general farmer login | D-S §4 admin enrollment, signed session binding, replacement recovery; secure-storage/session semantics untested | ACCEPT direction; offline command auth and copied credentials threat model remain BLOCKED |
| Authenticated source retention release | D-A retention_ack:null, D-R §7 forbids generating RCPT_ACK from phone/HTTPS/command MAC | ACCEPT fail-closed behavior; no release artifact/signature is supplied. Bounded capacity and approved loss boundary remain BLOCKED |

DB-02 JSON evidence checked here: all four fenced JSON blocks in D-A (request schema, response schema, request examples, response examples) parse with Python json.loads. This is **syntax checking only**. The reported Ajv46-negative/model/hash checks belong to the DB author and were not rerun. No endpoint, SQL, Auth/RLS, DB concurrency, signer, JCS implementation or source adapter is tested/approved by this review.

The D-A request/response structures are concrete enough for Flutter design review but not deployed APIs. Their fail-closed CONTRACT_NOT_ENABLED / WIRE_SPLIT_UNFROZEN behavior is compatible with unresolved source design; do not enable production just because JSON examples parse. Its private registries, event ledger, reading provenance and existing bigint/name preservation are proposals, not existing objects verified here.

## 7. Failure matrix — safe Flutter interpretation versus missing guarantees

| Scenario | Required Flutter behavior from V12/UI-02/DB-02 | Latest HW limitation / decision |
|---|---|---|
| App opens offline | Initialize/recover local ledger and provisioned policy before commands; online refresh separate | No offline command authorization provided; Start blocked until resolved |
| App closed/phone powered off | Controller intended autonomous while powered; phone collects/uploads nothing guaranteed; show last-known on return | One-shot events may be lost; periodic sensors cannot rebuild complete history |
| Internet fails during Start | Keep controller workflow separate from cloud; save confirmed event/outbox | Requires actual retained correlated source event currently absent |
| ACK lost after command | Unknown outcome; no automatic resend/new identity; read-only reconcile | No exact current-status/retained-outcome query; safe app must stay unresolved rather than claim failed |
| Event lost before local commit | Recover from controller retained evidence using original identity | No firmware replay in latest H-C; recovery guarantee missing |
| Running report received, local save fails | Show report plus record-not-saved warning; retry local save/read-only recovery; no Start retry | There is not yet a schema for sufficient current Running report in latest packet |
| Arduino loses power | Actual unpowered controller cannot regulate; after boot verify persisted batch/evidence/time and safe recovery, no fresh Start | Undefined GET_STATE and corrupt-seq BATCH_START reset risk identity loss/false transition; RTC missing |
| App reinstalled before upload | Controlled new provisioning; recover surviving source/cloud metadata, not guessed counts/profile/time | One-shot events + incomplete manifest cannot reconstruct original batch; accept explicit unknown/help, not false recovery |
| Cloud commits, reply lost | Reconcile original entity key/hash; retry exact immutable event if absent; no Bluetooth command | DB candidate handles direction; source adapter/atomic DB implementation not verified |
| Delayed/replayed telemetry | Keep source acquisition identity/time; unknown-age or stale indicator; no target fallback | u lacks reboot identity/acquisition validity/batch; freshness not reliably derivable |
| Wrong/revoked phone | Fail closed for commands/uploads according to distinct authority policies; preserve evidence | Backend registry supports proposed online denial, not missing offline authentication |
| Journal full/corrupt | No overwrite of sole critical evidence/new Start; safe local shutdown independent; explicit gap/recovery policy | Latest journal capacity/phase/STOP behavior not concretely defined; BLOCKED |

No firmware report without independent feedback verifies physical heater/fan/relay action. The farmer UI must say **“Incubator reports running”** / **“Last confirmed…”**, not “hardware verified.” Cloud **Active** means session lifecycle; no telemetry does not prove Stop; turning inactive can mean lockdown; heater off can mean thermostat satisfied.

## 8. v1.2 requirements absent, weakened or still unproven

- **J-01:** intended HC-05/RTC architecture is replaced by USB/millis wording without team authorization; baseline selection remains unapproved.
- **J-02:** strict schema/limits/proof regressed to contradictory command forms and fixture maxima; automatic64-byte ceiling is wrong. Split removal is acceptable only if semantics and capacity are preserved, which they are not yet.
- **J-03:** separate controller/installation/batch/command/event/sample identities not represented; deviceToken/uptime cannot replace all of them.
- **J-04:** explicit lifecycle admission/outcome, matched current-status query and content-aware duplicate/conflict behavior missing. Relay state and lockdown are not full Stop semantics.
- **J-05:** retained event replay removed; no explicit approved narrower loss boundary; journal/manifest capacity/CRC/phase/atomicity not proven.
- **J-06:** RTC/trustworthy original Start/time validity/outage policy remain missing; uptime-only or manually set day weakens required provenance.
- **J-07:** readiness/safe state/fault/recovery matrix and safety evidence remain unapproved; corrupted-state BATCH_START behavior contradicts no implicit Start.
- **J-08:** offline authorization missing; Hello/identity is not authentication. DB registry/source provenance do not resolve it.
- **J-09:** DB-02 preserves meaningful secure-sync direction but maps a different source catalog. No endpoint/deployment/auth/concurrency proof exists.
- **J-10:** independent channel validity, persistent acquisition identity/time/age and batch attribution absent or weakened.
- **J-11:** immutable approved profile/quantity snapshot missing; brooderStart expands pilot authority; approved Chicken values still pending.
- **J-12:** UI truthful uncertainty/save-failure distinctions are preserved in UI/DB designs, but source recovery needed to discharge uncertainty is missing.

Neither v1.2 nor these proposals authorize implementation or physical tests. Do not weaken the cloud adapter, call ACK Running, use target values as actuals, generate replacement event IDs, or mark lost source time valid to obtain artificial compatibility.

## 9. Actual source availability and verification record

### Available locally and inspected

Repository HEAD from the existing review baseline: `c7a26cfcaa619708aff4f793e8068ee176a6cf58`; working tree contains preserved uncommitted UI/generated/test/docs work. The source findings are from inspected local files, not a pristine or remote snapshot.

| Source file | Actual inspected evidence |
|---|---|
| `lib/services/arduino_protocol.dart` | Full355 lines; actuator Command191–211; telemetry147–175; ACK265–275; dispatch330–353; no hello/event decoder and no batch lifecycle schema |
| `lib/services/arduino_serial_io.dart` | Full307 lines; libserialport, pending IDs/3-second ACK timeout129–159, framing178–192, ACK completion202–208; no RFCOMM/retained event ledger |
| `lib/controllers/arduino_controller.dart:31–120` | Six-second receipt-age/connection readiness, not acquisition freshness or logical Running proof |
| `lib/services/supabase_service.dart:98–302` | Current quantity6..12, direct create/complete, global latest-reading query; not DB-02 ingestion |
| `lib/main.dart:16–32,2734–2773` | Online anonymous sign-in may gate display; cloud-first Start/settings and Started navigation |
| `pubspec.yaml` | Full31 lines; no Bluetooth/SQLite direct dependency; libserialport is not Classic SPP |
| `android/app/src/main/AndroidManifest.xml` | Full45 lines; no Bluetooth permissions |
| `arduino/SmartHatch_Uno/SmartHatch_Uno.ino` | Full603 lines; serialLine48 at90, plain-text command329–468 and STATUS482–507; selection starts control, Day8 initial/load fallback66–70,161–169; no batch UUID/quantity/RTC/event journal |
| `arduino/SmartHatch_Combined/SmartHatch_Combined.ino:74–223,389–547` | serialLine120; numeric ACK cache; SELECT/RESET start new batch; invalid EEPROM starts Chicken198–208; cache cleared528; not proposed latest HW schema |

Local sketch SHA-256:

- Uno: `0365b18bc969d36547440b5e4299b946da03fa5aeccdbff0fff8dc8efeef01fc`.
- Combined: `a466a868e6c148cf4f9c3230378d5033d81db89dfb77a3e0fa53891d847a9598`.

### Not supplied as matching evidence

- Ally's exact source snapshot at `d97d6af68118a175d99b1f61747c52b082bc15ec` / `ally-branch3`, claimed modern CMD_BUFFER_SIZE160 version and complete corresponding source hashes. No branch fetch/switch/merge performed. Abbreviated Git identifiers in H-F cannot be equated to the local SHA-256 values.
- Target board/core/library build artifacts, ELF/map/avr-size, stack/timing/interrupt-loss measurements, physical flashed identity and HC-05/RTC inventory/wiring/test evidence.
- DB author's referenced live schema inventory and external Ajv validator/tooling artifacts were not supplied in this task; prior inventory/validation claims remain attributed, not re-certified. All **required review documents** were available; these missing supporting artifacts limit verification, not document availability.
- No actual deployed bridge-sync endpoint, RLS/Auth test results, receipt signer or source-release verifier is established by the supplied proposals. DB-02 explicitly sets retention_ack:null.

### Work performed and preservation

Only this new UI-CONTRACT-03 Markdown deliverable is authorized for creation. The three existing UI-02 reviews and supplied attachments remain unchanged to preserve revision history. Performed full document review, targeted current-source reads, safe host-side count-script execution/size probes and JSON syntax checks; upstream core-source review was read-only. No Flutter/firmware/dependency/config/SQL edits, Supabase access/writes, auth provisioning, builds, hardware commands, uploads, merges, deployment or commits.

## 10. Decisions required from the team

1. **All:** choose and pin one hardware catalog revision consistent with v1.2; explicitly accept/reject the latest USB/actuator-only replacement. Backend (Mary/Cha) confirms the signatory and updates adapters only after that decision.
2. **Ally + Kath:** supply exact explicit batch Start/Stop, current read-only status and retained result/replay semantics; retain original batch/quantity/species/profile/Start and original command/event identity across restart. No automatic Start retry or corrupt-state new batch.
3. **Ally:** correct UART-ring/frame-size and compile-evidence claims; prove direction-specific allowed-frame maxima, parser service/memory, journal layout/phase and safe power-loss/full-storage behavior for the chosen source.
4. **Ally + backend + Kath:** agree offline authorization/provisioning/revocation, source provenance, clock/RTC/outage/freshness and persistent identity/counter policy. Keep unknowns visible; no default trust or invented timestamps.
5. **Backend + Kath:** reconcile DB-02 with the chosen wire revision; approve canonical manifest/evidence mappings, receipt/hash/revision checks, manual-completion Stop prerequisite and new-batch lifecycle policy. Keep contract gates disabled until resolved.
6. **All + profile approver:** approve Chicken profile/capacity/pilot safety and bounded retained-evidence/reinstall loss guarantee; choose verifiable server release or an explicitly narrower retention boundary. DB-02 supplies no release artifact today. Obtain all approvals on the same revision; K06 v0.5/portal and implementation remain on hold.
