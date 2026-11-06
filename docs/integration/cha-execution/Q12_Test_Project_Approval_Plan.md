# Q12 — staged test-project inspection and implementation approval plan

**Prepared:** 2026-10-31 · **Owner:** Cha/Mary (backend only).
**Status:** PLAN PREPARED; remote inspection NOT AUTHORIZED / NOT RUN.
Mary's “alright lets do your recommendation” authorized this preparation only.

## 1. Fixed boundary

- Only **smarthatch-test**, project reference **`zbwntspdecngnicllwlw`**;
  approved API origin, if needed in a later separately approved phase:
  `https://zbwntspdecngnicllwlw.supabase.co`.
- Explicitly exclude main project **`suopuhgtwyqkpupzvdng`**, production, and all
  other projects. Never rely on a CLI's currently linked/default project.
- No credentials in documents, commands, transcripts or evidence. Do not request
  pasted passwords, JWTs or service-role keys. Use an authorized existing secure
  connection; stop if one is unavailable or its target cannot be verified.
- No Flutter/firmware edits, installs, physical commands, flashing, powered tests,
  deployments, commits, pushes, merges, task completion or formal K06 adoption.
- Real source acceptance stays disabled. No adapter selection, invented trusted
  manifest, physical Start replay, fabricated Stop/timestamp or retention release.
- Preserve existing data/objects and all prior reviews, logs and ZIPs. The earlier
  narrow role/fixture probe permission is history, not permission for these phases.

## 2. First independently approvable phase: A — read-only catalog inspection

**Purpose:** establish actual schema/security metadata before proposing mutations.
Does not require Ally's source decision. Does not exercise an application endpoint
or prove Auth/JWT, RLS enforcement, concurrency, ingestion or manual-result safety.

### Exact proposed operations

1. Verify the selected connection's project reference against the explicit test
   reference above before connecting. Record only the reference and verification
   method, not its DSN/credential. A database named `postgres` is NOT project proof.
   No new connection, login or project access has been performed while planning.
2. On that verified existing connection, run the sibling
   [Q12_Phase_A_Read_Only.sql](Q12_Phase_A_Read_Only.sql) unchanged: one explicit
   **READ ONLY, REPEATABLE READ transaction**, short local statement/lock timeouts,
   bounded catalog queries, then **ROLLBACK**. No application/auth-table row reads,
   stored-function execution, `EXPLAIN ANALYZE`, writes or DDL.
3. Save sanitized outputs locally in a new run-owned directory, together with
   UTC run time, approved phase/text, SQL SHA-256, target verification, tool/version,
   each command/result/error and transaction exit/rollback confirmation.
4. Compare the resulting metadata against the drafts and report missing objects,
   collisions, owners, grants and policies. Propose an exact next patch only; do
   not automatically apply a draft or broaden this authorization.

### Objects read, never changed

| Catalog | Bounded scope / purpose |
|---|---|
| `pg_namespace`, `pg_class`, `pg_attribute`, `pg_attrdef` | `public`/`private` table/view/sequence metadata, columns/default expressions, owners, ACLs, RLS/FORCE RLS flags; schema ACLs also for `auth` |
| `pg_constraint`, `pg_index` | Constraints/index definitions of `public`/`private` tables; check existing Active guard without changing it |
| `pg_policy`, `pg_trigger` | Policy and non-internal trigger definitions for those tables; detect permissive alternatives and side effects |
| `pg_proc` | Metadata/ACL/security-definer/search-path/owner/signatures of bridge_sync-prefixed functions and audit helpers in `public`/`private`; only `auth.uid()`/`auth.jwt()` helper signatures, not bodies or calls |
| `pg_roles`, `pg_auth_members`, `pg_default_acl` | Attributes/memberships of current connection role, `anon`, `authenticated`, `smart_hatch_bridge_owner`; `public`/`private` and global default ACLs; no password catalogs |

No table contents, `auth.users`, `auth.sessions`, token/key configuration, function
bodies, project secrets or REST responses are requested. Metadata expressions may
still contain sensitive literals: inspect/sanitize before saving or sharing.
Results above a query's limit are incomplete, not proof of absence; stop and
propose a narrower follow-up instead of silently expanding scope.

### Expected results, stop conditions and cleanup

- Missing draft objects are a valid finding, not permission to create them.
  Existing objects are not automatically trusted/adopted/replaced.
- An insufficient privilege error is an inspection limit: record SQLSTATE and
  stop. No granting, role switching, privilege escalation or fallback project.
