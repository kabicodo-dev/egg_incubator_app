# UI-CONTRACT-02 — Wire Compatibility Review

Reviewer: Kath — Flutter/UI/UX. Date: 2026-10-28.

**Follow-up decision: REQUEST CHANGE; exact examples reviewed, final compatibility still BLOCKED.** Documentation only, not protocol approval or implementation authorization. HW-02's missing-input blocker is now cleared; its unresolved schemas, security and feasibility are not.

## 1. Inputs and evidence

- Reviewed `C:\Users\ACER\Downloads\SmartHatch_v1.2.md`, all 255 lines. SHA-256: `6814dc872f18ab1b54488c25ac1c4df7ae433c7bf62e5ba389262ee0a009bf47`.
- **Follow-up inputs read completely:** `HW-02_Exact_Wire_Message_Catalog.md` (167 lines), `HW-02_Uno_Feasibility_And_Recovery.md` (131 lines), `Open_Decisions.md` (67 lines), supplied in Downloads. They supersede this review's earlier missing-input finding, not shared v1.2 approval.
- Input SHA-256 values: catalog `b43da3e1a42d3a2a2a0c5b5455d4dfa713b4d36ac409ae08a5925bd9acd5327d`; feasibility `85627787fa4b566e0b97609c7a6d880ba61bbd6be17ef6aa7e5f67dda64fde41`; decisions `23de67cb97c6b1dc28e7ea59974345678ae87d6eeb17292162e73e4cf5eef0fd`.
- **CALCULATED in follow-up:** independently parsed and counted all 14 JSON literals using Python, then constructed the listed section-6 split alternatives and counter-width probes. These are document calculations, not application parser tests, worst-case proofs or hardware tests. Ally's referenced count script was not supplied; it was not run.
- v1.2 remains the shared candidate; HW-02 provides proposed additions/changes, including compact aliases instead of UUIDs. They require joint reconciliation.
- **SOURCE VERIFIED:** inspected Flutter working tree at repository HEAD `c7a26cfcaa619708aff4f793e8068ee176a6cf58`; pre-existing uncommitted UI/generated/test/document files remain present. References describe inspected files, not necessarily pristine HEAD.
- **DOCUMENTATION VERIFIED:** official Android documentation and current sqflite package metadata, retrieved 2026-10-28. These establish platform/package requirements, not project build success.
- **PROPOSED:** all implementation designs below and in the two companion documents. **UNKNOWN:** device compatibility, physical behavior, flashed sketch and memory/runtime safety.
- No new build, Flutter test, dependency installation, database access, hardware command, firmware upload or deployment was performed. Historical test totals are not UI-02 verification.

## 2. Current application and actual dependencies

| Evidence | Verified finding | Consequence |
|---|---|---|
| `pubspec.yaml:7–17`; `pubspec.lock:169–176` | Dart floor 3.11; `flutter_libserialport` resolves to 0.6.0 | USB serial is not Android RFCOMM support |
| `pubspec.yaml:10–17` | Direct dependencies: Flutter SDK, supabase_flutter, flutter_dotenv, cupertino_icons, google_fonts, flutter_libserialport | No direct Bluetooth or local SQLite dependency |
| `pubspec.lock:499–506` | shared_preferences 2.5.5 is transitive | Does not establish a transactional batch ledger/outbox |
| `lib/services/arduino_serial_factory.dart:1–10` | dart:io selects libserialport even on mobile | A platform branch is not Bluetooth capability detection |
| `android/app/src/main/kotlin/com/example/egg_incubator_app/MainActivity.kt:1–5` | Plain FlutterActivity | No native RFCOMM bridge |
| Main Android manifest `:1–45` | No Bluetooth permissions | Permission/runtime design is outstanding |
| `android/settings.gradle.kts:20–23`; app Gradle `:9–23,41–44` | AGP 9.1.0, Kotlin 2.4.0, JVM 17; SDK levels delegated to Flutter | Numeric resolved SDKs and release-build compatibility not established by a build |
| `.dart_tool/package_config.json:600–602` | Cached generator Dart 3.13.3 / Flutter 3.47.3 | Cached metadata, not a newly verified runtime/toolchain |
| `lib/main.dart:16–31` | Anonymous online sign-in awaited before runApp if session absent | Offline startup/recovery is not implemented |
| `lib/main.dart:2734–2772` | Cloud-first session creation, phone Start time, humidity 55, then Started navigation | No controller-confirmed offline Start flow |

