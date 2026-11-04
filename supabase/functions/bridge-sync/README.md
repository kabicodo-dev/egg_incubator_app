# Bridge sync — local implementation slice

[Backend directory guide](../../README.md) · [Supporting tools](../../dev/README.md) · [SQL draft index](../../drafts/README.md)

**Owner:** Mary Charlyn (Cha / Mary) — backend and integration.
**Status:** real handler/adapters implemented locally; NOT DEPLOYED; source
acceptance disabled; PostgreSQL persistence RPCs NOT IMPLEMENTED/TESTED yet.

This is a code runbook, not a new wire contract or another decision round.
Uses existing DB-02 candidate request names and table terminology. Updated
objectives include Chicken/Duck/Quail software profile identity and monitoring;
no new numerical incubation/safety targets or physical validation are implied.

## Runnable code and checks

From repository root, Node26.4.0 was used (no npm dependencies installed):

```powershell
node --test --test-timeout=15000 test/backend/bridge_sync_http_test.mjs test/backend/bridge_monitoring_test.mjs
node supabase/dev/serve-bridge-sync.mjs
```

The second command opens **127.0.0.1:8787 only**. No existing `.env` is loaded.
Without separately supplied isolated Supabase environment settings, requests fail
closed with 503. It does not simulate a successful server or database. Stop with
Ctrl+C. `BRIDGE_PORT` may select another validated port; source acceptance remains
disabled regardless of port or credentials.

| File | What is actually implemented |
|---|---|
| `../_shared/bridge-sync-core.mjs` | Strict bounded HTTP input, duplicate-aware JSON, candidate schema/type/ID/time validation, canonical semantic fingerprint, receipt/reconciliation checks and sanitized errors |
| `../_shared/bridge-sync-supabase.mjs` | Actual fetch adapters to Supabase Auth `/auth/v1/user` and named RPC boundaries; non-anonymous subject/session/issuer/audience/expiry checks after trusted Auth verification; explicit isolated-target URL validation; no main-project usage |
| `../_shared/bridge-monitoring.mjs` | All three species identity mapping, independent reading validity/age states, known Combined diagnostic descriptions, stable scoped condition-notification data (not push delivery) |
| `index.ts` | Candidate Deno Edge entrypoint; not run/deployed because no Deno/runtime/test stack is available |
| `../../dev/serve-bridge-sync.mjs` | Actual Node loopback HTTP adapter around the shared handler, including testable socket loss |

Production Flutter/parser/firmware are unchanged. No Start/Stop command operation
exists in the cloud handler. Controller event uploads record past evidence only.
Historical one-shot egg-turn and lockdown diagnostics remain **not sync eligible**
because current source lacks the required durable batch/event/sample evidence.
No fabricated IDs or clock values are added to make them pass ingestion.

## Real Supabase boundary still needed

Supabase config is server environment only: isolated `SUPABASE_URL`, its public
client key in `SUPABASE_ANON_KEY`, and explicit `BRIDGE_TEST_PROJECT_REF` for a
non-local test project. Never paste keys/tokens into logs, fixtures or portal.
Main project `suopuhgtwyqkpupzvdng` is refused by this local integration slice.
Do not change that guard to meet a test deadline. Local Edge container networking
and actual Auth issuer/session claims need real-stack verification; the Node
loopback adapter is not proof that Deno environment/network settings work.

Required database interfaces are explicit **unimplemented** dependencies:

- `bridge_sync_authorize_v1`: current non-anonymous Auth user/session + private
  installation/device binding; revoked or wrong scope denied, never self-enroll.
- `bridge_sync_ingest_v1`: atomic authorization recheck, canonical evidence/content
  verification, unique external-batch/event/sample mapping, legal dependencies/
  projection, stable receipts/revisions. **Must not trust the caller-provided hash
  or prior Edge checks**; direct RPC invocation must not bypass validation/RLS.
- `bridge_sync_reconcile_v1`: authorized scoped lookup with exact typed receipt
  identities/current revisions and truthful mapping; no physical commands.

Missing RPC/registry/network fails closed; no legacy open-table fallback exists.
The original local HTTP slice generated/applied no SQL. Subsequent DB-IMP-01 adds
an [offline disabled-registry draft](../../drafts/DB-IMP-01_disabled_registry.sql)
outside automatic migrations; it is not parsed/executed and implements no RPCs.
See its [patch/test/blocker report](../../../docs/integration/DB-IMP-01_Report.md)
and [new 70-test TAP log](../../../docs/integration/logs/2026-10-29-db-imp-01-node.tap).
No authorized isolated running instance is available for actual verification.
Next database implementation
must be reviewed and run only against the authorized isolated instance, preserving
existing main schema/History. No production migration or deployment is authorized.

