# C-01 audit completion review — supplied SQL exports and verified evidence

## Outcome: two audit tasks Completed, not a blanket security pass

The earlier assessment incorrectly kept **audit work** Partial because the
**implementation being audited** still has security/integration problems.
Those are different acceptance criteria. Finding and recording a vulnerability
can complete an audit without fixing the vulnerability or passing deployment gates.

Both audit records below have now been checked individually against their actual
portal requirements. No other task inherits completion from this review.

| Task | Owner / priority | Initial → final | Exact acceptance and evidence |
|---|---|---|---|
| ORIGINAL:C-01 — Audit the current database schema | Mary Charlyn / P1 | Partial → **Completed** | Written audit based on actual schema, listing tables, columns, RLS/policies, grants, routines/RPCs and Edge Functions; risky policies explicitly identified. The independently targeted test catalog, prior application inventory (historical only), fresh test Edge Function listing, and this report meet that inventory/audit scope. |
| OCT26:C-01 — Complete Supabase schema, access-control, and integration audit | Mary Charlyn / P0 | Partial → **Completed** | Actual-schema inventory plus access-control findings and source-based integration gap assessment are documented. Its portal verification is “List tables, columns, policies”; acceptance is “Audit based on real schema”, not successful remediation, deployment or physical end-to-end operation. |

Neither task requires implementing the missing RPCs or obtaining a secure result
from every downstream integration test before the **audit** itself is finished.
Shared decisions remain prerequisites for those implementation tasks, not for
honestly documenting their absence. This is a scope correction, not fabrication.

## Nine supplied CSVs: fully read, hashed and cross-checked

| Supabase Snippet Untitled query export | Contents | Use / limitation |
|---|---|---|
| (6).csv | 13 RLS policies | Public/authenticated permissive policies; matches test catalog. |
| (7).csv | 8 table/role grant rows | Both roles have SELECT/INSERT/UPDATE/DELETE/TRUNCATE grants; privilege flags alone do not establish row-policy outcomes. |
| (8).csv | 1 routine privilege row | `public.rls_auto_enable`, security definer; not a bridge-sync RPC. |
| (9).csv | Function definition | Event-trigger helper enabling RLS on newly created public tables; not ownership restrictions or ingestion implementation. |
| (10).csv | 1 event trigger | `ensure_rls`, ddl_command_end, enabled; this property is supplied export evidence, not freshly re-queried event-trigger catalog proof. |
| (11).csv | 4 primary-key constraints | No extra ownership/batch/hatch-count CHECKs are established by this export. |
| (12).csv | 5 indexes | Includes the single-Active-session unique index; does not make Start physically confirmed/idempotent. |
| (13).csv | 22 columns across 4 tables | Names/types/nullability/defaults match the independently verified test catalog. |
| (14).csv | 4 identity columns | BY DEFAULT bigint IDs; null column_default is not proof that identity generation is absent. |

`supplied-csv-review.json` records every row and SHA-256. Eight offline consistency
checks passed. The original Downloads files were not changed. CSVs contain no
project ref, original executed SQL, execution role, trustworthy observation time,
or CRUD fixture outcomes. Their structural agreement with the test catalog does
**not** identify their original project. No production state is inferred from them.

## Independently verified database scope

TEST: `smarthatch-test`, `zbwntspdecngnicllwlw`,
`https://zbwntspdecngnicllwlw.supabase.co`. Target/isolation and actual catalogs
were verified in the retained approved run. Four public application tables:

- `active_settings`: 5 columns; no singleton/session ownership constraint found.
- `incubator_presets`: 5 columns; audit does not approve numerical profile rows.
- `incubator_sessions`: 8 columns; existing Active guard retained; no original
  controller/batch/command/installation linkage observed in this schema.
- `sensor_readings`: 4 columns; no measured/source/batch/installation identity.

All four application tables have RLS enabled, not forced, and broad client grants.
Thirteen permissive policies and broad default grants were recorded. The
`rls_auto_enable` helper corrects older historical inventory statements claiming
there were no public routines; its existence does not mean RLS is restrictive.

