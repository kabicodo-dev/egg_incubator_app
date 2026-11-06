# Q12 Phase A controller — local implementation / review candidate

**2026-10-31. No remote execution performed or authorized by this implementation.**
Q12 Phase A remains incomplete. DB-IMP-01 and related original tasks are not
Completed. Attempt 1 and all previous records remain unchanged.

## Architecture and execution method

### Exact files created/modified

All new files are under `docs/integration/cha-execution/q12-controller/`:
`Q12Controller.cs`, `Q12Controller.Tests.cs`, `Invoke-Q12PhaseA.ps1`,
`Test-Q12Controller.ps1`, this `README.md`,
`local-test-8175115be7ba4e9ca1cad4a9fcec471f.json` and
`local-test-1118803c180d42a88e5491410bb69584.json`.
The existing sibling `q12-phase-a-status.json` was updated only with local
controller/review status. Historical Attempt 1 receipt, original approved SQL,
application/firmware/integration code and unrelated user work were not modified.

### Components

- `Q12Controller.cs`: bounded state machine plus Windows native libpq adapter.
  Uses existing PostgreSQL 17 `libpq.dll` at its installed absolute path. No Node,
  Python, NuGet or application dependency installation. Windows PowerShell 5.1
  compiles it locally with `Add-Type`.
- `Invoke-Q12PhaseA.ps1`: future human-operated wrapper. Default execution is
  denied before compilation or prompting. Both the explicit `ExecuteRemote`
  switch and exact approval acknowledgement are required; these are safeguards,
  not a substitute for actual new remote approval after review. Do not run it
  remotely under the local-only implementation request.
- `Q12Controller.Tests.cs` and `Test-Q12Controller.ps1`: local fake sessions and
  guards; no sockets or native DLL load. Tests do not invoke a permitted live
  adapter. Every evidence filename is unique; prior evidence is not overwritten.

### Fixed safeguards

1. SHA-256 pins the original SQL **before connecting**:
   `9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc`.
   The narrow lexer accepts that file only, yields 17 statements, and proves
   concatenation is byte-identical. Comments, whitespace, SQL and 10s/2s/60s
   approved timeouts are unchanged. Protocol NUL termination is not a SQL edit.
2. Only `zbwntspdecngnicllwlw`, host
   `aws-0-ap-northeast-1.pooler.supabase.com`, port 5432, database `postgres`,
   username `postgres.zbwntspdecngnicllwlw` are accepted. Main/other targets fail.
   No linked CLI, role initialization, API lookup, endpoint or auth-account operation.
3. Fixed `sslmode=verify-full`, root
   `C:\Users\Mary Charlyn\Downloads\prod-ca-2021.crt`. The wrapper locks this file
   against writing/replacement while using it and records its SHA-256. The root's
   provenance is Mary's existing downloaded certificate, not independently audited.
   libpq performs chain/hostname verification; live behavior has NOT been tested.
4. Password entered locally using `Read-Host -AsSecureString` before BEGIN. No
   password argument/env var/file. Temporary UTF-8 password buffers are cleared;
   libpq necessarily retains connection/auth material internally until PQfinish.
   Inherited PG* settings are temporarily removed/restored around connection setup;
   fixed parameters prevent service/password-file/SSL-option substitution. Do not
   run concurrently with other PG environment-dependent work in that same process.
   Notices are discarded before authentication polling; raw libpq/server errors
   are never printed or copied. No tracing, debug output or transcript is enabled.
5. One connection attempt per adapter instance; no reconnect/reset API. Authentication,
   target/SSL, startup read-only and initial idle checks must pass before SQL.
   Connection identity is checked with libpq getters, not `postgres` database-name
   inference. Pooler tenant binding depends on the exact project-specific user.
6. One statement at a time: drain exactly one complete PGresult, validate it, and
   only then send the next statement. BEGIN/SET/SELECT/ROLLBACK tags and libpq
   transaction states are checked. The first approved SELECT must report role
   `postgres`, `read_only=on`, `isolation=repeatable read`. No extra SQL is added.