## Evidence and remaining work

The authoritative dated status and message-family matrix are in
[INT-IMP-01_Evidence.md](../../../docs/integration/INT-IMP-01_Evidence.md).
[Supplied verification excerpts](../../../docs/integration/logs/2026-10-29-supplied-checks.md)
record 64 Node / 20 targeted parser checks. These were **not rerun during the
2026-10-29 evidence-only update**. Existing shared fixtures and implementation
are unchanged. A passing unsupported-parser characterization is not a compatible
decoder or completed OCT26:TEST task.

### Software dry-run procedure before any physical test

Run from repository root in the development checkout, without production credentials
or serial/Bluetooth connections. Commands below are instructions, not new results:

```powershell
node --test --test-timeout=15000 test/integration/int_imp_01.test.cjs test/backend/bridge_sync_http_test.mjs test/backend/bridge_monitoring_test.mjs
$env:CI='true'; & "C:\EggIncubator\flutter\bin\flutter.bat" test --no-pub "test/int_imp_01_parser_compatibility_test.dart" "test/arduino_protocol_test.dart"
```

Use your installed SDK path if different. First suite uses fake transport/controller
and FakeCloud, temporary host checkpoints, positive and negative/retry fixtures.
Backend suite separately exercises actual HTTP/core with fixture source adapter
and stub Supabase Auth/RPC. It does not connect the fake Bluetooth controller to a
real database or to Android. Tests must never import the fixture adapter into the
Edge entrypoint to enable ingestion.

For a new run, retain full output plus exact command, date, branch/HEAD and local
patch revision; attach log links to the single ledger. Expected case classes:
read-only query; explicit logical Start/Stop; ACK-only unknown; failed local commit;
offline replay without new Start; wrong-source/auth/scope rejection; malformed
JSON/source/body rejection; identical duplicate vs changed-content conflict;
response loss/reconciliation; stale readings and receipt revisions. Assign every
failure to one owner before another acceptance attempt. Do not change fixtures or
disable gates merely to obtain green output.

This supplied mock dry run satisfies only the mock-layer record. After the exact
producer/catalog and compatible Android patch arrive, pin their same revision and
run a matching software adapter dry run before requesting device acceptance. Real
isolated RPC/Auth/RLS/transaction/concurrency runs require the authorized running
test environment; record its identifier, migrations/adapter revision and sanitized
logs without tokens/keys. Missing environment is NOT TESTED, never stubbed PASS.
No physical test is authorized by completing these steps.

### Current limitations

The actual handler and Supabase HTTP adapter run in loopback tests, but the
Supabase Auth and RPC responses/storage are **boundary stubs**. The token fixture
is generated at runtime and not signed by Supabase. These tests do not prove JWT
signature verification, real Auth/registry/RLS/revocation, SQL atomicity or cloud
integration. They do test which requests reach persistence, canonical hashes,
errors, response scope and receipt handling in the implemented handler.

The first backend run exposed a malformed wrong-scope fixture and a lost-response
socket that did not close after its request stream ended. Both were corrected:
the scope fixture now has a consistent event/device key, and the loopback fault
hook explicitly destroys the response/socket. Subsequent full results are recorded
in `docs/integration/INT-IMP-01_Evidence.md`; no timeout was relabelled a pass.

User selected **code locally first**, **reuse the eight existing kit files**, and
confirmed Ally's active sketch/catalog is **not yet available**. Local Docker
engine is unavailable and hosted smarthatch-test was observed INACTIVE. Neither
was started/resumed. Only request to Ally: exact active `.ino`, matching catalog,
and implementing commit/paths; no D01–D06 round.

Next smallest steps:
1. Run this handler against a separately authorized, running isolated Supabase;
   implement/test the three database boundaries and real Auth/RLS tests there.
2. Pin Ally's actual source/catalog and add the exact reviewed source validator;
   `unavailableSourceAdapter` currently rejects all submissions, including farmer
   completion, so another lifecycle path cannot be enabled accidentally.
3. Kath uses the candidate HTTP errors/receipts and characterization fixtures to
   connect the real Android outbox/decoder, without guessing source IDs or epochs.
4. Add reviewed profile/time limits, source turning/lockdown/error schemas and
   notifications delivery only when producers/ownership permit. Condition helpers
   are not an implemented background push service or uninterrupted cloud feed.
