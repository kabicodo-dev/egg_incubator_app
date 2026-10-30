# SmartHatch Data & Communication Contract — DRAFT v0.1

## TASK ID

**K06 — Kath-owned shared contract proposal**  
Draft date: 2026-10-21. Source baseline: branch `kath-k02-previous-incubation-ui`, HEAD `b5f773f70ed3213ae60920b98196dd0d34b25e08`.

> **This document is a proposal, not an approved implementation specification.** Kath owns this draft; Cha and Ally must review their respective boundaries before adoption. No application, database, firmware, deployment or production change is authorized by this document. Source presence is not physical test evidence.

Approval vocabulary used throughout:

| Label | Meaning |
|---|---|
| **VERIFIED IN SOURCE** | Observed in inspected source only; not necessarily deployed, flashed, executed or physically tested. |
| **PROPOSED** | Recommended definition/translation for review; not implemented by this draft. |
| **TBD** | Requires team clarification or missing evidence. |
| **APPROVED** | Explicit acceptance by the responsible team member, recorded with scope/date/evidence. No K06 definition currently has this status. |

Existing K02 UI acceptance does not approve this shared persistence, timing or hardware contract. Chicken is the initial physical pilot; Duck and Quail remain supported software profiles, not physically validated hatch results. No successful physical hatch is asserted for Chicken either.

## FILES REVIEWED / evidence availability

### Ally's uploaded sketches: evidence missing

**TBD — Ally's three uploaded Chicken, Duck and Quail sketches are not accessible in the current workspace/resource listing.** Before drafting, workspace searches found only `arduino/SmartHatch_Uno/SmartHatch_Uno.ino`; species-named files found were PNG assets, not sketches. The available MCP resource listing was empty. This establishes availability in this session, not that the uploads never existed elsewhere.

The repository sketch is **not equivalent evidence** for Ally's uploads or actual flashed firmware. Comments in `IncubationProfile` refer to `SmartHatch_Chicken_Automatic_Stages.ino`, `SmartHatch_Duck_Automatic_Stages.ino` and `SmartHatch_Quail_Automatic_Stages.ino`; those files were not found. Their claimed correspondence is unverified. In all maps below, “sketch” means the inspected repository sketch only. Ally-upload equivalents are **TBD** for every row until supplied.

### Source register

| ID | Reviewed source / relevant locations |
|---|---|
| E1 | [`lib/main.dart`](../lib/main.dart): 74–248 species/session models; 2538–2621 previous-incubation draft; 2736–2753 Start guard; 2886–2947 save sequence; 3079–3090 confirmation; 3274–3278 day formula; 3384–3408 target/growth calculations; 4833–5006 sensor loading/fallbacks; 5114–5116 date label; 7583–7664 console mirroring; 7765–7774 real-batch day; 8027–8049 LCD state; 8355–8388 local brooder action; 8983–9035 simulator isolation. |
| E2 | [`lib/services/supabase_service.dart`](../lib/services/supabase_service.dart): 54–95 presets/settings; 100–167 quantity/session insert; 191–226 reads; 232–244 completion; 287–295 latest sensor query. |
| E3 | [`lib/controllers/incubator_controller.dart`](../lib/controllers/incubator_controller.dart): 5–120 profiles/brooder schedule; 129–177 defaults; 276–304 day/stage; 315–341 local brooding; 398–495 hysteresis/turning; 512–535 unused sync-payload builder. |
| E4 | [`lib/services/arduino_protocol.dart`](../lib/services/arduino_protocol.dart): 9–47 names/pins; 53–96 coercions; 110–186 telemetry; 189–247 commands/ack; 282–309 incoming parser. |
| E5 | [`lib/controllers/arduino_controller.dart`](../lib/controllers/arduino_controller.dart): 33–34 six-second cutoff; 54–103 connection/readings/defaults; 148–189 commands; 225–240 telemetry/late ack. |
| E6 | [`lib/services/arduino_serial_io.dart`](../lib/services/arduino_serial_io.dart): 67–106 serial setup; 129–159 timeout; 164–199 framing/ack matching. Also `arduino_serial_service.dart`, `arduino_serial_factory.dart`, `arduino_serial_stub.dart`. |
| E7 | [`arduino/SmartHatch_Uno/SmartHatch_Uno.ino`](../arduino/SmartHatch_Uno/SmartHatch_Uno.ino): 28–89 pins/timers/state; 103–128 initialization; 184–249 servo/telemetry/ack; 252–307 command parsing; 309–372 sensors/main loop. |
| E8 | [`supabase/migrations/20260929070513_remote_schema.sql`](../supabase/migrations/20260929070513_remote_schema.sql): 52–128 table declarations. `20260929204930_remote_schema.sql` is empty. `20261012090000_incubator_sessions_single_active.sql`:85–87 records a global single-Active index definition. **These do not prove current deployed schema/policies.** |
| E9 | [`README.md`](../README.md):22–91 transport/pin/behavior descriptions. Some claims conflict with E7; do not elevate documentation above code or hardware evidence. `docs/BE-01-session-ownership-audit.md` provides historical ownership context, not a fresh production verification. |
| E10 | `android/app/src/main/kotlin/com/example/egg_incubator_app/MainActivity.kt` is a plain FlutterActivity; main AndroidManifest has no custom USB intent-filter implementation. `pubspec.yaml` declares `flutter_libserialport`; E6 selects IO by `dart.library.io`, not specifically Windows. None proves Android USB operation. |

## WHAT WAS FOUND — exact current names before proposed names

### Database inventory (VERIFIED IN SOURCE; deployed equivalence TBD)

| Table | Exact columns and locally declared SQL types |
|---|---|
| `incubator_sessions` | `id bigint NOT NULL`; `egg_type text`; `start_date timestamp without time zone DEFAULT now()`; `status text DEFAULT 'Active'`; `egg_quantity integer DEFAULT 0 NOT NULL`; `end_date timestamp with time zone`; `eggs_hatched integer DEFAULT 0`; `temperature numeric`. |
| `incubator_presets` | `id bigint NOT NULL`; `egg_type text NOT NULL`; `target_temperature numeric`; `target_humidity numeric`; `incubation_days integer`. |
| `active_settings` | `id bigint NOT NULL`; `egg_type text`; `target_temperature numeric`; `target_humidity numeric`; `incubation_days integer`. Service selects a first row, not a database-enforced singleton in the inspected table definition. |
| `sensor_readings` | `id bigint NOT NULL`; `current_temperature numeric`; `current_humidity numeric`; `recorded_at timestamp without time zone DEFAULT now()`. No chamber, session, device, actuator or brooder column in this declaration. |

No inspected table declaration stores previous-incubation choice/days, physical Start verification, stage, actuator feedback, sensor sample sequence, bridge heartbeat or command queue. Do not write invented columns or silently pack these into unrelated existing fields. Missing persistence means **TBD**, not permission to migrate.

### Flutter and serial inventory (VERIFIED IN SOURCE)

