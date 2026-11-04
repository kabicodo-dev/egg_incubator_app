# Q12 requirement-to-evidence matrix

Prepared 2026-10-31. **No task status edited. No remote execution.**

## Scope determination (not an owner-approved closure decision)

Original source: `docs/integration/remaining-task-workqueue/decision-index.json:239–263`,
corroborated by `REMAINING_DECISIONS_ALL_OWNERS.md:125–133`. Q12 is titled
**“Separately scoped database/security implementation permission”**, owners
**Mary / authorized test-project owner, Kath**. It is a deduplicated decision
request, not a standalone implementation issue. No separate original Q12 issue
number or standalone implementation acceptance checklist was located. Do not
invent one or substitute DB-IMP-01's acceptance conditions.

Complete original request, verbatim:

> After exact choices, explicitly approve only the named test identity/fixture/migration/RLS/RPC/endpoint operations actually needed, with rollback/cleanup and readback proof. Existing narrow probe permission does not authorize schema changes, new account provisioning, enabling ingestion or production access. Until then use local tests/plans only.

Original already-answered boundary, verbatim:

> Isolated target smarthatch-test zbwntspdecngnicllwlw; prior narrow role probe allowed. Main-project protection and existing data preservation remain.

Affected tasks (dependency list, NOT operations authorized by Q12):
`ORIGINAL:C-03/C-04/C-05/C-08`,
`OCT26:C-04/C-05/C-06/C-07/C-10/C-11/TEST-02/TEST-09`,
`CURRENT:DB-IMP-01/INT-IMP-01`.

The complete original record and affected IDs remain at the source path above.
`tasks/CURRENT_DB-IMP-01.md:12–23` describes a separate migration/Edge/fixture/log
deliverable with source/Auth/design dependencies. None is silently included here.

**B–E disposition:** `Q12_Test_Project_Approval_Plan.md:100–110` explicitly requires
new exact manifests/consent. They are proposed dependent-task work, not mandatory
Phase A operations or currently authorized work. The plan at 83–84 explicitly says
“A acceptance: attributable bounded outputs and rollback confirmation, or a
truthful blocked/partial report. This does not close Q12 or any whole task.”
Owner confirmation of the original permission request's final disposition is still
needed. Even a successful Phase A cannot close all 14 tasks or approve B–E.

The preserved full portal `SmartHatch_Cha_Backend_Updated.html` corroborates this:
`details[data-workqueue-decision="Q12"]` / `#portfolio-Q12` contains the same
permission text and affected IDs; references in task cards are pending-request
links, not a standalone original Q12 implementation task. A sanitized exact
record/portal excerpt is retained in `original-scope-extract.json`.

## Original requirements (O identifiers are trace labels, not invented criteria)

Common evidence base: `docs/integration/cha-execution/` (E),
`docs/integration/remaining-task-workqueue/` (W), this package (P).
“PASS locally” never means remotely verified or owner accepted.

