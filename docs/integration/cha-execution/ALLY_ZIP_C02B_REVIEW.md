# OCT26:C-02B — direct Ally packet review and response

**Owner:** Mary Charlyn (Cha/Mary) · **Date:** 2026-10-30 · **Priority:** P1.
**Task status:** Not started → Partial. The document comparison is performed;
the full task is not Completed because its explicit C-02A prerequisite is open.
No other owner's status or completed evidence is changed.

## Input and verification boundary

Received `01-20261030T075957Z-1-001.zip`, SHA-256
`d7657d191f11d18d4e87f803c1314719157bbe7b9f56a184b56e0cde31d15eb2`.
The archive contains 34 Markdown documents, not the referenced source, patch,
raw fixtures, executable models, validation scripts, build logs or ELF/HEX.
It was extracted into a fresh approved temporary directory, not the source tree.
All 34 files are indexed/hashed; this review closely reads the A-01 handoff,
interface, A-04 format options, personal response, parser-patch report and profile
approval section. Other documents are inventoried, not claimed independently
reproduced or all exhaustively reviewed. Reported checks are not new executions.

Comparison inputs: existing `docs/C02-provisional-communication-contract.md`,
the three preserved DB-02 candidates, current D01–D06 ledger/amendment and the
previously supplied Flutter compatibility review. External Flutter findings are
working-tree-specific, not an assertion that every branch is identical.

## Completed review output: provisional C-02 against A-01 findings

| A-01 finding | Provisional contract / current candidate comparison | Disposition |
|---|---|---|
| F-01 missing app-facing sketch in Ally branch | C-02 cannot choose a source from README. Our checkout has a different sketch; missing there is not missing globally. Numeric START candidate and START_BATCH/CONFIRM summary still diverge. | D01 source/supersession open; no baseline selected |
| F-02 USB app, no HC-05/Android SPP | Provisional §§2–3 still mention USB fallback/ESP8266. Those are historical, not current route approval; selected route stays Uno↔HC-05↔Android↔cloud. | Future contract revision required, not a transport implementation pass |
| F-03 no RTC | Provisional §4 proposes source measured_at/boot/sequence; latest response confirms these are absent. Do not promote millis/receipt to source UTC or fabricate Day 1. | Null/false time direction retained; elapsed/outage policy open |
| F-04 no independent fuse/watchdog | Provisional §§1, 5 disclaim safety/physical evidence; physical status VERIFIED cannot be satisfied by relay latch bits. | No safety clearance or independent output feedback inferred |
| F-05 low SRAM | Provisional ID bounds up to 64 chars are proposals, not feasible frame limits. Later parser build reports 266 B remaining. | D03 directional maxima, stack/service and journal encoding required |
| F-06 no physical validation | Provisional synthetic VERIFIED examples test structure only; newer RUNNING is reported controller/latch confirmation. | Source report ≠ physical switching proof; physical tests remain gated |
| F-07 stuck-but-plausible DHT | Provisional validity is reported plausibility, not calibration/authentication. Current pair-valid flag does not supply per-channel provenance or stuck detection. | Keep separate validity/freshness/calibration/safety labels |
| F-08 running overloaded by command | START running is post-confirmation in reports; TURN_NOW running is in-flight. Generic running→batch RUNNING is unsafe. | Must branch on cmd for this candidate; final wire decision not selected |
| F-09 divergent variants | Provisional nested payload/command_id, numeric cmd/id, legacy actuator and DB-02 HW02 adapter shapes are not interchangeable even when v:1. | No permissive fallback or silent alias mapping |
| F-10 nested older copy | An older compilable sketch is only a reference unless jointly selected. | Preserve history; require one matching source/catalog hash |

## Direct responses to Ally's ten A-03 questions

1. **Baseline:** no shared source selected. Keep the reported original `3721bce0…`
   and parser-patched `7106ebfe…` distinct. Ally must deliver existing actual
   source/patch/catalog and state whether START supersedes START_BATCH/CONFIRM.
2. **Family:** HC-05 Android remains selected architecture, not USB farmer
   fallback. Neither legacy actuator-only Flutter nor numeric NDJSON v1 is
   accepted as the final cross-component schema. DB-02 source acceptance stays off.
3. **RUNNING:** for the supplied numeric candidate, interpret START and TURN_NOW
   separately; neither ACK nor a GPIO latch is independent physical feedback.
   This is a review requirement, not selecting a replacement field/type.
4. **Sensor range:** do not choose −20..60 or −20..80 as a biological/safety range
   merely to make parsers agree. Preserve mismatch and source provenance; Ally
   and Kath must accept a version-specific parser policy. Approved incubation
   targets are a different numerical-profile approval.
5. **Identities:** no numeric command/batch→UUID/session cast or phone-invented
   source sequence. Android-origin durable identities are a design direction,
   not current implementation. Preserve lossless bigint session mapping.
6. **States:** cloud Active, command ACK, controller-observed state, independent
   physical feedback, farmer results and synchronization receipts stay distinct.
7. **Day:** trustworthy original Start + elapsed reference are prerequisites.
   Unknown UTC remains null; phone timestamps may be retained separately as phone
   provenance, never placed in source occurred_at to fake controller time.
8. **Evidence:** same source hash/patch/catalog and literal fixtures/build logs
   for software review; actual flashed identity, transport and physical output
   evidence only in separately authorized integration/physical tests.
