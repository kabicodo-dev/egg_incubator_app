# Kath — manual-result 0.2 delta review

2026-10-31. To Cha/Mary (one person). **Scoped review ACCEPT findings below; no formal adoption, enablement or task completion.** No architecture or unchanged-field review repeated. M08 is already approved; no renewed approval requested.

## Exact inputs

All **17 manifest entries** match SHA-256 and size. All **four preserved 0.1 parent fingerprints** match. The old delivered Dart evidence script still hashes to `bcb7ab832eabd97092e6d22a983910cd4e32288e5777f3cd79adbbd1ee57b45e`.

| Input | SHA-256 |
|---|---|
| SmartHatch_Manual_Result_0.2_Review.zip | `983be83c12aa3550c69e8f17bd0a5642b1a92e5ea9d667368c6b0e2a75ad6772` |
| Input manifest.json | `cbdcfdda10b266432d3b8abed2dcb4ca0bebdbfdefe34990f8fb8849f9c5426d` |
| DB-02_Manual_Result_API_0.2-review.md | `304da072775686906e67ea77ce635794273869f8ba3d933dcae80bf3fcdeabd6` |
| manual-result-0.2-review/schema.json | `b2d739271a2a575536c6db8c18504477eac951f63bfb88828bdf0f1db42cc7c4` |
| manual-result-0.2-review/fixtures.json | `5ec00ee6b891e6c21cb5c3a378fca9fa6ea1c06d60e4d6c1b36a07b036bf2afa` |
| manual-result-0.2-review/reference.cjs | `032f070b7e584729436a311aea4a8cd9d2223650d40e8f907698056c0763c209` |
| manual-result-0.2.test.cjs | `6548f2c7dd291c816c7654bd73bde404ee9c75c0fda48563c97f2b97e0126139` |

`inputs.stdout.txt` records every manifest path/hash/size, including both READMEs and preserved parents. It is a new captured verification log.

## Focused dispositions

Command labels D, V and N refer to the exact commands below.

| Section/field | ACCEPT / CHANGE / BLOCKED | Exact finding/replacement | Actual command/result | Remaining implementation/test |
|---|---|---|---|---|
| Manifest / preserved parents | ACCEPT | 17/17 entries verified; four pinned 0.1 parents unchanged. Old evidence script hash preserved. | V: exit 0; captured inputs.stdout.txt | Preserve historical evidence and version pins. |
| Discriminator / new canonical core | ACCEPT | Keep api_version:2 with exact DB02-MANUAL-RESULT-0.2-review. Contract remains in hashed core; old discriminator is rejected, never relabeled. No replacement needed. | D: both canonical strings, lengths and hashes match; old-contract lookup/error/nested negatives reject. | Implement exact version pinning; no automatic outbox conversion or fallback. |
| Closed shape then outstanding/original/outer/nested tuple | ACCEPT | Closed response variants plus separate four-field comparisons address the prior gap. Schema shape alone cannot establish equality. found:false requires receipt:null and does not authorize retry. | D: found/absent positives; all four fields mutated independently in outstanding, original, found outer, absent outer and nested positions reject; tested missing/extra/type contradictions reject. | Actual endpoint association, bounded UTF-8/duplicate-key parser, runtime guards and atomic outbox transition. |
| Expected receipt and continuity | ACCEPT | Compare original content/manifest/count, quantity/session mapping, revision/outcome/fixed effects/null acknowledgment. Prior receipt_id and first received_at cannot change. | D: expected-field mutations reject; unchanged prior receipt accepts; changed valid receipt UUID/time reject; string bigint max accepts and overflow rejects. | Trusted mapping/manifest and durable immutable receipt/readback across restart/concurrency. |
| Error retryability / commit state | ACCEPT | Exactly SERVICE_UNAVAILABLE and COMMIT_UNKNOWN require retryable:true. Only COMMIT_UNKNOWN permits unknown; others require not_persisted. Unknown commit requires original-identity reconciliation, not a blind resubmit. | D: all 13 valid codes accept; inverted retry and commit flags reject for each. | Actual transport/status/auth handling and authorized recovery scheduling; no new identity or physical retry. |
| Malformed / unknown response | ACCEPT | Reject without granting retry or claiming persisted/not-persisted. Preserve evidence for approved recovery. No replacement needed. | D: unknown code, missing/extra fields, wrong types, bad UUID/version/contract and contradictions reject. Guard rejection exposes no recovery authorization. | Actual raw malformed/duplicate-key/invalid-UTF-8/oversize transport tests and UI/outbox recovery behavior NOT RUN. |
| Fixture alternatives / M08 | ACCEPT | The two vectors have the same action identity but different content: independent alternatives only; sequential changed content must conflict. M08 reservation/reuse is already approved. | D: identity/content/scenario metadata and fixture reservation correspondence checks pass. | Backend conflict/concurrency test and actual first-durable-draft/seal/restart transaction tests NOT RUN. |
| Supplied Ajv schema/reference suite | BLOCKED | Local module resolution fails for ajv/dist/2020. No dependency installed. Supplied 27-test TAP is attributed package evidence only, not locally reproduced. | N: exit 1 before suite cases execute; MODULE_NOT_FOUND in node.stdout.txt. | Run exact suite when authorized existing Ajv8/ajv-formats tooling is available. |

