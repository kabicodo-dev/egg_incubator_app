# SmartHatch K06 — Consolidated 17-Decision Design Contract (v0.3 — Fresh-Egg Scope and Manual Hatch Count)

**Decision review date:** October 25, 2026  
**Source:** Existing K06 member answers and updated team decision workbook; Kath's latest confirmations for INT-06 and CHA-01; latest clarification of CHA-02 manual hatch-count entry and CHA-05 fresh-eggs-only scope.  
**Purpose:** One consolidated design baseline for implementation planning. This is **not** a physical safety certification or a claim that ESP8266/RTC/Supabase integration has passed testing.

## Architecture and scope

- **Preferred path (conditional):** Arduino Uno autonomously regulates the automated incubator; RTC supplies timekeeping; ESP8266 communicates over Wi-Fi through a secure ingestion path to Supabase; Flutter displays authorized incubator information.
- **Fallback:** Windows USB communication if the ESP8266/RTC/cloud path does not pass its required tests. Fallback does not silently transfer safety-critical control authority away from Arduino.
- **Scope:** automated incubator chamber only. Brooder is separate physical equipment and excluded from the farmer-facing application and demonstration scope. Do not delete historical data merely to remove brooder UI.
- **Protocol:** Ally will update combined Uno firmware to documented JSON/NDJSON. Actual flashed version, transport wiring, start verification and firmware behavior must be tested.
- **Security:** one authorized Flutter installation for initial pilot/defense, with properly restricted access. This is not an exemption from authentication/authorization. Trusted ESP8266 ingestion, least-privilege RLS and revocation are implementation/security gates.
- **Egg eligibility:** NEW SmartHatch batches accept fresh, not previously incubated eggs only. No transferred/partially incubated eggs, previous-incubation-days input, or continuation from an external incubator. Prior SmartHatch batch HISTORY remains available.
- **Completion:** Farmer manually enters the number of successfully hatched eggs, including 0 when appropriate; app validates and computes hatchability; do not infer the hatch count from sensors.
- **Time:** Day 1 at verified physical start; next day after each completed 24-hour interval; preserve original start through restart if verified persistent storage exists. RTC alone does not store batch metadata.
- **Safety:** no powered-load or egg testing until qualified electrical clearance and supervised safety checks. Do not claim actual hardware running from JSON ACK, database save, or Wi-Fi connection alone.

## Approval record

Kath reported that **Ally and Cha agreed** to Arduino Uno local authority (INT-06) and the single-authorized-device initial access model (CHA-01) on October 25, 2026. This is a reported team agreement, not individually signed confirmation or test evidence. Kath additionally clarified CHA-02 manual hatch-count entry and CHA-05 fresh-eggs-only eligibility. These are current scope instructions; the exact remaining technical implementation details stay proposed until team review. Other previously confirmed directions are labeled approved in the workbook; remaining detailed decisions stay proposed pending explicit acceptance. Physical safety and security tests remain separate verification gates.

## Latest scope clarifications (override older member proposals)

1. **CHA-02:** farmer manually enters successful hatch count at completion; SmartHatch validates and calculates percentage. Do not implement automatic hatch counting.
2. **CHA-05:** fresh eggs only for each new batch; no prior-incubation-days input or external-incubator continuation. Historical SmartHatch batch summaries remain supported.
3. These clarifications supersede conflicting older K06 individual answers and earlier v0.2 wording; they do not by themselves certify hardware or security tests.

## All 17 decisions


### INT-01 — Approved design direction

**Decision:** PROPOSED TEAM DECISION (UPDATED): Ally will update the Arduino Uno firmware to use newline-delimited JSON (NDJSON), with the agreed versioned message schema, command_id/batch_id correlation, actual sensor readings and validity flags, ACK distinct from confirmed physical RUNNING, STATUS/START/STOP/GET_READINGS as approved after firmware capability review, and structured errors. The ESP8266 will be the first Wi-Fi hardware candidate for secured telemetry delivery to Supabase, tested with the RTC. JSON is the agreed logical message contract; the ESP8266-to-Arduino physical interface and network transport remain to be designed and verified. Windows USB/9600-baud JSON serial remains a fallback, NOT the preferred final architecture. Species selection alone does not start incubation.

