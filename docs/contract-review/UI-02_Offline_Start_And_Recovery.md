# UI-CONTRACT-02 — Offline Start and Recovery

Owner: Kath — Flutter/UI/UX. Date: 2026-10-28.

**PROPOSED DESIGN / BLOCKED FOR IMPLEMENTATION AND COMPATIBILITY SIGN-OFF.** Follow-up now reviews supplied `SmartHatch_v1.2.md`, `HW-02_Exact_Wire_Message_Catalog.md`, `HW-02_Uno_Feasibility_And_Recovery.md` and `Open_Decisions.md`. Missing-input blocker cleared; exact split schemas/security/recovery still need changes. No replacement JSON protocol is defined here; corrections are joint-review requests in the existing Wire Review.

## 1. Evidence and scope

Architecture: Arduino Uno + RTC ↔ HC-05 Classic SPP ↔ Flutter Android ↔ Supabase. Arduino controls incubation autonomously. Phone absence is not Stop. ACK/cloud Active is not Running. Chicken/fresh eggs only for physical pilot; profiles and hardware readiness still require approval.

**SOURCE VERIFIED:** no Bluetooth bridge or SQLite ledger exists in inspected Flutter dependencies/source. `main.dart:16–31` gates app display on initialization/possible anonymous cloud sign-in. `:2734–2772` uses cloud-first Start. Current service completions are direct cloud writes, not physical Stop (`supabase_service.dart:232–244`). See [Wire Review](UI-02_Wire_Compatibility_Review.md) for dependency/source evidence, follow-up input hashes, independent counts and correction IDs.

**Not verified:** no new build/test/device/SQLite fault-injection/backend verification. This is a future implementation design, not a claim that offline Start works now.

## 2. Recommended Android transport and permissions

**PROPOSED:** narrow Kotlin RFCOMM client behind a byte-stream Flutter transport interface. Flutter owns protocol parsing/reconciliation; native code owns socket lifecycle and bounded I/O. Do not reuse USB port enumeration as Bluetooth discovery. No BLE/GATT plugin substitution.

- One active socket/serialized writer; cancellable connect/read off UI thread; close socket to cancel blocking connection; forward byte chunks without treating reads as messages. Handle partial writes/write exceptions conservatively as possible dispatch.
- Negotiate the actual HC-05 SPP service/UUID with Ally. Do not hard-code a guessed channel or silently downgrade security. Pairing and controller identity/command authorization are separate checks.
- On activity/background/process interruption, assume connection may end; persist evidence, then reconcile on foreground/reconnect. Foreground-only is baseline; no background service, continuous collection or upload guarantee.
- A plugin remains possible only after source/maintenance/API/lifecycle review and authorized release-build/device tests. No Bluetooth package is selected/installed by this task.

| Android case | Proposed minimum permission behavior |
|---|---|
| API 31+ paired-device communication | Declare/request runtime BLUETOOTH_CONNECT; handle denial/revocation without Start |
| API 31+ discovery, if used | Also BLUETOOTH_SCAN runtime; neverForLocation only if truthful; inspect cancelDiscovery permission requirements too |
| API <=30 | Legacy BLUETOOTH; BLUETOOTH_ADMIN for discovery/manipulation, with maxSdkVersion 30; pre-31 discovery requires applicable runtime location permission |
| Phone advertising | Not required for client-only design; do not request BLUETOOTH_ADVERTISE without actual need |
| Internet sync | INTERNET must exist in merged release manifest; no background/location permission added merely for offline Start |
| Unsupported/no Bluetooth or denied permission | Local History/recovery remains available; physical commands disabled |

Prefer system-prepaired designated device for pilot to reduce farmer discovery steps; identity verification remains mandatory. Permission checks must cover every invoked API, not just socket creation. Supported min/target SDK numbers and intended phone Android versions remain UNKNOWN pending resolved build/device evidence. Project declares AGP 9.1.0/Kotlin 2.4.0/JVM17 and Flutter-delegated SDK levels; declarations are not build compatibility proof.

## 3. Durable local store and identity design

**PROPOSED:** SQLite through a reviewed sqflite version. Current latest metadata is 2.4.5, Dart ^3.12.0 / Flutter >=3.44.0. Cached tool metadata is newer, but project advertises Dart >=3.11.0. Before adoption, either approve raising supported floors or select/test a compatible older version; no version is installed or solver-tested here. Shared preferences is not the command/event/outbox transaction store. Secrets need a separately reviewed Android Keystore-backed credential design, not plaintext ledger fields.

Proposed logical records (internal model names, NOT new shared wire/API keys):

