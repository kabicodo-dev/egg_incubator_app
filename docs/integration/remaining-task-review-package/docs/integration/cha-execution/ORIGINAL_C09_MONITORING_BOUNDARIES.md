# ORIGINAL:C-09 — stale readings/disconnection: independent boundary verification

**Owner:** Mary Charlyn (Cha/Mary) · **Date:** 2026-10-30 · **Priority:** P1.
**Status:** Partial → Partial; automated verification progressed, full criterion
not met. No C-02 choice, numerical freshness threshold or source schema selected.

## Why this can proceed while C-02 is parked

The source task requires Fresh/Stale/Unavailable/Unknown classification, with
measured cadence from Ally. Existing backend helper `remoteReadingStates` is
independently callable with explicit policy inputs; it uses no network, DB or
controller. We can test its existing behavior without declaring a particular
cadence, source UTC, wire format or UI policy approved. All 5000/1000/etc values
in these tests are arbitrary TEST inputs, not recommended operating thresholds.

The Superseded task is deliberately not executed. Kath's UI and Ally's firmware
are not changed. Scope is existing backend/helper unit verification, not live
readings or new control behavior.

## Actual changes and results

Added `test/backend/monitoring_boundary_test.mjs`, testing the actual unchanged
backend helpers, not a replacement mock classifier. Added a read-only helper
characterization script and retained its findings in monitoring-boundary-probes.json.

Commands actually executed:

```powershell
node --test --test-timeout=15000 --test-reporter=tap --test-reporter-destination=docs/integration/cha-execution/monitoring-boundary-targeted.tap test/backend/monitoring_boundary_test.mjs
node --test --test-timeout=15000 --test-reporter=tap --test-reporter-destination=docs/integration/cha-execution/monitoring-backend-regression.tap test/integration/int_imp_01.test.cjs test/backend/bridge_sync_http_test.mjs test/backend/bridge_monitoring_test.mjs test/backend/architecture_alignment_test.mjs test/backend/monitoring_boundary_test.mjs
node docs/integration/cha-execution/probe-monitoring-boundaries.cjs
```

- **Targeted: 27/27 passed**, zero failures/skips/cancellations.
- **Regression: 110/110 passed**, zero failures/skips/cancellations, INCLUDING
  those 27 tests. Not 137 distinct tests; historical 83-test run remains historical.
- Characterization probes executed, preserving production source hash
  `863447ee1c8a869cff380a7d55e99d6ce5ae207b9bf8237dc849efbdb0b434ec`.
  Probe observations are limitations, not additional accepted safety cases.

No production module, Flutter/Arduino source, Supabase draft/migration, deployment,
credential, database row, powered setup or old source contract was modified.

## What the tests demonstrate

| Boundary | Actual local evidence |
|---|---|
| Freshness exact threshold | At synthetic threshold remains fresh; one millisecond older becomes stale. No policy default invented |
| Missing/invalid policy | Omitted, nonfinite/coerced or negative relevant budgets produce unknown age, not live data |
| Independent metrics | Invalid temperature does not hide valid humidity, and vice versa |
| Unavailable vs unknown age | Invalid/missing/nonfinite values stay unavailable; otherwise valid metric with no trustworthy age stays unknown_age |
| No numerical coercion/default | Numeric strings/Booleans are not sensor numbers; missing values do not become zero or profile setpoints |
| Original acquisition time | Recent phone/server receipt or reconnect does not refresh an old acquisition |
| Source-clock validity | Unknown/invalid time gives no live value; future time beyond explicit synthetic skew stays unknown |
| Last-known distinction | Stale/unknown_age has null live_value; diagnostic last_value is separate and must not be displayed as live |
| State/connection separation | Cloud Active/relay/stage flags do not validate metrics; helper never claims Stop/Start/Completed/admission |
| Actual input guard | Existing validateSubmission rejects impossible source calendar date and missing batch association in real candidate fixture |
| Stable pure behavior | Repeat classification is stable; neither input nor policy mutated |

These are type/time/freshness unit results, not approved biological sensor ranges,
sensor calibration or authentication. A zero synthetic reading tests presence,
not safe incubation conditions.

## Explicit caller/composition limitations, not claimed fixed defects

1. The helper alone uses Date.parse; an impossible 2026-02-30 normalizes and can
   appear fresh. Existing submission validator strictly rejects that date, newly
   verified here. Every future caller must pass the strict input boundary; this
   work does not prove the full monitoring pipeline uses it correctly.
2. The helper itself accepts metrics without device/batch/sample identities.
   Existing submission validator rejects missing batch, but actual authorized
   source-to-batch selection still needs selected source/registry/mapping evidence.
   Do not choose latest Active or treat pure classification as source acceptance.
3. connected:false does not change per-metric age classification. That is not
   physical Stop. UI must compose a separate disconnected/unknown-current-state
   dimension and label last-known readings non-live as applicable. No real
   transport/widget behavior is proved by toggling a synthetic object field.

Source helper is currently a domain function, not a verified secure ingress,
source selector, firmware state machine or transport watcher. These observations
do not establish a production exploit or justify silently rewriting current code.

## What is still needed for full task completion

- Attributable measured acquisition/transmission cadence and delay information
  for the selected source; existing reported intervals are useful but not fresh
  measured transport evidence. Do not invent a threshold from our TEST constants.
- Exact accepted freshness/skew/unknown-clock/late-acquisition policy, including
  source continuity and reconnect behavior, with relevant Kath/Ally input.
- Approved source association/authorization and actual monitoring caller path.
- Actual connected/disconnected + metric-state composition acceptance tests in
  the compatible app/backend, not inferred physical state from a cloud receipt.

The software boundary test portion is performed. ORIGINAL:C-09 remains Partial.
OCT26:C-09 and related real-time/integration tasks are NOT completed by these tests.
All other task statuses remain unchanged: **7 Completed, 9 Partial, 25 Not started,
1 Superseded**; no new full task or physical/security readiness claimed.