**Why / tradeoff:** LATEST TEAM CLARIFICATION: Ally will update firmware to JSON. Existing Flutter serial JSON support provides a reference, but Ally's combined firmware has text-based serial output; neither ESP8266 delivery nor the revised firmware has been proven on the actual hardware. Prefer one consistent versioned logical data contract across fallback USB and proposed Wi-Fi routes, with route-specific framing/authentication.

**Owners:** Ally (firmware), Cha (protocol/backend), Kath (Flutter), Cla (documentation)

**Acceptance evidence / next action:** Ally updates and version-controls JSON firmware; captures actual physical serial examples; Cha/Kath validate parser compatibility; Ally/Cha test an actual sensor reading from Uno through ESP8266 to secured Supabase. Do not remove Windows fallback before passing the tests.

**Risk / limitation:** JSON agreement is not an implemented parser or proof of physical control. ESP8266 is 3.3 V and Uno is 5 V: verify power and safe logic-level interfacing. Keep Windows USB fallback; physical powered-load safety hold remains.

**Recorded confirmation:** Kath confirmed Ally will update firmware to JSON on 2026-10-25; firmware completion and physical test pending.


### INT-02 — Approved design direction

**Decision:** PROPOSED CONDITIONAL TEAM ARCHITECTURE (UPDATED): Preferred path, ONLY IF TESTED SUCCESSFULLY: Arduino Uno autonomous incubator controller + RTC timekeeping + ESP8266 Wi-Fi transport -> authenticated/restricted Supabase ingestion -> Flutter farmer-facing mobile monitoring. The first ESP8266 proof must transmit a genuine Arduino sensor reading to a secured Supabase test destination and match the stored reading; Wi-Fi association alone is insufficient. Validate reconnection, sensor freshness, correct batch identity, Start/Stop authority, and safety before relying on this as the full path. Windows USB remains the explicit fallback if ESP8266/RTC tests fail or critical security/reliability gates cannot be met. Chicken-first defense scope; report only verified parts. The RTC is a clock, not a networking device.

**Why / tradeoff:** LATEST TEAM CLARIFICATION: Kath confirmed Ally will test ESP8266 (not ESP32) with RTC, and the team wants to remove the Windows bridge if and only if the new hardware passes testing. Earlier Windows-first proposals in individual answers are historical, not the latest proposed team architecture. A verified sensor-to-cloud demonstration is required before choosing the Wi-Fi path for the defense.

**Owners:** Ally (Uno/ESP8266/RTC tests), Cha (secure ingestion/Supabase), Kath (Flutter monitoring and states), Cla (evidence and claims)

**Acceptance evidence / next action:** Run RTC test and ESP8266 real-reading-to-secured-Supabase proof. If successful, review reliability/security/control gates and approve Wi-Fi route; if not, troubleshoot and retain Windows USB fallback. Record pass/fail and decision; do not call untested route verified.

**Risk / limitation:** Do not equate one successful cloud upload with a production-ready bidirectional control path. Network disconnection must not disable safe local regulation. Offline buffering without Windows and persistent batch storage remain deferred pending hardware results.

**Recorded confirmation:** Kath selected ESP8266+RTC conditional preferred route on 2026-10-25; Ally will test ESP8266; fallback Windows USB.


### INT-03 — Approved design direction

**Decision:** TEAM-AGREED SCOPE, PENDING IMPLEMENTATION: SmartHatch farmer-facing software covers the AUTOMATED INCUBATOR CHAMBER ONLY. Brooder is a separate/additional physical chamber, not an automated app feature, consistent with adviser's instruction. Show incubator actual temperature/humidity separately from read-only species targets. For invalid/missing/stale actual values show '—' and accurate Sensor Unavailable/Reading Not Updated messages; optional last-known value is labeled non-live. Never replace an actual reading with a target. Preserve existing database records until any separately approved migration.

