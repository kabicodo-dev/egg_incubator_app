# Shared instruction package — backend review

Date: 2026-11-01. Scoped backend documentation review, not joint adoption,
implementation permission, deployment or new physical verification.

## Exact reviewed snapshot and placement

- Input: `SmartHatch_Shared_Instructions_2026-11-01.zip` supplied from Downloads.
- Raw ZIP SHA-256: `95dba6fd152869bf1dd89adad37b23e14a7573ae4ab3e62f5eb6b6fd957b2b50`.
- All **34** manifest entries matched their declared size/SHA-256, freshly checked.
- Inspected branch: `cha-branch2`, HEAD `2d2622e`; pre-existing modified/untracked
  work preserved. No branch switch, fetch, merge, commit or push performed.
- The ZIP actually uses `repository/docs/instructions/{GLOBAL,PROJECT_CONTEXT,
  ARCHITECTURE,DECISIONS,BACKEND}.md`, not flat `docs/ARCHITECTURE.md` or
  `docs/DECISIONS.md`. Its `supabase/AGENTS.md` is a discovery pointer.
- Read root pointer, shared global/context/architecture/decisions/backend guides,
  running-batch README, supplied manual-result 0.2 RESPONSE and existing local
  backend/decision sources. Package files were extracted separately, not overlaid.
- Added only the backend pointer/maintained role guide and this review, plus a
  navigation link in the existing backend README. Shared package documents, app,
  firmware and received evidence were not transplanted or rewritten.

Exact package fingerprints (raw bytes, not adoption signatures):

| Package path under `repository/` | SHA-256 |
| --- | --- |
| `docs/instructions/ARCHITECTURE.md` | `02cf83f599141a16f9efe92f611a42eec761a9cb614e1e126fab1edb28bc575a` |
| `docs/instructions/DECISIONS.md` | `4bc19f502a6fe5e93d11a344b463a78630b206d86253a25f5b352256c7b04a8a` |
| `docs/instructions/BACKEND.md` | `f86848727979a856d98f8c20e1a1a827d1e7a94f283520847b3dcc0f1ca19590` |
| `supabase/AGENTS.md` | `749783588e0196e6435a6746a3df8d31cbe4a1be88022b402cbe726129677704` |

## Section-by-section dispositions and exact proposed text

ACCEPT means the stated guidance is supported for this review scope, not formal
contract adoption, another owner's vote or proof of implementation.

