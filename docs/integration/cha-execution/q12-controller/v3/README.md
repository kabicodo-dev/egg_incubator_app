# Q12 Phase A — R1–R5 follow-up corrections (revision 3)

**2026-10-31 · LOCAL IMPLEMENTATION / VERIFICATION ONLY.**
**Readiness:** ready for independent source/evidence review, NOT remote execution.
Q12 Phase A and DB-IMP-01 remain incomplete; original task statuses are unchanged.
Real source ingestion remains disabled. No Supabase access, SQL execution, database
fixtures/users/changes, installation, deployment, commit, push, merge or Phase B.

## 1. Revision and change inventory

Everything created by this task is under
`docs/integration/cha-execution/q12-controller/v3/`. Original v1/v2 sources,
inventories, evidence and Attempt 1 records were not modified. Revision 3 uses
namespace `SmartHatch.Q12.V3`; it does not silently relabel older test results.

| File (all new in v3) | Exact code range / changes |
|---|---|
| `ModelPolicy.cs` | 1–306: copied v2 with new namespace; R1 at 81, R2 at 203–211/236–239/270, R4 at 110–129/271, procedure handling at 78/112/277–293 |
| `DurableController.cs` | 1–244: copied v2 with new namespace; context/source/run-mode changes at 12–26; attributed mirrored preflight at 77–96; server version at 109; mirrored rollback/close at 133–166; updated export guard at 171–215 |
| `NativeBoundary.cs` | 1–231: v2 transport retained, namespace changed only; existing one-connection/TLS/timeouts/no-reconnect behavior unchanged |
| `Correction.Tests.cs` | 1–390: retained 156 regression cases, new namespace/context/run ID, before-start hook, emergency mirror expectations adapted |
| `Followup.Tests.cs` | 1–202: independent PG17 fixtures/reference checks, R1/R2/R3/R4 and procedure regressions |
| `SourceSnapshot.psm1` | 1–107: new locked/hash-verified source capture, snapshot-string compilation, exact compiler-file receipts and cleanup |
| `Invoke-Q12PhaseA-V3.ps1` | 1–73: new default-deny launcher, snapshot compilation before credentials, context/emergency attribution; existing certificate and target gates retained |
| `Test-Corrections.ps1` | 1–116: new snapshot-based runner, 211 categorized tests, independent references and compiler receipts |
| `CERTIFICATE_PROVENANCE.md` | Byte-identical copy of v2 procedure. Actual trusted origin remains BLOCKED / NOT VERIFIED |
| This `README.md` | Follow-up closure matrix and verification report |
| `Write-ReviewInventory.ps1`, `review-inventory.json` | Local create-new inventory, final inputs/compiler receipt verification and v2 preservation check |

Each `local-verification-*` directory retains its exact test JSON, source/compiler
artifacts, synthetic examples, filesystem fixtures and emergency recovery evidence.
`review-inventory.json` enumerates every individual file/hash/size, excluding itself
to avoid recursive hashing. Compiler artifacts contain source/test constants, not
entered credentials or live database results; their source-like contents must not
be confused with captured runtime evidence.

## 2. R1–R5 and additional-schema closure matrix

All references below are inside v3, except the installed PostgreSQL references.
Statuses mean **local correction/test closure**, not actual remote acceptance.

