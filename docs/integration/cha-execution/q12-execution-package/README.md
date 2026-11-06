# Q12 coordinated execution and closure package

2026-10-31 · **BLOCKED BEFORE REMOTE EXECUTION.**

Local investigation, fresh source/evidence review and testing are complete to the
limits recorded here. No new blocking controller defect was found; the final
candidate remains **v3 unchanged**. No Supabase request, remote SQL, account,
migration, deployment, credential retrieval, task-status edit, commit/push/merge,
UI/firmware change, ingestion enablement or other original task was performed.

## Package contents

- [Original scope and requirement/evidence matrix](REQUIREMENT_MATRIX.md).
- [Fresh controller review, F1–F7/R1–R5 and catalog coverage](REVIEW.md).
- [Machine verification and offline certificate observation](local-review-evidence.json).
- [Original-source and three-runtime-unit compilation proof](additional-controls.json).
- [Pending remote receipt, discrepancy register and closure/sign-off](PENDING_REMOTE_AND_CLOSURE.md).
- `Verify-LocalEvidence.ps1`, `Verify-AdditionalControls.ps1`: executed offline,
  create-once evidence tools; no credential input or network operation.
- `package-inventory.json`: hashes/sizes of this package, the complete controller
  tree including the fresh run, relevant original records, SQL and draft comparators.
  Inventory excludes itself to avoid recursive hashing.

## Outcome and scope

Q12 is an original shared **permission request** affecting 14 tasks, not a
standalone database implementation task. No separate original issue with a full
implementation acceptance checklist was found. Its exact wording and owners are
preserved in REQUIREMENT_MATRIX.md. B–E are separately gated proposed dependent
work; not authorized, not automatic prerequisites to Phase A, and not evidence
that all original dependent tasks are complete. The owner must confirm the
permission request's final disposition. Phase A explicitly cannot close Q12.

Mary/Cha is one person; do not manufacture two independent sign-offs. Kath's
earlier scoped manual-result acceptance is not certificate provenance, migration
permission or final Q12 acceptance. Ally is not a Phase A prerequisite.

## Local results and review verdict

- Historical final v3 **211/211 PASS**, all cases/source/compiler receipts checked.
- Fresh **211/211 PASS**, run `d7b25ad8655a47318783ec987cee2859`:
  `../q12-controller/v3/local-verification-d7b25ad8655a47318783ec987cee2859/test-results.json`.
- v2 and v3 retained inventories: all recorded hashes and sizes PASS; original
  v1 input hashes PASS. No historical inventory/evidence rewritten.
- Eight frozen source hashes and five compiler receipts match both runs. Separate
  three-file runtime compilation PASS, with three additional receipts (not extra
  tests and not a remote run).
- Emergency-only synthetic recovery correlates actual tested-source hashes/run ID
  without the primary journal; rollback/idle/close are **simulated**, not live.
- 61 JSON/JSONL files scanned for known synthetic secret markers, no matches.
  This is bounded redaction regression evidence, not an arbitrary-secret audit.
- Actual native coverage remains three local-memory libpq probes; version 170011.
  No PGconn, socket, authentication, TLS handshake or real rollback exercised.
- **Verdict: local PASS WITH LIMITATIONS; remote readiness BLOCKED.** Fresh review
  by the same assistant is not independent human acceptance or a signed audit.

## Exact immutable SQL and target

SQL: `docs/integration/cha-execution/Q12_Phase_A_Read_Only.sql`

SHA-256: `9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc`

Exactly 17 statements, sequentially, one READ ONLY / REPEATABLE READ transaction;
10s statement, 2s lock, 60s idle timeouts unchanged. Twelve SELECTs including the
settings guard; eleven catalog queries each limited to the 501 overflow sentinel.
Final ROLLBACK; sole failure cleanup is one same-connection ROLLBACK if usable.

| Field | Only proposed value |
|---|---|
| Project | smarthatch-test |
| Reference | zbwntspdecngnicllwlw |
| Session pooler | aws-0-ap-northeast-1.pooler.supabase.com |
| Port / database | 5432 / postgres |
| Project-specific username | postgres.zbwntspdecngnicllwlw |
| TLS | verify-full; pinned local root file and owner-approved hashes |
| Explicit exclusions | suopuhgtwyqkpupzvdng, production, all other projects |

