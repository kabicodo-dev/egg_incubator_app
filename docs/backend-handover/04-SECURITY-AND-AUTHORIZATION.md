# 04 — Security and authorization handover

## Verified local design/code contributions

Cha/Mary's Git-attributed work includes Supabase migration/config setup (`d50dafb`), session-ownership audit/test/single-Active documentation (`cd481f3`, `a9d68fe`) and preserved backend handler/adapters/security candidates (`035e842`). Source inspection confirms strict validation, trusted-Auth-before-claim handling, non-anonymous candidate checks, scoped RPC ports, main-project refusal and no default source acceptance. This verifies local implementation intent, not live security.

The adapter calls `/auth/v1/user` before decoding claims. Decoding alone is not JWT verification; actual signatures, issuer/provider behavior, account email verification, revocation and SQL transaction checks remain unverified in this task. Caller-supplied IDs and hashes must never be treated as credentials or trusted canonical server facts.

## Precedence requiring careful takeover

1. Older M07/Q06-Q07/SQL/adapter materials describe designated installation and pinned session authorization.
2. [Q06/Q07 revision-3 receipt](../contract-review/Q06_Q07_Kath_Response_Rev3_Receipt_2026-11-02.md) records discussion recommendations, not authenticated new approvals.
3. Latest [Q07 technical 0.2](../contract-review/Q07_Provider_Session_Binding_Policy_0.2.md) and [ledger opening](../contract-review/CONTRACT-FREEZE-01_Team_Decisions.md) change current planning to self-service email/password signup, one-time email verification, ordinary password login, one-time team account-to-record assignment, no phone restriction and no routine admin reapproval.
4. Mary's P1–P6 design approval is **reported in the ledger**, not independently authenticated or implementation authorization. Final review, exact provider/client behavior and operational permissions remain pending.

Do not restore superseded phone-approval recommendations as the current requirement. Do not claim existing code implements account-only access. Historical installation/original actor identifiers and immutable action hashes still need preservation and reviewed mapping.

## Required future security evidence

- Verified assigned account allowed; unassigned, anonymous, wrong account, expired/revoked credentials denied on reads/writes/replay/receipt/reconciliation.
- Password login/reset/refresh/new phone behavior follows exact accepted policy; account switch never exposes another account's local evidence.
- Concurrent reassignment/revocation rechecked atomically with persistence; no direct REST/RPC bypass of authorization/canonical validation.
- No privileged credential in Flutter/firmware/logs/handover; no secret collection for this documentation task.
- Scope source authenticity and offline controller command authority separately from cloud authorization.

Historical catalog exports and narrow role-probe records are local documentary evidence only; no complete real Auth/RLS matrix is verified here. SMTP 0.1 is an unexecuted test proposal; newer relayed limits are one non-actionable email per consenting recipient, maximum three, no auto retry, window and secure method undecided. Neither 587/STARTTLS nor 465/implicit TLS is selected by this package.

Authorization, test and missing rollback gates are explicit per pending item in [06](06-PENDING-BACKEND-CHANGE-REGISTER.md). No RLS/Auth/grant/configuration or account operation is authorized.