## 3. Catalog disposition — no invented replacement protocol

Meaning: **ACCEPT** accepts the specified candidate structure/semantics as interpretable in a future strict Flutter decoder, not compatibility with today's parser or joint approval. **REQUEST CHANGE** requires the listed correction. **BLOCKED** requires an unmade security/product/feasibility decision. Every frame requires `v:1` integer and exact case-sensitive string `t`.

| HW-02 family | Direction | Decision | Exact correction / dependency |
|---|---|---|---|
| HELLO request (§3.1) | Android → Uno | ACCEPT | `v,t,qid` are unambiguous; 44 B. Read-only; unique 16-lowercase-hex query per exchange. Response still needs correlation/authentication fixes. |
| HELLO response (§3.2) | Uno → Android | REQUEST CHANGE | Sample `dev` violates hex rule. Echo request `qid`; bound `fw`, `caps` count/item lengths, rx/tx and auth enum. Define J1/EV1/TEL1 and split support explicitly. `auth:"authorized"` alone is not authenticated authority; freeze handshake. |
| START (§3.3) | Android → Uno | BLOCKED | Exact sample is 169 B, not oversized at 191. Do not adopt PREP/COMMIT solely on speculative size. Freeze pv/MAC widths, original quantity bounds, profile and auth/canonical binding first. CH-PENDING/tag placeholders cannot authorize Start. |
| START_PREP / PREPARED / START_COMMIT (§3.3 alternative) | Both | BLOCKED | Not exact schemas/examples yet; select only if full maximum START does not fit. Define prep-token binding, expiry/reboot, persistence, commit dedup, and read-only recovery. PREPARED is not START acceptance/Running. |
| STOP (§3.4) | Android → Uno | BLOCKED | Candidate keys/types interpretable, 134 B. Need verified authorization and exact already-stopped/no-match/full-journal behavior. A prior STOP identity must be recoverable after reboot; no ACK-as-Stopped. |
| STATUS (§3.5) | Android → Uno | ACCEPT | `v,t,qid` read-only query, 45 B. Flutter uses fresh qid; response completeness/observation ordering remains REQUEST CHANGE under STATE. Do not reuse qid to obtain a changed snapshot. |
| ACK accepted / rejected (§3.6) | Uno → Android | REQUEST CHANGE | Boolean ok and cid are interpretable. Freeze code/ok combinations: true only ACCEPTED, false rejection enums; freeze optional detail length or omit. Match cid to immutable local operation/bound controller. Define accepted timing vs durable transition; lost ACK is not failure. |
| STATE full (§3.7) | Uno → Android | REQUEST CHANGE | 198 B exceeds cap. Original split core also reaches 197 B with advertised counters/STARTING. Freeze smaller split and null/time/snapshot semantics; latest event seq alone is not an observation revision. See corrections below. |
| STATE + STATE_PROFILE (§6) | Uno → Android | REQUEST CHANGE | Need literal schemas and counts, one frozen snapshot per qid and exact join/conflict/timeout rules. Accept core operation only as partial state; missing profile/Start-time detail blocks readiness/day, not an automatic Start. |
| EVENT full (§3.8) | Uno → Android | REQUEST CHANGE | 204 B exceeds cap; choose exact split or another jointly approved limit. Fix invalid dev/eid sample, canonical ID width, original ep on replay and event-vs-prepared persistence semantics. |
| EVENT_CORE + EVENT_TIME (§6) | Uno → Android | REQUEST CHANGE | Keys are interpretable; define immutable join `(dev,ep,seq)` and canonical `(dev,seq)` identity only if seq globally persistent. Both parts required, including explicit null/false time. Partial record cannot confirm complete history/upload/release. |
| TEL (§3.9) | Uno → Android | REQUEST CHANGE | 169 B sample; use true Boolean validity, finite actual numbers or null/false. Fix dev; freeze bounds/precision, tv/ts and bid null policy, epoch uniqueness and acquisition/skew/freshness. Counter-width probe is 185 B before other value growth. |
| ERROR (§3.10) | Uno → Android | REQUEST CHANGE | Codes and nullable cid interpretable, 48 B. Define query-error correlation (`qid` or explicit uncorrelated timeout policy), mandatory fields and maximum widths. cid:null cannot reject any pending operation. Never parse a malformed ID to target a command. |
| REPLAY request (§3.11) | Android → Uno | REQUEST CHANGE | Freeze `after` as exclusive seq cursor, uint32; limit integer 1..2; fresh qid. Define how sequence zero is fetched, authorization/scope and outstanding-request serialization. |
| REPLAY_END (§3.11) | Uno → Android | REQUEST CHANGE | Define actual returned-count/first/last, empty result nulls, fixed snapshot boundary, oldest-retained/gap/completeness and more. Example first101/last103/limit2 cannot establish completeness without gap semantics. Advance only through durably complete records. |
| RCPT_ACK (§3.12) | Android → Uno | BLOCKED | Exact canonical eid, event-content binding, receipt identity/revision/disposition/auth scheme and positive release response absent. Only authenticated qualifying applied receipt can release; phone-generated tag example is not evidence of server commit. |

