# Supporting local tools

[Backend guide](../README.md) · [Bridge-sync runbook](../functions/bridge-sync/README.md)

- [serve-bridge-sync.mjs](serve-bridge-sync.mjs): Node loopback HTTP adapter for
  the shared bridge-sync handler. Exports `listenBridge` for backend tests and
  can run directly from repository root as `node supabase/dev/serve-bridge-sync.mjs`.
- Shared implementation stays in [functions/_shared/](../functions/_shared/);
  this directory is not deployed as an Edge Function.

Direct execution listens on `127.0.0.1:8787` by default and does not load `.env`.
It can use explicitly supplied Supabase settings, so it is **not inherently an
offline mock**. Do not launch it with production credentials or assume a running
server proves database integration. Source acceptance remains disabled. Use the
stubbed tests listed in the backend guide for local validation; see the runbook
before any separately authorized integration run.
