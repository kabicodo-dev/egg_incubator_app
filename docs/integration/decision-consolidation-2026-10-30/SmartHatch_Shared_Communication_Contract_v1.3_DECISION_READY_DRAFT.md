# SmartHatch — Shared Communication Contract v1.3
## DECISION-READY IMPLEMENTATION CANDIDATE · NOT YET JOINTLY APPROVED

**Prepared:** 28 October 2026  
**Target:** focused design freeze and evidence-based October 30 prototype/demo  
**Contract editor:** ChatGPT, consolidating the supplied project documents; **technical signatories:** Ally (firmware), Kath (Flutter/Android), Mary (backend/security), Cha (integration coordinator).  
**Status:** `DRAFT / SIX DECISIONS TO RATIFY / NO IMPLEMENTATION AUTHORIZATION FOR UNRESOLVED WIRE, AUTH OR HARDWARE-SAFETY CLAUSES`.

> **READ FIRST:** This document is a proposed consolidation, **not a claim that four people agreed**, not a verified firmware build, and not proof of working hardware, secure cloud access or hatchability. It preserves existing team decisions and turns unresolved issues into a short decision sheet. Do **not** treat example JSON or an unchecked box as a live controller instruction. One review of the *same revision* is required before implementing the corresponding wire contract.

## 0. Document hierarchy — no more competing contracts

1. **K06 v0.5 (27 Oct):** source of previously reported product/architecture decisions (HC-05/Android bridge, autonomous Uno, offline Start, Chicken-first fresh eggs, farmer-entered hatch count, cloud limitations). Retain as historical planning baseline.
2. **Shared communication v1.2 (27 Oct):** original cross-component *candidate*, not approved; carries J-01 through J-12 safety/data-integrity invariants.
3. **UI-CONTRACT-03 and INTEGRATION-CONTRACT-03 (28 Oct):** latest compatibility findings and six decision outputs; both say CHANGES REQUESTED.
4. **Earlier HW-CONTRACT-02 wire catalog** (`HW-02_Exact_Wire_Message_Catalog.md`, with `v/t/cid/bid/seq`): preferred *starting candidate* for v1.3 because it represents batch lifecycle and recovery; its numeric widths, security placeholders, multi-frame alternatives and capacity are **not yet accepted**.
5. **Latest HW-02 corrected catalog** (`HW-02_Exact_Wire_Message_Catalog (3).md`, `type/id/actuator/state`): **competing proposal, NOT selected** by this draft. Its removal of batch Start/Stop, read-only state, HC-05 and event retention is not an approved change. Do not mix its messages with earlier catalog or DB-02 adapters.
6. **DB-02 0.1-review:** Mary's current cloud *proposal* (`DB-02_Exact_Bridge_Sync_API.md`, `DB-02_Proposed_Schema_And_Security.md`, `DB-02_Conflict_Receipt_And_Recovery.md`); adapters remain disabled pending exact approved source contract. Older file headers may name Cha; Mary is the designated DB-02 owner for this sprint.

**Change rule:** After the four participants ratify D01–D06 below, Cha records one exact file revision and SHA-256. Ally/Kath/Mary implement against **that same revision**, not against filenames that happen to match. Any later contract change must state its affected fields, tests and owners; no silent replacement.

## 1. Fixed project scope — do not re-debate

| Item | Agreed planning direction / limitation |
|---|---|
| Primary physical command route | Android Flutter ↔ HC-05 Bluetooth Classic SPP ↔ Arduino Uno UART. USB is diagnostic only unless separately authorized. |
| Control authority | Uno autonomously controls incubator temperature, humidity, fan, heater and egg turning. Losing Bluetooth/internet must not delegate local control to cloud. |
| Offline Start | Farmer can request fresh-egg Start with Bluetooth but without internet, **only** when local command authorization and firmware safety checks succeed. Actual Running must be confirmed by source evidence. |
| Cloud bridge | Android uploads confirmed locally saved evidence when authorized and online. Phone-away live telemetry, guaranteed background uploads and missing-reading backfill are **not** promised. |
| Biological pilot | Chicken-only physical pilot, fresh eggs; no previously-incubated Start, no brooder farmer demo, no physical Duck/Quail claims. Existing UI may retain unvalidated profiles with truthful restrictions. |
| Batch quantity | Current UI accepts 6–12 eggs; **not** yet a verified physical capacity or approved firmware range. Do not silently turn it into hardware policy. |
| Farmer completion | Farmer manually enters `eggs_hatched` from 0 through original `egg_quantity`. Logical `hatched_count` is not a deployed DB column. Physical Stop and manual completion are separate. |
| Incubation time | Day 1 begins at substantiated physical Start; Day 2 after 24 valid elapsed hours. RTC/clock-invalid and power-outage recovery remain unresolved. |
| Safety and research claims | No powered-load/egg tests without qualified electrical clearance; no hatch-rate claim without a real completed cycle. |

