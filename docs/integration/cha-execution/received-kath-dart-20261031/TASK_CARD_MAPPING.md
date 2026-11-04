# Kath — full task-card receipt and existing-evidence mapping

**Date:** 2026-10-31. Review/evidence delivery only; no new design approval or implementation.

## Receipt verification

- Received `SmartHatch_Remaining_Tasks_Review_Packet.zip`, SHA-256 `8b62234f8dfce68c1a9d84b7fe6ab9050ce5a348d071f6d978e46bd46d9c6ce9`.
- All **79 manifest-listed files** exist and match their SHA-256 and byte sizes.
- All **34 task cards** are accessible. The eight requested cards were read.
- `remaining-task-workqueue/planned-test-records.json`: **102 unique cases, all NOT RUN**. SHA-256 `7072425481461528cfd0b0ce73546080c242f473c386cb1b029033d09a178db4`.
- Read the package README and Q-index in the requested order. The supplied manual-result API/schema/fixtures match the previously reviewed 0.1 fingerprints; no repeat field review or test run performed.
- The packet ledger SHA-256 is `55491aa83761bee5825beb3d3df231f87b0b88efb2fc18625c7cc7f5520e1de3`; it remains the register and was not edited.

## Mapping existing findings to exact card criteria

Every reference to checks below means the earlier **21 Node reference tests** and **41 independent Dart review assertions**, not implementation acceptance. No listed C1/C2/C3 status is changed.

| Task ID | Exact criterion | Existing evidence supplied | Remaining change/test | Responsible owner | Blocker |
|---|---|---|---|---|---|
| **ORIGINAL:C-08** | C1 manual zero/upper count without Stop; C2 duplicate/conflicting/alias singleton; C3 failed save leaves Active/no false success. | Prior Q05 field dispositions and count/identity reference checks support the review portion of C1/C2. Dart core/receipt tests supplied. SRC-01 already identifies current direct completion mismatch. | Actual result/outbox persistence, transactional singleton/concurrency and failed-save UI/readback checks; C3 not exercised by these models. | Mary backend; Kath store/UI. | Q06 storage/device choices, Mary's draft-ID decision, next candidate and Q12 scope. |
| **OCT26:C-02C** | C1 approved common fields/examples pinned; C2 incompatible versions fail closed; C3 producer/consumer/hash fixtures agree. | Exact 0.1 ACCEPT/CHANGE findings, Node version negatives and both Dart byte/hash vectors provide review/model evidence only. | Identify next candidate for tuple/retry/scenario changes; obtain required reviewer choices and selected wire; test actual producer/consumer version rejection. | Mary candidate/ledger; Kath consumer; Ally wire. | Q01–Q04 unresolved; proposed UUID reservation not approved. |
| **OCT26:C-10** | C1 bounded integer/valid denominator; C2 exact session/count idempotent readback; C3 failed save cannot finalize/show success. | Reference checks cover zero/upper/invalid count and positive-original-quantity preconditions; Dart checks lossless mapping/content. | Actual percentage/denominator behavior, persistence/readback/duplicate and failed-save UI tests. Neither arithmetic acceptance nor C2/C3 is established by vector parity. | Mary persistence; Kath UI/storage. | Q06/Q12 and exact next-candidate decisions. |
| **OCT26:C-11** | C1 lost response reconciles immutable identity; C2 expired/revoked/other sync denied; C3 restart/cloud retry issues no physical command. | Review-model outer/nested tuple/error guards, receipt semantics and prior recovery requirements support design of C1/C3. | Implement and exercise authenticated submit/lookup/outbox/restart/revocation and no-command paths. | Mary backend/auth; Kath recovery/transport separation. | Q01, Q06, Q07, Q12; actual backend/store absent from evidence. |
| **OCT26:TEST-02** | C1 real source/app/row equality; C2 authenticated bridge/receipt mapping; C3 unauthorized/revoked denied/no source release. | Vectors and mapping/fixed-effect guard checks are input expectations only; no real C1–C3 result. | Authorized source-to-app-to-isolated-cloud integration and actual identity/security tests, with retained logs. | Mary + Kath; Ally source; safety owner for applicable physical stages. | Selected source, credentials/test scope, implemented transport/store and Q13 prerequisites. |
| **OCT26:TEST-09** | C1 save/reread original batch; C2 pending/conflict/failure never Completed; C3 History survives restart/later batch. | Exact result_recorded/revision1/non-null mapping decisions and prior workflow review support review of C1/C2; source mismatch recorded. | Actual result entry, failed saves, receipt loss, restart and later-batch History tests; no C1–C3 acceptance pass supplied. | Kath UI/store; Mary persistence/readback. | Q06/Q12 and next-candidate implementation. |
| **CURRENT:DB-IMP-01** | C1 actual authenticated versioned persistence; C2 real idempotency/singleton/receipt races; C3 validation not weakened. | Exact request/receipt changes, reference negatives and Dart hash parity support validation-review portion of C3. | Review actual core/patch at recorded hash; implement selected adapter and atomic result storage; run authenticated persistence/concurrency/security tests. | Mary backend; Kath client; Ally source. | Actual core source not delivered, Q01/Q03/Q04/Q07/Q12. |
| **CURRENT:INT-IMP-01** | C1 exact revision/log per PASS; C2 actual failures assigned; C3 fake-transport/test-backend dry run before physical test. | Deliver unchanged Dart script and recorded stdout export with hashes/provenance. This supports ledger evidence linkage, not whole C1 closure. | Incorporate scoped evidence, assign actual future failures as observed; execute required matching fake-transport/test-backend dry run. | Mary/Cha coordinator (one person); Kath client; Ally source. | Matching implementations/fixtures, approved scope and Q01/Q06/Q12/Q13. No dry run performed. |