**Why / tradeoff:** Kath explicitly confirmed incubator-only scope per adviser. Some older individual proposals mention four incubator/brooder sensor channels; those are historical and are not requirements for the farmer-facing scope. Actual and target values remain distinct for data integrity.

**Owners:** Kath (UI scope), Cha (mapping), Ally (sensor channels), Cla (claims)

**Acceptance evidence / next action:** Test real, invalid, missing and stale readings; test wrong-batch data; verify no fallback to target; confirm incubator-only navigation while preserving historical DB records.

**Risk / limitation:** Removing brooder UI must not be interpreted as removal of physical brooder hardware or permission to delete old database records. Missing measurements must not fall back to targets.

**Recorded confirmation:** Kath confirmed incubator-only scope per adviser on 2026-10-25; team implementation pending.


### INT-04 — Proposed design detail

**Decision:** PROPOSED START/RECOVERY RULE (UPDATED): Distinguish saved batch record, Start Pending, and physically confirmed RUNNING; JSON ACK or Supabase save alone never proves operation. Confirm status from the actual Arduino controller, correlate batch_id/command_id, and verify before retrying after timeout. On power restoration, preserve original batch and start time, perform hardware/sensor/saved-settings safety checks, and automatically resume local control only if verified safe; otherwise enter safe error/not-running state. Show a persistent restart/interruption warning until farmer explicitly confirms inspecting incubator and eggs. Keep event evidence/history when supported; farmer acknowledgment is not proof of embryo viability.

**Why / tradeoff:** Team selected safe automatic resume and Kath selected inspection-required warning (Option C). These rules apply to ESP8266 cloud reporting and Windows fallback; no remote connection may be required for local safety. Ally must verify actual firmware state and safe recovery behavior.

**Owners:** Cha (session lifecycle), Ally (start evidence), Kath (farmer messages), Cla (terminology)

**Acceptance evidence / next action:** Test save-only, Start accepted, confirmed RUNNING, timeout, duplicate Start, USB loss, restart, safe resume and warning acknowledgment. Ensure warning cannot be dismissed as 'inspected' without affirmative farmer action.

**Risk / limitation:** If the board cannot prove safe recovery or persistent batch identity, do NOT automatically resume. An Arduino restart is not necessarily evidence of a power outage.

**Recorded confirmation:** Not individually confirmed in the supplied records.


### INT-05 — Proposed design detail

**Decision:** PROPOSED TIME/FRESHNESS CONTRACT (UPDATED): RTC supplies elapsed-time reference and measurement timestamps only when its time is verified. When RTC time is invalid, preserve otherwise valid sensor readings with measured_at=null and timestamp_valid=false as a proposed policy; Supabase server receipt time is not measurement time. Preserve source device_id, chamber='incubator', batch_id and unique sample identity when feasible. For ESP8266 online delivery, Supabase records server receipt/persistence times; delayed uploads must never be labeled live because they arrived recently. The numeric freshness threshold is pending measured transmission cadence and clock tests. RTC can assist 24-hour day progression but original batch start metadata must be stored persistently separately.

**Why / tradeoff:** ESP8266/RTC is now preferred conditionally, so Windows serial-receipt timestamps cannot be the default source. Kath has not explicitly finalized the invalid-RTC telemetry option, so keep it proposed rather than approved. Avoid inventing a measurement time or assuming RTC includes batch storage.

**Owners:** Cha (schema/clock), Ally (sample cadence/RTC), Kath (display), Cla (definitions)

**Acceptance evidence / next action:** Verify clock-valid and clock-invalid cases, delayed uploads, wrong-batch prevention, age classification, and server-generated persisted time. Capture sample raw record and matching DB row.

**Risk / limitation:** RTC model and synchronization still unknown. ESP8266 alone does not guarantee persistent offline storage. Cloud insertion time cannot substitute for lost measurement time.

**Recorded confirmation:** Not individually confirmed in the supplied records.


### INT-06 — Approved design direction