- Setup: `SpeciesData.name`, `incubationDays`, `temperature` (formatted String), `targetHumidity`; `eggCount` / `eggQuantity`; `PreviousIncubationDraft.previouslyIncubated` (`bool?`), `completedDaysText`; Checklist `previouslyIncubated`, `completedPreviousDays`, `_continuationBlocked`.
- Sessions: `BatchData.species`, `eggsTotal`, `eggsHatched`, `startDate`, `endDate`, `temperature`, `status`; service arguments `eggType`, `startDate`, `eggQuantity`, `temperature`.
- Local profile/controller: `speciesName`, `hatchDay`, `lockdownStartDay`, `temperatureTarget`, `heatOnBelow`, `heatOffAbove`, `activeHumidityLow/High`, `lockdownHumidityLow/High`, `eggTurnInterval`; `startDay`, `elapsedSeconds`, `currentIncubationDay`, `stageName`, `brooderStarted`, `brooderDay`, `externalControl`.
- Incoming JSON: `type: "telemetry"`; `incubator.temperature`, `incubator.humidity`, `brooder.temperature`, `brooder.humidity`; `actuators` keys listed below; `turning.intervalMinutes`, `turning.turnsToday`, `turning.secondsSinceLastTurn`, `turning.active`.
- Command JSON: `type: "command"`, `id`, `actuator`, `state`. Ack JSON: `type: "ack"`, `id`, `success`, success fields `actuator`, `state`, `hardwareVerified:false`; failure field `error`.
- `ArduinoTelemetry.receivedAt` is assigned on app parsing, not supplied in serial JSON. Serial messages have no species/session/stage/readiness/Start-confirmation field in E7.
- Local `toSyncPayload()` emits `species`, `eeprom_magic`, `hatch_day`, `lockdown_day`, `start_day`, `candling_days`, `egg_count`, `is_fertile_verified`, `target_temperature`, `humidity_low`, `humidity_high`, `elapsed_seconds`, `current_day`, `stage`, `turning_active`, `brooder_started`, `brooder_day`, `brooder_target_low`, `brooder_target_high`, `brooder_bulb_state`, `brooder_buzzer_alarm`. Search found its declaration but no caller in `lib/`. This is **not an implemented serial/Supabase synchronization contract**.

## CONTRACT FIELD MAP — smallest proposed adapter boundary

### Reading this map

The external/domain names below are **PROPOSED adapter vocabulary**, not new database columns, mandated global Dart renames or commands accepted by firmware. Preserve stable database and JSON wire names. Translate at boundaries. Only add persistence or extend serial messages after a separate reviewed need, migration/compatibility plan and rollout approval.

Every entry gives definition/type/allowed values, exact current mappings, producer/consumer/source of truth, mismatch/translation, test coverage and **APPROVAL STATE**. “None” means absent from the inspected representation, not absent from every external system. Evidence IDs identify the source. Existing tests listed were inspected/referenced, **not run in K06**; proposed tests do not yet establish coverage.

### A. Batch identity, inputs and lifecycle

#### A1. `session_id` — saved batch identity
- **Definition/type/allowed:** Positive database-generated bigint; propose decimal-string representation at external JSON boundaries to avoid large-integer precision loss. Not a serial port, physical machine or anonymous-auth ID.
- **Current map:** Flutter `sessionId`, `BatchData.id` (int); Supabase `incubator_sessions.id`; sketch/serial none.
- **Producer -> consumer / source of truth:** Database -> Windows/Android UI; persisted session row is authority for record identity, not physical attachment.
- **Mismatch / translation:** Telemetry has no batch ID; latest reading cannot prove association. Preserve SQL column; propose adapter string conversion and an explicit reviewed association policy. Never attach buffered samples to a new batch merely because it is now Active.
- **Tests:** Existing `one_active_batch_test.dart`, `session_ownership_audit_test.dart`; propose bigint round-trip, stale-association and cross-session isolation tests.
- **APPROVAL STATE:** **PROPOSED**; association/persistence **TBD — Cha + Ally**.

#### A2. `egg_type` — species profile selection
- **Definition/type/allowed:** String enum `Chicken`, `Duck`, `Quail` for a new supported setup. Unknown legacy values may display as unknown, not silently select Chicken for physical control.
- **Current map:** Flutter `SpeciesData.name`, `BatchData.species`, service `eggType`, local `IncubationProfile.speciesName`; Supabase all three batch/preset/settings `egg_type` columns; sketch/serial none. Local unused payload calls it `species`.
- **Producer -> consumer / source of truth:** Farmer selection + reviewed profile -> saved session/settings and UI; saved row owns record species, actual firmware/profile capability requires Ally evidence.
- **Mismatch / translation:** Repository sketch is not species-selectable. Propose `egg_type` unchanged at database boundary; adapt local `speciesName`/`species`, no global rename or imaginary profile-selection command.
- **Tests:** Existing previous-incubation species/quantity matrix; propose unknown-profile rejection at a future control boundary and adapter round-trip.
- **APPROVAL STATE:** **PROPOSED**; physical profile support **TBD — Ally**; database enum/case **TBD — Cha**.

#### A3. `egg_quantity` — eggs loaded for this batch
- **Definition/type/allowed:** Integer eggs, 6–12 inclusive for new sessions; reject decimals, missing and out-of-range values. A legacy DB default zero is not valid new input.
- **Current map:** Flutter `eggCount`, service `eggQuantity`, `BatchData.eggsTotal`, local `eggCount`; Supabase `incubator_sessions.egg_quantity`; sketch/serial none; unused payload `egg_count`.
- **Producer -> consumer / source of truth:** Farmer -> validated session service -> database -> UI; persisted quantity is record authority.
- **Mismatch / translation:** SQL permits zero by its local declaration; no current firmware quantity handoff. Preserve `egg_quantity`; adapt Dart names; do not claim quantity reached hardware.
- **Tests:** Existing `egg_quantity_validation_test.dart`, `egg_quantity_session_test.dart`, `history_egg_quantity_test.dart`; propose boundary non-integer/legacy-zero tests if persistence adapter changes.
- **APPROVAL STATE:** **PROPOSED** as shared contract; existing UI/service constraint **VERIFIED IN SOURCE**; backend validation **TBD — Cha**.

#### A4. `previously_incubated` — actual prior incubation choice
- **Definition/type/allowed:** Boolean in a completed draft; null means unanswered during editing, never silently No. Means actual incubation elsewhere, not merely time since candling.
- **Current map:** Flutter draft `bool? previouslyIncubated`, Checklist `bool previouslyIncubated`; Supabase none; sketch/serial none.
- **Producer -> consumer / source of truth:** Farmer -> local setup/Checklist; farmer declaration is authority for this input, not a sensor-derived fact.
- **Mismatch / translation:** Not persisted. Propose DTO bool; no encoding in `status`, `temperature`, `egg_type` or a fabricated firmware command. Yes remains UI-only with Start blocked.
- **Tests:** Existing `previous_incubation_step_test.dart`: explicit choice, Yes-to-No clearing, blocked Start, no seven-day default.
- **APPROVAL STATE:** **PROPOSED**; persistence **TBD — Cha**, hardware continuation **TBD — Ally**.