## 2. Normative safety/data rules (carry forward from v1.2)

**C-01. Truthful states.** Distinguish: Bluetooth connected; command ACK; *controller-reported* current state; independently measured actuator behavior (if available); local record saved; cloud event applied; and farmer completed. ACK/cloud Active/relay off/turning lockdown never by themselves prove Running or Stopped. Disconnected means current state may be unknown/stale, not automatically Stopped.

**C-02. Deliberate lifecycle.** Species selection, device boot, profile changes and generic actuator toggles must never initiate a new incubation batch. `START` must be an explicit farmer action tied to an immutable batch and approved profile/quantity. `STOP` must explicitly target the matching batch; it is not turning lockdown or temperature cycling. No second batch while one is active.

**C-03. Unknown outcome is not failed outcome.** Before dispatch, Android durably stores original batch/command intent and a conservative dispatch marker. If ACK is lost or Android crashes, do **not** automatically resend START with a new ID. Reconnect and request read-only state plus original outcome evidence. If unavailable, show **Start unconfirmed** and block another Start until authorized recovery.

**C-04. Distinct durable identities.** Controller, Android installation, batch, command/query, controller transition event, reboot epoch/sample and cloud session identities must not be conflated. Stable source event IDs and immutable original content are required for idempotent upload. Do not fabricate a source event ID or physical Start timestamp on the phone or backend.

**C-05. Source evidence and recovery.** A historical `started` EVENT proves a historical controller-reported transition; fresh correlated STATE proves only the controller's *current reported* state. The team must either retain critical original transition/outcome evidence through a defined recovery window or explicitly ratify the precise weaker loss guarantee, with honest UI/cloud behavior. One-shot events alone do not satisfy the original recovery promise.

**C-06. Independent time and sensor validity.** UTC source time (if trustworthy), source monotonic age, phone receipt and server receipt are separate. Invalid is not stale. Temperature and humidity actual readings must be distinguishable from setpoints, with validity and freshness. Unknown time must not be silently repaired with phone/server time.

**C-07. Offline and online authorization are separate.** HC-05 pairing, MAC address, public token or one designated phone do not by themselves authorize START/STOP or cloud writes. No service-role secret in Flutter/Arduino. Mary must authorize the cloud uploader and protect existing permissive policies; Ally/Kath must approve feasible local ownership/provisioning and revocation limitations. Until then, live Start and ingestion remain disabled.

**C-08. Evidence release is not HTTP success.** The proposed DB-02 `retention_ack:null` is not a device-verifiable release. Never delete source evidence because the phone saw HTTP 200, a generic JSON receipt, or a phone-authored hash. If authenticated Uno-side release is infeasible, define and approve bounded retention/service/loss policy; do not invent a signature.

**C-09. Safe persistence and control.** Torn EEPROM writes, full journals, invalid RTC, sensor faults, mismatched IDs and unknown recovery must never auto-create a batch or assert a completed transition. Define power-cut phases, integrity checks and fail-safe output policy. A firmware build or simulator test does not authorize powered-load tests.

**C-10. Strict bounded framing.** Candidate is compact, versioned LF-terminated JSON over HC-05 UART. Flutter handles split/coalesced byte streams. Uno RX ring occupancy, app parse buffer, Uno TX, Android RX, memory/stack and actual worst-case frame bytes are separate constraints. A 64-byte Arduino software RX ring is **not** a hard maximum complete frame length. Reject invalid/oversized frames by discarding through LF; never parse a suffix as a new command.

