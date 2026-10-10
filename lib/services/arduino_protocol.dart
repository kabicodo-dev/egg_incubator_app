import 'dart:convert';

/// JSON Lines protocol shared between the SmartHatch Flutter app and the
/// Arduino Uno firmware (see `arduino/SmartHatch_Uno/SmartHatch_Uno.ino`).
///
/// One complete JSON object per line, terminated by `\n`. This file contains no
/// platform dependencies so it can be unit-tested and reused on any target.

/// Message `type` values.
const String kTypeTelemetry = 'telemetry';
const String kTypeCommand = 'command';
const String kTypeAck = 'ack';

/// Canonical actuator names. These strings are the contract between the app and
/// the sketch, so both sides must use them verbatim.
const Set<String> kActuatorNames = {
  'incubatorBulb',
  'incubatorFan',
  'exhaustFan',
  'brooderBulb',
  'incubatorHumidifier',
  'brooderHumidifier',
  'eggTurningServo',
};

/// Human readable labels used by the UI for each actuator.
const Map<String, String> kActuatorLabels = {
  'incubatorBulb': 'Incubator Bulb',
  'incubatorFan': 'Circulation Fan',
  'exhaustFan': 'Exhaust / Intake Fan',
  'brooderBulb': 'Brooder Bulb',
  'incubatorHumidifier': 'Incubator Humidifier',
  'brooderHumidifier': 'Brooder Humidifier',
  'eggTurningServo': 'Egg Turning',
};

/// Physical relay pin (for documentation/UI hints only; the app never drives
/// GPIO directly).
const Map<String, String> kActuatorPins = {
  'incubatorBulb': 'D10',
  'incubatorFan': 'D12',
  'exhaustFan': 'D9',
  'brooderBulb': 'D11',
  'incubatorHumidifier': 'D6',
  'brooderHumidifier': 'D5',
  'eggTurningServo': 'D3',
};

bool isValidActuator(String name) => kActuatorNames.contains(name);

// ── Primitive coercion helpers (never throw; invalid => null) ──

double? _parseNumber(Object? value, {double? min, double? max}) {
  double? result;
  if (value is num) {
    result = value.toDouble();
  } else if (value is String) {
    result = double.tryParse(value.trim());
  }
  if (result == null || result.isNaN || result.isInfinite) return null;
  if (min != null && result < min) return null;
  if (max != null && result > max) return null;
  return result;
}

int? _parseInt(Object? value, {int? min, int? max}) {
  int? result;
  if (value is int) {
    result = value;
  } else if (value is num) {
    result = value.round();
  } else if (value is String) {
    result = int.tryParse(value.trim());
  }
  if (result == null) return null;
  if (min != null && result < min) return null;
  if (max != null && result > max) return null;
  return result;
}

bool? _parseBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case 'on':
      case '1':
        return true;
      case 'false':
      case 'off':
      case '0':
        return false;
    }
  }
  return null;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return const {};
}

/// A `telemetry` message from the Arduino.
///
/// Sensor fields are nullable: `null` means "unavailable / sensor error" and must
/// never be shown as `0`. Values outside a plausible physical range are also
/// treated as unavailable.
class ArduinoTelemetry {
  final double? incubatorTemperature;
  final double? incubatorHumidity;
  final double? brooderTemperature;
  final double? brooderHumidity;

  /// Last known relay states reported by the Arduino (defaults to `false`).
  final Map<String, bool> actuators;

  /// Configured automatic turning interval (minutes). Defaults to 240 (4 h).
  final int turnIntervalMinutes;

  /// Turns completed today, and seconds since the last turn (if reported).
  final int? turnsToday;
  final int? secondsSinceLastTurn;

  /// Whether the automatic turning system is currently enabled.
  final bool turningActive;

  /// When this reading was received by the app (used for staleness checks).
  final DateTime receivedAt;

  const ArduinoTelemetry({
    this.incubatorTemperature,
    this.incubatorHumidity,
    this.brooderTemperature,
    this.brooderHumidity,
    this.actuators = const {},
    this.turnIntervalMinutes = 240,
    this.turnsToday,
    this.secondsSinceLastTurn,
    this.turningActive = false,
    required this.receivedAt,
  });

