# Q12 Phase A — F1–F7 local correction report / revision 2

**Date:** 2026-10-31. **Scope:** local implementation and verification only.
**Verdict:** READY FOR INDEPENDENT SOURCE/LOCAL-EVIDENCE REVIEW.
**Remote readiness:** BLOCKED — actual certificate provenance remains unverified;
no new remote approval exists, and real TLS/pooler/Auth/rollback remain NOT RUN.
Q12 Phase A and DB-IMP-01 remain incomplete; original task statuses are unchanged.

This is a separate revision, not an overwrite of the reviewed 52-case candidate.
The parent directory's original source, launcher, tests, README and historical
46/52-case evidence remain byte-preserved. Their limitations remain historical;
they must not be mistaken for this correction candidate or used for remote retry.
No application/Flutter/firmware/integration files, SQL, drafts, credentials,
database objects, dependencies or source-ingestion settings were changed.

## 1. Complete change inventory

All new files are inside `docs/integration/cha-execution/q12-controller/v2/`.
No existing repository file was modified by this correction task.

| New file | Purpose |
|---|---|
| `ModelPolicy.cs` (lines 1–273) | SQL pin/splitter, exact target, all result schemas, PostgreSQL-array parser and narrow catalog export/comparison policy |
| `NativeBoundary.cs` (lines 1–231) | Scalar `IPq` boundary, testable transport, actual native shim, no-connection native probes |
| `DurableController.cs` (lines 1–229) | Provenance, incremental flushed journal, failure cleanup, export validation and certificate-attestation parser |
| `Invoke-Q12PhaseA-V2.ps1` (lines 1–81) | Default-deny future launcher with no-password arguments, locked root file, provenance gates and sanitized failure handling |
| `Correction.Tests.cs` (lines 1–389) | Categorized local tests; in-memory native substitutes, filesystem probes and actual no-connection libpq probes |
| `Test-Corrections.ps1` (lines 1–51) | Local test launcher, actual input fingerprints, syntax/default-deny checks, uniquely named evidence |
| `CERTIFICATE_PROVENANCE.md` | Separate trusted-origin/fingerprint procedure; actual status BLOCKED |
| This `README.md` | Closure matrix, results, limitations and review instructions |
| `Write-ReviewInventory.ps1` | Local-only, create-new complete file/hash inventory and original-source preservation checks |
| `review-inventory.json` | Generated exhaustive inventory (excluding itself to avoid recursive hashing) |

Preserved local correction-run directories:

- `local-verification-472ac2f34962445a95c70fecdcb680c2/` — initial **136/136**.
- `local-verification-4de01d0b0506410d9304f50123e58647/` — expanded **153/153**.
- `local-verification-2502e7780244458db0bb2647bf1b2e2c/` — expanded **154/154**.
- `local-verification-cdc2d6d37b14413889a8611c2c9e201f/` — expanded **156/156**.
- `local-verification-ee9acc30dabd49e0a5805776649865ce/` — final **156/156**,
  including wrong-table policy and wrong-overload owner comparison assertions.

Every run contains `test-results.json`, `synthetic-sanitized-example.jsonl`,
`journal-success/{journal,emergency}.jsonl`,
`serialization-failure/{journal,emergency}.jsonl` and `not-a-directory` (a harmless
local file used to force an I/O error). The last four also contain
`synthetic-root-bytes.txt` for local integrity-gate tests. These are NOT database
fixtures, actual certificates, real approval records or remote observations.
The exhaustive inventory names and hashes each file, not just these patterns.

## 2. F1–F7 closure matrix

Paths/line references below are in this `v2/` directory. Test references point to
`Correction.Tests.cs`; final case-by-case outcomes are in the 156-case JSON.