**Current Flutter compatibility: REQUEST CHANGE for every new envelope.** Existing decoder reads `type` and legacy message shapes, not uppercase `t` families; acceptance above means proposed semantics are implementable, not already implemented.

### Independently reproduced counts

All 14 examples parse as JSON; syntax validity does not imply schema validity (all four device-bearing examples violate dev hex rule). Counts below are content / with LF bytes:

| Literal | Bytes | Fits provisional 191 content? |
|---|---|---|
| HELLO request / response | 44/45; 133/134 | Yes / Yes |
| START / STOP / STATUS | 169/170; 134/135; 45/46 | Yes / Yes / Yes |
| ACK accepted / rejected | 70/71; 67/68 | Yes / Yes |
| STATE / EVENT | 198/199; 204/205 | No / No |
| TEL / ERROR | 169/170; 48/49 | Yes / Yes |
| REPLAY / REPLAY_END / RCPT_ACK | 67/68; 85/86; 105/106 | Yes / Yes / Yes |

The original §6 split alternatives, constructed from their listed fields using literal sample values, measure STATE core 180/181, STATE_PROFILE 143/144, EVENT_CORE 149/150 and EVENT_TIME 92/93. With ep/seq at 4294967295 and st STARTING, STATE core becomes **197/198**, still oversized. EVENT_CORE with maximum counters and fault_entered is 171/172; EVENT_TIME 108/109. These are specific probes, not full maxima (profile, code/detail, caps, timestamp and metric widths remain unfrozen).

The 191-byte target is **not current Uno capacity**. This workspace's F2 source independently has `char serialLine[120]` at line108 and stores at most119 content bytes plus NUL (`:487–500`). Proposed START169 and STOP134 cannot be safely sent to that unchanged reader; the catalog's unknown implementation/build status must not be mistaken for an upgraded receiver. Ally's feasibility report says source access failed in its environment; that is distinct from this workspace's source observation. Neither establishes the physical flashed image.

Reproduction without Ally's absent script: extract catalog fenced JSON with `re.findall(r'```json\s*\n(.*?)\n```', text, re.S)`, run `json.loads(s)`, then `len(s.encode('ascii'))` and add one for LF. Split probes select §6's exact listed fields, serialize compactly with `json.dumps(..., separators=(',',':'))`, and replace only the noted scalars. All calculations were host-side, not Flutter or Uno tests.

## 4. Exact current incompatibilities and requested shared corrections

