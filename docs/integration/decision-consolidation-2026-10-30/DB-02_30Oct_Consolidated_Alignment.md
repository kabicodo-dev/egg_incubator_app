# D01–D06 consolidated update and DB-02 alignment amendment

**Date:** 2026-10-30 · **Owner:** Mary Charlyn (Cha/Mary, same person as confirmed in this session).
**Disposition:** documentation-only candidate amendment; no blanket sign-off,
selected protocol, implementation authorization or new task completion.

The existing [decision ledger](CONTRACT-FREEZE-01_Team_Decisions.md) remains the
single answer register. This is its focused closure/amendment companion, not a
new protocol or another general audit. Existing v1.3 and DB-02 0.1 bytes are
preserved as review inputs; their open fields and contradictory completion rule
are not current approvals. See the manifest in the accompanying circulation ZIP.

## 1. Received answers — do not ask for them again

| Input | What is received | Evidence level |
|---|---|---|
| Mary's D04/D06 backend position | Scoped non-anonymous protected-cloud enrollment; null retention release; immutable retry/content conflict, lossless real DB names; independent-result change request | Actual personal answers recorded locally; not joint freeze |
| User's latest consolidation request | Supports deliberate Start, no automatic physical replay, durable original evidence, idempotent sync, controlled enrollment and distinct ACK/state/cloud/receipt dimensions | Design-principle support only; no exact protocol/code authorization or inferred Kath signature |
| Ally personal-response summary pasted by user | 13 positions dispositioned; firmware capability limitations; source 7106ebfe01d037c95766cd51c43b43fa02f92b922fc5a180770fd27b3822c5ec; reported build and JCS example reproduction | Attributed report, not artifact validation; individual 13-item list not in pasted summary |
| Ally-2026-10-30-Packet-Review.md | Review of 34 Markdown-only ZIP files; source/build identity, current limitations, null/no synthetic release, conditional support for manual results without Stop | Supplied review of another packet; underlying ZIP, source/fixtures/logs/model not available here |
| ORIGINAL-C-02-Flutter-Compatibility-Review.md | REQUEST CHANGE: current reviewed app has legacy actuator protocol, parser mismatches, cloud-first Started display, no durable batch intent/state machine; reports 63 tests passed | External working-tree review based on c7a26cf plus local changes, not independently rerun here and not necessarily this branch |

Ally's full four completion conditions are cited at response :235–250 by the
packet reviewer but not reproduced verbatim in the attached reviews. What is
explicitly received: result saving need not require Stop; completion must not
itself clear the single-Active guard or authorize another physical batch. Do not
invent or claim acceptance of the other conditions. Request the existing text,
not a fresh review.

The prior absence of an explicit Ally reply in the earlier 26-report export was
accurate for that snapshot only. It no longer describes the current answer state.
Missing files on a different branch are availability findings, not proof a task
was never completed. Cha/Mary are one respondent; historical v1.3 wording naming
four participants does not create a second independent approval.

## 2. Common revision and boot behavior — unresolved, not silently selected

There are at least three candidate descriptions: earlier v1.3 batch-aware
v/t/cid/bid/seq; earlier reported START_BATCH with confirm:CONFIRM and related
maintenance commands; Ally's numeric-ID START/ACK/RUNNING without confirm.
Neither an example nor newer report date establishes supersession. No translation
or alias is adopted. **Ally must identify which source/catalog supersedes which;
Kath and Mary then accept the same delivered bytes.** Flashed identity stays UNKNOWN.

Deliver the existing source export/patch, complete literal catalog and raw
request/response fixtures, build/toolchain logs and reported Dart handshake model.
Do not recreate work merely because the Markdown ZIP omitted it. Development
HEAD alone does not identify an uncommitted parser patch; pin source SHA as well.

Ally's boot/reset table must cover: valid/blank/corrupt/full EEPROM; boot, RESET,
species selection, reconnect and valid sensor recovery. For each, identify
(a) batch creation/identity changes, (b) reported lifecycle/RUNNING emission,
(c) actual control/output-enable path, and (d) required deliberate authorization.
Tests must inspect output activation after valid sensor recovery, not merely
absence of RUNNING or activeBatchId==0. Preserving autonomous control of an
existing legitimately active batch is not permission to create a fresh batch.
Exact recovery behavior remains a shared choice; powered verification is gated.

## 3. DB-02 amendment — separate result, lifecycle and physical admission