7. `PQntuples` counts rows, not untrusted text/footer parsing. Exactly 500 rows is
   accepted; 501 stops immediately with no later catalog SELECT. Results are also
   bounded to 64 fields and 16 KiB per cell before managed decoding. Multiple,
   missing, malformed or incomplete results fail closed.
8. Server SQL errors/statement or lock timeouts stop further inspection. A 15s
   client query deadline is additional protection, not a change to approved server
   settings. An outstanding/broken transport is declared unusable and closed,
   never reused for an unsafe ROLLBACK. Connection polling has a 10s deadline;
   OS DNS/native-call stalls are not a hard-realtime guarantee.
9. On recoverable failure, only original usable in-transaction/failed-transaction
   connection receives one cleanup `ROLLBACK;`. On success the file's unchanged
   final ROLLBACK is used. Require its server tag and `PQtransactionStatus=IDLE`.
   Tag-with-nonidle, unavailable rollback, disconnect and close failure are not
   inspection success. No independent verification SQL or later phase is run.

## Evidence policy / important functional limitation

Default evidence is aggressively sanitized: statement numbers, validated command
tags, row counts, failure codes, redacted row shapes, connection/rollback/idle/close
status, certificate and SQL hashes. **All cell values, column identifiers and raw
server messages are withheld**, because even catalog defaults, policy expressions,
object names and error text can contain credentials. No raw result file is written.
This preserves structural result evidence but **does not provide sufficient values
for a semantic schema/grant/policy review**. Do not claim the full catalog audit is
done from this output. A separately reviewed safe metadata-export policy may be
needed; this implementation does not silently enable a less-redacted mode.

Returned catalog values exist briefly in memory for validation/redaction; password
and native/internal memory wiping cannot be proven by mock tests. Crash dumps,
OS swap, debugger access and machine compromise are outside this controller's
guarantees. Protect the workstation and do not enable credential recording.

## Local verification

From repository root, in a fresh process:

```powershell
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File docs/integration/cha-execution/q12-controller/Test-Q12Controller.ps1
```

Latest actual result at preparation: **52/52 local tests passed**, plus serialized
redaction and default-deny entrypoint integration checks. See
`local-test-1118803c180d42a88e5491410bb69584.json` for case-by-case results,
input SHA-256 fingerprints and PowerShell version. Earlier 46-case run retained
in `local-test-8175115be7ba4e9ca1cad4a9fcec471f.json`.

An intermediate harness invocation stopped because Windows PowerShell treated the
expected entrypoint-denial stderr as a terminating native error. The harness was
corrected to capture that expected denial; the final run passed. This was not a
remote connection attempt, SQL failure or successful inspection.

Coverage includes unchanged-byte reconstruction, one-session success, hash/target/
TLS guards, read-only/isolation/role failures, 500/501 for all 11 catalog queries,
SQL permission/syntax errors, statement/lock/client timeouts, connection loss,
rollback success/failure/nonidle, incomplete/multiple/malformed results, close
failure, reconnect prevention and credential/error/evidence redaction.

## Remaining review/dependencies

**Ready for independent source/local-test review, NOT certified for remote use.**
The native adapter compiles, but successful DLL loading/ABI, real TLS verification,
password prompting/authentication, libpq startup ParameterStatus availability,
Supavisor transaction behavior, OS/network stalls and real rollback have not been
exercised. Failure-path TLS/timeouts are simulated, not actual network security
tests. Full result buffering inside libpq can precede the managed size checks.
Uncatchable process termination may prevent final evidence/rollback confirmation.

Review source, certificate provenance, redaction usefulness and these limitations
first. Obtain Mary's explicit approval for any remote attempt. Do not increase
timeouts, modify SQL, install packages, create accounts/roles, change schemas/RLS/
grants/functions, deploy, enable ingestion, or advance to Phase B. No current local
test qualifies as Q12, DB-IMP-01, integration, Auth/RLS or whole-task completion.
