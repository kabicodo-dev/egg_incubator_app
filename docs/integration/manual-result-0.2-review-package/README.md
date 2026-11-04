# SmartHatch manual-result 0.2 — delta-only review request

Prepared 2026-10-31; candidate NOT jointly approved, enabled or implemented.
Mary has explicitly APPROVED M08: reserve action UUID on first durable draft
creation, reuse at seal and retries. Do NOT ask her this same decision again.
No package/SDK/enrollment/finalization/database/physical approval is implied.

Read docs/contract-review/DB-02_Manual_Result_API_0.2-review.md first. Old 0.1
parent artifacts are included byte-identically for comparison, not overwritten.
Kath's scoped ACCEPT findings and delivered 0.1 Dart script are retained evidence;
do not repeat general architecture or unchanged-field review.

Please return ACCEPT / CHANGE / BLOCKED only for:
1. New explicit 0.2 contract discriminator and NEW exact hash vectors.
2. Full closed shape + outer/outstanding/original/nested tuple and receipt checks.
3. retryable:true only service unavailable/unknown commit, exact commit states,
   malformed/unknown response rejection without false commitment inference.
4. Alternative-scenario wording and already approved UUID reuse at durable seal.

27 local schema/model tests pass; these are not an actual store/server/Auth run.
All actual implementation cases remain NOT RUN. Existing source/manifest,
native package/device, authorization and physical gates remain open.

Optional local reproduction using ALREADY installed Ajv8/ajv-formats via NODE_PATH:
node --test docs/integration/cha-execution/manual-result-0.2.test.cjs
No install permission granted; report unavailable tools rather than changing app
dependencies. reference.cjs is TEST-ONLY, no runtime/client implementation.

Do not auto-upgrade/relabel old outbox content or claim old Dart vectors prove
0.2 parity; contract is hashed and changes the digests. Supply actual new vector
results with source/hash/scope, not an email draft or another receipt promise.

No implementation, deployment, provisioning, database/RLS/RPC, formal adoption,
flashing or powered tests authorized. Package prepared, not sent externally.
