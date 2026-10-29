#!/usr/bin/env python3
"""Verify the A-08 test-log format and the 2026-10-29 evidence bundle.

Usage:
    python docs/evidence/a08/check_a08_log.py

It checks only document/evidence integrity:
- the required entry fields are present;
- every physical row P-01..P-15 is NOT RUN and not claimed as PASS;
- software rows are explicitly PASS (software);
- every file in sha256sums.txt exists and matches its hash.

It cannot prove any hardware result. No board, sensor, relay or HC-05 is touched.
"""

from __future__ import annotations

import hashlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
LOG = ROOT / "docs" / "a08_hardware_test_log.md"
BUNDLE = ROOT / "docs" / "evidence" / "a08" / "2026-10-29"
SUMS = BUNDLE / "sha256sums.txt"

REQUIRED_FIELDS = [
    "Date/time:",
    "Tester:",
    "Setup/revision:",
    "Safety clearance:",
    "Approved-limit reference:",
    "Expected:",
    "Actual:",
    "Result:",
    "Photo link:",
    "Raw capture:",
    "SHA-256:",
]

PHYSICAL_IDS = [f"P-{n:02d}" for n in range(1, 16)]
SOFTWARE_IDS = [f"SW-{n:02d}" for n in range(1, 6)]


def fail(message: str) -> "None":
    raise SystemExit(f"FAIL: {message}")


def require(condition: bool, message: str) -> None:
    if not condition:
        fail(message)


def main() -> int:
    require(LOG.is_file(), f"missing log: {LOG}")
    text = LOG.read_text(encoding="utf-8")

    for field in REQUIRED_FIELDS:
        require(field in text, f"missing entry field: {field}")
    require("## 8. Reviewer sign-off (Cla)" in text,
            "missing Cla reviewer sign-off block")
    require("Cla" in text, "reviewer name missing")

    lines = text.splitlines()
    for test_id in PHYSICAL_IDS:
        rows = [line for line in lines if line.startswith(f"| {test_id} |")]
        require(len(rows) == 1, f"{test_id}: expected exactly one physical row")
        row = rows[0]
        require("NOT RUN" in row, f"{test_id}: physical row must be NOT RUN")
        require("PASS" not in row, f"{test_id}: physical row must not claim PASS")

    for test_id in SOFTWARE_IDS:
        rows = [line for line in lines if line.startswith(f"| {test_id} |")]
        require(len(rows) == 1, f"{test_id}: expected exactly one software row")
        require("PASS (software)" in rows[0],
                f"{test_id}: software row must be labelled PASS (software)")
        require("not hardware" in text.lower() or "not a hardware" in text.lower(),
                "log must state that software rows are not hardware evidence")

    require(SUMS.is_file(), f"missing checksum list: {SUMS}")
    checked = 0
    for raw in SUMS.read_text(encoding="utf-8").splitlines():
        raw = raw.strip()
        if not raw:
            continue
        match = re.match(r"^([0-9a-f]{64})\s+\*?(.+)$", raw)
        require(match is not None, f"malformed checksum line: {raw}")
        expected, relative = match.group(1), match.group(2).replace("\\", "/")
        target = ROOT / relative
        require(target.is_file(), f"missing evidence file: {relative}")
        actual = hashlib.sha256(target.read_bytes()).hexdigest()
        require(actual == expected, f"hash mismatch: {relative}")
        checked += 1

    require(checked >= 10, "too few evidence files hashed")
    print(
        f"PASS: A-08 log format; {len(PHYSICAL_IDS)} physical rows NOT RUN; "
        f"{len(SOFTWARE_IDS)} software rows labelled PASS (software); "
        f"{checked} evidence files match sha256sums.txt"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
