# Approved test-project security probe — OCT26:C-01

**Owner:** Mary Charlyn L. Aguirre · **Priority:** P0  
**Initial/final task status:** Partial → Partial; security acceptance **not met**.  
**Run:** `2026-10-29T19-29-38-293Z` (October 30 in Asia/Manila).

## Latest approval and stopping point

The user's explicit approval supersedes the earlier **local-preparation-only**
restriction for this narrowly scoped test. It does **not** approve schema/policy
changes, RPC activation, deployments, production access, commits, or decisions
owned jointly with Kath/Ally. Earlier reports are retained as historical attempts.

No further task was started. The audit remains Partial because intended secure
installation access is not implemented/verified. After observing the current
security gap, testing stopped without changing its policies or enrolling a
pretend authorized installation.

## Target and current implementation

- Reverified using current CLI account metadata: TEST `smarthatch-test`,
  `zbwntspdecngnicllwlw`, `https://zbwntspdecngnicllwlw.supabase.co`, ACTIVE_HEALTHY,
  not linked. The application project remains separately linked; no relinking or
  application SQL was performed.
- Fresh test-project catalog matched the earlier snapshot for application tables,
  columns, policies, grants, default ACLs, constraints and indexes. No unreviewed
  drift was adopted. Read-only preflight passed before writing fixtures.
- Four application tables/22 columns/13 policies remain in the catalog. The
  three `bridge_sync_*_v1` RPCs are still absent. Existing Flutter anonymous
  auth/direct-table behavior and source-ingestion gate were not changed.

## Actual remote test

One transaction acquired a NOWAIT write-conflicting lock on `sensor_readings`;
used a two-second lock timeout and twenty-second statement timeout; checked for
unknown noninternal triggers, foreign keys and exact fixture-ID collisions;
and tested only synthetic rows at explicit negative IDs. No sequence values,
session/Active records, settings, existing sensor values or Auth users were used.

`SET LOCAL ROLE` selected real PostgreSQL `anon` / `authenticated` roles.
`request.jwt.claims` contained a synthetic UUID, **not a signed JWT**. This is a
real database role/RLS exercise, not a real login, token validation, anonymous
Auth session, designated-installation, revocation or Android integration test.

| PostgreSQL role | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| `anon` | 2 fixture rows readable | 1 fixture inserted | 0 rows affected | 0 rows affected |
| `authenticated` | 2 fixture rows readable | 1 fixture inserted | 0 rows affected | 0 rows affected |

- **8 probes executed**, zero unexpected SQL errors.
- **4 allowed operations** (SELECT/INSERT for both roles) demonstrate the missing
  installation restriction on these tested sensor-row operations. This is a
  security finding against the intended scoped model, not a newly introduced
  regression or a claim about all tables.
- Four UPDATE/DELETE probes affected zero rows. No SQLSTATE 42501 was returned;
  do not describe them as privilege exceptions or a complete security pass.
- **Unconditional ROLLBACK executed.** A separate read-only exact-ID query
  confirmed **0 remaining fixture rows**.
- **Auth users created: 0.** No end-user/installation provisioning was necessary.
- No migrations, schema/RLS/grant changes, RPC activation, deployments, firmware,
  Flutter edits or Git commits.

Exact transaction fixture IDs are in the log; cleanup touched only this
transaction's three generated IDs. No broad deletion or cleanup of other work.

## Files, commands, evidence

New runner: `docs/integration/cha-execution/run-approved-security-test.cjs`.
It requires an explicit execute flag, hard-pins/excludes project refs, refreshes
catalogs, stops on schema drift, and logs sanitized results without credentials.

```powershell
node --check docs/integration/cha-execution/run-approved-security-test.cjs
node docs/integration/cha-execution/run-approved-security-test.cjs
node docs/integration/cha-execution/run-approved-security-test.cjs --execute-approved-probe
```

Actual evidence under
`docs/integration/cha-execution/security-run-2026-10-29T19-29-38-293Z/`:

- `verified-target.json`: current target/isolation metadata and approval boundary.
- `fresh-catalog.json`: actual preflight catalog response.
- `probe.sql` / `probe-results.json`: full rolled-back transaction and eight results.
- `verify-cleanup.sql` / `cleanup-results.json`: independent exact-ID absence check.
- `status.json`: SECURITY_GAPS_OBSERVED; eight probes, four allowed, four zero-row,
  no unexpected errors, verified rollback and no Auth users created.
- `cli-role-initialization-note.txt`: CLI emits “Initialising login role”. Its
  internal administrative role initialization is not independently audited;
  this is not a claim that absolutely no platform-side effect occurred.

The preceding successful preflight-only run is preserved in
`security-run-2026-10-29T19-29-18-577Z/`. An initial runner invocation failed while
quoting CLI arguments through cmd.exe and produced CLI help, not a SQL result.
The launcher was corrected to invoke the `.cmd` shim through PowerShell, without
changing execution policy; the failed log is preserved in its original run folder.

## Acceptance and what remains

| Acceptance area | Result |
|---|---|
| Fresh test target and schema verification | PASSED within logged catalog scope |
| Narrow real role/RLS fixture matrix | EXECUTED; sensor SELECT/INSERT security gap observed |
| Rollback of this probe and exact-ID absence | PASSED; not a transaction-safe bridge-sync implementation test |
| Intended installation-scoped security | FAILED / not implemented |
| Real signed JWT/Auth/revocation/authorized installation | NOT RUN / shared identity decisions unresolved |
| Other three application tables and ownership isolation | NOT RUN |
| Real RPCs, ledger, idempotency/concurrency/receipt recovery | BLOCKED; routines absent, contracts/implementation unresolved |
| New backend Node/Flutter regression suites | NOT RUN; no application/backend implementation changed |
| Physical HC-05/Uno/Android integration | REQUIRES PHYSICAL HARDWARE TESTING |

Kath must agree the concrete authentication/direct-table compatibility transition;
Ally must supply the canonical source identities/catalog and retained evidence.
Use `TEAM_APPROVALS_AND_LOCAL_PLAN.md` for the exact file/decision map. No missing
team answer was fabricated or replaced by this user's test authorization.

**Next:** obtain those specific shared decisions and review a separate security
remediation/test design. Do not silently apply SQL drafts or skip to another
task. The current approval does not authorize fixing permissive policies.

The complete HTML, task reports, handoff and additive report JSON are updated with
this separate stable-ID attempt; prior reports/statuses are preserved. Subsequent
portal checks are static unless explicitly recorded as new browser tests.
