# DB-IMP-01 — disabled database foundation and regression record

**Task ID:** CURRENT:DB-IMP-01 · **Display:** DB-IMP-01 · **Source:** CURRENT
**Owner:** Mary Charlyn · **Date:** 2026-10-29
**Status:** safe offline patch/fixtures complete; full migration, RPC implementation
and actual security/persistence acceptance BLOCKED. NOT DEPLOYED.

## What I actually changed

- Added [candidate registry migration draft](../../supabase/drafts/DB-IMP-01_disabled_registry.sql)
  outside `supabase/migrations/`, so normal migration discovery cannot apply it.
  It defines only the two proposed private registry tables from DB-02, with explicit
  client ACL revocations, RLS enabled/forced and no allow policies. CHECKs hard-lock
  controller active/contract_enabled and installation active to false. Ordinary
  row updates cannot enable ingestion. It contains no enable/provisioning step.
- Added [closed-gate fixture expectations](../../test/fixtures/integration/db_imp_01_closed_gate.json)
  referencing all six existing submission examples, without duplicating/changing
  their hash-pinned bodies, wire fields, count/time/profile values or source selection.
- Extended the existing HTTP test file with six initial/retry closure scenarios.
  Successful Auth/authorization stubs do not bypass the real disabled source adapter;
  no receipt, entry, session or ingestion call is produced. Farmer completion with
  null wire evidence is also blocked.
- Reused the existing Edge entrypoint, core, Supabase ports and loopback server
  unchanged. No fixture adapter was imported into production source. Missing config,
  invalid Auth or denied registry still return their existing errors; a structurally
  valid submission with accepted Auth/registry reaches `CONTRACT_NOT_ENABLED` 503.
  Errors are not all flattened to the contract code, and no validation was weakened.

## Files modified / added

- Added `supabase/drafts/DB-IMP-01_disabled_registry.sql`.
- Added `test/fixtures/integration/db_imp_01_closed_gate.json`.
- Modified `test/backend/bridge_sync_http_test.mjs` (six new tests).
- Added `docs/integration/logs/2026-10-29-db-imp-01-node.tap` (actual runner output).
- Added this report; updated `INT-IMP-01_Evidence.md` and the bridge-sync README
  to link this separate implementation-task continuation.

No Flutter, firmware, existing migrations, DB-02 pinned review documents, cloud
config or original fixture bodies changed. No `incubator_sessions` or
`sensor_readings` alteration or data update appears in this draft. Existing
`egg_quantity`, `eggs_hatched`, IDs, defaults, global Active guard and History are
preserved. No legacy row ownership or timestamp is inferred.

## Tests performed / actual results

New execution (not the supplied 64/20 evidence):

```powershell
if (Test-Path -LiteralPath "docs/integration/logs") { node --test --test-timeout=15000 --test-reporter=tap --test-reporter-destination="docs/integration/logs/2026-10-29-db-imp-01-node.tap" "test/integration/int_imp_01.test.cjs" "test/backend/bridge_sync_http_test.mjs" "test/backend/bridge_monitoring_test.mjs" } else { throw 'Evidence log directory missing' }
node --check "test/backend/bridge_sync_http_test.mjs"
```

Full runner output: [DB-IMP-01 TAP log](logs/2026-10-29-db-imp-01-node.tap).

```text
1..70
# tests 70
# suites 0
# pass 70
# fail 0
# cancelled 0
# skipped 0
# todo 0
```

The log includes all original positive/negative/retry cases and six new closure
cases (`ok 32`–`ok 37`). Syntax check returned success without output.
`git diff --no-index --check -- "NUL" "<path>"` was also run for the SQL draft,
JSON fixture, HTTP test, this report, INT ledger and bridge README: no whitespace
errors; only Git LF-to-CRLF normalization warnings. This report was checked again
after its final update. This is a text check, not PostgreSQL validation.

| Required fixture class | New-run evidence | Boundary |
|---|---|---|
| Authorized candidate evidence | TAP `ok 16`, `ok 24`–`ok 26` | Accepted only with test adapter and Auth/RPC stubs; not real authorization approval |
| Unauthorized / anonymous / revoked | TAP `ok 18`–`ok 19` | Boundary stub behavior, not real JWT/RLS/session-revocation proof |
| Duplicate / changed-content conflict | TAP `ok 16`, `ok 25` | Stub storage; no SQL uniqueness/concurrency proof |
| Wrong source / source-body mismatch | TAP `ok 20`–`ok 21` | Candidate fixture checks; active producer absent |
| Retry / lost response / reconciliation | TAP `ok 27`–`ok 29` | Real HTTP socket/receipt validation, stub storage |
| Closed contract, initial and repeated submission | TAP `ok 32`–`ok 37` | Actual disabled adapter, accepted Auth/registry stubs, zero ingestion calls |