**Decision:** TEAM-AGREED DESIGN — ARDUINO UNO LOCAL CONTROL: Arduino Uno is the primary authority for the automated incubator chamber: local temperature and humidity regulation, fan/heater/humidifier actuation, egg-turning schedule, and fail-safe decisions using approved Chicken/Duck/Quail profiles and valid sensor readings. ESP8266 is the preferred Wi-Fi communications interface and RTC is for timekeeping; neither Supabase nor Flutter nor a Windows computer is required for the immediate local control loop. ESP8266+RTC use is conditional on actual integration tests; Windows USB is a communication fallback, not the intended authoritative control loop. After a restart, the Uno must restore the original batch and start timestamp only if verified persistent state is available, check sensor and hardware safety, and resume automatically ONLY if safe; otherwise enter a safe error state. Farmer-facing restart/interruption warning persists until farmer acknowledges physical inspection. The electrical safety issue requires documented clearance before powered-load or egg testing. Design agreed by team as reported by Kath; physical behavior not yet verified.

**Why / tradeoff:** Kath selected Arduino Uno as controller and reports Ally and Cha agreed. This supersedes Ally's earlier Windows-authoritative individual answer. Arduino-local regulation matches the conditional ESP8266 architecture and avoids reliance on a continuously running Windows PC or internet for safety-critical control. Firmware, electrical safety, and recovery behavior are NOT verified merely by approval.

**Owners:** Ally (hardware safety and final authority feasibility), Kath (UI), Cha (boundary), Cla (claims)

**Acceptance evidence / next action:** Choose Arduino-local vs Windows-authoritative; document USB disconnect and PC shutdown behavior. Verify fail-safe on invalid sensor, overheat, restart, power loss, command loss and safe automatic resume using supervised empty-incubator testing after safety clearance.

**Risk / limitation:** APPROVED DESIGN, NOT VERIFIED IN TEST. Ally must demonstrate safe autonomous operation and fault handling; no powered-load/egg tests until qualified electrical clearance is documented. On invalid sensor, overtemperature, corrupt stored batch, or unsafe restart, do not assume safe automatic resume. ESP8266 3.3V/Uno 5V interfacing must be checked.

**Recorded confirmation:** Kath reports agreement from Ally and Cha on 2026-10-25; individual signatures or direct written confirmations not attached.


### INT-07 — Proposed design detail

**Decision:** PROPOSED TEAM DEFENSE POLICY: For October 28, present only what has dated, reproducible evidence. Demonstrate Chicken-first functionality that has actually passed physical/end-to-end testing. Label each feature as source-inspected, mock-tested, physically verified, end-to-end verified, planned, or blocked. Historical manual-incubation outcomes may be described only when properly collected and validated. SmartHatch automated hatchability comparison results remain pending until a real incubation cycle completes and results are recorded. Cla and the adviser must review manuscript/defense claims.

**Why / tradeoff:** Kath, Cha and Cla converge on evidence-limited claims. No full Chicken hatch cycle can be completed between an October 25 start and October 28 defense. No invented hatchability, interview or safety results.

**Owners:** Cla (manuscript/adviser), Ally (physical evidence), Cha (cloud evidence), Kath (demo)

**Acceptance evidence / next action:** Cla creates claims table with evidence link, test date, test type, observed result and limitation. Adviser confirms what may be shown if pilot is incomplete.

**Risk / limitation:** Do not imply successful hatchability, unattended-safe operation, completed cloud path, or physical automation based only on source code or UI mockups.

**Recorded confirmation:** Not individually confirmed in the supplied records.


### CHA-01 — Approved design direction

**Decision:** TEAM-AGREED INITIAL SECURITY SCOPE — OPTION B: SmartHatch will use ONE designated authorized Flutter application installation/device for the initial pilot/defense, without implementing a general multi-user registration or farmer pairing workflow. The single-device scope is a deployment limitation, NOT authentication by itself. Cha must establish a secure, revocable identity for that installation and test least-privilege Supabase grants, RLS and any RPC policies in a test project. That installation may read only authorized incubator records and perform only explicitly approved actions; it must not be able to forge sensor telemetry or acquire administrative privileges. ESP8266 readings must reach Supabase through a trusted authenticated ingestion path (e.g. a restricted server-side endpoint), never through an embedded Supabase service-role key. If an authorization method cannot be safely implemented and verified by the defense, disable affected cloud writes and remote control; demonstrate only independently verified restricted functionality. The exact credential provisioning/revocation and ingestion endpoint design are Cha's implementation decisions requiring review before deployment. Kath reports Ally and Cha agree to Option B; security configuration has not been verified.

