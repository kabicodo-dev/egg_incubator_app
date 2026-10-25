# SmartHatch HW-02 — Real Sensor Validation (Physical Validation Checklist)

**Owner:** Hardware
**Branch:** `ally-branch3` (feature branch — do not merge without approval)
**Depends on:** HW-01 (connection & readiness protocol)

## Goal

Live and simulated sensor readings must never be mixed. Only valid, fresh
physical readings are labeled "live". Simulated (slider) preview values are
clearly distinguished and never presented as live hardware readings.

## Physical sensor inventory

| Chamber | Sensor | Arduino pin | Telemetry field | Plausible range |
|---------|--------|-------------|-----------------|-----------------|
| Incubator | DHT11 temperature | D2 | `incubator.temperature` | −20 .. 60 °C |
| Incubator | DHT11 humidity | D2 | `incubator.humidity` | 0 .. 100 % |
| Brooder   | DHT11 temperature | D4 | `brooder.temperature` | −20 .. 60 °C |
| Brooder   | DHT11 humidity | D4 | `brooder.humidity` | 0 .. 100 % |

Notes:
- The DHT11 requires ≥ 2 s between reads (`SENSOR_INTERVAL_MS = 2500`).
- Telemetry is emitted every `TELEMETRY_INTERVAL_MS = 2000` ms.
- Invalid / out-of-range / missing values are reported as JSON `null` — **never** as `0` and never as a stale value.
- Sensor validity is enforced in `ArduinoTelemetry.fromJson` (`lib/services/arduino_protocol.dart`).

## Readiness pre-condition (HW-01)

Before any reading is labeled live, the Arduino must be in the HW-01 `ready`
state: serial port open **and** a telemetry frame received within the
heartbeat timeout (default 6 s). A serial port alone is not sufficient.

## Source tracking (implemented in this branch)

`IncubatorController` now records the source of every sensor reading
(`SensorDataSource.physical` / `simulated` / `none`) plus the receipt
timestamp of the last physical frame:

- `sensorSource` — where the current readings came from.
- `sensorLastReceivedAt` — receipt time of the last physical frame.
- `sensorsAreLive` — true only for fresh physical readings (within
  `sensorStaleAfter`, default 6 s). Simulated readings are never live.
- `sensorsAreSimulated` — true for local slider preview values.

Physical and simulated sources are never mixed: each `updateSensors` call
overwrites the source, so a simulator preview cannot be mistaken for live
hardware.

## Supervised physical validation checklist

Run this checklist with a real SmartHatch Uno connected over USB. A second
person (supervisor) should observe the hardware and the app simultaneously.

### 1. Live physical readings are labeled live

- [ ] Disconnect the Arduino: chamber cards show `—` (source `none`), no values.
- [ ] Connect the Arduino, wait for the first telemetry frame: chamber cards
      show `LIVE` (source `physical`) and real temperature/humidity values.
- [ ] Readings update approximately every 2 s (telemetry interval).
- [ ] `sensorsAreLive` is `true` while frames arrive within 6 s.

### 2. Simulated values are never labeled live

- [ ] With the Arduino disconnected, move a simulator slider: chamber cards
      show `SIMULATED` (source `simulated`) and the slider value.
- [ ] `sensorsAreLive` is `false` while simulated; `sensorsAreSimulated` is
      `true`.
- [ ] Reconnect the Arduino: source flips to `physical`/`LIVE` on the first
      fresh frame; the simulator value is overwritten, not merged.

### 3. Stale physical readings are not live

- [ ] With the Arduino connected and live, pause telemetry (e.g. hold the
      Arduino in reset or disable its loop): after > 6 s of silence, the
      source reverts to `—`/`none` and `sensorsAreLive` becomes `false`.
      No simulated value appears in its place.
- [ ] Resume telemetry: source returns to `LIVE` on the next frame.

### 4. Invalid / missing / out-of-range data

- [ ] Disconnect one DHT11 (or short its data pin): the corresponding chamber
      value shows `ERROR`, `hasIncubatorSensorError` /
      `hasBrooderSensorError` is `true`, and the frame is still `LIVE` (other
      chamber still fresh).
- [ ] Inject an out-of-range value (> 60 °C or < 0 % humidity): it is
      reported as `null`, never as `0` or a stale number.
- [ ] Brooder NaN or out-of-safe-range (< 10 °C / > 40 °C): brooder bulb
      turns OFF and the buzzer alarm sounds (safety cutoff).

### 5. Chamber mapping

- [ ] Incubator values map to incubator tiles; brooder values map to brooder
      tiles — never crossed.
- [ ] Relay states (bulb/fan/humidifier/exhaust) match the Arduino-reported
      actuator states when `externalControl` is active.

### 6. No simulated data reaches hardware

- [ ] Moving simulator sliders never writes to the serial port or changes any
      relay while the Arduino is disconnected.
- [ ] No Supabase write is triggered by simulator interaction.

## Unit tests

`test/arduino_sensor_source_test.dart` covers source tracking, staleness,
chamber mapping, out-of-range/null handling, and physical-vs-simulated
non-mixing.

## Notes

- No firmware changes are made in this branch; the DHT11/pin mapping and
  telemetry contract already exist in `arduino/SmartHatch_Uno/SmartHatch_Uno.ino`
  and `lib/services/arduino_protocol.dart`.
- No destructive database changes.
- Review and approval required before merging.
