# SmartHatch K06 — Consolidated 17-Decision Design Contract (v0.4 — HC-05 Bluetooth + Android Bridge)

**Decision update date:** October 27, 2026  
**Supersedes:** `SmartHatch_K06_Consolidated_17_Decision_Contract_v0.3.md` **only where this v0.4 explicitly changes the communication architecture and related implementation guidance**. Keep v0.3 as a historical record.  
**Sources:** The supplied v0.3 consolidated 17-decision contract (reviewed October 25, 2026); Kath's reported adviser/team Phase 1 answers (ARCH-01–ARCH-04) on October 27, 2026.  
**Purpose:** One current implementation-planning baseline. This is **not** evidence of hardware verification, cloud security, successful Android background sync, qualified electrical clearance, or an actual incubation/hatch cycle.

## Change-control and approval status

| Phase 1 ID | Decision | Status as of 2026-10-27 |
|---|---|---|
| ARCH-01 | Final selected communication module: **HC-05 Bluetooth** (Bluetooth Classic serial; exact supplied module/firmware to be audited) | **Design approved**, as reported by Kath from adviser/team |
| ARCH-02 | **No phone-away cloud-upload requirement**: readings upload only when the Android bridge is connected, operating, internet-enabled and authorized | **Design approved** |
| ARCH-03 | Final primary path: **Uno + RTC ↔ HC-05 ↔ Flutter Android bridge ↔ secured Supabase** | **Design approved** |
| ARCH-04 | **Arduino Uno retains independent local incubation control** | **Design approved**, hardware proof pending |
| ARCH-05 | Write/review formal K06 v0.4 contract and align team baseline | **Draft produced here; pending team review/adoption and repository placement** |
| ARCH-06 | Share approved contract and revised instructions with Ally, Cha, Kath, Cla and their OpenCode sessions | **Pending distribution and acknowledgment** |

**Meaning of 'approved':** The team selected the design. It does **not** mean hardware has been connected, code completed, Supabase secured, background uploads demonstrated or safety tests passed. Phases 2–8 remain pending except the separately reported K-03A Flutter software-test result.

### Architecture and operational boundary

```text
            Autonomous local control (continues without phone/internet)
   [Arduino Uno + approved local profiles + RTC + sensors + actuators]
                             ⇅ serial UART
                [HC-05 Bluetooth Classic module]
                             ⇅ Bluetooth SPP (short range)
             [Flutter app on designated Android phone]
                             ⇅ internet + authorized requests
                   [Secure Supabase services]
```

- **Primary communication:** HC-05 ↔ Android Bluetooth Classic SPP, not ESP8266 Wi-Fi and not BLE unless a separately verified hardware change is approved.
- **Cloud updates:** Only while the designated Android bridge is actually connected, active, online and authorized. **A paired phone alone is not sufficient.** App background/screen-locked behavior is a test item, not a promised feature.
- **Phone away/offline:** Arduino maintains its local regulation; no new Supabase telemetry arrives through the absent phone. Cloud history may remain readable over internet but must be labeled historical/stale, not live. No guaranteed missed-reading buffering, replay or backfill.
- **Control:** The Uno makes real-time heater/fan/humidifier/turning/safety decisions. Android/Supabase cannot substitute for the local controller. App-originated commands require physical Uno confirmation before UI claims RUNNING/STOPPED.
- **Scope:** Automated incubator chamber only. Brooder is out of farmer-app/demo scope; historical records are preserved unless separately reviewed. Chicken-first physical evidence; Duck and Quail are app profiles pending biological/firmware approval.
- **Egg eligibility:** Fresh eggs only for new batches; no transfer or previous-incubation-days flow. Preserve prior SmartHatch batch History.
- **Completion:** Farmer manually enters `hatched_count` (including zero), app validates, computes hatchability and verifies authorized persistence; no automatic hatch counting.
- **Time:** Day 1 at verified physical Start; Day 2 after 24 elapsed hours; original start needs verified persistence in addition to RTC.
- **Security:** One designated Android installation for pilot, but real authorization/RLS and secure ingestion still required. **No privileged Supabase service-role key in Flutter, Arduino or Bluetooth messages.** Pairing is not cloud authorization.
- **Fallback:** Windows USB may be used for **explicitly labeled laboratory diagnosis/contingency**, not as the approved farmer-facing transport or an automatic replacement for Bluetooth. Any changed defense transport requires team review.
- **Safety:** No powered-load or egg testing without documented qualified electrical clearance. Never infer physical operation from Bluetooth pairing, ACK, cloud save or UI animation.

### What v0.4 changes from v0.3

