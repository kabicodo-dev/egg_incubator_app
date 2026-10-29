# OCT26:K-03B-02 — Chicken profile confirmation record

**Prepared by:** Cha (consolidation) · **Date:** 2026-10-30 · **Last updated:** 2026-10-30
**Status:** **PENDING** — firmware clarification received; P1–P3 profile decisions and attributable sign-offs outstanding; source identity reconciliation required
**Scope:** Documentation only. No code, database, firmware, or hardware change; no authorization to load eggs.
**Retention:** This record is retained open. Kath's earlier confirmation of the species document is preserved as **reported team agreement**; it is not reclassified as a signed approval.

## 1. Evidence boundary

| Label | Meaning in this record |
|---|---|
| **[DOC]** | Previously agreed species document: `HUMIDITY AND TEMPERATURE` (Chicken section) |
| **[SRC]** | Selected source revision as declared by Ally: `arduino/SmartHatch_Combined/SmartHatch_Combined.ino`, commit `80971f902d5634f7fed78ff073fcb78fa31be460` |
| **[APP]** | Current Flutter constants in `lib/controllers/incubator_controller.dart` |
| **[PROPOSED]** | A proposal in meeting notes/contract drafts, not a team decision |
| **[UNVERIFIED]** | Claimed but not reproducible from the locally available repository |

[SRC] is a **source declaration only**. Ally's handoff states no board was flashed, no load was energized, and A-03/A-08 results are host-simulation results. [SRC] therefore describes source settings, not measured behavior.

## 2. Selected-revision verification (local clone)

Checked against this working copy (HEAD `c7a26cf`, `cha-branch2`; all local and origin refs):

| Check | Result |
|---|---|
| Commit `80971f9…` present | **No** — object not found in local or `origin/*` refs; also not in `origin/ally-branch3`. Cannot confirm its date, message, or diff. [UNVERIFIED] |
| Source SHA-256 of working-tree `SmartHatch_Combined.ino` | **`a466a868…`** raw; **`07ca16dc…`** with LF normalization. Neither equals the declared `3721bce0…`. [UNVERIFIED] |
| Profile constants in working-tree copy | Heater 37.5/38.0 °C, cutoff 39.0 °C, humidity 45–55 / 65–70 %, lockdown Day 19, turn 4 h, servo 0/180/90 with 400 ms — **match the declaration** |
| Behaviors described in the declaration vs working-tree copy | **Differ:** working-tree copy has no START/handshake command; telemetry day is capped at 21 (no `elapsedDay()`); humidifier is *not* forced OFF at ≥39.0 °C. These indicate the local copy is a different (earlier) revision. |
| Claim that `SmartHatch_Uno.ino` was deleted in `38232e9` and is absent from the current tree | **Does not hold here** — the file is present and tracked (`dd8583d`); `38232e9` is not in this clone. |

**Disposition:** the profile values are usable as *declared source settings*; byte-level identity of the selected revision and the canonical remote remain open under D01 / HW-IMP-01. This is a source-lineage gap, not a profile-value dispute.

## 3. Consolidated Chicken profile

### 3.1 Resolved in substance (value settled; formal approval still unimplemented)

| Item | Basis | Status |
|---|---|---|
| Species / code | `EGG_CHICKEN = 1` [SRC]; app `Chicken` [APP] | Consistent |
| Incubation duration | 21 days / 504 h; complete at **1,814,400 s** [DOC][SRC] | Consistent |
| Active/main RH | **45–55 %** [DOC dedicated Humidity section][SRC][APP]; reported team agreement recorded 2026-10-30 | Settled in substance by reported team agreement. [DOC] also contains 50–55 % passages (schedule and quick-facts); those are documentation errors to correct, not a reopened value |
| Lockdown RH | **65–70 %**, from Day 19 boundary [DOC][SRC][APP] | Consistent |
| Humidity control | ON below low limit, OFF at/above high limit; hysteresis only; no active dehumidification [SRC][APP] | Consistent as a control rule |
| Lockdown start (humidity) | Day 19 = elapsed ≥ **1,555,200 s** (18 × 86,400) [DOC "Days 19–21"][SRC] | Consistent |
| Lockdown temperature | No separate Chicken lockdown temperature; same band throughout [DOC][SRC] | Consistent |
| Over-temperature cutoff 39.0 °C | **Added safety behavior**, not a species-document value [SRC] | Not a profile decision (see §6) |
| Start/day convention | Day 1 at confirmed physical Start; Day N = `floor(elapsed/86,400) + 1` [DOC][SRC]; matches K06 CHA-06 24-hour convention | Consistent at principle level; wiring to a START handshake is [UNVERIFIED] |