#### A5. `completed_previous_days` — full prior incubation days
- **Definition/type/allowed:** Integer full days; No -> exactly 0; Yes -> positive integer. Empty/0/negative/decimal/non-numeric invalid for Yes. Species/near-hatch maximum remains TBD, not invented.
- **Current map:** Flutter `completedDaysText` -> Checklist `completedPreviousDays`; Supabase none; sketch/serial none. Local `defaultStartDay=7` and `candlingDays=7` are different concepts.
- **Producer -> consumer / source of truth:** Farmer -> validated local draft; later date/controller consumers require approval.
- **Mismatch / translation:** Do not map directly to `startDay`, `start_date` subtraction, `candling_days` or a silent seven-day offset. Propose separate input; preserve K02 block until complete contract exists.
- **Tests:** Existing previous-incubation invalid-input/1,7,99-day/no-write tests; propose agreed species limits and continuation date examples only after review.
- **APPROVAL STATE:** **PROPOSED**; maximum/counting/physical continuation **TBD — Kath + Cha + Ally**.

#### A6. `record_status` versus `physical_state`
- **Definition/type/allowed:** Proposed `record_status`: `Active`, `Completed`, or adapter `unknown` for unusable data (never write `unknown` to SQL without review). Proposed separate `physical_state`: `unknown`, `start_pending`, `running`, `error`; do not infer stopped from disconnect. Exact physical evidence remains TBD.
- **Current map:** Flutter `BatchData.status`, `_starting`, `ActuatorCommandStatus`; Supabase `incubator_sessions.status`; sketch has per-actuator/turning state but no batch-running status. `_starting` means save-in-flight, not Arduino Start pending.
- **Producer -> consumer / source of truth:** Database -> record UI; approved hardware/bridge evidence -> physical-state UI. Neither is a substitute for the other.
- **Mismatch / translation:** `createSession()` inserts Active before physical verification; settings are a second write; “Incubation Started!” follows. Preserve stored status spelling; expose physical unknown until evidence exists. Partial save must not be hidden, auto-deleted or blindly retried.
- **Tests:** Existing `one_active_batch_test.dart` covers duplicate/refused saves, not physical Start. Propose save-success/start-unknown, settings-failure-after-insert, timeout, reconnect, duplicate request and evidence-correlation tests.
- **APPROVAL STATE:** **PROPOSED** separation; transitions, evidence, recovery and storage **TBD — Cha + Ally + Kath**.

#### A7. `eggs_hatched` / `completed_at` — farmer-recorded result
- **Definition/type/allowed:** Integer hatch count 0..saved egg quantity; completion timestamp nullable until completion. Zero is a possible completed result, not a default result for an Active batch. No automatic hatch claim when a timer expires.
- **Current map:** Flutter `BatchData.eggsHatched`, `endDate`, Finish Batch flow; Supabase `eggs_hatched`, `end_date`, `status='Completed'`; sketch/serial none.
- **Producer -> consumer / source of truth:** Farmer confirmation -> database -> History/result display. This records a declared result, not sensor proof of hatching or physical stop.
- **Mismatch / translation:** UI labels `endDate` as “Hatch Date”; do not equate completion with exact hatch observation or stop command. Preserve columns; adapter `completed_at <- end_date` only after timezone interpretation is confirmed.
- **Tests:** Existing `active_batch_finish_test.dart`, `history_result_labels_test.dart`; propose completion-vs-physical-stop and timestamp round-trip tests.
- **APPROVAL STATE:** **PROPOSED**; result/date terminology and time encoding **TBD — Kath + Cha**.

### B. Stage, day, hatch date and targets

#### B1. `incubation_stage` / `brooder_started`
- **Definition/type/allowed:** Proposed stages `active_incubation`, `lockdown`, `brooding`, `unknown`; stage describes biological/control phase, not DB lifecycle or measured hatch success. Brooder start is a distinct event, not automatic proof hatch occurred.
- **Current map:** Flutter `stageName` values `ACTIVE INCUBATION`, `LOCKDOWN / HATCHING`, `BATCH COMPLETE`; `isLockdown`, `isBatchComplete`, `brooderStarted`, `startBrooding()`; Supabase none; sketch/serial none for phase/brooder start. Serial `turning.active` is not incubation stage.
- **Producer -> consumer / source of truth:** Approved profile/time evaluator or firmware -> UI; who owns actual control stage is TBD. Local simulator output is not physical authority.
- **Mismatch / translation:** Local day-7 stage can appear on the farmer console; “Start Brooder (A0)” invokes local controller, while repository sketch has no A0 brooder event. Proposed stage translation is display-only until Ally confirms authoritative source. Do not map `BATCH COMPLETE` to hatched or database Completed automatically.
- **Tests:** Existing simulator isolation and console tests; propose stage-boundary, unknown-stage and brooder-start provenance tests.
- **APPROVAL STATE:** **PROPOSED** vocabulary; stage authority/brooder event **TBD — Ally + Kath**, storage **TBD — Cha**.

#### B2. `completed_incubation_days` / `display_day` / `brooder_day`
- **Definition/type/allowed:** Whole-day nonnegative count; displayed biological day is a distinct integer with indexing/bounds TBD. Brooder day starts from a separately confirmed brooder event. No default Day 7 for farmer batches.
- **Current map:** Flutter Home/current: elapsed `.inDays + 1`; Details: elapsed `.inDays` without +1; `BatchData` truncates start/end strings to dates; local controller: `startDay + elapsedSeconds ~/ 86400`, default `startDay=7`; `brooderDay`, `setBrooderDay()` clamp 1..60 (comment says 1..42). Supabase only `start_date`, `end_date`, profile `incubation_days`; sketch has uptime days for turn counter, no incubation/brooder day.
- **Producer -> consumer / source of truth:** Chosen time authority + saved full timestamps + declared prior days + reviewed profile -> all UI projections; actual control phase requires agreed firmware authority.
- **Mismatch / translation:** Off-by-one, timestamp truncation, and day-7 defaults conflict. Ask team to choose incubator-local calendar boundaries vs completed 24-hour periods, timezone, indexing and reboot policy. Keep raw time separate from formatted date; no formula adopted here.
- **Tests:** Existing Home/Details tests characterize different formulas; propose one agreed example matrix: initial instant, 23:59/24h, midnight, prior days, timezone/DST, clock changes, reboot and brooder boundary cases.
- **APPROVAL STATE:** **TBD — Kath + Cha + Ally**. No date-counting change authorized.

#### B3. `expected_hatch_at` / `incubation_days` / `lockdown_start_day`
- **Definition/type/allowed:** Nullable estimate with explicit timezone and reviewed profile duration; never an actual hatch result. Duration/day thresholds positive integers; final values TBD where sources conflict.
- **Current map:** Flutter `SpeciesData.incubationDays`, `IncubationProfile.hatchDay`, `lockdownStartDay`, Current `startDate + totalDays`, success-screen `now + incubationDays`; Supabase preset/settings `incubation_days`; no expected-hatch/lockdown column; sketch/serial none.
- **Producer -> consumer / source of truth:** Approved profile and approved baseline/date convention -> UI; actual hatch remains farmer report.
- **Mismatch / translation:** Quail 17 days in defaultSpeciesList vs 18 in IncubationProfile; Details “Hatch Date” uses `end_date`. Preserve `incubation_days`; do not repurpose `end_date` for an estimate. Estimated date remains null if required evidence is missing.
- **Tests:** Existing setup/navigation/Details tests; propose all-profile duration consistency, continuation estimate and estimate-vs-result tests after counting approval.
- **APPROVAL STATE:** **PROPOSED** separation; durations, lockdown boundaries, calculation **TBD — Ally + Kath**, persistence/time type **TBD — Cha**.

