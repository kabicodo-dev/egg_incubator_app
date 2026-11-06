# S1 — supplied local verification transcript excerpts

Recorded for CURRENT:INT-IMP-01 on 2026-10-29 by Mary Charlyn.
Source: preceding local implementation tool-output transcript and user-supplied
`#mary-integration-report` summary. **Not rerun during this evidence-only update.**
This file transcribes selected output lines; timings and terminal prefixes are
omitted. It is not an original complete machine log or a new execution result.
No standalone original log artifact was found in the inspected repository.

Source context: `cha-branch2`, HEAD
`c7a26cfcaa619708aff4f793e8068ee176a6cf58`, with uncommitted/untracked local
implementation/tests. HEAD alone does not reproduce those additions. Preserve
the working files with this evidence; no new implementing commit is claimed.

## S1-node — supplied combined run

```powershell
node --test --test-timeout=15000 "test/integration/int_imp_01.test.cjs" "test/backend/bridge_sync_http_test.mjs" "test/backend/bridge_monitoring_test.mjs"
```

Selected successful test names from the supplied output:

```text
✔ updated objective: Chicken profile identity propagates without invented numerical targets
✔ updated objective: Duck profile identity propagates without invented numerical targets
✔ updated objective: Quail profile identity propagates without invented numerical targets
✔ updated objective: unknown species/profile identity is rejected, never defaults to Chicken
✔ updated objective: temperature and humidity have independent actual-value/freshness states
✔ updated objective: stale remote reading stays stale despite recent cloud receipt
✔ updated objective: invalid RTC, unconfigured threshold or future clock does not claim live data
✔ updated objective: source egg-turning diagnostic is recognized but never fabricated into a synced event
✔ updated objective: source lockdown stage is recognized for all species, not inferred from relay off
✔ updated objective: sensor errors have diagnostic data without claiming source identity or safety
✔ updated objective: a sensor error does not erase a separately reported lockdown stage
✔ updated objective: condition notification data is stable and controller-reported, not push delivery proof
✔ real core strict JSON rejects duplicate/escaped/nested keys, overflow numbers and trailing text
✔ real core accepts all seven existing candidate request shapes without changing fixtures
✔ real canonical core matches recorded DB-02 fingerprint and ignores transport metadata
✔ actual loopback HTTP records Start, duplicate and changed-content conflict via real handler/ports; DB stub only
✔ actual HTTP default source gate refuses valid-looking controller evidence before persistence
✔ actual HTTP missing/forged credentials and anonymous user are denied against Auth boundary stub
✔ actual HTTP registry/session denial blocks writes and receipt lookup even for otherwise accepted Auth fixture
✔ actual HTTP wrong source scope is denied before source adapter/store
✔ actual HTTP source/body mismatch and unsupported split evidence cannot persist
✔ actual HTTP duplicate JSON keys, invalid dates, wrong types and invented event kinds are rejected
✔ actual HTTP stream bounds and method/media handling fail without storage writes
✔ actual HTTP Stop and farmer zero completion remain separate accepted candidate facts
✔ actual HTTP readings use source values and source fingerprint, not profile targets
✔ actual HTTP returns committed waiting/conflict receipts distinctly from rejected content
✔ real HTTP socket response loss after handler completion reconciles same stored receipt (storage stub)
✔ upstream persistence failure and malformed receipt are sanitized, never false success
✔ actual reconciliation validates request IDs and nested receipt scope before echoing data
✔ real Supabase ports refuse main-project URL and require explicit isolated configuration
✔ real Supabase ports do not turn a missing RPC/registry into a fake allowed result
✔ INT-08 source snapshots and fixture namespaces are pinned, not selected
✔ INT-08 source pinning permits checkout line endings, never semantic source drift
✔ INT-08 review references cannot open real hardware or claim an active catalog
✔ INT-08 all 20 reference frames retain exact payload byte counts across checkout line endings
✔ INT-01 byte fragmentation at every boundary preserves each reference frame
✔ INT-01 coalesced reads and one-byte reads preserve order
✔ INT-01 exact test bound succeeds; overflow suffix is discarded through LF
✔ INT-01 invalid ASCII/NUL input is not surfaced as a valid frame
✔ INT-01 disconnect clears partial bytes; reconnect does not join old suffix
✔ INT-02 repeated read-only status queries never actuate or create outbox events
✔ INT-03 explicit mock Start then Stop; controller report differs from cloud lifecycle
✔ INT-03 ACK alone remains unknown; it is not a Running report
✔ INT-03 manual zero hatch count does not dispatch a physical Stop
✔ INT-04 lost ACK with event/report still records one Start
✔ INT-04 lost entire outcome, app restart and reconnect recover original retained mock event
✔ INT-04 older retained Start cannot override newer current mock Stop
✔ INT-04 replayed original command result after Stop is not current Running evidence
✔ INT-04 wrong controller on reconnect cannot bind, Start or reassign original local events
✔ INT-05 same logical command replays outcome; changed content conflicts
✔ INT-05 a different Start identity cannot replace an active batch; wrong batch Stop rejected
✔ INT-05 repeated local event has one outbox entry; changed same-key content is retained as conflict
✔ INT-06 failed initial local commit prevents command dispatch
✔ INT-06 Running report plus failed event save stays distinct; source recovery repairs mock outbox
✔ INT-06 offline event checkpoint survives reopen; failed upload preserves immutable outbox
✔ INT-07 response lost after mock commit reconciles same receipt with one session
✔ INT-07 identical duplicate does not reopen completed batch; same ID changed count rejected
✔ INT-07 uploader/phone receipt changes do not rename an existing mock source fact
✔ INT-07 missing predecessor persists waiting receipt; no invented session
✔ INT-07 existing unrelated Active record conflicts without automatic completion or reassignment
✔ INT-07 fake revoked-authorization gate denies submission and receipt reads, preserving local events
✔ INT-07 mismatched receipt content cannot mark synced; no unsigned Uno release
✔ INT-07 lower receipt revision ignored; same revision changed receipt rejected
✔ INT-08 read-only export is portable labelled JSON with original wire bytes and candidate DB fixtures
ℹ tests 64
ℹ suites 0
ℹ pass 64
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
```