| Record | Required properties / constraints |
|---|---|
| Provisioning binding | Installation/controller IDs, provisioning generation, capability/profile references, authorization policy reference; credential handle only |
| Batch | Stable offline ID, original quantity/species, immutable approved profile snapshot/reference, original Start evidence/time validity, lifecycle projection, nullable cloud mapping |
| Command intent | Immutable command ID/type/controller/batch/content, canonical content fingerprint, dispatch-may-occur marker, reconciled outcome; uniqueness within approved scope |
| Source evidence/event | Original complete frame(s), verified binding, immutable source identity/content, original source time/validity, first phone receipt; unique source key; conflicting content quarantined |
| Outbox | References immutable cloud submission/event ID; pending/waiting/blocked/applied, attempt metadata and eligible retry time; no executable hardware command |
| Receipt | Exact subject IDs/content association, receipt ID/revision/time/disposition/session mapping; transactionally associated with outbox |
| Readings | Source device/batch/sample/epoch, values+validity, acquisition age/time validity, receipt provenance; retention policy separate from critical events |
| Partial logical evidence | Validated EVENT_CORE/TIME parts and source identity, immutable part body, first receipt and completeness flags; unique logical part, bounded storage, no outbox until complete |
| Replay progress | Per-controller safe completed cursor, snapshot boundary and explicit gap/recovery status; commit progress only with complete verified records |

Use foreign keys/uniqueness, transactional schema migrations, serialized writers and crash-recoverable journal/synchronization settings. Candidate baseline: rollback journal with synchronous FULL; confirm actual driver settings/storage assumptions and fault-injection behavior before claiming power-loss durability. No memory-only journal or disabled synchronization for critical records. Choose telemetry pruning/storage budgets separately; never silently evict unsynced critical evidence. Full/corrupt disk blocks new commands, preserves what can be read, and enters support/recovery. Do not silently delete/recreate the ledger.

## 4. Full offline Start sequence

1. **Open offline:** show local initialization/recovery UI; open/migrate/check ledger and recover unresolved intents before enabling commands. Online login/refresh/sync runs independently, never blocks recovery display. First-ever unprovisioned install cannot Start offline.
2. **Check authority:** load valid provisioned binding and apply jointly approved offline policy. No valid policy/credential = setup/help, not a farmer registration screen or automatic anonymous provisioning.
3. **Connect correct controller:** request applicable Nearby Devices permission, open SPP, verify expected controller identity/version/capabilities and command authorization. Reject wrong device; do not auto-adopt it.
4. **Read-only reconcile:** new STATUS/query identity; obtain current state plus retained batch/outcomes. Resolve previous uncertain commands first. A controller already running another batch blocks Start even if cloud is empty. Cloud Active conflicts require reconciliation, not hardware reset.
5. **Prepare:** preserve species cards/navigation, but physical pilot permits only approved Chicken/fresh eggs. Load immutable approved profile; confirm supported version and valid quantity. Current source 6..12 is pending shared capacity ratification. Missing profile/clock/safety gate blocks Start, not silent defaults. Display readiness from controller, not phone sensor guesses.
6. **Deliberate farmer action:** single Start action with reentrancy gate. Generate stable offline batch and command IDs per approved catalog; freeze content. Disable concurrent lifecycle actions for that controller. SQLite transaction T1 saves batch+intent. Failure = do not transmit.
7. **Dispatch boundary:** transaction T2 commits dispatch-may-occur before writing. Only after successful commit and still-valid binding/readiness/auth, send the approved Start frame once. No transport-level automatic resend of an actuator command. A timeout/write error after this boundary is uncertain, even if zero actual delivery is possible.
8. **Confirm separately:** ACK acceptance only advances request processing. Await valid durable Start transition evidence and a matching current-state observation. They may arrive in either order; lost ACK does not invalidate sufficient evidence. A retained Start followed by newer Stop means started then stopped, not currently Running.
9. **Commit confirmation:** T3 atomically stores immutable event evidence, reconciled intent, batch projection and upload-outbox entry. Historical events may be committed even before current state is known; do not fabricate an unknown projection. The UI can report received Running evidence with storage warning before T3, but cannot claim Saved on phone.
10. **Later upload:** when foreground/online/cloud-authorized, submit same immutable event. Do not execute Start to repair a cloud error. T4 validates/stores committed receipt and updates mapping/outbox atomically. No Synced label until appropriate applied disposition for exact event; all required events must apply for batch-level Synced.

## 5. Crash and failure matrix