1. **Supersedes** v0.3's *conditional ESP8266 → Supabase* preferred route with **HC-05 → Android bridge → Supabase** (INT-01, INT-02, HW-01).
2. Replaces ESP8266-specific transport, testing and credential assumptions throughout affected decisions with Bluetooth Classic/Android requirements (INT-04/05/06, CHA-01/03/04/06/07/08/09).
3. Makes **phone-dependent cloud updates** an intentional product limitation; does **not** promise remote live readings, always-on Android background uploads or automatic offline backfill.
4. Keeps the **same 17 K06 decision IDs**, their underlying safety/data-integrity principles, and the earlier manual-hatch-count/fresh-eggs-only/24-hour-day/incubator-only rules.
5. Retains the original ESP8266 choice only as **historical context**; it is not an active instruction to purchase, wire or code Wi-Fi.

## Approval record and historical notes

Kath reported Ally and Cha's agreement to Uno local authority (INT-06) and one authorized Flutter installation (CHA-01) on October 25, 2026; this was not individually signed or physically tested. Kath additionally confirmed manual hatch-count entry (CHA-02) and fresh-eggs-only eligibility (CHA-05). On October 27, 2026, Kath reported the adviser's final HC-05 Bluetooth choice and the team's ARCH-02/03/04 design answers. The report establishes the **current design direction** but is not individual hardware, backend or Android test evidence. Where a decision is marked 'proposed', its detailed implementation remains open to team review. Historical v0.3 defense dates are not new commitments.

## All 17 decisions

### INT-01 — Approved JSON direction; Bluetooth transport pending verification

**Decision:** Ally will update the combined Arduino Uno firmware to a documented, versioned newline-delimited JSON (NDJSON) logical message protocol over serial. Messages should support real sensor readings and validity flags, stable `device_id`/`batch_id`, `command_id` for command correlation, structured errors, and `ACK` separate from physically confirmed `RUNNING`. `STATUS`, `START`, `STOP`, and `GET_READINGS` are proposed message types, subject to Ally's actual firmware-capability review. The **HC-05 Bluetooth Classic serial link to the Flutter Android app** replaces ESP8266 as the selected primary transport. The Android app is the internet bridge to securely authorized Supabase services; the HC-05 cannot upload to Supabase by itself. Species selection or expanding View Details must never start incubation.

**Why / tradeoff:** The team has selected Bluetooth for the pilot to simplify the local serial link, accepting that cloud telemetry depends on a nearby, connected Android bridge. Bluetooth is not automatically simpler for the complete app/backend workflow. JSON is a logical data contract, not evidence that Bluetooth framing, Android parsing, or the firmware are already working. Existing Flutter serial code may be a reference, not proof of Android Bluetooth Classic compatibility.

**Owners:** Ally (Arduino serial messages), Cha (schema, cloud ingestion), Kath (Android Bluetooth parser/bridge), Cla (documentation).

**Acceptance evidence / next action:** Ally identifies the actual flashed firmware and produces raw, versioned NDJSON serial samples. Ally and Kath verify genuine sensor/status/command exchanges over the exact HC-05 module and a physical Android phone; Cha verifies corresponding authorized Supabase records when internet is available. Test partial/invalid lines, duplicate commands, disconnect/reconnect, and matching `batch_id`/`command_id`.

**Risk / limitation:** HC-05 Bluetooth Classic SPP must not be mistaken for BLE. The exact module/firmware, baud rate, pairing behavior, 5 V Uno-to-module RX voltage compatibility, Android permissions and plugin support remain unverified. Windows USB serial may be retained as an explicit development/diagnostic contingency, not as the approved farmer-facing architecture. Powered-load safety hold remains.

**Recorded confirmation:** On 2026-10-27 Kath reported HC-05 Bluetooth with Android bridge as the final design choice; firmware and physical tests pending. JSON direction carried forward from 2026-10-25.

### INT-02 — Approved Bluetooth/Android-bridge architecture; implementation unverified

**Decision:** **ARCH-01 through ARCH-04 approved as design:** Arduino Uno autonomously controls the incubator; RTC supports timekeeping; HC-05 Bluetooth Classic serial links the Uno to a nearby Flutter **Android** phone; the Android app, while connected and operating with internet access, may send authorized telemetry/batch updates to Supabase and retrieve authorized cloud records. **ESP8266 Wi-Fi is superseded as the selected primary transport.** The farmer's phone is intentionally required for new cloud telemetry: **SmartHatch does not have to upload readings while the phone is away.** The RTC is a clock, not a network module or batch database.

**Why / tradeoff:** This simplifies the chosen hardware-to-phone path but creates a phone-dependent cloud bridge. When the phone is out of Bluetooth range, switched off, app bridge unavailable, or internet unavailable, new readings through that bridge stop uploading; the Arduino must still control the incubator. An app that is minimized or a locked phone is **not guaranteed** to keep bridging without explicit Android background-behavior design and testing. Supabase may still show previously stored records, but these must not be labeled live.

