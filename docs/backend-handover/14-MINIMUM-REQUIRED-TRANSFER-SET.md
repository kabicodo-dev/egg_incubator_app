# 14 — Minimum required comparison set (Phase 1)

Prepared 2026-11-03. **Comparison inventory only; no transfer or implementation authorized. Kath's handover acceptance remains pending.**

## Verified baseline

- Root/checkout: `C:/EggIncubator/egg_incubator_app` — matches expected.
- Branch: `cha-branch2` — matches expected.
- HEAD: `2d2622e6b1b0c538dda3c3023e97ae467eaf53b6` — matches expected.
- Initial status: **3 unstaged tracked modifications, 704 untracked files**, zero staged/deleted/unmerged entries. Compared with the earlier final record, the extra item is `docs/backend-handover.zip`; it pre-existed this phase and is excluded, not opened.
- Final expected delta: only documents 14–16, bringing untracked count to 707. Existing handover documents remain unchanged. Final checks recorded below.

The five requested handover documents were inspected; document 13 supplied the candidate pool. Current paths/hashes/status/last-touch commits below are independently read from disk/Git, not copied from its hashes. For long documents, relevant sections and a complete programmatic path/hash comparison were used; this is not an exhaustive audit of every source/report body.

## Selection and per-file interpretation

This is a minimum **continuation/review** set, not a ready-to-merge implementation. No production persistence implementation exists merely because adapters/drafts exist. All selected items are necessary to Kath's scoped review **in their stated role**, but none is known missing from her checkout. Compare before deciding whether any later transfer is needed.

Each row below specifies path, purpose, priority, dependencies, inclusion evidence and potential future PR disposition. The independent SHA-256/status table later in this document joins by exact path and supplies source branch/HEAD, tracked/local status, unstaged flag and last-touch commit. Together the tables are the requested per-file inventory.

Future PR codes: **C** = conditional candidate for a narrowly reviewed future source/test change, not consent or a claim the file needs change; **D** = documentation/reference candidate only; **R** = historical/reference evidence, not an implementation PR or automatic upload. Existing tracked files may already be shared. Raw source/hash inspection is not execution or acceptance.

Dependencies reference groups/IDs below; they are comparison requirements, not instructions to install/run. Node built-ins need no installation. Existing Flutter tests require the app's current dependencies; no package/configuration changes authorized. Q12 has external Windows/.NET/libpq/PG17-reference prerequisites, **not inspected or installed** in this phase.

## P0 — Backend source and SQL

| Exact repository-relative path | Purpose / why required | Priority | Dependencies | Inclusion evidence | Future PR |
|---|---|---|---|---|---|
| `supabase/functions/_shared/bridge-sync-core.mjs` | Existing strict validation/hash/receipt logic and disabled source gate | P0 | Supabase ports; API contract | Manifest; actual test imports; existing handover 02/04 | C |
| `supabase/functions/_shared/bridge-sync-supabase.mjs` | Auth/RPC adapter; older installation/session assumptions needing comparison with Q07 | P0 | Core; future real RPCs; Q07 0.2 | Policy 0.2 §8; backend HTTP test imports | C |
| `supabase/functions/_shared/bridge-monitoring.mjs` | Freshness/profile/diagnostic boundaries, no approved numerical policy | P0 | Core; monitoring tests | Handover 02/08; source dependency | C |
| `supabase/functions/bridge-sync/index.ts` | Candidate Edge entrypoint composition; not deployment | P0 | Core and Supabase adapter; runtime environment not read | Manifest; handover 02 | C |
| `supabase/dev/serve-bridge-sync.mjs` | HTTP adapter imported by selected tests; do not launch | P0 | Core/ports; Node runtime | bridge_sync_http_test.mjs imports | C |
| `supabase/migrations/20260929070513_remote_schema.sql` | Original schema baseline needed to interpret later migrations/drafts | P0 | Historical order; no apply | Manifest; migration lineage | R |
| `supabase/migrations/20260929204930_remote_schema.sql` | Second historical schema baseline; prevent incomplete migration comparison | P0 | Earlier migration; no apply | Manifest; historical migration lineage | R |
| `supabase/migrations/20261012090000_incubator_sessions_single_active.sql` | Global single-Active invariant separate from account/phone policy | P0 | Historical session schema; audit test | Audit Git contribution and ownership test | R |
| `supabase/drafts/DB-IMP-01_disabled_registry.sql` | Hard-disabled registry boundary, not Q07 0.2 implementation | P0 | Future reviewed schema; no execute | Manifest; Q12/draft dependencies | C |
| `supabase/drafts/DB-IMP-01_authorization_schema_draft.sql` | Existing candidate authorization assumptions to reconcile, not adopted account schema | P0 | Disabled registry; security review | Q07 0.2 §8; RPC draft dependencies | C |
| `supabase/drafts/DB-IMP-01_bridge_sync_rpcs_draft.sql` | Candidate wrappers and deliberate incomplete persistence boundary | P0 | Both other drafts; future ledger | Manifest; adapter's three RPC ports | C |
| `lib/services/supabase_service.dart` | Legacy direct-table/session completion behavior exercised by audit tests; compare only, no Flutter edit | P0 | Existing Flutter/Supabase dependencies | session_ownership_audit_test.dart import; policy §8 | R |