| Finding | Implementation | Tests / actual outcome | Status and residual limitation |
|---|---|---|---|
| **R1 — default ACL nullability** | `ModelPolicy.cs:81` declares defaclacl non-null, OID 1034; generic validation at 102 rejects NULL before export. Nullable nspacl/relacl/proacl remain unchanged. | Independent literal 4-column fixture in `Followup.Tests.cs:41–46`; negative/positive cases at 88–91 PASS. Reference check at 72–87 confirms installed PG17 bki FORCE NOT NULL. | **RESOLVED LOCALLY.** No database query was used to establish this. |
| **R2 — full constraint identity** | `ModelPolicy.cs:203–211` compares exact schema/private, intended table, exact constraint name, kind c and supported definition. Unknown identities are UNRESOLVED; recognized but mismatched identities are DIFFERENT. `236–239` counts tuple identities, so duplicate/ambiguous rows never MATCH. | `Followup.Tests.cs:108–139`: **18/18** cases PASS for three exact comparators, wrong relation/schema/kind/definition, cross-registry placement, unknown name, duplicate identity and same name in two schemas. | **RESOLVED LOCALLY.** Comparators still cover only the three declared disabled-registry constraints; no blanket constraint/security acceptance. |
| **R3 — emergency attribution** | `DurableController.cs:77–96` writes and flushes the full manifest to BOTH destinations before Connect. It includes run ID, approval reference, exact target, SQL and eight source fingerprints, versions, certificate fingerprints and explicit executionMode. Both destinations also receive terminal outcomes at 155–164. Later failures append a correction; use the last terminal event for that run ID. | `Followup.Tests.cs:157–200`: **3/3** file-based/rejection cases PASS. Before-start hook reads the flushed emergency preflight. Primary is faulted, preserved under another name, and excluded from recovery assertions. Emergency alone proves correlation/source hashes/rollback/idle/close. | **RESOLVED LOCALLY.** Emergency and primary share a storage device; hardware/total storage failure, crash and missing terminal records still cannot be called success. |
| **R4 — server version** | `ModelPolicy.cs:115–128` validates the entire version string and returns only major.minor. Settings SELECT is checked at 111; normalized value is retained in catalog evidence at 271 and `Summary.ServerVersion` at `DurableController.cs:109`. No libpq substitution. | `Followup.Tests.cs:140–156`: **18/18** cases PASS: numeric and supported package formats; NULL/empty/overlong/malformed/injected/suffix forms stop before catalog queries, preserve no raw text. | **RESOLVED LOCALLY.** Unknown version formats stop for review. Supported package suffix text is discarded; a numeric version is an observation, not compatibility certification. |
| **R5 — compilation identity** | `SourceSnapshot.psm1:12–54` opens original inputs under read-sharing locks, hashes bytes and validates UTF-8 round trip. `57–98` compiles captured strings, not mutable original paths; verifies snapshots again and records exact compiler-generated file and decoded-text hashes. Launcher at 9–13/23–24 uses snapshot fingerprints; locks stay held through the run. | `Test-Corrections.ps1:26–76`: **5/5** actual filesystem/compiler cases PASS: five input receipts; blocked write; physical modification after deliberately breaking the lock rejected before compiler; in-memory tampering rejected; uncaptured unit rejected. | **RESOLVED LOCALLY for C# compilation inputs.** PowerShell/module bootstrap, CodeDom/compiler, OS and same-process integrity remain trusted. This is not code signing or a defense against a compromised host. |
| **Procedure NULL result** | `ModelPolicy.cs:78` permits NULL only in result_type; 112 still rejects non-null empty return types. At 277–293, NULL is SQL_NULL_RETURN_TYPE_UNCLASSIFIED / UNRESOLVED; no approved function-argument/owner/config MATCH is inferred. No SQL/prokind column was added. | Independent 9-column fixture at `Followup.Tests.cs:47–52`, cases 92–107 PASS: legitimate NULL shape, unrelated NULLs, wrong OID/order and blank return text. **10/10 independent schema cases** including R1 pass. | **RESOLVED LOCALLY with explicit uncertainty.** Approved SQL does not select prokind; NULL alone cannot prove that the row is a procedure or an approved function. |

## 3. Actual tests and retained evidence

From repository root:

```powershell
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File docs/integration/cha-execution/q12-controller/v3/Test-Corrections.ps1
```

**Final run: 211 tests, 211 passed, 0 failed.**
[Final test-results.json](local-verification-fdf7956c5ace4af7bd47605d80d44f9d/test-results.json)
contains all cases, eight source fingerprints, five compiler-input receipts,
independent reference hashes/excerpts and explicit NOT RUN remote behaviors.

| Category | Passed |
|---|---:|
| Retained/adapted v2 regression cases | 156/156 |
| Independent PG17 reference check | 1/1 |
| Independent schema cases | 10/10 |
| Full constraint identity | 18/18 |
| Server-version handling | 18/18 |
| Emergency-only file recovery | 3/3 |
| Source snapshot/filesystem/compiler | 5/5 |
| **Total** | **211/211** |

The 156 retained cases include 39 native-API substitutes, three actual local-native
memory-only libpq probes, 74 earlier shape cases and other controller/policy/I/O
tests. New independent fixtures do not read their column/OID/nullability expectations
from Shapes. Earlier self-derived fixtures remain regression tests, not independent
proof of all live PostgreSQL result schemas.

Actual local-native coverage is still PQlibVersion and synthetic in-memory PGresult
operations only. It opens no PGconn/socket and runs no SQL. CLR 4.0.30319.42000,
PowerShell 5.1.26100.9711, installed libpq 170011 (17.11).

### Earlier attempts preserved

- `local-verification-3892609edcbf4448ad25a1f28eb99fe8`: 205/206. The new concurrent
  emergency reader used incompatible Windows file-sharing flags; the controller
  safely stopped before the fake native connection. This is not a remote failure.
- `local-verification-c3bfebc1a48c47c6bc26bdcc2cd93ca6`: 206/206 after reader correction.
- `local-verification-d4164e06880e4ef5acc1bc83ef374ce8`: 207/207, adding exact compiler
  input receipts and real tested-source hashes in recovery evidence.