| Finding | Implementation and precise references | Local verification | Status / limitation |
|---|---|---|---|
| **F1 — catalog evidence** | `ModelPolicy.cs:143–270`: fixed non-secret design vocabulary; unknown identifiers become per-run opaque labels, not hashes. Known owners, booleans/enums/types and canonical ACL grants retained. Controlled expression/default/RLS/function-owner comparisons output MATCH/DIFFERENT; unknown expressions remain UNRESOLVED and no literal/hash is persisted. Policy comparisons bind to the intended table; function-owner comparison requires exact known argument identity. `DurableController.cs:160–200` validates export before serialization. | Tests `:261–292,335–348`: useful metadata, sensitive IDs/config/errors, quoted ACLs, NULL ACL, direct leak attempts, wrong-table/wrong-overload rejection and baseline outcomes. **11 evidence-policy cases PASS.** | **PARTIALLY RESOLVED:** useful narrow comparison implemented; arbitrary expressions, unknown identifiers, unsupported overload signatures and NULL/default ACL expansion remain unresolved. CompleteCatalogVerification is always false. Never infer full audit/adoption. |
| **F2 — native transport** | `NativeBoundary.cs:13–104`: scalar native API plus clock/root gates, real adapter polling/decoding/draining/deadlines/no reconnect. `:106–231`: actual native bindings and memory-only probes. | Tests `:174–260`: **39 native-API-substitute cases PASS** including ACTIVE/read/write polling, TLS rejection, row counts, malformed streams, SQLSTATE, deadlines, disconnect, rollback and close. `:370–378`: **3 actual local-native cases PASS**, version and empty/500/501 memory results. | **RESOLVED for the local boundary requirement.** Mock TLS is not real TLS. Actual local probes validate only listed no-connection bindings; no handshake, server or pooler tested. |
| **F3 — durable evidence** | `DurableController.cs:45–68`: create-new main/emergency files, initial writes and Flush(true) before connection; each record validated before append. `:85–157`: statement intents/results/errors, immediate cleanup rollback record, final state and emergency fallback. Launcher `:38–45,65–79`: attributable local preflight and sanitized launcher failures. | Tests `:293–324`: **7 durability cases PASS** for preflight/mid-run/final-write failures, both destinations failing, real filesystem create/read/refusal, export rejection. | **RESOLVED locally**, subject to hardware/OS durability limits. Total storage failure cannot produce guaranteed durable evidence; it explicitly reports failure, not success. Uncatchable termination remains a limitation. |
| **F4 — exact shapes** | `ModelPolicy.cs:63–111`: expected column order/count, OIDs, nullability and representations for every SELECT. 500 accepted, 501 rejected. No SQL changes. | Tests `:148–173`: **74 shape cases PASS**. `:174–183` adds four whole-controller malformed-rectangular-result failures through the native boundary. | **RESOLVED locally.** Actual target-server output OIDs/representations have not been observed; unexpected variants stop, not silently coerce. |
| **F5 — provenance** | `DurableController.cs:12–24,75–82`: approval reference, exact target, certificate/SQL/source/draft fingerprints, CLR/PowerShell/libpq versions. `:97–117`: UTC events, command status, monotonic statement duration, SQLSTATE and transaction state; `:127–154`: rollback/close. Launcher `:17–45` validates source/draft context before remote work. | Tests `:326–333` and preflight/SQLSTATE/native cases PASS; final evidence contains all six runtime/test-source fingerprints. | **RESOLVED locally.** Synthetic examples have fake proof hashes and approval references; they are explicitly not actual owner approvals or remote evidence. |
| **F6 — certificate provenance** | `CERTIFICATE_PROVENANCE.md:1–42`: authenticated authoritative origin + independent trusted DER fingerprint procedure. `DurableController.cs:204–227`: strict flat-string record; rejects missing/extra/duplicate fields and invalid/future dates. Launcher `:46–56`: locked file, file/DER fingerprint equality and validity gate. | Tests `:349–368`: synthetic valid/invalid attestation records and altered local-file rejection PASS. These are integrity/parser tests only. | **PROCEDURE/GATES IMPLEMENTED; ACTUAL PROVENANCE BLOCKED.** No Supabase access or real trusted-origin verification performed. A human attestation cannot authenticate itself. |
| **F7 — honest coverage** | All tests carry explicit categories; no preparation-Boolean test or claim that 52 mocks prove native networking. `Test-Corrections.ps1:29–51` and this report enumerate actual-native coverage and all NOT RUN remote behavior. Original v1 files retained as history, not silently relabelled. | Final JSON has **156 cases, all PASS**, with distinct categories. Syntax and actual default-deny launcher checks also PASS. | **RESOLVED for this correction revision.** No external reviewer acceptance/signature is claimed. |

## 3. Actual commands and results

Run locally, from repository root:

```powershell
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File docs/integration/cha-execution/q12-controller/v2/Test-Corrections.ps1
```

Final evidence:
[test-results.json](local-verification-ee9acc30dabd49e0a5805776649865ce/test-results.json).

| Category | Passed |
|---|---:|
| Controller logic | 9/9 |
| Result schemas/representations | 74/74 |
| Real transport logic over scalar fake native API | 39/39 |
| Evidence policy/leak rejection | 11/11 |
| Journaling/filesystem behavior | 7/7 |
| Provenance/attestation parsing | 13/13 |
| Actual libpq, no connection | 3/3 |
| **Total** | **156/156** |

