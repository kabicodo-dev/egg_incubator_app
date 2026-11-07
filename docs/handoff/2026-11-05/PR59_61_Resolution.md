# PR59–61 resolution — local fixes prepared, no remote changes

Recorded 2026-11-05. Kath requested resolving the review gates while she works
on other things. Work remained isolated: no push, commit, merge, hosted setting
change, deployment, SQL, Auth/RLS/RPC or hardware operation.

## Decisive finding: the work is already on development

The GitHub branch endpoint returned actual `development` head
**`52d3abf93a8f880cadddc0bdb1f5570e93d8dff9`**, titled
`chore: preserve Cha backend handoff, review evidence, and boundary tests`.
Its ancestry includes `2d2622e` and `035e842`. In contrast, the PR response's
`base.sha` field still reported `c7a26cf`. The first isolated review was explicitly
against that old pinned base, not the actual current branch. This follow-up
corrects the applicability of that review; do not use it as current merge readiness.

All **100 selected PR files are already present** on current development:

| PR | Byte-identical | Line-ending equivalent only | Missing / semantic differences |
| --- | --- | --- | --- |
| #59 | 62 | 1 | 0 |
| #60 | 20 | 0 | 0 |
| #61 | 16 | 1 | 0 |

No merge is needed to transfer those selected files. This does not review every
other file or certify the broader preservation commit/history. Do not import
that whole history or overwrite Kath's feature checkout.

## Conflicts explained and local resolution selected

Object-only `git merge-tree --write-tree --merge-base=c7a26cf...` analysis in a
separate bare object repository confirmed:

- All three heads compose without conflicts against the old base.
- Against actual `52d3abf...`, #60 composes cleanly; #59/#61 have add/add conflicts.
- #59: `docs/integration/cha-execution/received-ally-c02-20261102.txt`.
- #61: `docs/integration/cha-execution/q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/test-results.json`.

Both conflicts are CRLF/LF-only; content matches after **only** CRLF-to-LF
comparison. Resolution: retain current development bytes and preserve the
incoming originals separately with their raw SHA-256 values. Do not rewrite
historical fingerprints or fabricate another test run. Both variants are saved
in the evidence folder. No Git branch was merged or changed by merge-tree.

Recommended hosted disposition: close the redundant draft PRs with an accurate
already-present explanation after owner approval, rather than force a redundant
merge. **No PR was closed, edited or marked ready.**

## Fixes prepared against current development

`PR59_61_Resolution.patch` changes only these maintained/documentary areas:

1. `docs/instructions/BACKEND.md`: preserve Cha's expanded safeguards but carry
   forward Kath's accepted future backend/Flutter ownership, prior contributor
   credit, and approved Q07 account-based planning. Explicitly distinguish the
   old installation/session-bound code from the selected account experience.
2. `supabase/AGENTS.md`: reconcile the maintained-guide/GLOBAL discovery pointers.
3. Add an acceptance source and additive handover receipt; historical unchecked
   package/risk forms are not silently checked off.
4. `.github/workflows/ci.yml`: retain PR and development-push CI; analyze all
   production Dart and Flutter tests with `flutter analyze --no-pub lib test`,
   then `flutter test --no-pub`.
5. `.github/workflows/deploy.yml`: preserve current build/deploy contents and
   quality gates, but remove automatic push publication; retain explicit manual
   workflow dispatch and the same app/test analysis scope.

These are **sandbox/patch changes only**. Current hosted workflows still have
their old triggers. Do not publish to development before separately authorizing
and reviewing the workflow guard. Never assume a local patch disables GitHub.
The patch does not contain app code, dependencies/lockfile changes, migrations,
evidence-byte replacements, credentials or backend activation.

## Fresh validation

| Check | Result / boundary |
| --- | --- |
| `flutter pub get --offline` in the sandbox | Exit 0 using cached packages; SDK constraints adjusted four sandbox lockfile entries. This lockfile is NOT included in the patch. The helper's console print then hit a Windows Unicode encoding error; pub's saved result was exit 0 |
| `flutter analyze --no-pub` on selected-file sandbox before adding historical Dart scripts | PASS, exit 0 |
| `flutter test --no-pub test/int_imp_01_parser_compatibility_test.dart --reporter expanded` | **5/5 PASS** |
| `flutter test --no-pub --reporter expanded` | **192/192 PASS** on development-baseline app/tests plus incoming parser checks; NOT a rerun of Kath's separate uncommitted UI refactor |
| Fresh combined backend/integration suite | **110/110 PASS**, Node v22.19.0, external fetch blocked; upstream ports are mocks |
| Manual-result 0.2 exact schema/reference suite | **27/27 PASS**, Ajv 8.17.1 / ajv-formats 2.1.1 already present in global expo-cli dependencies; no installation |
| C02 validator | PASS: 14 examples, 65 negatives, 11 malformed/unsafe cases, 20 incompatible-frame isolation checks; protected inputs unchanged |
| Direct SDK `dart analyze --format=machine lib test` | Exit 0, no findings |
| Direct SDK analysis including current development's two archived Dart review scripts | Ten informational lints, confined to those scripts: two undeclared direct crypto imports and eight prints. Exit 0 for Dart's non-fatal-info default; NOT a clean whole-tree result |
| Extra Flutter-wrapper analyzer reruns after importing archival scripts | Timed out; NOT claimed PASS. Did not terminate or modify others' Flutter processes |
| Proposed workflow YAML and trigger/assertion checks | PASS using existing YAML tooling; CI remains PR/push enabled, Pages manual only, app/test quality checks retained |
| Remote CI rerun, Edge/Android/native/Q12/real database/hardware tests | NOT RUN |

Current development's hosted CI run
[41772105295](https://github.com/kabicodo-dev/egg_incubator_app/actions/runs/41772105295)
and Pages run
[41772105470](https://github.com/kabicodo-dev/egg_incubator_app/actions/runs/41772105470)
both failed at the Flutter analysis step. The archived review-script lints are
consistent with this failure; raw hosted analyzer logs were not independently
retrieved. No green hosted result is claimed from local checks. Their old failed
conclusions will not change until a separately authorized updated run occurs.

## Publication boundary and next step

The local guidance, schema-tooling and conflict-diagnosis issues are addressed.
The prepared patch needs a **new, separately authorized publication/review**;
merging the three old drafts is unnecessary for content delivery. Hosted CI and
manual-only publication protection cannot become effective without that remote
change. No automatic commit, push, merge, close, dispatch or deployment occurs.

The existing feature checkout remains on `feature/kath-k03a-species-details` /
`dc837441cab7e1782ecc80a06e7c1d580be434a1`; its app changes are not overwritten.
Running-batch protections remain. No portal task completion is inferred.