## P0 — Tests and exact dependency closure

| Exact repository-relative path | Purpose / why required | Priority | Dependencies | Inclusion evidence | Future PR |
|---|---|---|---|---|---|
| `test/backend/bridge_sync_http_test.mjs` | Actual handler/HTTP boundary and Auth/RPC stub coverage | P0 | Core/adapter/dev server; mock kit | Imports inspected | C |
| `test/backend/bridge_monitoring_test.mjs` | Monitoring/profile domain expectations | P0 | Monitoring/core; kit | Manifest; existing test runbook | C |
| `test/backend/architecture_alignment_test.mjs` | Local closed-gate/architecture regressions | P0 | Core/adapter; kit | Handover 08; local-only test | C |
| `test/backend/monitoring_boundary_test.mjs` | Explicit time/metric boundary regression; no operating threshold approval | P0 | Monitoring/core; kit | Handover 08; local-only test | C |
| `test/integration/int_imp_01.test.cjs` | Candidate recovery/dedup/receipt characterization | P0 | Mock module, fixture manifest, source snapshots | Imports/loadKit/source-pinning test inspected | C |
| `test/integration/support/int_imp_01_mocks.cjs` | Shared mock-kit loader and exact dependency map | P0 | Fixture manifest; DB02 API; two NDJSON fixtures | loadKit inspected, lines 34–52 | C |
| `test/integration/export_int_imp_01_fixtures.cjs` | Required exporter subprocess in integration test, not a redundant generated export | P0 | Mock-kit loader/fixtures/API | int_imp_01.test.cjs lines 328–329 | C |
| `test/fixtures/integration/int_imp_01_sources.json` | Pins historical source/API identities; selection remains null | P0 | Two sketches, DB02 API and NDJSON | Full manifest read | C |
| `test/fixtures/integration/hw02_batch_review.ndjson` | Exact earlier literal frame corpus used by loader/validator | P0 | Fixture manifest; no selected adapter | wire_references in inspected manifest | C |
| `test/fixtures/integration/hw02_corrected_review.ndjson` | Exact corrected six-frame corpus; distinct from selected source | P0 | Fixture manifest | wire_references in inspected manifest | C |
| `test/fixtures/integration/db_imp_01_closed_gate.json` | Disabled-source/backend fixture prerequisite | P0 | Candidate core/contracts | Existing source/test inventory | C |
| `test/session_ownership_audit_test.dart` | Characterizes legacy global sessions; not desired Q07 account behavior | P0 | Legacy service; existing Flutter dependencies | Header/imports inspected | C |
| `test/one_active_batch_test.dart` | Existing app-side single-Active regression, independent of account policy | P0 | Legacy service; existing Flutter test environment | Dependency closure inspection; **additional path not in old manifest scope** | C |
| `pubspec.yaml` | Existing package dependency declarations needed to compare Flutter test environment | P0 | Existing project only; no install | Audit-test package imports; **additional path outside old manifest** | R |
| `pubspec.lock` | Exact already-resolved Dart dependency baseline | P0 | pubspec.yaml; no resolver/build | Flutter test dependency closure; **additional path outside old manifest** | R |
| `arduino/SmartHatch_Uno/SmartHatch_Uno.ino` | Read-only source-pinning dependency of integration test, not selected/flashed firmware | P0 | int_imp_01_sources.json | source_snapshots explicitly lists it | R |
| `arduino/SmartHatch_Combined/SmartHatch_Combined.ino` | Other exact source-pinning dependency; not a substitute for Ally's missing packet | P0 | int_imp_01_sources.json | source_snapshots explicitly lists it | R |
| `docs/validate-c02-provisional.cjs` | Modified documentation validator, isolates incompatible fixture families | P0 | Provisional schema/examples; two NDJSON corpora; pre-existing Ajv tooling | Current unstaged diff and latest review receipt | C |
| `docs/integration/cha-execution/manual-result-0.2.test.cjs` | Exact reference/schema/immutable-parent regression for selected 0.2 source | P0 | Ajv2020/ajv-formats already available; 0.2 schema/fixtures/reference and four parents | Imports and parent-fingerprint test read, lines 1–24 | C |

The firmware files above are included solely because an existing selected test reads their bytes. No firmware transfer to hardware, editing, build, serial access or flashing is proposed. Pubspec files are environment references, not package-change candidates. Minimal test closure does not mean the full Flutter/native toolchain is available or tests were run.

## P0 — Current contracts and decisions

