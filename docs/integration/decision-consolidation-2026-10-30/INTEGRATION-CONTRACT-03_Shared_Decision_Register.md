# INTEGRATION-CONTRACT-03 — Shared decision register

**Coordinator:** Cha · **DB-02 proposal owner:** Mary
**Firmware owner:** Ally · **Flutter/UI owner:** Kath
**Register revision:** `0.1-review` · **Date:** 2026-10-28
**Disposition:** REQUEST CHANGE / NOT JOINTLY APPROVED / NOT IMPLEMENTATION AUTHORIZATION

This register reconciles proposals; it is **not** an approved v1.3, replacement
wire catalog, implementation, merge instruction, or permission for hardware tests.
Only this coordination document was created. No original report/header, application,
firmware, database, migration, credential, project configuration or portal was edited.

## 1. Executive findings and decision authority

All **four current HW-02 files, three full UI-02 files, three DB-02 files, and the
original shared v1.2** were available and read. No summary substituted for a missing
document. Missing-full-UI availability is now cleared; compatibility is not.

The current inputs are **different proposal generations**, not one compatible set:

- Corrected HW-02 proposes USB, lower-case `type` families, actuator/key commands,
  no complete read-only recovery query, and one-shot events without retained replay.
- Full UI-02 explicitly reviewed the earlier uppercase `t`/HELLO/STATUS/STATE/
  EVENT/TEL catalog, with compact aliases, original batch IDs and retained replay.
- DB-02 `0.1-review` likewise normalizes that earlier catalog into UUID-based cloud
  records and stable receipts. Its adapters are deliberately disabled pending review.
- Shared v1.2 still selects HC-05 Classic SPP/Android, explicit offline Start,
  independent identities, read-only reconciliation and recoverable transition evidence.

**Highest-priority conclusion:** do not implement the corrected HW catalog merely
because its filename says corrected or its example counts match. First choose a
single revision and resolve the lost lifecycle/recovery capabilities explicitly.

### Ownership and approval

Mary owns all DB-02 decisions/actions in this register, per the current user
instruction. Existing DB-02 headers still say `Owner: Cha`; that historical label
is preserved as source provenance, not silently rewritten or used to transfer
backend ownership. Cha coordinates evidence, change control and joint closure.
Source v1.2/UI/HW texts also contain historical three-person/Cha-backend labels;
this register's operational ownership supersedes those labels for this task only.

Ally approves firmware feasibility; Kath approves Android interpretation/durability/
UI; Mary approves cloud identity/API/storage/security mapping. Cha records decisions
and verifies cross-component agreement. No coordinator recommendation supplies
another person's approval. Numerical profiles need a named designated approver,
who is not identified in these inputs; Ally must obtain that designation.

### Evidence/status conventions

- **SOURCE VERIFIED:** directly read a source/report; a claim in a report is not
  automatically a verified implementation fact.
- **PRIOR LIVE INVENTORY:** actual database structure observed 2026-10-27 11:00:42
  UTC, cited from the completed inventory; not re-queried here.
- **CALCULATED:** host byte count/hash/arithmetic only.
- **PROPOSED:** recommendation awaiting named reviewers.
- **UNKNOWN:** source/build/runtime/physical evidence unavailable.
- **ACCEPT:** coordinator recommends the stated invariant/direction only. It does
  not mean implementation exists, item closed, or joint protocol approval.
- **REQUEST CHANGE:** a concrete inconsistency must be corrected.
- **BLOCKED:** an unmade decision or absent feasibility/proof prevents freezing
  that capability. P0 = contract-breaking; P1 = required implementation/readiness
  work; P2 = source/document hygiene. No severity is a new safety clearance.

## 2. Full source manifest and revision pinning

