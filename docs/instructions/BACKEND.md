# SmartHatch backend working instructions

## Current ownership and policy precedence — 2026-11-05

Kath explicitly accepted future Flutter and Supabase backend development
responsibility on 2026-11-04 so Cha can focus on the paper. Preserve Cha/Mary's
backend contributions and dated reviews; Ally retains firmware/hardware ownership.
See `docs/handoff/2026-11-04/backend-responsibility-acceptance.md`. This resolves
future responsibility acknowledgment only, not blanket acceptance of every PR,
contract, risk or operational action. Do not ask for renewed Cha approval merely
because an older record names her as backend owner.

Read the shared GLOBAL, PROJECT_CONTEXT, DECISIONS and ARCHITECTURE guides in
`docs/instructions/` when present, then the exact linked backend records below.
The historical review and candidate-implementation facts are retained, not
reclassified as current implementation permission.

Q07 revision 0.2 P1–P6 account-based planning is already approved by Kath:
self-service signup, one-time email verification, ordinary email/password login,
one-time authorized assignment of correct records, no approved-phone gate or
routine session reapproval, protected logout/local isolation and account-scoped
History. See `docs/contract-review/Q07_Provider_Session_Binding_Policy_0.2.md`
and `docs/backend-handover/16-P1-P6-APPROVAL-ATTRIBUTION-CLARIFICATION.md`.
Do not reopen this unchanged approval. Existing installation/session-bound code
and SQL remain historical candidates requiring explicit compatibility work; they
do not implement the newer policy. Stable actor/installation evidence identities
must not be silently rewritten to remove an old authorization restriction.

No production/Auth/RLS/RPC/schema change, deployment, source activation or
occupied-controller operation follows from ownership or local validation.

Reviewed: 2026-11-01, against `cha-branch2` / `2d2622e` plus existing working-tree
records. This is maintained backend working guidance, not joint contract adoption,
an implementation permission or a security/physical certification.

## Read first and preserve existing work

- Check branch, `git status --short --branch`, existing diffs and actual source.
  Preserve uncommitted/untracked work. Do not automatically commit, push or merge.
- Shared package paths are `docs/instructions/`, not the earlier requested flat
  `docs/ARCHITECTURE.md` / `docs/DECISIONS.md`. Read the shared guides when present;
  do not copy another checkout over this one or invent missing files' contents.
- Read the [package review](../contract-review/SHARED_INSTRUCTIONS_Backend_Review_2026-11-01.md)
  and [existing answer ledger](../contract-review/CONTRACT-FREEZE-01_Team_Decisions.md).
  This guide is not a competing decision register. Cite exact scope/revision when
  conflicts arise; propose a correction rather than silently overriding an answer.
- Search newer scoped receipts before asking questions. A later answer supersedes
  only its stated fields, not an entire historical contract or report.

## Protect the existing running batch

Kath reports eggs already incubating autonomously on Arduino **programmed by Ally**.
The unfinished app is disconnected; RTC/Bluetooth physical testing is pending.
Automatic temperature/humidity/turning are attributed reports, not a newly verified
physical PASS. Exact prior uploaded-image matching remains unresolved; a candidate
review's NOT FLASHED statement does not negate Ally's earlier programming.

- Treat it as the same existing SmartHatch batch, not transferred-egg onboarding,
  a fresh Start or evidence of an already-authorized registration operation.
- Existing-batch reconciliation/registration remains proposed, not adopted or
  implemented. Do not create a duplicate session, replay Start, synchronize settings,
  complete/delete another record or release Active to make the app catch up.
- No development-driven connection, USB/serial/Bluetooth opening, module attachment,
  reset, power cycle, reflash or command experiment on the occupied controller.
  Even a read-only program can trigger connection-related reset. Hardware/safety
  concerns belong with Ally and appropriate qualified guidance, not guessed procedures.
- Preserve operator species, original eggs-set count and Start text with reporter,
  evidence, timezone, precision/uncertainty and record-entry time. Keep these apart
  from controller-confirmed identity/Start, acquisition time and phone/cloud receipt.
  Unknown remains unknown; do not manufacture midnight UTC, a verified day, original
  manifest or source ID from app launch, current Running or a recent receipt.
- Future evidence review may yield matched existing session, unmapped batch or
  conflict needing adjudication. None grants writes or commands. Any future remote
  lookup, registration or hardware observation needs its applicable explicit scope.

## Directory layout and migration-history safeguards

See [the backend directory guide](../../supabase/README.md).