**Owners:** Ally (Uno/RTC/HC-05), Kath (Android Bluetooth connection and relay), Cha (secure Supabase ingestion and authorization), Cla (evidence, contract and claims).

**Acceptance evidence / next action:** On a physical Android device, demonstrate a real Arduino sensor sample → HC-05 → Flutter bridge → restricted Supabase test destination with matching identity/value/time provenance; test pairing, reconnect, phone-away, app foreground/background, screen lock, internet outage and safe local regulation. Verify bidirectional Start/Stop/status separately; cloud save or Bluetooth pairing alone never proves physical RUNNING. Log observed rather than assumed behavior.

**Risk / limitation:** Cloud continuity, background operation and automatic replay of readings during absence are **not approved capabilities** until separately designed and verified. Do not silently introduce Wi-Fi, Windows-as-gateway, unattended remote control, or a second transport as an active path. Windows USB remains an optional lab diagnostic/contingency requiring explicit scope approval if used in the defense. Keep Chicken-first evidence-limited pilot and all electrical safety gates.

**Recorded confirmation:** Kath reported adviser/team final Bluetooth choice, no phone-away uploads, Android bridge, and Uno local authority on 2026-10-27. This is an approved design direction, **not** hardware, Android, security or end-to-end test evidence.

### INT-03 — Approved design direction

**Decision:** TEAM-AGREED SCOPE, PENDING IMPLEMENTATION: SmartHatch farmer-facing software covers the AUTOMATED INCUBATOR CHAMBER ONLY. Brooder is a separate/additional physical chamber, not an automated app feature, consistent with adviser's instruction. Show incubator actual temperature/humidity separately from read-only species targets. For invalid/missing/stale actual values show '—' and accurate Sensor Unavailable/Reading Not Updated messages; optional last-known value is labeled non-live. Never replace an actual reading with a target. Preserve existing database records until any separately approved migration.

**Why / tradeoff:** Kath explicitly confirmed incubator-only scope per adviser. Some older individual proposals mention four incubator/brooder sensor channels; those are historical and are not requirements for the farmer-facing scope. Actual and target values remain distinct for data integrity.

**Owners:** Kath (UI scope), Cha (mapping), Ally (sensor channels), Cla (claims)

**Acceptance evidence / next action:** Test real, invalid, missing and stale readings; test wrong-batch data; verify no fallback to target; confirm incubator-only navigation while preserving historical DB records.

**Risk / limitation:** Removing brooder UI must not be interpreted as removal of physical brooder hardware or permission to delete old database records. Missing measurements must not fall back to targets.

**Recorded confirmation:** Kath confirmed incubator-only scope per adviser on 2026-10-25; team implementation pending.

### INT-04 — Proposed physical Start and safe recovery rules (unchanged in principle)

**Decision:** Distinguish saved batch, `Start Pending`, and physically confirmed `RUNNING`. An NDJSON `ACK`, Bluetooth connection, Android app action or Supabase save alone never proves incubation started. Correlate `batch_id` and `command_id`, verify current Uno status before retrying after timeout, and never create duplicate Starts. On Uno restart, preserve original batch/start only when independently verified persistent storage exists; perform sensor, settings and hardware safety checks, then resume local control **only if safe**, otherwise enter a safe error/not-running state. Show a persistent restart/interruption warning until the farmer affirmatively confirms physical inspection. Inspection acknowledgment is not proof eggs survived.

**Why / tradeoff:** Physical status must come from the autonomous Uno, not a phone/cloud state. Bluetooth loss may leave command outcome unknown; the app must reconcile rather than blindly retry.

**Owners:** Cha (session lifecycle), Ally (Start/Stop and recovery evidence), Kath (pending/error/warning UX), Cla (terminology).

**Acceptance evidence / next action:** Test save-only, accepted command, verified RUNNING, timeout, duplicate Start, Bluetooth loss during Start, phone restart, Uno power cycle, safe resume, and warning acknowledgment. Test whether a fresh local Start is possible when the phone/cloud is unavailable under the agreed operating procedure.

**Risk / limitation:** Automatic safe resume is not verified. If persisted identity or hardware state is unknown, do not claim successful Start or resume. An Uno restart is not necessarily evidence of an electrical outage.

**Recorded confirmation:** Original v0.3 proposed rule carried forward; physical implementation and test still pending.

### INT-05 — Proposed RTC and reading-freshness contract

