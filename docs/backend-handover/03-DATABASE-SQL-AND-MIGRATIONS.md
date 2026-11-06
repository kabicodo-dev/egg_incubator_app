# 03 — Database, SQL and migrations

## Exact available SQL paths

| Path | Source / state | Evidence interpretation |
|---|---|---|
| `supabase/migrations/20260929070513_remote_schema.sql` | tracked; introduced by `d50dafb` | Historical schema snapshot; inventoried, not fully read here |
| `supabase/migrations/20260929204930_remote_schema.sql` | tracked | Historical schema snapshot; inventoried, deployment unknown |
| `supabase/migrations/20261012090000_incubator_sessions_single_active.sql` | tracked; `cd481f3` | Opening source inspected: global one-Active index and historical reviewer application claim; no present catalog verification |
| `supabase/drafts/DB-IMP-01_disabled_registry.sql` | tracked; `035e842` | Read in full: inactive controller/installation hard locks, no enabling/public RPC grant; unapproved candidate |
| `supabase/drafts/DB-IMP-01_authorization_schema_draft.sql` | tracked; `035e842` | Inventoried, prior review describes partial authorization design; not newly SQL-reviewed or parsed |
| `supabase/drafts/DB-IMP-01_bridge_sync_rpcs_draft.sql` | tracked; `035e842` | Opening/wrapper/dependency excerpt inspected: deliberate ingestion stop before persistence; unapproved candidate |
| `docs/integration/cha-execution/Q12_Phase_A_Read_Only.sql` | local-only | Pinned historical 17-statement read-only scope; fingerprint in Q12 records, no execution here |
| `docs/integration/cha-execution/2026-10-30-test-catalog.sql` and security-run SQL | local-only | Historical evidence/query files inventoried only; not current hosted-state proof or executable instructions |

Exact per-file availability, raw-byte hashes and Git last-touch commits are in [13](13-HANDOVER-FILE-AND-PATCH-MANIFEST.md). Config exists but was not read: configuration inspection/change is outside this task.

## Preservation and future implementation requirements

Keep migration names/order/bytes and draft locations. Do not move drafts into automatic migrations, apply them, reset a database or infer current deployment from file presence or an old `APPLIED` comment.

Preserve real `egg_type`, `egg_quantity`, `eggs_hatched` semantics and History. Bigint IDs crossing candidate APIs require lossless decimal strings, not floating-point casts. The global single-Active guard is not an account assignment policy and not physical admission proof.

DB-IMP-01 still needs reviewed account authorization/assignment, atomic server-side canonical recomputation, ledger/dedup/content-conflict enforcement, receipt/reconciliation, races, direct-table bypass protection and manual-result 0.2. Existing drafts cannot be assumed to implement these.

**Rollback:** historical index-drop text exists in the migration, but is not an approved current recovery plan and weakens the one-Active guarantee. A comprehensive future migration rollback/data-preservation/restore/readback plan is **missing and requires owner approval**. Do not invent or execute one. See DB-IMP-01, security and account tasks in [06](06-PENDING-BACKEND-CHANGE-REGISTER.md).
