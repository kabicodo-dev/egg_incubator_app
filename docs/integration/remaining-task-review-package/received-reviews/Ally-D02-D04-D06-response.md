# Ally — D02 / D04 / D06 response (firmware and source position)

**Task:** ALLY-D02-D04-D06-01 (answers the "Exact requests to Ally" in
`D04_D06_Mary_Backend_Position`)
**Owner:** Ally (firmware/source)
**Record date:** 2026-10-30 (Asia/Manila)
**Branch:** `ally-branch3` · **HEAD:** `80971f902d5634f7fed78ff073fcb78fa31be460`
plus the uncommitted HW-IMP-01 parser patch (source SHA-256
`7106ebfe01d037c95766cd51c43b43fa02f92b922fc5a180770fd27b3822c5ec`)
**Disposition:** **PERSONAL POSITIONS ONLY — NOT JOINTLY APPROVED, NOT
IMPLEMENTATION AUTHORIZATION, NOT HARDWARE/SAFETY CLEARANCE.**

This document answers four questions the team asked of the firmware owner:

1. exact controller/source identity (D02);
2. offline authorization and retention feasibility (D04);
3. remaining recovery facts;
4. a review of "completion independent of Stop" (D06).

It contains no new protocol, no new field, no new approved value, and no code
change. Every statement about the firmware is either read directly from the
current source or measured from a build performed here.

## 1. Evidence basis

| Item | Value |
|---|---|
| Source file | `arduino/SmartHatch_Combined/SmartHatch_Combined.ino` |
| Build | **21164 B flash (65 %), 1782 B SRAM (87 %), 266 B free** |
| HEX SHA-256 | `9c1192f1d11049e51af0e6d325312039d1847dd683a8f50cb80c474b54ee1554` |
| ELF SHA-256 | `806ac17178440080aafd551c881772bac24cc5b300ad6e46fed02bc6621d4aea` |
| Manifest verification | **10 of 11** source documents in INTEGRATION-CONTRACT-03 §2 re-hashed byte-identical on this machine (H-C, H-F, H-O, H-S, U-W, U-R, U-F, D-A, D-S, D-R) |
| Unverifiable here | `SmartHatch_v1.2.md`, v1.3 draft, UI-CONTRACT-03, Oct28–30 handoff — **absent**, hashes not re-checked |
| DB-02 receipt hash | Documented `started` `content_sha256` **reproduced exactly** from the documented preimage under RFC 8785 JCS |

Exact commands and outputs: `docs/evidence/ally-d02-d04-d06/2026-10-30/`.

Note on the build: it is byte-identical to the PILOT-GATE-01 build
(21164/1782/266, same HEX and ELF), which confirms no source change occurred
between that record and this one.

## 2. What the firmware actually contains (identity and storage)

Read from source, with line numbers in `source_facts.txt`:

| Concern | Actual implementation | Consequence for D02/D04 |
|---|---|---|
| Batch identity | `uint32_t batchId` inside `StartRecord`, EEPROM offset 32, magic `0x5337`, version 1 | Numeric 32-bit only. No UUID, no device identity, no installation identity |
| Progress record | `BatchState` at EEPROM 0, magic `0x5636`: `eggType`, `uint32_t elapsedSeconds` | No original Start timestamp, no profile version, no command id |
| Command id | `long id` (signed 32-bit) in parser, ACK, cache | DB-02 requires 16 lowercase hex characters (8 bytes). Type and format differ; no hex encoding exists |
| ACK cache | 8 entries, `char command[16]`, `char status[10]`, `char detail[32]`, keyed by numeric id | **Volatile**; cleared at boot (line 896). No content fingerprint, so same-id/different-content cannot be detected |
| Parse buffer | `char serialLine[120]` (line 154) | DB-02's 4096-byte `wire_evidence` frames can never be produced by this device |
| STOP | **No `STOP` string exists in the source** (0 matches) | Stop semantics, evidence and storage are unimplemented, not merely untested |
| RTC | **No RTC driver** (0 matches for `RTClib`, `DS3231`, `setTime`, `now()`); `Wire.begin()` at line 884 belongs to the I2C LCD | No UTC, no date, no persisted wall time. Only `elapsed_seconds` and `millis()` |
| Integrity | **No CRC, no checksum, no watchdog** (0 matches) | Durable records today rest on a magic/version check only |
| Telemetry content | `type, v, uptime_ms, egg_type, day, hatch_day, elapsed_seconds, stage, batch_complete, incubator{...}, brooder{...}` | Contains **no** `batch_id`, command id, event sequence, boot epoch, original Start, profile version or retention cursor |

