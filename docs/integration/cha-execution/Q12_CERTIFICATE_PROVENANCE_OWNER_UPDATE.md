# Q12 Phase A — owner-provided certificate provenance update

Recorded 2026-10-31. **Assessment: PARTIALLY SATISFIED; independent authoritative
fingerprint verification remains pending. No remote execution authorization.**

This addendum updates the current assessment without rewriting the historical
controller/procedure, execution package or their fingerprint inventories. Earlier
statements that owner attestation was not supplied are historical; this addendum
supersedes that specific gap. Q12 and DB-IMP-01 remain incomplete. No status edit.

## 1. Owner evidence received

The user explicitly attests:

> I confirm that I am an owner of the Supabase test project `smarthatch-test`, project reference `zbwntspdecngnicllwlw`.

> I personally downloaded the existing certificate `prod-ca-2021.crt` from the Supabase Dashboard under Database Settings → SSL Configuration → Download Certificate.

The owner reports successful Windows `certutil -dump` inspection, subject/issuer
Supabase Root 2021 CA, validity April 28, 2021 through April 26, 2031, and:

- DER SHA-256: `807025AD50D4ED219D2C9C7D299C004F824EB00CF7F65AFEF607D07B72E6CAFA`.
- PEM/file SHA-256: `700723581420DD1AC98FD7E9AC529F0EF210EADCAF87FC868A3AD7D114C2F3B7`.

The owner also states:

> The DER fingerprint also matches a publicly documented Supabase Root 2021 CA fingerprint.

No URL, publication title/publisher, document excerpt or independent authoritative
record was supplied for that public fingerprint. The attestation is retained as
owner evidence, not misrepresented as an assistant-observed download, raw supplied
certutil log, independent identity audit or inspected public publication. No download
time is invented. Project ownership need not be requested again for this assessment.

## 2. Evidence layers and current disposition

| Evidence layer | Current assessment | What it establishes / does not establish |
|---|---|---|
| Project ownership and Dashboard download | **OWNER-ATTESTED / RECEIVED** | User states authority for this exact project and personally obtaining this existing file through its SSL settings. This resolves the missing owner statement, not independent verification of the Dashboard session. |
| Owner's certutil inspection | **OWNER-REPORTED / CONSISTENT** | Reported identity, dates and hashes agree with local inspection. Raw certutil output was not supplied and is not needed merely to repeat the independently available local hash computation. |
| Assistant offline certificate inspection | **LOCALLY VERIFIED** | Fresh parse/hash at 2026-10-31T15:16:45.9231002Z matches both owner-provided hashes (case-insensitive hexadecimal comparison). Identity/validity match. Earlier local observation records CA constraints/signing usage. Does not establish trusted origin, endpoint chain/hostname or current revocation status. |
| Public fingerprint corroboration | **OWNER-REPORTED; SOURCE NOT PROVIDED / NOT INDEPENDENTLY INSPECTED** | The matching-publication claim is recorded. Publisher, exact fingerprint basis (DER versus PEM), authenticity and source independence cannot yet be assessed. Do not label this verified public corroboration. |
| Independent authoritative verification | **PENDING / NOT COMPLETE** | No identified independent authoritative expected DER value has yet been checked. Recomputing the local file, matching subject/issuer, or an unattributed public fingerprint does not satisfy this layer. |

## 3. Fresh offline inspection

Existing file: `C:\Users\Mary Charlyn\Downloads\prod-ca-2021.crt`.

- Subject and issuer: `CN=Supabase Root 2021 CA, O=Supabase Inc, L=New Castle, S=Delware, C=US`.
- Not before: `2021-04-28T10:56:53Z`.
- Not after: `2031-04-26T10:56:53Z`; within validity at the inspection time.
- DER SHA-256: `807025ad50d4ed219d2c9c7d299c004f824eb00cf7f65afef607d07b72e6cafa`.
- File SHA-256: `700723581420dd1ac98fd7e9ac529f0ef210eadcaf87fc868a3ad7d114c2f3b7`.
- Approved SQL rehashed unchanged:
  `9cac281d9ecca2dda46c93de85f2b26b01f9b762d2def67a5efa5ad578242fdc`.