**Decision:** RTC supplies elapsed-time reference and measurement timestamps **only when its time is verified**. If RTC time is invalid, preserving otherwise valid sensor values with `measured_at=null` and `timestamp_valid=false` remains a **proposed**, not finalized, policy. Android/Supabase receipt time is not automatically measurement time. Retain source `device_id`, `chamber='incubator'`, verified `batch_id`, and unique sample identity/sequence when feasible. On phone reconnection, delayed or replayed samples (if any are actually buffered) must never appear as fresh solely because they were just uploaded. Numeric freshness threshold awaits observed Uno sample cadence, RTC accuracy and Bluetooth relay behavior. RTC alone does not preserve original batch metadata.

**Why / tradeoff:** A phone-dependent bridge can introduce delay and gaps. A disconnected phone means no current cloud feed; it does **not** establish that the physical incubator stopped.

**Owners:** Cha (schema, time provenance), Ally (RTC/cadence), Kath (freshness UX), Cla (definitions).

**Acceptance evidence / next action:** Verify valid/invalid RTC, lost Bluetooth, delayed Android upload, phone clock mismatch, wrong-batch association, sample duplication and correct server receipt timestamp. Compare raw sample, app display and stored database record.

**Risk / limitation:** Exact RTC model, clock initialization and persistent batch storage remain unverified. No guaranteed offline buffering/backfill is part of the approved architecture.

**Recorded confirmation:** v0.3 proposed time/freshness rules carried forward with HC-05/Android transport; detailed policy pending.

### INT-06 — Team-agreed autonomous Arduino Uno authority

**Decision:** **Arduino Uno remains the sole primary local authority** for approved incubator temperature/humidity regulation, heater, humidifier, fans, egg turning and fail-safe decisions. HC-05 is a communication module, RTC supports timekeeping, Flutter Android is the user interface/optional cloud bridge, and Supabase stores authorized data. **None of these is required for the immediate local control loop.** Approved Chicken/Duck/Quail settings must be available to the Uno as verified local settings. Following restart, restore original batch/start only with verified persistence; check sensors, settings and hardware safety, resume automatically **only if safe**, otherwise remain in a safe error state. Farmer inspection warning remains until acknowledged. No powered-load or egg tests without qualified electrical clearance.

**Why / tradeoff:** This retains the v0.3 team-agreed control boundary and fulfills ARCH-04. Phone loss must stop cloud updates, not incubation regulation.

**Owners:** Ally (local control, recovery, electrical safety), Kath (farmer UI), Cha (cloud/command boundary), Cla (claims).

**Acceptance evidence / next action:** Supervised, safety-cleared tests of phone-away, Bluetooth disconnect, internet loss, sensor failure, overtemperature, Uno restart, command loss, safe resume and actuator response. Record physical evidence rather than inferred status.

**Risk / limitation:** **Approved design, not verified physical behavior.** No automatic resume without validated persistent state and safety checks. HC-05 voltage/power interfacing must be checked against the exact breakout, not assumed from its carrier label.

**Recorded confirmation:** Kath reported Ally and Cha agreement to Uno authority on 2026-10-25 and reaffirmed it in ARCH-04 on 2026-10-27; no direct signed evidence or physical tests attached.

### INT-07 — Proposed design detail

**Decision:** PROPOSED TEAM DEFENSE POLICY: For October 28, present only what has dated, reproducible evidence. Demonstrate Chicken-first functionality that has actually passed physical/end-to-end testing. Label each feature as source-inspected, mock-tested, physically verified, end-to-end verified, planned, or blocked. Historical manual-incubation outcomes may be described only when properly collected and validated. SmartHatch automated hatchability comparison results remain pending until a real incubation cycle completes and results are recorded. Cla and the adviser must review manuscript/defense claims.

**Why / tradeoff:** Kath, Cha and Cla converge on evidence-limited claims. No full Chicken hatch cycle can be completed between an October 25 start and October 28 defense. No invented hatchability, interview or safety results.

**Owners:** Cla (manuscript/adviser), Ally (physical evidence), Cha (cloud evidence), Kath (demo)

**Acceptance evidence / next action:** Cla creates claims table with evidence link, test date, test type, observed result and limitation. Adviser confirms what may be shown if pilot is incomplete.

**Risk / limitation:** Do not imply successful hatchability, unattended-safe operation, completed cloud path, or physical automation based only on source code or UI mockups.

**Recorded confirmation:** Not individually confirmed in the supplied records.

### CHA-01 — Team-agreed one-authorized-Android-installation scope; security unverified

