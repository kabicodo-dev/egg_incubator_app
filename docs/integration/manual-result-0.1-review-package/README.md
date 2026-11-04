# Manual-result API 0.1-review — exact-byte review package

Prepared 2026-10-30. PROPOSED, NOT JOINTLY APPROVED, NOT IMPLEMENTED/DEPLOYED.
The user confirmed personal M01–M07 directions; exact fields are NEW proposals.

Read docs/contract-review/DB-02_Manual_Result_API_0.1-review.md first, then the
companion schema, fixtures and closure matrix. All 24 actual implementation
acceptance cases remain NOT RUN. The 21 passing tests are pure local proposal
checks, not a real server, Auth, database, Flutter or physical integration pass.

Kath: please return ACCEPT / CHANGE / BLOCKED against the exact candidate bytes:
1. Separate result-only version/operation (no old farmer_completed fallback).
2. Original manifest/mapping required; missing stays Pending validation, not dummy IDs.
3. Unknown vs explicitly phone-clock action time; whole-second precision.
4. Exact eight-field core/hash vectors; reproduce canonical UTF-8/digests in Dart.
5. Immutable result receipt/lookup and validation; lossless bigint session mapping.
6. One ordinary result per batch, deferred corrections, unchanged Active/end_date.
7. Durable local freeze/result/outbox and T4 receipt/mapping commit boundaries.
Provide only your concrete package/version/schema/SDK proposal and remaining changes;
do not repeat architecture review or assume these new fields are already approved.

Ally: this adds NO controller command, Stop evidence, admission or release proof.
Existing selected-source/manifest-trust/recovery facts remain your deliverables.
No fresh general audit or physical test is requested.

From the package root, local optional reproduction (no install required):
node docs/integration/cha-execution/manual-result-reference.cjs
node --test docs/integration/cha-execution/manual-result-proposal.test.cjs
These scripts are test-only. Do not import them into production or upload fixtures.
General JSON Schema/raw parser validation is NOT performed by this test oracle.

No code/database changes, deployment, flashing or powered tests authorized.
No external send occurred; preparing this ZIP does not complete distribution.
See manifest.json for byte fingerprints; do not silently edit review inputs.