#### B4. Incubator target set point and control ranges
- **Definition/type/allowed:** Proposed `targets.incubator.temperature` finite numeric °C; `heat_on_below`/`heat_off_at_or_above` thresholds and humidity `low`/`high` in %RH are distinct from target and UI ideal ranges. Low <= high; operational limits/polarity/inclusivity require Ally approval.
- **Current map:** Flutter formatted `SpeciesData.temperature`, local `temperatureTarget`, `heatOnBelow`, `heatOffAbove`, humidity profile limits; Current UI temperature target ±0.5 and RH target ±5; Supabase `incubator_presets.target_temperature/target_humidity`, `active_settings.target_temperature/target_humidity`, and session `temperature` written as selected target. No range columns. Sketch/serial has no setpoint/range input or automatic threshold evaluator in E7.
- **Producer -> consumer / source of truth:** Reviewed species/stage profile -> UI/config adapter -> future approved controller boundary; desired settings and applied hardware settings must stay distinguishable.
- **Mismatch / translation:** Save handler always writes `humidity:55`; scalar presets differ from local stage ranges. Preserve existing scalar columns and translate as scalars only, never invent a range from ±5 or claim hardware applied a DB write. Range representation/persistence is TBD; no setpoint command invented.
- **Tests:** Existing quantity/session tests verify save flow, not firmware application; propose profile/stage/threshold equality/hysteresis/missing-value adapter tests. Review legacy assertions before changing them.
- **APPROVAL STATE:** **PROPOSED** semantics; numerical profile, safety limits and applied-settings evidence **TBD — Ally**, persistence/precedence **TBD — Cha + Kath**.

#### B5. Brooder target ranges and alarm thresholds
- **Definition/type/allowed:** Proposed `targets.brooder.temperature_low/high` (°C), `humidity_low/high` (%RH), alarm state/evidence separate from readings. No invented species/age guideline or safety guarantee.
- **Current map:** Flutter `brooderTargetLow/High`, `IncubationProfile.getBrooderTargetLow/High()`, `brooderHumidityLow=45`, `brooderHumidityHigh=60`, `brooderBuzzerAlarm`, `brooderAlarmMessage`; Supabase none; sketch has DHT brooder readings and manually commanded relays, not these thresholds/age schedule/alarm JSON.
- **Producer -> consumer / source of truth:** Approved profile + brooder day -> target display; firmware owns actual safety/control policy only after Ally confirms it.
- **Mismatch / translation:** Local controller claims Arduino correspondence, but missing species sketches prevent verification; Current Incubation compares brooder to fixed 30–32°C and 45–60% rather than the full local age schedule. Propose target-range adapter from a single reviewed profile, no broadcasting local simulated alarm as hardware alarm.
- **Tests:** Propose per-species/week boundary tests, null-sensor/cutoff/hysteresis tests, and hardware-vs-local provenance tests; no physical validation supplied.
- **APPROVAL STATE:** **TBD — Ally** for targets/alarms; **PROPOSED** separation; optional persistence **TBD — Cha**.

### C. Actual measurements, timestamps and quality

#### C1–C4. Four actual sensor channels

**Definition/type/allowed for each:** Nullable finite numeric temperature in °C or humidity in %RH. Valid zero is not missing. Current parser accepts temperature -20..60°C, RH 0..100%; these are parsing bounds, not approved operational safety limits. Propose canonical numeric JSON, null for unavailable; do not replace actuals with targets or simulator values.

| Concept / proposed external path | Flutter exact name | Supabase column in local declaration | Repository sketch -> JSON |
|---|---|---|---|
| C1 incubator actual °C: `incubator.temperature` | `ArduinoTelemetry.incubatorTemperature`, controller getter same name; Details `_liveTemperature` searches `temperature`/`temp` | `sensor_readings.current_temperature` (chamber meaning requires Cha confirmation) | `incTemp`, gated by `incValid` -> `incubator.temperature` |
| C2 incubator actual %RH: `incubator.humidity` | `ArduinoTelemetry.incubatorHumidity`; Details `_liveHumidity` searches `humidity`/`relative_humidity` | `sensor_readings.current_humidity` (chamber meaning TBD) | `incHum`, gated by `incValid` -> `incubator.humidity` |
| C3 brooder actual °C: `brooder.temperature` | `ArduinoTelemetry.brooderTemperature`, controller getter same name | None | `brooderTemp`, gated by `brooderValid` -> `brooder.temperature` |
| C4 brooder actual %RH: `brooder.humidity` | `ArduinoTelemetry.brooderHumidity`, controller getter same name | None | `brooderHum`, gated by `brooderValid` -> `brooder.humidity` |

- **Producer -> consumer / source of truth (each channel):** Physical DHT -> sketch sample cache -> serial parser -> Windows UI; proposed bridge/database adapter -> Android UI. Sensor sample is measurement origin; persisted row is a timestamped copy, never automatically “live.” This chain has not been physically verified.
- **Mismatch / translation (C1/C2):** Explicitly map existing `current_temperature`/`current_humidity` to the incubator measurement model only after Cha confirms chamber semantics. Fix consumer adapter rather than rename SQL columns to `temperature`/`temp`. Current Details falls back to setpoint/target and has no finite/range/freshness test.
- **Mismatch / translation (C3/C4):** No confirmed DB representation; do not write brooder values into incubator columns. Until Cha reviews a minimal additive storage/transport option, cloud brooder readings are unavailable. No migration is prescribed here.
- **Additional quality issue (all four):** E7 clears both chamber values when either DHT value fails, using chamber validity flags; no per-value validity bit on wire. Fresh serial frames can repeat the same cached sensor sample because telemetry interval is 2s and sensor interval 2.5s.
- **Tests (each channel):** Existing `arduino_protocol_test.dart` covers telemetry, numeric strings, out-of-range and nulls; `farmer_console_readings_test.dart` covers fake live/stale/unavailable/disconnected rendering. Proposed DB-key adapter, chamber-isolation, NaN/Infinity, partial-sensor, target-not-actual and old-row tests.
- **APPROVAL STATE (each channel):** Existing names **VERIFIED IN SOURCE**; mapping/provenance rule **PROPOSED**; chamber/DB coverage **TBD — Cha**, real sensor semantics/limits **TBD — Ally**.

