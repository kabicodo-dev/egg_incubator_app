# Kath/Mary seven-item proposal — comparison and recommended response

Date: 2026-10-30. User supplied
`updated-Kath-Mary-Remaining-Decisions-Proposal-2026-10-30` (Markdown without
extension), SHA-256
`fcac95a70cbce94d6fe7e244310eea8b26ba92d3a7d34b436cf2a1c0faaf8fc7`.
This is a received proposal, expressly not signatures or implementation authority.
The dispositions below are review recommendations, not new Mary/Kath votes.

## Reviewed revisions and scope

The attachment cites ledger SHA 6197a2b78fe173a9ff3bf08427903bbc2b28bbe35bd6d4959ab7f4411826c604
and amendment SHA 01bce400e1519ee798dbfd5dcc94ef74923f21c2ddcdec95a2efa046cd93c8bd.
At receipt our newer files hashed dfeae7398078fb91eefdfb39209e50a475f6a822dfd5623e95f0f5583e0a37e8
and 4808510868e2ad57e35f9059dbcfa3e27bf1a54c6cf9d94a629037c35412e3db.
Those are different snapshots, not proof either member's work never happened.
The attachment explicitly did not receive the new versioned manual-result API.
Do not call this review acceptance of its exact field names/hash/receipt semantics.
The cited prior Kath focused-review fingerprint matches the earlier received file.

Package/version/toolchain claims are attributed metadata/source observations in
Kath's proposal, not independent native-build/security validation in this receipt.
No package lookup, install, build, device test or migration was performed here.

## Seven rows: retain existing answers; resolve only concrete differences

| Row | Existing confirmed Mary position | Recommended response / unresolved detail |
|---|---|---|
| 1 Workflow | M01/M06 already support durable saved/pending-validation/sync/conflict and atomic commits | Retain support. Review exact label: new API says result_recorded, not old event-applied/lifecycle completion. Server-recorded only after a matching result receipt is durably committed locally |
| 2 Manifest | M03 supports immutable original quantity/profile/actor/batch and no current-settings repair | Confirm design alignment, but exact manifest encoding/trust fingerprint remains open. Draft-created action UUID is a concrete proposal: may be retained as result_id at sealing, never regenerated on retry; must be explicitly reconciled with current API freeze wording. Draft identity must not authorize source facts or alias singleton rules. Replacement recovery requires explicit admin scope, not credentials/ID possession alone |
| 3 Corrections | M04 already defers submitted corrections; drafts editable until seal | Already aligned. No correction endpoint/UI authorized. Support-recipient name/contact is still not supplied; do not invent a staffed administrator or response SLA |
| 4 Finalization | M02 defers prototype lifecycle finalization; result alone leaves Active intact | Defer the proposed administrator-finalization endpoint/hold machinery as a future design. Stop prerequisite applies only to that future finalization proposal, NEVER manual result recording. Separate durable controller hold/atomic release policy is not approved/implemented; needs Ally/shared evidence and design |
| 5 Storage | M06 accepts durability requirements but deliberately leaves package/SDK selection to reviewed Kath proposal | Hold exact pins sqflite_sqlcipher 3.4.1 + flutter_secure_storage 11.2.0, API 30+ and crypto/key/pragma/backup implementation for explicit Mary/Kath compatibility-test authorization and actual target-device/native-build evidence. Metadata is not certification. No install or production pubspec edit |
| 6 Backend | M05 assigned Mary exact versioned API/fixtures; result independent of Stop | Deliver existing SmartHatch_Manual_Result_0.1_Review.zip, not draft a competing API. Resolve result_recorded vs applied/disposition, immutable revision 1 vs mutable revisions, non-null mapped session vs nullable waiting receipt, and separate admission/lifecycle lookup before acceptance |
| 7 Enrollment | M07 supports controlled non-anonymous scope, no privileged credential and protected evidence preservation | Retain direction. Hold new 30-minute activation expiry, exact credential/refresh/session reapproval and device-auth/offline unlock/key-loss mechanism for explicit reviewed choice and tests. Administrator/recipient and test-device eligibility must be real, not assumed. App enrollment cannot authorize controller commands |

These recommendations do not withdraw any previously confirmed M01–M07 principle.
New concrete choices have not been approved by the user merely by forwarding this
attachment. Do not ask for blanket acceptance of all seven rows.

## Concrete interface differences Kath must review against the new package

1. **Success meaning:** proposed result receipt outcome is result_recorded. It
   means one result is stored, never cloud Completed or physical Stop/admission.
2. **Prerequisite/mapping:** current proposal rejects missing trusted manifest or
   mapping with a nonpersisted error; app retains Pending validation. It does not
   issue committed waiting receipts with nullable session IDs for this result API.
3. **Receipt revisions:** current prototype result receipt is immutable revision 1;
   mutable event processing/reconciliation belongs to the older API. Decide which
   exact result contract is accepted; do not silently merge them.
4. **Lifecycle/admission:** new result-only lookup does not claim current hardware
   permission or include a finalization/hold endpoint. Any such extension requires
   a separately reviewed versioned contract and actual controller evidence.
5. **Action allocation:** Kath proposes action UUID at draft creation; candidate
   API describes allocation/check at durable seal. A draft UUID can be checked and
   reused at seal without becoming a new submitted identity, but this is a proposed
   reconciliation to confirm, not an implemented algorithm or approval.
6. **Original manifest:** the fixture manifest digest is synthetic. Exact original
   manifest bytes, authorization/trust establishment and selected source mapping
   remain blockers. App-local canonical bytes alone do not establish controller
   admission or an approved profile.

Local SQLCipher PK/FK/lease/revision/durability suggestions and T1–T6 failure tests
are useful preparation. One result per original batch must remain enforced server-
side across actors/aliases/replacements, not merely uniqueness by local actor.
In-flight logout/revocation requires actual server authorization/transaction tests;
local locks cannot promise cancellation of a request already committed remotely.

## Short recommended message for the user to send

Thank you. Rows 1 and 3 align with my recorded M01/M04/M06 directions; original
manifest truthfulness and controlled-cloud enrollment principles remain confirmed.
Please review the attached manual-result API 0.1 package for the concrete fields,
hash vectors and receipt contract rather than infer the older event API applies.
It currently requires a trusted manifest and real mapping before server acceptance,
uses result_recorded with immutable revision 1, and defines no admission/finalization
endpoint. Please return specific changes to those choices if needed.

Keep administrator finalization, per-controller hold/release machinery and the
Stop prerequisite for that future finalization OUT of current prototype execution;
result saving remains independent of Stop and leaves Active intact. Please propose
only the remaining exact manifest/action-allocation/recovery reconciliation.
The new storage pins/API-30 floor, activation expiry and concrete secure-key/session
mechanism remain candidates pending explicit confirmation and authorized native
compatibility/security tests. No install, code/database change or physical test is
authorized. The actual support recipient is still to be named, not assumed.

## Effect on tasks

No full task becomes Completed. This is proposed workflow/storage alignment, not
Ally's exact C-02A schema/example review, final protocol selection, implementation
or storage/security test evidence. Existing task statuses and old executable
candidates remain unchanged. The prepared API package is already available; this
receipt does not resend it or claim an external delivery acknowledgment.
