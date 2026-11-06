# 17 — Draft PR safety, comparison and attribution record

Recorded 2026-11-04 for the separately authorized draft handover PRs targeting
`development`. This supplements historical inventories; it does not rewrite their
dated observations or constitute handover acceptance.

## Automation gate

Owner-observed findings supplied in the conversation (not independently inspected
through the assistant's account):

- Repository: `kabicodo-dev/egg_incubator_app`.
- Repository Webhooks page: no webhooks listed.
- Installed GitHub Apps page: only Supabase and ChatGPT Codex Connector.
- First connected Supabase project: production deployment enabled for `main`;
  automatic PR preview branching disabled/unavailable on the Free plan.
- `smarthatch-test`: repository connected, deployment OFF, automatic PR preview
  branching disabled/unavailable.
- Both connected Supabase projects checked by the owner. No settings changed.

The completed GitHub Actions inspection found the hosted `main` and `development`
deployment workflow triggers only on push to `development` or manual dispatch,
not on dedicated handover-branch pushes or PR creation. The local CI workflow is
analysis/tests, not deployment; workflow changes are excluded from these PRs.

The assistant's API permission failures are not evidence of an unresolved
integration after the owner's observations. No specific Codex deployment or
database automation has been identified; no additional Codex setting confirmation
is requested. This is scoped operational-risk clearance for handover branches and
draft PR creation, not a universal guarantee about future automation or permission
to push to `main`/`development`, merge, deploy or execute SQL.

## Kath's read-only comparison — owner supplied

- Checkout: `C:\egg_incubator_app`.
- Branch: `feature/kath-k03a-species-details`.
- HEAD: `dc837441cab7e1782ecc80a06e7c1d580be434a1`.
- 78 entries: 5 identical, 5 different, 68 absent at their listed paths.
- Relocated copies are not yet reconciled. No comparison report file was created.

The five differing paths are explicitly excluded from handover replacement:

| Path | Owner-reported state / review requirement |
| --- | --- |
| `supabase/migrations/20261012090000_incubator_sessions_single_active.sql` | Tracked/clean in Kath's checkout; different raw hash; preserve existing migration history and compare bytes before proposing any change. |
| `lib/services/supabase_service.dart` | Local modifications in Kath's checkout; preserve. |
| `test/session_ownership_audit_test.dart` | Local modifications in Kath's checkout; preserve. |
| `test/one_active_batch_test.dart` | Local modifications in Kath's checkout; preserve. |
| `pubspec.lock` | Tracked/clean in Kath's checkout; different raw hash; no dependency-resolution or replacement proposed. |

Raw-hash differences alone establish neither functional conflicts nor a preferred
version. Absence at a listed path is not proof no relocated implementation exists.
Review these drafts alongside Kath's actual working changes; do not overlay an
entire checkout or treat this record as content reconciliation.

## Publication boundaries and provenance

- Three separate draft PR scopes: documentation/contracts, backend source/tests,
  and Q12 material. None is ready-to-merge or operational authorization.
- New branches must start at hosted `development`, not the local backup commit.
  Select exact files; do not cherry-pick/push the preservation history wholesale.
- `035e8425af7b880c0351f672a875a5f689062d65` and
  `2d2622e6b1b0c538dda3c3023e97ae467eaf53b6` remain source provenance only.
  Historical `.env` handling in the backup lineage precludes wholesale transfer.
- Preserve Cha/Mary's recorded backend contributions, Kath's supplied reviews and
  Flutter contributions, and Ally's supplied firmware/hardware contributions.
  A preservation/import commit is not a sole-authorship claim. Assistant-assisted
  work and local-only documentary ownership retain the qualifications in document 09.
- No workflow edits, secrets/credentials/certificates, CLI metadata, archives,
  generated portal exports, duplicate package copies, old Q12 implementations or
  overlapping compiler/run duplicates belong in the selected changes.
- Q12 is retained for review only. No controller launcher, SQL, remote retry,
  provisioning or Supabase setting change is authorized. Historical synthetic
  evidence is not fresh remote verification or actual rollback evidence.
- Backend source remains a disabled candidate, not implemented account-only Q07
  security or deployed persistence. Cross-PR dependencies must be reviewed together.

The existing source checkout and Kath's separate checkout must remain untouched
apart from this new documentary record; publication uses isolated worktrees.

## Selected publication and fresh local validation

All three branches start independently at hosted `development` commit
`c7a26cfcaa619708aff4f793e8068ee176a6cf58`. Every selected destination path is an
addition relative to that baseline, not a replacement of an existing file.

- Documentation/contracts: 63 paths, including this package, current policies,
  exact manual-result parent inputs, reference/schema checks, attributable receipts
  and maintained backend guidance. Historical candidate documents remain historical.
- Backend source/tests: 20 paths, including disabled handler/adapters, offline SQL
  drafts outside migrations, mock/loopback tests and their exact fixtures.
- Q12: 17 paths, limited to v3 source/tests, pinned SQL as reference material,
  latest scoped status/provenance/review records and one historical test-results
  record. Old implementations, overlapping runs and compiler duplicates are excluded.

The backend mock kit reads the exact DB-02 API document in the documentation PR;
the C02 validator reads fixtures in the backend PR. These independent drafts must
be reviewed together. Q12's design comparators refer to drafts in the backend PR.
This is not a self-contained Q12 native reproduction bundle: external native/PG17
prerequisites and supplemental raw evidence are not included or newly verified.
Existing firmware, app dependency files and migrations remain baseline references,
not replacement candidates; no missing-path inference from Kath's comparison is
used to transplant relocated work.

Fresh checks ran in a fourth isolated worktree containing the selected files from
all three scopes, without a Git merge, on Node `v26.4.0`:

- Backend/integration boundary suite: **110/110 passed**; in-memory stubs, loopback
  HTTP and temporary host files only.
- Manual-result 0.2 schema/reference suite with already available Ajv tooling:
  **27/27 passed**, including four immutable parent-byte fingerprints.
- C02 documentation validator: 14 positive examples, 65 negative mutations,
  11 malformed/unsafe cases and 20 incompatible literal-frame isolation checks
  passed; protected inputs unchanged.
- Three backend JavaScript syntax checks passed.
- Three Q12 PowerShell files parsed with zero syntax errors. No Q12 script,
  native controller, SQL or database operation was executed for this publication.
- Selected files passed targeted secret-pattern scanning with no findings. The
  unpublished backup's removed `.env` diff contained a JWT-shaped credential;
  no value is reproduced. That commit and its unpublished descendant are not
  ancestors of the handover branches. This does not clean or certify common
  pre-existing remote history; baseline `.env`/history is not modified here.

These checks do not establish Flutter/Edge build compatibility, real Auth/RLS,
account-only Q07 authorization, persistence, hardware behavior, trusted certificate
provenance or actual rollback. Targeted scanning is not a guarantee of detecting
every possible secret. Historic evidence is retained with its original attribution
and scope; fresh validation does not replace a named human review or acceptance.