Local target constants/negative tests verified. Real tenant routing and TLS are
not independently established by those constants or Mary's historical SSL report.
Before approval the authorized owner must confirm these connection coordinates
from the authenticated test project's settings, without supplying a password.

## Certificate observations versus trust

Existing file, inspected offline only:
`C:\Users\Mary Charlyn\Downloads\prod-ca-2021.crt`.

- Subject/issuer: `CN=Supabase Root 2021 CA, O=Supabase Inc, L=New Castle, S=Delware, C=US`.
  Spelling is the certificate's actual text, not an inferred company identity.
- Validity: 2021-04-28 10:56:53Z through 2031-04-26 10:56:53Z; locally within range.
- Critical basic constraints: CA; key use includes certificate and CRL signing.
- File SHA-256: `700723581420dd1ac98fd7e9ac529f0ef210eadcaf87fc868a3ad7d114c2f3b7`.
- DER SHA-256: `807025ad50d4ed219d2c9c7d299c004f824eb00cf7f65afef607d07b72e6cafa`.

**These are observations, NOT approved fingerprints.** No chain/revocation/network
check, signature trust adjudication or trust-store import was performed.
An equal subject/issuer or locally calculated DER hash is not trusted origin.

Required authoritative source procedure:
`../q12-controller/v3/CERTIFICATE_PROVENANCE.md`.
The expected authenticated source is the test project's Database SSL settings at
`https://supabase.com/dashboard/project/zbwntspdecngnicllwlw/database/settings`.
This source was not visited/validated in this run. Owner must provide:

1. Sanitized authenticated-origin/project/date/operator attestation for the
   certificate actually downloaded from that project's SSL settings.
2. Expected DER SHA-256 from an independently trusted authoritative record,
   verifiable official publication or authenticated official support. Identify
   that source/channel. Rehashing this same file does not satisfy independence.
3. Confirmation of CA identity/validity and equality to the independently expected
   DER value, plus exact local file hash and project connection coordinates.
4. Genuine owner record matching the strict eight fields in the provenance
   procedure, correlated to the approval reference below. No completed owner
   record is fabricated in this package.

If the authoritative certificate differs, **stop**. Do not automatically replace
the pinned file or approve this observed fingerprint to make checks pass.

## Proposed command and exact approval scope — NOT EXECUTED

