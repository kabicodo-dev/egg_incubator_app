# 02 — Architecture and implementation status

## Current boundary map

Local records select autonomous Uno → HC-05 Bluetooth Classic SPP → Android Flutter bridge → scoped Supabase persistence/monitoring. USB is diagnostic; ESP8266/USB farmer fallback text in older C03/C02 proposals is historical. Formal amendment adoption and actual transport compatibility are separate evidence gates.

| Component | Available evidence / current classification |
|---|---|
| `supabase/functions/_shared/bridge-sync-core.mjs` | Directly inspected local implementation: strict closed shapes, duplicate-key/unsafe-number rejection, canonical hash, receipt checking, default-disabled source submissions. Implemented but not fully verified as a deployed service |
| `supabase/functions/_shared/bridge-sync-supabase.mjs` | Directly inspected Auth HTTP and three RPC adapters; main-project refusal. RPC existence or real enforcement not established |
| `supabase/functions/bridge-sync/index.ts` | Directly inspected candidate Deno entrypoint, default source gate closed; source presence is not deployment |
| `supabase/functions/_shared/bridge-monitoring.mjs` | Directly inspected freshness/profile/diagnostic helpers. Explicit policy inputs, not approved operating thresholds or source authorization |
| `supabase/dev/serve-bridge-sync.mjs` | Inventoried supporting adapter; do not launch: settings can enable external requests |
| Existing Flutter services / Arduino sketches | Tracked paths inventoried; compatibility findings in prior review are documentary evidence, not newly executed integration |
| SQL drafts | Partial candidate authorization/wrappers; no accepted ledger/result-only implementation; not applied here |
| Manual-result 0.2 | Scoped Kath ACCEPT recorded, design/reference evidence only; incompatible with existing v1 handler |
| Q07 account policy 0.2 | Latest planning direction; Mary design approval reported; final joint review and implementation pending |

## Critical distinctions

Cloud `Active`, physical Start, ACK, RUNNING/latch reports, independent output feedback, manual result and synchronization receipt are not interchangeable. Cloud retries must never replay physical commands. `retention_ack:null` means a cloud receipt is not controller evidence-release authority.

The default source adapter throws `CONTRACT_NOT_ENABLED`. Reconciliation is a separate authorized RPC path, not gated by that submission adapter; default-disabled ingestion is **not** proof all endpoints are disabled or secure.

Current v1 handler requires installation/device identifiers and legacy `stopped_event_id` for farmer completion. Latest account planning removes approved-phone/session pinning, not immutable historical actor/source identity. A coordinated version/compatibility change is needed; do not silently rewrite stored hashes or old fixtures.

An existing occupied batch is reported in [backend guidance](../instructions/BACKEND.md). Its uploaded image and physical state are not independently verified here. No connection, reset, Start/Stop, settings synchronization, duplicate session or running-batch registration is authorized.

Next work is enumerated per task in [06](06-PENDING-BACKEND-CHANGE-REGISTER.md), not implicitly authorized by this overview.
