# Ally C-02 review — receipt and scoped closure assessment

**Date:** 2026-11-02. **Owner:** Mary Charlyn (Cha/Mary).
User supplied Ally-attributed `Downloads/c-02.txt`; preserved byte-for-byte as
[received response](received-ally-c02-20261102.txt), SHA-256
`9751a0ee6bae3da807798c6f047589ca1b05349a466e6e0aa3f808ff50472436`.
Receipt is user-delivered review evidence, not independent reviewer authentication.

## Outcome

Ally's exact-input review is **RECEIVED — REQUEST CHANGES**. Do not request another
general review of these same provisional bytes. Exact shared-wire acceptance is
still BLOCKED. Ally explicitly has not issued a corrected replacement contract.
Numeric START is implemented in his candidate; START_BATCH/CONFIRM is not. The
provisional attachment itself contains START/STOP/STATUS, not START_BATCH/CONFIRM.
This supersession answer is received, not joint selection of a source/protocol.

## Actual verification

Run `node docs/integration/cha-execution/verify-ally-c02-receipt-20261102.cjs`.
Six local integrity/review-boundary checks passed. Machine evidence is
[verification JSON](ally-c02-receipt-verification-20261102.json).

- All three current provisional input hashes equal the full hashes in Ally's
  response and Kath's preserved review/snapshots.
- The existing validator was rerun with Node v26.4.0, already installed Ajv 8.17.1
  and ajv-formats 3.0.1: **14 examples, 65 schema negatives, 11 malformed/unsafe
  cases PASS**, plus the validator's CRLF/whitespace/two edge checks; exit 0.
  [New output](ally-c02-schema-revalidation-20261102.txt) preserves this execution.
- Current validator SHA-256 is
  `40c7bd4444612c317f72058ad6fb74c0710d0a95098bd67fab352bd235395e63`.
  It differs from the historical 30 Oct fingerprint. It was already modified on
  entry; it was not edited or reverted in this work. This is a new execution of
  current bytes, not a claim to reproduce the historical validator revision.
- Fingerprinted inputs remained unchanged during the run. Historical logs remain
  untouched. Schema validity does not demonstrate firmware compatibility.

## C-02A — review-only criteria evidenced

The task card states: deliver a provisional contract, have its schema reviewed by
Ally and Kath, and validate sample messages. It lists no linked task prerequisite.

| Criterion | Evidence | Assessment |
|---|---|---|
| Provisional contract/schema/examples prepared | Existing three unchanged provisional files | Demonstrated, not adopted |
| Both reviews cover the same input revision | Kath's preserved review/snapshots; Ally's full input hashes; new integrity checks | Demonstrated at delivered-review level; both outcomes CHANGE |
| Sample validation | Fresh local execution and retained output | Demonstrated for shape only |
| Gaps explicit | Both reviews; incompatible envelopes, missing identities/STOP/recovery/time, incoming-frame limits | Demonstrated; no fix inferred |

**Eligible for Completed at preparation/review scope.** A CHANGE outcome can
satisfy a review requirement; firmware compatibility is not this task's stated
acceptance. This assessment does not automatically publish a portal status or
recompute portfolio counts. The prior Partial records remain dated history.

## C-02B — comparison performed; dependency qualification remains

The existing [A-01 comparison](ALLY_ZIP_C02B_REVIEW.md) records all F-01–F-10:

| Finding | Current disposition including the new response |
|---|---|
| F-01 source availability | Full candidate identities now supplied; matching raw source delivery and joint selection remain separate |
| F-02 transport | HC-05/Android remains selected architecture; source review is not a transport pass |
| F-03 RTC | Source UTC/original wall time cannot be invented |
| F-04 independent safety | No fuse/watchdog/electrical clearance demonstrated |
| F-05 SRAM | Incoming 119-content-byte limit and reported 266 B headroom constrain redesign |
| F-06 physical validation | ACK/RUNNING/latch state is not independent physical proof |
| F-07 sensor validity | Plausibility/validity is not calibration, freshness or stuck-sensor detection |
| F-08 RUNNING | START confirmation and TURN_NOW in-flight reports must remain command-specific |
| F-09 protocol variants | Numeric id/cmd and provisional payload.action envelopes are incompatible despite v:1 |
| F-10 older copy | Historical/local source is not silently promoted to selected or flashed source |

C-02A's previously missing review is now supplied and its narrow criteria assessed
above. C-02B also lists **OCT26:A-01** as a prerequisite. Receipt of A-01's report
was previously recorded, but this turn does not independently certify that external
task's full completion. **Retain C-02B Partial pending prerequisite confirmation.**
Do not ask for another A-01 audit: reconcile its existing completion evidence only.

## Corrections and boundaries

- Validator absence is Ally-working-tree-specific; it exists here.
- 314/243/237 content bytes become 315/244/238 with one LF terminator. The 119-byte
  limit is incoming application content, not a TX or AVR ring whole-frame limit.
- Ally's uint32 storage does not prove the full unsigned range is accepted by a
  signed-long command parser. Freeze admitted numeric ranges using matching raw
  source and boundary fixtures; do not infer them from the storage type alone.
- A numeric batch ID is not a global identity, authorization credential or original
  manifest. Profile/quantity/actor metadata needs explicit verified mapping and
  collision/reuse handling; never attach telemetry to latest Active by guess.
- Exact flashed firmware remains UNKNOWN. Current local source is not proven to
  equal Ally's reported `7106ebfe…` candidate.
- No protocol family was selected, historical schema overwritten, source adapter
  enabled, Q06/Q07 policy changed, or Q12 permission expanded. No production code,
  database, firmware, serial, hardware or browser-storage operation occurred.

## Next decision, not another general review

Use the [focused decision request](../../contract-review/C02_Wire_Family_Decision_Request_2026-11-02.md).
Record the actual Mary/Kath/Ally response against one identified candidate; do not
treat preparation of that request as delivery, a vote, or implementation consent.
