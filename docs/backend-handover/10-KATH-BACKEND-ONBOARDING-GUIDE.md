# 10 — Kath backend onboarding guide

**Takeover is pending review and explicit responsibility acknowledgment.** Historical author credit remains with contributors; this package changes no runtime owner, account, permission or contract.

## START HERE — KATH'S BACKEND TAKEOVER

### Safe to use now
1. Compare repository root, branch, full HEAD, staged/unstaged/untracked status and hashes with [01](01-REPOSITORY-BASELINE-AND-EVIDENCE.md) and [13](13-HANDOVER-FILE-AND-PATCH-MANIFEST.md).
2. Read [backend instructions](../instructions/BACKEND.md), then newer [ledger opening](../contract-review/CONTRACT-FREEZE-01_Team_Decisions.md): older guide phone-pinning wording is superseded for Q07 planning only.
3. Read actual candidate core/adapter/entrypoint and disabled SQL as text; retain closed source gate. Use read-only Git and local path/hash comparisons without secrets.
4. Read [test boundaries](08-TESTS-AND-ACCEPTANCE-EVIDENCE.md); existing syntax-only Node checks are a non-backend-changing workflow, not deployment/native compatibility evidence. No checks were run by this task.

### Needs completion
- Reconcile local-only Q12, new tests, contracts, receipts and three unstaged diffs before relying on a different checkout.
- Source/catalog delivery and final wire choice; Q07 account assignment/security compatibility; real RPC/ledger/result-only feature; client durable storage and native tests; full monitoring and integration acceptance.
- Q12 original rollback and actual inspection evidence remain unavailable/incomplete. Do not turn synthetic output into real evidence.

### Requires coordination
- **Kath:** package review/acceptance, future task ownership, exact Android/SDK/native storage/fencing design and device evidence.
- **Ally:** existing matching raw firmware/catalog/build packet, source identity/time/STOP/recovery/retention feasibility, occupied-controller protection.
- **Cha/Mary:** contributor provenance, current local work and backend decisions; latest account-policy design approval is reported, not execution permission.
- **Authorized project/assignment/safety owners:** identify actual authority; approve exact later operational scope and recovery plans. Unknown owners remain blockers, not permission for Kath to act by default.

### Do not execute yet
- No migrations/SQL, hosted queries, account/provider/SMTP changes, RLS/grant changes, source enabling, remote retry, deployment or configuration edits.
- No USB/Bluetooth/serial connection, reset, flash, commands or powered tests on the reported occupied incubator.
- No automatic patch application/merge/stage/commit or old outbox conversion. No test runner/server launch under the present documentation-only scope.

## Recommended review order

Baseline → architecture/security/contracts → exact manifest and missing-file comparison → every relevant [pending task](06-PENDING-BACKEND-CHANGE-REGISTER.md) → Q12/test evidence → risks → [unchecked acceptance form](12-HANDOVER-ACCEPTANCE-CHECKLIST.md).

Record requested corrections separately without overwriting historical sources. Completion of documentation does not establish receipt by another session, formal contract adoption, safe implementation readiness or acceptance.