- Stop on target mismatch/uncertainty, unexpected sensitive output, query timeout,
  result overflow, changed SQL bytes, unapproved tool operation or any write/DDL
  requirement. End/rollback the transaction; preserve sanitized failure evidence.
- Expected database delta: **none**. On SQL error issue `ROLLBACK` on the same
  connection; if disconnected, PostgreSQL aborts its open transaction, but mark
  explicit rollback confirmation unavailable until verified. Close the connection.
- Read-only mode is a guard, not a sandbox for arbitrary functions: execute only
  the fixed catalog script. Ordinary connection/service logging can still occur.
- No fixture/account/object is created, so no delete/drop cleanup is permitted.
  Capture the ROLLBACK result and idle/no-open-transaction connection state where
  supported. Inability to confirm this is reported, not called a verified cleanup.
  Later run-owned-object absence checks apply only to separately approved phases.

**A acceptance:** attributable bounded outputs and rollback confirmation, or a
truthful blocked/partial report. This does not close Q12 or any whole task.

## 3. Why none of the existing SQL drafts is approved for application

Inspected completely as local text only; not parsed/executed against PostgreSQL.

| Draft | Exact affected objects if separately approved later | Current limitation |
|---|---|---|
| `supabase/drafts/DB-IMP-01_disabled_registry.sql` | Creates `private` schema, `private.controllers`, `private.authorized_installations`; table constraints/implicit indexes, schema/table revokes, ENABLE/FORCE RLS | Hard CHECKs keep controller/installation inactive and contract disabled; no policies/rows, no legacy public-table repair |
| `DB-IMP-01_authorization_schema_draft.sql` in same directory | Creates/reuses `smart_hatch_bridge_owner`; grants membership to migration role and schema/auth-helper privileges; adds eight installation columns, checks, `db_imp_01_one_active_installation`; creates `private.enrollment_audit`, identity sequence, two indexes, three owner policies, `private.enrollment_audit_immutable()` trigger function and trigger, `private.record_enrollment_audit(...)`, `private.bridge_sync_authorize_impl(uuid,uuid,boolean)`; function ownership/grants/comments | Managed-role/ownership/Auth-helper compatibility unverified; no admin workflow or approved expiry; hard locks remain; role reuse requires inspection, not silent adoption |
| `DB-IMP-01_bridge_sync_rpcs_draft.sql` in same directory | Creates/owns/grants EXECUTE on `public.bridge_sync_authorize_v1(uuid,uuid)`, `public.bridge_sync_ingest_v1(jsonb,text)`, `public.bridge_sync_reconcile_v1(jsonb,uuid)` | Ingest/reconcile deliberately raise `EVIDENCE_LEDGER_NOT_IMPLEMENTED` (`0A000`); Edge non-retryable mapping still missing; no ledger/receipt implementation |

These are older event/reading drafts, **not manual-result 0.2 implementation**.
Kath's scoped ACCEPT does not approve these SQL bytes, remove hard locks, choose
storage/enrollment, or establish original-manifest trust.

## 4. Later phases — NOT covered by phase A consent

Each requires a new exact, hashed operation manifest after inspection. No wildcard
approval of this table, unspecified “necessary changes,” or all existing drafts.

| Phase | Proposed boundary | Prerequisites and explicit consent needed |
|---|---|---|
| B — actual Auth/session probe | Run-owned non-anonymous test user/session only; sign-in, refresh, sign-out/revocation checks; no registry activation | Q07 actual owner/bootstrap/session/recovery choices; exact account count/identifiers and Auth endpoints/actions, effects and cleanup disclosed first. Do not create an anonymous user merely to test denial without its own permission |
| C — disabled foundation test | Separately reviewed transaction-local schema/role/constraint/grant/policy tests, still hard-disabled | A inventory plus exact revised SQL and role compatibility plan. Existing objects are a stop/collision, not overwrite targets. No permission to apply the three current COMMIT-ending drafts |
| D — result-only persistence/security implementation | Future exact manifest/mapping/result/receipt objects and narrowly scoped RPCs; atomic authorization and persistence; preserved Active/status/end_date | Trusted manifest/source binding, Q06/Q07 inputs where applicable, exact new schema/API implementation/legacy bypass remediation and rollback design. No concrete result-table names or enablement patch are approved yet |
| E — endpoint and integration | Future explicitly named test-project deployment/config plus client-specific work by Kath only under her own authorization | Approved D artifacts, corrected error mapping, auth/raw-parser/security/concurrency evidence and separate deploy/rollback approval; real firmware ingestion remains separately gated by Ally/source/security evidence |