1. `lib/services/arduino_protocol.dart:330–353` dispatches `type` values telemetry/ack/lcdAck, not a compact `t` envelope. If the final catalog retains compact keys, add a separately versioned approved decoder later; do not silently route through legacy parsing.
2. `arduino_protocol.dart:55–98` accepts numeric strings, rounded numbers and permissive Boolean conversions. Proposed decoder must validate exact schema types, finite numbers and integral counters without coercion.
3. `arduino_protocol.dart:265–275` requires string ACK ID and reads `success`; F2 `arduino/SmartHatch_Combined/SmartHatch_Combined.ino:392–396` emits numeric ID and `status`. Transport alone cannot repair this semantic mismatch.
4. `arduino_serial_io.dart:178–192` allows malformed UTF-8 and processes complete lines before checking residual length. Enforce the bound before decoding any complete line and before accumulating unbounded input.
5. F2 `:439–455,464–500` uses substring extraction, enables text commands and restarts accumulation after overflow. Reject invalid whole frames and discard through delimiter; production Bluetooth must not retain an unauthenticated text-command bypass.
6. F2 `:398–414` deduplicates numeric IDs without comparing content; `:528` clears cache on boot. Persist/recover command outcomes and reject changed content under one identity.
7. Flutter telemetry stores receipt time (`arduino_protocol.dart:131–175`), not acquisition time; controller `:34–35,71–78` uses a six-second receipt threshold. Neither is sufficient for delayed/replayed telemetry freshness.
8. `main.dart:175–193` discards Start time-of-day; `:4664–4672,4713–4717` falls back to targets/setpoints. Preserve original time and actual-value absence instead.

These are requested shared-contract/implementation requirements. No files implementing them were changed.

## 5. Field validation and cross-component identity corrections

| v1.2 candidate | Flutter interpretation / validation proposal | Outstanding decision |
|---|---|---|
| HW-02 dev / iid aliases versus v1.2 UUIDs | dev must match `[0-9A-F]{16}`, iid `[0-9a-f]{16}`. `SH01A1B2C3D4E5F6` is 16 characters but S/H are not hex. Replace synthetic sample with e.g. `AB01A1B2C3D4E5F6`, or explicitly change alphabet; do not accept both silently | Cha must bind aliases to provisioned controller/installation UUIDs; never pad/cast a 64-bit alias into a claimed UUID. Ally proves provisioned uniqueness |
| Batch UUIDv4, 32 lowercase wire hex | Exact `[0-9a-f]{32}` if adopted; preserve losslessly and convert to cloud UUID explicitly | Ally approves storage/frame fit; Cha canonical conversion |
| Command 16 lowercase random hex | Exact `[0-9a-f]{16}` if adopted; preserve as text, never double or signed-bigint conversion; secure random generation, local uniqueness and collision rejection | Cross-installation scope, retention and replay/exhaustion: all three |
| Event counter / boot epoch / sample counter | Candidate unsigned 32-bit: integer token in `0..4294967295`, no fractions, strings, overflow or silent wrap | Zero/reserved values, exhaustion and controller reinitialization: Ally + Cha |
| Cloud session bigint | Canonical decimal string in cloud API; no leading sign/zeros unless explicitly permitted; range per server contract | Exact range, nullable cases: Cha |
| ts / start_s and tv | Integer UTC Unix seconds if tv:true; propose mandatory null when tv:false. No omission, zero-as-unknown or phone-time substitution. Reject true/null and false/non-null. Range not defined by packet; unsigned does not automatically mean 32-bit | Ally + Cha must approve time range, skew, each message's source meaning and null schema |
| Cloud occurred_at / timestamp_valid | Candidate whole-second UTC RFC3339 or null; Boolean true iff trusted source instant is present; retain invalidity | Per-kind source vs farmer time, skew bounds: Cha + Ally |
| Egg quantity | Current app permits integers 6..12 (`supabase_service.dart:100–123`); this is source behavior, not newly approved hardware capacity | Ally/profile approver + Cha must ratify same bounds |
| pv, sp, qty | pv immutable string, CH-PENDING forbidden admission; sp exact integer 1/2/3, Chicken pilot only; no truthy/string coercion; qty current app 6..12 conflicts with proposed 1..unknown-capacity | Approve one quantity rule and pv alphabet/max length, profile and per-state nulls; no numerical profile invented |
| tc, rh, t_ok, rh_ok | Metric finite JSON number iff its own Boolean is true, otherwise null/false. Reject quoted numbers, NaN/Infinity, true/null, false/number; integral-valued JSON numbers are acceptable metrics | Ally approves sensor limits/precision/acquisition cadence; Cha maps tc→current_temperature, rh→current_humidity without targets |
| st, kind, ok, code, detail | Exact catalog enums; st string, kind string, ok Boolean; detail omit or fixed bounded string. No unknown-state fallback to IDLE/RUNNING | Freeze ok/code table, optional detail bytes and internal safety event cid null policy |
| rx, tx, fw, caps, auth, clk | rx/tx positive integer content limits within supported local bounds; fw string, caps bounded unique string list, auth allowlisted string, clk Boolean; mandatory qid echo proposed | Lengths/limits/cap meanings/auth handshake remain BLOCKED; untrusted HELLO cannot allocate arbitrary buffers |
| after, limit, first, last, more, rev, dis | after uint32 exclusive; limit integer1..2; more Boolean; first/last null when empty proposed; rev positive integral with frozen upper bound; dis exact applied/waiting_dependencies/conflict | Replay boundary/gaps/count and receipt type ranges remain incomplete |