No additional candidate text replacement is requested by this delta review. ACCEPT refers to the reviewed contract rule/model evidence, not a production implementation claim.

## New Dart vectors

Both **full canonical strings** are printed in `dart.stdout.txt`, not reconstructed from the old evidence.

| Independent scenario | UTF-8 bytes | SHA-256 |
|---|---:|---|
| unknown_time_zero | 422 | `799cb58d64b2db57c950eefb8c16ddbc8fd88cd75252ffe1693ed121ecc8b078` |
| phone_time_upper | 445 | `9ac45d31b8981342f8c13b2d4d9334e1d3f22cca2ff25086399e065ce326356c` |

## Actual commands and log provenance

Run from `C:\egg_incubator_app`. Variables below abbreviate actual absolute paths, not different inputs:

```powershell
$e = 'C:\egg_incubator_app\docs\review-evidence\manual-result-02-2026-10-31'
$r = 'C:\Users\ACER\AppData\Local\Temp\opencode\manual-result-02-review-20261031'

# V: exit 0; 17 manifest entries / four parents / old Dart script hash verified
powershell -NoProfile -ExecutionPolicy Bypass -File "$e\verify_inputs.ps1"

# D: exit 0; REVIEW-ONLY PASS checks=106 vectors=2
dart --packages=C:\egg_incubator_app\.dart_tool\package_config.json "$e\dart_manual_result_02_review.dart" "$r\docs\contract-review\manual-result-0.2-review\fixtures.json"

# N: exit 1; missing ajv/dist/2020, no candidate suite pass claimed
node --test "$r\docs\integration\cha-execution\manual-result-0.2.test.cjs"

# Toolchain: exit 0; Dart SDK 3.13.3 stable, windows_x64
dart --version
```

Each retained stdout/stderr pair was **newly captured directly during execution**, using PowerShell `Start-Process -RedirectStandardOutput ... -RedirectStandardError ... -NoNewWindow -Wait -PassThru` with the above command arguments. The names are `inputs.*.txt`, `dart.*.txt`, `node.*.txt` and `dart-version.*.txt`. Empty stderr files are intentional. These are not exports of earlier console text. The initial Node availability attempt and the retained captured attempt both failed for the same missing module. Input verification was recaptured after correcting only the verification script's displayed parent-count expression; the delivered final log reports four parents.

The new independent Dart script uses already cached package:crypto via existing package_config.json; it does not import the supplied reference or install anything. It models the relevant closed shapes and guards on parsed objects, not a complete JSON Schema validator or general JCS implementation. Its canonicalizer is restricted to this validated ASCII/string/null/integer core. Scenario/M08 assertions check fixture correspondence, not persisted transactions. No raw duplicate-key/UTF-8 parser or storage/state machine was exercised.

**All implementation acceptance remains NOT RUN.** No application/firmware edits, dependency installs, accounts/database/RLS/RPC operations, deployment, formal adoption, flashing or powered tests. Result-only boundaries remain unchanged: no Stop prerequisite, automatic Completed/end_date change, Active-guard release, physical command or retained-evidence release. No old 0.1 files/evidence were overwritten and no outbox record was migrated. No whole task was marked Completed.