#### C5. `measured_at`, `received_at`, `recorded_at` — distinct clocks
- **Definition/type/allowed:** Proposed UTC ISO-8601 timestamps with `Z`/offset at external boundaries; nullable when origin time unknown. `measured_at` = actual acquisition time; `received_at` = Windows bridge receipt; `recorded_at` = existing DB field whose true semantics must be confirmed. Never stamp an old sample “fresh” at upload.
- **Current map:** Flutter `ArduinoTelemetry.receivedAt=DateTime.now()` on parsing; Supabase `sensor_readings.recorded_at` naive timestamp default now(); sketch `lastSensorMillis`, `lastTelemetryMillis`, `millis()` are uptime timers, no timestamp/sample ID in JSON. Session `start_date` naive and `end_date` timezone-aware are separate record dates.
- **Producer -> consumer / source of truth:** Sensor/firmware for acquisition if exposed; Windows clock for receipt; DB for insertion time. Android displays translated instants/age; firmware uptime cannot be converted to wall-clock without an agreed reference/reboot policy.
- **Mismatch / translation:** Current DB date default cannot prove sensor measurement time; no timezones embedded in naive SQL type. Cha must state current timezone/meaning before translating. Preserve `recorded_at`; don't relabel it acquisition time without evidence or rewrite historical times. Extra acquisition/receipt storage is TBD.
- **Tests:** Propose timezone/offset/missing/invalid/future timestamp, delayed upload, reboot/uptime rollover, duplicate cached sample and clock-skew tests.
- **APPROVAL STATE:** **PROPOSED** distinction/UTC boundary; current naive-time interpretation **TBD — Cha**, acquisition/uptime support **TBD — Ally**.

#### C6. `reading_state` / `connection_state` / `last_received_at`
- **Definition/type/allowed:** Proposed measurement quality `live`, `stale`, `unavailable`, `disconnected`; transport `disconnected`, `connecting`, `connected`, `error`. A fresh frame with invalid numbers is not a healthy sensor. Bridge online, serial connected and sensor fresh are separate facts.
- **Current map:** Flutter `_ReadingStatus`, `ArduinoConnectionStatus`, `isLive`, `isStale`, `staleAfter=6s`; Supabase no quality/bridge heartbeat column; sketch no such enum, emits nulls for invalid chamber readings.
- **Producer -> consumer / source of truth:** Serial/bridge events + approved clock-age calculation -> UI; Android must use cloud sample/bridge evidence, not its own unsupported COM-port state.
- **Mismatch / translation:** Home conflates stale with connecting; Details reads global latest row once with no age test. Proposed live requires valid channel + agreed age + source/link evidence; after cloud/USB loss show unconfirmed, not physical stop. Untrusted/future timestamps do not pass freshness. UI may retain a last-known value only visibly marked stale with age.
- **Tests:** Existing farmer-console fake-state tests; proposed Home/Details/cloud offline, stale boundary and clock-skew tests. Six seconds is existing behavior, not an approved cloud threshold.
- **APPROVAL STATE:** **PROPOSED** vocabulary; serial/cloud thresholds, upload cadence and reconnect handling **TBD — Ally + Cha + Kath**.

### D. Actuators and physical behavior

#### D1. `actuators.<wireName>` — reported logical outputs
- **Definition/type/allowed:** Proposed nullable boolean per output: true = firmware-reported enabled/on, false = explicitly reported disabled/off, null = absent/unknown; quality/time accompany it. Neither output pin readback nor ack proves load power, airflow, heating, mist production or tray motion.
- **Current map:** Flutter `ArduinoTelemetry.actuators`, `ArduinoController.actuatorOn()` (missing -> false); `IncubatorController` local `...State` properties; Supabase no actuator columns. E7 `digitalRead(pin)==LOW` for relays; servo reports `turningEnabled`.
- **Producer -> consumer / source of truth:** Firmware logical-output telemetry -> UI; requested state, acknowledged state and later reported state must remain distinguishable. Independent physical feedback, if any, is TBD.
- **Mismatch / translation:** Parser currently fills absent outputs with false, and some screens use cached/default states. Propose preserve exact actuator keys with nullable/quality adapter, not simulated defaults. Existing tests asserting absent=false characterize code, not desired physical truth.
- **Tests:** Existing protocol registry/default tests; proposed absent-vs-false, stale-output, contradictory ack/telemetry and commanded-vs-physical tests.
- **APPROVAL STATE:** **PROPOSED** unknown semantics; feedback and electrical meaning **TBD — Ally**, persistence **TBD — Cha**.

#### D2–D8. Exact actuator behavior inventory and proposed boundary

Each row inherits D1's nullable-boolean type, producer/consumer/source-of-truth and provenance requirements. All have **no existing Supabase column**. The `actuator` command name and `actuators` telemetry key are exactly the shown wire name. “Local rule” is not proof of firmware automation.

| Concept | Flutter internal map | Sketch exact map / observed source behavior | Existing mismatch / proposed translation | Tests | APPROVAL STATE |
|---|---|---|---|---|---|
| D2 incubator heater | `incubatorBulb`, `incubatorBulbState`; local `_evaluateIncubatorHeating()` | `PIN_RELAY_INCUBATOR_BULB=10`, RELAYS `incubatorBulb`; active-low, boots off, boolean command controls pin | Local <=37.5 on / >=38 off; no such automatic hysteresis in E7 loop. Preserve key, display reported output only; actual autonomy/failsafe TBD | Existing protocol key/pin test; propose threshold-edge + sensor-loss policy tests after Ally review | **VERIFIED IN SOURCE** names; **PROPOSED** adapter; automation **TBD — Ally** |
| D3 circulation fan | `incubatorFan`, `incubatorFanState=true` local default | `PIN_RELAY_INCUBATOR_FAN=12`; `incubatorFan`; active-low, initialized off, command-driven | Local “always on” default conflicts with sketch boot off. Unknown until report; no unconditional forced-air claim | Registry; propose boot/disconnect/manual-vs-auto authority tests | **VERIFIED IN SOURCE** names; operating policy **TBD — Ally** |
| D4 exhaust fan | `exhaustFan`, `exhaustFanState=false` | `PIN_RELAY_EXHAUST_FAN=9`; `exhaustFan`; active-low, boot off, command-driven | No automatic temperature/ventilation rule verified in E7. Preserve boolean meaning, do not invent vent cycle | Registry; propose explicit off/on/unknown and alarm-override tests | **VERIFIED IN SOURCE** names; ventilation policy **TBD — Ally** |
| D5 incubator humidifier | `incubatorHumidifier`, `incubatorHumidifierState`; local `_evaluateIncubatorHumidifier()` | `PIN_RELAY_INCUBATOR_HUMIDIFIER=6`; `incubatorHumidifier`; active-low, boot off, command-driven | Local on below stage low / off >= high; E7 does not apply ranges. Preserve key; desired range != applied state | Registry; propose stage-boundary, equality, null-sensor and output tests | **VERIFIED IN SOURCE** names; range/safety behavior **TBD — Ally** |
| D6 brooder heater | `brooderBulb`, `brooderBulbState`, `_evaluateBrooderHeating()` | `PIN_RELAY_BROODER_BULB=11`; `brooderBulb`; active-low, boot off, command-driven | Local brooder-start/day hysteresis, null-sensor alarm, <10 or >40°C cutoff not implemented in E7. Never advertise these as flashed safeguards | Registry; propose inactive/day/sensor-fault/cutoff tests plus separate physical verification plan | **VERIFIED IN SOURCE** names; automatic/safety behavior **TBD — Ally** |
| D7 brooder humidifier | `brooderHumidifier`, `brooderHumidifierState`, `_evaluateBrooderHumidifier()` | `PIN_RELAY_BROODER_HUMIDIFIER=5`; `brooderHumidifier`; active-low, boot off, command-driven | Local on <45 / off >=60 only after local brooder start; no equivalent E7 loop rule. Preserve reported state, no inferred mist | Registry; propose disabled/boundary/sensor-loss tests | **VERIFIED IN SOURCE** names; automation **TBD — Ally** |
| D8 egg turner | `eggTurningServo`, `turningActive`, local `eggTurningStatus`/`scheduledTurnsPerDay` | `PIN_EGG_SERVO=3`; `turningEnabled=true`; command changes schedule enable, not immediate turn; 4h interval, 25°/155°, 900ms attached then detach | E7 has no stage/lockdown stop; local profile disables scheduled turning in lockdown. Preserve key as schedule-enabled only, never servo-moving/turn-confirmed. No “turn now” command proposed | Registry/turn-interval tests; propose schedule-vs-motion, reboot, lockdown ownership tests | **VERIFIED IN SOURCE** names; actual positions/load/schedule/lockdown **TBD — Ally** |