| ID / exact source wording | Required action | Current status / evidence | Required tests | Dependencies / approval | Completion condition |
|---|---|---|---|---|---|
| O1 “After exact choices, explicitly approve only the named test identity/fixture/migration/RLS/RPC/endpoint operations actually needed, with rollback/cleanup and readback proof.” | Identify choices and supply exact operation manifest; obtain genuine scoped consent, then retain authorized results/cleanup proof. | **PARTIAL/BLOCKED.** E/Q12_Test_Project_Approval_Plan.md names A; E/Q12_PHASE_A_APPROVAL_AND_BLOCKER.md preserves narrow historical consent. This request requires fresh final-command approval. Later operations unchosen/unapproved. | Manifest/hash/target checks; actual authorized readback and cleanup, not model outcomes. | Authorized owner/Mary and Kath where applicable; Q06/Q07/source/design choices only for relevant later task. No Ally prerequisite to A. | Relevant choices and exactly named operations approved and required proof accepted; owner defines disposition for this shared request. Not implied by A preparation. |
| O2 “Existing narrow probe permission does not authorize schema changes, new account provisioning, enabling ingestion or production access.” | Keep earlier permission narrow; no mutations, accounts, ingestion or production. | **BOUNDARY OBSERVED.** E/Q12_PHASE_A_APPROVAL_AND_BLOCKER.md; P/REVIEW.md; immutable SQL. | Target/TLS/hash/default-deny negative cases; source review of only fixed SQL and cleanup. | Separate explicit consent would be necessary for any later operation; absent here. | No prohibited action under this permission. Does not itself close request. |
| O3 “Until then use local tests/plans only.” | Remain local until exact new authorization. | **PASS for current workflow.** Fresh local 211-case run; P/local-review-evidence.json. | Local runner plus source review; remote calls NOT RUN. | Fresh reviewed-command approval and trust/credential gates. | Stop before remote; no fallback/retry/provisioning. |
| O4 “Isolated target smarthatch-test zbwntspdecngnicllwlw; prior narrow role probe allowed. Main-project protection and existing data preservation remain.” | Pin test target, exclude main/production, preserve existing data. | **LOCAL PIN VERIFIED / REMOTE UNVERIFIED.** v3 ModelPolicy.cs:16–47; NativeBoundary.cs:162–188. Attempt 1 is user-reported only. | Mismatched project/host/user/port/TLS deny tests; genuine verify-full/tenant check on approved connection pending. | Owner confirmation of connection coordinates from authenticated project; no Supabase access in this run. | Exact test target established, no data delta; genuine remote evidence if approved. |

## Phase A plan and latest-request gates (not retroactive original criteria)

Each row retains a direct quote from the staged plan or latest user request, and
separates implementation from the evidence still required for execution/closure.