Reserved reference `Q12-PA-20261031-02` is an identifier only, **not an approval**.
Proposed owner-record location below does not currently contain an attestation.
From `C:\EggIncubator\egg_incubator_app`, in a fresh trusted Windows PowerShell
console with no transcript/recording/debugger:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\docs\integration\cha-execution\q12-controller\v3\Invoke-Q12PhaseA-V3.ps1" -ExecuteRemote -ApprovalReference "Q12-PA-20261031-02" -CertificateApprovalFile ".\docs\integration\cha-execution\q12-execution-package\certificate-owner-approval.json"
```

**Preconditions before requesting runnable approval:** trustworthy certificate
evidence/record; owner's target confirmation; final source/SQL/package fingerprint
match; authorized operator able to enter existing database credential locally
through the hidden prompt. The API agent cannot safely supply interactive input;
there is no established agent credential channel. Do not send passwords in chat,
arguments, environment files or a transcript. No new account/password reset.

Conditional approval text, **not effective unless genuinely supplied after those
preconditions are met**:

> I am authorized for smarthatch-test / zbwntspdecngnicllwlw. I approve one attempt
> of the exact v3 command above under Q12-PA-20261031-02, with the unchanged pinned
> SQL, bounded metadata-only read-only transaction, sanitized local evidence and
> original-connection rollback/close. I accept the documented partial comparison
> coverage. No automatic retry, other target, mutation, account/fixture/role/RLS/RPC
> change, deployment, source enablement, later phase or task-status edit is approved.

Do not run yet. This package cannot safely recommend unconditional remote approval
while certificate provenance is missing. Fresh final-command consent remains a
separate mandatory gate; historical narrow consent and this local-work request
do not substitute for it. If any reviewed bytes change, reverify/review the exact
candidate before seeking consent.

## Risks, stops, rollback and evidence handling

| Risk / stop | Required response |
|---|---|
| Missing authority/provenance/secure credential, hash mismatch, target uncertainty, expired/mismatched certificate | Stop before connection; no TLS downgrade, linked CLI fallback or secret request. |
| SQLSTATE/error, malformed shape/OID/NULL, 501 rows, unexpected stream/state, timeout, lost connection, evidence/serialization failure | Stop subsequent catalog statements; original usable connection gets at most one cleanup ROLLBACK if in/failed transaction. Otherwise mark explicit rollback UNAVAILABLE and close. No reconnect/retry. |
| ROLLBACK tag without idle, close failure or absent/torn final record | Not successful inspection/cleanup; preserve failure evidence and escalate. New connection does not prove original rollback. |
| Partial comparisons/unknown object identity, withheld expressions, unapproved draft deviation | Report UNRESOLVED/scoped difference; do not certify full audit or execute corrective SQL. |
| Native DNS/result buffering/disk stalls or crash | Managed watchdogs/flushes are not hard realtime or power-loss guarantees. Missing proof remains missing; inspect preserved evidence without reconnecting. |

Do not pause inside a transaction. Credential entry and all preparations occur
before BEGIN; the controller sends/validates/journals sequentially without human
prompts. On success require ROLLBACK command tag, IDLE state, connection closure,
durable last terminal event and attributable bounded outputs. Database delta is
none; no delete/drop cleanup is permitted because nothing was created.

Run evidence location: fresh `../q12-controller/v3/run-<runId>/`, not a reused
directory. Retain `journal.jsonl`, `emergency.jsonl`, compiler artifacts and final
hash manifest. Unknown identifier mappings/raw expressions stay in memory only;
never save libpq messages, raw results, password/token material or hidden hashes
of sensitive expressions. Inspect the final event for the same run ID and
mode REMOTE_AUTHORIZED; synthetic examples cannot serve as live receipts.

Retain original files unmodified on the protected workstation; restrict sharing
to sanitized review material and hash copies before transfer. No retention expiry
was specified, so no evidence deletion/cleanup is authorized. Shared-disk emergency
evidence is not an independent backup. No production or remote storage upload is
included. Review any later actual outputs before sharing, even though identifiers
are allowlisted/opaque. Receipt and reviewer forms remain explicitly pending.

## Copy-ready questions by owner

**Kath / authorized test-project owner (certificate/target blocker):**
> Please provide a non-secret authenticated-origin attestation for the root CA
> downloaded from smarthatch-test's SSL settings, the independently authoritative
> expected DER SHA-256 and its trusted source/channel, verification time/operator,
> and confirmation of the exact Session pooler host/port/project-specific username
> above. Please do not send passwords, tokens, cookies or login screenshots.
> If no independent fingerprint exists, report that gap rather than approving the
> hash calculated from the same file. Then complete the strict owner record only
> if the provenance steps genuinely pass.

**Mary/Cha and Kath where responsible (scope/closure blocker):**
> The original Q12 is a shared permission gate for 14 tasks; the staged plan says
> Phase A cannot close it. Please confirm that B–E remain separately gated
> dependent-task work, identify which exact permission decisions (if any) remain
> necessary to close this shared request, and name the authorized closure reviewer.
> No blanket approval or implementation-task completion is requested.

**Mary/Cha (remote authorization/operation gate, after trust evidence):**
> Please review the exact command, fingerprint inventory, partial catalog coverage
> and stop/rollback rules. Once trust/target facts pass, explicitly approve one
> attempt using the scoped text above and confirm that you can enter the existing
> credential privately in a local trusted console. Do not paste it here.

**Ally:** no Phase A hardware question or dependency; do not introduce one.

## Final gate / recommended status

Implemented: v3 safeguards; prepared: full local package and pending forms;
locally tested: 211/211; reviewed: fresh same-assistant source/evidence pass with
limits; externally accepted: **no**; trusted certificate: **no**; newly approved
remote command: **no**; remotely verified catalog/rollback: **no**; closed: **no**.

**Q12 BLOCKED** pending authoritative trust/target facts, secure operator path,
fresh final-command consent, genuine remote evidence if authorized, original
permission disposition and final reviewer acceptance. DB-IMP-01 remains separate
and incomplete. No portal/GitHub status has been changed.

**Single next user action:** return the non-secret owner provenance/target evidence
bundle requested above (or state that its independent fingerprint is unavailable).
Do not supply a password or authorize an unsafe bypass. Review/approval of the
fixed command follows once that security gate is satisfied.
