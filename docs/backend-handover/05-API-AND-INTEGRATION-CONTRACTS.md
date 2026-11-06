# 05 — API and integration contracts

## Contract register

| Files | Classification / next disposition |
|---|---|
| `docs/C02-provisional-communication-contract.md`, schema and examples | Historical provisional family, not selected wire; both exact-input CHANGE reviews now received |
| `docs/contract-review/Original-C02-candidate-1.*` | Separate historical candidate; inventoried, not interchangeable with provisional/numeric/source families |
| `docs/contract-review/DB-02_Exact_Bridge_Sync_API.md`, schema/security and conflict/recovery companions | `0.1-review` proposed cloud API; not jointly adopted/deployment evidence |
| `docs/contract-review/DB-02_Manual_Result_API_0.1-review.md`, schema/fixtures/closure matrix | Preserved parent proposal; not silently overwritten by 0.2 |
| `docs/contract-review/DB-02_Manual_Result_API_0.2-review.md`, `manual-result-0.2-review/` | Scoped Kath ACCEPT recorded; API version 2 AND exact contract tag required; actual server/client feature not implemented |
| `docs/contract-review/C02_Wire_Family_Decision_Request_2026-11-02.md` | Focused numeric interim v1 vs target v2 request; prepared, not evidence of delivery or selection |
| K06 v0.3/v0.4 and ARCH-05 amendment | Architecture direction documented; formal adoption/distribution separate |

## Latest C-02 review evidence

[2 Nov receipt](../integration/cha-execution/ALLY_C02_20261102_RECEIPT_AND_CLOSURE.md) records Ally's same-input REQUEST CHANGES, with current validator output. Both reviewers' CHANGE outcomes can satisfy a review-only deliverable without approving the wire. C-02A is assessed eligible for scoped completion, not automatically published as Completed. C-02B remains Partial pending separate A-01 prerequisite reconciliation. Do not ask for duplicate general reviews or infer a new shared protocol.

Numeric `START` is reported implemented in Ally's candidate; `START_BATCH/CONFIRM` is not. Candidate source hashes/build descriptions are not raw source delivery, joint selection or flashed-image evidence. Incoming 119-content-byte limit is not TX/ring capacity. Same `v:1` labels do not make incompatible envelopes compatible.

## Manual-result 0.2 requirements to preserve

- Pin `api_version:2` and `contract:"DB02-MANUAL-RESULT-0.2-review"`; preserve the eight-field hashed core and exact fixtures.
- M08 reserves the original action UUID at first durable draft; use it as result ID at seal/retry; ambiguous commits reconcile the original identity, not a new action.
- Validate trusted original manifest/session/quantity and integer count `0..egg_quantity`. Missing mapping is pending validation, not manufactured identity/time.
- Result-only recording does not command Stop, mark lifecycle Completed/end_date, clear Active, admit another hardware batch or release retained evidence.
- Validate outstanding/outer/nested tuple, content hash, count, manifest, session and receipt continuity. Only SERVICE_UNAVAILABLE/COMMIT_UNKNOWN are retryable in this exact proposal; only COMMIT_UNKNOWN is unknown-commit state.

Current handler still requires `api_version===1` and `stopped_event_id`; that is a verified incompatibility, not an authorized silent fix. Migration/version/outbox/History compatibility and rollback remain missing approvals. See [06](06-PENDING-BACKEND-CHANGE-REGISTER.md).
