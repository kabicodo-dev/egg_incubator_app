#!/usr/bin/env python3
"""Strict A-02 NDJSON checker for a captured SmartHatch_Combined serial log.

Usage:
    python arduino/SmartHatch_Combined/host/check_ndjson.py <capture.ndjson>

It exits non-zero on the first contract violation and prints a PASS summary
otherwise. It validates framing and message shape only; it cannot prove that
any relay, sensor or HC-05 link physically behaved as reported.

A-06 START captures use `check_start.py`: START RUNNING is a post-confirmation
status (ACK precedes RUNNING), unlike the TURN_NOW in-flight semantics checked
here.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

TYPES = {"ack", "running", "telemetry", "event"}
STATUSES = {"accepted", "rejected"}


def fail(message: str) -> "None":
    raise SystemExit(f"FAIL: {message}")


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def is_number(value: object) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__.strip(), file=sys.stderr)
        return 2

    path = Path(sys.argv[1])
    raw = path.read_bytes()
    require(raw, "capture is empty")
    require(b"\r" not in raw, "CR byte found; A-02 framing is LF only")
    require(raw.endswith(b"\n"), "capture must end with exactly one LF")

    lines = raw.split(b"\n")[:-1]
    frames = []
    for number, line in enumerate(lines, start=1):
        require(line != b"", f"line {number}: blank line")
        try:
            frame = json.loads(line.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            fail(f"line {number}: not one JSON object ({exc})")
        require(isinstance(frame, dict), f"line {number}: not a JSON object")
        frames.append((number, frame))

    acks = {}
    running = {}
    for number, frame in frames:
        where = f"line {number}"
        require(frame.get("v") == 1, f"{where}: missing or unsupported v")
        kind = frame.get("type")
        require(kind in TYPES, f"{where}: unknown type {kind!r}")

        if kind == "ack":
            require(isinstance(frame.get("id"), int), f"{where}: ack id must be int")
            require(isinstance(frame.get("cmd"), str), f"{where}: ack cmd must be str")
            status = frame.get("status")
            require(status in STATUSES, f"{where}: bad ack status {status!r}")
            if status == "rejected":
                error = frame.get("error")
                require(isinstance(error, dict), f"{where}: rejected ack needs error object")
                require(isinstance(error.get("code"), str) and error["code"], f"{where}: error.code required")
                require(isinstance(error.get("message"), str) and error["message"], f"{where}: error.message required")
                require("message" not in frame, f"{where}: rejected ack must not use top-level message")
            else:
                require(isinstance(frame.get("message"), str), f"{where}: accepted ack needs message")
                require("error" not in frame, f"{where}: accepted ack must not carry error")
            acks.setdefault(frame["id"], []).append((number, frame))

        elif kind == "running":
            require(isinstance(frame.get("id"), int), f"{where}: running id must be int")
            require(isinstance(frame.get("cmd"), str), f"{where}: running cmd must be str")
            require("status" not in frame and "error" not in frame, f"{where}: running is not terminal")
            running.setdefault(frame["id"], []).append(number)

        elif kind == "telemetry":
            for key in ("uptime_ms", "day", "hatch_day", "elapsed_seconds"):
                require(is_number(frame.get(key)), f"{where}: telemetry.{key} must be a number")
            require(frame["day"] == frame["elapsed_seconds"] // 86400 + 1,
                    f"{where}: day must be floor(elapsed_seconds/86400)+1")
            for room in ("incubator", "brooder"):
                block = frame.get(room)
                require(isinstance(block, dict), f"{where}: missing {room} block")
                require(isinstance(block.get("valid"), bool), f"{where}: {room}.valid must be bool")
                for key in ("temperature_c", "humidity_percent"):
                    value = block.get(key)
                    require(value is None or is_number(value),
                            f"{where}: {room}.{key} must be number or null")
                    if not block["valid"]:
                        require(value is None,
                                f"{where}: stale {room}.{key} reported as a live value")
        else:  # event
            require(isinstance(frame.get("event"), str) and frame["event"], f"{where}: event name required")

    # A-02 separates in-flight state from terminal confirmation.
    require(running, "capture contains no running frame")
    for command_id, numbers in running.items():
        require(command_id in acks, f"running id {command_id} never received an ack")
        first_running = numbers[0]
        first_ack = acks[command_id][0][0]
        require(first_running < first_ack,
                f"id {command_id}: running must precede its terminal ack")

    # The duplicate-id scenario must replay the terminal ack, not re-run.
    require(len(acks.get(102, [])) == 2, "expected two acks for duplicate id 102")
    require(all(frame["status"] == "accepted" for _, frame in acks[102]),
            "duplicate id must replay the original accepted outcome")

    rejected = [frame for _, frame in frames
                if frame.get("type") == "ack" and frame.get("status") == "rejected"]
    require(rejected, "capture contains no structured rejection")
    require(any(frame["error"]["code"] == "line_too_long" for frame in rejected),
            "line_too_long rejection missing")

    print(f"PASS: {len(frames)} frames, {len(acks)} acked ids, "
          f"{sum(len(v) for v in running.values())} running frame(s), "
          f"{len(rejected)} structured rejection(s), LF-only framing")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