**Candidate decision for Mary + Kath, with Ally's exact conditions to attach.**
This amendment records the requested direction; it is not a replacement executable
request schema or SQL migration. DB-02 0.1 §3's applied-Stop prerequisite and its
required stopped_event_id remain preserved historical candidate bytes and are
explicitly **not aligned** with this change. Local candidate validators/fixtures
still implement the old rule and must not be represented as the amended feature.

### A. Manual result recording

- A farmer may record a manual integer count 0..original positive egg_quantity
  without physical Stop evidence. Record is farmer-origin, not a controller event.
- Preserve original batch/installation/action identity and immutable content;
  changed content under that identity conflicts. No new identity to hide an edit.
- Unknown action time remains unknown with its provenance; phone/server receipt
  is not substituted for controller occurrence time.
- Proposed local UX: durable local draft/saved-pending-sync and authenticated
  server result receipt are separate. If original batch/quantity cannot yet be
  validated, retain the draft/evidence as pending, not a fabricated session mapping
  or validated final result. Kath must accept the concrete transaction/UX rules.
- Result storage itself neither needs nor invents Stop, does not dispatch a command,
  and does not automatically mutate session status to Completed.

### B. Cloud lifecycle projection

**Conservative proposed closure:** persist an accepted result independently while
leaving the existing Active lifecycle guard intact. Treat later lifecycle
finalization as a separate explicit reviewed projection decision. This is a
proposal, not a recorded joint choice. An alternative immediate Completed
projection requires a separate effective occupancy/admission guard first; it must
not be enabled merely by changing status or dropping the existing partial index.
Owners must choose the exact finalization prerequisites and truthful end-time rule.

Reuse existing egg_quantity/eggs_hatched names and bigint session mapping; no
new hatchability percentage column or destructive schema rewrite is proposed.
Where pending result storage cannot be represented by the old schema without
changing lifecycle, design the minimal additive result representation before SQL.
No concrete new table, event name, field deletion or status enum is approved here.

### C. Physical batch admission

Independent manual results, cloud Completed, HTTP success and ACK are **never**
permission for another physical batch. Admission must use the selected controller's
matching-batch state, unresolved original-command guard, local authorization and
agreed safety/recovery policy. Unknown outcome remains blocked pending read-only
recovery or separately authorized adjudication. Backend cannot command Start or
certify safe outputs; no Stop evidence may be synthesized to clear a cloud guard.

### D. Exact DB-02 edits after the choices are accepted

| Existing candidate | Required coordinated revision | Tests before closure |
|---|---|---|
| Conflict/Recovery §3 farmer_completed | Replace applied-Stop dependency with agreed original-manifest/count/result dependencies; define result receipt independently of lifecycle finalization | Result before Stop, missing Start/quantity, out-of-order sync, duplicate/conflicting count, truthful unknown time |
| Exact API request schema/examples/hash | Choose result entity/operation or event semantics; revise required fields, canonical preimage, receipt meaning and compatibility/version rejection together | Literal shared serialization/hash fixtures; old/new version mismatch fails closed; no guessed source adapter |
| Schema/Security §2.3 Active index/projection; event constraints | Preserve current index until agreed occupancy/lifecycle design is proven; minimal additive result storage and scoped transactional projections | Result alone cannot free Active guard or admit batch; concurrent result/finalization/new-batch race tests |
| Flutter intent/outbox/receipt and Started UI | Separate local result saved, uploaded/applied, lifecycle complete and controller state; cloud Start success cannot show MCU Running | Durable restart, lost reply, unrelated/late ACK, no-internet startup and cloud retry never dispatch Start |

The referenced canonical Start example reproduction is useful attributed evidence,
not selection of firmware, proof all preimages agree or an amended-result hash test.
Controller identity/epoch/sequence fields absent from numeric START cannot be
fabricated by the phone or server to satisfy the existing DB-02 source adapter.
Preserve API 4096-byte evidence ceiling as a cloud resource bound, not Uno output
size. serialLine[120] constrains RX application storage only. Keep directional
RX/TX/framing/service/stack budgets separate.

## 4. Only genuine open decisions and accountable closure