Unsigned 32-bit integers fit exact native Dart integer arithmetic and JavaScript safe-integer range; their persistence/reboot feasibility on Uno is unproven. No identifier may pass through floating-point parsing. Counter storage loss must not recycle old source identities.

## 6. Proposed strict framing algorithm

1. Allocate bounded framer state for the negotiated supported protocol; maintain CONTENT and DISCARD_TO_LF modes. Bound native queues/platform-channel batches as well as Dart accumulation.
2. Process each chunk byte-by-byte; chunks may contain a prefix, suffix or several frames. LF ends one frame. No command action from partial data.
3. On first excess content byte enter DISCARD_TO_LF, clear partial content, report one bounded error and consume everything through LF. Resume only with the next complete frame.
4. Define optional CR explicitly with Ally. Proposed acceptance: only one CR immediately before LF, excluded from content but included in raw-wire capacity; reject embedded CR. Uno NUL is local parser storage, not transmitted data.
5. Strictly decode the agreed ASCII-compatible subset. Reject malformed UTF-8, illegal bytes, invalid escapes, trailing data, non-object roots and duplicate keys at every object depth. Use a duplicate-aware parser/tokenizer; ordinary map-producing jsonDecode alone does not establish duplicate-key rejection.
6. Validate version and message schema: exact keys/types, mandatory keys, allowlisted enums, finite/ranged values, exact IDs, null/validity consistency and no unapproved extensions. JSON key order must not matter.
7. Unsupported version: quarantine/ignore the frame for state transitions, display update/help state and disable physical commands. Do not guess a legacy schema or reply with unsolicited actuator commands. Diagnostic messages contain no credentials/raw farmer-facing JSON.
8. Validate bound controller, connection generation, batch, command/event/sample and ordering before changing projections. Invalid or unrelated evidence cannot confirm a pending operation.
9. On disconnect, clear incomplete frames and binding; retain durable intents/evidence. On reconnect, negotiate and reconcile afresh. Define incomplete-frame deadline and error/rate limits jointly, not from current three-second USB ACK timeout.

Required size proof: Android serialized content <= approved Uno RX content; Android framer capacity >= approved Uno TX content, plus agreed delimiter treatment. HW-02 targets 191 content bytes, not a proven implementation limit. 191 content + LF = 192 wire bytes; with optional CRLF = 193 wire bytes. A receiver storing stripped content needs 192 bytes for content+NUL (not content+CR+LF+NUL). Resolve whether CR is excluded from content and delay its processing to distinguish CRLF from embedded CR. Do not infer two safe Uno buffers from this arithmetic. Count complete maxima with all frozen widths/auth fields; never accept full 198/204-byte STATE/EVENT under the 191 target.

## 7. Decisions and acceptance evidence still required

- **Ally:** catalog input is now present; provide corrected exact split schemas/examples, maximum-width count script, source/build identity, RX/TX and memory/stack proof, EEPROM replay/cursor/transition semantics, clock/sample and full-journal STOP policy; approved Chicken profile/readiness.
- **Cha:** freeze cloud per-kind schema, content canonicalization (including transport/replay metadata exclusions), authenticated receipt validation/revisions/conflicts, device scope and ID mapping; provisioning/revocation; qualifying Uno event-release proof.
- **Kath + Ally:** select native/plugin transport, numeric deadlines and parser version policy against the same catalog. No BLE/GATT substitution for HC-05 Classic SPP.
- **Planned only:** fixtures for every frame; each chunk boundary; coalesced frames; exact maximum/maximum+1; suffix attack; malformed UTF-8/duplicate keys; wrong/unknown version; counter boundaries; replay/order/binding mismatch. Build/release and physical Android transport tests require separate approval and identified device/toolchain evidence.

