# Supabase / backend guide

Start here to find backend files. Existing paths are retained so CLI discovery,
test imports and dated review references continue to work.

Before editing, read [the backend instruction entry point](AGENTS.md) and its
[maintained role guide](../docs/instructions/BACKEND.md). The guide distinguishes
current local implementation, reviewed proposals and separately gated execution;
this directory index is not a contract or deployment approval.

| Location | Purpose |
|---|---|
| [migrations/](migrations/) | Existing timestamped database migration history; keep filenames, ordering, contents and location intact. |
| [config.toml](config.toml) | Supabase CLI local-service configuration, including API, database, Auth and Edge runtime settings. Not proof of hosted configuration. |
| [functions/bridge-sync/](functions/bridge-sync/README.md) | Candidate Edge entrypoint (`index.ts`) and detailed implementation/test runbook. |
| [functions/_shared/](functions/_shared/) | Shared HTTP validation, Supabase adapters and monitoring helpers used by the entrypoint and local tests. |
| [dev/](dev/README.md) | Supporting Node loopback HTTP adapter; not an Edge Function deployment directory. |
| [drafts/](drafts/README.md) | Offline SQL proposals, deliberately outside automatic migrations; not approved or applied migrations. |
| `.temp/` | Ignored Supabase CLI local/link metadata, when present. Leave in place; do not commit or copy its contents into reports. |

## Boundaries

Keep `config.toml`, `migrations/`, `functions/bridge-sync/index.ts` and
`functions/_shared/` in their existing CLI-compatible locations. Do not move
draft SQL into migrations as an organizational cleanup. Migration presence does
not establish what has been applied to any database.

The bridge-sync entrypoint is a local candidate, not a deployment claim. Its
default source adapter fails closed. SQL drafts and stubbed tests do not prove
deployed RPCs, authorization, RLS or durable persistence. See the
[function runbook](functions/bridge-sync/README.md) for implementation limits.

## Local checks

From repository root, with Node.js (the existing runbook records v26.4.0):

```powershell
node --check supabase/dev/serve-bridge-sync.mjs
node --test --test-timeout=15000 test/backend/bridge_sync_http_test.mjs test/backend/bridge_monitoring_test.mjs
```

These tests use loopback HTTP and stubbed Supabase boundaries, not a live
database. Do not supply production credentials. This guide does not authorize
deployment, migration application, database resets or remote operations.

Backend tests remain in [test/backend/](../test/backend/). Shared integration
evidence remains in [docs/integration/](../docs/integration/); neither directory
is reorganized here. Never include environment files, tokens, keys or CLI link
metadata in reports.
