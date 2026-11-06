# DB-02 manual-result API — 0.2-review delta

**Date:** 2026-10-31 · **Owner:** Mary Charlyn (Cha/Mary).
**Status:** NEW REVIEW CANDIDATE; NOT JOINTLY APPROVED / NOT ENABLED / NOT DEPLOYED.

Read with [the preserved 0.1 proposal](DB-02_Manual_Result_API_0.1-review.md).
All 0.1 source/schema/fixture bytes remain unchanged. This document and the
`manual-result-0.2-review/` directory explicitly identify a new review revision,
not a silent update to already reviewed inputs.

## 1. Exact delta and unchanged scope

| Area | 0.2 proposed change | Approval/evidence boundary |
|---|---|---|
| Draft UUID reservation | At first durable draft creation reserve the original action UUID; sealing reuses it as result_id. Original committed identity survives ambiguous commits/restarts/retries. First durable creation and seal may be one transaction. | Mary explicitly approved M08: “yes i approve that specific rule”; actual store/transactions not implemented |
| Contract discriminator | api_version stays 2; exact contract becomes DB02-MANUAL-RESULT-0.2-review | New candidate bytes need exact review; this is not API activation |
| Lookup matching | Closed schema first; outer device/batch/actor/result tuple must match outstanding lookup and its original immutable result; nested receipt must match the same tuple and full expected receipt/core constraints | Test-only reference and negative fixtures; not a production response parser or database result |
| Retryability | Exactly SERVICE_UNAVAILABLE and COMMIT_UNKNOWN have retryable:true; all other listed codes false. COMMIT_UNKNOWN requires commit_status:unknown; all other codes not_persisted | Expressible in schema; raw malformed/unknown envelope gives no retry/commit inference |
| Scenario wording | unknown_time_zero and phone_time_upper are independent alternatives with SAME action identity and different content; sequential second submission must conflict | Both are synthetic vectors, not two accepted results for one batch |

Still unchanged: eight-field semantic core; unknown or whole-second explicitly
phone-clock action time; real trusted manifest/mapping before result acceptance;
immutable revision-1 result_recorded receipt; original positive egg_quantity and
bounded manual count; decimal bigint mapping; current uploader excluded from
immutable actor/core; one initial result per controller/batch; no correction or
finalization endpoint. Result alone leaves status/Active/end_date/admission intact.
No Stop dependency or source release proof is added. No physical Start/Stop exists
in this interface. Manifest trust/encoding and selected source remain blockers.

## 2. Normative response-validation order for review

1. Accept a response only from the approved authenticated endpoint/transport in
   the future implementation. Local fixtures/oracle do not authenticate anything.
2. Strictly parse bounded UTF-8, rejecting duplicate keys; validate the exact
   closed version/contract/operation/response-kind schema. These raw HTTP/parser
   steps remain NOT implemented/tested by the parsed-object oracle.
3. For lookup, validate the outstanding lookup request and retained original
   immutable submission, including same original device/batch/actor/result tuple.
   An unrelated lookup must not be compared to whichever result arrived last.
4. Compare all four outer tuple fields to the outstanding original tuple.
5. found:false requires an explicit receipt:null. It is an absence observation,
   not proof an in-flight original submission cannot commit; no new identity or
   physical command may be inferred. Authorization/eligibility still apply to
   any later identical resubmission.
6. found:true requires a structurally valid nested recorded receipt. Compare
   all four nested tuple fields with outer fields AND retained request tuple.
7. Validate expected content/manifest hash, original quantity/count, lossless
   mapped session, version/contract/revision/outcome/fixed effects and null release.
   Receipt ID and first received_at must remain identical if a prior receipt is
   already retained. Schema UUID/date syntax does not establish continuity.
8. Only after validation may the future client atomically commit receipt/mapping/
   outbox state. This remains a required implementation test, not an oracle pass.

Standard JSON Schema does not compare arbitrary sibling identifiers/expected
hashes without nonstandard extensions. `schema.json` deliberately uses standard
2020-12 plus an explanatory $comment; normative tuple/content comparisons are
performed separately by the TEST-ONLY reference and remain required at runtime.

## 3. Error handling — no inference from malformed replies

Known closed error envelopes only. ERROR retryability is code-specific, not
caller-controlled advice: SERVICE_UNAVAILABLE means known not_persisted;
COMMIT_UNKNOWN means uncertain outcome requiring read-only reconciliation of
original identity. Neither authorizes a new result identity or physical retry.
401 requires approved reauthentication; 403 denies protected operation; manifest/
mapping/count/conflict/disabled-contract errors do not trigger blind automatic
retry. Unknown code, missing/extra fields, wrong types, bad UUID/version/contract
or contradictory retry/commit flags fail validation without claiming persistence
did or did not happen. Preserve local evidence and use the approved recovery path.

## 4. Version/hash and migration boundary

Contract is one of the eight immutable core fields; 0.2 therefore has NEW vector
digests even though field names and synthetic data remain the same. Old 0.1 Dart
parity evidence is retained for 0.1 only. Kath must check exact 0.2 canonical bytes
and response guards before claiming consumer parity for this revision.

Never relabel an existing 0.1 pending/committed action as 0.2, mint a new result ID
to bypass a conflict, or auto-convert outbox records. Any future version migration
requires explicit identity/receipt/history compatibility policy and authorization.
The current server recognizes neither proposal as enabled; no fallback path is
introduced by producing these documents.

## 5. Artifacts and reviewer actions

Directory `manual-result-0.2-review/` contains the schema, synthetic fixture/vector
set, TEST-ONLY reference code, delta tests, local logs, immutable-parent manifest
and README. External Ajv tooling is reused only for local validation; no package
or native dependency installation occurs.

**Mary's M08 decision is closed as a personal design choice.** Do not request it
again. **Kath:** review only this delta: exact discriminator/new hashes, complete
lookup comparison and code-specific retryability. Her previous scoped ACCEPT
recommendations for unchanged 0.1 semantics are preserved, not discarded or
presented as blanket 0.2 sign-off. **Ally:** no new firmware review requested by
this result-only delta; existing source/admission/manifest facts remain due.

All 24 old actual implementation cases and 102 portfolio cases remain NOT RUN.
Unit/schema/model passes are not durable draft/seal, authentication, persistence,
concurrency, raw parser, Flutter, controller, physical, research or adoption tests.
No whole task status changes merely from approval of M08 or this candidate.
