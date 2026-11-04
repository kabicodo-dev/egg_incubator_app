# Q12 Phase A — public certificate references assessed

2026-10-31. **Certificate provenance: PARTIALLY SATISFIED; final acceptance
BLOCKED on independent authoritative fingerprint evidence.**

This addendum supersedes the source-not-identified/source-not-inspected portions
of `Q12_CERTIFICATE_PROVENANCE_OWNER_UPDATE.md`. Historical files and fingerprint
inventories remain unchanged. No certificate approval record is fabricated.

## Sources actually reviewed

Only the two user-supplied public pages were fetched read-only. No authenticated
Dashboard, project API, database, TLS endpoint probe, credential or SQL access was
performed. Public documentation access is not a test-project connection.

### 1. Community report in Supabase's repository

URL: https://github.com/supabase/supabase/issues/50862

Title: “Shared pooler certificate chain fails strict TLS verification:
intermediate CA missing Key Usage”. The retrieved issue body is attributed to
`bintillia`, opened September 24, 2026. Its public certificate section contains:

```text
Root: Supabase Root 2021 CA
807025ad50d4ed219d2c9c7d299c004f824eb00cf7f65afef607d07b72e6cafa
```

This exactly matches the previously locally verified DER SHA-256. A retrieved
community comment also reports that hash and an independent Dashboard-related
download. Those are additional third-party claims, not official endorsement.
The activity includes triage/label changes; those do not authenticate the posted
fingerprint or turn community observations into provider certification. No
explicit provider-authorized fingerprint confirmation was identified in the
retrieved content. Do not claim comments not returned by the fetch were reviewed.

**Classification: public community corroboration VERIFIED as to the posted
matching value; independently authoritative provider verification NOT established.**
Repository ownership, GitHub HTTPS delivery, labels and an issue remaining open
are not sufficient evidence that Supabase endorses the exact fingerprint.

The issue concerns observed chains on other endpoints/clients, including a
different region/port and Python/OpenSSL strict verification. It is a compatibility
caution, NOT evidence that the approved Q12 Session pooler or libpq 17.11 has
failed. No workaround from the issue was executed or adopted. If the actual
approved client later fails chain/hostname verification, stop; do not downgrade
TLS, trust an intermediate instead, disable checks, or automatically retry.

### 2. Official SSL documentation

URL: https://supabase.com/docs/guides/platform/ssl-enforcement

The retrieved “Postgres SSL Enforcement” documentation states:

> The strongest mode offered by Postgres is `verify-full` and this is the mode you most likely want to use when SSL enforcement is enabled. To use `verify-full` you will need to download the Supabase CA certificate for your database. The certificate is available through the dashboard under the SSL Configuration section in the Database Settings page.

Its SSL-mode table describes verify-full as encryption plus CA and hostname
verification. This is official support for the owner's reported download path
and the controller's selected SSL mode. The fetched page does **not** publish the
expected DER SHA-256 above or explicitly endorse the community issue's value.

**Classification: authoritative PROCEDURE/TLS documentation; not authoritative
verification of this exact certificate fingerprint.**

The page also describes CLI/API enforcement changes and trust-list edits. Those
examples are documentation only; none was run. No change to server enforcement,
certificate store, controller or approved SQL is authorized by reading them.

## Evidence disposition under the existing gate

| Layer | Current status |
|---|---|
| Owner of smarthatch-test / zbwntspdecngnicllwlw | Owner-attested and reaffirmed; retained, no repeat requested |
| Certificate personally downloaded from project's Dashboard SSL settings | Owner-attested and reaffirmed; route corroborated by official documentation |
| Local certificate identity, validity and DER/file hashes | Previously independently computed locally; matches owner report; not rerun or relabelled as a new inspection here |
| Public matching fingerprint | Source now identified and inspected; matching community value corroborated |
| Expected DER value from a separately trusted authoritative channel | **Still missing**; neither retrieved source establishes this exact provider-authorized value |
| Full reviewed provenance method / owner approval file | **Not yet accepted / not created** |

The existing reviewed gate at
`q12-controller/v3/CERTIFICATE_PROVENANCE.md:16–20` requires the expected DER hash
through an existing approved organizational record, verifiable Supabase publication
or authenticated official support confirmation. The launcher record asserts
`AUTHENTICATED_SOURCE_AND_INDEPENDENT_TRUSTED_FINGERPRINT`. Combining an official
procedure with an unendorsed community hash does not satisfy that assertion.

This is a Q12-specific existing gate, not a claim that TLS or Supabase universally
requires an independently published fingerprint. No criterion was weakened,
waived or expanded. An explicit official endorsement of the exact DER fingerprint
could satisfy the missing component; a bare request to re-download/rehash the same
file would not provide the required independent expected value.

## Precise missing evidence and safest next action

Missing: an authenticated provider confirmation (or another already approved
authoritative independent record) that the expected **DER SHA-256** for the
applicable Supabase Root 2021 CA is:

`807025ad50d4ed219d2c9c7d299c004f824eb00cf7f65afef607d07b72e6cafa`

The confirmation should identify the CA and its applicability to the project's
current connection path, so a stale or unrelated CA is not silently adopted.
Do not ask support to approve the local PEM byte hash; PEM formatting can differ.
The PEM/file hash remains an integrity pin for the exact local file.

**Single next action: request that confirmation through the project's authenticated
official Supabase support channel and provide its non-secret response/reference.**
No account creation, payment, support submission or external message was performed
by the assistant. If that support route is unavailable, report the blocker rather
than waiving the gate. An existing official publication or approved independent
organizational record with equivalent evidence remains an allowed alternative.

Copy-ready request:

> I own smarthatch-test (project reference zbwntspdecngnicllwlw). Please independently
> confirm the expected DER SHA-256 of the CA currently intended for this project's
> Session pooler connection using sslmode=verify-full. Our Dashboard-downloaded
> Supabase Root 2021 CA hashes to
> 807025ad50d4ed219d2c9c7d299c004f824eb00cf7f65afef607d07b72e6cafa.
> Is this the correct provider-authorized trust anchor, or has it been replaced?
> Please supply the official expected DER fingerprint or a provider-authorized
> reference containing it, rather than only confirming the download procedure.
> No database access or configuration change is requested.

After authoritative verification: complete the truthful owner provenance record,
confirm the exact target coordinates and secure local operator path, recheck
controller/SQL fingerprints and obtain fresh explicit approval for the exact
reviewed one-attempt Phase A command. No remote approval is inferred here.

**No SQL, migrations, production access, Phase B, controller edits, certificate
replacement or task-status changes. Q12 and DB-IMP-01 remain incomplete.**