**Why / tradeoff:** Kath explicitly selected Option B: one authorized device for the initial deployment. This reduces onboarding scope without implying that a phone is trustworthy simply because it is the only phone used. A fixed authorized installation still needs secure identity, access restrictions, revocation, and a separate trusted telemetry publisher. Cha will verify allowed and denied operations rather than assume existing RLS is correct.

**Owners:** Cha (authorization design and test matrix), Kath (farmer onboarding UX), Ally (ESP8266 device identity), Cla (security claims)

**Acceptance evidence / next action:** Cha: design the restricted authorized-demo identity and trusted ingestion endpoint; document the SELECT/INSERT/UPDATE/DELETE matrix and test positive/negative permissions using real client identities. Ally: test ESP8266 authenticated telemetry without privileged firmware secrets. Kath: ensure only authorized device can see approved data, and show clear offline/unavailable states. Evidence: sanitized RLS test logs, rejected unauthorized request, accepted authorized read and trusted telemetry write, revocation test, no leaked keys.

**Risk / limitation:** APPROVED SCOPE, SECURITY GATE OPEN. One authorized device does not mean anonymous/public access. No privileged Supabase key in Flutter or ESP8266. Do not deploy remote commands or unverified protected data access; if secure access cannot be demonstrated, restrict the cloud demo and retain Arduino-local control.

**Recorded confirmation:** Kath reports agreement from Ally and Cha on 2026-10-25; individual signatures or direct written confirmations not attached.


### CHA-02 — Manual hatch-count requirement confirmed; persistence details proposed

**Decision:** PROPOSED COMPLETION CONTRACT: When the farmer chooses Complete Incubation, the Flutter UI MUST require the FARMER TO MANUALLY ENTER the number of successfully hatched eggs (hatched_count), a whole number from 0 through original eggs_set. Display the original egg count, compute hatchability = 100 * manually_entered_hatched_count / original_eggs_set, and request final review and confirmation. SmartHatch MUST NOT claim to automatically detect/count successfully hatched eggs; the count is farmer-reported. Save completion for exactly the intended batch/session with authorized, validated, idempotent update and verify persisted status/result before showing Completed. If the update fails, retain active/pending state. Database completion is not proof physical actuators stopped; coordinate separate hardware Stop/transition confirmation.

**Why / tradeoff:** Kath wants required hatchability entry; Cha, Ally and Cla require record-level persistence verification. Both requirements are compatible and should be combined.

**Owners:** Cha (transaction/validation), Kath (form), Ally (physical stop), Cla (research)

**Acceptance evidence / next action:** Test 0, valid maximum, negative, over-count, noninteger, duplicate completion, wrong session ID, failed network and post-save reread; verify no false Completed display.

**Risk / limitation:** If eggs_set=0 or unknown, do not divide by zero or invent hatchability. Unverified physical Stop remains unconfirmed.

**Recorded confirmation:** Kath reaffirmed the required manual hatch-count input on 2026-10-25; backend persistence and physical Stop verification remain proposed/pending tests.


### CHA-03 — Proposed design detail

**Decision:** PROPOSED PARTIAL-START RECOVERY (ESP8266-NEUTRAL): If a batch is saved but actual Arduino Start is not confirmed, keep the original batch and command identity; show Start Pending/Unconfirmed, retain entered data, and query verified hardware status before retry. Never blindly duplicate Start or create a new batch. The final command path (ESP8266 or USB fallback) must not weaken idempotency or require cloud connectivity for local safety.

**Why / tradeoff:** All four member proposals align: preserve pending record, prevent duplicates and verify first.

**Owners:** Cha (transaction/recovery), Ally (status/idempotency), Kath (UX), Cla (limits)

**Acceptance evidence / next action:** Simulate DB success+settings failure, DB success+USB timeout, duplicate Start, app restart and reconnection; verify one batch, no unsafe repeated Start and accurate labels.