| Shared section / lines | Disposition | Exact source and correction |
| --- | --- | --- |
| `supabase/AGENTS.md`, 1–6; `BACKEND.md`, 1–46 | CHANGE (expand role guide, preserve pointer design) | The package pointer targets guides not yet installed here. New `supabase/AGENTS.md` links the maintained local `docs/instructions/BACKEND.md`; that guide adds actual layout, commands, local status and dated source links without importing other checkout files. |
| `ARCHITECTURE.md`, selected responsibility flow, 6–46 | ACCEPT | K06 v0.4 INT-01/02/06 and package running-batch README §§Current operating context / Consequences. Existing batch programmed by Ally, app disconnected; route is selected direction, not current deployed integration. No Start/registration/observation permission follows. No replacement needed. |
| `ARCHITECTURE.md`, Observed Flutter layout / Important gaps, 48–76 | CHANGE (qualify checkout; do not undo Kath's work) | Package observations refer to its checkout, while local `lib/main.dart` remains the earlier layout. Add: “These layout and driver observations identify the package author's checkout only. Recheck the target branch and local changes; absence here does not negate another branch's implementation. The backend working guide records this checkout's separate status.” |
| `ARCHITECTURE.md`, backend row 42 and startup/direct operations 69–72 | CHANGE (add exact implementation qualifier) | Actual `bridge-sync-core.mjs` validates api_version 1 and legacy stopped_event_id; `bridge-sync-supabase.mjs` contains Auth/RPC HTTP boundaries. Add: “Cha's checkout has local v1 handler/adapters with default source acceptance disabled. It does not implement result-only 0.2; SQL drafts/stubs do not establish real persistence RPCs, deployed RLS or transactional authorization.” |
| `ARCHITECTURE.md`, Evidence/state boundaries and checklist, 78–98 | ACCEPT | DB-02 0.1 API §5; manual-result 0.2 §1; Mary M02/M03/M06; Kath 0.2 receipt. Preserve all distinctions; no replacement needed. |
| `DECISIONS.md`, D08 | CHANGE (retain scope answer, add later backend position) | Mary D04/M07, recorded 30 Oct in `D04_D06_Mary_Backend_Position.md`. Append: “Protected operations require administrator-controlled non-anonymous enrollment and current installation/controller/session scope on each operation and replay, including reconciliation reads. IDs/session pinning are not physical-device attestation or source authentication; cloud authorization is separate from controller command authority. Exact bootstrap/replacement choices remain open.” Do not reopen the single-installation answer. |
| `DECISIONS.md`, D09 / M08 | ACCEPT | Mary position file, 31 Oct M08 §§3–21; Kath 0.2 receipt. Already approved personal design choice, not implemented transactions. No renewed approval or replacement needed. |
| `DECISIONS.md`, R01 | ACCEPT | DB-02 manual-result 0.2-review §§1/4; Kath exact delta ACCEPT. Both api_version:2 and DB02-MANUAL-RESULT-0.2-review, contract in hashed core; no relabel/fallback/migration. No replacement needed. |
| `DECISIONS.md`, R02 | ACCEPT | DB-02 manual-result 0.2-review §§2–3 and Kath receipt. Closed shape plus relational/runtime checks, exact commit/error semantics and immutable receipt continuity are required; implementation remains separate. No replacement needed. |
| `DECISIONS.md`, R03 | CHANGE (clarify reviewer-specific provenance) | Preserve S4's failed Node run. `KATH_02_DELTA_ACCEPT_RECEIPT.md`, 31 Oct, lines 30–52, separately records Mary's exact-suite rerun. Replace qualification with: “These are attributed historical results, not rerun by this shared-document task. Kath's local Node attempt was BLOCKED before cases by missing ajv/dist/2020. Separately, Mary's receipt records an exact unchanged-suite rerun with existing Ajv8/ajv-formats: 27/27 passed. Neither proves real endpoint, Auth, storage transactions, concurrency or physical integration.” |
| `DECISIONS.md`, C01–C03 and R05; running-batch README | ACCEPT | Supplied 1 Nov handoff distinguishes Ally's prior programming from candidate flash status, manual information from controller evidence, proposed reconciliation from registration authority. No missing-identity inference from disconnected app; no replacement needed. |
| `BACKEND.md`, result-only 33–36 | ACCEPT with expansion | Mary M02/M03, manual-result 0.2 §1, Kath receipt. Expanded local guide explicitly retains trusted original manifest, positive quantity, bounded manual count, legacy incompatibility and unchanged Active/end_date/admission/release. No new schema or API authorized. |

## Supersession and overlapping organization guidance

No newer **formally adopted** register is established by this package. Its
`DECISIONS.md` explicitly says it is not that adoption record. Preserve the local
`CONTRACT-FREEZE-01_Team_Decisions.md` as the existing attributable answer ledger;
the shared reading entry point can link it rather than invent a competing vote.

Narrow already-recorded updates are not missing approvals:

- Mary M08, 31 Oct: supersedes pending draft-identity reservation/reuse only.
- Kath 0.2 receipt, 31 Oct: closes the scoped exact-0.2 technical delta review,
  not shared source, Q06/Q07, implementation, formal adoption or deployment.
- Q12 status: phase-A read-only approval exists; the manually reported attempt
  was Partial/Blocked before catalog SELECT; retry remains gated. Do not generalize
  older “test unavailable” or “no remote attempt” runbook text into current status.
- Package 1 Nov reported running batch supersedes historical “egg loading pending”
  as operating context, not safety/RTC/Bluetooth verification. Later species software
  approval/18-day Quail is not negated by older pending numerical-profile notes.

Existing organization guides (`supabase/README.md`, `supabase/dev/README.md`,
`supabase/drafts/README.md`, function README) are retained as layout/runbook/history.
The role guide references them instead of moving files, rewriting dated evidence,
or treating directory cleanup as contract adoption. No identifiable organization
PR revision was supplied with this ZIP; reconciliation is against these available
working-tree guides, not a claim that an unseen PR was reviewed or merged.

Unresolved: selected matching firmware/source/catalog and running-image evidence;
trusted original manifest/mapping; Q06/Q07 exact native storage/enrollment/session
choices; formal adoption/distribution; real persistence/security/integration tests;
explicit existing-batch registration policy and any future execution permission.
Do not ask again who programmed the board, for M08, or for unchanged Q05 review.

## Verification for this documentation task

Freshly executed:

- Package manifest: **34/34** size/SHA-256 matches; ZIP hash above.
- `node --test --test-timeout=15000 test/integration/int_imp_01.test.cjs test/backend/bridge_sync_http_test.mjs test/backend/bridge_monitoring_test.mjs test/backend/architecture_alignment_test.mjs test/backend/monitoring_boundary_test.mjs`: **110/110 passed**, zero failures/skips/cancellations. Fixtures, stubs, loopback and temporary host files only; not real Supabase or controller tests, not 0.2 implementation acceptance.

Additional fresh checks:

- `node --check` separately for `supabase/functions/_shared/bridge-sync-core.mjs`,
  `supabase/functions/_shared/bridge-sync-supabase.mjs` and
  `supabase/dev/serve-bridge-sync.mjs`: all three passed.
- Local documentation check: four changed/added documents, **21** relative links
  resolve, code fences balanced, no trailing whitespace. `git diff --check` passed
  for tracked changes (existing LF/CRLF warnings only); the separate documentation
  check also covered the new/untracked files.

No new Dart/Flutter, AVR, real Auth/RLS/SQL, hardware or 0.2 schema-suite execution
is claimed. Existing 106 Dart checks / 27 schema-reference test results retain
their own provenance. No dependency installation or historical log overwrite.