External source root **D** = `C:\Users\Mary Charlyn\Downloads\`.
Repository review root **R** = `docs/contract-review/`.
SHA-256 values below hash the **raw bytes**, not prettified/rendered Markdown.
Filename suffix `(1)` is an artifact name, not a semantic version or approval.

| ID | Exact source filename/location | Version / status / provenance |
|---|---|---|
| H-C | D + `HW-02_Exact_Wire_Message_Catalog (1).md` | corrected PROPOSED; owner Hardware; reports ally-branch3; USB/lowercase candidate |
| H-F | D + `HW-02_Uno_Feasibility_And_Recovery (1).md` | correction pass; build not verified; reports commit d97d6af68118a175d99b1f61747c52b082bc15ec |
| H-O | D + `HW-02_Open_Decisions.md` | correction pass; PROT/BYT/RCL/EMB register, no approval |
| H-S | D + `HW-02_count_frames.py` | corrected counter; six literal constructors and expected lengths, not a firmware build |
| U-W | D + `UI-02_Wire_Compatibility_Review.md` | Kath; 2026-10-28 follow-up; REQUEST CHANGE; reviews earlier HW packet |
| U-R | D + `UI-02_Offline_Start_And_Recovery.md` | Kath; 2026-10-28; proposed, compatibility blocked |
| U-F | D + `UI-02_Farmer_UI_State_Specification.md` | Kath; 2026-10-28; proposed, not implemented/approved |
| D-A | R + [DB-02_Exact_Bridge_Sync_API.md](DB-02_Exact_Bridge_Sync_API.md) | DB-02 0.1-review; proposed; original header Cha, current owner Mary |
| D-S | R + [DB-02_Proposed_Schema_And_Security.md](DB-02_Proposed_Schema_And_Security.md) | DB-02 0.1-review; proposed, not executed; current owner Mary |
| D-R | R + [DB-02_Conflict_Receipt_And_Recovery.md](DB-02_Conflict_Receipt_And_Recovery.md) | DB-02 0.1-review; proposed; current owner Mary |
| V12 | D + `SmartHatch_v1.2.md` | shared consolidated candidate, 2026-10-27, NOT APPROVED; original 255 nonempty/physical text lines excluding terminal empty split |

| Source ID | Raw SHA-256 |
|---|---|
| H-C | `37afae0d57277a22521450119ceb00382467caf1a58f03628cd8afc5bec89640` |
| H-F | `1dea144aea7dbbfdbd9fbb4d67057aa3af179f52e889933010e2ee09f2119ed5` |
| H-O | `b445c4b373cc79f1fede3068ba118f695db1c67d17bb557c380c0b7380d7acb8` |
| H-S | `b2bc944b46bb1535c7a181c8984a3b6cc99a28fb56df9beca9f9924e831fcb0b` |
| U-W | `df906a48bb1512f158a3322f44d359d7def266479eefe96d99b3b7271fc0107e` |
| U-R | `052913aa296df2df280c24f30ff250ab0569d3171eccae625cdb50adbc2d0e21` |
| U-F | `7796c167acc7e1288c604635ecd9d4b44930ac070c73cc4cea254fde22174fae` |
| D-A | `5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab` |
| D-S | `6322985031a82d25184bd0ebefc7e1a9016d74c22b7e8d587e94dafb16d3f230` |
| D-R | `08e6f97c7c320769e223218fbea7ce52a1d4a1b0ec5d117a83965d5678f39f06` |
| V12 | `6814dc872f18ab1b54488c25ac1c4df7ae433c7bf62e5ba389262ee0a009bf47` |

H-C and H-F have only five physical lines because most Markdown is serialized
with literal `\n` and escaped quotes on physical line 5 (and metadata on line 3).
The complete contents were read through a **display-only** expansion, without
rewriting either file. Cite `H-C:5 §A.7`, for example, not invented normalized
physical line numbers. Require a clean, hash-pinned published revision before
freezing exact parser literals; do not accidentally send escaped export artifacts.

### Earlier HW packet actually reviewed by UI-02/DB-02

U-W:9-12 explicitly names and hashes these **different** earlier files. Raw-byte
hash comparison locally confirms the references; they were consulted as lineage,
not substituted for H-C/H-F/H-O:

| Earlier filename in D | Raw SHA-256 |
|---|---|
| `HW-02_Exact_Wire_Message_Catalog.md` | `b43da3e1a42d3a2a2a0c5b5455d4dfa713b4d36ac409ae08a5925bd9acd5327d` |
| `HW-02_Uno_Feasibility_And_Recovery.md` | `85627787fa4b566e0b97609c7a6d880ba61bbd6be17ef6aa7e5f67dda64fde41` |
| `Open_Decisions.md` | `23de67cb97c6b1dc28e7ea59974345678ae87d6eeb17292162e73e4cf5eef0fd` |

No current document supplies a joint adoption record replacing the earlier
retained-event design with H-C's one-shot design. D-A's summary-only UI caveat
was accurate when authored; full UI is now available and that **input-availability**
blocker is cleared here. D-A/D-S/D-R adapters still target the earlier HW packet,
so their actual compatibility must be re-reviewed by Mary, not presumed repaired.

## 3. Targeted implementation/source verification

Local worktree: `C:\EggIncubator\egg_incubator_app`, branch `cha-branch2`, commit
`c7a26cfcaa619708aff4f793e8068ee176a6cf58`. Different reported source branches are
not automatically different firmware: identify actual content and build together.

| Evidence ID | Exact source and lines | Verified finding / limitation |
|---|---|---|
| S1 | `arduino/SmartHatch_Uno/SmartHatch_Uno.ino:63-70,90-91` | Local Uno variant has Day 8 initialization and `serialLine[48]`, not a source-verified CMD_BUFFER_SIZE=160. Neither is approved fresh-egg behavior. |
| S2 | `arduino/SmartHatch_Combined/SmartHatch_Combined.ino:82-87,108-115,198-208` | Combined variant has 120-byte input, species/runtime EEPROM, volatile ACK cache, invalid-state new-batch reset. It lacks proposed durable identities. |
| S3 | Combined:398-436,464-500,528 | Cache replays numeric ID alone, SELECT/RESET create a batch, substring parser/text-command path, overflow restarts accumulation, cache cleared at boot. Not retained-event recovery or safe shared contract. |
| S4 | `lib/services/arduino_protocol.dart:191-211,241-275` | Flutter command uses top-level id/actuator/state; ACK parser expects `success`, not H-C's `status`. Familiar spelling alone is not compatibility. |
| S5 | `lib/services/supabase_service.dart:125-167,232-245` | Cloud-first Active insert obtains bigint ID; direct completion update is not an idempotent confirmed-event transaction. |
| S6 | `README.md:28-30,54-68,81-85` | Names Uno upload and historical USB/JSON assumptions, not proof which sketch is flashed or current HC-05 behavior. Do not promote README over shared architecture. |
| S7 | `...\Arduino15\packages\arduino\hardware\avr\1.8.8\cores\arduino\HardwareSerial.h:31-65,105-114,121` | Locally installed core's default 64-byte RX/TX arrays are **software** buffers; macros are conditionally defined; 8N1 is begin default. Not proof of the actual flashed core/build. |
| S8 | Same core `HardwareSerial_private.h:101-116`; `HardwareSerial.cpp:166-188,225-278` | ISR enqueues until ring full; read advances tail; TX can stream as space drains. A queue is not a whole-frame hardware cap. |

S7/S8 absolute prefix: `C:\Users\Mary Charlyn\AppData\Local`. No core/sketch
was modified, built or flashed. Git blob IDs of inspected sketches:
Uno `3859467ce33e25d4ea2a32d3f888288a141ae1b6`,
Combined `befec1255aae74eeef42fde1620cc08fc199717a`.
These are **Git blob IDs, not sketch SHA-256 or upload evidence**.

Prior live database evidence is reused from
[SmartHatch_Supabase_Actual_Schema_Inventory.md](../../SmartHatch_Supabase_Actual_Schema_Inventory.md):124-203,
205-320. No new schema/Auth query or row access was performed. Real names remain
`incubator_sessions.id`, `egg_type`, `egg_quantity`, `start_date`, `status`,
`end_date`, `eggs_hatched`, `temperature`; `sensor_readings.current_temperature`,
`current_humidity`, `recorded_at`; presets/settings retain existing names.

## 4. Cross-component compatibility matrix — all 16 requested capabilities

The two joined tables constitute one matrix keyed by C01-C16. The first compares
requirements/conflicts; the second supplies severity, owner, proposed decision
and status. Supporting citations are source IDs/sections above, not summaries.

| ID / capability | Hardware requirement/proposal | Flutter requirement/proposal | Backend requirement/proposal | Exact conflict or missing behavior |
|---|---|---|---|---|
| C01 Identity | H-C §A.1/3/5: arbitrary <=23-char id, device model/u and public deviceToken; no batch/event/sample key defined | U-R §3/4 and U-W §5 require stable offline batch, query/command, source event/epoch/sample IDs and binding | D-A §3 maps aliases to controller/installation UUIDs, batch UUID and source-scoped event/sample keys; bigint session kept | H-C lacks bid/cid/seq/epoch/provisioned dev semantics expected by UI/DB. A model name or token guess cannot fill them. |
| C02 Physical START/STOP | H-C §A.4/7 maps selection/actuators/turning to control, lacks exact deliberate batch Start/Stop schema | U-R §4, Offline Stop; U-F:28-31 requires deliberate fresh-egg Start and separate correlated Stop | D-R §3 requires occurred started/stopped evidence and independent manual completion | Selecting species may start; thermostat-off or TURN_STOPPED lockdown is not batch Stopped; no original batch/request/evidence gate. |
| C03 ACK / Running / Active | H-C §A.1 says ACK processed only; hardwareVerified false | U-F:13-20,43-55 separates accepted request/current report/history | D-R §3/4 distinguishes events, lifecycle, receipt | Separation principle agrees, but H-F §5.2 attempts to infer Stop from actuator flags. Concrete transition proof missing. |
| C04 Read-only STATUS/STATE and freshness | H-C §A.7 explicitly has no status query; H-F §5.3 invokes undefined GET_STATE | U-R §6 requires fresh query, original outcome, current snapshot and gaps; U-W §8 freezes snapshot correlation | D-A §5/D-R §3 normalizes correlated STATE separately from original event | Asynchronous telemetry cannot retrieve original request/batch/count/time or prove a fresh correlated response. No executable read-only recovery contract. |
| C05 Bluetooth reconnect | H-C §A.1 selects USB; H-F §3 labels HC-05 transport despite no configuration evidence | U-R §2 selects HC-05 Classic RFCOMM candidate, new connection generation/auth/reconcile | D-A §2 scopes internet relay; no remote control/fallback inferred | Transport regresses from V12 HC-05/Android; reconnect handshake/binding/query absent in H-C. |
| C06 Offline ledger/outbox | H-F §5 relies on app reconstruction, admits no retained events | U-R:35-91 defines T1/T2/T3/T4 and critical durable outbox; no resend queue | D-R §5 expects immutable outbox and matching receipt/hash transaction | Android local design direction is compatible with DB; it cannot save a confirmation lost before T3 without source retention. Not implemented or crash-tested. |
| C07 Duplicate commands | H-C §A.4/7 defines replay ACK for repeated/in-flight id, no content comparison or reboot scope | U-R §4/5 needs durable same-ID outcome, changed-content conflict, no blind resend | D-S §2.4/D-R §2 needs immutable command/batch context | commandAckSeq alone does not specify original ID+content+outcome mapping; ID reuse after batch reset unsafe. S3 cache is volatile and content-blind. |
| C08 EEPROM reboot recovery | H-F §5.1/3 proposes token/manifest/journal but corrupt seq resets to BATCH_START | U-R:84-89/§6 preserves identity, recovery/unknown, no replacement batch | D-A §3/D-R §8 forbids reusing identity/counter or replacing original Start | Reset may manufacture a batch/day or reuse identity. Token range/size and magic addresses overlap in the proposal; no byte map/atomic phase proof. |
| C09 Retention/replay | H-C §A.7 and H-F §5.2 remove source replay; one-shot events discarded on power cycle | U-R §5/6 stages complete events, replays missing evidence, survives crashes only if source survives | D-R §2/3/7 requires immutable original event and reviewable retention/loss boundary | Unsupported removal of earlier bounded replay/retention; ACK replay cannot reconstruct a lost occurred transition. No joint loss guarantee approval. |
| C10 Cloud ingest/dedup | H-C event has code/sensor/monotonic time, no batch/cid/event sequence | U-R §7 submits same immutable source event and validates fingerprint | D-A §4-8 exact candidate event/reading/receipt schema, atomic source key; D-S §3 transaction | Mary cannot map new sparse one-shot events to mandatory source/context fields without inventing evidence. Old adapters not compatible by default. |
| C11 Authentication | H-O EMB-02: no offline auth; H-C HELLO exposes public nonce and only accepted/rejected | U-R:57-60, U-W:136 require provisioned local command ownership; no pairing-as-auth | D-S §4/5 requires non-anonymous subject/session registry and no bypass; local auth separate | Public deviceToken/iid/HC-05 pairing do not authorize command or upload. Key purposes, generations, cloning, offline revocation unresolved. |
| C12 Receipt/release | H-O EMB-03 says receipt channel not delivered; no retained records to release | U-R:129-134 checks hash/revisions/disposition, forbids phone-only release | D-R §7 holds retention_ack null until verifiable exact-source binding | No agreed Uno-verifiable server proof/fingerprint/retention boundary. SHA/JWT/HTTPS on Android is not authenticated release on Uno. |
| C13 Chicken profile/quantity | H-C allowed chosenEgg/incubationDay/brooderStart/setPoint/turnNow; no approved immutable Chicken manifest or qty | U-F:27-31 Chicken physical pilot, read-only profiles, fresh eggs; U-W:102-103 notes current6..12 | D-A §5 gate on approved manifest; D-S reuse egg_type/egg_quantity, no invented numeric targets | Expanded brooder/day/manual-control keys exceed current farmer pilot; original quantity/version recovery absent; quantity bounds unratified. |
| C14 RTC/day/outage | H-F §5.5 millis-only; u/time are uint64 monotonic microseconds; corrupt-state reset | U-R §8 needs source/receipt time, original Start, current elapsed confidence; no date-only/clamp trick | D-A §3/5 uses source UTC/null and validity; D-S §2.3 preserves legacy projections | Uptime is not UTC and resets/wraps; no original Start/current reference/outage policy. uint64 max cannot pass through lossy JSON parsing. |
| C15 Frames/version/parser | H-C §A.2 payload vs §A.4 actuator/state vs key names; proto0.2.3 only inside HELLO; claims ring hard64; H-S six literals | U-W §3/6 requires exact types/version, drain-to-LF, correct RX/TX bounds; targeted old 191 candidate | D-A gates exact adapters; evidence resource ceiling is HTTP-only, not wire acceptance | Multiple schemas/versions; unsupported ring claim; counted examples not maxima; parsing/escaping and full mandatory messages not frozen. |
| C16 Firmware/build/physical evidence | H-F §2 reassigns to Uno; compile command produced no object; memory estimate not linked build; actual flash unknown | U-W §1/2 source-only; native transport/SQLite not installed/tested | D-A §9 fixture checks only; DB not deployed; physical claims not permitted | Development sketch not agreed; claimed CMD_BUFFER_SIZE160 absent locally; exit0+unused input is not compilation evidence; no stack/runtime/physical proof. |

| Capability | Severity / class | Responsible owner(s) | Proposed decision for team review | Status |
|---|---|---|---|---|
| C01 | P0 identity/design dependency | Ally + Mary + Kath; Cha coordinates | Select lossless distinct controller/installation/batch/command/event/sample identities and private alias mapping; no invented fields from defaults | BLOCKED |
| C02 | P0 lifecycle/implementation blocker | Ally lead; Kath + Mary review | Specify deliberate admitted Start/Stop and occurred-evidence phases; selection/turner/relay bits cannot substitute | REQUEST CHANGE |
| C03 | P0 invariant, realization pending | Ally + Kath + Mary | Accept ACK != current controller state != cloud lifecycle != receipt; exact evidence still needs C02/C04/C09 | ACCEPT |
| C04 | P0 recovery/design blocker | Ally + Kath lead; Mary validates evidence | Restore a complete read-only current-state/original-outcome query; remove undefined GET_STATE reference or supply exact safe semantics | BLOCKED |
| C05 | P0 architecture choice/regression | Ally + Kath; Mary scope; Cha records vote | Keep agreed HC-05/Android; label USB lab-only unless all explicitly approve architecture amendment | REQUEST CHANGE |
| C06 | P1 compatible direction, runtime unknown | Kath lead; Mary receipt contract; Ally source recovery | Retain T1-T4/no hardware replay/immutable outbox; define tested storage budgets and failure policy | ACCEPT |
| C07 | P0 identity/implementation blocker | Ally lead; Kath + Mary | Persist original critical command ID/content/outcome and define terminal conflict/replay precedence; never dedup on ACK ID alone | REQUEST CHANGE |
| C08 | P0 recovery/design and implementation | Ally lead; Kath + Mary | Integrity-checked versioned layout/commit phases; corrupt state -> recovery, not BATCH_START/new identity | REQUEST CHANGE |
| C09 | P0 explicit loss-policy choice | Ally + Kath + Mary; Cha records joint approval | Restore bounded critical replay OR explicitly approve narrower loss guarantee and corresponding UI/DB changes; not automatic adoption | BLOCKED |
| C10 | P0 source contract dependent | Mary lead; Kath API client; Ally source | Preserve existing DB names/mapping and canonical dedup; keep incompatible source adapters disabled until exact evidence is agreed | BLOCKED |
| C11 | P0 threat-model/design choice | Ally local auth; Mary cloud auth; Kath storage/setup | Separate source identity, offline authority and online rights; select feasible mechanism and disclose cloning/revocation limits | BLOCKED |
| C12 | P0 trust/retention design choice | Mary server proof; Ally verifier; Kath relay | No release on ACK/2xx/plain receipt; retain null release artifact until source-comparable proof or signed-off loss boundary | BLOCKED |
| C13 | P0 product/profile approval | Ally + designated profile approver; Kath + Mary; Cha tracks | Restrict physical pilot to approved Chicken/fresh eggs; freeze capacity/version; remove unapproved control scope | BLOCKED |
| C14 | P0 time policy and source dependency | Ally clock; Kath day UI; Mary UTC/provenance | Preserve original Start and distinct times, explicit unknowns; no millis->UTC or new Day1 on reconnect; ratify outage policy | BLOCKED |
| C15 | P0 schema/design + P1 implementation | Ally + Kath; Mary adapter validation | One exact versioned envelope and exhaustive catalog; separate actual parse size, queue occupancy and TX/RX caps; regenerate maximum proofs | REQUEST CHANGE |
| C16 | P1 build/physical readiness; P0 baseline choice | Ally lead; Kath Android; Mary backend; Cha evidence | Pin one agreed development image/core/dependencies; real compile/link/size and separate runtime/physical gates; no inferred flash | BLOCKED |

ACCEPT rows C03/C06 accept the principle as a coordination recommendation only;
neither is a joint resolved item or verified functioning feature.

## 5. Contract-breaking blockers, proposed resolutions and closure evidence

Each B-item has a named action owner and explicit reviewer/closure artifact.
All decisions remain unapproved. Design alternatives are presented for meeting
selection; no new exact wire layout/field is finalized in this register.

### B01 — Pin one source packet, architecture and development sketch (P0)

**Conflict:** H-C §A.1 selects USB and names a different development lineage;
V12:17,62-73 selects HC-05 and required lifecycle/recovery capabilities. U-W:10-12
and D-A §1 hash/reference an older packet. New filenames do not establish joint
supersession. H-C and H-F also contain serialized Markdown artifacts.

**Proposed decision:** publish one clean, uniquely versioned candidate source set
with raw hashes and accepted-change list; retain earlier files as historical.
Keep HC-05/Android and explicit local authority unless an architecture amendment
is affirmatively accepted. README upload directions do not choose the flashed
prototype or supersede design. Do not arbitrarily choose between the two sketches.

**Owner:** Cha source control/decision log; Ally firmware selection; Kath/Mary
confirm matching inputs. **Close with:** all four acknowledge same manifest and
baseline, a proposed firmware commit/hash/core identity, and a separate field for
unknown/flashed image. No actual upload is required for design acknowledgment.

### B02 — Contradictory command/ACK/version envelope (P0)

**Evidence:** H-C physical line5 §A.2 mandates `payload`; §A.4 example instead
uses top-level actuator/state; allowed keys use a third vocabulary. §C diagram
returns payload to Command. ACK status is alternately 200/400/409/replay, quoted
numeric text and a replay flag; existing Flutter actually reads `success` (S4).
Protocol version 0.2.3 is only inside app-sent HELLO; ordinary frames have none.

**Proposed decision:** Ally/Kath produce one closed, version-identifiable schema
per family, including exact command content, accepted/rejected/replay outcomes,
batch/controller/query correlation and field limits. No decoder may guess across
envelopes; Mary's adapter must target the same approved semantics. An arbitrary
actuator toggle is not an incubator lifecycle command.

**Owner:** Ally + Kath; **reviewer:** Mary; **Cha:** track J-02/J-04 closure.
**Close with:** one catalog, examples validated against exact schemas, mapping
table and same-ID/changed-content/replay test cases. No unilateral protocol choice.

### B03 — Missing source identity, original batch manifest and EEPROM collision (P0)

**Evidence:** H-C §A.3 says public deviceToken = 16-byte nonce at 0x100-0x10F,
HELLO labels it a 32-byte hex nonce; H-F §5.1 calls it 32 bytes in a 16-address
range. H-C §C places magic@0x100 and epoch@0x101 inside the same token region.
HELLO is app->firmware carrying what appears to be controller metadata/token;
who proves whose identity is undefined. `device:"UNO_R3"` is a board model,
not unique physical device. Event example lacks source device/u despite §A.7's
claim. No stable offline batch ID/original quantity/profile evidence is defined.

**Proposed decision:** agree public identifier versus secret purpose; count bytes
and hex characters distinctly; choose a nonoverlapping power-safe retained layout
only after actual EEPROM map review. Preserve separate provisioned controller,
installation, original batch, command and occurred-event identities. Mary may map
a compact alias to a UUID privately, but must not pad/cast an alias into a claimed
UUID or invent missing event IDs/times. Restoring phone local intent is not enough
after uninstall if controller/cloud original metadata is absent.

**Owner:** Ally retained map/identity; Mary canonical mapping; Kath original local
manifest/reinstall. **Close with:** agreed size/alphabet/namespace/counter/reset
rules, original manifest retrieval, EEPROM byte map/CRC/phase design and a lost-
phone recovery truth table. No addresses in the current proposal are adopted.

### B04 — No complete read-only recovery query (P0)

**Evidence:** H-C §A.7/H-F §5.2 explicitly omit query/response and rely on periodic
telemetry; H-C §C and H-F §5.3 invoke undefined GET_STATE. Telemetry examples do
not carry logical batch state/original command/count/profile/full Start evidence.
U-R:60,93-110 requires fresh query/state and retained original outcomes.

**Proposed decision:** require a bounded read-only reconciliation exchange that
returns bound source identity, actual batch/state, original outcome/manifest,
time confidence and retention gap information. It must never mutate profile,
counter, batch or outputs. Separate fresh observation from historical event.
The spelling/family can be selected jointly; an undefined GET_STATE is not a
solution and cloud get_reconciliation is not a physical query.

**Owner:** Ally + Kath; Mary checks evidence needed for projection.
**Close with:** exact schemas/correlation/snapshot/deadline/empty/no-match/gap
semantics plus lost ACK, duplicate query, old-event/new-state and wrong-source
fixtures. No-match alone cannot authorize another Start.

### B05 — Source replay removed without joint loss-policy approval (P0)

**Evidence:** H-C §A.7/H-F §5.2 say one-shot events discarded by power cycle; U-R
§5/6, D-R §5/7 and V12:21,68,93 require recoverable source facts or an explicitly
narrower approved guarantee. ACK replay is command-processing evidence, not a
retained transition archive. This is a **design regression proposal**, not a
missing-source-file problem.

**Proposed decision:** restore feasible bounded durable source replay, with
counter/epoch consistency, complete-event assembly, cursor/high-watermark/gap/
empty/end semantics and journal-full rules; OR have Ally/Kath/Mary explicitly
approve which offline/crash/reinstall events can be lost and revise UI/DB claims
to match. Do not claim original Start/count/time can be reconstructed from
current relay states. No unlimited retention or sensor backfill requirement.

**Owner:** Ally source journal/replay; Kath recovery/loss UX; Mary durable receipt
boundary. **Cha:** collect explicit loss-boundary votes. **Close with:** exact
capacity/layout/retention contract and power-cut/crash matrix, plus documented
acknowledgment boundary; runtime/hardware proofs remain later gates.

### B06 — 64-byte ring is not an absolute frame limit (P0 claim correction)

**SOURCE VERIFIED correction:** S7 declares `_rx_buffer` in software with a
conditional `SERIAL_RX_BUFFER_SIZE`; S8 enqueues arriving characters and `read()`
advances the tail. Normal 64-slot implementation leaves one slot empty. Frames
longer than the queue may be accumulated in an application buffer while that
queue is drained. The 64-byte ring is neither a UART hardware whole-frame store
nor an unavoidable wire-length cutoff. TX frames must not be rejected because
they exceed the Uno RX queue; direction matters. Do not enlarge buffers blindly:
compile configuration, SRAM and interrupt index constraints still apply.

**CALCULATED illustration:** at 9600 baud with 8N1, 10 bits/character gives 960
bytes/s; 63 queued bytes correspond to 65.625 ms without draining. This is not a
measured safe latency or guarantee: interrupts, burst delivery, critical sections,
blocking control/library routines and sender pacing determine actual overrun.
H-C's statement that *all* frames exceed 64 also contradicts its own 42-byte
Hello-ack. A 92-byte Command is not intrinsically impossible because of 64 alone.

**Real local limits:** S1 has 48-byte application storage; S2 has 120. S3's reader
can hold at most119 content bytes plus NUL and has unsafe overflow resumption.
No claimed 160-byte local buffer was found in the inspected Uno variant. These
are independent facts, not proof either sketch can run the candidate protocol.

**Owner:** Ally correct feasibility/capacity claims; Kath sender/framer timing;
Mary evidence caps. **Proposed decision:** measure RX service latency and actual
parse limits separately from buffered queue capacity and TX streaming. No binary
switch or arbitrary191/256-byte allocation is justified by the false64 premise.
**Close with:** pinned core/sketch configuration, bounded maximum frame schemas,
runtime service/timing/memory analysis and later targeted overflow tests. Physical
transport/build readiness remains UNKNOWN until separately verified.

### B07 — Literal counts pass, maximum and memory proofs do not (P1/P0 sizing)

H-S was fully read. No usable Python executable was identified here (command
discovery found Windows app aliases only); the script **was not run**. Independent Node reproduction
uses compact JSON + LF, exact ASCII fields, exact uint64 literal and Python's
49.0 spelling. All six listed **literal** counts match:

| Constructor / H-S lines | Content / with LF | Declared with LF | Result |
|---|---|---|---|
| COMMAND:72-77 | 91 / 92 | 92 | MATCH |
| TELEMETRY:90-106 | 183 / 184 | 184 | MATCH |
| ACK:81-87 | 127 / 128 | 128 | MATCH |
| HELLO:109-119 | 190 / 191 | 191 | MATCH |
| HELLO_ACK:122-125 | 41 / 42 | 42 | MATCH |
| EVENT:128-135 | 93 / 94 | 94 | MATCH |

This does **not** verify the maximum declarations: MAX_DEVICE_LENGTH and
MAX_ACTUATOR_LENGTH are not used to generate the corresponding payload widths;
UNO_R3 is not a31-character source identifier; literal actuator/profile/string/
metric/error values are not exhaustive maxima. Arbitrary <=23-char IDs can need
escaping and expand on wire. Null/invalid variants, negotiated fields and distinct
command envelope choices are not counted. Uint64 literal maxima exceed signed
64-bit and JavaScript-safe integer range; runtime precision requires explicit
type/width rules, not merely same number of printed digits. No sensor values in
the script are observations, approved targets or proof of calibration.

The H-S assertions compare constructed literal length with a table; they do not
compare against an implemented frame cap or prove schemas match H-C §A.2.
No actual Python PASS or new firmware build is claimed in this register.

H-F §3.1 records compiler exit0 with `linker input file unused because linking
not done` and no object/ELF/HEX. That is **not evidence that the .ino was compiled**;
correct it to unverified compiler invocation. Estimates cannot establish stack
headroom; earlier1794-byte Combined figure and later Uno estimates are not
comparable linked builds of the same configuration.

**Owner:** Ally. **Kath/Mary:** review exact maximum fixtures/types.
**Proposed decision:** publish a corrected schema-driven, maximum-width generator,
then a real preprocess/compile/link/size artifact for the chosen sketch/core/
libraries; separately assess stack/runtime. **Close with:** reproducible commands,
toolchain versions, output artifacts/map/size and source correspondence. None
requires flashing or authorizes powered loads.

### B08 — Physical lifecycle, reboot and Stop evidence (P0)

**Evidence:** H-C §A.7/H-F §5.2 infer Stop from actuator false or TURN_STOPPED;
turner lockdown is not incubation completion and thermostat duty-cycle-off is
not batch Stop. H-F §5.3 corrupt commandAckSeq -> BATCH_START conflicts with
V12's no auto-new-batch and original Start preservation. H-F §5.4's single-writer
manifest plus CRC statement alone is not a complete power-loss atomicity proof.

**Proposed decision:** define explicit logical admission/prepared/occurred/recovery
phases; persist intent safely but never replay a prepared record as an occurred
started transition. Same for Stop: local safety action must remain possible when
storage is full, but missing durable evidence must be reported honestly. Keep
controller-reported state separate from independent physical actuator feedback.
ACK is receipt/admission/processing only; exact meaning must be frozen per code.

**Owner:** Ally lifecycle/safety; Kath failure UX; Mary allowed event projection.
**Close with:** state transition/rejection table, same-ID/content persistence,
fault/full-journal/corruption and every power-cut boundary, original-source facts
replayable without re-energizing outputs. Subsequent electrical/physical tests
are separate authorized evidence, not prerequisites to pretending code exists.

### B09 — Offline/online authorization and source authenticity (P0)

**Evidence:** H-O EMB-02 says no wire auth. A public EEPROM nonce or board name
does not bind an authorized phone. H-C APP->FW HELLO carrying firmware/device
details plus accepted-only reply cannot establish source possession by itself.
D-S §4 separates non-anonymous cloud identity/session registry from local keys;
U-R §4 requires provisioned offline authority before sending.

**Proposed decision:** agree threat model and feasible offline command ownership,
key provisioning/generation/replacement and challenge/replay handling. Separately
review Mary's Auth/session registry, RLS/grants and scope. No service-role key on
phone/firmware and no user-editable authorization. Cloud revocation is not instant
offline Bluetooth revocation; display/setup/recovery and accepted limits must be
explicit. Android credentials can identify uploader without cryptographically
proving a genuine sensor acquisition; do not overclaim provenance.

**Owner:** Ally offline mechanism; Mary cloud/credentials/RLS; Kath secure storage/
provisioning UX; Cha threat-model decision log. **Close with:** agreed security
boundary/key purposes, exact binding/validation, tests-to-run for forged/wrong/
revoked/copied sessions and controlled recovery. Actual security enforcement
tests require separate implementation/test-project authorization.

### B10 — Unverified receipt must not release evidence (P0)

**Evidence:** H-O EMB-03/H-F §5.5 say backend signs but no device channel exists;
D-A §6 and D-R:234-269 deliberately return `retention_ack:null`; no signing or
verifier was implemented. H-C removes source retention entirely. These are not
working alternatives. A certificate chain is not the only possible authentication
design, but no MAC/signature scheme is approved by these reports.

**Proposed decision:** retain no-auto-release. If supported, prove a domain-
separated server/Uno authenticated receipt binding source identity/generation,
exact retained event and locally comparable content, stable receipt/revision and
qualifying disposition; phone relays unchanged. A phone-known command MAC must
not masquerade as server commitment. Pending/conflict/error/HTTP2xx alone cannot
release evidence. Cloud JCS includes Android manifest data Uno may not retain;
agree source-only fingerprint linkage rather than assuming equal local hashes.

**Owner:** Mary server proof; Ally bounded verifier/journal; Kath relay/local
receipt handling; Cha approval capture. **Close with:** agreed trust/loss boundary,
key/preimage/verification/positive-release/replay/corruption behavior and feasible
size/memory plan. Runtime cryptographic validation is a later test gate. If
infeasible, all explicitly ratify the narrower retention guarantee (B05).

### B11 — Profiles, timing, validity, pilot scope (P0)

**Evidence:** H-C §A.4 allows brooderStart/incubationDay/turnNow/setPoint outside
the selected farmer pilot. H-F §5.5 lacks RTC; u/time are monotonic microseconds,
not UTC. U-R §8 needs per-channel validity and separate age; H-C sensors' shared
valid flag means fresh yet false only on invalid values, leaving stale case
undefined. U-R current6..12 is source behavior, not approved capacity. No source
supplies an approved Chicken numerical manifest. DeviceToken/header units and
microseconds also differ from the earlier seconds/UTC candidate.

**Proposed decision:** Chicken-only physical pilot, fresh eggs only; preserve
other species cards as informational/software where agreed. Keep original count,
approved immutable profile mapping, no mutable guessed targets or day offset.
Ratify quantity and profile/turning/lockdown/safety values with named approver.
Retain independent validity/unknown-age/fresh/stale; new arrival never repairs age.
Agree RTC units/range/validity/current elapsed reference, drift/skew/outage policy;
never map uptime to occurred_at or reconnect to Day1. Formula remains
floor(elapsed_seconds/86400)+1 only with trustworthy reference. No numeric
freshness threshold or profile value is approved here.

**Owner:** Ally + named profile approver; Kath display/local time; Mary exact
DB projection/provenance. **Close with:** approved profile/version/capacity/scope
table and clock/unknown/stale policy plus boundary fixture plan; actual RTC,
calibration, regulation/outage/electrical proof remains UNKNOWN.

### B12 — Mary DB/UI mapping, completion policy and stale document assumptions (P0/P1)

**Evidence:** Mary D-A requires source keys/payloads absent from H-C; D-R §3
requires applied Stop before completion; U-F:31 and U-R §7 allow independent
manual capture but do not finalize upload timing while Stop evidence is absent.
UI status/save/dependency/conflict states otherwise map well to D-R §4/5.
DB files' prior full-UI-missing caveat is now stale, but their headers/adapters
were not updated by this task. H-O treats backend signing as supplied; it is not.

**Proposed decision:** Mary/Kath freeze exact cloud core/normalization and receipt
hash/revision/mapping semantics only against the selected hardware evidence.
Preserve existing table names and bigint IDs, immutable offline batch association,
no current-active reassignment, source/phone/server times, separate Stop versus
manual count, explicit legacy conflict recovery. Decide whether farmer data can
remain a local draft until Stop dependency is known (current DB candidate), or
needs a separately specified pending manual-event policy. Do not invent a Stop
reference or auto-send Stop/auto-complete to close the gap. Update candidate
adapters/docs only after owners accept the selected source set; no automatic
protocol translation from H-C into synthetic started/stopped events.

**Owner:** Mary backend proposal revision; Kath local outbox/receipt; Ally source
capability; Cha change-control review. **Close with:** mapping for every required
source item or explicit unsupported outcome, approved cloud schemas and complete
fixtures for duplicate/mutated/reordered/lost-response/dependency/legacy-Active
cases. Existing prior fixture passes cannot certify a changed source protocol.

## 6. Decisions requested from the four participants

No row is already approved. These are the smallest **decision outputs**, not
extra independent JSON proposals. Cha records accepted wording/revision/hash
and individual decision from each participant; disagreement remains blocked.

| Decision | Required answer / deliverable | Lead and accepting reviewers | Blockers addressed |
|---|---|---|---|
| D01 Baseline/change control | Which exact source packet/sketch/core is the next candidate? HC-05 stays primary or explicit amendment? One clean hash-pinned manifest, old reports retained | Cha coordinates; Ally, Kath, Mary accept | B01, C05/C16 |
| D02 Lifecycle/identity/recovery capability | One consistent command envelope; distinct IDs; deliberate Start/Stop; safe read-only query; correlated occurred event/current snapshot; original quantity/profile retrieval. Restore replay or explicitly choose a loss alternative | Ally lead; Kath and Mary accept; Cha records scope | B02-B05/B08 |
| D03 Capacity/build proof | Remove absolute64 claim; freeze actual RX/TX/parse/type limits with queue service/timing, max fixtures and source/build correspondence; no automatic buffer/binary switch | Ally lead; Kath and Mary review results | B06-B07 |
| D04 Authority/retention trust | Offline command auth versus online authorization; key provisioning/replacement/revocation, source-claim limits; qualifying receipt proof or bounded loss/service path, full journal and Stop safety | Mary cloud + Ally local; Kath UX; all four record guarantee | B05/B09-B10 |
| D05 Clock/profile/pilot | Name numerical-profile approver; ratify Chicken capacity/version/scope, clock-invalid admission/day/outage policy and independent validity/age semantics | Ally + designated approver; Kath/Mary map; Cha tracks named approval | B11 |
| D06 Cloud/local projection | Exact accepted source-to-cloud adapters, canonical core/hash, session mapping, dependency/conflict/disposition, receipt revision and farmer-completion policy, legacy handling; Mary revises DB-02, Kath aligns UI | Mary + Kath lead; Ally evidence review; Cha cross-checks final manifest | B12 |

These decisions may close design questions after explicit agreement; code changes,
database execution, hardware safety and integration readiness still need their
separate evidence gates. Do not demand existing endpoint deployment or physical
flashing merely to call a design clause reviewed, and do not infer readiness
from design approval. Keep K06 v0.5, portal approval and final v1.3 on hold.

## 7. Minimal joint meeting agenda

1. **Cha opens with the manifest (D01).** Confirm all are reviewing corrected HW
   plus lineage-aware UI/DB, and assign Mary backend ownership. Record source-set
   choice/architecture and exact unresolved claims, not an automatic adoption.
2. **Ally + Kath resolve the required capability set (D02).** Decide recovery
   query, occurred/current separation, IDs/original metadata and replay/loss
   direction first. Do not debate new key spellings before required facts exist.
3. **Ally presents capacity evidence/corrections (D03).** Accept the queue-versus-
   frame correction; assign missing maximum/timing/build artifacts. No vote can
   manufacture SRAM/headroom proof; unresolved bounds stay blocked.
4. **Mary + Ally present trust/retention options (D04).** Kath confirms lost-phone/
   outbox/support consequences. Explicitly choose whether the required guarantees
   are feasible or need a joint scope reduction; never assume phone receipt is
   server-authenticated release.
5. **Ally identifies profile approver and time policy owners (D05).** Ratify only
   supplied approved inputs; retain unknowns instead of improvising values.
6. **Mary + Kath close the mapping/receipt actions (D06).** Fix the Stop/manual-
   completion policy and selected adapters. Cha ends with named artifacts,
   unresolved blockers, individual decisions and next review revision; no joint
   sign-off until the identical concrete candidate is circulated and accepted.

## 8. Recommended implementation order and named actions

The current task stops at documentation. Below are future actions, not execution
authorization. No branch merge, reset, commit, push, Auth provisioning, SQL or
physical command is included in this register's completion.

| Order / action | Accountable owner | Required input / output / evidence |
|---|---|---|
| A01 Version/source reconciliation | Cha | D01 accepted source manifest, current ownership, revision lineage and open decisions; individual votes recorded |
| A02 Correct hardware feasibility/catalog | Ally | D02/D03; clean schemas, complete read-only query/replay or loss decision, storage layout/phase/counters, real compiler artifacts and maximum/timing evidence |
| A03 Android/source-state compatibility review | Kath | Same A02 revision; byte framing/correlation, local intent/dispatch/evidence/outbox/receipt transactions, crash/partial/reinstall truth table and compatible dependency proposal |
| A04 Backend evidence/security proposal revision | Mary | Same A02/A03; revised exact API/additive schema/canonicalization and scoped provisioning, dependencies/conflicts/receipts, no migrations executed |
| A05 Profile/RTC/safety admission package | Ally + designated profile approver | D05 approved numerical inputs and clock policy, pin/module/source evidence and planned physical/safety gates; Kath/Mary mappings |
| A06 Receipt/loss-boundary agreement | Mary server + Ally verifier; Kath relay | D04; feasible canonical source linkage, keys/verifier/release or explicit narrower recovery guarantee; Cha records accepted limits |
| A07 Pre-freeze consistency review | Cha | One selected catalog + A03/A04/A05/A06, field-by-field matrix with no P0 design blocker; same-version sign-off by Ally/Kath/Mary, coordination acknowledgment by Cha |
| A08 Separate implementation tasks | Ally firmware; Kath Android; Mary backend | Only after design authorization; isolated branches/worktrees as appropriate and minimal scoped changes, no unreviewed main-database deployment |
| A09 Software/build/test-project validation | Ally/Kath/Mary in their domains | Parser/serialization/queue/journal/SQLite/transaction/RLS/revocation/replay/reorder tests; distinguish models/builds from real integration; approved test destination |
| A10 Physical/end-to-end and claims review | Ally hardware; Kath Android; Mary server; Cha evidence coordination | Separate documented electrical clearance and authorization before powered loads; genuine source-to-row/receipt, disconnect/restart tests; no invented hatchability or unattended-safety claims |

Before A08, a design packet can be jointly approved without claiming tested
hardware. Before live operation/main rollout, A09/A10 and required deployment
review must meet their own acceptance criteria. Prototype physical image remains
UNKNOWN unless actual upload/verification evidence exists.

## 9. Current closure ledger

| Item | Evidence availability | Current closure status |
|---|---|---|
| Four HW files | Full raw contents read, exact hashes pinned | AVAILABLE; semantic/design blockers remain |
| Three full UI files | Full contents read, not summary; earlier input blocker cleared | AVAILABLE; authored against older HW |
| Three DB files | Full contents read incl. embedded schemas/examples | AVAILABLE; original owner header preserved, Mary owns revision; old adapters not selected |
| Original v1.2 | Full contents/hash, matches UI cited baseline | AVAILABLE; NOT APPROVED |
| Six literal counts | Independently reproduced including LF, all match H-S table | CALCULATED only; not maximum proof or actual Python execution |
| Absolute64 claim | Counterevidence from installed AVR1.8.8 software ring/read/write | REQUEST CHANGE; actual runtime service capability still UNKNOWN |
| Build/stack/physical source identity | No new compile/link/map/upload/device test | UNKNOWN; H-F exit0 claim not upgraded |
| Live database/security behavior | Prior inventory cited only, no new queries or identity tests | STRUCTURE ONLY; runtime security not certified |
| Joint protocol approval | No individual decisions on a selected revised packet collected | BLOCKED; 0 approvals claimed by this register |

## 10. Validation record and completion limits

Actually performed during coordination:
- Full source reads for the manifest, display-only expansion for escaped HW
  exports, raw SHA-256 pinning and prior-HW hash comparison.
- Targeted sketch/Flutter/Supabase/README reads for actual mismatches; locally
  installed AVR1.8.8 core reads for the false absolute-frame-limit assertion.
- Independent Node compact-JSON literal byte counts preserving uint64 digits
  and integral float49.0 spelling, plus 8N1 queue arithmetic. Only stdout emitted.

No supplied Python script execution, firmware compile, Flutter build/test,
dependency installation, database audit/write, API/Auth/RLS/security test, source
key inspection, Bluetooth connection, pin/wiring change, flashing, powered-load
test, deployment, commit or merge. Earlier UI/DB test results are attributed prior
evidence, not rerun or promoted to current integration success.

Actual final document checks passed:
- 11 required source/baseline raw SHA-256 values match the full local files.
- All 16 C01-C16 IDs have both requirement/conflict and owner/decision/status rows.
- All 12 B01-B12 blocker records, six D01-D06 decision outputs and ten A01-A10
  named action entries are present; owner/closure-evidence text was reviewed.
- All four repository-relative Markdown links resolve; code fences balance.
- Git whitespace check reports no whitespace errors; it emits an LF-to-CRLF
  warning. No line-ending setting was changed.
- Final Git status adds only this register to the initial existing-work snapshot.
  The source proposals' hashes/headers were preserved; the new file is untracked
  and uncommitted on cha-branch2, and the existing worktree remains active.

Validation used Node v26.4.0 read-only checks (fs reads, crypto SHA-256,
Buffer.byteLength and structural assertions) and `git diff --no-index --check`
against NUL for this new Markdown file. These checks are not protocol runtime,
firmware compilation, SQL, security or physical tests. No branch/worktree was
created/removed and no cleanup was needed or authorized for this unintegrated work.

**Task completion means the coordination register is prepared, not any contract
decision is jointly approved.** Stop after this document; collect the meeting
answers and exact owner revisions before preparing any final v1.3 or code tasks.