#### D9. `turning` counters / interval
- **Definition/type/allowed:** `intervalMinutes` positive integer minutes; `turnsToday` nonnegative integer; `secondsSinceLastTurn` nonnegative seconds; `active` schedule-enabled boolean (unknown when absent proposed). Scope of “today” must be explicit.
- **Current map:** Flutter `turnIntervalMinutes` default 240, `turnsToday`, `secondsSinceLastTurn`, `turningActive`, derived scheduled turns/day; Supabase none; sketch `TURN_INTERVAL_MS`, `turnsToday`, `lastTurnMillis`, `turnsDay=millis()/86400000`; serial keys `turning.intervalMinutes/turnsToday/secondsSinceLastTurn/active`.
- **Producer -> consumer / source of truth:** Firmware scheduler -> UI; counting code increments after issuing servo operation, not independently sensed tray movement.
- **Mismatch / translation:** “Today” in E7 is uptime 24h buckets, not incubator-local midnight. Reset loses counters; no profile/session persistence or EEPROM use in E7. Parser defaults and controller default six turns/day may fabricate schedule when absent. Preserve existing keys, annotate counter basis as TBD; do not invent physical confirmations.
- **Tests:** Existing protocol scheduled-turn derivation; propose unknown counter/default, reboot/day-bucket rollover and session-association tests.
- **APPROVAL STATE:** **PROPOSED** distinctions; counter/day/retention semantics **TBD — Ally + Kath**, cloud persistence **TBD — Cha**.

#### D10. Buzzers, interlocks and safety policy
- **Definition/type/allowed:** Proposed alarm status nullable boolean plus known fault reason/source; thresholds and de-energization policy require explicit firmware review. Not a synonym for UI warning colour.
- **Current map:** Flutter local `brooderBuzzerAlarm`, `brooderAlarmMessage`; Supabase none; sketch `PIN_BUZZER_INCUBATOR=7`, `PIN_BUZZER_BROODER=8`, initializes LOW with active-HIGH assumption, no buzzer command/telemetry or safety evaluator in loop.
- **Producer -> consumer / source of truth:** Actual firmware fault evidence -> UI; local simulations stay local. A failed sensor sample in E7 reports null but does not itself switch an already-on relay off.
- **Mismatch / translation:** README labels buzzers active-low relays; E7 assumes active-high. Do not assume wiring polarity, cutoff behavior or independent feedback. Retain missing alarms as unknown; no new alarm/control protocol specified.
- **Tests:** Proposed fault provenance/equality/reconnect tests after Ally policy review; physical safety test plan separate and not executed here.
- **APPROVAL STATE:** **TBD — Ally**; optional UI/storage mapping **PROPOSED**, persistence **TBD — Cha**.

### E. Communication, command confirmation and platform boundaries

#### E1. Serial transport / JSON versus text
- **Definition/type/allowed:** Existing repository protocol: newline-delimited JSON objects at 9600 baud, 8 data bits, no parity, 1 stop bit, no flow control. `type` is `telemetry`, `command`, or `ack`. Unknown/malformed lines must not become valid telemetry/control success.
- **Current map:** Flutter `parseArduinoLine()`, `ArduinoCommand.toJsonLine()`, IO reader newline framing; Supabase none; E7 `Serial.begin(9600)`, `Serial.println()` JSON, `pollSerial()` newline parsing.
- **Producer -> consumer / source of truth:** Windows serial adapter <-> inspected firmware implementation for their respective encodings. Ally's flashed/uploaded protocol remains TBD.
- **Mismatch / translation:** No verified plain-text species sketch is available. **JSON vs text is an unresolved compatibility risk, not a demonstrated difference between supplied sketches.** If Ally supplies text serial, require exact representative lines/commands, delimiters, units, error cases, baud and meaning; review a boundary adapter or deliberate versioned protocol change. Do not invent text tokens or auto-detect with ambiguous control semantics.
- **Tests:** Existing protocol malformed/unknown/whitespace tests; propose real captured fixture parsing, fragmented/coalesced lines, CRLF, partial/oversize input and compatibility tests. No recorded physical serial capture supplied.
- **APPROVAL STATE:** Existing JSON protocol **VERIFIED IN SOURCE**; reuse **PROPOSED** only if Ally confirms; upload/flashed compatibility **TBD — Ally**.

#### E2. `command` request and acknowledgement
- **Definition/type/allowed:** Existing request `{"type":"command","id":"...","actuator":"<registry name>","state":true|false}` + newline. Proposed ID nonempty ASCII, unique per request, <=23 bytes for repository parser compatibility; JSON body <=159 bytes excluding terminator for E7's 160-byte buffer. These constraints must be rechecked against Ally's firmware.
- **Current map:** Flutter `ArduinoCommand.id/actuator/state`, generated `cmd-<milliseconds>-<counter>`; `_pending` resolves by ack ID, timeout 3s, duplicate pending actuator blocked; Supabase no command queue/status columns; sketch `id[24]`, `actuator[24]`, `CMD_BUFFER_SIZE=160`, `handleCommand()`, `sendAck()`.
- **Producer -> consumer / source of truth:** Windows controller -> firmware -> matching ack -> UI command status; firmware acknowledgement is processing evidence, not load verification or batch Start.
- **Mismatch / translation:** Ack success has `id`, `actuator`, `state`, `hardwareVerified:false`; failure has `id`, `success:false`, `error`. Flutter ack parser keeps hardwareVerified false and transport matches ID, not full requested actuator/state. Late acks can update controller output cache. Propose validate correlation and expected output, preserve logical-vs-physical distinction; on timeout outcome is unknown, not definitely off. No blind replay after reconnect. Retry/idempotency semantics TBD.
- **Tests:** Existing protocol serialization/ack tests; propose wrong ID/output, duplicate/late ack, truncated ID, partial write, command rejection, timeout/disconnect and reconnect replay tests.
- **APPROVAL STATE:** Shape **VERIFIED IN SOURCE**; tightened boundary **PROPOSED**; timeout/retry/idempotency/actual firmware behavior **TBD — Ally + Kath**; cloud command transport **TBD — Cha** and not proposed for v0.1.