**Required test expectations for any later exact implementation plan:**
- No/invalid/expired/unverified Auth: authentication denial; authenticated but
  wrong user/session/installation/device/capability, revoked/replaced/expired or
  inactive enrollment: protected-operation denial without leaking another scope.
- Missing original trusted manifest/mapping: reject recording, never invent it.
- Same original action/core retry: same immutable receipt; changed core under
  same identity: conflict; competing initial results: at most one committed result.
- Receipt/mapping/result atomicity, ambiguous commit recovery, revocation races,
  direct-table/RPC privilege bypass, trigger/policy composition, and rollback must
  be exercised against real approved objects, not inferred from schema/model tests.
- Result-only success never changes Completed/end_date/Active/admission, emits a
  physical command or changes `retention_ack:null`.
- Permanent disabled/unimplemented conditions must not appear as retryable
  success/outage. Actual PostgREST/Edge mappings must be captured, not assumed.
  Current hard-disabled drafts cannot demonstrate successful authorization or
  persistence. Forged SQL claims test predicates only, never real JWT validity.

## 5. Mandatory rollback/cleanup design for every later mutation request

Before consent, supply exact object signatures, baseline definitions/owners/ACLs/
policies, operation order, run-owned fixture identifiers, expected SQLSTATE/HTTP
results, concurrency schedule and post-cleanup queries. No shared-object DROP
CASCADE, broad DELETE, auth-user deletion with unreviewed cascade, or role reuse.

- **Transactional trials:** explicit BEGIN/savepoints and final ROLLBACK, no
  embedded COMMIT. PostgreSQL transactional DDL does not make Auth/HTTP/deploy
  side effects transactional; identity sequence increments on pre-existing
  sequences may survive rollback. Plan/approve these separately.
- **Committed changes:** require separate consent and exact inverse patch. Restore
  only recorded run-owned changes; never drop/recreate shared schema/role or erase
  existing rows/history. If safe reversal cannot be demonstrated, do not proceed.
- **Auth accounts/sessions:** keep exact run ownership; invalidate run sessions,
  then delete only approved run accounts after checking dependencies. Prove absence
  via approved admin readback and denial of the old session, without saving tokens.
- **Fixtures:** use explicit approved primary keys and dependency order. Audit
  append-only triggers mean DELETE may be intentionally forbidden: use transaction
  rollback or obtain a separate retention/disposal decision, not a trigger bypass.
- **Schema/roles/RPCs:** compare baseline and post-cleanup catalogs; prove new
  run-owned objects/membership/grants absent and pre-existing definitions intact.
- **Deployment:** restore the exact prior version/config only if separately
  approved, verify behavior and source-disabled gate. No blanket environment reset.
- Report cleanup failures immediately; stop further work. Do not claim a restored
  baseline on commands succeeding without readback, or erase failure evidence.

## 6. Mary's first approval checklist

Approve only when you are authorized to permit access to this test project:

- [ ] I authorize phase A only, using the exact sibling SQL file reviewed here.
- [ ] Target is `smarthatch-test` / `zbwntspdecngnicllwlw` only; main/production excluded.
- [ ] Existing secure connection, bounded metadata-only reads, local sanitized
      evidence and final rollback/connection closure are permitted.
- [ ] No account/fixture writes, schema/RLS/grant/RPC changes, deployments,
      source enablement or later phases are authorized by this approval.

Suggested reply (not an approval until Mary actually supplies it):

> I am authorized for smarthatch-test. I approve Q12 phase A read-only catalog
> inspection only for zbwntspdecngnicllwlw using Q12_Phase_A_Read_Only.sql as
> prepared on 31 Oct, with sanitized local evidence and rollback. No mutations,
> deployments, production access or later phases are approved.

If authority is uncertain, obtain the test-project owner's consent instead.
No renewed M08 approval or general Kath 0.2 review is requested.

## 7. Evidence/status boundary

Plan and SQL preparation are local documentation work only. All remote phase A–E
operations remain NOT RUN, all 24 manual-result implementation and 102 portfolio
cases remain NOT RUN. No new full task completion/status change:
**7 Completed / 9 Partial / 25 Not started / 1 Superseded**.
Original full HTML/storage, source Downloads HTML and existing review packages
remain unchanged. The current decision ledger links this plan; older packets
remain historical snapshots rather than silently regenerated deliveries.