| Path | Boundary |
| --- | --- |
| `supabase/config.toml` | Local CLI configuration; not hosted configuration evidence |
| `supabase/migrations/` | Historical timestamped migrations; preserve names, order, bytes and location |
| `supabase/functions/bridge-sync/index.ts` | Candidate Edge entrypoint; not a deployment claim |
| `supabase/functions/_shared/` | Actual local handler, Supabase HTTP adapters and monitoring helpers |
| `supabase/dev/` | Supporting Node loopback adapter, not an Edge deployment directory |
| `supabase/drafts/` | Offline disabled SQL proposals, deliberately outside automatic migrations |
| `test/backend/`, `test/integration/` | Local boundary/mock tests; keep import paths and historical evidence intact |
| `docs/contract-review/`, `docs/integration/` | Dated candidates, answers and evidence; retain originals |

Never rewrite/reorder migrations or move draft SQL into migrations as cleanup.
Migration presence does not prove deployment. Preserve existing IDs/History and
real `egg_type`, `egg_quantity`, `eggs_hatched` meanings; bigint API mappings must
be lossless decimal strings, not floating-point casts. Do not invent new schema
from prose or silently convert legacy timestamps/statuses into verified facts.

No database reset, migration application, account provisioning, Auth/RLS/grant/RPC
change, deployment or production access follows from documentation or local tests.
Q12 phase-A read-only test-project approval is already recorded; do not ask for that
same approval again or expand it. The recorded attempt is Partial/Blocked, original
rollback is unverified, and remote retry requires specific approval. Later phases
remain excluded: see [current Q12 status](../integration/cha-execution/q12-phase-a-status.json).

## Identity, authorization and provenance