Scope: 33 mock tests + 31 backend HTTP/core/monitoring tests. Fake transport uses
logical controller calls; FakeCloud is the test backend. The HTTP handler uses
real loopback sockets but Supabase Auth/RPC storage and the admitted fixture
adapter are stubs. These are separate software dry-run layers, not one Android →
HC-05 → pinned firmware → real Supabase end-to-end test. No hardware was opened.

## S1-parser — supplied targeted parser run

```powershell
$env:CI='true'; & "C:\EggIncubator\flutter\bin\flutter.bat" test --no-pub "test/int_imp_01_parser_compatibility_test.dart" "test/arduino_protocol_test.dart"
```

Selected output text, with file prefixes omitted:

```text
INT-08 actual Flutter parser / unselected review fixtures all compact t-family review frames remain unsupported today
INT-08 actual Flutter parser / unselected review fixtures corrected status ACK does not imply current parser success
INT-08 actual Flutter parser / unselected review fixtures corrected sensors envelope does not populate actual incubator values
INT-08 actual Flutter parser / unselected review fixtures hello and event review families have no implemented decoder
INT-08 actual Flutter parser / unselected review fixtures kit cannot assert a selected active firmware or catalog
00:02 +20: All tests passed!
```

Reported total: 5 characterization tests + 15 existing protocol tests. A passing
characterization of an unsupported message is **not compatibility PASS**. No full
Flutter suite, release build, Android transport or new decoder is evidenced.

## S1-static — supplied checks, not new runs

Four `node --check` invocations returned success without output for:
`supabase/functions/_shared/bridge-sync-core.mjs`,
`supabase/functions/_shared/bridge-sync-supabase.mjs`,
`supabase/functions/_shared/bridge-monitoring.mjs`, and
`supabase/dev/serve-bridge-sync.mjs`.

Supplied `git diff --check` returned success, with an LF/CRLF warning for the
existing deploy workflow; untracked files were outside that check. Deno was
unavailable; no Deno type/runtime check is inferred. Earlier first-run fixture/
socket failures were reported fixed by Mary Charlyn; their original failure logs
were not retained here. The final matching cases are in S1-node above.