| Exact repository-relative path | Purpose / why required | Priority | Dependencies | Inclusion evidence | Future PR |
|---|---|---|---|---|---|
| `docs/contract-review/Q07_Provider_Session_Binding_Policy_0.2.md` | Exact P1–P6 technical design; current account planning, old header still says review pending | P0 | Matching simple proposal; approval clarification 16 | Full policy read; current user approval clarification | D |
| `docs/contract-review/Q07_Plain_Language_Access_Proposal_0.2.md` | Matching account-access explanation; avoid reverting to invitation/phone approval | P0 | Technical 0.2 | Technical policy links it | D |
| `docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md` | Active ledger; Mary approval report and latest scope/precedence | P0 | Received source decisions; see 16 | Inspected current opening; modified tracked file | D |
| `docs/contract-review/Q07_SMTP_Test_Project_Plan_0.1.md` | Independent documentary location of Mary design-approval report and setup exclusion; NOT SMTP execution candidate | P0 | Ledger, approval clarification | Line 18 approval report; lines 3–6 unexecuted boundary | R |
| `docs/contract-review/DB-02_Exact_Bridge_Sync_API.md` | Existing v1 API and executable JSON example dependency of tests | P0 | Core/fixture manifest | loadKit reads exact named example blocks | D |
| `docs/contract-review/DB-02_Proposed_Schema_And_Security.md` | Candidate persistence/security semantics, not deployed schema | P0 | API/drafts; Q07 delta | Manifest/handover 03–05 | D |
| `docs/contract-review/DB-02_Conflict_Receipt_And_Recovery.md` | Existing conflict/unknown-outcome/receipt semantics to preserve | P0 | API; identity/content constraints | Handover 05/06 | D |
| `docs/contract-review/DB-02_Manual_Result_API_0.2-review.md` | Scoped result-only candidate, not implemented by current v1 | P0 | Exact schema/fixtures/reference below; parent preserved locally | Kath scoped ACCEPT receipt | D |
| `docs/contract-review/manual-result-0.2-review/schema.json` | Exact reviewed structural shape | P0 | 0.2 API | Current candidate payload definition | C |
| `docs/contract-review/manual-result-0.2-review/fixtures.json` | Canonical request/response examples and hashes | P0 | Schema/reference | Current candidate tests | C |
| `docs/contract-review/manual-result-0.2-review/reference.cjs` | Local reference guards; not deployed server | P0 | Fixtures/schema; no execution | 0.2 proposal/tests | C |
| `docs/contract-review/manual-result-0.2-review/parent-and-change-manifest.json` | Exact list of four immutable parent inputs read by 0.2 test | P0 | Four parent rows below | Test lines 21–24; manifest read | R |
| `docs/contract-review/DB-02_Manual_Result_API_0.1-review.md` | Preserved parent API required by 0.2 fingerprint test, not current replacement design | P0 | Parent manifest | Exact parent key in manifest | R |
| `docs/contract-review/manual-result-0.1.schema.json` | Preserved schema bytes required by 0.2 parent-integrity test | P0 | Parent manifest | Exact parent key in manifest | R |
| `docs/contract-review/manual-result-0.1.fixtures.json` | Preserved fixture bytes required by 0.2 parent-integrity test | P0 | Parent manifest | Exact parent key in manifest | R |
| `docs/contract-review/manual-result-0.1.closure-matrix.json` | Preserved parent acceptance matrix dependency, not actual passed cases | P0 | Parent manifest | Exact parent key in manifest | R |
| `docs/contract-review/D04_D06_Mary_Backend_Position.md` | M08/identity/result boundaries; old access assumptions qualified by Q07 0.2 | P0 | Ledger; technical 0.2 | Handover 05; candidate provenance | D |
| `docs/C02-provisional-communication-contract.md` | Exact historical reviewed provisional family, not selected wire | P0 | Schema/examples and CHANGE receipts | Current C02 review | R |
| `docs/C02-provisional.schema.json` | Matching historical schema; distinguishes families | P0 | Provisional contract/examples | Validator and review receipt | C |
| `docs/C02-provisional.examples.json` | Exact review inputs rather than a report alone | P0 | Schema/validator | Validator and review receipt | C |
| `docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.4_Bluetooth_Android_Bridge.md` | Architecture amendment identifying current HC-05/Android direction; adoption separate | P0 | Existing architecture record; no new vote | Handover 02/05; policy compatibility context | R |
| `docs/contract-review/C02_Wire_Family_Decision_Request_2026-11-02.md` | Focused unresolved wire choice rather than repeat review | P0 | Exact-input reviews; matching packet still missing | Latest C02 receipt | D |

## P1 — Required verification and compatibility evidence