**Risk / limitation:** If hardware state is unknown or cloud unavailable, do not assert Start failed or succeeded; preserve safe recovery path.

**Recorded confirmation:** Not individually confirmed in the supplied records.


### CHA-04 — Proposed design detail

**Decision:** PROPOSED SETTINGS CONTRACT (UPDATED): Use one authoritative incubator active-settings/profile state, consistent between Arduino and approved backend records. Farmer selects predefined Chicken/Duck/Quail profiles; targets are read-only and hardware application requires verified confirmation. Selecting or expanding an egg card must not start incubation. Preserve existing egg images and Continue behavior; View Details can expand approved descriptions. On ESP8266-first architecture, the Uno must not depend on Windows or cloud for safe local control, and cloud settings writes alone never prove settings were applied. Cha verifies schema and authorization before changes.

**Why / tradeoff:** Cha and Ally support single authoritative settings identity; Kath's species-card proposal defines read-only UX. Versioning may require schema changes, so keep as proposed until schema review.

**Owners:** Cha (settings identity/versioning), Kath (UI), Ally (profile truth), Cla (documentation)

**Acceptance evidence / next action:** Test two simultaneous updates, stale-version rejection, selection-only no command, correct Arduino profile mapping, View Details expand/collapse without image replacement.

**Risk / limitation:** Never treat Supabase setting save as physical application. Resolve conflicts using batch/device IDs and a single verified local control authority.

**Recorded confirmation:** Not individually confirmed in the supplied records.


### CHA-05 — Fresh-eggs-only scope confirmed; batch-history implementation details proposed

**Decision:** CURRENT SCOPE — FRESH EGGS ONLY. SmartHatch will accept only fresh eggs that have NOT been previously incubated in another machine or session. Every new batch starts its own incubation cycle at Day 1 upon verified physical Start (see CHA-06). DO NOT implement a "Previously incubated?" question, previous incubation days, transferred/partially incubated egg tracking, incubation-day offsets, or resume-from-external-incubator workflow in Flutter, Arduino, ESP8266, Supabase, or the docs-portal. A power interruption within the SAME SmartHatch batch is recovery of that existing batch, NOT previously incubated egg onboarding. Preserve the separate History feature for PRIOR COMPLETED SMARTHATCH BATCHES: batch ID, species, original eggs set, start/completion dates, status, manually entered hatched count, and calculated hatchability. Preserve existing History cards, search, filters, and View Details. Daily raw sensor logs need not be exposed to farmers, although verified backend retention for diagnostics/research may be needed. Do not delete existing legacy fields or records without separate migration approval.

**Why / tradeoff:** Kath clarified on 2026-10-25 that SmartHatch supports fresh eggs ONLY. Earlier individual answers from Cha, Ally and Cla considered transferred or previously incubated eggs; those proposals are SUPERSEDED for the current project. The phrase "previous incubation batches" in Kath's History proposal refers to historical SmartHatch batch records, NOT already-incubated eggs being loaded into a new batch.

**Owners:** Kath (eligibility and History UI), Cha (batch schema/history), Ally (fresh-start stages), Cla (research and scope language)

**Acceptance evidence / next action:** Verify that all new-batch flows start from fresh eggs at Day 1; there is no previous-incubation-days field, transfer-egg option or stage offset in the active UX. Verify old completed SmartHatch batches remain searchable and viewable after new batches start. Verify that existing-batch restart recovery does not create a new transferred-egg workflow.

**Risk / limitation:** Do not confuse a previously completed SmartHatch batch with eggs previously incubated elsewhere. Preserve historical database records unless an explicitly reviewed migration is authorized. Fresh eggs is an eligibility requirement, not a claim that the app can biologically verify freshness.

**Recorded confirmation:** Kath explicitly confirmed fresh-eggs-only scope on 2026-10-25; exact database/history behavior still requires implementation testing.


### CHA-06 — Approved design direction