### 3.2 Genuinely outstanding profile decisions

| ID | Decision | Options / evidence | Owner |
|---|---|---|---|
| **P1 — Turning-stop boundary** | Exact elapsed boundary at which turning stops (17 or 18 completed days) | (a) **1,555,200 s** = 18 completed days, start of Day 19 (current [SRC], coupled to the humidity switch); (b) **1,468,800 s** = 17 completed days, start of Day 18, if [DOC] "stop turning on day 18" means no turning during Day 18. [DOC] itself conflicts: "Stop turning the eggs on day 18" vs lockdown "Days 19–21" vs quick-facts "Lockdown (Days 18–21)". Closest recorded input is [PROPOSED] (meeting notes): lockdown after 18 completed days = 432 h, i.e. option (a). No team decision recorded. **Not to be inferred from document wording by the Flutter layer.** | Ally + designated profile/adviser reviewer |
| **P2 — Four-hour turning interval** | Adopt 4 h / 6 turns per day as the automatic-turner setting | 4 h exists in [SRC] and [APP] (`turnIntervalMinutes` 240), but is an implementation choice, not approval. [DOC] only says 3–5/day by hand or up to 24/day (hourly) automatic. No decision record selects 6/day; no record rejects it. Servo travel/mechanics verification is tracked separately (§6). | Ally + designated profile/adviser reviewer |
| **P3 — Heater control band** | Adopt the 37.5–38.0 °C band, its upper bound, and how "target" is displayed | [DOC] target 37.5 °C; forced-air guideline **37.5–37.8 °C**. [SRC][APP] use ON ≤37.5 °C / OFF ≥38.0 °C, so the OFF threshold is **0.2 °C above** the document's stated guideline and 37.5 is a low threshold, not a midpoint. Existing code is evidence of behavior, not approval. Also affects any UI "within ±0.5 °C of target" indicator. | Designated profile/adviser reviewer + Ally |

Not outstanding: duration, both humidity ranges, lockdown humidity boundary, lockdown temperature, species identity. Turning angle/mechanics is not a value decision but a physical-verification item (§6).

### 3.3 P4 — completion-day display (decided by Cha, 2026-10-30)

| Item | Record |
|---|---|
| Decision | Do **not** silently cap the elapsed-day counter. At 1,814,400 s (21 completed days), the elapsed day is **Day 22**. |
| Farmer-facing wording | **"Expected hatch period reached — 21 days elapsed."** |
| Retained data | Actual uncapped elapsed time remains available. |
| Explicitly not claimed | That hatching occurred; that the batch is `Completed`; that hardware stopped. |
| Timing-contract check | **Consistent.** K06 CHA-06 defines `floor(elapsed/86,400)+1`; the K06 meeting notes example gives 21 completed days → Day 22; UI-02 §8 states "no silent cap of true day at profile duration. A progress bar may clamp separately." Any progress-bar clamp is a separate presentation concern. |
| Status | **Display decision recorded.** Implementation is not authorized by this record and remains subject to the normal change process. |

## 4. Requested "existing decisions" check