9. **Reconnect:** no automatic Start replay. Fresh telemetry/RUNNING alone is
   insufficient if uncorrelated or missing original batch/outcome evidence;
   retain unresolved outcome until agreed read-only recovery/adjudication.
10. **Location:** existing CONTRACT-FREEZE-01 ledger and DB-02 consolidated
    amendment carry choices; this report records the attributable C-02B comparison.
    No second competing decision register is created.

## A-04 options: backend review, not a unilateral selection

- **A: numeric v1 unchanged:** does not meet current trusted batch/sample source
  association requirements. Never attach late readings to latest Active by guess.
- **B: versioned provenance:** can address missing fields only after actual
  feasibility, exact schema/identity/time policy and all-owner acceptance. No
  field/size/version is implemented or selected by this review.
- **C: app envelope:** can truthfully add phone receipt/local capture metadata,
  but cannot repair missing controller batch/sample identity, original time or
  authenticate the source. Quarantine/reduced guarantees need explicit approval.

The literal `v:1` is not a common contract identifier across these incompatible
families. A-04's local 'frozen implemented v1' is not joint protocol approval.

## Ally's thirteen dispositions — full text now received

| Position | Disposition (primary) | Scope |
|---|---|---|
| D02-1 | BLOCKED | Design blocked / shape CHANGE; exact identity/byte budget not selected |
| D02-2 | CHANGE | STOP absent; six exact semantic choices supplied |
| D02-3 | ACCEPT | ACK/state/cloud distinction; no independent physical feedback |
| D02-4 | CHANGE | Extend STATUS with agreed recovery data; not invented GET_STATE |
| D02-5 | BLOCKED | Four-slot journal vs explicit narrower loss guarantee remains choice |
| D02-6 | CHANGE | Exact directional bounds required; HTTP ceiling not device size |
| D04-1 | BLOCKED | Controller key/provision/revoke/crypto feasibility absent |
| D04-2 | CHANGE | Bounded critical retention, not telemetry/ACK archive |
| D04-3 | ACCEPT | Full/corrupt blocks new Start, not emergency safety action; unimplemented |
| D04-4 | ACCEPT | retention_ack:null, no HTTP/phone-synthesized release |
| D04-5 | ACCEPT | Offline revocation/clock limits; do not reinterpret phone time as source UTC |
| D06-1 | ACCEPT | Real DB names, bigint, immutable retry/content conflict |
| D06-2 | ACCEPT WITH CONDITIONS | Manual result independent of Stop, subject to four conditions below |

Primary count: 6 ACCEPT (one conditional), 4 CHANGE, 3 BLOCKED. D02-1's secondary
shape CHANGE is retained, not counted as another position.

Exact conditions in the received response :238–245:
1. Completion never commands, implies or records a physical Stop.
2. Completion does not by itself clear the single-Active guard or authorize
   another hardware batch; admission is a separate lifecycle decision.
3. Unknown original completion time stays NULL, not replaced by server receipt.
4. Counts remain manual integers 0..original egg_quantity, not sensor-derived.

These agree with Mary's requested separation and the conservative DB-02 amendment
direction. Exact storage/lifecycle finalization/admission rules and Kath's
transaction/UX acceptance are still open. No removal of stopped_event_id from
code/schema/fixtures is authorized or performed.

## Findings not to propagate from the supplied documents

- A 120-byte RX application buffer does not constrain all outgoing TX frames;
  a 4096-byte HTTP ceiling is not a required Uno frame size.
- AVR long is four bytes; an eight-byte command identity does not fit it unchanged.
- The 64-byte AVR software RX ring is not a hardware whole-frame maximum.
- Same-ID cached ACK replay is not changed-content detection; no fingerprint
  exists in the described RAM cache. It is not durable idempotency across reboot.
- No RUNNING frame or activeBatchId==0 does not prove outputs stay off after
  sensor recovery. Earlier reset/selection/blank-EEPROM control reports still
  require the selected source's transition/output reconciliation.
- Existing profile values are now directly supplied in the profile document
  §8.5, **NOT APPROVED**. Existing Day-7/stage wording in reports does not reopen
  selected Day-1 architecture; numerical approval and compatibility remain gates.

## Actual work, acceptance and remaining tasks

Performed: safe ZIP inventory/extraction; all Markdown file hashes; direct
13-position/four-condition transcription; F-01..F-10 comparison; ten concrete
backend responses; ledger/amendment receipt corrections; Partial task/report
publication. Companion validation checks document integrity and exact source
excerpts only. No Arduino/Flutter build or reported host/JCS test was rerun.

**OCT26:C-02B remains Partial:** its explicit dependencies are OCT26:A-01 and
OCT26:C-02A. A-01's report and A-03 handoff are now delivered here; C-02A still
requires schema reviewed by Ally and Kath, with validated sample messages. The
reviews identify incompatibilities; they do not establish that both reviewed
the exact provisional schema/example bytes. Do not infer that dependency passed.

C-02C explicitly waits for approval/final fields. ORIGINAL:C-02, DB-IMP-01,
secure ingestion, installation authorization, time/batch freshness and integration
still lack their exact criteria. Numerical profile database verification is not
closed by an unsigned source profile. No remaining full task is newly completed.

Cha totals after this progress update: **7 Completed, 8 Partial, 26 Not started,
1 Superseded**; still 34 unfinished nonsuperseded records. The earlier remaining
queue assessment is historical; C-02B now has actual input and review progress,
not an ongoing assertion that the handoff is absent.