| ID / exact wording and source | Required action | Current status / evidence | Required tests | Dependencies / approval | Completion condition |
|---|---|---|---|---|---|
| A1 “run the sibling Q12_Phase_A_Read_Only.sql unchanged” (plan 36–40) | Preserve 17 statements/order, read-only repeatable-read and 10s/2s/60s timeouts. | **LOCAL PASS.** P/local-review-evidence.json; v3 Pin.Sql and transport. SQL hash 9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc. | Hash/split/reconstruction/sequential-send tests; actual remote receipt pending. | Fresh A-only command approval. | Same bytes executed once in order on approved connection, or truthful stop. |
| A2 “Save sanitized outputs locally in a new run-owned directory” (plan 41–43) | Incremental attributed journal/emergency records with versions/timing/exit. | **LOCAL PASS.** v3 FileJournal/ExportGuard; three emergency-only tests and fresh evidence. | Flush/create-new, failure paths, synthetic leak guard, eight source/five compiler fingerprints. | Protected operator workstation/storage; no transcripts/debug dumps/recording. | Actual sanitized complete records retained; no missing/torn terminal event called success. |
| A3 “Compare the resulting metadata against the drafts” (plan 44–46) | Compare only supported scoped baselines; expose remaining uncertainty. | **IMPLEMENTED PARTIALLY; REMOTE NOT RUN.** P/REVIEW.md coverage table and pending discrepancy form. | 11 policy tests, 18 constraint tests; actual catalog review pending. | Actual authorized outputs; unapproved drafts are comparators, not adopted design. | Each real observation attributed MATCH/DIFFERENT/UNRESOLVED; no complete audit claim. |
| A4 “On SQL error issue ROLLBACK on the same connection” (plan 73–80) | One cleanup attempt only if original connection remains usable/in transaction; close, record tag/idle. | **LOCAL PASS / REAL UNAVAILABLE.** v3 DurableController.cs:133–166. Attempt 1 has no original rollback confirmation. | Error/aborted-state/connection loss/nonidle/cleanup/close and evidence-failure cases. | Original connection usability; no reconnect substitute. | Real original tag + idle + closure, or explicit UNAVAILABLE and blocked/partial outcome. |
| A5 “A acceptance: attributable bounded outputs and rollback confirmation, or a truthful blocked/partial report. This does not close Q12 or any whole task.” (plan 83–84) | Record actual outcome honestly, separately from closure. | **TRUTHFUL BLOCKED REPORT PREPARED; successful inspection pending.** Attempt 1 and P/README.md. | Review evidence completeness; no model-to-live inference. | Owner/reviewer acceptance. | Either accurate bounded success or partial/blocked receipt; never overall Q12 completion from A alone. |
| L1 “Continue this correction-and-verification cycle until all locally resolvable blocking findings are closed.” (latest request Phase 1) | Fresh source/evidence review, fix genuine blocking defects in preserved new revision if found. | **LOCAL REVIEW PASS WITH LIMITS.** P/REVIEW.md; fresh 211/211. No new blocking code defect identified; v3 unchanged. | R1–R5/procedure and F1–F7 review, inventory/compiler checks. | Same assistant review is not separate human acceptance. | No identified locally fixable blocking code defect; external trust/live tests remain blocked. |
| L2 “Do not manufacture or self-approve a trusted certificate fingerprint.” (Phase 2) | Offline inspect certificate; obtain authoritative origin and independent DER reference plus genuine owner attestation. | **BLOCKED ON TRUST; OFFLINE PARSE DONE.** P/local-review-evidence.json and README.md. | X509 identity/validity/CA/key-use observations; actual verify-full NOT RUN. | Authorized project owner; trusted source/fingerprint unavailable locally. | Provenance procedure genuinely satisfied, not a copied local hash; explicit owner acceptance. |
| L3 “STOP BEFORE REMOTE EXECUTION.” (Phase 3) | Produce exact command/scope; await new explicit authorization. | **STOP OBSERVED.** P/README.md includes proposed fixed command, not executed. | Default-deny invocation PASS; source review. | Certificate evidence and secure local credential method first. | Explicit final reviewed-command approval, no implied approval from this prompt. |
| L4 “Perform this phase ONLY after I provide explicit authorization.” (Phase 4) | Execute a single approved A attempt only; never auto-retry. | **NOT RUN / BLOCKED.** P/PENDING_REMOTE_AND_CLOSURE.md. | Live TLS/auth/settings/shapes/sequential/rollback checks. | Fresh consent + owner trust + existing secure local credential. | All safety controls/evidence pass; failure yields exact stop, not automatic retry. |
| L5 “Do not claim a complete audit when the evidence is insufficient.” (Phase 5) | Attribute every actual finding/severity/impact/owner; no corrective SQL. | **PENDING ACTUAL DATA.** Coverage boundaries and empty finding form prepared. | Actual sanitized results matched to expected state; missing bodies/ACL expansion/kind unresolved. | Authorized successful inspection; adopted design where one exists. | Honest scoped findings accepted; no invented observed state. |
| L6 “The authorized reviewer has accepted the closure evidence.” / “Do not change the original portal/GitHub task status without my explicit approval.” (Phase 7) | Assemble closure evidence; request actual sign-off and separate status-edit consent. | **NOT ACCEPTED / NO STATUS EDIT.** Pending sign-off form, original O1 scope unresolved. | Requirement-by-requirement final gate. | Mary/Cha and authorized owner/Kath as applicable (Mary/Cha is one person). | Original permission disposition agreed; required real evidence and explicit reviewer acceptance; separate status-edit authorization. DB-IMP-01 remains separate. |

## Historical evidence reconciliation

- Original v1: 52 tests, withheld all cell values; insufficient semantic evidence
  and native/shape/durability/provenance gaps. Preserve, do not execute as latest.
- v2: F1–F7 correction report, 156 tests; partial catalog semantics and real
  certificate trust explicitly open. Not a replacement for live evidence.
- v3: R1–R5 and procedure corrections, original final 211/211; fresh rerun 211/211.
- Attempt 1: actual report from Mary, not raw supplied/independently verified log;
  BEGIN and three SETs, then idle timeout before SELECT. No successful catalog
  results and no explicit original rollback proof. It is not a completed A run.
- The initial plan header and older decision ledger predate approval/Attempt 1;
  they remain historical, not overwritten to make their statuses look current.

**Recommended disposition: Q12 BLOCKED (local preparation/review complete to the
stated limits). No published status edit and no completion sign-off.**
