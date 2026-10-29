#!/usr/bin/env python3
"""A-03 fail-safe checker for a SmartHatch_Combined telemetry capture.

Usage:
    python arduino/SmartHatch_Combined/host/check_control.py <capture.ndjson>

The capture is produced by `control_host_sim.cpp`, which compiles the real
sketch. This checker validates the *software* control law and safe-state
transitions visible in telemetry. It cannot prove relay polarity, heater power,
sensor accuracy, HC-05 operation or any physical safety property.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

HEAT_ON_C = 37.5
HEAT_OFF_C = 38.0
OVER_TEMP_C = 39.0
ACTIVE_HUMIDITY_LOW = 45.0
ACTIVE_HUMIDITY_HIGH = 55.0
BROODER_HEAT_ON_C = 30.0
BROODER_HEAT_OFF_C = 32.0
BROODER_HUMIDITY_LOW = 45.0
BROODER_HUMIDITY_HIGH = 60.0
EPS = 0.05


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

    telemetry = [(n, f) for n, f in frames if f.get("type") == "telemetry"]
    require(telemetry, "capture contains no telemetry")

    seen_invalid = False
    seen_valid_after_invalid = False
    seen_overheat = False
    seen_invalid_after_overheat = False
    seen_fan_off_invalid = False
    counts = {
        "valid": 0,
        "invalid": 0,
        "heat_on": 0,
        "heat_off": 0,
        "humid_on": 0,
        "humid_off": 0,
        "overheat": 0,
        "brooder_invalid": 0,
    }

    for number, frame in telemetry:
        where = f"line {number}"
        incubator = frame.get("incubator")
        brooder = frame.get("brooder")
        require(isinstance(incubator, dict), f"{where}: missing incubator block")
        require(isinstance(brooder, dict), f"{where}: missing brooder block")

        for room, block in (("incubator", incubator), ("brooder", brooder)):
            for key in ("valid", "bulb_on", "humidifier_on"):
                require(isinstance(block.get(key), bool),
                        f"{where}: {room}.{key} must be bool")
            for key in ("temperature_c", "humidity_percent"):
                value = block.get(key)
                require(value is None or is_number(value),
                        f"{where}: {room}.{key} must be number or null")
                if not block["valid"]:
                    require(value is None,
                            f"{where}: stale {room}.{key} reported as a live value")

        if not incubator["valid"]:
            seen_invalid = True
            counts["invalid"] += 1
            for key in ("bulb_on", "humidifier_on", "fan_on", "exhaust_fan_on"):
                require(isinstance(incubator.get(key), bool),
                        f"{where}: incubator.{key} must be bool")
                require(incubator[key] is False,
                        f"{where}: invalid incubator must force {key}=false")
            seen_fan_off_invalid = True
            if seen_overheat:
                seen_invalid_after_overheat = True
        else:
            if seen_invalid:
                seen_valid_after_invalid = True
            counts["valid"] += 1
            temperature = incubator["temperature_c"]
            humidity = incubator["humidity_percent"]
            require(is_number(temperature), f"{where}: valid incubator needs temperature")
            require(is_number(humidity), f"{where}: valid incubator needs humidity")
            require(incubator["fan_on"] is True,
                    f"{where}: circulation fan must run while incubator data is valid")

            if temperature >= OVER_TEMP_C - EPS:
                seen_overheat = True
                counts["overheat"] += 1
                require(incubator["bulb_on"] is False,
                        f"{where}: over-temperature must turn the heater OFF")
                require(incubator["humidifier_on"] is False,
                        f"{where}: over-temperature must turn the humidifier OFF")
            else:
                if temperature >= HEAT_OFF_C - EPS:
                    require(incubator["bulb_on"] is False,
                            f"{where}: heater must be OFF at/above {HEAT_OFF_C} C")
                if temperature <= HEAT_ON_C + EPS:
                    require(incubator["bulb_on"] is True,
                            f"{where}: heater must be ON at/below {HEAT_ON_C} C")
                if humidity < ACTIVE_HUMIDITY_LOW - EPS:
                    require(incubator["humidifier_on"] is True,
                            f"{where}: humidifier must be ON below {ACTIVE_HUMIDITY_LOW} %")
                if humidity >= ACTIVE_HUMIDITY_HIGH - EPS:
                    require(incubator["humidifier_on"] is False,
                            f"{where}: humidifier must be OFF at/above {ACTIVE_HUMIDITY_HIGH} %")

            if incubator["bulb_on"]:
                counts["heat_on"] += 1
            else:
                counts["heat_off"] += 1
            if incubator["humidifier_on"]:
                counts["humid_on"] += 1
            else:
                counts["humid_off"] += 1

        if not brooder["valid"]:
            counts["brooder_invalid"] += 1
            require(brooder["bulb_on"] is False,
                    f"{where}: invalid brooder must turn its heater OFF")
            require(brooder["humidifier_on"] is False,
                    f"{where}: invalid brooder must turn its humidifier OFF")
        else:
            temperature = brooder["temperature_c"]
            humidity = brooder["humidity_percent"]
            require(is_number(temperature), f"{where}: valid brooder needs temperature")
            require(is_number(humidity), f"{where}: valid brooder needs humidity")
            if temperature <= BROODER_HEAT_ON_C + EPS:
                require(brooder["bulb_on"] is True,
                        f"{where}: brooder heater must be ON at/below {BROODER_HEAT_ON_C} C")
            if temperature >= BROODER_HEAT_OFF_C - EPS:
                require(brooder["bulb_on"] is False,
                        f"{where}: brooder heater must be OFF at/above {BROODER_HEAT_OFF_C} C")
            if humidity < BROODER_HUMIDITY_LOW - EPS:
                require(brooder["humidifier_on"] is True,
                        f"{where}: brooder humidifier must be ON below {BROODER_HUMIDITY_LOW} %")
            if humidity >= BROODER_HUMIDITY_HIGH - EPS:
                require(brooder["humidifier_on"] is False,
                        f"{where}: brooder humidifier must be OFF at/above {BROODER_HUMIDITY_HIGH} %")

    # The scenario must actually exercise the safe-state transitions, not just
    # produce harmless telemetry.
    require(seen_invalid, "capture never exercised invalid-sensor fail-safe")
    require(seen_fan_off_invalid, "invalid-sensor frame never had fan_on=false")
    require(seen_overheat, "capture never reached the over-temperature cutoff")
    require(seen_valid_after_invalid,
            "capture never showed recovery to a valid incubator reading")
    require(seen_invalid_after_overheat,
            "capture never showed sensor loss after an over-temperature event")
    require(counts["heat_on"] and counts["heat_off"],
            "capture did not exercise both heater states")
    require(counts["humid_on"] and counts["humid_off"],
            "capture did not exercise both humidifier states")
    require(counts["brooder_invalid"], "capture never exercised brooder sensor loss")

    print(
        "PASS: A-03 control/fail-safe invariants; "
        f"{len(telemetry)} telemetry frame(s); "
        f"valid={counts['valid']} invalid={counts['invalid']} "
        f"overheat={counts['overheat']} brooder_invalid={counts['brooder_invalid']}; "
        "invalid=>all incubator outputs off, overheat=>heater+humidifier off/fan on, "
        "recovery observed"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