The supplied **20/20 targeted parser checks were reused, not rerun**: no Flutter
code changed. Supplied four source syntax checks remain prior evidence. See
[S1 attribution](logs/2026-10-29-supplied-checks.md). No full Flutter suite/release
build or Deno runtime/type check is claimed.

New source inspection: a content search in `lib/**/*.dart` for
`service.role|service_role|sb_secret_` returned no matches. No Flutter file or
credential was added. This limited marker search is not a complete secret scan
or a claim about externally provisioned secrets/compiled assets.

## Evidence / source revision

Initial commands: `git status --short --branch`, `git branch --show-current`,
`git rev-parse HEAD`. Checkout remains `cha-branch2` at
`c7a26cfcaa619708aff4f793e8068ee176a6cf58`. Local implementation/draft/test files
are uncommitted; HEAD is not an implementing commit for them.

Inspected existing migration `20260929070513_remote_schema.sql:98-107` for
`egg_quantity integer DEFAULT 0 NOT NULL` and `eggs_hatched integer DEFAULT 0`;
DB-02 schema/security and exact API drafts; current shared ports/handler, Edge
entrypoint and HTTP fixtures. No database was queried. Earlier
[repository inspection](logs/2026-10-29-repository-inspection.md) remains provenance,
not a new active-source selection. New draft is based on candidate DB-02 registry
names/alias rules only; it creates no source mapping or approval.

## Errors

New Node tests: zero failures. No error is assigned to Ally/Kath merely because
their dependent slices cannot run. Any future SQL/port failure belongs to Mary
Charlyn until triaged; no SQL result is claimed here. SQL has **not been parsed,
applied, rolled back or tested against PostgreSQL**. No mock substitutes for it.

## Remaining blockers / deployment blockers

1. **Mary Charlyn — authorized isolated database:** no running authorized instance
   supplied. Earlier Docker unavailable / hosted smarthatch-test INACTIVE state
   was not rechecked, resumed or modified. Review actual object ownership/default
   privileges/roles/Auth claims and whether `private` already exists before any
   separately authorized application. This draft deliberately errors on existing
   schema/object collisions instead of adopting/replacing unfamiliar objects.
2. **Mary Charlyn — actual security/transactions:** required
   `bridge_sync_authorize_v1`, `bridge_sync_ingest_v1`, `bridge_sync_reconcile_v1`
   remain UNIMPLEMENTED. This foundation creates none of them. It does not fix
   legacy public grants/policies/default privileges/direct-write bypasses. Event
   ledger, provenance, enrollment/processing audits, atomic dedup/projection,
   direct-RPC validation and least-privilege grants still require the real-stack
   implementation/tests. RLS syntax in an unexecuted draft is not a security pass.
3. **Ally — exact active producer:** active sketch + matching catalog + implementing
   commit/paths (or exact files) absent. No local sketch/branch observation selects
   them. Gate remains disabled, no lossless IDs/epochs/timestamps invented.
4. **Kath — compatible Android implementation:** same-revision decoder, HC-05
   Classic SPP permissions/pairing/lifecycle and transactional local store/device
   logs absent. Existing parser characterizations do not implement these.
5. **Physical integration:** separate explicit authorization and qualified documented
   safety clearance required. No hardware was opened or driven.

Do not move this draft into automatic migrations or enable registry rows/adapter
to work around a dependency. All three hard-disable CHECKs are intentional. Future
enablement needs a distinct reviewed patch only after source/security gates pass.
No main-project use, service-role key on Android, deployment or production writes
are authorized. No automatic Start retry is introduced.

## What still needs verification

PostgreSQL syntax/ACL/default-deny behavior; actual non-anonymous Auth signature/
session/issuer/refresh/revocation behavior; registry/direct-RPC/direct-table bypass;
transaction rollback/commit ambiguity; simultaneous duplicate/conflict/revocation;
stable persisted receipts and projection dependencies; legacy schema/History
compatibility; exact source validation; Android storage/Bluetooth; notification
delivery and safety-cleared end-to-end operation. RTC/original Start, Day N and
freshness still require attributable trustworthy time, never cloud receipt time.
Three-species software support is not numeric profile approval or physical proof;
physical pilot remains Chicken-only, fresh eggs, incubator-only, manual counts.

## Related tasks — no completion inference

ORIGINAL:A-04; ORIGINAL:C-01–C-09;
OCT26:C-01, OCT26:C-02A, OCT26:C-02B, OCT26:C-02C,
OCT26:C-03–C-11. These relationships are coverage context only. No related task's
acceptance result is changed or inferred complete by this patch.

## Recommended next task

Make a separately authorized isolated Supabase instance available for Mary Charlyn
to review/execute the disabled foundation and implement/test the atomic RPC and
security migration. In parallel obtain Ally's exact producer/catalog set and
Kath's compatible implementing patch. Keep source ingestion disabled throughout.
