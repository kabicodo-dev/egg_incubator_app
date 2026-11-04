# ARCH-05 — controlled K06 architecture amendment record

**Record revision:** 1.0-review · **Date:** 2026-10-30.
**Owner:** Mary Charlyn (Cha/Mary), documentation/backend coordination.
**Disposition:** RECORDED IN REPOSITORY; NOT YET ADOPTED (user confirmed).
**Task:** OCT26:ARCH-05 remains Partial until its outstanding formal adoption
gate is actually evidenced. No implementation, firmware, database or safety
authorization is created by this document.

## 1. Authoritative inputs and preservation

The actual user-supplied documents were located in Downloads, read, and copied
byte-identically into this repository. This corrects earlier working notes that
the standalone v0.3 baseline was unavailable. Their source approval labels and
historical statuses are preserved, not silently rewritten.

- [K06 v0.3 — historical baseline](../SmartHatch_K06_Consolidated_17_Decision_Contract_v0.3.md).
- [K06 v0.4 — supplied architecture amendment draft](../SmartHatch_K06_Consolidated_17_Decision_Contract_v0.4_Bluetooth_Android_Bridge.md).
- Exact raw byte fingerprints and source paths: `ARCH-05_source_manifest.json`.

No standalone v0.5 source file was located; the portal attributes some design
decisions to a v0.5 change-control table. Do not fabricate a v0.5 document or infer
its formal adoption. The located v0.4 source independently records the same four
architecture directions and their reported design approval, so they are not
dependent on reconstructing v0.5 bytes.

This record indexes the supplied amendment; it does not approve all seventeen
technical clauses or replace later scoped D01–D06 decisions. It is not an
alternative protocol or a wholesale new K06 revision.

## 2. Existing architecture directions being formally recorded

Source: supplied v0.4 change-control table :12–15, architecture :23–44, INT-02
:74–86 and INT-06 :130–142. Approval is reported by Kath from adviser/team, not
new signatures collected by this agent.

| Existing task | Direction already recorded | Evidence level |
|---|---|---|
| ARCH-01 | HC-05 Bluetooth Classic SPP selected; exact physical module/firmware still needs identification | Reported design approval, not hardware proof |
| ARCH-02 | No requirement to upload through the phone while it is away/unavailable | Reported product/design choice, not a tested bridge guarantee |
| ARCH-03 | Uno ↔ HC-05 ↔ Flutter Android bridge ↔ authorized Supabase through phone internet | Reported design approval; RTC remains intended timekeeping, not verified installed hardware |
| ARCH-04 | Uno retains independent local regulation and safety authority | Reported design approval, physical fail-safe verification remains pending |

The selected farmer-facing route is NOT ESP8266 Wi-Fi, BLE, Windows-as-controller
or an automatic USB replacement. USB remains explicitly labelled diagnostic/lab
contingency under the source's scope limitations. Any changed demonstration route
needs explicit review; no module purchase/wiring instruction is issued here.

## 3. Precisely what is amended, and what is not

Supplied v0.4 explicitly supersedes v0.3 ONLY in communication architecture and
related transport guidance (:4,46–52). It preserves the same 17 decision IDs.

