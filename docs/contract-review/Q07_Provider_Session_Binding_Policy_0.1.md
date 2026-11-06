# Q07 — provider, session and installation-binding policy

**Revision:** 0.1 · **Prepared:** 2026-11-02 · **Workstream:** Mary/Cha backend
**Status:** PROPOSED TECHNICAL COMPANION — NOT A NEW PERSONAL OR JOINT APPROVAL.

Prepared at Mary's request for the next backend action. Complements the existing
[plain-language access proposal](Q07_Plain_Language_Access_Proposal_0.1.md);
neither supersedes reviewed Q06/Q07 0.1 or constitutes a new API/schema contract.
Actual scoped replies belong in [the existing ledger](CONTRACT-FREEZE-01_Team_Decisions.md).
No package, account, Auth configuration, registry, grant, SQL/RPC or endpoint change
is authorized. No remote inspection, invitation or native test is performed.

## 1. Inputs and boundaries

- [Kath response revision 3 receipt](Q06_Q07_Kath_Response_Rev3_Receipt_2026-11-02.md):
  E1–E3 BLOCKED; S3/S4/E4/E5 are design recommendations, not personal signatures.
- [Mary M01–M08](D04_D06_Mary_Backend_Position.md) and manual-result 0.2 scoped
  ACCEPT remain unchanged; no repeat Q05 review or M08 question.
- [Maintained backend guidance](../instructions/BACKEND.md): existing eggs/batch
  reported running autonomously on Arduino programmed by Ally; app disconnected.
  No connection, reset, reflash, module attachment, command, duplicate session,
  registration, settings synchronization or Active release to test this policy.
- Shared GLOBAL/PROJECT_CONTEXT/DECISIONS/ARCHITECTURE guides and running-batch
  handoff were not present at their referenced paths in this checkout. Use the
  maintained local guide/package review, not invented contents from another session.
- Intended phone remains Infinix Smart 8; exact native/device facts must be recovered
  by the client reviewer. Phone model, UUID and session pin are not device attestation.

## 2. E1 — concrete proposed pilot sign-in flow

**P1 (proposal): administrator-precreated/invited existing user; typed email OTP
for ordinary pilot sign-in; administrative binding is a separate action.**

1. An authorized human administrator, named privately before execution, verifies
   the intended user/inbox. Create/invite only that non-anonymous provider identity
   through a supported admin workflow outside the app. No shared passwords, privileged
   key in Android, public signup or app-controlled user creation.
2. For ordinary sign-in, the client requests a provider email OTP for the existing
   user, with the resolved SDK's equivalent of **`shouldCreateUser: false`**.
   Kath must verify the exact resolved SDK option and actual no-user-creation behavior;
   no exact API call is certified by this prose. Generic UI must not enumerate users.
3. Recommend typed OTP for this first pilot flow to avoid depending on a new custom
   activation/deep-link endpoint. If the provider's initial invitation requires a
   callback, that separate onboarding path remains BLOCKED until its exact verified
   redirect/template/SDK flow is agreed. Do not convert invite/magic-link/recovery
   token types interchangeably or consume an arbitrary callback URI.
4. OTP acceptance establishes provider authentication only. Verify trusted Auth
   subject, non-anonymous status, issuer/audience/expiry and session identity before
   any protected operation. Body IDs/email/decoded JWT alone are not verification.
5. First login is **authenticated but unbound**: protected data and receipt lookup
   remain denied until separately approved administrative installation/controller/
   session scope exists. The app cannot activate itself from a login callback.

**Still needed:** real admin/support recipient privately; actual provider flow and
sanitized configuration; Kath's exact SDK/options/UI and callback decision. This
is a recommendation to review, not an assertion that invites/OTP work with signup
disabled in the hosted project. If that combination fails, keep E1 blocked rather
than enabling public signup or silently creating users.

## 3. E2 — configuration/expiry evidence, not assumed defaults

**P2 (proposal): provider enforces OTP expiry, one-time use and rate limits;
no custom activation-code service or selected 30-minute window.**

| Setting | Proposed required policy | Current verified level |
|---|---|---|
| Public signup/anonymous sign-in | Protected pilot flow must not create users implicitly; proposed hosted signup/anonymous switches disabled subject to reviewed app migration | Local `config.toml` has both enabled; hosted UNKNOWN |
| OTP/invitation expiry, resend, failed attempts and replay | Provider-server enforcement; exact values and token-type semantics recorded before approval, not client countdown authority | Local email OTP expiry is 3600 and max_frequency is `1s`; NOT selected hosted values or proof of security |
| Access-token lifetime / refresh reuse | Preserve provider rotation/reuse protections; approve actual values and recovery behavior only from sanitized evidence | Local JWT expiry 3600, refresh rotation true/reuse interval 10; hosted/SDK behavior UNKNOWN |
| Redirect/template handling | Only exact approved application routes/templates; no wildcard acceptance, token logging or arbitrary URI navigation | Local site/redirect URLs are localhost; no Android callback approval established |
| Administrative binding lifetime | Separate from OTP/token expiry; active scope needs an explicitly reviewed expiry/revocation policy using trusted server time | No duration selected. Unspecified must not silently authorize indefinitely |

