#!/usr/bin/env python3
"""A-06 START/ACK/RUNNING checker for a SmartHatch_Combined capture.

Usage:
    python arduino/SmartHatch_Combined/host/check_start.py <capture.ndjson>

The capture is produced by `start_host_sim.cpp`, which compiles the real
sketch. This checker validates the *software* START handshake and the ordering
of receipt ACK versus hardware-confirmed RUNNING. It cannot prove relay
contacts, sensor accuracy, HC-05 transport or physical incubation.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ACCEPTED_MESSAGES = {"start_received", "start_already_running"}
REJECTED_CODES = {
    "invalid_batch_id",
    "batch_already_running",
    "batch_already_complete",
}


def fail(message: str) -> "None":
    raise SystemExit(f"FAIL: {message}")


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def is_int(value: object) -> bool:
    return isinstance(value, int) and not isinstance(value, bool)


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__.strip(), file=sys.stderr)
        return 2

    raw = Path(sys.argv[1]).read_bytes()
    require(raw, "capture is empty")
    require(b"\r" not in raw, "CR byte found; framing is LF only")
    require(raw.endswith(b"\n"), "capture must end with exactly one LF")

    frames = []
    lines = raw.split(b"\n")[:-1]
    for number, line in enumerate(lines, start=1):
        require(line != b"", f"line {number}: blank line")
        try:
            frame = json.loads(line.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            fail(f"line {number}: not one JSON object ({exc})")
        require(isinstance(frame, dict), f"line {number}: not a JSON object")
        require(frame.get("v") == 1, f"line {number}: missing/unsupported v")
        require(frame.get("type") in {"ack", "running", "telemetry", "event"},
                f"line {number}: unknown type {frame.get('type')!r}")
        frames.append((number, frame))

    start_acks = [(i, f) for i, (_, f) in enumerate(frames)
                  if f.get("type") == "ack" and f.get("cmd") == "START"]
    start_running = [(i, f) for i, (_, f) in enumerate(frames)
                     if f.get("type") == "running" and f.get("cmd") == "START"]
    require(start_acks, "capture contains no START ack")
    require(start_running, "capture contains no START running frame")

    # Every START ack carries both identities and a valid outcome vocabulary.
    for index, frame in start_acks:
        require(is_int(frame.get("id")), f"frame {index + 1}: START ack id must be int")
        require(is_int(frame.get("command_id")),
                f"frame {index + 1}: START ack needs command_id")
        require(is_int(frame.get("batch_id")),
                f"frame {index + 1}: START ack needs batch_id")
        require(frame["command_id"] == frame["id"],
                f"frame {index + 1}: command_id must equal id")
        require(frame.get("status") in {"accepted", "rejected"},
                f"frame {index + 1}: bad START ack status")
        if frame["status"] == "accepted":
            require(frame.get("message") in ACCEPTED_MESSAGES,
                    f"frame {index + 1}: unexpected accepted START message")
            require("error" not in frame,
                    f"frame {index + 1}: accepted START ack carries error")
        else:
            error = frame.get("error")
            require(isinstance(error, dict),
                    f"frame {index + 1}: rejected START needs error object")
            require(error.get("code") in REJECTED_CODES,
                    f"frame {index + 1}: unexpected START error code {error.get('code')!r}")
            require("message" not in frame,
                    f"frame {index + 1}: rejected START ack must not use top-level message")

    # RUNNING is a post-confirmation status, not the in-flight meaning used by
    # TURN_NOW. It must carry both identities and follow an accepted ACK.
    for index, frame in start_running:
        require(is_int(frame.get("id")), f"frame {index + 1}: START running id must be int")
        require(is_int(frame.get("command_id")),
                f"frame {index + 1}: START running needs command_id")
        require(is_int(frame.get("batch_id")),
                f"frame {index + 1}: START running needs batch_id")
        require(frame["command_id"] == frame["id"],
                f"frame {index + 1}: command_id must equal id")
        require(frame.get("status") == "running",
                f"frame {index + 1}: START running must carry status=running")
        prior = [
            ack_index for ack_index, ack in start_acks
            if ack_index < index
            and ack.get("status") == "accepted"
            and ack.get("command_id") == frame["command_id"]
            and ack.get("batch_id") == frame["batch_id"]
        ]
        require(prior,
                f"frame {index + 1}: RUNNING without an earlier accepted START ack")
        require(prior[0] < index,
                f"frame {index + 1}: RUNNING must follow ACK")

    # The first START must be receipt-only first and RUNNING later.
    first = start_acks[0][1]
    require(first.get("message") == "start_received",
            "first START ack must be receipt-only (start_received)")
    first_id = first["id"]
    first_ack_index = start_acks[0][0]
    first_running = [
        index for index, frame in start_running if frame.get("id") == first_id
    ]
    require(first_running, "first START never received RUNNING")
    require(first_ack_index < first_running[0],
            "first START RUNNING must follow its receipt ACK")

    # Duplicate command id must be idempotent: two ACKs/RUNNINGs for id 301 and
    # no new batch_started event between them.
    duplicate_acks = [index for index, frame in start_acks if frame.get("id") == first_id]
    require(len(duplicate_acks) >= 2, "duplicate START id was not replayed")
    duplicate_ack_index = duplicate_acks[1]
    duplicate_running = [
        index for index, frame in start_running
        if index > duplicate_ack_index and frame.get("id") == first_id
    ]
    require(duplicate_running, "duplicate START did not re-assert RUNNING")
    between = frames[duplicate_ack_index + 1:duplicate_running[0]]
    require(not any(frame.get("event") == "batch_started" for _, frame in between),
            "duplicate START restarted the batch")

    # Explicit rejection evidence.
    rejected = [(index, frame) for index, frame in start_acks
                if frame.get("status") == "rejected"]
    codes = {(frame.get("error") or {}).get("code") for _, frame in rejected}
    require("invalid_batch_id" in codes, "missing invalid_batch_id rejection")
    require("batch_already_running" in codes, "missing batch_already_running rejection")
    require("batch_already_complete" in codes, "missing batch_already_complete rejection")
    for index, frame in rejected:
        require(not any(running_frame.get("id") == frame.get("id")
                        for _, running_frame in start_running),
                f"frame {index + 1}: rejected START must not emit RUNNING")

    # Sensor-invalid case (id 306): ACK first, then at least one invalid telemetry
    # frame before RUNNING. This is the direct evidence that RUNNING waits.
    sensor_ack = next((index for index, frame in start_acks if frame.get("id") == 306), None)
    sensor_running = next((index for index, frame in start_running if frame.get("id") == 306), None)
    require(sensor_ack is not None and sensor_running is not None,
            "sensor-invalid START sequence missing")
    require(sensor_ack < sensor_running,
            "sensor-invalid RUNNING must follow ACK")
    invalid_between = [
        frame for _, frame in frames[sensor_ack + 1:sensor_running]
        if frame.get("type") == "telemetry"
        and (frame.get("incubator") or {}).get("valid") is False
    ]
    require(invalid_between,
            "RUNNING appeared without an intervening invalid incubator reading")

    # Actuator-readback case (id 308): ACK and RUNNING must be separated by at
    # least one telemetry frame; the C++ harness asserts the pin mismatch itself.
    actuator_ack = next((index for index, frame in start_acks if frame.get("id") == 308), None)
    actuator_running = next((index for index, frame in start_running if frame.get("id") == 308), None)
    require(actuator_ack is not None and actuator_running is not None,
            "actuator-readback START sequence missing")
    require(actuator_ack < actuator_running,
            "actuator-readback RUNNING must follow ACK")
    require(any(frame.get("type") == "telemetry"
                for _, frame in frames[actuator_ack + 1:actuator_running]),
            "actuator-readback RUNNING must follow at least one control/telemetry pass")

    # EEPROM reload identity must be reused without a new batch_started event.
    reload_ack = next((index for index, frame in start_acks if frame.get("id") == 309), None)
    reload_running = next((index for index, frame in start_running if frame.get("id") == 309), None)
    require(reload_ack is not None and reload_running is not None,
            "EEPROM reload duplicate sequence missing")
    require(reload_ack < reload_running, "EEPROM reload RUNNING must follow ACK")
    require(not any(frame.get("event") == "batch_started"
                    for _, frame in frames[reload_ack + 1:reload_running]),
            "EEPROM reload duplicate restarted the batch")

    # Day N remains derived from the firmware's elapsed counter, never from
    # ACK/receipt ordering.
    telemetry = [frame for _, frame in frames if frame.get("type") == "telemetry"]
    for frame in telemetry:
        elapsed = frame.get("elapsed_seconds")
        day = frame.get("day")
        require(is_int(elapsed) and is_int(day),
                "telemetry needs integer elapsed_seconds and day")
        require(day == elapsed // 86400 + 1,
                "Day N must be floor(elapsed_seconds/86400)+1")

    print(
        "PASS: A-06 START handshake; "
        f"{len(start_acks)} START ack(s), {len(start_running)} RUNNING frame(s), "
        f"{len(rejected)} rejection(s); ACK receipt precedes hardware-confirmed "
        "RUNNING; duplicate START idempotent; sensor and actuator waits observed"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