## 3. D02 — lifecycle, identity and recovery

Status legend: **ACCEPT** = I accept the stated direction; **CHANGE** = a
specific alternative is required; **BLOCKED** = I cannot supply a defensible
answer yet.

### D02-1 Source identity — **BLOCKED (design) / CHANGE (shape)**

Current firmware can produce exactly one durable identity: a 32-bit numeric
`batchId`. DB-02 requires four independent identities (`device_id`,
`installation_id`, `batch_id` as UUIDs; `command_id` as 16 hex). None exist.

To close this without inventing values, three things must be decided together:

1. **Controller identity** — provisioned by an administrator rather than
   generated on the Uno. The Uno has no hardware RNG and no clock; a
   self-generated "UUID" would be a weak counter dressed as an identifier.
2. **Batch identity** — generated once by Android before any START is sent, then
   carried on the wire. The Uno stores and echoes it; it must never mint one.
3. **Command identity** — 8 bytes (16 hex) fits the same space as today's
   `long`, but the wire and the ACK must both carry hex text. This is a wire
   change, not a type cast.

**Cost, stated honestly:** a 16-byte batch UUID plus a 16-character command id
cannot be added to the existing frames without exceeding `serialLine[120]`.
The exact budget belongs to D03, which is still BLOCKED. I will not pick an
encoding before the bounds decision.

### D02-2 Explicit START / STOP — **CHANGE**

START exists and is explicit. **STOP does not exist at all.** Before it can be
implemented, these must be answered by the owners (I will not invent them):

1. Is STOP admitted while a batch is running, while starting, while in fault,
   and while idle?
2. Does STOP abort and freeze `elapsedSeconds`, or complete the batch?
3. Does STOP clear the retained `batchId` and `StartRecord`, or leave them for
   reconciliation?
4. Is STOP permitted when the journal is full or corrupt (I recommend yes, as a
   safety action without durable evidence)?
5. What evidence distinguishes "STOP accepted" from "outputs actually off"?
6. What does STOP mean for turning and for lockdown state?

Two invariants I will hold regardless of the answers:

- STOP is a command with its own id, never inferred from relay state, from
  `TURN_STOPPED`, or from "heater happens to be off" (this agrees with C02 in
  the register).
- An ACK is processing evidence only. It is never "the batch is stopped".

### D02-3 ACK vs current state vs cloud Active — **ACCEPT (principle)**

Already implemented and host-tested: an ACK is emitted for receipt; RUNNING is
emitted only after the controller confirms the actuators, and duplicate START is
idempotent (A-06: 48 checks, 0 failures). The separation the register asks for
already exists in behaviour.

Limitation to record: "hardware-confirmed RUNNING" is still source-level
confirmation, not independent physical feedback. No sensor or relay-contact
feedback closes that loop.

### D02-4 Read-only recovery query — **CHANGE**

`STATUS` exists and is read-only (ACK `telemetry_follows`, then one telemetry
frame). It is **not** the reconciliation exchange B04 requires. It cannot
return: the bound `batch_id`, the original command id, the original Start, the
approved profile reference, an event sequence or epoch, or a retention
gap/cursor.

Adding those fields costs bytes in a 120-byte line, so this collides with D03.
My position: STATUS should be extended rather than duplicated, and the new
fields must be specified together with the size budget. An undefined
`GET_STATE` reference must not survive into any implementation.

### D02-5 Retained replay — **BLOCKED (capacity decision)**

There is no retained event record. The only replay-like behaviour is the
8-entry volatile ACK cache, which is cleared at boot and carries no content
fingerprint. It cannot reconstruct a lost `started`/`stopped` transition.

Two honest options, and only the team can pick one:

- **Option A — bounded durable journal.** The HW-IMP-02 model proposes
  4 slots × 64 B at `0x0200..0x02FF` (256 B, untouched by current code). A
  slot fits `magic/version (4) + source sequence (4) + boot epoch (4) +
  kind (1) + command id (8) + batch id (16) + timestamp (8) + CRC (2)` ≈ 47 B.
  It retains **at most four critical transitions**, not a batch history, and no
  telemetry.
- **Option B — explicit narrower guarantee.** State in the contract exactly
  which offline/crash events may be lost, and revise the UI/DB claims to match.