Used Windows X509Certificate2 parsing and local SHA-256 only. No chain building,
revocation fetch, certificate-store import, web request, Supabase connection,
remote SQL, migration, deployment or Phase B operation occurred. The certificate
and approved SQL were not edited. No controller/test changes were necessary;
the earlier 211/211 tests were not rerun or relabelled as new results.

## 4. Can the certificate requirement now be accepted?

**Accept the ownership/download attestation and matching local identity/hash
inspection as satisfied evidence components. Do not yet accept the complete
existing certificate-provenance gate.**

The currently reviewed local procedure
`q12-controller/v3/CERTIFICATE_PROVENANCE.md:16–20` explicitly requires an expected
DER SHA-256 from a separately trusted authoritative channel. The launcher record
in `DurableController.cs:230–239` asserts method
`AUTHENTICATED_SOURCE_AND_INDEPENDENT_TRUSTED_FINGERPRINT`. The new owner statement
does not establish that full method without identifying the public source.

This is the **existing Q12 local gate**, not a claim that Supabase/PostgreSQL/TLS
universally mandates an out-of-band fingerprint, and not a new requirement for
support confirmation specifically. An authentic, independently obtained official
Supabase publication containing the same DER fingerprint, or an existing approved
organizational record/authenticated official support record, can satisfy the
missing component if its authority, fingerprint basis and source independence
are established. An unattributed or third-party repost provides corroboration,
not by itself authoritative verification.

Do not create `certificate-owner-approval.json` with status
`OWNER_VERIFIED_TRUSTED_ORIGIN` yet: that would assert a method whose independent
fingerprint component is still unestablished. Do not weaken the procedure/parser
or silently treat the update as a waiver. Any proposed alternative trust model
would need explicit security review and applicable approval, not an inferred
exception. No such change is made here.

## 5. Remaining Phase A gates

1. **Identify and assess the public/authoritative fingerprint source.** Exact URL
   or non-secret official/approved record reference and publisher are missing.
   Verification is not performed by this update, which makes no network requests.
2. Once that check actually passes, record the genuine verification method/time
   and owner-reviewed eight-field provenance record tied to the final approval
   reference. A future record is not itself permission to execute remotely.
3. Confirm the exact Session pooler coordinates from the authorized test project's
   settings: `aws-0-ap-northeast-1.pooler.supabase.com:5432`, database `postgres`,
   username `postgres.zbwntspdecngnicllwlw`. Ownership/download attestation does not
   additionally assert those specific connection coordinates.
4. Recheck final controller/SQL fingerprints before any authorized attempt; use
   the reviewed v3 command in `q12-execution-package/README.md:119–151`, with hidden
   local credential entry by the authorized operator. No credential in chat,
   argument, transcript or new secret file. No credential has been supplied here.
5. Obtain **fresh explicit approval of that exact command for one Phase A attempt**,
   accepting bounded/partial catalog coverage, sanitized evidence, original-
   connection rollback and no automatic retry. This certificate update is not
   that approval. Main/production, mutations and B–E remain excluded.
6. Actual TLS/hostname/auth/settings/results and original-connection rollback/idle/
   closure still require genuine authorized execution evidence; none is inferred
   from certificate hashes or local tests.

Overall Q12 additionally retains the original permission-disposition and final
reviewer-acceptance gates; DB-IMP-01 remains separate. No original task is advanced.

## 6. Exact next action

**Provide the exact URL and publisher of the public Supabase Root 2021 CA
fingerprint you referenced, or identify the approved official/organizational
record containing the expected DER SHA-256.** If possible, include its relevant
non-secret fingerprint excerpt. Do not send passwords, tokens, cookies or login
screenshots. No repeated ownership confirmation, certificate re-download or SQL
execution is requested. The source must be assessed before declaring independent
authoritative verification complete.