| Exact repository-relative path | Purpose / why required | Priority | Dependencies | Inclusion evidence | Future PR |
|---|---|---|---|---|---|
| `docs/integration/cha-execution/q12-controller/v3/ModelPolicy.cs` | Current reviewed catalog shape/comparison policy | P1 | Other v3 C# sources; pinned SQL | v3 README/execution review | C |
| `docs/integration/cha-execution/q12-controller/v3/NativeBoundary.cs` | Native transport boundary and memory-only test interfaces | P1 | Installed libpq external prerequisite; not loaded here | v3 review | C |
| `docs/integration/cha-execution/q12-controller/v3/DurableController.cs` | Ordered single-session/evidence/rollback controller candidate | P1 | ModelPolicy/NativeBoundary | v3 review | C |
| `docs/integration/cha-execution/q12-controller/v3/SourceSnapshot.psm1` | Locked source/compiler identity logic | P1 | Windows/.NET compiler environment | Test-Corrections imports/read inspected | C |
| `docs/integration/cha-execution/q12-controller/v3/Invoke-Q12PhaseA-V3.ps1` | Launcher gates must be reviewed with controller; DO NOT RUN | P1 | v3 sources, SQL and separate provenance/operator authorization | Test-Corrections names list; v3 review | C |
| `docs/integration/cha-execution/q12-controller/v3/Correction.Tests.cs` | Retained regression source, not just PASS report | P1 | v3 controller; external native prerequisites | Test-Corrections compilation list | C |
| `docs/integration/cha-execution/q12-controller/v3/Followup.Tests.cs` | Independent shape/constraint/snapshot follow-up coverage source | P1 | v3; external PG17 references | Test-Corrections compilation list | C |
| `docs/integration/cha-execution/q12-controller/v3/Test-Corrections.ps1` | Exact source/test composition and run categorization, DO NOT RUN | P1 | Eight named v3 inputs, SQL, host prerequisites | Dependency list inspected | C |
| `docs/integration/cha-execution/q12-controller/v3/README.md` | Scope, known limits and local correction history | P1 | Matching v3 source and evidence | Existing inspected handover/review | D |
| `docs/integration/cha-execution/Q12_Phase_A_Read_Only.sql` | Pinned original inspection scope dependency, not permission to execute | P1 | Exact approval and controller; no database access | Test-Corrections pinned path | R |
| `docs/integration/cha-execution/q12-phase-a-status.json` | Historical phase status; later receipts qualify old fields | P1 | Attempt and certificate updates | Backend instructions; handover 07 | R |
| `docs/integration/cha-execution/Q12_PHASE_A_ATTEMPT_1_RECEIPT.md` | Interrupted owner-reported attempt and unavailable original rollback | P1 | Original raw evidence remains unavailable | Handover 07/11 | R |
| `docs/integration/cha-execution/Q12_CERTIFICATE_PROVENANCE_OWNER_UPDATE.md` | Owner/download attestation received, not full trust acceptance | P1 | Later public-reference assessment | Explicit supersession in latest assessment | R |
| `docs/integration/cha-execution/Q12_CERTIFICATE_PUBLIC_REFERENCE_ASSESSMENT.md` | Latest authoritative fingerprint blocker; avoids obsolete missing-owner claims | P1 | Prior owner update; no network here | Handover 07 | R |
| `docs/integration/cha-execution/q12-execution-package/REVIEW.md` | Same-assistant review limits, not human sign-off | P1 | v3 source and single current run below | Handover 07 | R |
| `docs/integration/cha-execution/q12-execution-package/PENDING_REMOTE_AND_CLOSURE.md` | Unaccepted gates, no fabricated actual inspection/rollback | P1 | Review; actual remote evidence absent | Handover 07/12 | R |
| `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/test-results.json` | One latest 211-case local evidence record, no overlapping-run count inflation | P1 | Matching v3 fingerprints; referenced external/raw artifacts may remain supplemental | Execution review identifies this exact run | R |
| `docs/integration/cha-execution/ALLY_C02_20261102_RECEIPT_AND_CLOSURE.md` | Latest same-input CHANGE review and C02A/B qualification | P1 | Received response and validator output | Handover 05 | R |
| `docs/integration/cha-execution/received-ally-c02-20261102.txt` | Actual preserved delivered review, not merely a summary | P1 | Provisional three-file packet | Latest C02 receipt | R |
| `docs/integration/cha-execution/ally-c02-schema-revalidation-20261102.txt` | Actual retained current-validator output; not rerun here | P1 | Current modified validator; exact inputs | Latest C02 receipt | R |
| `docs/integration/cha-execution/ALLY_ZIP_C02B_REVIEW.md` | Firmware/backend finding comparison; raw matching firmware still missing | P1 | Supplied-report provenance; C02 receipt | Handover 05/11 | R |
| `docs/integration/INT-IMP-01_Evidence.md` | Tracked integration fixture/compatibility boundaries and remaining gates | P1 | Selected source kit/tests | Manifest; backup commit | R |
| `docs/integration/cha-execution/KATH_02_DELTA_ACCEPT_RECEIPT.md` | Scoped manual-result 0.2 ACCEPT, not Q07 approval or real implementation | P1 | Exact 0.2 candidate | Handover 05/08 | R |
| `docs/contract-review/MARY_Backend_Preparation_2026-11-01.md` | Existing local source/API mapping and test-limit report | P1 | Matching source at report time; later Q07 override | Handover 08; current mapping context | R |

## Explicit exclusions and deferred supplements