## 3. One proposed interface direction — NOT yet a byte-level freeze

**Recommendation for D02:** use the earlier `v/t/cid/bid/seq` family as the **single starting catalog**, not Ally's later actuator-only `type/id` replacement. It already names the facts UI and DB need. The exact wire packet, ID widths, split/fragment rules and offline authentication must still be made feasible on the chosen Uno sketch and approved together.

| Logical family | Direction | Required semantics for ratification | Current status |
|---|---|---|---|
| HELLO/capabilities | Android ↔ Uno | Actual source identity, protocol version, capabilities, local authority result; distinguish query and response | CANDIDATE |
| START | Android → Uno | Explicit command, stable batch, species/profile/quantity, local authorization, safe admission; no action on selection | BLOCKED: schema/security/size |
| STOP | Android → Uno | Explicit matching-batch deliberate stop, safe physical shutdown semantics, durable original outcome | BLOCKED: schema/recovery |
| STATUS → STATE | Android → Uno → Android | **Read-only** correlated current controller state, original batch/start linkage, clock confidence, evidence gaps | BLOCKED: exact exchange |
| ACK/reject | Uno → Android | Correlated accepted/rejected/prior-outcome with bounded reason; never itself Running | CANDIDATE |
| EVENT/recovery | Uno → Android | Original occurred transition ID/content/time validity; retained or explicitly approved loss boundary; ordered recovery | BLOCKED: persistence |
| TELEMETRY | Uno → Android | Actual measured values, per-channel validity, acquisition identity/time, separate setpoints | BLOCKED: max sizes/cadence |
| ERROR | Uno → Android | Typed bounded failure, safe overflow and unsupported-version handling | CANDIDATE |
| Cloud submit/reconcile | Android ↔ Supabase | Mary's `bridge-sync` candidate, authenticated immutable event/reading, dedup, exact applied/waiting/conflict receipt | BLOCKED: adapter/auth/deployment |

**Do not implement any illustrative `mac` or profile placeholder from the earlier catalog as a real credential or approved Chicken profile.** Do not assume the six later HW-02 example lengths (92, 184, 128, 191, 42, 94 bytes including LF) are maxima. Do not select Uno/Combined/flashed sketch by guessing from README. The approved source manifest and exact schema are D01–D03 outputs.

## 4. One-time design-freeze decision sheet (D01–D06)

**Instructions:** Timebox to **one 45-minute joint decision session on October 28**. Cha writes a single answer per row in this document; Ally/Kath/Mary record `ACCEPT / REQUEST SPECIFIC CHANGE` against the *same* revised packet. No generic new review report. If a decision cannot be made from available evidence, record a named implementation blocker and the reduced demonstration scope; do not pretend it is approved.

| ID | My recommended default to decide today | What must be filled in before freezing | Responsible sign-off |
|---|---|---|---|
| **D01 — baseline** | Keep K06 v0.5 architecture; HC-05/Android; select one actual Arduino sketch/branch and one wire-catalog lineage. Prefer earlier batch-aware catalog as basis, **not** latest actuator-only catalog. | Canonical Git remote, branch, commit, sketch SHA-256, core/toolchain, actual flashed identity (or `UNKNOWN`), source hash and approved transport | Ally + Kath + Mary; Cha records |
| **D02 — lifecycle/identity/recovery** | Require deliberate START/STOP, read-only STATUS/STATE, stable original batch/command/event IDs, ACK separate from occurred transition, no blind retry. Restore bounded recovery if feasible. | Exact field-level packet schema, duplicate-content rules, persistent manifest, replay or explicitly signed loss boundary, state/rejection table | Ally + Kath + Mary |
| **D03 — bytes/build** | Keep JSON-LF **if** actual Uno memory/latency tests support it. Correct false 64-byte whole-frame rule; no arbitrary binary switch. | True maximum fixtures, RX/TX parser sizes, service-time budget, genuine compile/link artifacts, flash/SRAM/stack estimate; if not feasible, approved bounded multi-frame alternative | Ally; Kath validates Android; Mary maps |
| **D04 — trust/release** | Pilot is one designated Android installation, but require separate offline local command authority and authenticated Supabase uploader. Keep `retention_ack:null`; do not auto-release EEPROM evidence. | Feasible provisioning/revocation policy, exact authorization test boundary, bounded journal/service retention or verifiable release; explicit accepted loss guarantee | Ally + Mary + Kath |
| **D05 — profile/time** | Chicken fresh-egg physical pilot only; manual hatch count; unknown RTC time remains unknown. No unapproved numeric profile. | Named profile approver, real heater/humidity/turning limits, actual capacity, RTC module/clock-invalid policy, power-outage day policy, sensor validity/freshness rules | Ally + designated profile approver; Kath/Mary acknowledge |
| **D06 — local/cloud mapping** | Preserve SQLite intent/dispatch/evidence/outbox; use Mary's candidate idempotent `bridge-sync` and real deployed DB column names; cloud projection must never create physical facts. | Exact source-to-DB adapter and tests, auth/RLS, original session mapping, receipt states, manual completion vs physical STOP, no-migration fallback demo | Mary + Kath; Ally checks source; Cha records |