## Existing evidence delivered

- `dart_manual_result_review.dart`: unchanged existing script, SHA-256 `bcb7ab832eabd97092e6d22a983910cd4e32288e5777f3cd79adbbd1ee57b45e`.
- `dart_manual_result_review.recorded-stdout.txt`: export of the original console output retained in this session; see README for provenance. No separately captured original stdout file existed. It was not recreated by rerunning tests.
- Both published canonical strings/lengths/digests match; 41 assertions concern the reviewed fixture subset and prospective guards only. The original 0.1 fixture remains unchanged.

## Remaining availability gaps

The task cards, planned-case record, architecture v0.3/v0.4 and amendment record are **now delivered**, so the previous missing-file qualifications for those inputs are cleared. Receipt does not constitute formal adoption.

Still not delivered in this packet:

- Actual selected Ally source/patch/catalog, raw firmware fixtures/build/toolchain/model artifacts and supersession answer.
- `supabase/functions/_shared/bridge-sync-core.mjs`, referenced by CURRENT:DB-IMP-01 at hash `b7a9aa133ce46d180b84de0c2f712c5dc9229cf59c8b24c42f4dd661750850d2`. Its presence in Mary's checkout is not disputed; the implementation is not included here for inspection.
- Standalone `docs/integration/cha-execution/monitoring-backend-regression.tap` referenced by CURRENT:INT-IMP-01. The consolidated `portfolio-backend-regression.tap` is supplied; no recreation or repeat run of existing tests is requested. Provide the existing standalone log only if its exact historical fingerprint must be verified.
- Any actual next-candidate implementation of the tuple/retry/schema/fixture changes; supplied 0.1 remains the reviewed historical candidate.

Mary must decide the proposed draft-action UUID reservation. Lookup tuple matching, retryable-by-code and fixture-scenario clarification remain recorded next-candidate changes, not silent modifications. Package pins, API30 and activation expiry remain candidates. All existing participant positions and pending formal adoption remain unchanged.

**No acceptance case or whole task was marked Completed. No application/firmware edit, installation, account/database/RLS/RPC operation, deployment, formal adoption, external sending, flashing or physical test was performed. Only receipt verification, card reading, evidence copying/export and this mapping were performed.**
