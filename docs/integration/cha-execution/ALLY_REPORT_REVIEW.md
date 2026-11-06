# Ally's report export — are the outstanding backend questions answered?

## Result: useful progress evidence, but not all questions are resolved

Reviewed **all 26 reports covering 23 outer task IDs** in
`SmartHatch-all-reports-2026-10-30-1.json`, exported
`2026-10-30T02:38:43.020Z`. All are attributed to Ally. Source SHA-256:
`09309a30346acd04b14f4db058d0aa0019dc1a77bbb748535f0b9541b7745da8`.

The JSON is structurally a valid portal report export. It is not a source-code,
full-contract or raw-build-log bundle. Reported results are attributed evidence,
not tests rerun by Mary/the reviewer. The original export remains unchanged and
was **not imported** into browser reports. No task status or sign-off is changed.

## Important filing problems before import

| Report ID | Outer JSON assignment/status | Actual body | Interpretation |
|---|---|---|---|
| `R-mvuclz61hgzq` | OCT26:HW-01, RTC identification, Completed | CURRENT:HW-IMP-01, parser/START/STATUS patch, explicitly PARTIAL; STOP/auth/RTC/durable recovery blocked | This is not evidence that an RTC chip was identified. |
| `R-mvucw1mbzn44` | OCT26:HW-02, Bluetooth identification, Completed | CURRENT:HW-IMP-02, durable recovery host model/design; no production journal/RTC/auth | This is not evidence that an HC-05/module/firmware was identified. |

These two otherwise useful bodies appear to have been saved under the wrong task
selection/status. Preserve the original records; ask Ally to correct their filing
with provenance in their working portal rather than rewriting or deleting their
reports here. Do not infer confirmed RTC/Bluetooth from the latest outer labels.
Other rows also have Not started labels with bodies describing prepared docs:
read their scope, not just the status badge. ORIGINAL:A-06's Completed badge is
not a physical-Start pass: its body explicitly limits the results to host tests.

## D01–D06 comparison

| Decision/question | What Ally's supplied text actually provides | Still required | Result |
|---|---|---|---|
| **D01: canonical source/catalog** | A-01/A-02 identify `ally-branch3`, HEAD `80971f902d5634f7fed78ff073fcb78fa31be460`, Combined sketch; later HW-IMP bodies supply patched source SHA-256 `7106ebfe01d037c95766cd51c43b43fa02f92b922fc5a180770fd27b3822c5ec`. They explicitly disclose an uncommitted patch and an app-facing source gap. | Exact source/patch files, matching complete catalog/manifest/toolchain and a deliberate same-packet choice by owners. Local observation/reporting is not joint selection or flash identity. | **Partially documented; selection unapproved.** |
| **D02: lifecycle, identities, recovery** | START ACK vs RUNNING, duplicate/changed-content/wrong-batch/lost-ACK/split cases and LF overflow drain are reported host-tested. STATUS is read-only in the described fixtures. | STOP is explicitly unimplemented. A-04 says v1 telemetry lacks device_id, batch_id, sample_id, measured_at and timestamp_valid. Exact original event/sample/manifest identities, complete schemas and production retained recovery are not supplied/implemented. | **Partial host evidence; contract gaps remain.** |
| **D03: real build/byte/memory bounds** | Compile/link and avr-size outputs are reported: pre-patch 21,142 B flash / 1,781 B SRAM; patched 21,164 B / 1,782 B, only **266 B** static headroom; source/HEX/ELF hashes listed. | Need actual build logs, pinned toolchain/libraries, maximum permitted RX/TX fixtures, byte bounds/delimiter treatment, stack/service-budget assessment on the selected packet. A low-memory linked build is not proof of safe worst-case runtime capacity. | **Build evidence reported; bounds/feasibility acceptance not closed.** |
| **D04: offline authority and retained-evidence policy** | HW-IMP-01 explicitly says authorization/live admission unimplemented. HW-IMP-02 proposes a host model: 4 × 64 B journal at 0x0200–0x02FF, CRC/commit marker, 64 cut offsets, no overwrite when full. | Actual feasible local provisioning/authentication/revocation design; production journal; exact retention/full/corrupt/accepted-loss policy; explicit response to Mary's retention_ack:null/no HTTP-only release position. A proposed model is not an approved loss guarantee or production durability. | **Blocked/unapproved, with useful design preparation.** |
| **D05: profile/RTC/time/freshness** | No RTC implementation; wall_clock_valid=false/monotonic-only is reported. Profile signature, physical RTC identification/wiring/timekeeping and safety remain pending. Pilot is explicitly NO-GO. | Named profile approver's actual values/signature; real RTC/module information; agreed invalid-clock/outage/freshness policy and attributable source timestamps. Implementation literals are not approved incubation values. | **Explicitly blocked, not answered with approved values.** |
| **D06: source/cloud mapping and independent completion** | A-03 prepares a C-02 handoff; A-04 proposes choices A/B/C (v1, v2, or v1+envelope), with D-01…D-10 and Cha/Kath sign-off pending. Host recovery/model work helps define limitations. | Exact source-to-backend fields/receipts/dependencies, complete proposal files, and Ally's explicit ACCEPT/CHANGE/BLOCKED response to Mary's **manual completion independent of physical Stop** and safe next-batch rule. No such acceptance is recorded in this export. | **Not jointly answered; Mary's requested change remains pending.** |

