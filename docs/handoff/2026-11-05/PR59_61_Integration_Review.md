# Cha PRs #59–#61 — isolated integration review

Review recorded 2026-11-05; the request/acceptance conversation began 2026-11-04.
**Outcome: local backend/mock checks PASS; not ready for an automatic merge.**

## Exact scope and provenance

Kath authorized isolated integration review and local checks only: no merge,
push, workflow changes, Supabase operations or deployment. Review used a new
temporary directory, not a branch checkout or modification of her app source:

`C:\Users\ACER\AppData\Local\Temp\opencode\smarthatch-pr59-61-review-e691zi6q`

| PR | Exact head | Added paths |
| --- | --- | --- |
| #59 documentation/contracts | `01bef0b01e1c35ff6e112af4e705126b68038f4b` | 63 |
| #60 disabled backend candidate/tests | `2cf5dac7ecfc36a8531756634c601e8a114783bb` | 20 |
| #61 Q12 source/bounded historical evidence | `d3741c7d153d8bc9ed1aeb81d5300277af7b9884` | 17 |

All have parent/base `c7a26cfcaa619708aff4f793e8068ee176a6cf58`.
Read-only GitHub API/raw retrieval verified all **100 Git blob hashes**, with
SHA-256 recorded in `retrieval.json`. The isolated tree combines additions with
selected non-secret baseline source; it is **not a Git merge**. No `.env`, token,
certificate or credential file was copied. No dependencies were installed.

## Actual fresh checks

Environment: Node **v22.19.0** (not the contributor's v26.4.0).

| Check | Actual result |
| --- | --- |
| Combined Node backend/integration suite, four backend test files plus `test/integration/int_imp_01.test.cjs` | **110/110 PASS**, exit 0 |
| First suite attempt | 109/110: review export omitted two baseline `.ino` snapshots; ENOENT, not a candidate assertion defect. Added read-only baseline snapshots and reran; original log retained |
| `node --check` on core, Supabase adapter, monitoring helper and loopback adapter | **4/4 PASS**, exit 0 |
| Selected JSON inputs | Parsed successfully |
| Hashes of 100 incoming files after tests | Unchanged |
| PowerShell Parser.ParseFile on `Invoke-Q12PhaseA-V3.ps1`, `SourceSnapshot.psm1`, `Test-Corrections.ps1` | **3/3 syntax-only PASS**, zero parse errors; scripts NOT executed |
| Manual-result 0.2 / C02 Ajv validation | **BLOCKED**: cached Ajv found but `ajv-formats` unavailable; no installation or substitute validator |
| Fresh Flutter analyzer/tests, Android or Deno/Edge build | **NOT RUN** in this review |
| Actual Supabase Auth/RLS/RPC/persistence, Q12 native/SQL/remote execution, hardware | **NOT RUN** |

The Node invocation included a separate review preload that blocks external
`fetch`; actual HTTP was restricted to loopback. Credential-related environment
variables were omitted from the test process. Upstream Supabase ports were
injected stubs. Temporary JSON ledgers are mock host storage, not Android crash
durability or PostgreSQL transaction evidence.

Commands, TAP stdout/stderr, availability diagnostics, checks and pin manifest
are retained in the review directory and the accompanying `pr59-61-evidence/`.
Preparation helper: `../2026-11-04/prepare_pr_review.py` (read-only network
retrieval; creates a new temporary directory each run).

## Integration findings and merge gates

1. **No added-path collisions** against the pinned development tree or between
   the three PRs. This is static composition evidence, not a successful Git merge.
2. **GitHub state remains unresolved:** all three are drafts; #59/#60 reported
   unknown mergeability; #61 reported `mergeable:false` / `dirty`. Shared ancestry
   and disjoint additions do not explain that hosted discrepancy. Do not claim
   it has been resolved. Hosted checks showed only Supabase Preview, skipped;
   no completed green Flutter CI was observed.
3. **Local guidance collision:** incoming `docs/instructions/BACKEND.md` and
   `supabase/AGENTS.md` differ from Kath's current files. Other 98 incoming paths
   were absent at exact or FILE_LOCATIONS-resolved paths. This is not proof no
   semantically related material exists elsewhere. Preserve current work.
4. **Instruction reconciliation is needed:** incoming BACKEND lines 81–84 and
   148–155 still describe installation/session gates and Mary as owner. Preserve
   candidate implementation history, but qualify it against approved Q07 0.2
   account-based planning and Kath's explicit responsibility acceptance. Do not
   reopen those unchanged decisions or claim the old code implements them.
5. **Historical handover pending statements:** add a current receipt for Kath's
   accepted future responsibility, not a fabricated acceptance of every package,
   risk or proposed API. Preserve Cha's historical authorship/evidence.
6. **Deployment hazard:** hosted `development` workflow runs on push and can
   publish Flutter web to GitHub Pages with configured repository Supabase values.
   Merging is not operationally inert. No workflow setting was changed, secret
   inspected, or deployment authorized. Explicit prevention/authorization is needed.
7. **Backend remains disabled:** incoming Edge code keeps the source gate closed;
   RPCs/drafts are not proof of deployed persistence. The v1 handler is not the
   manual-result 0.2 implementation or Q07 account-only authorization. Keep these
   as implementation follow-ups, not reasons to invent successful integration.

The detailed unapplied reconciliation proposal is retained in the temporary
review folder. No branch or PR was changed to apply it.

## Recommendation

Do not merge yet. Resolve hosted mergeability, carry forward current ownership/
policy guidance, establish the CI result and deployment boundary, then obtain
the next explicit merge scope. A separate workflow/deployment decision and
implementation plan follow; do not activate SQL or hardware to make tests pass.

Kath's current feature branch/checkpoint and uncommitted app work are preserved.
No task statuses or portal reports were promoted to Completed by this review.

## Follow-up — current development identified, 2026-11-05

The subsequent [resolution report](PR59_61_Resolution.md) identifies actual
development head `52d3abf93a8f880cadddc0bdb1f5570e93d8dff9`, beyond the old base
reported by the PR metadata above. All 100 selected files are already present
(98 byte-identical, two line-ending-only). This explains the hosted conflicts
and supersedes the earlier unresolved-conflict assessment for the current tree.
No redundant merge was performed. Schema checks now pass using existing global
tooling; fresh Flutter results and prepared workflow/guidance patches are in the
resolution report. This earlier record remains the old-base review, not a claim
that current development lacks the handover or that the new patch is published.