I recommend A **with** its four-record limit written down, because a limit that
is written down is usable and an unstated one is not. A is not implemented in
production firmware; only a host model exists.

### D02-6 Capacity claim — **CHANGE**

The register is right that the 64-byte AVR ring is not a frame limit. The real
local limit is the 120-byte application buffer. Any cloud schema that assumes
4096-byte device evidence, or that sizes fields from a "191-byte ideal", must
carry a device-direction bound that this firmware can actually produce.

## 4. D04 — authority, retention and release

### D04-1 Offline command authorization — **BLOCKED**

There is no authorization of any kind on the wire: no key, no nonce, no
provisioned secret, no pairing authority. HC-05 pairing is not command
authorization, and a board name or public token is not a credential.

Feasibility is genuinely unproven and I will not promise it:

- flash headroom is 11,092 B, which could hold a compact SHA-256/HMAC;
- **SRAM headroom is 266 B**, which is the binding constraint;
- a keyed digest path adds stack and state that must be measured, and would
  probably require reducing the 8-entry ACK cache or other buffers first.

Required before any claim: a real compile/link with the primitive included, a
stack measurement, and a decision on where the key lives and how it is
provisioned, rotated and revoked while the phone and incubator are offline.
None of that exists today.

### D04-2 Bounded retention — **CHANGE** (same choice as D02-5)

Retention is feasible only as the four-slot journal above. It is **not**
feasible as full history: 1 KB EEPROM total, 256 B currently proposed for the
journal, and no external storage on the Uno.

What can be retained: four critical transitions, with integrity per record.
What cannot: telemetry backfill, per-sample history, “every event since Start”,
or any receipt/acknowledgment archive.

### D04-3 Journal full / corrupt — **ACCEPT (principle), unimplemented**

I accept the safe direction: a full or corrupt journal must block a *new Start*,
must never overwrite the only unacknowledged proof, and must not block an
emergency local safe action. Corruption must lead to a recovery state, never to
a silent new batch, a reused counter or a fabricated Day 1.

### D04-4 `retention_ack` and release — **ACCEPT fail-closed**

I agree with Mary's position and with DB-02 §7: `retention_ack` stays `null`.
Android must not synthesize `RCPT_ACK` from HTTP 2xx, from an ACK, or from a
phone-owned MAC. There is no verifier in firmware today, and inventing one
without a threat model would be worse than having none. No automatic release
path should be enabled.

### D04-5 Revocation and clock — **ACCEPT (limits)**

Cloud revocation cannot reach an offline Bluetooth link; that limitation should
be stated, not worked around. And because there is no RTC, the controller cannot
supply UTC at all: it can only report `elapsed_seconds` since its own retained
start. Any `occurred_at` therefore comes from the phone and must be labelled as
such. Day N remains `floor(trustworthy elapsed_seconds / 86400) + 1` only when
the original Start and the elapsed reference are both trustworthy.

## 5. D06 — local/cloud mapping and completion

### D06-1 Names and idempotency — **ACCEPT**

I accept preserving `egg_quantity`/`eggs_hatched` and the bigint session
mapping. I accept same-identity/same-content = idempotent retry, changed content
= conflict, and that a cloud response never proves a physical transition.
Caveat: the firmware is not a party to the cloud schema. It emits no cloud
field, and its ACK cache cannot detect changed content today.

### D06-2 Completion independent of Stop — **ACCEPT WITH CONDITIONS**

Mary's change request asks to save a validated manual hatch result independently
of Stop evidence. My answer, on firmware grounds:

**The DB-02 §3 rule cannot be satisfied by this controller, because STOP does
not exist.** Requiring an applied referenced Stop as a prerequisite for
`farmer_completed` therefore blocks every completion indefinitely, and the only
way to satisfy it today would be to fabricate a Stop — which I will not do and
which no record authorizes.

I therefore support separating manual completion from Stop, subject to four
conditions:

1. Completion never commands, implies or records a physical Stop.
2. Completion does not by itself clear the single-Active guard or authorize
   another hardware batch. Whether a new batch may be admitted is a lifecycle
   decision, not a completion side effect.
3. An unknown original completion time stays `NULL`; server receipt time is not
   substituted for it.
4. Hatch counts stay manual, integer, `0..original egg_quantity`, never derived
   from sensors.

I also note the mirror-image risk: without a Stop rule, a batch can stay
`Active` indefinitely. `batch_complete` in firmware is a stage calculation past
the hatch day — **not** a Stop. The team still owes an explicit rule for
"controller may still be running, farmer says the batch is done".