  factory ArduinoTelemetry.fromJson(
    Map<String, dynamic> json, {
    DateTime? receivedAt,
  }) {
    final incubator = _asMap(json['incubator']);
    final brooder = _asMap(json['brooder']);
    final actuatorJson = _asMap(json['actuators']);
    final turning = _asMap(json['turning']);

    final actuators = <String, bool>{};
    for (final name in kActuatorNames) {
      actuators[name] = _parseBool(actuatorJson[name]) ?? false;
    }

    return ArduinoTelemetry(
      // DHT11 plausible ranges: temp -20..60 C, humidity 0..100 %.
      incubatorTemperature:
          _parseNumber(incubator['temperature'], min: -20, max: 60),
      incubatorHumidity: _parseNumber(incubator['humidity'], min: 0, max: 100),
      brooderTemperature:
          _parseNumber(brooder['temperature'], min: -20, max: 60),
      brooderHumidity: _parseNumber(brooder['humidity'], min: 0, max: 100),
      actuators: actuators,
      turnIntervalMinutes:
          _parseInt(turning['intervalMinutes'], min: 1, max: 1440) ?? 240,
      turnsToday: _parseInt(turning['turnsToday'], min: 0),
      secondsSinceLastTurn: _parseInt(turning['secondsSinceLastTurn'], min: 0),
      turningActive: _parseBool(turning['active']) ?? false,
      receivedAt: receivedAt ?? DateTime.now(),
    );
  }

  bool get hasIncubatorSensorError =>
      incubatorTemperature == null || incubatorHumidity == null;

  bool get hasBrooderSensorError =>
      brooderTemperature == null || brooderHumidity == null;

  /// Scheduled turns per day derived from the Arduino-reported interval
  /// (e.g. 240 minutes => 6 turns/day).
  int get scheduledTurnsPerDay =>
      (1440 / turnIntervalMinutes).floor().clamp(0, 24);
}

/// A `command` message sent from the app to the Arduino.
class ArduinoCommand {
  final String id;
  final String actuator;
  final bool state;

  const ArduinoCommand({
    required this.id,
    required this.actuator,
    required this.state,
  });

  Map<String, dynamic> toJson() => {
        'type': kTypeCommand,
        'id': id,
        'actuator': actuator,
        'state': state,
      };

  /// Serialized as a single JSON line (terminated with `\n`).
  String toJsonLine() => '${jsonEncode(toJson())}\n';
}

/// An `ack` message from the Arduino confirming/rejecting a command.
///
/// An acknowledgement means the firmware *processed* the command; it is not
/// independent proof that a relay physically switched (see [hardwareVerified]).
class ArduinoAck {
  final String? id;
  final bool success;
  final String? actuator;
  final bool? state;
  final String? error;

  /// Always `false`: the reference hardware cannot independently verify the
  /// physical state, so acknowledgements are command confirmations only.
  final bool hardwareVerified;

  const ArduinoAck({
    this.id,
    required this.success,
    this.actuator,
    this.state,
    this.error,
    this.hardwareVerified = false,
  });

  factory ArduinoAck.fromJson(Map<String, dynamic> json) {
    final actuatorRaw = json['actuator'];
    final actuator =
        actuatorRaw is String && isValidActuator(actuatorRaw) ? actuatorRaw : null;
    return ArduinoAck(
      id: json['id'] is String ? json['id'] as String : null,
      success: _parseBool(json['success']) ?? false,
      actuator: actuator,
      state: _parseBool(json['state']),
      error: json['error'] is String ? json['error'] as String : null,
    );
  }
}

// ── Incoming message envelope ──

/// Base type for a parsed incoming line.
abstract class ArduinoIncoming {
  const ArduinoIncoming();
}

class ArduinoTelemetryMessage extends ArduinoIncoming {
  final ArduinoTelemetry telemetry;
  const ArduinoTelemetryMessage(this.telemetry);
}

class ArduinoAckMessage extends ArduinoIncoming {
  final ArduinoAck ack;
  const ArduinoAckMessage(this.ack);
}

/// A syntactically valid JSON object with an unrecognized `type`.
class ArduinoUnknownMessage extends ArduinoIncoming {
  final String? type;
  const ArduinoUnknownMessage(this.type);
}

/// A line that was not valid JSON, or not a JSON object.
class ArduinoMalformedMessage extends ArduinoIncoming {
  final String raw;
  const ArduinoMalformedMessage(this.raw);

  @override
  String toString() => 'ArduinoMalformedMessage(${raw.length} chars)';
}

/// Parses a single newline-delimited line.
///
/// Returns `null` for blank lines (which should simply be ignored). Never
/// throws: malformed input becomes [ArduinoMalformedMessage].
ArduinoIncoming? parseArduinoLine(String line) {
  final trimmed = line.trim();
  if (trimmed.isEmpty) return null;

  Object? decoded;
  try {
    decoded = jsonDecode(trimmed);
  } catch (_) {
    return ArduinoMalformedMessage(trimmed);
  }
  if (decoded is! Map) return ArduinoMalformedMessage(trimmed);

  final map = _asMap(decoded);
  final type = map['type'];

  switch (type) {
    case kTypeTelemetry:
      return ArduinoTelemetryMessage(ArduinoTelemetry.fromJson(map));
    case kTypeAck:
      return ArduinoAckMessage(ArduinoAck.fromJson(map));
    default:
      return ArduinoUnknownMessage(type is String ? type : null);
  }
}