Local source settings are inspected text only. No hosted config was fetched, no
dashboard change made, and no existing secret/config was exported. A future evidence
record should identify project ref, observation time, authorized method, setting name,
sanitized value and limitation; omit inbox addresses, codes, tokens and keys.
Provider inspection beyond existing Q12 catalog scope requires its own permission.

Kath should define expired/resend/error UI and verified token/callback types; client
timers are advisory. Success/resend/sign-in is never administrative activation.

## 4. E3 — session pin and refresh/reapproval policy

**P3 (proposal): pin the approved tuple `(subject, session, installation, controller)`
plus authorization revision, capabilities and reviewed validity bounds.**

| Situation | Proposed protected-cloud behavior |
|---|---|
| New login, no active binding | Deny protected reads/writes; show awaiting approval, no data creation/rebinding |
| Access token expired, refresh possible | Pause protected requests; use only the reviewed provider refresh flow. Resume only with trusted valid token, unchanged approved subject/session and current registry scope |
| Token refresh changes only token material | Not automatic reapproval if verified subject/session and binding remain valid; actual SDK/provider invariants still need tests |
| New subject/session, lost session, new installation | Pause; require explicit admin reapproval/re-pin with audit and revision change; app cannot amend registry |
| Revoked/expired binding, valid Auth token | Deny every protected operation, including receipt/reconciliation reads; no automatic renewal from token possession |
| Auth service/network unavailable | No fallback to direct tables/cached cloud authorization. Preserve local evidence and uncertain write outcome; do not label it a proven 401/403 or no-commit |

Trusted verification plus current operation scope is required for each call and
replay. Auth sign-out or refresh-token revocation must not be assumed to invalidate
every already-issued access token immediately; registry denial is a separate guard.
If the agreed immediate provider-session-revocation semantics require an additional
server check, its supported implementation/test is a blocker, not presumed present.
No TTL, grace period or approved active lifetime is invented here.

The local HTTP adapter calls trusted Auth then checks claims and references three
RPCs. That is not proof of hosted JWT/RLS/session enforcement. Kath must inspect
the exact **resolved** SDK lifecycle and token-storage behavior, not just the pubspec
range. Package/Keystore/backup choices remain S1/S2 work; no plaintext fallback.

## 5. Binding, singleton and authorization transactions

**P4 (proposal): admin-only audited compare-and-set binding/re-pin/revoke/replace;
one active installation in the current single-incubator pilot.**

These are logical requirements, not approved table/endpoint names or runnable SQL:

1. Administrative caller authority comes from a separately verified supported
   admin channel, never a body `administrator=true` or mobile privileged credential.
   Validate subject/session/installation/controller, expected current revision,
   capability set, reason and reviewed lifetime before committing a binding.
2. Serialize changes for the pilot/controller slot. Recheck expected revision under
   lock; conflict on stale change, never last-writer-wins takeover. Activation must
   not infer controller identity or create a running-batch session from a phone name.
3. Re-pin/revoke/replacement must lock the same authorization scope consulted by
   protected writes. Increment revision and append sanitized before/after actor/scope/
   reason/request/outcome audit with the state change in one transaction. Failure
   rolls back both; do not lose audit of a committed change. No client audit mutation.
4. On replacement, revoke old scope and activate new scope atomically with no
   observable interval allowing both. If provider setup fails before that atomic
   step, no half-activated replacement. Preserve the old revoked mapping in history;
   do not delete/rewrite original batch/result/source actors.
5. Future protected writes acquire the relevant scope lock and recheck current
   authorization/capability/revision, expiry using server time **after lock wait**,
   trusted original mapping and content in the same transaction as persistence.
   Use consistent lock order and reviewed timeouts; no user input-controlled lock
   escalation. Edge precheck alone cannot protect a direct RPC caller.
6. Race meaning: if a write commits under valid scope before revocation takes the
   serialized boundary, preserve that fact; revocation does not undo it. If revocation
   wins, the later write denies. Lost replies stay uncertain until authorized lookup.
   Protected reads also recheck current scope; already returned bytes cannot be recalled.
7. Server-enforce one initial result per original controller/batch **across actors**,
   immutable action identity/content and lossless session mapping. Same action/content
   returns the original immutable receipt; changed content or competing initial result
   conflicts. Do not implement dedup only on current uploader or trust an Edge hash.

Old disabled SQL drafts are not this policy's implementation: they hard-disable
registry/source capability, have no admin activation/replacement operations or real
ledger, and list only historical v1 operations. They do not authorize result-only
0.2 by name, implement the proposed active-lifetime policy or prove post-lock expiry
and direct-access bypass safety. Keep all bytes/locks unchanged pending reviewed work.

## 6. E4/E5 — logout, in-flight results and recovery grants

**P5 (proposal): local logout first fences dispatch/callbacks and locks the vault;
cloud deauthorization and provider logout have separately reported outcomes.**