## 6. Defects found in the supplied record set

These are contract-hygiene findings, not code findings.

1. **The ledger is stale against Mary's own answers.** `CONTRACT-FREEZE-01`
   §2 and §4 still record "PENDING — no reply supplied" for every decision,
   while `D04_D06_Mary_Backend_Position` (30 Oct) records four answers. That
   later document states it updated "the main decision ledger's current answer
   cells"; the ledger supplied here shows no such update. One of the two must be
   corrected before either is cited as current.
2. **Cha and Mary are the same person.** The register assigns Cha to record and
   verify Mary's backend decisions and states that "no coordinator
   recommendation supplies another person's approval". With one human in both
   roles, that independence does not exist. It should be disclosed in the
   ledger rather than implied by separate headings.
3. **Line numbers are stale.** Register S2/S3/S4/S5 cite `cha-branch2` at
   `c7a26cf`. Content matches this tree, but positions do not — e.g.
   `serialLine[120]` is line 154 here, not 82-87, and the ACK cache is at
   162-167. Re-pin before citing.
4. **Broken repository links.** `docs/contract-review/` here contains only the
   four HW-02 files; the three DB-02 documents exist only outside the repo, so
   the register's relative links to D-A/D-S/D-R do not resolve in this checkout.
5. **The "corrected" HW-02 catalog is still an escaped export** — five physical
   lines, literal `\n`, mojibake em dashes, and `payload`/`GET_STATE`/`191` all
   present. It must not be treated as a frozen literal source in this form.

## 7. What I cannot answer

- **D05 numerical profile** — no named approver exists; I will not supply
  temperature/humidity/day/capacity values.
- **RTC behaviour** — no RTC is present; a policy cannot be tested into
  existence.
- **Device provisioning mechanism** — no channel exists to deliver a controller
  identity or key.
- **Cryptographic feasibility** — needs a real build and stack measurement at
  266 B free SRAM; not claimed.
- **Any physical behaviour** — no board was flashed, no load energised, no
  sensor or HC-05 connected, no egg involved.

## 8. Verification performed for this record

```
.\.arduino\bin\arduino-cli.exe compile --fqbn arduino:avr:uno \
  --build-path .arduino\build_ally_d02_d04_d06 arduino\SmartHatch_Combined
```

Result: 21164 B flash (65 %), 1782 B SRAM (87 %), 266 B free.
`avr-size`: Program 21164 B (64.6 %), Data 1782 B (87.0 %).
HEX and ELF hashes identical to the PILOT-GATE-01 build.

```
node docs\evidence\ally-d02-d04-d06\2026-10-30\jcs_reproduction.js
```

Result: the DB-02 `started` `content_sha256`
`3ec2e9e1d4d8e06500276e9a47713eea3f7069b9525ea3a45664b66bf45ced86` reproduced
exactly from the documented 12-field preimage (734-byte canonical core). Seven
alternative shapes were checked and all differed, so the match is not
coincidental. This confirms the DB-02 hash is genuine; it does not implement or
approve JCS in the product.

Source facts were extracted read-only (`source_facts.txt`), including explicit
zero-match checks for RTC, UUID, STOP, CRC and watchdog.

No firmware file was modified in this task.

## 9. Requests to other owners

- **Cha:** update the ledger with Mary's four answers and these thirteen positions;
  re-pin S2–S5 line numbers against this branch; publish a clean, hash-pinned
  HW-02 catalog; record that Cha and Mary are the same person.
- **Mary:** state which rule replaces DB-02 §3 for completion; confirm whether
  controller identity is provisioned as a UUID alias or stays numeric; confirm
  device-direction frame bounds rather than the 4096-byte HTTP ceiling.
- **Kath:** confirm the app can generate a batch UUID and a 16-hex command id
  before START, and what the local draft does while completion has no Stop.
- **Kath + Mary:** decide the "controller may still be running" case before any
  new batch is admitted after a manual completion.

## 10. Non-claims

- Not an approval, joint acceptance, or freeze of D02, D04 or D06.
- Physical pilot scope is unchanged: **Chicken-only, fresh eggs only, manual hatch counts, incubator-only**. Three-species behaviour remains software-only.
- No hatch is claimed complete by 3/4 November or any other date.
- Not evidence that identity, STOP, authorization, retention, CRC or replay
  exist in the product.
- Not a safety clearance; no powered test, flashing, wiring change or egg test.
- No claim that any of these positions is technically proven on hardware.