Sources: [Mary's D04/M07 position](../contract-review/D04_D06_Mary_Backend_Position.md),
[DB-02 0.1 API §§2–3/5](../contract-review/DB-02_Exact_Bridge_Sync_API.md), and actual
`supabase/functions/_shared/bridge-sync-supabase.mjs`.

- In the historical v1 candidate, protected operations require verified
  non-anonymous Auth plus authorized installation/controller/session scope on
  each operation and replay, including receipt/reconciliation reads. This
  describes the old implementation boundary, not the selected Q07 0.2 account
  experience above. IDs are not credentials; do not bypass the old gate without
  implementing and testing the explicitly scoped replacement authorization.
- Controller, installation, original actor, current uploader, batch, command/query,
  event/sample and cloud session are distinct. Never guess associations from latest
  Active, a Bluetooth name, upload order or a global latest-reading query.
- Cloud authorization is not offline command authority or source authenticity.
  JWT decoding alone is not verification. Token/session possession does not prove
  one physical phone. Cloud expiry/revocation is not controller Stop.
- The local adapter uses trusted Supabase Auth before claim checks; real signature,
  registry/RLS/revocation and transaction enforcement still require actual isolated
  verification. Future SQL must recheck authorization and canonical content atomically;
  direct RPC/table calls must not bypass validation by trusting an Edge-provided hash.
- Missing registry/RPC/source contract fails closed. Do not enable hard-disabled
  capabilities or install fixture adapters into production entrypoints to get a PASS.
  Preserve the local adapter's main-project refusal; no legacy direct-table fallback.
- Source acquisition/occurrence, monotonic age, phone receipt, cloud receipt and
  manual entry times remain separate. Keep unknown source time null/invalid where
  allowed; no receipt-time repair, fabricated epoch/sequence or numeric-to-UUID cast.
  Delayed data is not live because upload is recent. Targets are not actual readings;
  sensor validity, freshness, calibration and source authentication are separate.
- Never expose `.env`, CLI link metadata, tokens, keys or private rows in logs,
  fixtures or handoffs. No service-role/privileged credential in Flutter or firmware.

## Contract and implementation status — do not flatten these levels

| Artifact / exact scope | Status and permitted interpretation |
| --- | --- |
| K06 v0.4 architecture, INT-01/02/06 | Selected HC-05 Classic SPP / Android / autonomous Uno direction; formal adoption remains separate; USB/ESP8266 history is not a replacement route |
| `DB-02_Exact_Bridge_Sync_API.md` and companions, `0.1-review` | Historical proposed cloud v1 contract; not jointly approved or deployed |
| `supabase/functions/_shared/bridge-sync-core.mjs` | Local v1 handler exists; requires `api_version===1`, retains legacy `stopped_event_id`; default source submissions are disabled |
| Supabase adapters / SQL drafts | HTTP boundary code exists; named persistence RPCs and actual secure transactional behavior are not established by it or the disabled SQL drafts |
| Manual-result `0.2-review` | Exact candidate has scoped Kath ACCEPT; not enabled, implemented by v1, formally adopted or deployed |
| M01–M08 | Mary's recorded personal design decisions; M08 is already approved; not blanket approval of packages, schema, controller authority or deployment |
| Local tests / received reports | Only their stated model/stub/loopback boundary; not real Auth/RLS, durable client transactions, integration, physical or whole-task completion |

Read [manual-result 0.2 delta](../contract-review/DB-02_Manual_Result_API_0.2-review.md)
with its preserved 0.1 parent and [Kath's received scoped ACCEPT](../integration/cha-execution/KATH_02_DELTA_ACCEPT_RECEIPT.md).
Older pending-Q05 wording is historical; do not request another unchanged review.

- Pin **both** `api_version: 2` and `contract: "DB02-MANUAL-RESULT-0.2-review"`.
  Contract is in the eight-field immutable hashed core. Pin matching schema,
  fixtures/canonical hashes and guards; reject wrong versions without fallback.
- Never relabel 0.1 actions, auto-convert outbox records or mint new result IDs to
  hide changed content/unknown commits. A future conversion needs explicit reviewed
  identity/receipt/History compatibility policy and authorization.
- **M08:** reserve action UUID at first durable draft creation, reuse as result_id
  at sealing/retry; first durable creation and seal may share a transaction. Recover
  ambiguous commits using the original committed identity. An in-memory draft is
  not durably saved. Actual draft/seal/restart transactions remain unverified.
- Result-only recording validates the trusted original manifest/mapping, positive
  original quantity and integer count `0..egg_quantity`. Missing evidence stays
  pending validation, not a fabricated mapping/hash. It requires no physical Stop;
  does not set Completed/end_date, clear Active, admit another batch, dispatch a
  command or release retained controller evidence (`retention_ack:null`).
- Legacy `completeSession` and historical v1 `farmer_completed` are not this feature.
  Do not remove their Stop dependency or reroute result actions silently under a
  documentation edit. Preserve historical fixtures and expose incompatibility.
- Closed shapes are followed by outstanding/original/outer/nested tuple checks,
  expected content/manifest/count/session and immutable receipt continuity. Absence
  or malformed responses do not prove no commit or authorize a new identity.
  In the exact 0.2 proposal only SERVICE_UNAVAILABLE and COMMIT_UNKNOWN are retryable;
  only COMMIT_UNKNOWN has unknown commit state. Recovery is not physical replay.

## Coordinate changes, not competing contracts

- Kath owns future backend and Flutter work; Ally owns firmware/hardware.
  Preserve Mary's prior backend attribution and source references. Before a
  schema/API change, identify exact source/catalog/contract hashes, affected fields,
  compatibility/version behavior, original manifest trust, authorization and time
  semantics. No implicit translation between incompatible messages called `v:1`.
- Ally supplies actual source/identity/time/retention evidence; Kath validates the
  matching decoder, durable intent/outbox/receipt behavior, truthful UI, scoped
  storage, idempotency, mappings and bypass protection. A report's
  source hash is not proof of running-image identity. Do not request answered votes.
- Preserve [existing Q06/Q07 proposal 0.1](../contract-review/Q06_Q07_Kath_Mary_Decision_Proposal_0.1.md)
  as a proposal, not selected package/SDK/enrollment/session policy. Native storage,
  session replacement and controller-side authorization remain exact shared choices.
- Species software approvals and Quail's 18-day decision in the shared package are
  not reopened. Exact numerical transcription, source applicability and physical
  capacity/safety evidence remain distinct; do not treat old missing-profile notes
  as negating later software-content approval or invent new numerical thresholds.
- Record actual scoped answers in the existing ledger; preserve dated originals.
  Review acceptance, formal adoption, implementation and test level are independent.
  This task authorizes no migrations, account changes, deployments or commands.

## Safe local validation (from repository root)

These existing checks need no production credentials, `.env`, hardware or real DB.
Node v26.4.0 is the previously recorded tooling; report the actual version/results.

```powershell
node --check supabase/functions/_shared/bridge-sync-core.mjs
node --check supabase/functions/_shared/bridge-sync-supabase.mjs
node --check supabase/dev/serve-bridge-sync.mjs
node --test --test-timeout=15000 test/integration/int_imp_01.test.cjs test/backend/bridge_sync_http_test.mjs test/backend/bridge_monitoring_test.mjs test/backend/architecture_alignment_test.mjs test/backend/monitoring_boundary_test.mjs
```

The suite uses fixtures, mocks, temporary host storage and loopback HTTP; it does
not implement or prove real Supabase persistence or physical Start/Stop. Test fixture
adapters stay test-only. Syntax checks do not prove Deno/Edge build compatibility.

Optional exact 0.2 schema/reference check, **only with already available reviewed
Ajv8/ajv-formats tooling** (no dependency install or app package edit implied):

```powershell
node --test --test-timeout=15000 docs/integration/cha-execution/manual-result-0.2.test.cjs
```

Missing tooling is BLOCKED, not PASS. Kath's missing-Ajv run and Mary's separately
recorded 27/27 run are distinct evidence. Do not relabel either or claim a new run.
Do not launch `serve-bridge-sync.mjs` as an offline check: explicit environment
settings can make it contact Supabase. No `supabase start`, reset, link, db push,
deployment or provisioning is needed for documentation validation.
