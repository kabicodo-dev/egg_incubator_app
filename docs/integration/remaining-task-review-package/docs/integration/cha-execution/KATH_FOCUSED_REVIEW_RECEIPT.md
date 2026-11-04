# Kath focused C-02 review — received findings and closure impact

Date: 2026-10-30. User supplied the Kath-attributed review:
`Kath-C02-Provisional-Focused-Review-2026-10-30.md`, SHA-256
`4473813552ef21a77fe57296f89fb7843a3b4f1ad19990c3e596b70f66e162e0`.

## What is now evidenced

All five input hashes in the review matched this checkout's actual files at
receipt. Exact copies were preserved under `kath-focused-review-inputs/` before
the current ledger was updated. Later ledger edits need not match the reviewed
snapshot; the three schema/contract/example input files remain unchanged.

The review directly covers the historical provisional schema and all fourteen
examples. Its overall outcome is CHANGE, not compatible/approved. The document
says prepared for Kath to review/send, not a signature; receipt from the user
establishes review delivery, not independent authentication of every personal
proposal or exact shared-contract sign-off. Do not request this review again.

Independently reproduced: all fourteen compact UTF-8/LF message lengths. Command
content lengths are START 314, STOP 243, STATUS 237 bytes; all exceed the reported
119-byte incoming-content capacity of serialLine[120] including NUL. That Uno
capacity is attributed to Ally's report, not freshly source/build verified here.
Outgoing telemetry above 119 bytes does not establish an incoming RX failure.

Kath's Dart probe is reported evidence, not rerun in this session: nested telemetry
decodes unavailable, ACKs lose ID/success correlation, status/error are unknown.
Outgoing commands being unknown to an incoming parser is not itself a parser bug;
the sender incompatibility is separately source-reviewed. No full JSON Schema
validation or fourteen-fixture compatibility pass is inferred from JSON parsing.

## Findings and specific decisions now received

| D01–D06 area | Received review outcome | Still open |
|---|---|---|
| D01 common protocol | BLOCKED; no silent alias/translation between payload.action, numeric START and START_BATCH/CONFIRM | Ally supersession plus matching source/catalog/patch/fixtures, then owner acceptance |
| D02 identities | Supports Android-origin original UUID/16-hex identity and durable pre-dispatch intent; source owns transition/epoch/sample identity | Final encoding, persistence/recovery and exact source mapping |
| D02 operation/recovery | Pending after ACK; unknown timeout remains unresolved; recovery must resolve lost ACK without requiring ACK arrival first | STOP table, pending-Start lifetime/cancel semantics, original outcome vs current-state query |
| D03 bounds | Concrete 14-example byte counts; proposes LF, strict decoding, bounded accumulation/discard-through-LF | Directional maxima/stack/service/layout proof; no approved numeric buffers |
| D04 cloud/local trust | Supports scoped non-anonymous cloud enrollment, separately controlled binding, protected Android storage and offline recovery initialization | Plugin/SDK/key lifecycle and controller authorization mechanism; login is not enrollment |
| D04 retention | Supports null/no HTTP-only release | Exact bounded loss/layout/service policy not accepted by this review |
| D05 time/validity | Unknown source time remains unknown; reported operation, independent physical feedback and clock confidence are independent | Profile approver, outage/elapsed continuity, actual freshness/skew/expiry policies |
| D06 results | Supports amendment A/B/C direction and all four Ally conditions; result alone leaves Active guard intact | Exact result/API/hash/schema/transactions and explicit lifecycle finalization/admission rule |

Kath proposes local draft/save-failure/pending-validation rules; immutable action
after submission; atomic result/outbox and receipt/mapping commits; separate
saved/sync/conflict/controller/lifecycle labels. These are documented design
positions, not implemented or accepted concrete storage/API/package revisions.

## Corrections the replacement contract must address

- Historical backend-before-Start allocation conflicts with offline original
  Android intent; USB fallback/ESP8266 publishing text is not the selected route.
- A shared numeric v:1 is not proof that incompatible envelopes are compatible.
- Schema needs actual field precision/byte maxima, manifest/quantity/profile/actor
  binding, retained transitions and original outcome recovery—not just current state.
- Provisional fractional UTC and DB-02 whole-second canonical evidence must be
  reconciled without silent rounding or hash changes.
- Self-declared VERIFIED and latch bits do not establish independent physical
  feedback. Conversely, unknown UTC must not forbid a truthfully labelled
  controller-reported operation solely because it lacks wall time. Agreed elapsed
  day display still needs source continuity and outage rules.

Do not change the historical input files in place or enlarge buffers to hide a
failed fixture. Draft the replacement against a selected feasible source packet
and preserve explicit version/schema rejection and approval gates.

## Task effect and actual checks

This supplies Kath's exact C-02A schema/example review evidence. It is a valid
CHANGE review outcome; review does not have to mean approval. The remaining
gap is Ally's response to these same historical schema/example bytes, not another
Kath general audit. C-02A also requires sample-message validation; Kath explicitly
did not rerun full JSON Schema validation. Earlier validation remains historical
evidence until its provenance/applicability is established.

C-02B's comparison output remains performed and its C-02A prerequisite remains
open. C-02C cannot finalize unselected fields. DB-IMP-01 and physical tests are
not unblocked by this review. No published task status is changed in this receipt
update; no full task is newly Completed. Existing seven completed tasks stand.

`review-kath-focused.cjs`: five local evidence checks passed; records raw review
hash, five exact input snapshots, independent fourteen-message sizes and scope
boundaries in `kath-focused-review-validation.json`. These are document/size
checks only. No Dart probe, Flutter/firmware build, JSON Schema validator,
database operation, deployment, flashing or powered test was executed here.
