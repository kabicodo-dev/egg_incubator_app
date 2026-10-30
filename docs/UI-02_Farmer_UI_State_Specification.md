# UI-CONTRACT-02 — Farmer UI State Specification

Owner: Kath — Flutter/UI/UX. Date: 2026-10-28.

**PROPOSED / NOT IMPLEMENTED / NOT JOINTLY APPROVED.** Follow-up reviews supplied v1.2 plus all three HW-02 documents. The earlier missing-input blocker is cleared; schema/split/authorization/receipt/feasibility blockers remain. This specifies presentation and local behavior, not a separate wire protocol.

## 1. Independent state dimensions

Never collapse these into one green Ready/Active badge:

1. **Connection:** unavailable / permission needed / disconnected / connecting / connected.
2. **Authority and eligibility:** checking / not provisioned / unauthorized / wrong controller / unsupported version / not ready / ready.
3. **Controller operation:** unknown / last-known / reports IDLE, STARTING, RUNNING, STOPPED, FAULT or RECOVERY under the final agreed enum. These labels do not prove physical relay/load response.
4. **Command outcome:** prepared / dispatch possible / accepted / rejected / unknown / reconciled.
5. **Phone record:** saving / saved / save failed / recovery required.
6. **Cloud record:** offline / waiting / uploading / processing dependencies / applied / blocked / conflict.
7. **Each reading:** valid or invalid, plus fresh/stale/unknown acquisition age. Preserve source/receipt provenance separately.
8. **Time confidence:** verified elapsed reference / needs checking / unavailable.

Cloud Active is historical session lifecycle, never evidence of current Running. Cloud failure does not mean controller stopped; connection success does not mean authorized or safe.

## 2. Proposed screens and navigation

- **Local loading/recovery:** starts without internet; load records and check provisioning. Offer readable storage/setup error and support, not an empty spinner awaiting cloud auth.
- **Home / Current incubation:** operation and last confirmation, separate connection/phone/cloud badges, actual reading tiles and explicitly labelled targets, day/time confidence and read-only reconnect/check action.
- **Connect incubator:** system permission explanation, connect to designated paired controller, identity/compatibility/authorization checks. No farmer-facing raw UUID/MAC/JSON as verification substitute.
- **Species details and setup:** preserve Chicken/Duck/Quail cards, artwork, View/Hide Details, Continue and selected-species navigation. Chicken alone is eligible for the physical pilot after approved profile/readiness; other cards remain informational/software options, not physical approval. Fresh eggs only; transfer option remains disabled.
- **Pre-Start review:** approved Chicken profile label/version display in human terms, original quantity, fresh-egg checklist and explicit Start. No mutable guessed setpoints. No Start on Continue/species selection.
- **Start confirmation/recovery:** show waiting, unknown or storage-failed distinctions. Leaving the screen is not cancelling an already dispatched hardware operation.
- **History/details:** merge durable local records and authorized cloud mappings by stable batch identity, preserve search/filters and manual completion. Distinguish source-confirmed, unconfirmed intent and legacy cloud-only history. Preserve original Start instant internally; dates are formatting only.
- **Manual completion:** farmer-entered hatch count `0..original_quantity`, explicit confirmation, immutable app-origin event and offline save/sync indicator. Completion does not transmit physical Stop. A separate deliberate Stop action must use approved controller authorization/confirmation; no automatic Stop from completion or duration.

## 3. Farmer wording and action table

