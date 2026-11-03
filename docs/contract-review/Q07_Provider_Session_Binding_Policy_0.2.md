# Q07 — account access, provider and session policy

**Revision:** 0.2 · **Prepared:** 2026-11-02
**Status:** ALIGNED TO LATEST USER-SUPPLIED PLANNING DIRECTION; FINAL REVIEW PENDING.
No implementation, hosted configuration change, account operation or deployment
permission follows from this revision.

## 1. Change and precedence

The latest supplied review requests these five planning choices:

1. Self-service Sign Up and one-time email verification.
2. Normal email/password login, without emailed login codes.
3. One-time team assignment of the correct incubator records to the account.
4. No phone approval or installation restriction.
5. No administrator reapproval after ordinary logout/login or password reset.

This revision replaces the invited-user/OTP/installation/session-reapproval
**planning recommendations** in [technical policy 0.1](Q07_Provider_Session_Binding_Policy_0.1.md)
and the earlier plain-language proposal. Their bytes remain historical evidence.
Use the [aligned simple explanation 0.2](Q07_Plain_Language_Access_Proposal_0.2.md)
with this file, not the older explanation. Actual responses remain in the
[existing decision ledger](CONTRACT-FREEZE-01_Team_Decisions.md).

This is a deliberate change from earlier M07/single-installation and Kath revision-3
recommendations, not a claim that they already described account-only access.
Record latest planning direction without inventing a joint signature, formal
architecture adoption or implementation permission. M08 identity reuse, immutable
facts, no false physical state and result/Active separation remain requirements.

## 2. P1 — self-service signup and verified account

- User supplies email/password through supported provider signup. No administrator
  invitation, user precreation, shared password or service-role credential in app.
- Require provider-confirmed email before protected incubator access. Account/email
  verification is a one-time onboarding step, not an emailed code at each login.
  Recommend a supported verification link; Kath must confirm exact provider token
  type, template, redirect/callback and SDK flow before implementation.
- Signup, verification and sign-in do not assign incubator records. A verified
  account with no assignment sees an unassigned/no-incubator state, not other
  accounts' records and not a fabricated empty/new batch.
- Subsequent ordinary login uses email/password. Do not substitute OTP, magic-link
  login, device enrollment or an email-code screen for that flow.
- Provider handles password verification securely; do not store or log plaintext
  passwords, email verification/reset tokens or service keys. Apply supported
  provider password/abuse protections; exact values remain verified-config work.

## 3. P2 — provider configuration and recovery

| Area | Required planning behavior | Evidence still needed |
|---|---|---|
| Signup | Self-service email/password signup enabled; no invite-only gate | Sanitized hosted signup/provider settings and actual SDK signup behavior |
| Email confirmation | Provider-verified email required before protected records; one-time onboarding | Confirmation enforcement, expired/resend/replay behavior and safe callback handling |
| Login | Password login for verified accounts; no emailed codes for normal sign-in | Resolved SDK password-login/session persistence and error handling |
| Password reset | Supported provider recovery flow may send a reset link; after successful reset, ordinary password login restores account-scoped eligibility without team reapproval | Reset token type/redirect, SDK recovery state, actual provider session invalidation behavior |
| Token lifetime/refresh/rate limits | Standard reviewed provider controls, not a new activation window | Actual hosted configuration and verification; no invented numeric duration |
| Anonymous access | Anonymous sessions cannot access protected incubator data | Explicit server enforcement and migration from current anonymous startup |

One-time verification and user-requested password-reset emails are not normal-login
codes. A password reset does not itself alter account-to-record ownership or invoke
team reassignment. Changed-email/provider security checks are separate exceptional
flows; no automatic transfer of record ownership based on matching an email string.
Use the stable verified provider **account subject/user ID**, not email, as access
identity. Local `supabase/config.toml` is not hosted-state proof: it currently has
anonymous/signup enabled and email confirmations disabled. No settings changed here.

## 4. P3 — account sessions, not phone/session approval

- Authorize the authenticated verified account's current record assignment and
  operation on every protected read, upload, replay and receipt/reconciliation call.
  The backend obtains subject/verification from trusted provider verification,
  never client IDs, a body flag or JWT decoding alone.
