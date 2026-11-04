# Cha local preparation and targeted team approvals

## Current authorization

The user selected **Local preparation only**. This follow-up makes no remote
queries/writes, Auth provisioning, cleanup, migrations, RLS changes, activation,
deployment, commits or hardware changes. Earlier catalog evidence is reused,
not re-queried. OCT26:C-01 stays **Partial**; no next portal task is started.

Prepared `security-test-plan.json` and its offline safety validator. The plan
covers read/write identity boundaries, exact RPC names, disabled gates, and
future transaction/duplicate/conflict checks. It contains no runnable remote
test or credential. Validation proves only that the plan's safety constraints
are internally consistent—not that database security passes.

Run locally:

```powershell
node docs/integration/cha-execution/validate-security-test-plan.cjs
```

Results: `security-test-plan-validation.json`. Live cases remain NOT RUN or
BLOCKED_BY_TEAM_DECISIONS. No approved authorized-installation fixture is invented.

## Files needing Kath/Ally review of specific decisions

These are existing documents, not new implementation assignments. Do not ask them
to approve all files indiscriminately; record their attributable answer to the
specific interface/behavior they own. Mary also reviews backend decisions.

| Existing file | Who must review | What remains to agree |
|---|---|---|
| `docs/contract-review/CONTRACT-FREEZE-01_Team_Decisions.md` | Kath + Ally + Mary | Record actual D01–D06 answers: canonical source/catalog, lifecycle/recovery, real byte/build limits, local/online authorization and retention, profile/time policy, and Android/cloud mapping. Existing pending rows were not filled here. |
| `docs/contract-review/INTEGRATION-CONTRACT-03_Shared_Decision_Register.md` | Kath + Ally + Mary | Close specific cross-component conflicts against one selected revision; no independent architecture re-selection. |
| `docs/contract-review/DB-02_Exact_Bridge_Sync_API.md` | Kath + Ally + Mary | Kath: request/receipt compatibility; Ally: original event/batch/command/sample identities and actual source fields. Preserve the exact three RPC names; unresolved wire mappings stay disabled. |
| `docs/contract-review/DB-02_Conflict_Receipt_And_Recovery.md` | Kath + Ally + Mary | Kath: immutable outbox, receipt reconciliation, local draft/completion handling; Ally: retained source evidence, replay and feasible retention/loss guarantee. Stop-versus-completion prerequisites need an explicit shared decision. |
| `docs/contract-review/DB-02_Proposed_Schema_And_Security.md` | Kath + Mary; Ally for source/local authority assumptions | Kath: transition from anonymous/direct-table access to scoped installation identity, startup and History compatibility. Ally: controller identity/provenance and offline command authority. SQL security remains Mary's implementation/review responsibility. |
| `docs/contract-review/K-03B-02_Chicken_Profile_Record.md` | Named profile approver + Ally, with Kath/Mary acknowledging mappings | Exact approved profile/capacity/clock/freshness values and source evidence. Kath/Ally agreement alone is not a substitute for the designated numerical-profile approver or physical safety clearance. |

The local `docs/C02-provisional-communication-contract.md` and
`docs/contract-review/Original-C02-candidate-1.md` are historical/provisional
contract candidates. Related JSON schemas/examples must match whichever exact
revision the team selects. Do not request blanket approval of conflicting
candidates or treat an old candidate as the chosen active wire catalog.

Some source packet names are references to Downloads attachments, not repository
files: `SmartHatch_Shared_Communication_Contract_v1.3_DECISION_READY_DRAFT.md`,
`UI-CONTRACT-03_Final_Compatibility_Decisions.md`, and
`HW-02_Exact_Wire_Message_Catalog.md`. The table above identifies actual repository
paths. External filenames alone do not establish the approved revision/hash or
that the file is currently present; request the exact matching packet from its owner.

## SQL drafts: review versus execution approval

- `supabase/drafts/DB-IMP-01_disabled_registry.sql`
- `supabase/drafts/DB-IMP-01_authorization_schema_draft.sql`
- `supabase/drafts/DB-IMP-01_bridge_sync_rpcs_draft.sql`

These stay **DO NOT APPLY**. Kath/Ally need to review their relevant assumptions
above, not author or approve every backend SQL line. Applying any draft also
requires Mary's explicit environment/action authorization and real isolated SQL
validation; teammate contract acceptance does not authorize deployment. Local
draft preparation is permitted, but unresolved identity/source/receipt semantics
are not finalized in this follow-up. No existing SQL draft was changed.

## Next action

Share the targeted table with Kath and Ally and obtain exact replies/attachments
for the unresolved interfaces. Until those replies and separately scoped remote
test authorization exist, retain the local test plan, keep ingestion disabled,
and leave the audit Partial. Do not skip to another task or mark mock/static
checks as real permission/integration acceptance.