| State / screen | Evidence gate | Exact proposed text | Actions / prohibitions |
|---|---|---|---|
| Not connected | No active bound link | “Incubator not connected.” / “Connect to check its latest status.” | Connect; view local History. Start disabled. Do not show Stopped. |
| Connected, checking | Socket exists, handshake incomplete | “Connected. Checking the incubator…” | No Start until identity/capabilities/authorization/readiness verified. |
| Connected but not authorized | Connection bound but command authority absent/denied | “Connected, but this phone is not authorized to control this incubator.” / “Contact the SmartHatch team.” | Help; authorized read-only access only if policy permits. No command bypass or complex farmer login. |
| Wrong controller | Reported identity differs from provisioned one | “This is not the assigned incubator.” | Disconnect/reconnect to correct unit; no automatic reassociation. |
| Unsupported version | Protocol/capabilities incompatible | “This incubator needs a SmartHatch update before this phone can control it.” | Help; local History. No guessed legacy fallback. |
| Ready to Start | Authorized bound compatible controller; current eligible state, approved profile/quantity/clock/safety gates; healthy local store; no uncertain command | “Ready to start Chicken incubation.” / “Starting works without internet. Records will sync later.” | Deliberate Start once. Ready does not mean incubation already began. |
| Starting / awaiting confirmation | Intent/dispatch persisted; command sent or may be sent | “Waiting for the incubator to confirm Start…” | Start disabled; no automatic resend. No Started animation based on ACK. Numeric timeout remains jointly TBD. |
| ACK accepted only | Correlated acceptance, no sufficient transition/current evidence | “Start request accepted. Waiting for confirmation…” | Continue observing/reconcile after deadline; not Running. |
| Split STATE detail missing | Valid current core, profile/original Start detail incomplete | “The incubator reports [state]. Some batch details are still being checked.” | Fresh read-only check. No Ready/day/approved-profile claim from absent detail; no mixing snapshots. |
| Split EVENT incomplete | Only matching CORE or TIME received | “The batch record is still being recovered.” | Keep separately reported current operation; retrieve retained evidence. No complete-event upload or Start retry. |
| Historical started event only | Complete retained original started event, no fresh STATE | “A Start record was recovered. Reconnect to check the incubator's current status.” | Do not present historical Started as current Running. |
| Optional START_PREP accepted | Only if two-step exchange is jointly adopted | “Start details checked. Waiting for the incubator to confirm Start…” | No Running claim; no PREP actuator action. Commit token/dispatch semantics still BLOCKED. |
| Stop awaiting confirmation | Durable STOP intent/dispatch, ACK absent or accepted | “Waiting for the incubator to confirm Stop…” | No Stopped claim from ACK; leaving screen is not cancelling Stop. |
| Stop outcome unknown | STOP may have been sent, matching outcome incomplete | “We couldn't confirm whether incubation stopped. Reconnect and check the incubator.” | Read-only reconciliation; no automatic Stop/Start or manual completion. |
| Controller reports STOPPED | Fresh matching current observation | “The incubator reports stopped.” | If stopped event missing add “The Stop record is still being recovered.” Does not prove loads off or record farmer hatch count. |
| Replay gap / missing original batch data | Retention loss, unresolved original quantity/profile or missing event part | “Some batch records could not be recovered. Contact the SmartHatch team.” | Preserve surviving evidence and operation report; do not invent profile/quantity/times, reset source or start a replacement. |
| Incubator reports Running | Valid correlated current Running observation; Start history completeness separately represented | “The incubator reports running.” / “Last checked [time].” | Show reading/phone/cloud status independently. If durable Start evidence missing, add “Start record is still being recovered.” No hardware-verified claim. |
| Start outcome unknown | Dispatch possible, no conclusive matching outcome | “We couldn't confirm whether incubation started.” / “Reconnect and check the incubator.” | “Reconnect and check”; Help. No Start again / “Start failed” / replacement batch. |
| Running confirmed, phone record not saved | Valid Running evidence received, local commit failed | “The incubator reports running, but this phone couldn't save the batch record.” / “Keep the phone nearby and contact the SmartHatch team.” | “Try saving again” means local persistence only; read-only reconciliation/Help. No Start retry. |
| Disconnected with prior state | Earlier observation only | “Phone disconnected. Last confirmed running at [known time].” | Reconnect; no current/live assertion. Use actual last state, not always Running. If clock untrusted use “Last connection: the incubator reported running.” |
| Saved offline / waiting | Durable confirmed event and outbox; no applied receipt | “Saved on this phone. Waiting to sync.” | Upload later in foreground. Never claim cloud save. No background guarantee. |
| Uploading | Authorized upload in progress | “Syncing saved records…” | No claim of success until receipt validation. Losing internet leaves local record intact. |
| Server persisted, dependencies pending | Matching committed waiting_dependencies receipt | “Saved to server. Processing pending.” | Check again later; not whole-batch Synced. |
| Synced | Exact validated applied receipt; all required events applied for batch badge | “Synced.” | Means records saved/applied to server, never proof of physical operation. |
| Synchronization conflict | Committed conflict or rejected identity/content conflict | “This batch needs help syncing.” / “Contact the SmartHatch team.” | Preserve evidence; Help. No silent overwrite/reset or new Start. State whether phone saved the record independently. |
| Upload not authorized | Server refuses upload | “Saved on this phone. Sync needs team assistance.” | Help; retain outbox. Online refusal does not prove current offline controller authority was revoked. |
| Sensor fault / invalid channel | Channel invalid or controller sensor fault | “Temperature unavailable” / “Humidity unavailable”; fault banner “The incubator reports a sensor problem.” | Valid other channel may remain visible with own age. Approved safety guidance/Help; no target fallback or green Normal. |
| Stale reading | Valid historical value, acquisition age exceeds approved threshold | “Last temperature reading: [value]. Not current.” | Show known acquisition time/age; reconnect/check. Do not label receipt time as measured time. |
| Unknown reading age | Valid metric, acquisition age not substantiated | “[value] — reading time unavailable.” | No Fresh/Live label; targets shown separately. |
| Incubation day unavailable | Missing/untrustworthy original Start or elapsed reference | “Incubation day unavailable—time needs checking.” | Help/reconcile; no fake Day 1 from app open or cloud row. |
| Controller FAULT / RECOVERY | Matching current fault/recovery observation | “The incubator needs attention.” / “Checking recovery status.” | Approved fault-specific guidance; read-only check/Help. No automatic reset/resume/Start. |
| Initial local save failed | No intent committed and no dispatch permitted | “This phone couldn't save the Start request. Incubation was not requested.” | Retry storage only after confirming no dispatch occurred. Never reuse this wording for ambiguous post-dispatch failures. |
| Reinstalled / unprovisioned | No verified surviving installation binding | “This phone needs SmartHatch setup before it can control the incubator.” | Team-assisted setup and read-only recovery when authorized. Never assume no batch exists. |