| Boundary / failure | What can be trusted | Required recovery; forbidden action |
|---|---|---|
| T1 fails | No durable intent, no dispatch authorized | Explain storage problem; no send |
| T1 committed, T2 never committed | Prepared intent; write was forbidden by ordering | Do not auto-send on app startup. Check controller; resume only through explicit reviewed action |
| T2 commit throws/ambiguous | Marker may exist; current process must not write | Read/recover local transaction; conservatively reconcile if unresolved |
| After T2, before/during/after write, app dies | Command may have reached Uno | Read-only STATUS/retained evidence using same existing identities; never auto-send Start |
| Bluetooth drops or ACK times out | Delivery/transition unknown unless valid evidence exists | Show outcome unknown, reconnect/bind/reconcile; timeout is not rejection |
| ACK accepted, event lost | Accepted request, not proven Start | Query retained outcome/current state; no new Start |
| Start event received, state missing | Historical Start known | Save event; current operation unknown/last-known until fresh correlated STATUS |
| Current Running observed, required durable event absent | Current controller report, incomplete Start history | Show report separately; seek retained evidence. Do not invent Start event/time or mark full Start record complete |
| Valid Running+event received, T3 fails | Running report exists in live memory, not proven phone persistence | Show record-not-saved warning; retry local save/retrieve retained evidence; never Start again |
| T3 succeeds, process dies before upload | Durable event+outbox | Recover upload queue; no hardware replay |
| Server commits, reply lost | Server result uncertain locally | Reconcile/retry same event identity/content |
| Receipt received, T4 fails | Receipt in memory only; server may have committed | Keep queue; same-event retry returns same receipt; do not duplicate event |
| Controller restarts / journal corrupt or gaps | Only surviving verified evidence | Rebind and obtain RECOVERY/current status; no inferred new IDLE/new batch. Explicit support if evidence insufficient |
| Wrong controller/profile/batch or unsupported version | Binding/capability mismatch | Quarantine evidence, disable automatic reassociation and Start |
| Storage becomes full/corrupt | Existing readable evidence only | No new Start; recovery screen, no silent purge/reset; distinguish current controller report from local storage problem |
| Phone reinstalled / data cleared | Old ledger/credential may be gone | Treat as unprovisioned; controlled provisioning, identify controller, retrieve surviving cloud/controller evidence; no guaranteed recovery without survivors |
| Restored backup | May contain old binding/commands/outbox | Verify credential generation and source/cloud identities before authority; never replay backed-up Start |
| Controller lost its persistent identity/counters | Prior identity cannot be safely assumed | Controlled reprovisioning with new epoch/identity as approved; no counter reuse |

**Retention boundary:** local receipt alone does not survive uninstall. Preferred candidate is bounded Uno event retention until verifiable qualifying server receipt. Server/Uno capacity, authentication and exhaustion policy are BLOCKED. If not feasible, jointly document which offline events may be lost. Android database transactions cannot make two devices atomically commit, protect against uninstall, or guarantee surviving evidence on Uno.

## 6. Read-only reconciliation algorithm

On reconnect/resume: new connection generation → bind identity/version/auth → new STATUS query ID → validate current observation and retrieve retained original command result/events → order/deduplicate by approved source identities → transactionally reconcile local history/outbox → update current-state projection only from current/newer observations. Replayed historical frames retain original occurrence time and do not refresh live state.

Handle no-match/missing result as unresolved, not proof that nothing started. Require explicit source proof/approved recovery procedure before offering a new batch. Distinguish STOP outcome uncertainty from Start uncertainty using the same conservative rules; farmer completion is an independent app-origin event.

Query timeout/poll cadence/retry/backoff and replay end/gap semantics remain BLOCKED by omissions in the now supplied HW-CONTRACT-02. Retrying a read-only query with a new query identity must not change the original Start identity. No generic pending-command queue is permitted to resend Start after reconnect.

### HW-02 split evidence and local transaction refinement

The original full STATE/EVENT exceed the provisional 191-byte cap. Even its suggested STATE core reaches 197 content bytes at the declared counter widths. Do not implement that split until corrected schemas/counts are approved (Wire Review §8 correction2).