| Decision | Existing answer retained | Exact remaining deliverable / owner |
|---|---|---|
| D01 common revision | Source/build candidates and HC-05/Android direction supplied | Ally supersession + matching source/catalog/artifacts; Kath/Mary accept hashes, canonical remote/toolchain. Flashed board separately UNKNOWN |
| D02 STOP/read-only recovery/boot | No current STOP; inadequate STATUS; ACK not transition; no auto replay | Ally provides transition/output/recovery table and literal schemas; Kath/Mary accept mapping, fault/emergency/unknown-outcome rules |
| D02/D03 identities + bounds | Numeric batch, volatile ACK cache and memory constraints reported | Ally + Kath agree original Android IDs and durable dispatch; Ally proves wire/journal encoding, RX/TX/stack/service. Mary accepts lossless mapping. 8-byte command cannot fit 4-byte long |
| D04 bounded retention | Four-slot critical journal proposal; no telemetry/ACK archive; null/no HTTP release | Ally exact layout/full/corrupt/service policy, reconcile uint32 model vs 16-byte batch/8-byte command proposal; all accept explicit loss windows. Emergency safety action not blocked by full journal |
| D04 controller/cloud authorization | Controlled cloud enrollment direction; current controller auth absent | Ally controller keys/provision/revoke feasibility; Kath secure storage/setup/offline UX; Mary cloud registry/auth scope. App enrollment is not controller authentication |
| D05 profile/time/outage | Candidate values already supplied; unknown UTC preserved | Designated numerical approver (name still needed) accepts existing profile/version/capacity; Ally module/RTC facts; all choose invalid-clock/outage/elapsed/freshness policies. Do not request restatement of values |
| D06 result/lifecycle/admission | Mary independent-result request + Ally conditional support; immutable sync direction | Mary/Kath accept A/B/C choices above, attach Ally's existing four conditions, then version API/schema/local transactions/receipt fixtures and approved test scope |

No deadline or acceptance is invented for an owner. The named owners should return
only the requested artifact or exact choice; unresolved choices keep their
dependent implementation gate closed, not every historical answer marked missing.

## 5. Implementation and test closure — not authorization to execute

1. **HW-IMP-01, Ally:** selected source, strict parser, exact STOP/read-only
   recovery and no-new-batch/output-on-boot semantics. Existing build evidence
   retained; deliver raw fixtures/logs before independent reproduction. New tests
   cover selected maximum frames, duplicate/changed-content, reset/EEPROM/sensor
   recovery output paths. No flashing or powered test in this work.
2. **HW-IMP-02, Ally:** chosen identity-aware layout and bounded retained evidence;
   host-model checks of older uint32 layout do not prove revised layout. CRC,
   torn-write/full/corrupt tests and later separately cleared power-cut hardware
   checks. Static 266 B remaining is not a measured runtime stack guarantee.
3. **UI-IMP-01/02, Kath:** selected decoder/framer and durable pre-dispatch intent,
   atomic evidence/outbox and receipt transactions. Preserve existing reviews,
   components and 63 reported tests without calling them revised-wire acceptance.
   Test crash/lost ACK/reconnect/no internet, no automatic physical replay, truthful
   Started UI, result save and unresolved physical admission.
4. **DB-IMP-01, Mary:** once exact choices/permission exist, version-pinned adapter,
   amended result semantics and transactional idempotency/reconciliation. Test
   authorized/anonymous/other/revoked identities, conflicts, receipt validation,
   missing dependencies and concurrent occupancy guards in separately approved
   isolated scope. No schema/RLS/RPC activation now; main project untouched.
5. **INT-IMP-01, Cha/Mary coordinating:** one selected message→producer→consumer→
   persistence→test matrix. Host/mock checks labelled as such; actual transport
   and physical outputs require separate evidence, image identity and authorization.

## 6. Tracker reconciliation and circulation

Maintain independent columns: design position/approval, source implementation,
software tests (reported vs reproduced), physical verification. Do not erase
prior Cha database inventory/audit or Kath review work based on another checkout's
absence. Existing completed Cha reviews/design tasks remain completed within
their scope; no blanket downgrades or newly completed implementation tasks.
Retain two earlier report filing mismatches as provenance issues, not firmware
or RTC/module confirmation. Do not import another branch's status automatically.

Pilot remains **NO-GO**: no cleared empty-incubator run, verified flashed board or
egg loading. Profile sign-off, electrical clearance and physical checks stay gated.
No firmware, Flutter, SQL, Auth, database, deployment, flashing or powered test is
authorized by this consolidated record. No approval is inferred from a successful
documentation check.

**Circulation:** send the generated `SmartHatch_D01-D06_Review_Package.zip` with
its cover README and SHA-256 manifest. It contains the current v1.3 draft unchanged,
Mary's backend-position response, this update, existing ledger, DB-02 historical
candidates and the two supplied review attachments. v1.3's old PENDING sheet and
participant wording are historical draft text; the ledger carries current actual
answers. No competing edited v1.3 or implicit supersession is circulated.
Package generation is not actual delivery; recipient/date acknowledgments remain
unrecorded until the user sends it. ARCH-06 is not completed by preparing a ZIP.