**Decision:** The initial pilot uses **one designated authorized Flutter Android installation/device**, with no general farmer registration workflow. This is a deployment scope choice, **not** authentication. Cha must implement and verify a revocable identity, least-privilege Supabase access, RLS/RPC policies and a secure path for Android-relayed telemetry. Pairing to HC-05, knowing a Bluetooth PIN, or using the one designated phone does **not** by itself authorize cloud writes or prove that telemetry came from the genuine Uno. Do not embed a Supabase service-role/secret key in the Android app or Arduino. An ordinary public client key is not a substitute for RLS and authorization. Restrict or disable unverified cloud writes/remote commands for the defense.

**Why / tradeoff:** The Android bridge changes the trust boundary: an app connected to HC-05 can relay data, but its cloud permissions must be constrained and telemetry provenance validated to the degree achievable for the pilot. A server-side restricted ingestion endpoint is one candidate, not an implemented fact.

**Owners:** Cha (identity, RLS, ingestion and test matrix), Kath (authorized-device UX and Android permissions), Ally (Bluetooth/device identity), Cla (security claims).

**Acceptance evidence / next action:** Document permitted SELECT/INSERT/UPDATE/DELETE and RPC operations; test authorized and unauthorized devices, rejected forged readings, revoked identity, cloud offline state, no exposed privileged keys, and accepted legitimate relay from physical hardware.

**Risk / limitation:** Security gate remains open. Do not treat HC-05 pairing as encryption/authentication adequate for all threats or claim secure telemetry without tests. If reliable restrictions cannot be demonstrated, restrict the cloud demo and retain Uno-local functionality.

**Recorded confirmation:** Kath reported Ally and Cha agreed to single-device scope on 2026-10-25; architecture changed to Android bridge 2026-10-27; no security verification supplied.

### CHA-02 — Manual hatch-count requirement confirmed; persistence details proposed

**Decision:** PROPOSED COMPLETION CONTRACT: When the farmer chooses Complete Incubation, the Flutter UI MUST require the FARMER TO MANUALLY ENTER the number of successfully hatched eggs (hatched_count), a whole number from 0 through original eggs_set. Display the original egg count, compute hatchability = 100 * manually_entered_hatched_count / original_eggs_set, and request final review and confirmation. SmartHatch MUST NOT claim to automatically detect/count successfully hatched eggs; the count is farmer-reported. Save completion for exactly the intended batch/session with authorized, validated, idempotent update and verify persisted status/result before showing Completed. If the update fails, retain active/pending state. Database completion is not proof physical actuators stopped; coordinate separate hardware Stop/transition confirmation.

**Why / tradeoff:** Kath wants required hatchability entry; Cha, Ally and Cla require record-level persistence verification. Both requirements are compatible and should be combined.

**Owners:** Cha (transaction/validation), Kath (form), Ally (physical stop), Cla (research)

**Acceptance evidence / next action:** Test 0, valid maximum, negative, over-count, noninteger, duplicate completion, wrong session ID, failed network and post-save reread; verify no false Completed display.

**Risk / limitation:** If eggs_set=0 or unknown, do not divide by zero or invent hatchability. Unverified physical Stop remains unconfirmed.

**Recorded confirmation:** Kath reaffirmed the required manual hatch-count input on 2026-10-25; backend persistence and physical Stop verification remain proposed/pending tests.

### CHA-03 — Proposed partial-Start recovery across Bluetooth

**Decision:** If a batch is saved but the Uno's physical Start is not confirmed, retain original batch and command identities; show `Start Pending`/`Unconfirmed`, preserve input, and request actual Uno status before retry. Never duplicate Start or create a new batch just because Bluetooth, Android internet or Supabase times out. Cloud availability is not required for local safety; define an approved recovery path when phone connection is lost.

**Why / tradeoff:** A Bluetooth command can reach the Uno even if its reply is lost. A phone/cloud timeout is not evidence that physical Start failed.

**Owners:** Cha (transaction and recovery), Ally (idempotent command/status), Kath (UX), Cla (limits).

**Acceptance evidence / next action:** Simulate DB save success with Bluetooth Start timeout, disconnected phone after command send, duplicate Start, app restart, reconnect, and unknown Uno state; verify exactly one batch and accurate status.

**Risk / limitation:** Until physical status is known, neither success nor failure can be asserted. No unverified automatic retry.

**Recorded confirmation:** v0.3 proposed rule retained; Bluetooth-specific recovery untested.

### CHA-04 — Proposed authoritative profile/settings contract

**Decision:** Use one authoritative active incubator settings/profile state, consistent between the Uno and approved backend records. Farmer selects predefined Chicken/Duck/Quail profiles; targets are read-only and physical application requires verified Uno confirmation over the approved local interface. Selecting or expanding a species card must not Start incubation. Preserve egg images, Continue behavior and View Details expansion. **Supabase settings writes and Bluetooth delivery acknowledgments are not proof the Uno applied settings.** The Uno must have the approved profile locally and not depend on a phone or cloud for its ongoing control loop. Cha verifies schema and authorization before changes.