Windows PowerShell **5.1.26100.9711**, CLR **4.0.30319.42000**, actual local
`PQlibVersion()` **170011** (PostgreSQL 17.11). Local-native probes call
PQmakeEmptyPGresult(NULL), PQsetResultAttrs/PQsetvalue on in-memory 500/501-row
objects, count/OID/UTF-8-cell getters and PQclear. **No PGconn, socket or SQL.**
No database fixtures/users were created. No dependency installation occurred.

The first compilation encountered an old C# compiler variable-shadowing error in
test delegates. It was corrected before the retained successful runs. Later runs
expanded coverage; do not add their overlapping case counts together. Earlier
run fingerprints describe their earlier revisions, not the final sources.

The launcher was exercised ONLY without ExecuteRemote, proving default denial
before credential/native/network work. Full launcher live behavior was not run.

## 4. SQL integrity and execution invariants

Original approved SHA-256 remains:

`9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc`.

`Pin.Sql` verifies actual bytes, requires 17 statements, and checks concatenation
is identical. Native send adds only the required protocol NUL terminator. One
statement is sent, drained, shape-checked and journalled before the next.
The 10-second statement, 2-second lock and 60-second idle SQL timeouts are untouched.
The separate 10s connect/15s client watchdogs do not alter those settings.
No retry, automatic reconnect, role creation or extra inspection SQL exists.
Only the original usable connection may receive failure cleanup ROLLBACK.

## 5. Updated evidence design and comparison boundary

- Both evidence files are opened create-new and flushed before connecting.
- Local preflight records approval reference/source fingerprints; full preflight
  records exact target, versions and SQL/certificate/draft hashes before connecting.
- Each approved statement gets an intent and sanitized outcome with UTC, duration,
  row count, SQLSTATE, validated columns, command tag and native transaction state.
- Allowlisted design identifiers remain readable; unknown names have stable aliases
  within that run only. No raw-name dictionary or hash of hidden values is written.
- ACL arrays are parsed, not split on raw commas; recognized entries retain roles,
  grantor and canonical privilege symbols. Unsupported quoted-role grammar is
  UNRESOLVED. NULL ACL is explicitly **not** equivalent to no privileges.
- Known disabled-registry constraints/defaults, owner-policy expressions, RLS flags
  and function owners can be compared to exact preserved **unapproved design**
  drafts. A MATCH is a scoped comparison, not security certification or adoption.
- Different formatting of an expression is DIFFERENT from that exact baseline,
  not automatically a semantic security failure. Arbitrary expressions/signatures,
  default ACL expansion and unknown identities remain UNRESOLVED.
- The export guard rejects raw sensitive values, unapproved column names/statuses,
  malformed timestamps, unexpected provenance fields and unknown failure codes.
- Explicit rollback tag plus idle state are distinguished from unavailable
  confirmation, and retained in the final flushed record. Primary journal failure
  attempts a separately pre-opened emergency record; both failing is STOPPED.
- JSONL is not atomic across arbitrary power/storage failures. A partial final
  line is evidence of interruption, never a successful event. Review sequence gaps
  and failures rather than discarding them as success. Journals are not signed.

## 6. Remaining prerequisites / limitations

1. Independent source/evidence review of this revision; especially allowlist,
   baseline coverage, OID assumptions, native bindings and emergency behavior.
2. Actual trusted certificate-origin/DER fingerprint verification and owner-approved
   provenance record. **Still BLOCKED.** Do not fabricate it from test examples.
3. Mary's separate explicit approval before any remote attempt. None is requested
   or inferred from this correction task. Default-deny launcher stays unused remotely.
4. Existing secure credential entry by the owner: no password argument, file, log,
   token, command echo or agent-visible secret. Native/secure memory, OS swap,
   debuggers and crash dumps are outside a provable no-leak guarantee.
5. Native libpq may buffer a result before managed cell/count limits. DNS/native
   calls or synchronous disk flush can stall outside a hard realtime guarantee;
   no interactive transaction pauses exist, but hardware stalls cannot be ruled out.
6. A full semantic catalog review may require further separately reviewed baseline
   coverage or approved local sensitive review. UNRESOLVED must remain visible.
7. Real certificate hostname rejection, authentication, server ParameterStatus,
   pooler tenant/transaction behavior and real rollback are **NOT RUN**. The actual
   local-native tests do not cover those operations.

**Stop point reached: local implementation/tests only.** No Supabase access,
remote SQL, migration, database changes, deployment, phase B, task completion,
commit, push, merge, firmware/Flutter edits or ingestion enablement.
