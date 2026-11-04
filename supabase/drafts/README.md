# Offline SQL reference drafts — do not apply

[Backend guide](../README.md) · [Bridge-sync runbook](../functions/bridge-sync/README.md)

These existing design proposals are deliberately outside `supabase/migrations/`.
Their presence is not approval, execution evidence or permission to change a
database. Do not rename them into timestamped migrations or apply them as cleanup.

| File | Review purpose |
|---|---|
| [DB-IMP-01_disabled_registry.sql](DB-IMP-01_disabled_registry.sql) | Candidate private controller/installation registry with disabled capability locks. |
| [DB-IMP-01_authorization_schema_draft.sql](DB-IMP-01_authorization_schema_draft.sql) | Candidate authorization schema, ownership/RLS and audit design; declares a dependency on the registry draft. |
| [DB-IMP-01_bridge_sync_rpcs_draft.sql](DB-IMP-01_bridge_sync_rpcs_draft.sql) | Candidate public RPC wrappers; declares dependencies on both other drafts. Ingestion remains disabled. |

The table is a reference index, **not an execution plan**. Read each file's
warnings and assumptions. Real SQL parsing, Auth/RLS, transaction and isolated
database verification require separate review and authorization; local Node
tests do not establish those results. Existing context is retained in the
[DB-IMP-01 report](../../docs/integration/DB-IMP-01_Report.md).
