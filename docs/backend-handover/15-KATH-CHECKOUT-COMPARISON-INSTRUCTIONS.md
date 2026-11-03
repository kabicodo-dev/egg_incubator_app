# 15 — Kath's read-only checkout comparison

**No copying, patches, staging, commits, merge, fetch/pull/push, dependencies, servers, tests, SQL, provider or hardware access.** This procedure only reads local Git metadata and the exact non-secret files in [14](14-MINIMUM-REQUIRED-TRANSFER-SET.md). Kath's acceptance remains pending.

## 1. Identify your own baseline

Run from Kath's intended local checkout; do not switch branches to make IDs match:

```powershell
$env:GIT_OPTIONAL_LOCKS = '0'
git -c core.optionalLocks=false rev-parse --show-toplevel
git -c core.optionalLocks=false branch --show-current
git -c core.optionalLocks=false rev-parse HEAD
git -c core.optionalLocks=false status --porcelain=v1 --untracked-files=all
git -c core.optionalLocks=false diff --name-status
git -c core.optionalLocks=false diff --cached --name-status
git -c core.optionalLocks=false ls-files --unmerged
```

Changing `GIT_OPTIONAL_LOCKS` affects only this shell process environment; it edits no repository configuration. Source baseline: `cha-branch2` / `2d2622e6b1b0c538dda3c3023e97ae467eaf53b6`. Different branch/HEAD alone is **not** evidence of incompatible or absent file contents. No source/Kath checkout equivalence is assumed.

## 2. Compare each exact path

Use one path at a time from document 14's selected-file inventory, replacing the sample below. Do not use directory-wide copying or inspect credentials/configuration files.

```powershell
$p = 'supabase/functions/_shared/bridge-sync-core.mjs'
Test-Path -LiteralPath $p -PathType Leaf
if (Test-Path -LiteralPath $p -PathType Leaf) {
    Get-FileHash -LiteralPath $p -Algorithm SHA256
    git -c core.optionalLocks=false ls-files --error-unmatch -- $p
    git -c core.optionalLocks=false status --porcelain=v1 --untracked-files=all -- $p
    git -c core.optionalLocks=false diff --name-status -- $p
    git -c core.optionalLocks=false diff --cached --name-status -- $p
    git -c core.optionalLocks=false log -1 --format='%H %an %s' HEAD -- $p
}
```

`ls-files --error-unmatch` nonzero means not tracked by this local index, not missing on disk. Empty status for an existing file can mean tracked/clean or ignored; use the path/track checks together. For ignored ambiguity, `git -c core.optionalLocks=false check-ignore -- $p` is read-only. Do not force-add anything.

## 3. Classify without changing files

| Finding | Meaning / next action |
|---|---|
| Present + same SHA-256 | Identical bytes; record no content transfer needed even if HEAD differs |
| Present + different SHA-256 | Record mismatch and both Git states; review scoped textual differences later, not automatic replacement |
| Source untracked, Kath tracked | Potentially already incorporated or independently changed; compare bytes/history, not status alone |
| Kath modified/staged/unmerged at same path | Overlap blocker: preserve her work; agree reconciliation separately |
| Absent by Kath's own path check | Missing in that checkout at that observation time only; propose exact missing file for later authorized handling |
| Unavailable/permission denied | Record unavailable; do not label absent or change permissions |
| Matching historical source but different current contract | Record semantic/version issue; no silent API/outbox/actor conversion |

For a tracked non-secret mismatch, Kath may read her own local difference using `git -c core.optionalLocks=false diff -- $p` and `git -c core.optionalLocks=false diff --cached -- $p`. Do not print unrelated files or historic secret blobs. A direct source-versus-Kath content comparison requires both versions to be legitimately available; this phase does not authorize obtaining/copying them.

## 4. Return evidence, not acceptance

Report checkout/branch/full HEAD and, for each selected path: presence, raw SHA-256, tracked/untracked/ignored state, unstaged/staged/unmerged flags, last-touch commit, match/mismatch/unavailable and potential overlap. Use console output/manual notes outside repository changes; no report file creation is required by this procedure. Do not disclose credentials, private rows, email tokens or certificates.

Only after both inventories exist can owners agree a minimal missing/differing subset and separate authorization for later action. No blanket copy, PR, merge or technical acceptance is recommended. Q07 design approval and backend handover acceptance are separate; see [16](16-P1-P6-APPROVAL-ATTRIBUTION-CLARIFICATION.md).