| K06 ID | Record effect | Technical implementation/verification boundary |
|---|---|---|
| INT-01 | HC-05/Android replaces ESP8266 primary transport; retain versioned logical JSON direction | No selection of START vs START_BATCH/CONFIRM, parser schema, widths or baud from this record |
| INT-02 | Android phone-dependent authorized cloud bridge, no phone-away upload requirement | No promise of background/locked-screen operation or offline telemetry backfill |
| INT-03 | Incubator-only farmer scope and actual-vs-target separation retained | No deletion of brooder history or claims of validated sensor values |
| INT-04 | Start/ACK/state and safe existing-batch recovery boundaries retained under Bluetooth | No new automatic-resume or fresh-batch-on-boot permission; unresolved transition/output behavior remains gated |
| INT-05 | Source time, phone/server receipt, batch association/freshness retained under Android relay | No numeric freshness threshold, RTC model, outage or clock-invalid admission rule chosen |
| INT-06 | Uno local authority retained; phone/internet not required for immediate local control | No evidence of actual safe actuator behavior or qualified electrical clearance inferred |
| INT-07 | Evidence-limited demo/research claims retained | Historical October 28 schedule not a renewed commitment; no invented hatch results |
| CHA-01 | One designated authorized Android installation and constrained relay replace publisher assumptions | HC-05 pairing is neither cloud authorization nor controller command authority |
| CHA-02 | Manual bounded farmer counts and truthful persistence retained | Later result/lifecycle separation is tracked in D06/M01–M07; old words do not enable Completed or require fabricated Stop |
| CHA-03 | Preserve original intent/unknown outcome across Bluetooth/phone/cloud failure | No blind physical Start replay |
| CHA-04 | Original approved local profile/settings identity retained | No numeric species targets approved; cloud save is not physical profile application |
| CHA-05 | Fresh eggs only for NEW batches; prior SmartHatch History retained | No transferred/previous-incubation-days flow or historical data deletion |
| CHA-06 | Day 1 at substantiated Start; Day 2 after 24 elapsed hours, source-time provenance retained | Exact invalid-clock/outage implementation and verified persistence remain separate gates |
| CHA-07 | Original controller/batch/sample association retained under Android relay | No relabelling delayed batch A readings as current batch B or claiming source IDs that do not exist |
| CHA-08 | Physical state, Bluetooth, internet/sync and sensor validity/freshness separated | No approved numeric threshold or always-on live feed; non-live values must be labelled |
| CHA-09 | Original Start identity/evidence and read-only reconciliation retained | No Start timestamp repaired from reconnect/upload or actual Running inferred from old cloud Active |
| HW-01 | HC-05/RTC/Uno identification and safe Android-link verification replace ESP8266 test assumption | No wiring, flashing, energized-load/egg test authorized by architecture approval |

No protocol, database migration, RLS change, RPC activation, protected-data
enrollment, credential provisioning, physical admission, journal release, profile
approval, safety clearance or research outcome is adopted as implemented here.

## 4. Precedence and later scoped work

Historical v0.3 remains readable and byte-preserved. Supplied v0.4 controls only
its expressly changed architecture guidance as a reported selected design; its
pending formal adoption label is not removed by this record. Later actual
personal/shared dispositions remain in
[CONTRACT-FREEZE-01](CONTRACT-FREEZE-01_Team_Decisions.md).

Mary's confirmed M01–M07 are personal positions, not a second coordinator vote.
The manual-result 0.1 proposal, actual firmware/catalog selection, Kath package/
SDK/key/session proposals and final lifecycle/admission policy remain review
inputs. No former missing-file claim overrides supplied or another-branch work.

Source-proposed automatic recovery language is not permission to create a new
batch on blank/corrupt EEPROM or activate outputs unexpectedly. Latest selected
source/output semantics and qualified physical verification are still required.

## 5. Actual formal adoption capture — no invented approvals

| Required evidence | Current record |
|---|---|
| Source v0.3 and supplied v0.4 revision identification | Available, repository copies and raw fingerprints recorded |
| ARCH-01–04 design decisions | Reported approved by Kath from adviser/team; preserved as attributed design evidence |
| Mary review of this exact controlled record | User authorized preparation/completion effort; selected Not yet adopted when asked about actual amendment adoption; no exact-text adoption inferred |
| Team review/adoption of the formal amended K06 baseline | NOT YET ADOPTED — user explicitly selected this answer on 2026-10-30; cannot infer from architecture principles or other file reviews |
| Repository placement and static verification | See companion source manifest and ARCH-05 verification output |
| ARCH-06 circulation to all required people/sessions | Separate task; Kath/Ally delivery reported, complete distribution/acknowledgment not established |

The source v0.4 explicitly states :16 pending team review/adoption/repository
placement, :316 final team-reviewed contract before calling adopted/distributed,
and :318 ARCH-05 draft prepared. A current user request to work until completion
authorizes the effort; it is not another person's adoption or a retrospective
signature. Existing actual adoption evidence may close this without another
general architecture review. Only collect the missing exact approval record.

**Actual follow-up answer:** The user selected “Not yet adopted” to the focused
question about formal amendment adoption. This confirms the remaining gate, not
permission to mark the task complete. Do not repeatedly ask whether adoption
already exists; the next action is the actual scoped amendment review/adoption.

## 6. Scope of potential completion

After actual adoption is established, ARCH-05 can be Completed for the formal
documentary amendment only. It must not complete ARCH-06 or any source, app,
cloud/security, freshness, physical or pilot task. No full task status is changed
until that gate is evidenced. If evidence is absent, the honest outcome is a
verified repository record with formal adoption still pending, not a fabricated
Completed badge.
