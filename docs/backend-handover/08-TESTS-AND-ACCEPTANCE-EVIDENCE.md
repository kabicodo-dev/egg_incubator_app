# 08 — Tests and acceptance evidence

**No tests/builds/scripts were executed for this handover.** Only repository text, Git metadata, local file hashes and Markdown links were inspected. Reported counts below are retained local evidence, not fresh PASS claims.

| Scope | Available record | Interpretation |
|---|---|---|
| Original candidate backend | `docs/integration/logs/2026-10-29-db-imp-01-node.tap` | Tracked historical local evidence; not live persistence |
| Architecture alignment | `oct26-c03-architecture-targeted.tap`, `oct26-c03-backend-regression.tap` under `docs/integration/cha-execution/` | Retained reported 13/13 and 83/83; targeted included in regression |
| Monitoring | `monitoring-boundary-targeted.tap`, `monitoring-backend-regression.tap` | Retained reported 27/27 and 110/110; policy constants synthetic, not operating settings |
| Latest schema review | `ally-c02-schema-revalidation-20261102.txt` and receipt JSON | Reported 14 positive / 65 negative / 11 malformed, plus isolation/edge checks; current modified validator differs from older fingerprint |
| Manual-result 0.2 | `manual-result-0.2.tap`, `manual-result-0.2-local-recheck-20261031.tap`, preparation report | Local reference/schema reports, 27/27 recorded in later preparation; not durable transaction/API acceptance |
| Kath Dart | `received-kath-dart-20261031/`, `received-kath-02-20261031/` and receipt files | Delivered client-side evidence; no independent native/Android execution here |
| Q12 | v3 `local-verification-*/test-results.json`, inventories and execution review | Historical 211/211 candidate coverage; overlapping runs, synthetic/local-native-memory only |
| Security role probe | `APPROVED_SECURITY_TEST_REPORT.md`, historical security-run files | Attributed historical isolated probe only; no current full Auth/RLS/transaction matrix inferred |

Files not content-read in this inspection are explicitly inventoried only in [13](13-HANDOVER-FILE-AND-PATCH-MANIFEST.md). Counts copied from an inspected review are documentary assertions, not independently recomputed assertions about raw test logs.

## Safe command distinction

Read-only Git/path comparisons and approved syntax-only checks need no backend change. Example existing syntax workflow: `node --check supabase/functions/_shared/bridge-sync-core.mjs` (not run here). Do not assume suites are no-write: existing `node --test` suites use temp storage/loopback HTTP, and Q12 scripts create evidence. Do not launch `serve-bridge-sync.mjs`, run package builders, browser scripts, security runners, SQL or CLI commands as documentation validation.

## Required future acceptance levels

1. Exact candidate source/contracts/fixtures and reviewed hashes agree.
2. Unit/parser/reference behavior plus native storage/crash/restart evidence.
3. Separately authorized isolated actual Auth/RLS/RPC/atomic persistence/race/bypass cases.
4. Compatible Android/source integration with truthful source/batch/time/freshness mapping.
5. Separately cleared physical/safety testing; no local test establishes it.

All pending tasks in [06](06-PENDING-BACKEND-CHANGE-REGISTER.md) specify test evidence and authorization/rollback gates. Missing native tooling/evidence is BLOCKED or UNKNOWN, not PASS.
