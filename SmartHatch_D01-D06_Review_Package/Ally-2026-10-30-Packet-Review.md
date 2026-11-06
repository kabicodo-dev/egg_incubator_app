# Review of Ally's 30 October packet

Date: 2026-10-30. Scope: document review only; no implementation or approval.

## Input and verification limits

Archive: `C:\Users\ACER\Downloads\01-20261030T071442Z-1-001.zip`.
The archive contains **34 Markdown files only**. It does not include the `.ino`
source exports, patches, host-model source, Dart handshake model, raw captures,
build logs, ELF/HEX artifacts or validation scripts referenced by the reports.
The Markdown files were extracted to approved temporary review storage, not
overlaid on the application source.

This review examines the decision response, START/protocol reports, implementation
reports, profile record, tracker plan and pilot gate, with status cross-checks
across the packet. Reported tests/builds are attributed to Ally; they were not
independently reproduced. The local Flutter review remains a separate working-tree
review, not a review of Ally's branch or its unavailable source artifacts.

## Outcome

**Substantial answers are already supplied. Update the existing decision ledger;
do not request a fresh general audit or leave every row as "no reply supplied".**
However, an answer that says a capability is absent is not a completed capability.
The packet is not a same-revision, jointly approved integration contract.

## D01–D06 crosswalk

| Decision | Answer/evidence already supplied | Remaining closure |
|---|---|---|
| D01 baseline | `k03b02_message_to_ally_cha_2026-10-30.md:40–54` identifies commit `80971f9…`, original source SHA-256 `3721bce0…`, build artifacts and no flashed image. `hwimp01_source_patch_start_stop_status.md:150–154` identifies the later parser-patched source `7106ebfe…`. HC-05/Android architecture is retained in `oct26_a04_final_ndjson_format_decision.md:23–26`. | Select original or patched candidate and provide the matching actual source/artifacts. Do not confuse a development baseline with a verified flashed board. |
| D02 lifecycle/identity/recovery | `ally_d02_d04_d06_response.md:58–158` explicitly answers START, absent STOP, inadequate STATUS, missing independent identities, volatile ACK cache and journal/loss alternatives. `a02_ndjson_serial_protocol.md:77–131` supplies START ACK/RUNNING examples. | Exact STOP semantics, final IDs/envelope, complete read-only recovery and retained-evidence policy remain unresolved. |
| D03 bounds/build | `hwimp01_source_patch_start_stop_status.md:118–154` reports genuine compile/link: 21,164 B flash, 1,782 B static SRAM, 266 B remaining, with source/HEX/ELF hashes. The parser drains oversized input through LF. | Raw artifacts are not in ZIP; full maximum-frame proofs, serial service/stack evidence and the final schema are not supplied. Remaining SRAM is not measured safe stack headroom. |
| D04 authority/retention | `ally_d02_d04_d06_response.md:160–212`: no wire authorization; retain `retention_ack:null`; no synthetic release; full/corrupt journal should block new Start, not emergency safety action; offline revocation limits acknowledged. | Feasible controller authorization, key lifecycle and bounded retention/release/service policy remain unimplemented/unapproved. K-01 app provisioning alone cannot close controller authorization. |
| D05 profile/time | `k03b02_chicken_profile_confirmation.md:335–353` gives exact candidate profile values, source identity and approval state. Time limitations and profile questions are explicit. | Named numerical-profile approval, actual capacity approval, outage/time policy, hardware identification and physical verification remain missing. Do not ask Ally to restate values already listed. |
| D06 local/cloud/completion | `ally_d02_d04_d06_response.md:214–250` accepts stable cloud identity/idempotency and manual completion independent of Stop, with four explicit conditions. A pure-Dart handshake model is reported in `a06_start_ack_running.md:207–239`, but not integrated. | Backend must reconcile the old applied-Stop prerequisite, result recording, cloud Active guard and new physical batch admission. Flutter durable storage/API integration and approved test scope remain open. |

## Specific inconsistencies to resolve, not repeat as broad questions

### 1. START versus START_BATCH/CONFIRM is a material revision mismatch

Cha's earlier supplied firmware summary said START_BATCH, RESUME_BATCH,
COMMISSION_START, ACK_POWER_LOSS and SET_ELAPSED require explicit CONFIRM, and
NEW_BATCH is a deprecated START_BATCH alias.

This packet instead documents `{"id":301,"cmd":"START","batch_id":7001}`
without confirmation (`a02_ndjson_serial_protocol.md:79–100`). None of those five
confirmation-gated command names or the literal JSON `confirm` field appears in
the 34 Markdown files. `oct26_a02_firmware_interface.md:84–104` still describes
NEW_BATCH/RESET/selection reset behavior. Request one explicit supersession answer
and the matching source; do not silently translate between these protocols.

### 2. Boot/reset behavior is not consistently described