## 4. Precedence, concurrency and recovery actions

- Show controller fault and record-save failure prominently; do not hide either under Synced. Connection/cloud/reading indicators remain independently visible.
- A Running observation with failed local save is still known controller evidence while process memory survives. After process death without persisted evidence, recover to uncertainty from surviving intent, not an invented remembered confirmation.
- New STATUS result may show stopped after a historical started event. Display current stopped/last-known state, retain both history facts. Older replay cannot regress a newer projection.
- Stop and Start are single deliberate operations, serialized for the controller. Unknown outcome blocks a replacement Start; cloud failure does not trigger physical Stop.
- Navigation away, Android back, double tap, reconnect and app resume must not send Start implicitly. “Reconnect and check” sends only agreed read-only queries; “Try saving again” retries only local commit; “Sync now” retries only cloud submissions.
- Do not offer an erase-record/reset-device fix to farmers. Support may need original evidence; no automatic destructive recovery.
- Read-only History remains available offline where storage is readable. Show unconfirmed intent as “Start confirmation needed,” not as a Running batch or completed incubation.
- Partial STATE may inform a clearly provisional current-operation tile, but cannot complete profile/day/readiness. Partial EVENT is not complete transition history even if ts is expected unknown; explicit matched null/false TIME is required under the proposed correction. Do not let REPLAY_END or more:false erase missing-part/gap warnings.
- A retained event with original old ep may be valid historical evidence after reboot; it cannot supply current-state freshness. Clear STATE assembly on disconnect, bind new query, then reconcile events separately. A changed response under one snapshot key is a support conflict, not “latest wins.”
- CH-PENDING, placeholder MAC tags and HELLO auth:"authorized" without verified authorization never enable Start. No raw alias or authentication tag is shown to farmers. If alias-to-controller/installation mapping fails, use setup/help state, not automatic new identity.

## 5. Time, actual values and accessible presentation

- Preserve full UTC Start and validity internally. Calculate Day N only from trusted elapsed evidence: floor(seconds/86400)+1. Date-only display strings must never feed the calculation. Clock regressions/outage policy remain unresolved; no guessed day.
- Last-checked time is phone observation receipt with correct label; measured time is source acquisition. If phone clock is untrusted, do not present its absolute time as reliable evidence.
- Label actual tiles “Measured temperature” / “Measured humidity”; show unavailable state as text/dash. Targets have distinct “Target” labels and approved profile provenance. No zero, simulation or target substitution.
- A single valid channel cannot certify both channels “Normal.” Separate fault/validity/freshness indicators; controller Running does not certify sensor health.
- Preserve white/orange branding, species artwork, History/search/filter/details and manual counts. Use readable text, minimum proposed 48 logical-pixel primary touch targets, text scaling, semantic labels, focus order and live-region announcements for important transitions.
- Never rely on orange/green/red alone; pair icon with plain-language label. No raw JSON, UUIDs, EEPROM, stack traces, service-role keys or Supabase terminology in farmer messages. Support diagnostics must redact secrets.
- Errors should explain next safe action; do not imply “retry” sends Start. Screen readers must announce waiting/unknown/save-failed states without repeated noisy polling announcements.

## 6. Evidence, blockers and planned verification

**SOURCE VERIFIED:** existing Started navigation follows cloud writes (`lib/main.dart:2734–2772`); history strips Start time (`:175–193`); actual-value fallbacks use targets (`:4664–4672,4713–4717`); telemetry freshness uses receipt time (`lib/controllers/arduino_controller.dart:34–35,71–78`). These are gaps, not modified behavior.

**BLOCKED — Ally:** corrected exact split schemas/count bounds, snapshot/replay/gap/phase and full-journal Stop semantics, original batch quantity/profile recovery, age/time evidence, readiness/profile approval, source/build/memory verification. **BLOCKED — Cha:** alias-to-UUID mapping, event canonical identity/content, authorization provisioning, exact applied/dependency/conflict receipts and verifiable release. **UNKNOWN:** approved numerical freshness/timeout/skew thresholds, full reinstall recovery and real Android compatibility. See Wire Review §3/§8 for message-by-message dispositions and exact correction requests.

Planned only: widget/state tests at narrow widths and large text, screen-reader checks, no-internet cold start, double tap/back navigation, ACK-only, event-before-ACK, historical Start then newer Stop, invalid/stale/unknown-age per-channel readings, save failure/crash/reinstall, wrong controller/version/auth, duplicate/out-of-order cloud receipts and manual completion without physical Stop. Add split parts in both orders, missing/conflicting parts, core-only Running, retired qid, replay partial/gap/end, old-epoch event, Stop unknown and placeholder auth/profile. Host-side JSON/count calculations were performed in follow-up; no new application/device tests or physical verification were performed.

Completion of these design documents does not approve contract v1.2, K06 v0.5, the portal, implementation, hardware loads or incubation trials. See [Wire Review](UI-02_Wire_Compatibility_Review.md) and [Offline Recovery](UI-02_Offline_Start_And_Recovery.md).