| Question | Existing decision found? |
|---|---|
| Turning-stop boundary | **No.** Only [PROPOSED] 432 h/Day 19 in K06 meeting notes, and conflicting [DOC] wording. CONTRACT-FREEZE-01 D05 (2026-10-28) records the profile as **BLOCKED / PENDING**. |
| Four-hour turning interval | **No.** Present in [SRC], [APP], and an earlier protocol draft table that marks the values "TBD — Ally". No ratified decision. |
| Heater-control band | **No.** 37.5 °C is a [DOC] target; 37.5/38.0 is [SRC][APP] source behavior listed as "TBD — Ally" in the earlier draft table. No ratified decision. |
| Completion-day display (P4) | **Decided by Cha on 2026-10-30** (§3.3), consistent with K06 CHA-06, the K06 meeting-note example, and UI-02 §8's "no silent cap of true day at profile duration". |

## 5. Approval evidence

### 5.1 What exists

| Evidence | Detail |
|---|---|
| Species document | Content reviewed in full for Chicken. **Reported team agreement** recorded 2026-10-30 (Kath's confirmation): the document is the agreed profile basis, with 45–55 % authoritative. **No explicit revision number, approval date, or sign-off block** exists in the inspected artifact. Reference markers `[1]`–`[4]` appear without a complete bibliography. Three same-named DOCX copies carry identical Chicken text; filename suffixes are not versions. |
| Reported agreement statement | Kath, 2026-10-30: confirmation of the species document "as reported team agreement" is retained. It is recorded as agreement-in-substance, not as a signed numerical-profile approval. |
| Firmware confirmation | Ally's 2026-10-30 handoff, transcribed from Kath's message; declares file, commit, source/HEX hashes, build sizes, and behavior. States its own source/build claims were not independently verified. |
| Decision registers | CONTRACT-FREEZE-01 (2026-10-28): D01 source selection **PENDING**, D05 profile/approver/values **BLOCKED**; all sign-off rows **PENDING**. INTEGRATION-CONTRACT-03 C13 remains **BLOCKED**. |
| Named approver | **Not recorded.** Registers require a "designated profile approver"; no name, role, or dated numerical-profile approval exists in the reviewed records. |

### 5.2 Required to close

1. **Source identity:** exact export matching commit `80971f9…` and SHA-256 `3721bce0…`, plus accessible revision evidence and the canonical remote. Compiled and flashed artifacts must be identified separately; flashed identity may remain `UNKNOWN`. Cha's local copy differs, so neither copy is a common baseline until reconciled.
2. **Profile identity:** immutable `profile_id` + `profile_version` for Chicken (e.g. `CHICKEN-21D-v1`), with the reconciled source revision and SHA-256 pinned to it.
3. **Value ratification (P1–P3 only):** turning-stop boundary, four-hour interval, heater band, recorded with chosen values and rationale; mechanical verification for turning tracked separately.
4. **Named sign-offs with dates:** designated profile/adviser reviewer for the numerical values; Ally for firmware feasibility; Kath and Mary acknowledging display/backend mappings; Cha recording. Approval of the profile is not safety clearance.
5. **Adviser approval:** if the capstone requires adviser sign-off on numerical setpoints, that approval is **not yet documented** and its absence must be stated in the task report.

## 6. Safety and recovery register — separate from profile confirmation

None of the following is approved by recording the profile.

| Item | Source finding | Status |
|---|---|---|
| Over-temp cutoff independence | 39.0 °C cutoff is a software comparison on the same DHT11 that drives the heater; not an independent thermal fuse; cannot detect a stuck-but-plausible reading | Open (HW-10 clearance not granted) |
| Cutoff scope discrepancy | Declaration says heater OFF **and humidifier OFF** at ≥39.0 °C; locally available copy only forces the heater OFF, leaving humidifier control active | Open — confirm in the cited revision or correct the declaration |
| Cutoff reset | No latch; normal control resumes below 39.0 °C; heater re-enables at ≤37.5 °C; no over-temp telemetry flag or buzzer | Documented, unapproved |
| Sensor failure | 10 s stale timeout → heater, humidifier, circulation fan, exhaust OFF; telemetry null; buzzer alarms | Documented, unverified |
| Post-completion control | At 1,814,400 s: turning and exhaust stop, but heater/humidifier continue on lockdown targets until NEW_BATCH/RESET | Open policy question |
| Automatic Start | Invalid EEPROM record auto-starts a new Chicken batch at Day 1 and emits `batch_started` | Open — conflicts with deliberate-Start direction (D02) |
| Power interruption | 60 s EEPROM save interval; off-time not counted; no RTC confirmed; up to ~60 s pre-cut loss; non-atomic writes without CRC | Open (D05/HW-02 clock policy) |
| Turning after reboot | `lastEggTurn` resets at boot, so the first post-boot turn can be up to 4 h late; outage turns are skipped | Open |
| Mechanical | No servo feedback, limit switches, or stall detection; 0°/180° may exceed the real turner's safe range (header requires bench-testing); returns to centre each turn; `performEggTurn()` blocks the loop ~800 ms plus travel | Unverified — bench test required |
| Resource limits | Declared A-08 build: 65 % flash, 86 % SRAM (267 B free) with compiler low-memory warning | Not reproducible locally; build evidence required |
| `TURN_NOW` exposure | Command exists in firmware; README says there is no manual "turn now" button | Open — confirm intent (not a profile value) |

## 7. Backend and Flutter mapping — implementation differences

| Meaning | Current mapping | Difference |
|---|---|---|
| Chicken identity | `species_code: 1` → `egg_type: "Chicken"` | Identity only; no numerical approval implied |
| Profile revision | `profile_ref` is preserved but unconstrained beyond a format regex | **No approved Chicken `profile_ref` value/registry exists** |
| Preset targets | `incubator_presets.target_temperature`, `target_humidity`, `incubation_days` | Single scalar RH cannot express active vs lockdown ranges or hysteresis |
| Active settings | `active_settings.target_temperature`, `target_humidity`, `incubation_days` | No turning schedule, band, cutoff, or profile version |
| Session snapshot | `incubator_sessions.temperature` | Settings snapshot, not a measurement; no profile version stored |
| Flutter constants | Match [SRC] numerically (21/19/37.5/37.5/38.0/45–55/65–70/4 h) | Comments still cite the retired Chicken-only sketch; `startDay` offset and day cap differ from declared firmware; `temperatureTarget` is used as if a midpoint in a ±0.5 °C indicator |
| Completion presentation | P4 requires uncapped elapsed day (Day 22 at 21 completed days) and the wording "Expected hatch period reached — 21 days elapsed" | Current app caps `currentIncubationDay` at `hatchDay` (21) and shows the stage label **"HATCHED"** at time-based completion (`lib/main.dart:8453–8457`), which implies hatching occurred. Change is **not authorized** by this record; recorded as a display-mapping gap for Kath. |
| Bridge state | Ingestion/adapter hard-disabled (`contract_enabled` false) | Combined diagnostics are `sync_eligible: false`; cannot confirm Start or profile |

## 8. Closure position

- **Consolidated profile:** complete in substance for species, duration, both humidity ranges/control, lockdown boundary, lockdown temperature, and the day formula; the species document is retained as reported team agreement.
- **P4:** decided by Cha (§3.3) and recordable as final for display wording; implementation remains unapproved.
- **Open profile decisions:** P1 turning-stop boundary, P2 four-hour interval, P3 heater band — owned by Ally with the designated profile/adviser reviewer. Existing implementation is evidence of behavior, not approval.
- **Open evidence:** reconciliation of source identity (`80971f9…` / `3721bce0…` vs the local copy) and canonical remote; compiled vs flashed artifacts; immutable profile version; named reviewer/approver and dated sign-offs; adviser approval if required.
- **Not authorized:** implementation, database change, firmware upload, powered/egg testing, or egg loading.
- **Task status:** **K-03B-02 PENDING** until P1–P3 are answered and §5.2 evidence is attached. This record does not authorize hardware operation.

*Changing this record's status to "confirmed" requires P1–P3 answers and the §5.2 approvals. It does not authorize hardware operation.*

## 9. Backend response to Kath's 2026-10-30 message (Cha / Mary)

Record retained at this path and kept **PENDING**. The species document stays recorded as **reported team agreement**, not as a signed numerical approval. P4 is recorded as a display decision only.

### 9.1 Backend confirmation status

| Profile item | Agreed basis | Backend representation today | Physically verified |
|---|---|---|---|
| Chicken identity (code 1) | [DOC] + [SRC] + [APP] | `species_code` 1 → `egg_type` `"Chicken"`; `incubator_presets.egg_type` text | No |
| Duration 21 d / 1,814,400 s | [DOC] + [SRC] | `incubator_presets.incubation_days`, `active_settings.incubation_days` | No |
| Active RH 45–55 % | [DOC] dedicated section + reported agreement | Single scalar `target_humidity`; cannot carry the range | No |
| Lockdown RH 65–70 %, Day 19 | [DOC] + [SRC] | Not representable; no stage-range columns | No |
| Lockdown temperature = same band | [DOC] + [SRC] | Not representable; no band columns | No |
| Heater band 37.5–38.0 °C (P3) | Outstanding | No columns; app constants only | No |
| Turning 4 h (P2) | Outstanding | No columns; app constant `turnIntervalMinutes` 240 | No |
| Turning stop boundary (P1) | Outstanding | No columns; derivable only from elapsed if decided | No |
| Day formula / P4 display | K06 CHA-06; P4 recorded | Derived at read time; no stored displayed-day column | No |

### 9.2 Backend answers

1. **Source identity** — Backend cannot pin `catalog_revision` or enable `contract_enabled` while the selected revision is unreconciled. `private.controllers` requires a pinned catalog revision and defaults `contract_enabled = false` (DB-02 §2.1). Ingestion remains disabled; flashed identity may stay `UNKNOWN`.
2. **Profile identity** — `CHICKEN-21D-v1` is reserved **as a documentation label only**. No `profile_id`/`profile_version` table or column exists in the current schema. `profile_ref` is format-validated (`[A-Z0-9][A-Z0-9._-]{0,31}`) but has no approved registry value. A version becomes effective only when P1–P3 and the §5.2 sign-offs are attached; backend records, and does not approve, numerical values.
3. **P4 projection** — Backend will treat elapsed seconds as the source value, derive the day with `floor(elapsed/86,400)+1`, and **not** cap it at 21. "Expected hatch period reached — 21 days elapsed" is a presentation string derived from elapsed ≥ 1,814,400 s. It must not write `status = 'Completed'`, claim a physical Stop, or imply hatching. Where the original confirmed Start is unavailable (legacy `start_date` is app save time), the day remains unknown rather than derived.
4. **Approval capture** — Proposed documentation fields, pending authorization: `profile_id`, `profile_version`, `source_commit`, `source_sha256`, `status` (`draft` / `pending` / `approved`), `approver_name`, `approver_role`, `approved_at`, `evidence_ref`, `scope`. No table or migration is created by this response.
5. **Adviser approval** — Still undocumented. If the capstone requires adviser sign-off on numerical setpoints, it must be supplied and linked; backend cannot substitute for it.
6. **No changes made** — No migration, Edge Function, table, policy, or seed change; no profile row is inserted or updated; ingestion stays fail-closed.

### 9.3 Backend asks back to Kath

- Confirm whether the profile identity should be recorded as a documentation-only manifest for now, or held until the profile schema is separately authorized.
- Confirm that P4 display wording applies only where the original confirmed Start is trustworthy, with "unknown day" otherwise.
- Keep the "HATCHED" completion label out of any Flutter change until P4 wording is implemented under the normal change process.