- Stop new dispatch; advance durable owner/session generation using Kath's reviewed
  atomic mechanism. Ignore stale callbacks for a different owner/generation without
  discarding the original uncertain submission. Lock protected local access and
  preserve encrypted evidence plus its separate key.
- Clear cloud credentials through the reviewed SDK sign-out flow. Report remote
  logout/revocation as pending/unknown if offline or unconfirmed; local logout is
  not proof of cloud deauthorization or request cancellation. Do not fabricate a
  sign-out endpoint or call a registry operation that does not exist.
- Existing cloud submission may commit. Reconcile original identity only after
  current authorized recovery access; never create a replacement action to hide it.
- No cloud logout, denial or revocation sends Start/Stop/Reset/settings or instantly
  revokes an offline old phone's vault/controller access. State that limitation.

**P6 (proposal): replacement historical access is explicit read/reconciliation-only
for named original controller/batch/receipt scope in this first slice.**

No broad History grant, implicit transfer or replay permission follows from replacement
login. Default denies historical writes, altered counts, corrections, finalization,
reopening batches and uploading an old actor's local actions. A future write-recovery
grant needs separate original-evidence/actor validation and agreed semantics; don't
invent it here. New authorized work still needs its own capability/source gates.
Lost local-only facts cannot be recovered from a nonexistent server record; no
export/import or local-only recovery guarantee is selected. Knowing IDs is not a grant.

## 7. Exact remaining owner answers

| Owner | Missing decision/evidence |
|---|---|
| Mary | Privately name authorized admin/support and controlled inbox; personally accept/change P1–P6 and active-lifetime/reapproval/recovery policy. No email address or credential disclosure requested in the technical reply |
| Kath | Existing-user OTP option/no-creation behavior; initial invite vs ordinary OTP routes; resolved SDK refresh/session/sign-out semantics; durable generation fencing; UI for unbound, denied, offline and unknown outcome |
| Mary + authorized project owner | Separately scoped sanitized hosted config inspection if desired; actual supported provider token-type/expiry/replay/rate-limit values and callback settings. Existing catalog approval does not cover arbitrary Auth inspection |
| Mary + Kath | Exact reviewed native/key/lifetime/recovery choices and acceptance scope; actual attributable agreement, not treating assistant recommendations as signatures |
| Ally/shared | Selected source/auth/manifest/retention/admission/time facts, independently. Policy design does not unlock source ingestion or existing-batch registration |

## 8. Future acceptance cases — NOT RUN by preparing this policy

| Case | Required result |
|---|---|
| Unknown user OTP/signup | No implicit new user/capability; generic UX and verified provider no-creation behavior |
| Invited but unbound user | Authentication may succeed; protected upload AND receipt/history reads deny |
| Expired/reused invite/OTP, resend and malicious callback | Provider rejection and reviewed client handling; no scope activation/logged tokens |
| Same-session refresh vs changed session | Only verified same approved tuple continues; changed tuple needs explicit reapproval |
| Revocation vs write; expiry while waiting for lock | Serial boundary/expiry rules above hold; no stale-authorized commit after revocation wins |
| Replacement vs stale re-pin/double activation | Expected-revision conflict and singleton enforce one active scope; complete audit or rollback |
| Logout/restart/late callback/lost response | No new dispatch/cross-owner state update; original uncertain outcome preserved and later scoped lookup |
| Recovery read vs old-actor write | Only explicit historical read scope allowed; old-actor upload/correction denied absent separate grant |
| Direct table/RPC bypass and source gate | Same protected-data constraints cannot be bypassed; disabled source remains disabled; no controller commands |

Testing requires exact patch/target/identity/fixture/configuration authorization and
cleanup/readback plan, plus native permission where applicable. Current Q12 attempt
and later-phase limits remain in [Q12 status](../integration/cha-execution/q12-phase-a-status.json).
No production, running-batch or hardware operation is part of this policy.

## 9. Send to Kath — scoped response request

> Kath, this is the backend technical companion to the existing plain-language
> access proposal, not a new Q05 review or an implementation request. Please review
> Q07_Provider_Session_Binding_Policy_0.1.md against its exact hash and return
> ACCEPT/CHANGE/BLOCKED for P1–P6 at design scope. In particular, confirm the
> supported existing-user typed email-OTP flow with no implicit signup, initial
> invite/callback needs, same-session refresh/new-session reapproval, local vs
> remote logout outcomes, worker fencing and read-only historical replacement scope.
> Mark actual provider/native/SDK facts unverified unless evidenced. I will
> coordinate the administrator/support and hosted configuration separately; no
> expiry value, account, active binding, native package or physical-phone guarantee
> is selected by this draft. Preserve M01–M08 and manual-result 0.2 ACCEPT. No
> installs, remote inspection/mutations or occupied-controller work requested.

Reply with responder/role/date, policy revision/hash, P-row, disposition, exact
replacement or missing fact, evidence level, next owner. No external send, new
member approval or task completion is claimed here. Revise with distinguishable
bytes/revision after actual feedback; preserve the exact reviewed inputs.