- Tokens must be valid, with verified issuer/audience/expiry and non-anonymous user.
  A session ID may support provider security, logs and client callback fencing; it
  is **not** an administrator-approved access pin.
- Ordinary token refresh, logout/login, password reset followed by valid login,
  new session or login on a different phone do not require team approval/re-pin.
  A valid new session of the same account uses the same still-current assignment.
- No installation allowlist, approved-phone slot, device enrollment, one-active-phone
  index, device attestation or serial-number check is required by this access policy.
  Incubator/controller IDs still scope data; they are not identifiers of an approved phone.
- Reject invalid/expired/revoked credentials as required by verified provider rules;
  allow normal reauthentication without team intervention. Explicit account/assignment
  revocation remains an exceptional security action, not routine session renewal.
- Network/Auth outage denies protected cloud calls without inventing a proven denial,
  canceled write or physical Stop. Never fall back to permissive direct tables.

Multiple sessions/phones of an account are not denied merely for being additional
phones. Concurrent data writes still need server idempotency/conflict controls.
This is not approval of multi-phone Bluetooth command arbitration or new hardware
control behavior, which remains separately gated with Ally.

## 5. P4 — one-time team assignment of correct existing records

Logical transaction requirements only; no schema, admin endpoint or executed SQL
is specified or authorized by this file.

1. An authorized team member identifies the correct stable account ID and verified
   original incubator/batch/record set using actual evidence. Team role/support
   contact must be identified before execution; never trust a client `is_admin` flag.
2. Atomically assign that record scope to the account with an audit of actor,
   reason, scope, expected mapping revision and outcome. Repeating the same valid
   assignment must not duplicate records; conflicting ownership requires adjudication,
   not last-writer-wins takeover or guessing from latest Active.
3. Assignment persists through routine login/logout/reset/new-phone sessions. It
   does not need reapproval or automatic expiry just because a session changes.
   Wrong-account/exceptional transfers or explicit revocation require a separately
   reviewed team action and history; not automatic client self-assignment.
4. Do not rewrite immutable original batch/actor/event/result identities to express
   account access. A new access mapping is not proof of original controller Start,
   original quantity/manifest, current physical state or permission to create a batch.
5. Serialize ownership changes and protected writes around a common authorization
   boundary; recheck current account scope in the persistence transaction. If a
   valid write commits before revocation, preserve it; if revocation wins, deny
   subsequent unauthorized work. Auth success alone is not an ownership grant.
6. Preserve the global physical single-active-batch safeguard independently of how
   many phone sessions exist. One account assignment does not permit a second
   physical Start or clear Active. No source ingestion gate is enabled by assignment.

Assignment of **existing incubator records** is not automatic existing-running-batch
registration. The occupied Arduino remains disconnected from this work: no connection,
command, reset, power cycle, reflash, settings synchronization or duplicate session.
Uncertain source identity/original times remain pending, with operator reports
preserved separately from controller-confirmed evidence.

## 6. P5 — logout, local evidence and recovery without reapproval

- Logout fences new uploader work/late callbacks, locks protected local access and
  clears cloud credentials through reviewed SDK behavior. Preserve encrypted local
  evidence and its separate key; do not erase/recreate data or new result IDs.
- A subsequent valid login to the **same account** can resume permitted scoped
  lookup/upload under its unchanged assignment, without administrator reapproval.
  A different account must not unlock or upload another account's local evidence
  simply because it uses the same phone. Define/test account-partitioned local access.
- Local vault/OS credential protection is security of stored data, not team phone
  approval. Exact unlock, backup, key and native behavior remain Q06 review work.
- In-flight uploads may commit after logout. Keep original identities and unknown
  outcomes, reconcile through currently authorized account scope; do not mint a new
  action or claim remote cancellation. Server idempotency is required across phones.
- Losing a phone/key may lose never-uploaded evidence; same-account cloud access on
  another phone cannot recreate local-only facts. No automatic key copying or new
  export/import guarantee is selected. Remote logout cannot instantly lock an offline
  vault or stop the Arduino; state that limitation truthfully.

## 7. P6 — account-scoped history and immutable result boundaries