**Why / tradeoff:** Retains the v0.3 single-authority goal while removing the ESP8266 assumption. Profile synchronization must be deliberate when the phone is absent.

**Owners:** Cha (settings identity/version), Kath (UI), Ally (firmware profile truth), Cla (documentation).

**Acceptance evidence / next action:** Test selection-only, conflicting/stale settings, correct physical Uno profile mapping, Bluetooth disconnect before/after settings command, and View Details behavior.

**Risk / limitation:** Resolve conflict using device/batch/profile version; do not substitute cloud settings for verified hardware state. Numerical profiles require adviser/Ally review.

**Recorded confirmation:** v0.3 proposed rule retained; physical profile mapping not verified.

### CHA-05 — Fresh-eggs-only scope confirmed; batch-history implementation details proposed

**Decision:** CURRENT SCOPE — FRESH EGGS ONLY. SmartHatch will accept only fresh eggs that have NOT been previously incubated in another machine or session. Every new batch starts its own incubation cycle at Day 1 upon verified physical Start (see CHA-06). DO NOT implement a "Previously incubated?" question, previous incubation days, transferred/partially incubated egg tracking, incubation-day offsets, or resume-from-external-incubator workflow in Flutter, Arduino, HC-05/Android bridge, Supabase, or the docs-portal. A power interruption within the SAME SmartHatch batch is recovery of that existing batch, NOT previously incubated egg onboarding. Preserve the separate History feature for PRIOR COMPLETED SMARTHATCH BATCHES: batch ID, species, original eggs set, start/completion dates, status, manually entered hatched count, and calculated hatchability. Preserve existing History cards, search, filters, and View Details. Daily raw sensor logs need not be exposed to farmers, although verified backend retention for diagnostics/research may be needed. Do not delete existing legacy fields or records without separate migration approval.

**Why / tradeoff:** Kath clarified on 2026-10-25 that SmartHatch supports fresh eggs ONLY. Earlier individual answers from Cha, Ally and Cla considered transferred or previously incubated eggs; those proposals are SUPERSEDED for the current project. The phrase "previous incubation batches" in Kath's History proposal refers to historical SmartHatch batch records, NOT already-incubated eggs being loaded into a new batch.

**Owners:** Kath (eligibility and History UI), Cha (batch schema/history), Ally (fresh-start stages), Cla (research and scope language)

**Acceptance evidence / next action:** Verify that all new-batch flows start from fresh eggs at Day 1; there is no previous-incubation-days field, transfer-egg option or stage offset in the active UX. Verify old completed SmartHatch batches remain searchable and viewable after new batches start. Verify that existing-batch restart recovery does not create a new transferred-egg workflow.

**Risk / limitation:** Do not confuse a previously completed SmartHatch batch with eggs previously incubated elsewhere. Preserve historical database records unless an explicitly reviewed migration is authorized. Fresh eggs is an eligibility requirement, not a claim that the app can biologically verify freshness.

**Recorded confirmation:** Kath explicitly confirmed fresh-eggs-only scope on 2026-10-25; exact database/history behavior still requires implementation testing.

### CHA-06 — Team-agreed 24-hour elapsed-day convention

**Decision:** **Day 1** begins only at verified physical Start. Displayed day = `floor(elapsed_seconds_since_original_confirmed_start / 86400) + 1`, so Day 2 starts after a full 24 hours, not at midnight. RTC is planned for local timekeeping independent of Bluetooth, phone, internet or Supabase. Original confirmed Start and batch identity require separately verified persistent storage. After power interruption, calculate elapsed calendar time from original Start but warn that incubation conditions during the interruption may be unknown. Resume physical control only after safety checks; keep inspection warning until acknowledged. Store UTC instants when known and display local time in Asia/Manila. Do not assume egg survival.

**Why / tradeoff:** The day rule does not change with transport choice. RTC model, initial time setting and persistence method remain pending actual tests.

**Owners:** Ally (RTC/persistence), Cha (time storage), Kath (day UI), Cla (methods).

**Acceptance evidence / next action:** Unit-test 0h, 23:59, 24h, 48h, near-midnight, timezone, app restart; hardware-test power cycle and original Start recovery after storage is chosen.

**Risk / limitation:** RTC alone does not store batch metadata or operate actuators. Invalid RTC or lost persistent state must not silently reset progress to Day 1.

**Recorded confirmation:** v0.3 team-agreed rule retained unchanged in principle; hardware persistence unverified.

### CHA-07 — Proposed telemetry ownership and batch association