**Decision:** TEAM-AGREED ELAPSED-DAY RULE (UPDATED): Day 1 begins only at physically confirmed incubation Start. Day N = floor(elapsed_seconds_since_original_confirmed_start / 86400) + 1, so Day 2 after 24 elapsed hours, not midnight. RTC is planned for timekeeping independent of Wi-Fi, and original confirmed Start must be saved in verified persistent storage (storage method deferred until RTC/ESP8266 hardware test). On power interruption, continue calendar elapsed time from original Start, but separately warn that actual incubation conditions during outage may be unknown. Resume physical control automatically only after validated safety checks; keep farmer inspection warning until acknowledged. Use UTC instants in backend when known and Asia/Manila for UI display. Do not assume eggs survived outage.

**Why / tradeoff:** Kath, Cha and Ally agree on confirmed Start and elapsed 24-hour day; subsequent team discussion explicitly selected original-start continuity and safe recovery. Exact RTC model, initial clock setting and persistent batch storage are deferred pending physical tests.

**Owners:** Ally (RTC/batch persistence), Cha (time storage), Kath (day UI), Cla (methods)

**Acceptance evidence / next action:** Unit-test 0h, 23:59, 24h, 48h, near midnight, timezone display, app restart; hardware-test power cycle and original start recovery after choosing persistent storage.

**Risk / limitation:** RTC alone cannot remember batch metadata or power the heater. If RTC or persistent start record invalid, do not silently reset to Day 1 or claim accurate elapsed progress.

**Recorded confirmation:** Kath previously confirmed 24-hour elapsed-day convention; hardware timestamp and persistence verification pending.


### CHA-07 — Proposed design detail

**Decision:** PROPOSED TELEMETRY OWNERSHIP (UPDATED): All ESP8266-sourced (or Windows fallback) readings retain device_id, chamber='incubator', original batch_id where verified, sample identity/sequence where feasible, and time provenance. Never attach a delayed upload to the currently active batch by upload time alone. Unverifiable association remains unknown/quarantined. Brooder data are outside farmer app scope; existing brooder records are not automatically deleted.

**Why / tradeoff:** Cha/Ally/Cla agree on attribution and delayed-upload protection; Kath's newer incubator-only UI scope limits displayed chamber, not necessarily historical storage. Confirm final device/chamber mapping with Ally.

**Owners:** Cha (mapping/ingestion), Ally (source identifiers), Kath (filtering), Cla (evidence)

**Acceptance evidence / next action:** Send batch A reading late after batch B starts; verify it never appears as B's current value. Reject/quarantine unknown association; test duplicate reading ID and source mismatch.

**Risk / limitation:** No assumption that ESP8266 has reliable offline queue/storage. Batch identity and sensor provenance must be verified.

**Recorded confirmation:** Not individually confirmed in the supplied records.


### CHA-08 — Proposed design detail

**Decision:** PROPOSED SENSOR-STATUS CONTRACT (UPDATED): In ESP8266/Supabase/mobile path, classify each actual incubator reading as Fresh, Stale, Sensor Unavailable, or Unknown Freshness from valid sensor flags, trustworthy source and measurement/receipt time. Never treat recent cloud upload as proof of fresh measurement. Show live '—' with 'Reading Not Updated' if stale, 'Sensor Unavailable' if invalid, 'Incubator Disconnected' only when connectivity loss is actually verified, and separate last-known readings with source/time. Numeric freshness threshold remains pending real ESP8266 cadence testing; Windows fallback uses its own observed cadence.

**Why / tradeoff:** Kath's farmer-friendly messages and Cha/Ally/Cla's technical freshness categories complement each other. No actual threshold or clock sync is verified in the backup.

**Owners:** Cha (freshness rule), Ally (cadence), Kath (labels), Cla (definitions)

**Acceptance evidence / next action:** Test fresh, late, invalid, missing, unknown timestamp, internet loss, USB loss, delayed upload and recovery; verify each UI label and no old-as-live value.

**Risk / limitation:** Wi-Fi lost ≠ incubator stopped. Invalid RTC may force Unknown Freshness even with a valid sensor reading.

**Recorded confirmation:** Not individually confirmed in the supplied records.


### CHA-09 — Proposed design detail

