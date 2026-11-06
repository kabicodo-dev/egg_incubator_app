# OCT26:C-02A — independent schema verification while reviews are pending

**Owner:** Mary Charlyn (Cha/Mary) · **Date:** 2026-10-30 · **Priority:** P0.
**Status:** Not started → Partial. Verification deliverable performed; exact
Ally schema/example review remains open. No new full task Completed.

## Actual independent work

Reused the already-installed approved-temporary Ajv 8.17.1 and ajv-formats 3.0.1
with Node v26.4.0. No dependencies installed and no Flutter lockfile/pubspec edits.
Reexecuted the unchanged `docs/validate-c02-provisional.cjs` against the exact
historical provisional schema/examples that Kath reviewed. Also performed
standards-validator checks of the exact already-shared manual-result proposal.

Retained evidence:
- `c02-schema-revalidation.txt`: schema meta-validation/compilation passed;
  **14 positive synthetic examples**, **65 schema-negative mutations**, and
  **11 malformed/unsafe frame fixtures** passed; CRLF/trailing-whitespace and
  two additional status/time combinations passed.
- `manual-result-jsonschema.tap`: **13/13 test groups passed**, zero failures;
  all seven published request/response example objects pass shape validation.
- `manual-result-reference-revalidation.tap`: **21/21 tests passed**, zero
  failures/skips/cancellations; these are the existing pure local reference tests,
  not a deployed API or transaction test.
- `independent-schema-verification.json`: exact schema/fixture/validator hashes,
  installed tool versions, results and limitations. All input hashes unchanged
  before/after; old review bytes were not silently replaced.

Reproduction:

```powershell
node docs/integration/cha-execution/verify-independent-schema-work.cjs
```

Runner reuses the known approved-temp tooling, writes UTF-8 local evidence logs,
and fails if validator execution fails or input bytes change. It does not connect
to a database, internet, serial port or hardware.

## Findings that must remain explicit

Shape validity is not current Flutter/Uno compatibility: the provisional START,
STOP and STATUS examples are still larger than Ally's reported incoming buffer.
The historical transport and identity assumptions still require CHANGE; no source
protocol is selected by a successful schema test.

The manual-result proposal deliberately requires additional relational guards:
original quantity bound, signed-bigint maximum, expected identity/hash/session
and manifest mapping cannot all be proven by a structural JSON Schema. Reference
checks reject representative mismatches, but actual server implementation is absent.

Two concrete hardening gaps were directly demonstrated without editing the
already-shared schema:
1. Outer lookup batch/actor/result fields can be structurally inconsistent with
   the nested receipt. A real response validator must compare the full tuple.
2. NOT_AUTHORIZED with retryable:true currently passes the error shape, though
   documented semantics require controlled authorization recovery, not blind retry.

These are open review/runtime requirements, not claimed fixed. Recommend exact
reconciliation validation and error-code/retryability constraints in a separately
reviewed revision; do not silently overwrite the 0.1 package Kath is reviewing.
Positive schema checks demonstrating these gaps are not successful authorization
or server-acceptance cases. Raw manual-result HTTP duplicate-key/UTF-8 parsing,
real database uniqueness/races, Dart parity and durable storage remain untested.

## Received decisions versus missing inputs

- Mary's M01–M07 personal positions are confirmed, not another member's vote.
- Kath's exact five-input CHANGE review has been received; she need not repeat it.
- Her later storage/workflow/session proposal is received, but new package pins,
  API-30 floor, activation expiry and future finalization machinery remain unapproved.
- Ally's full D02/D04/D06 response and four completion conditions are received.
  His later EML verification is email-draft preparation, not the requested exact
  provisional-schema/example disposition or protocol-supersession selection.

**C-02A now has fresh sample/schema validation evidence and Kath review evidence.**
Still required: Ally's exact same-input capability/schema review and explicit
disposition of genuine gaps. A CHANGE review is legitimate review evidence; it
must not be confused with final protocol approval. C-02B's dependency stays open,
and C-02C still requires shared field/protocol approval.

## Remaining implementation work not executed

All **24 manual-result implementation/acceptance cases remain NOT RUN**. No
actual persistence, token/RLS, Flutter store, new source adapter, hardware command,
deployment, migration, firmware build, flashing or powered test was performed.
Application and database implementation remains outside this verification scope.

Published Cha counts after honest progress: **7 Completed, 9 Partial,
25 Not started, 1 Superseded**; 34 unfinished nonsuperseded source records.
Only C-02A progresses newly to Partial. Other-member statuses and the completed
archive remain unchanged. Browser-saved overrides/reports must not be overwritten.
