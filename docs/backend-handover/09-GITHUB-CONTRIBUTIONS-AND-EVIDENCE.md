# 09 — Git contributions, attribution and transfer manifest

No GitHub/network access occurred. “GitHub contributions” below means available **local Git evidence**, not verification of current PRs, hosted branches or merge status.

## Preserve Cha's authorship

Git author `charlynaguirre91-lab` is associated with Cha/Mary by the repository's handover/report owner statements. This association is documentary, not independent identity authentication. Kath's future responsibility does not transfer authorship.

| Commit | Verified Git contribution | Limit |
|---|---|---|
| `d50dafb` | Supabase CLI configuration and initial schema migration introduced | Stat/history verified; not deployment verification |
| `cd481f3` | SECURITY-TASKS, session-ownership audit, single-Active migration and audit tests | Git file list verified; not new runtime acceptance |
| `a9d68fe` | Audit documentation updated with historical M1 application claim | Documentation attribution, not a fresh catalog finding |
| `035e8425af7b880c0351f672a875a5f689062d65` | 45-file preservation commit: architecture/contracts/schema inventory, handler/adapters, disabled drafts, mocks, tests/fixtures and evidence | Backup contains shared inputs too; author of a preservation commit is not necessarily sole author of every byte |
| `2d2622e6b1b0c538dda3c3023e97ae467eaf53b6` | K-04 backend dependency review preserved | Current HEAD; review credit, not physical implementation |
| `6655385`, `010b463`, `1d3504e`, `a961ac0` | Historical Supabase settings/preset/auth integration in available Git history | Prior behavior includes anonymous startup; historical contribution is not endorsement of current security |

Cha-attributed local documentation also covers security/authorization design, Supabase reviews, database/RLS investigations, C02/DB02 integration reviews, Q12 local controller corrections/evidence and technical recommendations. Local-only files have no commit authorship: attribution is **documentary/workstream ownership**, with assistant assistance where disclosed. Shared reviews and Kath/Ally supplied evidence retain their own provenance. For example `7f578af` records a migration contribution by `kabicodo-dev`; Arduino source contributions by Ally are not reassigned to Cha.

## Transfer manifest (operational summary)

The [complete exact-path manifest](13-HANDOVER-FILE-AND-PATCH-MANIFEST.md) is the canonical itemized counterpart: each path, tracked/local-only state, source commit when available, inspection level, byte fingerprint and transfer requirement. It also reproduces every pre-existing status entry and available ref. Do not copy or merge automatically.

| Required transfer set | Exact path / scope | Source / availability | Requirement |
|---|---|---|---|
| This package | `docs/backend-handover/README.md`, documents 01–13 | Newly created, untracked | Deliver for review only; acceptance separate |
| Backend | `supabase/functions/_shared/bridge-sync-core.mjs`, `bridge-sync-supabase.mjs`, `bridge-monitoring.mjs`; `supabase/functions/bridge-sync/index.ts`; `supabase/dev/serve-bridge-sync.mjs` | Tracked at HEAD, preserved in `035e842` | Compare exact checkout; shared-host presence unknown |
| SQL | Three `supabase/migrations/*.sql` and three `supabase/drafts/DB-IMP-01_*.sql` itemized in 03/13 | Tracked | Preserve bytes/order/draft boundary; do not execute |
| Tests/fixtures | `test/backend/`, `test/integration/`, `test/fixtures/integration/`, `test/session_ownership_audit_test.dart`, `test/int_imp_01_parser_compatibility_test.dart` | Tracked except architecture/monitoring boundary additions | Transfer missing local-only tests by reviewed non-overwriting method |
| Contracts | `docs/C02-provisional*`, `docs/contract-review/`, K06 v0.3/v0.4 | Mixed tracked, modified and local-only | Preserve parents and exact versions; latest ledger is an unstaged patch |
| Q12 | `docs/integration/cha-execution/q12-controller/`, `q12-execution-package/`, `Q12*`, `q12-phase-a-status.json` | Local-only | Review complete inventory; source/evidence/compiler artifacts have different roles; no credentials |
| New receipts/guidance | `docs/instructions/BACKEND.md`, `supabase/AGENTS.md`, backend README guides, 2 Nov C02/Q07 receipts | Local-only | Needed to avoid obsolete handoff guidance; verify against manifest |
| Other local evidence | All 689 initial untracked paths in 13 | Local-only relative to this index | Reconcile review-package duplicates and evidence; no blanket claim of shared availability |
| Three unstaged patches | Ledger, validator, bridge-sync README listed in 01/13 | Available working-tree differences; no patch file exported | Cha/Kath must review diffs and agree transfer; do not apply here |
| Two upstream-unmerged commits | `035e842...`, `2d2622e...` | Available only beyond cached `origin/cha-branch2`; current hosted presence unknown | Compare Kath's checkout, agree authorized transfer/merge separately; backup includes unrelated changes and historical `.env` removal, do not expose its secret history |
| Ally candidate packet | Reported `80971f902d5634f7fed78ff073fcb78fa31be460`, source `7106ebfe...`, raw source/patch/catalog/build files | Commit lookup unavailable; reports/receipts available | Obtain matching existing packet from Ally; do not rerun audit or fetch here |
| Shared instructions/running-batch package | `docs/instructions/GLOBAL.md`, `PROJECT_CONTEXT.md`, `DECISIONS.md`, `ARCHITECTURE.md`; `docs/handoff/2026-11-01/running-batch/README.md` | Absent locally; referenced in existing guidance | Request reconciliation from supplying owner; unavailable does not mean never existed |

No patch was exported, committed, merged or applied. Never transfer `.env`, CLI link metadata, tokens, certificates with private material or historic secret blobs. Inventory/hashes here concern non-secret scoped source/evidence paths only.