#### E3. Hardware readiness / batch Start confirmation
- **Definition/type/allowed:** Proposed UI labels: disconnected “Incubator not connected”; connecting “Connecting to incubator…”; stale “Readings out of date”; waiting “Waiting for incubator checks”; ready “Ready to start”; pending “Confirming incubation start…”; running “Incubation running”; error “Start not confirmed”. Readiness != fresh telemetry != saved Active != relay ack.
- **Current map:** Flutter connection/reading enums and save spinner exist, but no batch-level readiness evidence; Supabase `status` and settings only; E7 has actuator commands, no readiness/batch Start/status/configuration command.
- **Producer -> consumer / source of truth:** Approved actual readiness/Start evidence -> UI; exact producer/sequence is TBD, not a new readiness command invented here.
- **Mismatch / translation:** Propose disconnected/connecting/no-frame/stale disable Start; fresh data without approved checks remains waiting; ready requires team-defined checks plus valid setup/no conflicting batch; pending requires an approved workflow; running requires batch-correlated evidence. On link loss retain historical confirmation but mark current operation unconfirmed. Database-only save copy: “Batch saved — start unconfirmed.” K02 Yes remains blocked.
- **Tests:** Propose state precedence, partial sensors, saved-but-unconfirmed, stale-after-start, settings-failure and no-false-running tests. Existing save tests are not physical readiness tests.
- **APPROVAL STATE:** Copy/separation **PROPOSED**; readiness checklist/physical evidence **TBD — Ally + Kath**, lifecycle persistence **TBD — Cha**.

#### E4. Windows bridge -> Supabase -> Android UI
- **Definition/type/allowed:** Proposed minimal pilot topology: Uno USB <-> one Windows serial owner; Windows validated telemetry adapter -> existing approved Supabase representation -> Android read/display adapter. Android receiving sensor rows is not direct USB connectivity or remote command confirmation.
- **Current map:** Flutter `LibSerialPortArduinoService` + `ArduinoController` exist; `SupabaseService.getLatestReading()` reads one row; no `sensor_readings` insert/upsert or settings-to-serial forwarding call found in `lib/`. `toSyncPayload()` has no caller. Supabase has no confirmed brooder/bridge heartbeat/command table in E8. Sketch has no networking. Android uses plain FlutterActivity; IO factory is generic, not proof that its native serial plugin works on Android.
- **Producer -> consumer / source of truth:** Proposed Windows adapter is telemetry publisher, DB stores copies, Android displays data with provenance/age; firmware remains physical measurement/control origin. Farmer/session inputs may remain existing UI inputs; no new remote physical control implied.
- **Mismatch / translation:** Transport exists, but end-to-end upload/read-refresh/association path is not implemented in inspected source. Android Home/Current still consult the local Arduino singleton, so a DB row alone cannot make those views live. Retain existing DB names and REST reads; polling vs realtime, cadence, sample association, heartbeat and any necessary additive fields are TBD. No multi-device pairing/accounts/remote-control queue added by this draft.
- **Tests:** Proposed fake bridge->database->Android display integration, offline buffer timestamp preservation, duplicate sample handling, out-of-order uploads and no-command-on-read tests; separate approved physical Windows/Android demonstration later. None run here.
- **APPROVAL STATE:** Topology **PROPOSED**; firmware/Windows protocol **TBD — Ally**, DB publisher permissions/transport/schema **TBD — Cha**, Android source routing/refresh UX **TBD — Kath**.

## Verified source profile values — NOT adopted hardware settings

All numbers below are **VERIFIED IN SOURCE** (E1/E3), not approved agronomic/safety guidance or confirmation of Ally's firmware. Numerical canonicalization is **TBD — Ally + Kath**, storage mapping **TBD — Cha**.

| Species | UI defaults: incubation days / target °C / scalar RH | Local profile: hatch / lockdown day | Local active RH / lockdown RH | Local heat on / off comparisons |
|---|---|---|---|---|
| Chicken | 21 / 37.5 / 55% | 21 / 19 | 45–55% / 65–70% | on <=37.5; off >=38.0°C |
| Duck | 28 / 37.5 / 65% | 28 / 26 | 55–60% / 70–75% | on <=37.5; off >=38.0°C |
| Quail | 17 / 37.5 / 58% | 18 / 15 | 45–55% / 65–70% | on <=37.5; off >=38.0°C |

- Setup currently writes RH 55 for every species. Do not choose a canonical RH by averaging these values.
- Local Chicken/Quail brooder bands by day: <=7:32–35°C; <=14:29–32; <=21:27–29; <=28:24–27; <=35:21–24; later:21–21. Duck low: <=1:30; <=7:`30-(day-1)*0.5`; <=14:`27-(day-7)*4/7`; <=21:`23-(day-14)*4/7`; <=28:`19-(day-21)*4/7`; <=35:`15-(day-28)*2/7`; later:13; high = low+2. These are inventory only, not hardware prescriptions.
- Local brooder RH 45–60%; local temperature cutoff <10 or >40°C. Those cutoff/alarm behaviors are not in E7's loop.
- E7 does not consume profiles, setpoints, species, day, EEPROM magic, prior days or session ID. Its relays are command-driven, not the autonomous stage controller described by local-profile comments. Its servo schedule starts enabled at boot and is not batch/lockdown aware. Actual flashed behavior remains TBD.

## CONFLICTS and minimal proposed resolution

| ID | Observed conflict or evidence gap | Smallest proposed resolution / owner |
|---|---|---|
| X1 | Details reads `temperature/temp`, `humidity/relative_humidity`; local DB uses `current_temperature/current_humidity` | Consumer adapter, preserve stable DB columns; Cha verifies actual names/semantics. |
| X2 | Missing actuals become target/setpoint values; partial actuals can produce Normal | Keep actual nullable and targets separate; no “Normal” from a substituted missing sensor. Kath; quality contract Cha/Ally. |
| X3 | Fixed saved humidity 55 vs species scalars vs stage ranges | One reviewed profile/range authority, distinct scalar/range concepts; do not rename/drop columns or silently invent thresholds. Ally/Kath/Cha. |
| X4 | DB Active/success UI vs no verified physical Start; non-atomic settings write | Separate record status/physical evidence and honest copy; recovery contract before implementation. Cha/Ally/Kath. |
| X5 | Quail 17 vs 18 days; +1 vs no +1 day formulas; local Day 7 default | Resolve counting/durations with examples; retain full timestamps; no date-rule implementation in draft. All three. |
| X6 | JSON repo serial vs alleged external text serial | Missing Ally files/captures: do not claim established mismatch or invent text grammar. Review actual uploads, then adapter/compatibility decision. Ally. |
| X7 | Local automatic heat/humidity/lockdown/safety logic vs command-driven reference sketch | Verify flashed species firmware and control ownership; no proof local simulator performs physical control. Ally. |
| X8 | Fan local default ON vs reference sketch boot OFF; absent actuators -> false | Unknown until valid reported output; confirm default/polarity/policy. Ally/Kath. |
| X9 | Receipt freshness vs sensor sample age; naive DB time vs timezone-aware end date | Explicit clock provenance/timezone and cloud stale policy; preserve current columns until reviewed. Cha/Ally. |
| X10 | Global latest reading, no local DB chamber/session link; brooder persistence absent | Explicit one-incubator association policy; do not label unrelated latest sample as historical batch data. Minimal additive representation only if reviewed necessary. Cha. |
| X11 | Windows serial exists but upload/settings relay path absent; Android UI still local-serial-driven | Review minimal bridge + Android data-source adapter; no claim end-to-end already exists. Cha/Ally/Kath. |
| X12 | README says lockdown/safeguards and active-low buzzers; E7 lacks phase logic and assumes active-high buzzer silence | Treat README as disputed evidence, get wiring/firmware confirmation. No firmware edit. Ally. |
| X13 | Local brooder Start/A0 wording vs no A0 event in E7; LCD local Day 7/[ACTIVE] | Source-labelled state or unavailable, no unverified physical command promise. Kath/Ally. |
| X14 | Existing tests assert absent actuators=false and target-value fallbacks | Characterization != desired shared contract. Review replacements when fixes approved; do not weaken tests. Kath. |