- `local-verification-bebd27bce9604f5788913b8b6278d28f`: 211/211 expanded negatives.
- Final `local-verification-fdf7956c5ace4af7bd47605d80d44f9d`: 211/211 after comment
  clarification; its source fingerprints are the current review candidate.

Do not add overlapping runs' counts. Historical hashes intentionally identify
their earlier source revisions, not current files.

## 4. Independent schema-reference verification

Actual installed PostgreSQL 17 references were read as immutable byte snapshots,
hashed, and checked without SQL or network access:

- `C:\Program Files\PostgreSQL\17\share\postgres.bki`, line **11329**:
  `defaclacl = _aclitem FORCE NOT NULL`.
  SHA-256 `3a4c07f17eb30d4ce2046efee9998b0abb30f777fd7bde1ee8ddbf93a4cea892`.
- `C:\Program Files\PostgreSQL\17\doc\src\sgml\html\functions-info.html`, line **967**:
  pg_get_function_result returns NULL for a procedure.
  SHA-256 `3e57c206a85baeee74c89884def89c8a1dd18340bbb3ea1eed077ed8d63efe08`.
- Bki type definitions also independently confirm name=19, text=25, char=18,
  aclitem[]=1034 and text[]=1009 used by the affected fixtures.

The approved function-metadata SELECT uses pg_proc and name filters but no prokind
filter. A matching procedure therefore can legitimately appear. Because kind is
not selected, the controller accepts the nullable field with explicit uncertainty,
not a fabricated function/procedure determination. All other shape guards remain.
Installed references are not observations of the Supabase project's server version.

## 5. Emergency-only attribution proof

Read only this final run's file:

`local-verification-fdf7956c5ace4af7bd47605d80d44f9d/synthetic-emergency-only-recovery/emergency.jsonl`

It includes:

- Preflight with actual test run ID `fdf7956c5ace4af7bd47605d80d44f9d`, exact pinned
  target/SQL and **eight actual current source fingerprints**.
- `executionMode: LOCAL_SYNTHETIC`, synthetic approval reference and certificate
  placeholders. These are NOT real owner authorization or certificate provenance.
- Explicit simulated rollback confirmation, idle state and connection closure,
  correlated by that run ID. Primary write failure remains STOPPED with
  JournalDurable=false; successful recovery does not conceal the failure.

The test renames/preserves the primary as `primary-unavailable-preserved.jsonl` and
does not use it to establish the recovery assertions. It verifies the emergency
preflight before simulated connection startup, and separately verifies mirrored
terminal records on a successful mock run. No real remote rollback is claimed.

## 6. SQL integrity and restrictions

Approved SQL SHA-256 is still:

`9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc`.

The original file was not edited. Seventeen unchanged statements are still split
and executed in order only in simulations here. The 10s statement, 2s lock and
60s idle SQL timeouts are unchanged. No additional SELECT, migration, prokind read,
role/policy/grant change, account, fixture or later phase was introduced.

## 7. Remaining certificate/remote blockers and limitations

- Actual trusted certificate origin remains **BLOCKED / NOT VERIFIED**. Follow
  [CERTIFICATE_PROVENANCE.md](CERTIFICATE_PROVENANCE.md): authenticated authoritative
  source, independent trusted DER fingerprint, offline identity/CA/validity checks,
  both file/DER hashes and genuine owner attestation. A local hash or matching
  filename is not trusted-origin proof. No source was contacted in this task.
- Independent review of this revision and separate explicit permission are required
  before any remote execution. No remote approval is requested here.
- Real TLS, authentication, libpq connection startup, Supavisor routing, actual
  server schemas and actual rollback remain NOT RUN.
- Semantic comparison remains deliberately partial. Unknown expressions/identities,
  ACL expansion and NULL object kind remain UNRESOLVED; no whole-task completion.
- Snapshots bind C# input bytes/text and compiler receipts, not the authenticity
  of an already-running PowerShell host or compiler. Generated compiler files may
  contain a BOM; exact file-byte and decoded-content hashes are both retained.
- The evidence destinations share local storage. Total storage loss, OS/native
  stalls and uncatchable process termination can prevent terminal records; missing
  confirmation is not proof of rollback. Use last terminal records by run ID.
- Root/certificate and source locks prevent normal concurrent file replacement;
  they do not protect a compromised OS, debugger, crash dump or malicious code
  already executing with the same user's privileges. No absolute memory-erasure
  guarantee is inferred from SecureString or mocks.

**Stop point: local implementation/testing complete; independent review pending.
Q12 Phase A and DB-IMP-01 remain incomplete. No original task marked Completed.**