- A pending STATUS has one fresh qid, expected bound dev/current ep and a monotonic deadline. Core/detail must represent the same frozen snapshot. Deduplicate identical parts; reject conflicting/mismatched parts. Clear pending STATE assembly on disconnect/deadline and query afresh. Show core operation provisionally without profile/Start time if necessary, never Ready/day based on incomplete detail.
- Retained EVENT_CORE and EVENT_TIME join on original `(dev,ep,seq)`. Stage each validated part durably in an idempotent partial-record transaction. CORE without TIME is incomplete, even when clock invalidity is expected. An explicit TIME with ts:null,tv:false completes a time-unknown event only under the agreed null policy.
- On receiving final part, **one transaction** inserts/validates immutable complete event, marks intent outcome, updates justified batch projection, inserts immutable outbox submission, marks assembly complete and advances replay progress only if verified continuity allows it. A failure leaves either staged parts or the completed transaction, never a cursor beyond missing evidence.
- Same canonical event `(dev,seq)` with changed ep/content is conflict if seq is global. Source epoch on replay stays original. Retained parts may complete across reconnections only after authenticated source rebinding; old STATE parts cannot. Duplicate delivery after crash is safe; neither a new event ID nor a new Start is generated.
- Limit/outstanding-query/buffer/storage budgets must be bounded. A lost part triggers a new read-only REPLAY from last safe cursor, not a new Start. REPLAY_END/more/first/last currently cannot prove contiguous retention; exact gap/empty/high-watermark rules must be added before cursor logic is implementable.
- Current STATE does not contain original cid or qty; EVENT carries cid but no original qty/profile snapshot. Preserve original local intent when present; after reinstall obtain approved retained batch metadata or cloud evidence. No automatic reconstruction of original quantity/profile from defaults or the newest STATE. The catalog currently lacks a complete recovery path for these data.

### Offline Stop confirmation

1. Verify authorized binding and current matching bid; deliberate farmer Stop creates a **new** immutable cid and STOP intent, saved before dispatch with the same T1/T2 ordering. Do not reuse the Start cid or write completion count.
2. Send the approved STOP once; ACK ok:true/ACCEPTED means admitted only. Await joined stopped EVENT with matching original STOP cid/bid and a fresh STATUS/STATE observation of corresponding current operation. A safety-triggered internal stop with cid:null is separate evidence, not a falsely correlated farmer command outcome.
3. Persist stopped event/outbox/intent projection atomically. If current stopped state exists without event, report controller state but flag missing Stop history; if event exists without current state, record historical Stop but seek fresh state. No ACK-as-Stopped.
4. Disconnect/lost reply/crash follows read-only STATUS/REPLAY; show Stop outcome unknown, never silently send another lifecycle command. A repeated cid/same content must return prior outcome after reboot even when no batch remains active; define already-stopped versus NO_MATCHING_BATCH precedence.
5. A full/corrupt phone store must not silently enable unlogged Stop or claim it was sent. Show dedicated support/safety guidance under an approved policy. Ally must ensure local emergency/safety shutdown remains possible independently of app/storage/auth/network. The packet requires Stop possible with full Uno journal but does not define outcome/evidence when durable event cannot be written: **BLOCKED**, not permission to suppress safe shutdown or fabricate a durable event.
6. Stop is not farmer completion, does not prove physical outputs de-energized, and does not automatically free a conflicting historical cloud Active record. Safety-output/FAULT/RECOVERY behavior needs Ally's explicit definition.

### Journal commit versus actual Start boundary

HW feasibility §4 writes retained identity/event before initiating logical Start. Team must distinguish an admitted/prepared durable intent from a committed occurred transition. If power fails between them, recovering a prepared record must not emit an unearned started EVENT or report Running. Resolve the firmware phase model before Flutter treats recovered events as occurred facts. Do not fix this ambiguity by automatic resume/Start on boot. Same distinction applies to Stop; physical safe outputs and durable evidence are different guarantees.

## 7. Cloud upload and receipts

v1.2 proposes, but does not deploy, `POST /functions/v1/bridge-sync`, operations submit_event/submit_reading/get_reconciliation and api_version 1. Do not implement from this outline without Cha's exact kind-specific schemas.

- Freeze original evidence and immutable event content before retries; retry metadata is separate. First phone receipt must not change on every attempt. Cha must specify which replay/transport fields are excluded from canonical content so equivalent retained evidence does not falsely conflict.
- Validate authenticated transport and response schema, api_version, matching event/device/batch, receipt identity/revision, disposition and session decimal-string mapping. IDs alone are insufficient for changed-content conflicts: require server canonical-content confirmation/fingerprint or equivalent reconciliation proof for the submitted content.
- Record receipt revisions monotonically; stale/reordered receipts cannot undo newer applied/conflict handling. Exact admissible transitions require Cha approval.
- applied = exact event Synced; waiting_dependencies = persisted/processing, not Synced; conflict = preserve evidence and support; 401/403 = upload blocked, not loss of locally saved event. Distinguish unpersisted errors from committed receipts even on HTTP 409. 503/timeout = uncertain, same-event retry/reconcile.
- Proposed retry: bounded exponential backoff with jitter for network/temporary failures, foreground only. No hot loops. Pause permanent validation/security/conflict failures for authorized resolution; numeric retry budget remains to be agreed. No hardware command on cloud timeout.
- A receipt sent back to Uno must satisfy Ally/Cha's separately approved cryptographic/provenance and retention rules. HTTPS confirmation on phone alone is not proof Uno can verify it. Do not erase controller evidence yet.
- No service-role credentials in app/assets/logs. Existing anonymous/direct-write behavior needs backend review before secure deployment. No database objects or policies are changed here.