**Decision:** Readings originating at the Uno and relayed by HC-05 → Flutter Android → Supabase must retain source `device_id`, `chamber='incubator'`, verified original `batch_id`, and sample identity/sequence where feasible. Android receipt/upload time does not determine batch ownership. A delayed or duplicated upload must never be attached to whichever batch happens to be active at upload time. Unknown association must be flagged or quarantined. Brooder is excluded from farmer UI; historical records are not automatically deleted.

**Why / tradeoff:** A phone bridge introduces intermittent connection and possible delayed delivery. Source and batch provenance matter more than upload timing.

**Owners:** Cha (mapping/ingestion), Ally (source IDs), Kath (display/filtering), Cla (evidence).

**Acceptance evidence / next action:** Deliver batch A sample after batch B starts, duplicate a sample, disconnect/reconnect Android, and attempt mismatched source; verify no cross-batch contamination.

**Risk / limitation:** No assumption that HC-05, Uno or Android app retains a reliable offline queue. Backfill is out of scope unless separately implemented/tested.

**Recorded confirmation:** v0.3 proposed ownership rule retained; Bluetooth bridge untested.

### CHA-08 — Proposed sensor and connectivity status contract

**Decision:** Distinguish (a) **physical incubator operating status**, (b) **Bluetooth connection to the Android bridge**, (c) **Android internet/Supabase sync status**, and (d) **actual sensor reading validity/freshness**. Classify readings Fresh, Stale, Sensor Unavailable or Unknown Freshness using valid flags and trustworthy sample times; do not infer freshness from recent cloud receipt. Show live `—` with `Reading Not Updated` for stale data, `Sensor Unavailable` for invalid readings, and a precise Bluetooth/app/cloud status where known. `Incubator Disconnected` must not imply physical control has stopped. Label last-known values with source/time. Numeric freshness threshold is pending observed serial sample cadence.

**Why / tradeoff:** With the phone away, cloud telemetry is expected to pause by design; this is not necessarily an incubator malfunction. The UI must clearly explain 'No phone connection — cloud updates paused' without showing stale values as live.

**Owners:** Cha (freshness/sync rules), Ally (cadence/status evidence), Kath (farmer messages), Cla (definitions).

**Acceptance evidence / next action:** Test sensor invalid/missing, Bluetooth loss, phone away, app killed, Android background/lock, internet loss, Supabase rejection, reconnect and delayed sample; verify no false RUNNING/STOPPED or live labels.

**Risk / limitation:** No guaranteed background bridge. Bluetooth disconnect does not prove incubator power loss; invalid RTC may produce Unknown Freshness.

**Recorded confirmation:** v0.3 proposed rule adapted to approved Bluetooth architecture; implementation pending.

### CHA-09 — Proposed persistent Start evidence

**Decision:** Preserve stable `batch_id`/`command_id`, original verified physical Start timestamp, and supporting Uno status evidence. On Bluetooth/Android reconnect or Uno restart, query actual status and reconcile before showing `RUNNING`. Never replace original Start with phone reconnection or Supabase insertion time. Recover batch/settings only from verified persistent storage; check hardware safety before local resume. Keep inspection-required warning until farmer acknowledges physical inspection. Cloud row, Bluetooth pairing or last-known status cannot prove the current physical state.

**Why / tradeoff:** The original Start is a hardware event, not a network event. Loss of the phone must not reset incubation day or duplicate the batch.

**Owners:** Cha (durable evidence), Ally (Uno state/storage), Kath (UI), Cla (documentation).

**Acceptance evidence / next action:** Test repeated Start, command timeout, phone restart, Bluetooth reconnect, Uno power cycle, original start retention, safe resume and warning acknowledgment.

**Risk / limitation:** Persistent batch storage and RTC validity not yet verified. Do not infer RUNNING from a stale Supabase Active record.

**Recorded confirmation:** v0.3 proposed rule carried forward; no physical proof yet.

### HW-01 — Proposed HC-05/RTC/Uno verification and electrical safety gate

**Decision:** Ally must identify the exact flashed Uno firmware and update/test the combined JSON/NDJSON firmware; verify actual serial/status/Start behavior; confirm the supplied **ZS-040 carrier and HC-05 module/firmware identity** (user-reported HC-05 selection is not a completed physical module audit); identify the **exact Tiny RTC I²C chip** and verify its timekeeping and battery behavior. Document safe Uno-to-HC-05 wiring, power supply, UART TX/RX voltage compatibility and Android Bluetooth Classic SPP communication settings. Confirm communication using an actual Android phone. With Kath and Cha, prove a genuine Uno reading reaches an authenticated/restricted Supabase test destination **through the Android bridge** with matching data. Qualified electrical inspection/clearance remains mandatory before powered-load or egg tests.

