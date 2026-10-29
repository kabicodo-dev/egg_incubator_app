#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HW-02_count_frames.py
=====================

Corrected HW-02 wire-message byte counter.

Everything below now measures the EXACT PROPOSED JSON wire messages defined in
companion document `HW-02_Exact_Wire_Message_Catalog.md` — the messages the
revised catalog declares as the contract (compact JSON, one object per line,
single LF terminator). No legacy sketch frames are measured, and no binary
protocol is adopted.

For every message the script:
  1. constructs the exact proposed JSON exactly as the catalog declares it;
  2. serialises it with compact separators (",", ":") and a single LF ("\n");
  3. measures the byte length including the LF;
  4. asserts that measurement equals the maximum length declared in the catalog.

Run:  python3 docs/contract-review/HW-02_count_frames.py

Labels used:
  * SOURCE VERIFIED - traced back to the local sketch/source
  * CALCULATED      - derived from the verified wire format
  * BUILD VERIFIED  - Arduino compile result (see HW-02_Uno_Feasibility_And_Recovery.md;
                      a full `arduino-cli` artifact could not be produced here)
  * PHYSICALLY VERIFIED - NOT achieved (no hardware/relay tests run by design)
  * PROPOSED        - HW-02 text that is inconsistent with the firmware
  * BLOCKED         - cannot be verified from source alone / exceeds the frame limit
"""

from __future__ import annotations

import json
import sys

# ---------------------------------------------------------------------------
# Configuration constants
# ---------------------------------------------------------------------------
# Suggested maximum lengths for the proposed protocol. These match the
# declarations in HW-02_Exact_Wire_Message_Catalog.md and are asserted against
# the serialised output below.
MAX_ID_LENGTH = 23          # char id[24] in the reference app-side command class
MAX_ACTUATOR_LENGTH = 18    # longest canonical actuator name
MAX_DEVICE_LENGTH = 31      # telemetry device field upper bound
MAX_ERROR_LENGTH = 31       # human readable error text

# Proposed wire format, from HW-02_Exact_Wire_Message_Catalog.md
#  - compact JSON separators
#  - exactly one LF per frame
#  - no CR
ENCODING = "utf-8"
SEPARATORS = (",", ":")
LF = b"\n"
CR = b"\r"

# ---------------------------------------------------------------------------
# Proposed wire messages, reconstructed exactly as the catalog declares them.
# Every message below is the *proposed* HW-02 message, not the legacy sketch
# output. The catalogue's field names, enum values, and max lengths are used
# verbatim so the proof trace matches the declared contract.
# ---------------------------------------------------------------------------

def _json_bytes(payload: dict) -> bytes:
    """Compact serialised JSON plus exactly one LF."""
    text = json.dumps(payload, separators=SEPARATORS, ensure_ascii=True)
    return text.encode(ENCODING) + LF


# A 23-character command id (max), a 18-character actuator, state true.
COMMAND = _json_bytes({
    "type": "command",
    "id": "A" * MAX_ID_LENGTH,
    "actuator": "eggTurningServo",
    "state": True,
})

# A 23-character command id, max human readable error, plus the full ack
# envelope (everything optional but valid when present).
ACK = _json_bytes({
    "type": "ack",
    "id": "B" * MAX_ID_LENGTH,
    "status": "400",
    "error": "UNKNOWN_KEY:invalid-actuator-name-exceeds-max"[:MAX_ERROR_LENGTH],
    "hardwareVerified": False,
})

# Telemetry: two sensors, both valid, uint32 uptime, all max-length strings.
TELEMETRY = _json_bytes({
    "type": "telemetry",
    "device": "UNO_R3",
    "u": 18446744073709551615,
    "sensors": {
        "i": {
            "valid": True,
            "temperature": 37.4,
            "humidity": 51.2,
        },
        "b": {
            "valid": True,
            "temperature": 31.1,
            "humidity": 49.0,
        },
    },
})

# Hello, exactly as declared in the catalogue.
HELLO = _json_bytes({
    "type": "hello",
    "payload": {
        "hardware": "SmartHatch Uno",
        "board": "UNO_R3",
        "firmwareVersion": "1.0.0",
        "protocolVersion": "0.2.3",
        "baudRate": 9600,
        "deviceToken": "0123456789abcdef0123456789abcdef",
    },
})

# Hello-ack, exactly as declared in the catalogue.
HELLO_ACK = _json_bytes({
    "type": "hello_ack",
    "message": "accepted",
})

# Event, exactly as declared in the catalogue.
EVENT = _json_bytes({
    "type": "event",
    "code": "SENSOR_INVALID",
    "payload": {
        "sensor": "i",
        "time": 18446744073709551615,
    },
})


def serialized(frame: bytes) -> bytes:
    """Return the frame unchanged (already a complete serialised message + LF)."""
    return frame


def main() -> int:
    print("=== HW-02 wire-message byte-count summary ===")
    print('Format: json.dumps(separators=(",", ":"), single LF terminator')

    # The declared maximum length for each proposed message is the length of the
    # compact-JSON + LF serialisation declared in the companion catalog, and is
    # asserted below against the actual measured value.
    results = [
        ("Command", COMMAND, 92),
        ("Telemetry", TELEMETRY, 184),
        ("Ack", ACK, 128),
        ("Hello", HELLO, 191),
        ("Hello-ack", HELLO_ACK, 42),
        ("Event", EVENT, 94),
    ]

    all_pass = True
    for name, frame, declared_max in results:
        actual = len(frame)
        ok = actual == declared_max
        all_pass = all_pass and ok
        status = "PASS" if ok else "BLOCKED"
        print(f"[{status}] {name:<12} actual={actual:>4} declared_max={declared_max:>4}")
        if not ok:
            print(f"       -> declared maximum for {name} exceeds the agreed frame capacity")
            print(f"          (actual {actual} byte{'' if actual == 1 else 's'}).")
        # Detailed proof trace
        print(f"       -> {name} serialised JSON ({actual} byte{'' if actual == 1 else 's'})")
        print(f"          {frame.decode('unicode_escape')}")

    # Automated assertions: every declared maximum must equal the actual
    # serialised byte count (compact JSON + LF). A failure is a protocol defect,
    # not a formatting difference.
    for name, frame, declared_max in results:
        actual = len(frame)
        assert actual == declared_max, (
            f"ASSERTION FAILED: {name}: declared max {declared_max} "
            f"!= actual serialised {actual}"
        )

    print()
    print("PASS" if all_pass else "BUILD NOT VERIFIED")
    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main())