Ally's A-04 “v1 frozen” means the report's implemented baseline is not being
edited in place. The same report explicitly says the final Cha/Kath format
agreement is pending. It is **not** a jointly signed D01–D06 contract freeze.
Its local D-01…D-10 list is a different scoped decision list from the six shared
D01–D06 rows; the actual decision CSV is needed before mapping them.

## Progress we can reuse without repeating the audits

- A-01 firmware audit and A-02 interface documentation are reported prepared.
- START/ACK/RUNNING separation, null/invalid readings, parser drain and host
  recovery/turning/control checks are reported with limitations, not physical proof.
- Later reported totals include 40 HW-IMP-01 host checks, 31 durability-model
  checks and a pilot summary of 311 host checks. These runs overlap older suites:
  **do not add all report totals as distinct tests**. None was rerun in this review.
- Production journal, STOP, offline authorization, RTC, HC-05/Android and powered
  tests are expressly absent/blocked. No need to ask Ally to pretend they passed.
- The pilot report explicitly records NO-GO, no empty-incubator run, postponed
  eggs, unsigned safety clearance and pending profile approval. Those gates stand.

## Different source snapshots: do not silently merge them

This Cha checkout is still `cha-branch2` at `2d2622e`, not Ally's reported HEAD.
Its Combined source SHA-256 is
`a466a868e6c148cf4f9c3230378d5033d81db89dfb77a3e0fa53891d847a9598`,
not the supplied later `7106…` hash. Our local Uno sketch exists; Ally's audit says
the current app-facing path is missing in their main checkout. Those observations
can both be true for different snapshots; neither proves the other's branch wrong.

The reported `80971…` commit is not available in this local Git object database
(`git cat-file -t` could not resolve it). The seven specifically referenced audit/
interface/format/HW-IMP docs checked by this review are absent from this checkout.
No fetch, branch switch, merge, build, flash, hardware operation or database access
was performed. Path/hash strings in JSON are not a substitute for the file bytes.

## Small, targeted follow-up to Ally — one matching packet, not another audit

Please send a ZIP/source packet containing these existing outputs plus their
matching source/catalog/build evidence (no credentials):

1. `docs/oct26_a02_firmware_interface.md` — exact current interface/catalog.
2. `docs/oct26_a03_a01_findings_for_cha.md` and its `a01_findings_for_c02.csv` — the
   actual ten review questions/findings, not just a report that the memo exists.
3. `docs/oct26_a04_final_ndjson_format_decision.md` and
   `docs/evidence/oct26-a04/2026-10-30/format_decisions.csv` — exact A/B/C proposal,
   fields and pending decisions. Mary should review these before choosing a version.
4. `docs/hwimp01_source_patch_start_stop_status.md`, the exact Combined source or
   patch/manifest at `7106…`, build/avr-size/toolchain logs and matching fixtures.
5. `docs/hwimp02_durable_recovery_design.md` — precise proposed retention/full/loss
   policy and record schema, clearly labelled host-model versus production.

Then answer only the unresolved points:

> **D04:** What offline command-authority/provisioning/revocation and bounded
> retention/full/corrupt/loss policy do you propose? ACCEPT / CHANGE / BLOCKED on
> Mary's retention_ack:null and no automatic evidence release after HTTP success.
> Do not invent guarantees if the design cannot fit; name the exact blocker.
>
> **D06:** ACCEPT / CHANGE / BLOCKED on Mary's proposal to save validated farmer
> hatch results independently of physical Stop, without claiming Stop or allowing
> another hardware batch merely because the cloud row is Completed. What exact
> hardware state/admission/new-batch facts must Kath/backend preserve?

This asks for **Ally's response**, not for them to approve Kath's storage/auth UI
or the adviser's profile values. Kath's own sign-off and the missing byte-level
source/mapping decisions are still separately needed.

## Preservation and portal effect

All report bodies, IDs and source hashes are indexed under `ally-export-review/`.
The two task-ID mismatches are retained as findings; no raw report is reassigned,
overwritten, deleted or silently imported. The main ledger records progress
reports **received**, not an invented Ally approval. The portal gets Mary's
review summary only. Cha counts and all other members' statuses remain unchanged.

Local verification checks the JSON/index integrity, report counts, mismatches,
source preservation and pending approval boundaries. These are document checks,
not a new Arduino compilation, source acceptance, end-to-end or security test.