- No archives/ZIPs, generated portal HTML/JSON exports, packaged copies, old Q12 v1/v2 implementations, compiler intermediate duplicates, every overlapping verification run or unrelated research/hardware reports.
- No `.env`, config/CLI link metadata, credentials, certificate files, secret history or hosted settings. Public certificate **assessment reports** above are not certificate files.
- No broad directory transfer. Old Q07 0.1 policies and packaged manual-result copies remain deferred supplements. Only the four exact manual-result parent inputs explicitly read by the selected 0.2 test are included; no whole historical package is selected.
- `supabase/functions/bridge-sync/README.md` is one of the three modified files and is hashed separately below as a **review-only supplemental item**, not essential runtime source.
- Existing handover 04/06/09/11/13 are comparison context, not re-exported or changed. The added `test/one_active_batch_test.dart`, pubspec paths are transparently selected dependency extensions beyond the old manifest's scope; no claim those paths were originally listed there.
- Raw Q12 journals/compiler receipts/PG17 local references remain potential evidence supplements if a specific assertion needs verification; a single test-results JSON is not a self-contained independent reproduction bundle.

## Three unstaged modifications — review before any future transfer

1. `docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md`: +388/-12; compare exact current decisions/approvals against Kath's ledger; preserve attribution and scope, do not overwrite her changes.
2. `docs/validate-c02-provisional.cjs`: +51/-1; review incompatible-family/no-mutation additions with both fixture corpora and exact schema; old validation fingerprints are not current-byte fingerprints.
3. `supabase/functions/bridge-sync/README.md`: +2/-0, directory-guide links only; supplemental review because links may target local-only guidance on Kath's checkout. No automatic application.

## Relevant commits and local-only work

Full IDs, attribution and cached-upstream membership are verified below. `035e842` is a 45-file preservation commit, not sole authorship or a selective-transfer patch; it contains unrelated changes and historical secret removal, so do not export/apply it wholesale. `2d2622e` preserves K-04 review, not new runtime implementation. Selected tracked backend/contracts/tests generally come from the backup or earlier history; their exact last-touch commits are in the hash inventory. Selected Q07, Q12 and newer evidence/tests are local-only where indicated. “Beyond cached upstream” does not certify current GitHub/Kath absence.

| Verified commit | Author / recorded date | Scope and relevance |
|---|---|---|
| `035e8425af7b880c0351f672a875a5f689062d65` | `charlynaguirre91-lab`, 2026-10-30T02:09:30+08:00 | “backup: preserve SmartHatch backend work before autonomous tasks”; many selected backend/test/contract files last touched here; selective comparison only |
| `2d2622e6b1b0c538dda3c3023e97ae467eaf53b6` | `charlynaguirre91-lab`, 2026-10-30T02:15:24+08:00 | “docs: preserve K-04 backend dependency review”; modifies only `docs/contract-review/K-03B-02_Chicken_Profile_Record.md` (+33), intentionally outside this minimal continuation set |

Both appear in `origin/cha-branch2..HEAD`; cached upstream is `c7a26cfcaa619708aff4f793e8068ee176a6cf58`. No commits from other local branches lie outside HEAD ancestry. No fetch or current hosted membership check occurred. Historical contributor credit is not transferred to Kath by future ownership.

## Phase 1 validation results and blockers

- **77 selected exact paths + 1 supplemental modified README = 78 independently computed SHA-256 records.** Every file exists locally; every recorded digest was rechecked against current bytes. No missing/changed inventory digest. No Git blob hash substituted.
- The original manifest's **747 non-secret file digests** were independently recomputed: all match. The newly selected three dependency-extension paths (one_active_batch test and pubspec pair) were checked directly, not assumed from that manifest.
- New documents 14–16 exist and their local Markdown links resolve. Existing handover documents were only read; no writes outside these three new documents occurred.
- Final working tree: **3 unchanged pre-existing unstaged modifications; 707 untracked; 710 total status entries**. Zero staged/deleted/unmerged entries. Initial count was 704 untracked; the increase is exactly these three documents. The extra pre-existing ZIP was excluded. No patch exported/applied, PR created, branch/index/configuration change or remote operation performed.
- No application tests/builds, SQL, provider actions, networking, firmware/hardware access, credential or certificate inspection. Dependency inspection and hash comparison are not test execution.
- Kath's actual file presence/hashes/local changes remain **unknown**, not missing. Original P1–P6 approval artifacts/hash binding are unavailable locally; see [16](16-P1-P6-APPROVAL-ATTRIBUTION-CLARIFICATION.md). Current user-confirmed Kath approval is separately recorded.
- Still blocked: matching Ally raw packet/flashed identity, final wire selection, Q07 provider/native/SDK/assignment evidence, real account-scoped authorization/persistence tests, result-only implementation, Q12 authoritative fingerprint/actual inspection/original rollback evidence and separately approved recovery/operational scope.
- No implemented/verified Q07 0.2 account-specific security suite was located in the selected evidence. Existing tests characterize older candidate/legacy behavior and cannot substantiate acceptance of the new policy.
- Ready for **read-only comparison**, not transfer, merge, execution or formal handover acceptance. Kath's acceptance remains pending. No blanket-copy recommendation.

## Independent SHA-256 and current Git metadata

Every record below uses SHA-256 over current file bytes, not Git blob IDs. Source branch/HEAD are explicitly attached to every row. `Review required` is yes for every selected row; PR disposition/purpose/dependencies/evidence join to the selection tables above. A matching hash establishes identical bytes despite different HEADs. A mismatch requires scoped comparison, including possible CRLF/LF differences; do not normalize or edit either file during Phase 1.