## 8. Exact shared corrections proposed for Ally and Cha

These are requests to revise the **same catalog**, not adopted wire schemas. Recount after every accepted change.

1. **HELLO:** add mandatory qid echo and validate it against one outstanding request on current connection. Define authorization exchange with a challenge/session/key generation, algorithm/tag width, MAC canonical bytes and replay policy. Bind START/STOP to target dev, protocol/type, installation, command/batch, immutable fields and session/nonce context; absence of dev in command is safe only if cryptographically bound by agreed context. Bind returned controller evidence too, or explicitly state that source authenticity is limited. Unauthenticated auth:"authorized" and public IDs cannot grant authority. Read-only privacy/authorization policy also needs agreement.
2. **State split size:** one candidate using existing STATE/STATE_PROFILE families is to move start_s/tv out of STATE into STATE_PROFILE; add seq to STATE_PROFILE and omit its redundant bid. Join once on `(connection generation,qid,dev,ep,seq)`, inherit bid only from the matching core. With maximum uint32 ep/seq, STARTING, 10-character sample pv and 10-digit timestamp, resulting core is 166 content bytes, profile/time part 159. This is a bounded example, not maximum proof or approval; if profile/auth widths outgrow it, revisit the split together. Do not adopt the original 197-byte maximum-counter core.
3. **Snapshot semantics:** allow only one immutable snapshot per fresh qid. Core/profile/time values must be sampled together; duplicate same qid/same content is harmless, changed content is conflict. ep is current boot for STATE. seq denotes latest event watermark, not a unique observation counter: state can change STARTING→RECOVERY/FAULT while seq stays unchanged. Serialize STATUS, reject retired qids, and expire observations using an approved monotonic deadline/age policy. Freeze observation revision/age if unsolicited/concurrent state is wanted. `STATE.tv` originally describes start_s, not current observation time. Never use it as proof that phone current time is trustworthy.
4. **State null policy:** bid:null requires sp/pv/start_s:null and tv:false when no corresponding evidence exists. Retained STOPPED/FAULT/RECOVERY batch may keep non-null identity/profile/original Start. If batch exists but Start time is unknown, retain batch/profile and use start_s:null,tv:false. For IDLE/STARTING cases define exactly which batch is retained/admitted; do not clear matching evidence merely because not RUNNING. Historical start_s is original, unchanged on reconnect.
5. **Event identity:** seq must remain global per provisioned dev across boots if canonical identity is `(dev,seq)`. Define eid as `dev + '-' + seq in exactly 10 zero-padded decimal digits` for uint32 (sample currently uses eight); revise all literals/RCPT_ACK and cloud mapping together. If seq can restart, include a persistent identity epoch in the canonical key instead; do not silently switch scopes. EVENT.ep is the **original event's boot epoch**, including on replay; do not stamp replay with current epoch. TEL/STATE ep is their own source boot. Counter exhaustion/loss requires controlled reprovisioning, not reuse.
6. **Event time:** require EVENT_TIME even when invalid: ts:null,tv:false. Missing time part is incomplete, not invalid time. Parts must agree on dev/ep/seq; preserve original data/first receipt. Immutable `(dev,seq)` event identity with differing ep/body is conflict, not a second event. kind/cid policy: command started/stopped requires original cid; internal safety transition may use null only under an explicit approved kind/reason rule. Backend Start projection needs original qty/profile/species: resolve a retained batch snapshot/evidence retrieval path. Neither current STATE nor split EVENT carries original qty; lost phone/reinstall cannot safely reconstruct it from these frames alone.
7. **Durability versus occurrence:** feasibility §4 step4 says record may commit before initiating logical Start. A pre-transition record cannot be exposed/replayed as kind:started unless logical transition was committed under a defined atomic state model. Specify PREPARED/admitted versus transition-complete recovery phases (internal or jointly revised catalog). A power cut after intent journal but before transition must not produce a fictitious started event, timestamp or Running UI. Same rule for stopped; safety outputs must still respond when journal full. Define when ACK ACCEPTED is emitted and what happens if transition later fails.
8. **Replay:** choose exclusive after; reserve seq0 and start real events at1 (or explicitly support a before-first cursor). Freeze ordered snapshot/high-watermark, oldest-retained and gap indication **in this version**, returned count, empty first/last:null, and whether limit counts complete logical events (proposed yes, not split lines). REPLAY_END alone does not prove completeness. Prefer one replay request outstanding; EVENT parts remain immutable without request qid, which requires explicit no-interleaving policy or a correlated replay envelope chosen jointly. `more` continuation starts after highest **durably assembled, contiguous-under-approved-policy** event, not a lone received seq. No cursor advance on partial parts or unexplained gaps.
9. **ACK/error outcomes:** ACCEPTED only for ok:true; rejection enums only ok:false. ID_CONFLICT is not permission to generate a new Start identity or proof the original command was rejected/not executed. Replayed prior successful outcome after STOP does not imply Running. Specify which terminal rejections guarantee no transition for that exact immutable command; conflicts require reconciliation of the original outcome. ERROR with qid absent cannot correlate HELLO/STATUS/REPLAY errors: add a bounded query correlation variant or explicitly use query timeout without rejecting pending control commands. Don't invent cid for malformed input.
10. **Receipt:** fixed canonical eid and exact immutable-event content digest must be bound to server receipt identity/revision/disposition/controller scope/authentication. A command MAC key known to phone does not automatically prove a server committed; if phone is trusted to attest, state that narrower threat model. Need distinct server proof or approved attestation trust, stale-revision behavior, positive release result and repeat-safe handling. waiting_dependencies/conflict never release. No release scheme is approved by current RCPT_ACK.

