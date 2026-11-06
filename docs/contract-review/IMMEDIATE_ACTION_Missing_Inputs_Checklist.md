# Immediate action — one matching implementation packet

**Prepared:** 2026-11-01 · **Coordinator/backend:** Mary Charlyn (Cha/Mary, one person)
**State:** user reports the message sent to Ally and Kath (2026-11-01);
Kath's acknowledgment and Q06/Q07 discussion response revision 3 received through
Mary; Ally's acknowledgment/new matching packet and Kath's source/decoder findings
PENDING. No agent external send. Exact reply
and scope are recorded in the [existing ledger](CONTRACT-FREEZE-01_Team_Decisions.md).

**Goal:** collect the missing source/interface artifacts, then get scoped compatibility
answers against the same bytes. This is not another audit, protocol selection,
approval register, task completion report or permission to implement/deploy.

## Keep existing answers

- Selected architecture stays autonomous Uno + RTC ↔ HC-05 Classic SPP ↔ Android
  bridge ↔ authorized Supabase. USB is diagnostic; do not reopen Bluetooth vs Wi-Fi.
- Mary's M01–M08 positions and Ally's thirteen positions/four result conditions are
  already recorded. Do not request those answers again.
- Kath's manual-result **0.2 delta review is ACCEPT at review/model scope**. Q05
  needs no repeat review unless a concrete new finding/material change arises.
- Result recording alone does not set Completed/end_date, release the Active guard,
  imply physical Stop or authorize another batch. No automatic physical Start replay.
- Firmware/build/model reports are received evidence, not the underlying source,
  fixtures/build logs or physical verification. Missing delivery is not proof that
  another owner never did the work.

The [existing decision ledger](CONTRACT-FREEZE-01_Team_Decisions.md) remains the
single place to record actual answers. Use its latest dated receipts rather than
older historical pending statements. The [Q01–Q14 workqueue](../integration/remaining-task-workqueue/REMAINING_DECISIONS_ALL_OWNERS.md)
provides detailed requirements; its older Q05 request is superseded by the
[31 October 0.2 acceptance receipt](../integration/cha-execution/KATH_02_DELTA_ACCEPT_RECEIPT.md).

## 1. Ally — send existing missing artifacts (D01–D05; Q01–Q04/Q08)

- [ ] Supply one source export/patch, complete literal interface catalog and SHA-256
  manifest. Include branch/commit, uncommitted changes and toolchain/library versions.
  Explicitly state whether numeric START supersedes START_BATCH/CONFIRM or neither
  is selected. Report flashed identity UNKNOWN unless independently established.
- [ ] Attach matching raw request/response fixtures, build/avr-size logs and the
  previously reported model/test artifacts. Link existing files; do not redo a general audit.
- [ ] For START, STOP and read-only STATUS/recovery, specify actual support or
  NOT IMPLEMENTED, correlation fields, duplicate/changed-content/wrong-batch behavior,
  and boot/reset/selection/blank-corrupt-full EEPROM/sensor-recovery output transitions.
- [ ] State exact batch/command/event/sample/boot identity widths and persistence,
  timestamp validity and original-outcome retention limits. Missing fields stay missing;
  phone receipt cannot become controller acquisition time or original Start.
- [ ] Supply directional RX/TX maxima including delimiter rules, worst-case fixtures,
  memory/service-budget evidence and current controller-auth/journal limitations.
  Report measured cadence separately from configured intervals; do not invent measurements.
- [ ] Give the outstanding exact provisional schema/example disposition, identifying
  input hashes and concrete incompatibilities; a CHANGE/BLOCKED response is valid.

**Acceptance:** delivered files match their hashes and each claimed capability has
a matching literal fixture/log or an explicit unsupported/evidence-missing label.
This does not establish feasibility approval, security or physical readiness.

## 2. Kath — reply only on new selected bytes and remaining client choices

**2 Nov Q06/Q07 update:** [revision-3 response receipt](Q06_Q07_Kath_Response_Rev3_Receipt_2026-11-02.md)
records recommended-design ACCEPT S3/S4/E4/E5 and BLOCKED S1/S2/E1/E2/E3,
not new personal approvals or implementation consent. Intended phone Infinix Smart
8 is identified; recover prior detailed specs, do not choose a phone again.
Mary provider/session/binding policy and Kath native/SDK/device evidence are the
next coordination work. Exact source/decoder compatibility remains pending Ally.

**Acknowledgment received through Mary, recorded 2026-11-01:** Kath awaits Ally's
matching source/catalog/hash packet before confirming decoder compatibility and
will supply scoped findings afterward. Android transport, storage and enrollment/
session choices remain for coordination with Mary; no compatibility pass is
claimed. Manual-result 0.2 ACCEPT is unchanged. Do not request this acknowledgment
again or treat it as completion of any item below.

- [ ] Identify Flutter branch/commit/patch and decoder/framer fixtures corresponding
  to Ally's delivered packet. Return ACCEPT/CHANGE/BLOCKED for each interface family;
  if the packet is absent, identify that dependency rather than invent compatibility.
- [ ] Report actual Android Classic SPP transport status, permissions, target device
  and tested build scope. Separate source/mock checks from Android-device results.
- [ ] Resolve remaining Q06 storage/device/package/key/transaction choices and Q07
  bootstrap/session/refresh/logout/replacement behavior with Mary. Existing package
  versions, API-30 floor and activation expiry are proposals, not adopted defaults.