**Why / tradeoff:** HC-05 replaces ESP8266 in the hardware test plan. Bluetooth may simplify serial pairing but does not bypass Android integration, cloud security, RTC verification or physical safety. A module photo or a pairing icon is not an end-to-end test.

**Owners:** Ally (firmware, HC-05, RTC, wiring, safety), Kath (Android Bluetooth bridge), Cha (secure test ingestion), Cla (evidence).

**Acceptance evidence / next action:** Collect module/firmware IDs, photos, sketch version/checksum or upload proof, real serial sample, voltage/power review, Android pairing and serial exchange, app relay logs, matching secured Supabase test row, RTC valid/invalid/restart/battery tests, safety signoff, and pass/fail notes. Separately test physical Start/Stop and safe local operation without the phone.

**Risk / limitation:** Some HC-05 carrier boards accept 5 V power while their RX logic remains 3.3 V-level; confirm exact board specifications and safe level shifting before connecting Uno TX. Do not put privileged cloud credentials in Arduino or Android. Do not claim electrical clearance or powered-load testing without actual evidence.

**Recorded confirmation:** Kath reported HC-05 final architecture on 2026-10-27; physical identification, wiring, safety and end-to-end testing remain pending.

## Gates before relying on the physical or cloud system

1. **Firmware and protocol:** Ally identifies exact flashed Uno firmware, proves valid versioned JSON/NDJSON messages and correlates real command/status/physical Start. Bluetooth pairing or ACK alone is insufficient.
2. **HC-05 and Android:** Confirm exact HC-05 module/firmware, safe power/logic levels, Bluetooth Classic SPP on a physical Android device, permissions, pairing, message parsing, disconnect/reconnect and app foreground/background/lock behavior. Do not assume unattended background upload.
3. **RTC and persistence:** Confirm exact RTC chip, valid clock and battery/restart behavior; separately verify durable original batch/start metadata and safe restart behavior. RTC alone is not a batch store.
4. **Electrical and actuator safety:** Qualified inspection/clearance before powered-load or egg testing; supervised fail-safe tests for sensor fault, overheat, actuator response, restart and power interruption.
5. **Secure Supabase ingestion:** Cha demonstrates authorized Android bridge telemetry, rejected unauthorized/forged writes, least-privilege RLS/RPC, no privileged embedded keys, revocation and correct source/batch identity.
6. **Data freshness and offline limitations:** Kath/Cha verify actual-vs-target separation, stale/missing sensor labels, phone-away/cloud-paused state, no false RUNNING, and no promised backfill without evidence.
7. **Start, completion and research:** Verify physical Start/Stop, idempotent batch lifecycle, original elapsed-day rule, farmer-entered hatch count, accurate History and only genuine comparative hatchability evidence.
8. **Claims:** Cla/adviser review all manuscript/defense statements; label source-only, simulated, physically tested, end-to-end tested and pending features distinctly.

## Team implementation handoff — parallel work and dependencies

| Owner | Can start now | Waits for / gate |
|---|---|---|
| **Ally** | A-01 firmware audit; identify HC-05/RTC; assess UART/voltage safety; draft NDJSON sample messages | Safety clearance before powered-load tests; jointly approved message schema for final firmware integration |
| **Cha** | C-01 Supabase audit; C-02 provisional protocol; restricted Android-relay ingestion design and RLS test plan | Ally A-01 for final protocol; authorized Android bridge test for end-to-end claims |
| **Kath** | K-03B wording/profile review; UI-only audits; plan Android Bluetooth Classic pairing/connection, freshness and sync states | Approved profile numbers; agreed protocol; real Android + HC-05 for physical bridge tests |
| **Cla** | Preserve v0.3; align HTML portal/task library to v0.4; document evidence and limitations | Final team-reviewed contract before calling amendment adopted or distributed |

**Progress:** ARCH-01–ARCH-04 completed as design decisions. ARCH-05 draft prepared; ARCH-06 pending. Phases 2–8 are **not** completed. K-03A has separately reported Flutter software tests (7 targeted checks, 218 total passing); this is not hardware evidence. K-03B remains pending.

## Handoff to Claude (HTML portal only)

Update the **existing** SmartHatch HTML Documentation Portal to use this v0.4 contract as the current decision baseline. Preserve existing layout, styling, navigation, localStorage/task states, reports, historical v0.3 record and prior verified work. Revise architecture diagrams, decision register, HC-05/RTC inventory, Ally/Cha/Kath/Cla task prompts, Android bridge/cloud sync states, acceptance tests and blockers. Do not mark Phases 2–8 completed, do not invent successful hardware/cloud tests, and do not implement code or change Supabase data as part of the documentation task. Keep task IDs stable where possible and show a mapping if a task must be split.