**Decision record (fill in, do not infer):**

- Date/time and attendees: `PENDING`
- D01 result + source manifest/hash: `PENDING`
- D02 result + catalog revision/hash: `PENDING`
- D03 result + build/limits or explicit blocked test: `PENDING`
- D04 result + accepted threat/loss boundary: `PENDING`
- D05 result + named biological/profile approver: `PENDING`
- D06 result + adapter/cloud release gate: `PENDING`
- Ally firmware sign-off: `PENDING`
- Kath Android/UI sign-off: `PENDING`
- Mary backend/security sign-off: `PENDING`
- Cha integration coordination acknowledgment: `PENDING`
- Contract disposition: **NOT APPROVED** until filled and accepted.

## 5. Implementation tickets immediately after the corresponding decisions

**Tickets are scoped implementation assignments, not instructions to skip safety gates.** Each ticket ends with source changes + reproducible test output + known limitations. No member should spend the sprint producing another general report.

| Ticket | Owner | Code deliverable | Acceptance evidence / fallback |
|---|---|---|---|
| **HW-IMP-01** | Ally | On chosen Uno sketch: explicit START/STOP/STATUS parser and correlated ACK/STATE; safe no-auto-start; strict line overflow handling; source version | Actual compile/link + `avr-size`; host-generated normal/duplicate/wrong-batch/overflow test logs. If source memory fails, stop and report exact limits. No flashing without clearance. |
| **HW-IMP-02** | Ally | Durable original batch/command/transition record and recovery design; RTC/time-validity policy; event replay or approved narrower loss policy | EEPROM layout, power-cut simulation/unit tests, boot reconciliation; not a claim of physical reliability. |
| **UI-IMP-01** | Kath | Isolated Bluetooth transport/framer/decoder behind interface; mocked source fixtures; connecting/disconnected/unknown/confirmed/stale UI | Flutter analyzer and widget/unit tests. No production Start until D02/D04 approved. |
| **UI-IMP-02** | Kath | Offline-first app startup and local SQLite intent/dispatch/evidence/outbox; no automatic hardware command retry | Cold-start/no-internet, lost ACK, restart, duplicate cloud submission, local-save-failure tests. Use fake transport/test backend until approved. |
| **DB-IMP-01** | Mary | Version-pinned cloud adapter, immutable event/reading receipt and reconciliation in isolated test environment; security/RLS tests | Authorized/unauthorized/duplicate/content-conflict/wrong-source tests. No production migrations or open endpoint before security review. |
| **INT-IMP-01** | Cha | Single test matrix and integration harness matching the approved packet; align branches and coordinate safe end-to-end dry run | One evidence ledger: source commit, test command, actual result, limitation. No independent backend design. |
| **DOC-IMP-01** | Claude / documentation owner | Portal status + exact version/decision table, linking test evidence | Preview/navigation check. Never mark planned feature as implemented or hardware-verified. |

## 6. October 28–30 execution and fallback