No `bridge_sync_authorize_v1`, `bridge_sync_ingest_v1`, or
`bridge_sync_reconcile_v1` was found in the verified test public/private catalog.
A new **read-only** `supabase.cmd functions list --project-ref
zbwntspdecngnicllwlw --output json` returned `[]`, saved in
`test-edge-functions-audit.json`. No deployments or production queries were made.
Managed Auth/Storage internals and external schemas are outside this audit scope.

The approved live sensor-role probe is separately logged: SELECT/INSERT allowed
for both anon/authenticated; UPDATE/DELETE affected zero rows. Its fixtures were
rolled back and a separate query confirmed zero remaining rows. These are real
database-role results, not JWT/Auth-session/revocation verification.

## Current integration audit: source evidence, not a runtime pass

- `lib/main.dart:16–29`: initializes Supabase and calls signInAnonymously when no
  session exists. No auth change was made.
- `lib/services/supabase_service.dart`: direct preset/session/settings/reading
  calls remain; no `.rpc()` call in the service. Session creation stores Active;
  that is not evidence of a physical controller Start.
- `supabase/functions/_shared/bridge-sync-supabase.mjs:53–64`: local HTTP adapters
  reference the three exact RPC names, not a deployed database implementation.
- `pubspec.yaml:10–17` and AndroidManifest: current direct dependencies lack a
  Classic SPP/SQLite implementation package and the manifest lacks Bluetooth
  permissions. This is source evidence, not an Android device test.
- Firmware variants/local serial formats are not automatically a selected
  canonical producer or a flashed-image identity. ACK/STATE/retained recovery,
  durable outbox, original time/identity mappings and physical end-to-end behavior
  remain unverified. No firmware or Flutter changes were made.

This completes documenting integration readiness/gaps; it does not complete
implementing integration. The approved Uno → HC-05 → Android → Supabase
architecture is preserved.

## Changes, errors, tests, remaining work

Changes: added this completion review, CSV row/hash/consistency evidence, targeted
read-only test Edge Function listing, and two separate Completed audit reports.
Updated only the working portal defaults for these two audit IDs, plus its
report/queue/handoff artifacts. Historical Partial attempts remain unchanged.
Other team members' statuses and saved browser records are not overwritten.

Tests: 8/8 offline CSV consistency checks passed. Read-only test Edge Function
listing succeeded with zero entries. Earlier live role/rollback logs are reused,
not rerun here. Portal syntax/structure/import checks run after publication are
recorded separately. No new Node backend/Flutter/hardware or JWT tests claimed.
One initial PowerShell metadata command had a pipeline syntax error before
reading CSV contents; it was corrected. No SQL failed in this review.

Remaining security remediation and secure-ingestion implementation are **not
Completed**. CURRENT:DB-IMP-01, installation authorization, real RLS/JWT negative
matrices, immutable event ledger/receipts/replay and physical integration retain
their own acceptance criteria. CSV privilege booleans do not satisfy those tasks.
Superseded tasks remain Superseded, not converted to Completed.

Kath/Ally dependencies are unchanged; see TEAM_APPROVALS_AND_LOCAL_PLAN.md.
Recommended next action: resolve the specific shared identity/source/receipt
decisions before dependent backend implementation. No subsequent task is started
by this evidence review.

If an existing browser has a saved Partial override, it remains yours: the
working HTML publishes Completed defaults but does not silently overwrite newer
saved task records. Merge the new reports and update those two task dropdowns
after review if needed. Report import intentionally does not auto-complete tasks.

## New targeted browser verification

An initially empty `http://localhost:8876` test origin displayed both audited
tasks as Completed, with 136 records, all eight tabs, correct source coverage,
and Cha counts of 6 Completed / 7 Partial / 28 Not started / 1 Superseded.
Startup wrote no storage keys. On the separate previously seeded synthetic
`http://127.0.0.1:8876` origin, reload preserved all storage byte-for-byte and
kept its deliberately saved Partial/Needs verification overrides while the task
defaults were Completed. User file-tabs/storage were not touched. Results:
`audit-completion-browser-results.json`. This is new targeted runtime evidence,
not a rerun of all earlier responsive/import tests or any backend integration.