`hwimp01_source_patch_start_stop_status.md:51–66` reports no auto-start on boot or
selection, but `oct26_a07_rtc_restart_recovery.md:45–65` reports a fresh batch on
blank/corrupt EEPROM and control resuming after valid reads. The profile record
also describes auto-starting a fresh Chicken batch on invalid EEPROM
(`k03b02_chicken_profile_confirmation.md:147–154`). Absence of a RUNNING frame or
`activeBatchId == 0` does not prove heater outputs stay off. Require the selected
source's boot/RESET/selection/invalid-EEPROM transition-and-output table and tests
that check outputs after sensor recovery, not only setup or message absence.

### 3. The proposed journal model is not the proposed final identity layout

`hwimp02_durable_recovery_design.md:45–62` uses uint32 batch identity and int32
command identity. `ally_d02_d04_d06_response.md:140–151` discusses a candidate slot
with a 16-byte batch ID and 8-byte command ID. The model's 31 reported passing
checks do not validate that revised layout or a complete identity/replay protocol.
The same response (`:77–79`) says eight bytes fit the space of today's `long`;
its own source facts describe that long as signed 32-bit. Eight bytes is twice
four bytes. Reconcile the field budget before approving it.

### 4. Receive-buffer size and cloud evidence ceiling must remain separate

The response (`ally_d02_d04_d06_response.md:52,153–158`) overstates the effect of
`serialLine[120]`: that is an incoming application buffer, not a general TX-frame
limit. DB-02's 4,096-byte per-frame HTTP ceiling is an upper resource ceiling,
not a requirement for the Uno to emit 4,096 bytes. Preserve separate actual RX,
TX, parser and queue-service budgets. Earlier reports also call the software AVR
ring a hardware limit; the response correctly acknowledges it is not an absolute
frame-length limit. Correct the stale wording without reopening the architecture.

### 5. Completion acceptance still needs a concrete backend amendment

Ally supports saving a manual result without STOP, but also says completion must
not itself clear the single-Active guard or authorize another physical batch
(`ally_d02_d04_d06_response.md:235–250`). The old DB-02 candidate requires an applied
Stop and uses a partial index on status Active. Those rules cannot be reconciled
by a generic "accept". Define manual result storage, cloud lifecycle projection
and physical admission separately, without inventing Stop evidence.

### 6. Older global tracker judgments must not override other working trees

The tracker plan reviewed an older HTML snapshot without the browser export
(`tracker_consolidated_completion_plan.md:12–37`). It labels Kath's UI audit and
Cha's database inventory absent, yet the supplied Cha packet cites a prior live
inventory and this local tree has UI review/components/tests. Treat those as
branch/snapshot availability findings, not global proof work never occurred.
Its schema/hatchability-column recommendations also differ from DB-02's additive
model, which defers a stored hatchability value. Do not authorize migrations from
that older plan. Preserve selected architecture/day-origin decisions where already
documented; do not re-open ESP8266 or Day-7 merely because old HTML contains them.

## What can be accepted as supplied answers now

- Ally's stated source/build identity and reported test results as attributed
  report evidence, pending delivery/verification of the referenced artifacts.
- ACK, controller observation, independent physical feedback and cloud receipt
  are distinct; no automatic physical Start replay.
- No current STOP, controller authentication, RTC implementation or durable event
  journal is claimed by the latest response.
- Four-slot retention is a proposal, not a full event archive or production feature.
- Unknown source UTC remains unknown. A separately captured phone time must retain
  its phone provenance; it cannot become a verified controller occurrence time.
- Profile values are supplied; numerical approval and physical tests are separate.
- `pilot_gate_01_readiness.md:8–22,30–54` explicitly declares NO-GO, no empty-incubator
  run, no flashed-board verification and postponed egg loading. Do not override it.

## Minimal follow-up package

1. Cha updates the existing D01–D06 ledger with Ally's actual positions and links,
   distinguishing answered, agreed, implemented and verified. Correct ownership
   attribution from confirmed team information; Ally's assertion that Cha and Mary
   are the same person is not independently verified here.
2. Ally identifies which protocol supersedes the other and provides **one** matching
   source/patch/fixture/build-evidence bundle, including the reported Dart handshake
   model if it is to be reused. Existing work need not be recreated.
3. Cha supplies the referenced `D04_D06_Mary_Backend_Position` and current v1.3
   decision draft. Neither is present in this ZIP or the five previously supplied
   Cha attachments. Record existing answers rather than ask the same questions again.
4. Owners settle only the actual remaining choices: STOP and recovery semantics,
   final identity/frame/journal layout, authority/retention boundary, profile/time
   approval, and manual-result versus lifecycle/admission policy.
5. Kath can support Android-generated original batch UUID/16-hex command identities
   as a feasible design, but must implement/test durable pre-dispatch storage;
   current Flutter cannot be claimed to do this already. Actual-target UI and
   state/persistence seams can be tested with clearly labeled mocks without
   falsely presenting physical readings or waiting for physical pilot approval.

No source, firmware, SQL, provisioning, deployment or hardware operation was
performed for this packet review. Only this review document was added.
