# Manual-result 0.2 — M08 confirmation and delta preparation

Date: 2026-10-31. Mary's exact answer “yes i approve that specific rule” confirms
reservation of the action UUID at first durable draft creation, reuse as result_id
at seal, and unchanged identity on retries of that committed action. Recorded as
M08 in the existing position/decision ledger; no other personal choices inferred.

## Prepared, not enabled

- Separate `DB-02_Manual_Result_API_0.2-review.md`, generated `manual-result-0.2-review/`
  standard schema, synthetic fixtures/new vectors and TEST-ONLY reference guards.
- Closed shape validation before lookup tuple/content/receipt comparisons.
- retryable:true only SERVICE_UNAVAILABLE/COMMIT_UNKNOWN; exact commit-state
  relation; unknown/malformed envelopes rejected without an outcome inference.
- Alternative same-identity count/time vectors explicitly labelled independent
  scenarios; sequential changed content is expected to conflict, not create two
  results. Draft identity fixture demonstrates correspondence, not a transaction.
- Parent manifest checks the four exact 0.1 proposal/schema/fixture/matrix hashes;
  old source files, earlier review ZIPs and implemented code are not overwritten.

## Actual checks

With existing approved-temporary Ajv 8.17.1 / ajv-formats 3.0.1 in NODE_PATH:

```powershell
node docs/integration/cha-execution/build-manual-result-0.2.cjs
node --test --test-reporter=tap --test-reporter-destination=docs/integration/cha-execution/manual-result-0.2.tap docs/integration/cha-execution/manual-result-0.2.test.cjs
```

**27/27 passed**, zero failed/skipped/cancelled. Includes schema meta-validation,
nine fixture shapes, every known error flag combination, old-version rejection,
four outer/four nested tuple mismatch checks, expected original association,
hash/manifest/count/session/receipt continuity and no input mutation. All four
0.1 parent fingerprints preserved. These are local schema/model tests only.

Two NEW canonical-vector digests under the new 0.2 contract string:
- unknown_time_zero: 422 bytes;
  799cb58d64b2db57c950eefb8c16ddbc8fd88cd75252ffe1693ed121ecc8b078.
- phone_time_upper: 445 bytes;
  9ac45d31b8981342f8c13b2d4d9334e1d3f22cca2ff25086399e065ce326356c.

Kath's delivered 0.1 Dart parity remains valid 0.1 evidence, not 0.2 parity.
Ask only for the delta and actual new-vector checks, not a repeat general review.
No new Dart run, raw HTTP parser, authorization, transaction, durable store,
singleton race, source mapping, Flutter/firmware/device or physical test is claimed.
All 24 old implementation cases and 102 portfolio cases remain NOT RUN.

No new full task completion or status change: 7 Completed / 9 Partial /
25 Not started / 1 Superseded. Only M08's personal decision is now resolved.
