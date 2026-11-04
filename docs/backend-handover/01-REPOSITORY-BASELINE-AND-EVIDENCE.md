# 01 — Repository baseline and evidence discipline

## Exact inspected checkout

| Field | Recorded value |
|---|---|
| Inspection date | 2026-11-03; environment date, not an acceptance date |
| Repository root / checkout | `C:/EggIncubator/egg_incubator_app` |
| Branch | `cha-branch2` |
| HEAD | `2d2622e6b1b0c538dda3c3023e97ae467eaf53b6` |
| Parent backup | `035e8425af7b880c0351f672a875a5f689062d65` |
| Cached upstream | `origin/cha-branch2` at `c7a26cfcaa619708aff4f793e8068ee176a6cf58` |
| Ahead/behind cached upstream | Ahead 2, behind 0; no fetch performed |
| Initial status | 3 unstaged modifications; 689 untracked files; staged 0, deleted 0, unmerged index entries 0 |
| Tracked patch size | 441 insertions, 13 deletions; line-ending conversion warnings are Git observations, not edits by this task |
| Final expected delta | Only README plus 13 new Markdown files in this directory; exact validation in document 13 |

## Pre-existing tracked modifications

| Path | Initial status | Inspected difference |
|---|---|---|
| `docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md` | unstaged modified | 388 additions / 12 removals; newer receipts and planning recorded; current opening sections read |
| `docs/validate-c02-provisional.cjs` | unstaged modified | 51 additions / 1 removal; incompatible-fixture rejection and no-mutation checks; complete diff inspected |
| `supabase/functions/bridge-sync/README.md` | unstaged modified | 2 additions; backend directory links; complete diff inspected |

The 689 pre-existing untracked paths include Q12 v1/v2/v3 source and generated evidence, manual-result proposals/reviews, decision receipts, instruction guides, review-package copies and two backend tests. They are **local-only relative to the index**, not known absent everywhere else. Document 13 lists each path and classification. Nothing was staged, copied into source, applied or deleted.

## Local references

| Local branch | Tip |
|---|---|
| `cha-branch2` | `2d2622e6b1b0c538dda3c3023e97ae467eaf53b6` |
| `ally-branch3`, `main` | `b73d499d7f46f5914f25f5b56fca5a0101a182ac` |
| `development` | `e5ee5d13d5531110435e143315a2cd8a66442cc2` |
| `kath-branch1` | `833c4b0443e9e2ff41d9ecf5b0ee144c617b9f76` |
| `resolve-pr35` | `e5709214129c6c0f5966d549affbccf42c8f6835` |
| `staging` | `45f31f9380e234eb93796f676f5ec1a20dc78924` |

`git log --branches --not HEAD` returned no commits: no other local branch has commits outside HEAD ancestry. This does not cover unavailable branches or future remote updates. All cached refs and remote-only divergence are inventoried in document 13. Cached refs were read locally; no remote URL or credential file was accessed.

## Evidence rules

- **Implemented and verified:** directly inspected local behavior with retained checks supporting only their stated scope; no test rerun occurred here.
- **Implemented but not fully verified:** source exists, but runtime/security/persistence/native/physical acceptance is incomplete.
- **Approved design only:** explicit scoped approval recorded in a local document; not independently authenticated human acceptance or execution permission.
- **Documentation completed:** file content exists and was reviewed at the stated level; does not complete implementation.
- **Proposed / Blocked / Superseded / Unknown:** preserve unresolved choices, historical precedence and missing evidence separately.

Inspected content: baseline/status/history; core handler in full; Supabase adapter, monitoring helper and entrypoint; disabled registry and RPC/migration excerpts; current ledger opening; backend guide; current C-02, Q06/Q07, Q07 and Q12 receipts/reviews; historical handoff and task index. Generated manifest explicitly marks files inventoried/hash-checked only. A path, hash or embedded report is not proof the referenced raw file was inspected.

No `.env`, credentials, CLI link metadata, remote systems, database queries, builds, tests or hardware were accessed/executed. Existing SQL's application claims remain documentary history, not new deployment verification.