| Exact path | Source branch / HEAD | Current status | Unstaged | SHA-256 current bytes | Last-touch commit (tracked) | Review |
|---|---|---|---|---|---|---|
| supabase/functions/_shared/bridge-sync-core.mjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | b7a9aa133ce46d180b84de0c2f712c5dc9229cf59c8b24c42f4dd661750850d2 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| supabase/functions/_shared/bridge-sync-supabase.mjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | f2f047c1826b02aef5b39c4c25f841a887440a9a9b95182076af00abc1e49f04 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| supabase/functions/_shared/bridge-monitoring.mjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 863447ee1c8a869cff380a7d55e99d6ce5ae207b9bf8237dc849efbdb0b434ec | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| supabase/functions/bridge-sync/index.ts | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | e6d6fb79ddd31cf31796608457ea92efdf182f4e54912b5244e619c511c501c6 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| supabase/dev/serve-bridge-sync.mjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 73f3bcff120c87d91c3f606d6507e0b8c096894be462265f6147f2d56739074d | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| supabase/migrations/20260929070513_remote_schema.sql | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 6a1e3560f1d5afea60787c3639bbc170fc21adfe7b3418a2be371ede643b9425 | d50dafbf50a24cfb64b93902ed1e45fcff4d7b4d | Yes |
| supabase/migrations/20260929204930_remote_schema.sql | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 | 7f578afc28f2750c335097826d9ceeb0390734ae | Yes |
| supabase/migrations/20261012090000_incubator_sessions_single_active.sql | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 7b2ecca0e41eac1832fa451550faab65b234570968878e0d903d56c8dbde162b | cd481f36d8cfaf63a205894f6b40fa6afd14fac8 | Yes |
| supabase/drafts/DB-IMP-01_disabled_registry.sql | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 6d8e11d72f28bb6291184fea2227d20adb3dc9d73761517d86a87abe5517644b | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| supabase/drafts/DB-IMP-01_authorization_schema_draft.sql | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 258fad0aa091e6e5b7ba6bb660df84a2269aa0f326ecb72706eec6fb26e764d0 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| supabase/drafts/DB-IMP-01_bridge_sync_rpcs_draft.sql | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | dcb065fac25e2b26366d424bb236020185aaba92d23115e49fdd2584289eec4a | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| lib/services/supabase_service.dart | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 8af0b3288bd605bd1a8493c88df6ece83e68e52102190cbb3fc6f41800076c5b | e2c392d9bf22bafd77aa24278aeed84693507bb1 | Yes |
| test/backend/bridge_sync_http_test.mjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | b35c443438b22d32e56bc61fff2841c81a383006fe040c4f94e71db0e1210493 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| test/backend/bridge_monitoring_test.mjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 16980ca19914755b82ec3890261183b41a386c6d03f246428270ab5f7377e4dd | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| test/backend/architecture_alignment_test.mjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | f5ad1a3f2dd75c9b39245dc951cd908eeb427e2926b9f53cfd0703e7729f0f5b | None | Yes |
| test/backend/monitoring_boundary_test.mjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 4d586db6580d30a5b71a3ae996df439d648c4cfd517f35d29ab5acabb45c0b5e | None | Yes |
| test/integration/int_imp_01.test.cjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 1aef6eafe347e21105e729e52ee94d4ef98e1ed74ea65580fceefc43ecefc834 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| test/integration/support/int_imp_01_mocks.cjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 7bcf31c3dc5dc978e157e4475e9de438858b72da214c5ba5842e317fce8e1fa0 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| test/fixtures/integration/int_imp_01_sources.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 0bd3132aabd4a90989290e7ee226d5b7750bb9a264dab9f88c514a270029fcbe | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| test/fixtures/integration/hw02_batch_review.ndjson | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | e6c9ad858db1610a9aa3daab87c25ea575e42e282c033faed364bb7d0d654035 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| test/fixtures/integration/hw02_corrected_review.ndjson | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | c4c38f41d8aaaf24cc713b799641d9b8c8fb23c8f1d4f967daf69b4773bb9f11 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| test/fixtures/integration/db_imp_01_closed_gate.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 19ff6314a0955eed6e2dee35ee683aa9b8b2e156328524baebe03b62119312e7 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| test/session_ownership_audit_test.dart | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | e5cdbe29ccfdc2cb7a4c259181700f87758021f385df561aa110acb0e7e479d9 | cd481f36d8cfaf63a205894f6b40fa6afd14fac8 | Yes |
| test/one_active_batch_test.dart | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | f61751752063ccb6b8c1031ebf60a7b7b7d39a5d87cb2959080355d29c95099f | e2c392d9bf22bafd77aa24278aeed84693507bb1 | Yes |
| pubspec.yaml | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 61166a522d05709ae41fda2b4aad4a0e47d9fb2c1aad8b6c780bf9806b8d60d6 | e2c392d9bf22bafd77aa24278aeed84693507bb1 | Yes |
| pubspec.lock | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 7500f085c11d6bb49a9dfe81b3d6184aafe4782324837df4c80a2d67264e96a1 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| arduino/SmartHatch_Uno/SmartHatch_Uno.ino | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 0365b18bc969d36547440b5e4299b946da03fa5aeccdbff0fff8dc8efeef01fc | dd8583dbfd900a7277800ceaa2aecefdc532c02b | Yes |
| arduino/SmartHatch_Combined/SmartHatch_Combined.ino | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | a466a868e6c148cf4f9c3230378d5033d81db89dfb77a3e0fa53891d847a9598 | 9744d17a6a287e4a97310c26f79f56e12351392f | Yes |
| docs/validate-c02-provisional.cjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked modified | Yes | 40c7bd4444612c317f72058ad6fb74c0710d0a95098bd67fab352bd235395e63 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/contract-review/Q07_Provider_Session_Binding_Policy_0.2.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | ba7f4d082ee9f7916829e7c44f75a5a192c26d6324b06e588b9b07b6992cad8c | None | Yes |
| docs/contract-review/Q07_Plain_Language_Access_Proposal_0.2.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 8200322da2118c8a76e0ae1e16fa29c493062033c390c1d3a03a30505dc8ed69 | None | Yes |
| docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked modified | Yes | 213497b44449489db119099a600e059079efe040e6444423df1a2dd3fb307bdd | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/contract-review/Q07_SMTP_Test_Project_Plan_0.1.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 6e756e6a31bb128b369df0379b07a5687e2df0ad3c6d0441b4b2eec172370d28 | None | Yes |
| docs/contract-review/DB-02_Exact_Bridge_Sync_API.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 5678de5b6c6c1bcd7de827a4a28ad80b6f6d51454663f73118c6b12229a681ab | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/contract-review/DB-02_Proposed_Schema_And_Security.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 6322985031a82d25184bd0ebefc7e1a9016d74c22b7e8d587e94dafb16d3f230 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/contract-review/DB-02_Conflict_Receipt_And_Recovery.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 08e6f97c7c320769e223218fbea7ce52a1d4a1b0ec5d117a83965d5678f39f06 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/contract-review/DB-02_Manual_Result_API_0.2-review.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 304da072775686906e67ea77ce635794273869f8ba3d933dcae80bf3fcdeabd6 | None | Yes |
| docs/contract-review/manual-result-0.2-review/schema.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | b2d739271a2a575536c6db8c18504477eac951f63bfb88828bdf0f1db42cc7c4 | None | Yes |
| docs/contract-review/manual-result-0.2-review/fixtures.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 5ec00ee6b891e6c21cb5c3a378fca9fa6ea1c06d60e4d6c1b36a07b036bf2afa | None | Yes |
| docs/contract-review/manual-result-0.2-review/reference.cjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 032f070b7e584729436a311aea4a8cd9d2223650d40e8f907698056c0763c209 | None | Yes |
| docs/contract-review/D04_D06_Mary_Backend_Position.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | ba4ff1ec9dfb5f7b3168f3a805d891b83c265b96876274bb9bf0ab39552d0869 | None | Yes |
| docs/C02-provisional-communication-contract.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 3559b60ace2b2d12e0a52304ed4ff1d9831a416b9a4edb5478d7ec359a69ddb7 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/C02-provisional.schema.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 9e95d34ca160cae8600548c5c4919ece26953d892d77bd786198d9e9e15461dd | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/C02-provisional.examples.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 155a44ed24f2c0627481822569c008b1ee332d315d72abe3bf9f09fc584275b5 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/SmartHatch_K06_Consolidated_17_Decision_Contract_v0.4_Bluetooth_Android_Bridge.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 28311c53ed9675232ee6a25e9e481f8af26a10182de8f765edbf884e6fb1eed2 | None | Yes |
| docs/contract-review/C02_Wire_Family_Decision_Request_2026-11-02.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | ce5ecf7e1aa4c2d17bc03e72ad46eddcb40620df89b61dbaad860856df350fb7 | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/ModelPolicy.cs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | d94cb03cb1d61a5251d7b6e3c211288553cd3688d7a93fe859352c531dfb9fd8 | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/NativeBoundary.cs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 381f705c0892d7b8f93278e14da545ba013e0afce77642d10e2b4f9b044b5268 | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/DurableController.cs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | a9ffb06222e53f31f1cda4fc848dc646257b83790ffd067ae87473790fb4bcb9 | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/SourceSnapshot.psm1 | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 8998819dbf1458e83d80c537066cd7c5ab16d044e5954a823b61c8b4c26a9be2 | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/Invoke-Q12PhaseA-V3.ps1 | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 004b5468b3e0fda8c52cd4efe1edd70fefd33de9424b8ce516c21dd28b761ae9 | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/Correction.Tests.cs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | dd8e5a6fd0d2e286ddfc91701187d930ad59719fb12aad48fe46509656b1d113 | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/Followup.Tests.cs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | dd012010cb1f6fb86c98dfc1c10a973c13e355455841466096561b8de1ff8fc1 | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/Test-Corrections.ps1 | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | b6838eb5942fe96ae7dc2684e9f2bc8f57b54b5429274f34ebf6ab98881eeba4 | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/README.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | eea740d5b27e272d4bc385119f5ba8680f6d2dc4e7a4bd332c1d04ef16dee54f | None | Yes |
| docs/integration/cha-execution/Q12_Phase_A_Read_Only.sql | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc | None | Yes |
| docs/integration/cha-execution/q12-phase-a-status.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 341a49d2a5193878252e65357484fb6e6eaafd68232f9b5345f73e1db712b0fb | None | Yes |
| docs/integration/cha-execution/Q12_PHASE_A_ATTEMPT_1_RECEIPT.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 11cdf66dbada5874fde06504f7d1b929b30080196849e47313d89871653d0913 | None | Yes |
| docs/integration/cha-execution/Q12_CERTIFICATE_PROVENANCE_OWNER_UPDATE.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | ede9b61185a10fc48841d978d986a8f88c7c202ac6641095c34fd096f24e068c | None | Yes |
| docs/integration/cha-execution/Q12_CERTIFICATE_PUBLIC_REFERENCE_ASSESSMENT.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | d5b80a71b5f52946242e185eaaed376ac1ddc6460c5bb176c0b1ec0d9a42917b | None | Yes |
| docs/integration/cha-execution/q12-execution-package/REVIEW.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | aa8951f2726e336934929798b4d84a948437b8aa1f81fed87100827a330e02eb | None | Yes |
| docs/integration/cha-execution/q12-execution-package/PENDING_REMOTE_AND_CLOSURE.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 0748a45e1b8c0dd7cc34db476e51fc49c18e2c34eaa367cb1e85aa1dfefd972b | None | Yes |
| docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/test-results.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 4882652349926f6e3a158f1b9af4d2bef195478748e0e7e2395951b9401c7fd3 | None | Yes |
| docs/integration/cha-execution/ALLY_C02_20261102_RECEIPT_AND_CLOSURE.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | e068fb4c06fd302e568e270ef085569b334aed6c7e37f00868a793d60462e895 | None | Yes |
| docs/integration/cha-execution/received-ally-c02-20261102.txt | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 9751a0ee6bae3da807798c6f047589ca1b05349a466e6e0aa3f808ff50472436 | None | Yes |
| docs/integration/cha-execution/ally-c02-schema-revalidation-20261102.txt | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | d580a05e219b861815fc132ff2b437a283e13955f682bf995ee0074255efb259 | None | Yes |
| docs/integration/cha-execution/ALLY_ZIP_C02B_REVIEW.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 2250c3723211f1abe1d8812bdc8100df94ddbcfb399f08850ec2b32e56d3ef2a | None | Yes |
| docs/integration/INT-IMP-01_Evidence.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | c206cb6152b8c87c588c03b10d4948939aee71dc66a67659c8f9d55d0a372d05 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/integration/cha-execution/KATH_02_DELTA_ACCEPT_RECEIPT.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | c78dd9951b2cd76db367871acd9cd0d2b158158e72c3a470f82d02689e494fcb | None | Yes |
| docs/contract-review/MARY_Backend_Preparation_2026-11-01.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 2fd9c9e8fa77a5191d22ecd36b33b8dd9e7d65877090c19ca5c0164222a3385d | None | Yes |
| supabase/functions/bridge-sync/README.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked modified | Yes | 034358a48400e1e8be4fd9a55d1ed694602e713d08c1ce8aca0f29efe70e3433 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| test/integration/export_int_imp_01_fixtures.cjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Tracked clean | No | 36a58827d2213699f1da6999b02147de01b674db599590f22253b7229b159f07 | 035e8425af7b880c0351f672a875a5f689062d65 | Yes |
| docs/integration/cha-execution/manual-result-0.2.test.cjs | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 6548f2c7dd291c816c7654bd73bde404ee9c75c0fda48563c97f2b97e0126139 | None | Yes |
| docs/contract-review/manual-result-0.2-review/parent-and-change-manifest.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | a2c723c8e574fe4cf6c22bde5039c94e58d04a50d05f73502173fd713ea287a0 | None | Yes |
| docs/contract-review/DB-02_Manual_Result_API_0.1-review.md | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | be60e96696bcf6acde43727b2205410a81beed08907e7ce7a8a0c8770c20bb98 | None | Yes |
| docs/contract-review/manual-result-0.1.schema.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | c8a17ad20cc1bc6656ef2f4029c725916fb9fab4bb0b5085850f75f8c7909125 | None | Yes |
| docs/contract-review/manual-result-0.1.fixtures.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | a92cba4f788eb844bd04824db3fa14c8c963dc57397299a7ae4d624bc8952f77 | None | Yes |
| docs/contract-review/manual-result-0.1.closure-matrix.json | cha-branch2 / 2d2622e6b1b0c538dda3c3023e97ae467eaf53b6 | Untracked local-only | No | 55c66ae00782dfdd4c255e2bfb9c2c984fdf0b2655cc42610f744ad9e31efbf2 | None | Yes |