- [ ] Identify durable intent/dispatch/evidence/outbox and receipt-commit behavior,
  including local-save failure, restart and unknown Start outcome. Cloud retries
  must never dispatch a hardware Start.

**Acceptance:** exact reviewed input hashes, capability gaps and concrete client
choices are attributable. Previously accepted 0.2 result semantics are carried
forward, not resubmitted for a generic review. Live integration stays unverified.

## 3. Mary — map the packet and record scoped decisions

**Latest 2 Nov correction — use for current access review:**
[technical companion 0.2](Q07_Provider_Session_Binding_Policy_0.2.md) and
[simple proposal 0.2](Q07_Plain_Language_Access_Proposal_0.2.md) implement the supplied
planning direction: self-service signup, once-verified email, password login,
one-time team account-to-record assignment, no phone restriction or ordinary
logout/login/password-reset reapproval. Older 0.1 requests below are historical
where contrary. This is a documentation revision; code/security tests/permission
and final review remain separate, with no new task-card completion.

**2 Nov next backend action prepared:** [Q07 technical policy 0.1](Q07_Provider_Session_Binding_Policy_0.1.md)
defines P1–P6 provider/session/binding recommendations and conditional tests, using
the existing plain-language proposal and Kath revision-3 response. Send its scoped
message for concrete review; actual personal/joint choices and execution permission
are still pending. Preserve the existing occupied batch without connecting/registering it.

**Q06/Q07 coordination prepared:** use the
[focused storage/enrollment/session proposal 0.1](Q06_Q07_Kath_Mary_Decision_Proposal_0.1.md)
and its copy/paste message for concrete S1–S4/E1–E5 replies. Proposal preparation
does not check off joint agreement or authorize implementation.

**Independent preparation performed 2026-11-01:** see
[Mary's backend mapping, compatibility gaps and conditional security tests](MARY_Backend_Preparation_2026-11-01.md).
Thirteen local inputs are fingerprinted; the current-checkout field comparison is
prepared. The full items below remain unchecked because new-packet acceptance,
actual member decisions and implementation prerequisites are still outstanding.

- [ ] Verify delivered file hashes; preserve original files and provenance.
- [ ] Compare actual source fields with DB-02: device/batch/command/event/sample,
  source time/validity, original manifest/quantity and lossless session mapping.
  Mark any missing or incompatible field BLOCKED; do not alias IDs or invent time.
- [ ] Record ACCEPT/CHANGE/BLOCKED in the existing ledger with responder, date,
  exact revision/hash, scope and remaining dependency. A source packet may be
  inspected without being approved for ingestion.
- [ ] Agree concrete Q06/Q07 client/cloud boundaries with Kath. Preserve legacy
  direct-table compatibility until a separately reviewed migration plan exists.
- [ ] Prepare the next isolated authorization/security slice only after its own
  prerequisites are satisfied; request explicit operation-specific permission
  before accounts, schema/RLS/RPC changes or deployment. Do not apply drafts wholesale.

**Acceptance:** a field-by-field mapping and attributable scoped answers exist;
unresolved items keep their gates closed. Neither collection nor agreement alone
completes DB-IMP-01, INT-IMP-01 or physical acceptance tasks.

## Copy/paste request — send to Ally and Kath

> Ally and Kath: please help close the missing implementation inputs, not repeat
> our general audits. Ally, please send one matching source/patch/catalog/hash
> packet with literal fixtures and existing raw build/test evidence. State the
> START vs START_BATCH/CONFIRM supersession and actual STOP/recovery/identity/time/
> frame-limit/auth/retention support, including what is unimplemented. Kath, once
> those exact bytes are available, confirm decoder compatibility and the remaining
> Android transport, durable storage and enrollment/session choices with me.
> Your manual-result 0.2 delta ACCEPT is already recorded; no repeat Q05 review is
> requested. Reply using the template below. No credentials, new general audit,
> deployment, database changes or hardware operations are requested. If an artifact
> is unavailable, name its owner and next delivery time instead of claiming a pass.

```text
Responder / role:
Date:
Decision reference: D__ / Q__
Input source/catalog/schema revision and SHA-256:
Disposition: ACCEPT / CHANGE / BLOCKED
Exact supported scope or replacement / missing artifact:
Evidence: file + hash + command/log + actual result + limitation
Implementation / device / physical verification: NOT RUN unless evidenced
Next owner and delivery time (if blocked):
```

## Exit check — before choosing the next implementation slice

- [ ] One identified source/catalog revision with matching artifact hashes is available.
- [ ] Ally, Kath and Mary have attributable answers against those same bytes for
  the relevant capabilities; incompatible or unsupported operations remain disabled.
- [ ] Every unresolved source/auth/storage/time/profile/retention requirement has
  an owner and an explicit effect on the proposed slice; a packet is not a blanket freeze.
- [ ] Next slice has concrete acceptance tests and separately scoped authorization
  where required. Production and powered hardware remain excluded.

Existing Q12 phase-A read-only approval is not reopened here. Its recorded attempt
is Partial/Blocked; a remote retry needs the specific approval described in
[Q12 status](../integration/cha-execution/q12-phase-a-status.json). It grants no
later mutation/deployment phase. Formal amendment adoption, distribution, profile
approval, electrical clearance and research acceptance remain separate gates.

**Next action for Mary:** await the requested matching artifacts/replies, then
verify them and retain actual scoped answers in the existing ledger. User-reported
message delivery and Kath's user-relayed acknowledgment are recorded above;
Q06/Q07 coordination may proceed without claiming source compatibility. No
technical acceptance, task-status change or execution permission is inferred.
