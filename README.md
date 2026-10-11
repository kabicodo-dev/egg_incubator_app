# egg_incubator_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Egg Incubator App
Connected with Supabase and Flutter.

## Arduino Uno USB Control

SmartHatch can talk to a SmartHatch Uno firmware over the USB serial port.
While connected, the hardware owns the relays and the app shows **live** sensor
readings (no simulated values are disguised as real data).

- Firmware: [`arduino/SmartHatch_Uno/SmartHatch_Uno.ino`](arduino/SmartHatch_Uno/SmartHatch_Uno.ino)
- App side: `lib/controllers/arduino_controller.dart` + `lib/services/arduino_serial_*.dart`
- Transport: USB serial (default **9600 baud**), JSON Lines (one JSON object per line).

### Wiring / pin map

| Device                  | Pin  | Notes                        |
| ----------------------- | ---- | ---------------------------- |
| Incubator DHT11         | D2   | Temperature + humidity       |
| Incubator egg turner    | D3   | Servo, auto every 4 h        |
| Brooder DHT11           | D4   | Temperature + humidity       |
| Brooder humidifier      | D5   | Relay, **active-LOW**        |
| Incubator humidifier    | D6   | Relay, **active-LOW**        |
| Incubator buzzer        | D7   | Relay, **active-LOW**        |
| Brooder buzzer          | D8   | Relay, **active-LOW**        |
| Exhaust / intake fan    | D9   | Relay, **active-LOW**        |
| Incubator bulb (heat)   | D10  | Relay, **active-LOW**        |
| Brooder bulb (heat)     | D11  | Relay, **active-LOW**        |
| Incubator circulation   | D12  | Relay, **active-LOW**        |

All relays are **active-LOW** (`LOW` = relay ON). Actuator names used by the
protocol: `incubatorBulb`, `incubatorFan`, `exhaustFan`, `brooderBulb`,
`incubatorHumidifier`, `brooderHumidifier`, `eggTurningServo`.

### Protocol

```
App -> Arduino : {"type":"command","id":"cmd-1","actuator":"incubatorBulb","state":true}
Arduino -> App : {"type":"ack","id":"cmd-1","success":true,"actuator":"incubatorBulb","state":true}
Arduino -> App : {"type":"telemetry","incubator":{"temperature":37.6,"humidity":51.4},
                  "brooder":{"temperature":31.2,"humidity":49.0},
                  "actuators":{"incubatorBulb":true,...},
                  "turning":{"active":true,"intervalMinutes":240,"turnsToday":3}}
```

- `telemetry` is emitted by the firmware ~every 2 s. Sensor errors are sent as
  missing values (`null`); they are never shown as `0`.
- The app confirms a command only after a matching `ack`.
- While connected, manual commands override automatic hysteresis in the app;
  the firmware keeps running its own safeguards. Disconnecting returns control
  to the app-side simulation/profile logic.
- Egg turning is **scheduled only** (auto every 4 h = 6 turns/day, halted in
  lockdown): there is no manual "turn now" button. `eggTurningServo` enables or
  disables the automatic schedule.
- When connected, live status is shown in three places: the **Home tab**
  ("Live Incubator Status" panel, no navigation needed), **Active Incubation**
  and the **Hardware Console**. Egg turning shows progress like
  "3 of 6 turns done today · next in 1 h 12 m".
- The Hardware Console is reachable from the Home panel and from Active
  Incubation via "Open Hardware Console".

### Running on Windows

1. Enable **Developer Mode** (Windows Settings > Update & Security > For
   developers) so `flutter pub get` can create the plugin symlinks needed by
   `flutter_libserialport`.
2. Upload `arduino/SmartHatch_Uno/SmartHatch_Uno.ino` to the Uno with the
   Arduino IDE, then plug it in over USB.
3. `flutter pub get && flutter run -d windows`
4. In the app, open the hardware console / incubation screen, pick the COM port
   (e.g. `COM3`), tap **Connect**.

The feature is safe on web builds: the serial implementation is replaced by a
no-op stub on non-`dart:io` platforms.

### Tests

```
flutter test
```
`test/arduino_protocol_test.dart` covers the JSON-Lines protocol parsing;
`flutter analyze` should report no issues.