### October 28 — DECIDE AND CODE

- **First 45 minutes:** four members decide D01–D06 using section 4. Do not re-open HC-05, autonomy, offline Start or Chicken scope absent new physical evidence.
- **Next 2–4 hours:** Ally implements/test-builds HW-IMP-01 in her branch; Kath starts UI-IMP-01 with mock transport; Mary starts DB-IMP-01 only in isolated local/test scope; Cha builds INT-IMP-01 matrix and pins canonical repository. Run tasks **in parallel** after the relevant decisions.
- **By end of day:** one contract revision/hash, one source commit or patch per owner, test logs and blockers; not another broad review. If hardware cannot compile, Kath continues UI/mock demo without claiming physical integration.

### October 29 — INTEGRATE AND VERIFY

- Align actual schema/fixture versions and run non-powered serial/controller tests; verify Flutter↔firmware stream parsing, explicit START/STOP/STATUS semantics and offline UI behavior.
- Only with qualified electrical clearance, approved wiring/pins, confirmed flashed sketch and supervisor authorization: perform a controlled physical test; separately document controller-reported state versus actual actuator behavior. Otherwise show a labeled simulator/bench-only demo.
- If Mary's test endpoint passes auth/RLS and mapping tests, run a supervised source→Android→test Supabase receipt; otherwise keep cloud demo mocked or read-only and mark ingestion pending.
- Cha records PASS/FAIL/NOT TESTED for each link. Kath/Ally/Mary fix **specific failing tests only**.

### October 30 — EVIDENCE FREEZE

- Freeze demo code/branch and evidence before presentation. Rehearse only supported scenarios. Cla/adviser review wording; do not claim a completed Chicken hatch cycle or measured hatchability without actual data.
- If full path is blocked, deliver **an honest partial prototype**: autonomous control code/build evidence (if achieved), Android UI/mock Bluetooth states, actual known hardware results, and clearly labeled Supabase candidate. Do not energize loads or fake readings to meet the date.

**Hard stop:** If D01–D06 are not sufficiently settled on October 28, the team must choose the smaller evidence-limited demo **that day**. Do not start another cycle of four new documents.

## 7. Definition of done (independent gates)

1. **Design frozen:** exact same wire/API revision and decision sheet accepted by Ally, Kath, Mary, with Cha's coordination record; no P0 contradiction. This alone is **not** working code.
2. **Software implemented:** source changes committed on identified branches; reproducible Flutter tests, genuine AVR build, cloud test fixtures and security checks; no invented passes.
3. **Integration demonstrated:** actual transport, source identity and batch lifecycle exercised end-to-end with logs; cloud receipt only if test endpoint is authorized and working. Mocked paths must be labeled.
4. **Physical readiness:** electrical clearance, correct pin map, safe actuators, RTC/sensor tests and approved powered test plan. **Not implied** by 1–3.
5. **Research readiness:** real measured incubation/hatch data and valid manual comparison records. **Not implied** by a short demo or a green test suite.

## 8. Source provenance

- `SmartHatch_K06_Consolidated_17_Decision_Contract_v0.5_Offline_Start_Shared_Terminology.md`
- `SmartHatch_Shared_Communication_Contract_v1.2_CONSOLIDATED_CANDIDATE.md`
- `UI-CONTRACT-03_Final_Compatibility_Decisions(1).md`
- `INTEGRATION-CONTRACT-03_Shared_Decision_Register.md`
- `HW-02_Exact_Wire_Message_Catalog.md` (earlier batch-aware candidate)
- `HW-02_Exact_Wire_Message_Catalog (3).md` (latest competing revision)
- `HW-02_Uno_Feasibility_And_Recovery (3).md` and `HW-02_count_frames (2).py`
- `DB-02_Exact_Bridge_Sync_API.md`, `DB-02_Proposed_Schema_And_Security.md`, `DB-02_Conflict_Receipt_And_Recovery.md`

**Interpretation priority:** verified source/test evidence > explicitly recorded team decision > proposal > illustrative fixture. This document does not assert that any missing approval, firmware build, endpoint, RTC, authorized Bluetooth link or physical test already exists.