## 8. Source time, elapsed day and measurements

Preserve original Start, event occurrence, acquisition, first phone receipt and server receipt as separate values with validity/provenance. Wire epoch units/ranges and cloud UTC RFC3339 semantics must agree; never infer from digit count. Timestamp without timezone legacy fields require explicit UTC projection, not implicit local parsing.

Only for trustworthy Start and current elapsed reference: `day = floor(elapsed_seconds / 86400) + 1`. At 0/86399 seconds Day 1; at 86400 Day 2 (arithmetic examples, not device tests). Negative elapsed is a clock error. No Day 1 from ACK/cloud now/reconnect or date-only History text; no silent cap of true day at profile duration. A progress bar may clamp separately. Verified monotonic anchoring can advance within one valid process interval; after reboot/restart re-establish time evidence. RTC drift/time corrections/outage counting remain Ally/team decisions.

Per-channel values and validity remain separate from age: invalid → unavailable; valid but unknown acquisition age → unknown age; known acquisition age above approved threshold → stale; valid known age within threshold → fresh. Arrival alone is not acquisition time; duplicates never refresh age. If elapsed transit is not bounded, current source age may remain unknown even with a recent packet. Counter/epoch/time agreement and measured cadence must precede numerical freshness threshold.

Actual temperature/humidity tiles use actual validated measurements only. Missing/invalid/stale live value does not become target temperature/humidity. Show retained values only as explicit last readings with age. Settings/profile targets have separate labels and cannot prove applied actuator behavior or normal conditions.

HW-02 TEL fields are tc/rh plus Boolean t_ok/rh_ok; preserve mappings tc→current_temperature and rh→current_humidity. False validity requires null, true requires finite approved number. tv describes acquisition ts, not a fresh-connection flag. Proposed rule tv:false iff ts:null; no missing/guessed ts. Duplicate `(dev,ep,n)` with same payload cannot reset age; changed payload is a source conflict. Original acquisition stays attached to original bid even if uploaded after a new batch. Source/phone clock agreement and approved skew/transit bound are necessary to derive current age from UTC; tv:true alone does not prove phone clock accuracy. If unknown, show unknown age; keep live connection heartbeat separate. STATE start_s is original Start, not current clock; day after reboot still needs trusted current elapsed reference, which the catalog has not fully specified.

## 9. Acceptance gates and open decisions

| Owner | Required before compatibility/design freeze |
|---|---|
| Ally | Correct HW-02 sample dev, HELLO qid, split STATE/EVENT schemas/maxima and observation/replay semantics; firmware source/build/memory, transition phase/full-journal Stop outcomes, original batch metadata recovery, RTC/sample bounds and Chicken profile approval |
| Cha | Exact auth provisioning/revocation, cloud schemas/canonical comparison/receipts, session mapping, dependency/conflict handling, controller receipt-release proof |
| All | Offline authority mechanism and limitations, accepted data-loss boundary, supported versions, quantity/profile/clock policy, same exact protocol revision approval |
| Kath after authorization | Solver/build/release checks, duplicate-aware parser tests, permissions and lifecycle device spike, SQLite fault/crash tests, state-machine/UI tests |

Planned tests include every crash boundary above, malformed/oversized frames, wrong IDs, stale/replayed events, receipt loss/reordering, full/corrupt storage, app kill/reinstall, Android permission revocation and no-internet cold start. These tests have NOT been run. No powered-load or egg tests without separate documented electrical clearance.

References: [Android permissions](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions), [RFCOMM](https://developer.android.com/develop/connectivity/bluetooth/connect-bluetooth-devices), [SQLite atomic commit](https://www.sqlite.org/atomiccommit.html), [sqflite metadata](https://pub.dev/api/packages/sqflite), v1.2 B1/C1–C4/section 6. See [Farmer UI](UI-02_Farmer_UI_State_Specification.md).