## QUESTIONS / OWNER — focused review checklist

### Kath — approve UX/domain scope (all currently TBD)
- [ ] Confirm profile spelling/case and unknown-profile behavior; Chicken-first pilot statement without hatch-result claims.
- [ ] Confirm 6–12 quantity rule and prior-incubation meaning/No=0/Yes-positive; preserve blocked Yes Start until all dependencies resolved.
- [ ] With Cha/Ally, choose time baseline, day indexing/calendar-vs-24h rule, expected-hatch wording and worked examples. No existing team agreement inferred.
- [ ] Confirm record-vs-physical state labels and UI source selection: Windows local telemetry vs Android cloud copy; unavailable/stale/last-updated presentation.
- [ ] Confirm local/simulator state never appears as actual output or confirmed hardware stage; decide brooder button semantics.
- [ ] Approve adapter vocabulary/minimal scope; no automatic global rename, new screen/account/pairing system or remote-control feature.

### Cha — approve persisted data / bridge boundary (all currently TBD)
- [ ] Supply a sanitized schema/type/constraint confirmation for the deployed tables (no credentials or production row dump required). Confirm exact sensor keys and chamber units.
- [ ] Confirm `incubator_sessions.temperature` is saved setpoint; confirm `end_date` is completion, not predicted/observed hatch time.
- [ ] Confirm each timestamp's timezone, origin and meaning; how naive historical dates must be interpreted; choose authoritative start instant separately from physical confirmation.
- [ ] Confirm single shared incubator/global one-Active scope and active_settings row identity/concurrency behavior; historical docs/index declaration are not fresh deployment checks.
- [ ] Specify sample/session/chamber association, ordered-latest tie/null handling, and minimal brooder/quality/receipt representation if needed. Preserve stable columns with adapters where possible.
- [ ] Decide prior-days/physical evidence persistence only after semantics approval; identify if a minimal reviewed migration is genuinely necessary and its compatibility/rollout.
- [ ] Define publisher/read permissions and Windows upload/Android refresh plan; no secret-bearing Android client, production writes or new command queue authorized here.
- [ ] Define partial session/settings failure and uncertain Start recovery/idempotency. No delete/reset/retry assumption.

### Ally — approve physical/serial/control contract (all currently TBD)
- [ ] Provide the three uploaded sketches (exact filenames/version or hash), identify what is actually flashed, and state whether it differs from `SmartHatch_Uno.ino`.
- [ ] Provide sanitized example telemetry/error/ack lines and accepted command forms for that firmware; confirm JSON vs text, baud/framing and field units/limits. Do not energize hardware just for this document.
- [ ] Confirm species/day/previous-days acceptance or explicitly unsupported inputs; resolve Quail duration, lockdown boundaries, humidity ranges, temperature hysteresis and brooder schedules.
- [ ] Confirm who owns autonomous heat/humidity/fan/servo control and safety; startup/disconnect/reboot/sensor-failure behavior, polarity, pin map, buzzer wiring, A0 meaning and any EEPROM retention.
- [ ] Confirm servo enabled vs moving semantics, angles/interval, lockdown disable, counter day basis and whether any physical feedback exists.
- [ ] Define readiness and batch-correlated Start evidence using actual available behavior; a relay ack must not be treated as independent load verification. If unsupported, state unsupported rather than inventing a command.
- [ ] Confirm timeout/ack correlation/retry/late-message rules, line/ID limits, telemetry/sample timing and timestamp/uptime availability.
- [ ] Identify later physical pilot test evidence required. Code existence is not a completed physical test or hatch result.

## EVIDENCE — tests and safe verification boundary

- K06 performed file/directory searches, Git status/HEAD reads, source/test inspection and attachment/resource discovery only. No Flutter test, analyzer, application startup, serial connection, firmware upload, database query or network-to-production operation was run for this task.
- Inspected test evidence includes `test/arduino_protocol_test.dart`, `test/previous_incubation_step_test.dart`, and `test/session_ownership_audit_test.dart`. Other named suites are existing coverage references from K05, not fresh K06 executions. None demonstrates real relay switching, USB/Android connectivity, autonomous regulation, Start confirmation or hatch outcomes.
- Existing protocol tests cover JSON parse/serialization and current defaults, not missing Ally firmware compatibility or a Windows->Supabase->Android bridge.
- Future verification sequence is a proposal: approved examples -> pure adapter/unit tests -> isolated fake integration -> separately authorized physical Chicken pilot. Do not execute this sequence automatically.

## REVIEW STATUS

| Scope | Responsible reviewer(s) | Status | Recorded acceptance |
|---|---|---|---|
| Draft ownership, domain wording and UI source rules | Kath | **PROPOSED** | None for K06 |
| Deployed DB shape, time semantics, lifecycle and cloud adapter | Cha | **TBD** | None for K06 |
| Uploaded/flashed sketches, serial grammar, control/safety/readiness | Ally | **TBD** | Missing sketches; none for K06 |
| Cross-team day/profile/Start reconciliation | Kath + Cha + Ally | **TBD** | None for K06 |
| Current source inventory | Read-only inspection | **VERIFIED IN SOURCE** | Not deployment/physical approval |

To record **APPROVED**, identify exact section/fields, decision, reviewer, date and evidence. Approval of one field does not approve another layer, migration, rollout or physical behavior. Any unresolved Ally-dependent item stays TBD.

## NEXT SAFE ACTION

Kath shares this draft and asks Ally to reattach the three sketches or provide their accessible workspace paths/version identifiers, and asks Cha for sanitized schema/time/ownership confirmation. Record decisions and update the proposal only after review. Stop here: no implementation, migration, branch switch, staging, commit, push, merge, deployment or hardware operation.

Only this Markdown document was added. Existing environment/generated changes and committed K02/UI-02 work are preserved; no secret contents were read or reproduced.