- Correct team-assigned account scope governs access to existing History and its
  authorized operations from any normally authenticated session. No replacement-phone
  approval, historical read-only downgrade or new team grant merely for a new phone.
- Scope must explicitly distinguish read/reconciliation from allowed result uploads;
  do not let a caller self-claim another account's records or change immutable authors.
  Genuine original-actor/missing-source recovery exceptions remain separate data
  integrity questions, not routine login/phone approval gates.
- Enforce one logical initial result per original controller/batch across phones,
  sessions and actors, immutable content conflicts, lossless session mapping and
  trusted original manifest/count validation server-side. No correction/finalization
  endpoint, invented Stop or physical command is added by this access revision.
- Result alone leaves Active/end_date/admission unchanged and retention release null.
  Preserve M08 IDs and existing sealed payloads/hashes. Do not relabel old queued
  facts, silently reinterpret `installation_id` as account ID, remove immutable
  actor fields or claim the old API/SQL already implements account-only access.

## 8. Compatibility changes required before implementation

| Existing material/code | Effect of this planning change |
|---|---|
| Technical/simple 0.1 and Q06/Q07 E1–E5 recommendations | Retain as historical inputs; invite/OTP/phone restriction/reapproval replaced for current account-access planning |
| Earlier M07/backend-guide designated-installation language | Explicit planning delta; do not claim every old assumption is unchanged or formally adopted. This ledger records the new supplied direction |
| Legacy Flutter anonymous startup/direct tables | Needs coordinated signup/verification/password-login/account-scoped data migration; not changed now |
| `bridge-sync-supabase.mjs` and disabled SQL | Existing installation/session-pinned authorization is not this account-only policy; later reviewed adapter/schema/RLS changes required, including direct-call bypass protection |
| Manual-result 0.2 scoped ACCEPT/fixtures | Do not reopen unchanged result semantics. Separately assess affected authorization/actor mapping/version compatibility before any API change; no rehash or silent outbox conversion |
| Q06 storage and client worker design | Encryption/durability remain; remove phone-enrollment assumptions and verify per-account isolation and same-account new-session resume |

## 9. Future acceptance tests — NOT RUN here

1. New user signs up, verifies email once, and later uses password login without
   email codes. Unverified/anonymous users cannot access protected records.
2. Verified unassigned user sees no incubator data; assignment exposes only correct
   records. Other accounts cannot enumerate/read/write receipts or batches.
3. Same account retains permitted scope after logout/login, ordinary refresh,
   provider password reset and login on a second phone: no team/phone/session approval.
4. Expired verification/reset links, replay, bad callback, login abuse and invalid/
   revoked tokens fail safely using verified provider rules; no token/password logs.
5. Concurrent same-account phones preserve singleton result/idempotency/content
   conflict behavior and never admit a second physical batch.
6. Account switch/logout/late callbacks isolate local and remote state; unknown
   upload outcome reconciles under original identity rather than creating duplicates.
7. Team assignment/revocation races, direct REST/RPC bypass and account-ID spoofing
   enforce server authorization atomically without rewriting original facts.
8. Existing-batch/manifest/source gates remain closed absent their own evidence;
   an account assignment alone does not register, Start, Stop or complete hardware.

Hosted configuration/SDK/native evidence and exact test scope still need separate
authorization under [Q12 status](../integration/cha-execution/q12-phase-a-status.json).
No account, provider setting, policy, row, code or physical operation changed here.

## 10. Return to reviewer

> Thanks for the correction. Technical companion 0.2 now follows self-service Sign
> Up, one-time email verification, normal email/password login without emailed login
> codes, one-time team account-to-record assignment, no phone/installation restriction,
> and no team reapproval after ordinary logout/login or password reset. Earlier
> invite/OTP/session-pinned drafts are historical, not the current planning request.
> Please review P1–P6 against this revision/hash and return only concrete mismatches
> or ACCEPT/CHANGE/BLOCKED at design scope. Hosted config, exact client flows and
> authorization compatibility remain to verify; no implementation consent inferred.

Use responder/role/date, revision/hash, P-row, disposition, exact replacement or
missing evidence and next owner. Final review, real tests, team assignment and
deployment are separate from preparing this aligned proposal.
