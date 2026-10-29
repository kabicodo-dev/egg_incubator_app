# HW-02 Open Decisions (correction pass)

**Owner:** Hardware · **Branch:** `ally-branch3` (feature branch — do not merge without approval)  \n**Source repository:** `C:/Users/celine/Documents/Sandy/SCHOOL/REPORTS/SmartHatch/egg_incubator_app`  \n**Gate:** Kath (Flutter/UI-02) + Mary (backend/owner) + Cha (DB-02/protocol) must approve each item before it is final.

This file lists every decision still open after the correction pass. It is **not** a protocol finalisation; each item must be explicitly agreed by Kath, Mary, and Cha.

---

## 1. Prototype assignment

| # | Decision | Status |
|---|---|---|
| PROT-01 | Which sketch is the physical incubator's firmware? | **LEGACYFIRMWAREBEHAVIOR** — READMEs pin `arduino/SmartHatch_Uno/SmartHatch_Uno.ino`. `arduino/SmartHatch_Combined/SmartHatch_Combined.ino` is a separate variant. **Confirm before any flash.** |

---

## 2. Byte counts and frame fit

| # | Decision | Status |
|---|---|---|
| BYT-01 | Command frame size, measured as compact JSON + LF: **92 B** (not 107; measured by `HW-02_count_frames.py`) | **BLOCKED** — 92 B exceeds the 64-byte Uno `Serial` RX ring buffer (hardware) even though the app-level parse buffer (`CMD_BUFFER_SIZE=160`) holds it. RX overrun occurs on the wire. |
| BYT-02 | Telemetry field count and worst-case values | **CALCULATED** → 2-sensor telemetry with uint64 `u` max measures **184 B**. Every proposed frame is measured by the corrected script and asserted. |
| BYT-03 | Reference frame vs legacy plain-text frames | **LEGACYFIRMWAREBEHAVIOR** — correct that legacy is `ACK,<msg>` + `STATUS,...`, not the proposed JSON. |
| BYT-04 | Echo/hello correlation | **PROPOSED** — requires `kTypeHello` in the app (K1); **not** implemented in the reference Uno sketch. |
| BYT-05 | Byte-count script | **FIXED** — the script now constructs and serialises the exact proposed JSON (compact separators + single LF) and asserts each declared maximum against the measured value. All six frames PASS. |
| BYT-06 | Binary protocol | **NOT ADOPTED** — a binary frame solution was not chosen; no complete binary format is defined and no Kath/Mary agreement exists. The proposed JSON remains the only contract. |

---

## 3. Socket/recovery

| # | Decision | Status |
|---|---|---|
| RCL-01 | Durable `commandAckSeq` + manifest | **PROPOSED** — not in current sketch; requires EEPROM manifest + journal (H1) |
| RCL-02 | Two-EEPROM.update atomicity | **FALSE** — explicitly marked NOT an atomic guarantee |
| RCL-03 | Overrun behavior | **LEGACYFIRMWAREBEHAVIOR** — line dropped; proposal: reply `400/E2BIG` |
| RCL-04 | Serial buffer sizing | **PROPOSED FIX** — the app-level parse buffer is already enlarged (`CMD_BUFFER_SIZE=160` in the modern Uno sketch), but this does **not** fix the 64-byte RX overrun; the fixable constraint is the hardware RX limit, which requires a smaller frame, host-side buffering, or agreed binary framing. |

---

## 4. Embedded/FSK

| # | Decision | Status |
|---|---|---|
| EMB-01 | RTC gate | **MISSING** — `millis()`-only; decide before any wall-clock work |
| EMB-02 | Offline authorization | **NOT PROVIDED** — no auth on the wire |
| EMB-03 | Authenticated cloud-receipt release | **NOT PROVIDED** — backend signs receipts; device has no cert |
| EMB-04 | SRAM/flash proof | **SOURCE VERIFIED (tight)**; exact `avr-size` artifact **BUILD NOT VERIFIED** (see feasibility doc) |

---

## 5. Joint approval list (final gate)

We need **Kath**, **Mary**, and **Cha** to agree on:

1. **Proto** — adopt §A of the corrected catalog (or reject it); confirm the 64-byte RX-limit BLOCKED status is acceptable and what, if anything, unblocks it (smaller frame, host buffering, or agreed binary).
2. **Firmware** — approve the proposed JSON Command capacity vs the 64-byte RX limit; the modern `CMD_BUFFER_SIZE=160` removes the app-level overflow but not the RX overrun.
3. **App** — approve `kTypeHello` parse and `ackCache`/duplicate-id semantics (K1/K4).
4. **Backend+DB** — approve the new command/`deviceToken`/`commandAckSeq` schema and the receipt-shipping dependency.

**No joint approval or hardware verification has been claimed or performed in this correction pass.** The unresolved decisions in §1–§4 above remain open and are carried forward exactly as agreed by the team.
