# F6 — trusted certificate-origin verification procedure (not executed)

**Actual provenance status: BLOCKED / NOT VERIFIED.** This correction task makes
no Supabase request. A matching filename, successful encryption, local file hash,
self-signed root or Windows certificate parsing is not proof of trusted origin.

Before a separately approved remote attempt, the authorized owner must:

1. Use an independently trusted browser/workstation session. Verify HTTPS origin
   `https://supabase.com`, normal browser certificate validation and authenticated
   project `zbwntspdecngnicllwlw` / smarthatch-test. Do not use copied email links,
   certificate-warning overrides, arbitrary search downloads or a different project.
2. Open the project's Database settings SSL section. Retrieve the root certificate
   through that authenticated source **without changing any project setting**.
   Retain a sanitized source/date/owner attestation; no login material or cookies.
3. Obtain the expected **certificate DER SHA-256** through a separately trusted
   authoritative channel (existing approved organizational certificate record,
   verifiable Supabase publication, or authenticated official support confirmation).
   If no authoritative fingerprint is available, report this gap. A second hash
   of the same untrusted file is not an independent trust source.
4. Offline, inspect certificate subject/issuer, CA basic constraints, validity and
   DER SHA-256. Compare DER fingerprint to that authoritative value. Separately
   record the exact PEM/file-byte SHA-256 used by the controller. Do not import
   certificates into machine/user trust stores, reset passwords or change SSL.
5. Have the authorized owner review the source and both fingerprints. Only then
   create a local provenance record with exactly these fields:
   `status`, `projectRef`, `sourceUrl`, `verificationMethod`, `verifiedAtUtc`,
   `approvalReference`, `fileSha256`, `derSha256`.
   Required status: `OWNER_VERIFIED_TRUSTED_ORIGIN`; method:
   `AUTHENTICATED_SOURCE_AND_INDEPENDENT_TRUSTED_FINGERPRINT`; source URL:
   `https://supabase.com/dashboard/project/zbwntspdecngnicllwlw/database/settings`.
   Time is whole-second UTC; approval reference format `Q12-PA-YYYYMMDD-NN`.
   This task does not generate a record falsely claiming those steps occurred.
6. Review the source attestation alongside the machine record. The record is a
   human trust assertion, not cryptographic proof of its own provenance. The launcher
   rejects missing/mismatched record and file/DER hashes; it cannot authenticate
   an owner's statement offline. A subsequent real connection must still pass
   libpq `verify-full` against the pooler hostname. No TLS downgrade is permitted.

No certificate fingerprint has been approved by this correction task. Do not
substitute a locally computed fingerprint to bypass this gate. No remote approval
is requested here; all remote work awaits separate explicit permission.