**Decision:** PROPOSED PERSISTENT START EVIDENCE (UPDATED): Use stable batch_id and command_id for Start requests, preserve verified physical Start time and supporting Arduino status evidence, and reconcile after RTC/Uno restart or ESP8266 reconnection before claiming Running. The original Start is never replaced by reconnect time. Recover original batch/settings from verified persistent storage, check hardware safety, then resume local regulation if safe. Keep inspection-required warning visible until farmer confirms inspection. ESP8266 link state and Supabase session state must not be mistaken for hardware operating state; Windows USB fallback follows same rules.

**Why / tradeoff:** All member proposals require batch-correlated Start proof; Ally says restart persistence remains unverified. Original batch persistence method and RTC clock initialization deferred until hardware tests.

**Owners:** Cha (durable evidence), Ally (physical state and storage), Kath (UI), Cla (documentation)

**Acceptance evidence / next action:** Test repeated Start, timeout, app restart, Windows restart, Arduino power cycle, preserved original start time, safe resume, inspection confirmation and unknown state.

**Risk / limitation:** Persistent storage and RTC test not complete. Do not infer Running from an old Active row or from Wi-Fi connectivity.

**Recorded confirmation:** Not individually confirmed in the supplied records.


### HW-01 — Proposed design detail

**Decision:** PROPOSED HARDWARE VERIFICATION GATE (UPDATED): Ally will identify the physical Uno firmware version, update combined firmware to the agreed JSON protocol, verify its actual serial/status/Start behavior, and test the exact ESP8266 module with the available RTC (exact RTC model pending). Minimum ESP8266 test: a genuine Arduino sensor reading reaches an authenticated/restricted Supabase test destination with matching values, supported by hardware photo, serial log, transmission result, database record and pass/fail note. RTC test: valid time, independence from Wi-Fi, restart retention, and backup-battery retention if supported. Resolve and document qualified electrical/voltage safety clearance before any powered-load or egg testing. Windows USB remains fallback until verified.

**Why / tradeoff:** No member has provided verifiable flashed firmware identity or raw serial proof. Safety clearance is asserted by Ally but uncorroborated in the supplied evidence; it must not be treated as completed qualification.

**Owners:** Ally (firmware, RTC, ESP8266, electrical safety), Cha (secured Supabase test ingestion), Kath (app integration review), Cla (evidence)

**Acceptance evidence / next action:** Collect photo/model IDs, sketch checksum or upload proof, 9600-baud serial capture, controlled sensor reading, safe test signoff, RTC restart/battery retention test, ESP8266 sensor->secured Supabase matching record; record pass/fail.

**Risk / limitation:** ESP8266 3.3V power/logic requires proper interfacing with 5V Uno. Do not place privileged cloud credentials in firmware. No powered-load tests until qualified clearance documented.

**Recorded confirmation:** Not individually confirmed in the supplied records.


## Gates before relying on the physical or cloud system

1. **Firmware and protocol:** Ally identifies the exact flashed Uno firmware and demonstrates actual JSON messages and reliable command/status correlation. A JSON response alone does not prove physical operation.
2. **Electrical and actuator safety:** Qualified electrical inspection/clearance is documented before powered-load or egg testing. Verify sensor-failure, overheat, restart and fail-safe responses under authorized supervision.
3. **ESP8266 and RTC:** Confirm exact RTC model, valid clock and restart behavior, safe 3.3 V/5 V interfacing, and authentic readings arriving at a secured test Supabase destination. Wi-Fi connection alone is not sufficient.
4. **Security:** Cha tests the single authorized device, rejects unauthorized reads/writes and forged telemetry, protects secrets, and documents credential revocation.
5. **Start/recovery and progress:** Demonstrate actual hardware start evidence, idempotent batch identity, original start-time persistence, 24-hour day convention and restart inspection warning.
6. **Defense evidence:** Cla and adviser approve research claims; incomplete hatchability results are clearly described as pending.

**Implementation planning can start for source-only tasks and tests after this design baseline is accepted.** Cloud deployment and physical powered-load tests remain blocked until their respective verification gates pass.