## 9. Split-record assembly and incomplete-message recovery

See companion Offline Start document for local transactions. Byte-level partial lines are volatile and cleared on disconnect; validated logical parts can be durably staged, never treated as completed transitions.

- **STATE:** bounded pending snapshots keyed by fresh query and source connection. Cache out-of-order matching parts only within the query deadline. Exact duplicates are harmless; mismatched keys cannot combine; same key/different content quarantines the exchange. Retire qid on timeout/disconnect, request a new snapshot with new qid; do not mix old profile with a new core. A valid core may show provisional/last-checked operation without profile/time, but Ready/verified day/full confirmation stays blocked until required evidence is assembled. Query RTT/deadline is a recency bound only under the agreed response-snapshot rules, not continuous operation proof.
- **EVENT:** bounded/durable staging per `(dev,ep,seq)` with unique canonical `(dev,seq)`. CORE/TIME may arrive in either order or duplicate; verify entire immutable joined content before T3 event+outbox transaction. Partial rows cannot enter upload outbox, advance durable replay cursor or release Uno retention. On timeout/reconnect request retained events from last safe cursor with a new replay qid; original event keys/time do not change. Retained event from old ep may complete across connections only after verified same controller/global seq; current STATE may not be assembled across connections.
- **Conflict/overflow/storage full:** stop assembly for affected logical record, retain diagnostics/evidence under bounded policy, mark unresolved and seek read-only reconciliation. Do not fabricate absent parts, infer Start failure or send another Start. On app restart load staged partials for retained-event completion only after binding; stale STATE stays last-known and needs new STATUS.
- **TEL:** one complete acquisition frame required; no schema-defined split currently. Partial bytes are discarded on disconnect; no generated readings or backfill. `tv:false/ts:null` is unknown acquisition time, not fresh; `_ok:false` is invalid independently of age. Repeated `(dev,ep,n)`/same body is duplicate without refreshing acquisition age; changed body is conflict. Newer sample order uses approved non-reused epochs/counters, not arrival timestamps. No freshness threshold is finalized.

## References

- Shared input: v1.2 sections 2–7, especially A1–A4 and C1–C4.
- [Android Bluetooth permissions](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions).
- [Android RFCOMM connections](https://developer.android.com/develop/connectivity/bluetooth/connect-bluetooth-devices).
- [sqflite package metadata](https://pub.dev/api/packages/sqflite); latest retrieved 2.4.5 requires Dart ^3.12.0 / Flutter >=3.44.0.
- [SQLite atomic commit](https://www.sqlite.org/atomiccommit.html).
- Companion designs: [Offline Start and Recovery](UI-02_Offline_Start_And_Recovery.md), [Farmer UI](UI-02_Farmer_UI_State_Specification.md).
