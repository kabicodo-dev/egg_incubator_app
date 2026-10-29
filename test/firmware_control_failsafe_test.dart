import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A-03 local-control / fail-safe check for lines captured from
/// `SmartHatch_Combined.ino`.
///
/// The fixture is real captured output from
/// `arduino/SmartHatch_Combined/host/control_host_sim.cpp`, which compiles the
/// production sketch against shimmed AVR headers and records the scripted
/// control scenario. It is software evidence only: it does not prove relay
/// polarity, heater power, sensor accuracy, HC-05 operation or any physical
/// incubation/safety property. No board was flashed and no load was energised.
void main() {
  const fixture = 'test/fixtures/firmware/combined_a03_control_capture.ndjson';
  const heatOnC = 37.5;
  const heatOffC = 38.0;
  const overTempC = 39.0;
  const humidityLow = 45.0;
  const humidityHigh = 55.0;

  late List<Map<String, dynamic>> frames;
  late List<Map<String, dynamic>> telemetry;

  setUpAll(() {
    final bytes = File(fixture).readAsBytesSync();
    expect(bytes, isNotEmpty, reason: 'capture fixture must not be empty');
    expect(bytes.contains(13), isFalse, reason: 'framing is LF only');
    expect(bytes.last, 10, reason: 'capture must end with a single LF');

    final lines = utf8.decode(bytes).split('\n')..removeLast();
    frames = [for (final line in lines) _decodeObject(line)];
    telemetry = frames.where((f) => f['type'] == 'telemetry').toList();
  });

  test('every line is one versioned frame', () {
    expect(frames, isNotEmpty);
    for (var i = 0; i < frames.length; i++) {
      expect(frames[i]['v'], 1, reason: 'line ${i + 1}: v must be 1');
      expect(
        frames[i]['type'],
        anyOf('ack', 'running', 'telemetry', 'event'),
        reason: 'line ${i + 1}: unknown type',
      );
    }
    expect(telemetry.length, greaterThan(40),
        reason: 'scenario must run long enough to sample every phase');
  });

  test('invalid incubator sensor forces every incubator output off', () {
    final invalid = telemetry
        .where((f) => _room(f, 'incubator')['valid'] == false)
        .toList();
    expect(invalid, isNotEmpty, reason: 'scenario must exercise sensor loss');

    for (final frame in invalid) {
      final incubator = _room(frame, 'incubator');
      expect(incubator['temperature_c'], isNull);
      expect(incubator['humidity_percent'], isNull);
      expect(incubator['bulb_on'], isFalse);
      expect(incubator['humidifier_on'], isFalse);
      expect(incubator['fan_on'], isFalse,
          reason: 'circulation fan must not stay energised without valid data');
      expect(incubator['exhaust_fan_on'], isFalse);
    }

    // Loss must occur after a healthy frame and recover afterwards.
    final firstInvalid = telemetry.indexWhere(
      (f) => _room(f, 'incubator')['valid'] == false,
    );
    expect(
      telemetry
          .take(firstInvalid)
          .any((f) => _room(f, 'incubator')['fan_on'] == true),
      isTrue,
      reason: 'sensor loss must follow a valid, running phase',
    );
    expect(
      telemetry
          .skip(firstInvalid + 1)
          .any((f) => _room(f, 'incubator')['valid'] == true),
      isTrue,
      reason: 'scenario must show recovery from the fail-safe',
    );
  });

  test('over-temperature turns heater and humidifier off, fan stays on', () {
    final hot = telemetry.where((f) {
      final incubator = _room(f, 'incubator');
      final temperature = incubator['temperature_c'];
      return incubator['valid'] == true &&
          temperature is num &&
          temperature >= overTempC - 0.05;
    }).toList();
    expect(hot, isNotEmpty, reason: 'scenario must exercise overheat');

    for (final frame in hot) {
      final incubator = _room(frame, 'incubator');
      expect(incubator['bulb_on'], isFalse);
      expect(incubator['humidifier_on'], isFalse,
          reason: 'humidification must stop above the over-temperature cutoff');
      expect(incubator['fan_on'], isTrue);
    }

    // Sensor loss after an overheat must still end in the all-off state.
    final overheatIndex = telemetry.indexOf(hot.first);
    expect(
      telemetry.skip(overheatIndex + 1).any(
            (f) => _room(f, 'incubator')['valid'] == false,
          ),
      isTrue,
      reason: 'scenario must combine overheat with a later sensor loss',
    );
  });

  test('heater follows the 37.5 / 38.0 C hysteresis band', () {
    expect(_frameWithIncubator(telemetry, 37.4, bulbOn: true), isNotNull);
    expect(_frameWithIncubator(telemetry, 38.3, bulbOn: false), isNotNull);

    final offAt38 = telemetry.indexWhere(
      (f) => _frameHasIncubator(f, heatOffC, bulbOn: false),
    );
    expect(offAt38, greaterThanOrEqualTo(0));

    final stillOff = telemetry.indexWhere(
      (f) => _frameHasIncubator(f, 37.6, bulbOn: false),
      offAt38 + 1,
    );
    expect(stillOff, greaterThan(offAt38),
        reason: 'heater must not re-enable at 37.6 C after switching off at 38.0 C');

    final backOn = telemetry.indexWhere(
      (f) => _frameHasIncubator(f, heatOnC, bulbOn: true),
      stillOff + 1,
    );
    expect(backOn, greaterThan(stillOff),
        reason: 'heater must re-enable at/below $heatOnC C');
  });

  test('humidifier follows the 45 / 55 percent hysteresis band', () {
    final onAt449 = telemetry.indexWhere(
      (f) => _frameHasIncubator(f, 37.5, humidity: 44.9, humidifierOn: true),
    );
    expect(onAt449, greaterThanOrEqualTo(0));

    final stillOn = telemetry.indexWhere(
      (f) => _frameHasIncubator(f, 37.5, humidity: 54.9, humidifierOn: true),
      onAt449 + 1,
    );
    expect(stillOn, greaterThan(onAt449));

    final offAt55 = telemetry.indexWhere(
      (f) => _frameHasIncubator(f, 37.5, humidity: humidityHigh, humidifierOn: false),
      stillOn + 1,
    );
    expect(offAt55, greaterThan(stillOn),
        reason: 'humidifier must stop at/above $humidityHigh %');

    final backOn = telemetry.indexWhere(
      (f) => _frameHasIncubator(f, 37.5, humidity: 44.9, humidifierOn: true),
      offAt55 + 1,
    );
    expect(backOn, greaterThan(offAt55),
        reason: 'humidifier must restart below $humidityLow %');
  });

  test('brooder control and sensor fail-safe are independent of the incubator',
      () {
    final invalid = telemetry
        .where((f) => _room(f, 'brooder')['valid'] == false)
        .toList();
    expect(invalid, isNotEmpty);
    for (final frame in invalid) {
      expect(_room(frame, 'brooder')['bulb_on'], isFalse);
      expect(_room(frame, 'brooder')['humidifier_on'], isFalse);
    }

    expect(_frameWithBrooder(telemetry, 29.5, bulbOn: true), isNotNull);
    expect(_frameWithBrooder(telemetry, 32.0, bulbOn: false), isNotNull);
    expect(_frameWithBrooder(telemetry, 31.0, humidity: 44.9, humidifierOn: true),
        isNotNull);
    expect(_frameWithBrooder(telemetry, 31.0, humidity: 60.0, humidifierOn: false),
        isNotNull);
  });
}

Map<String, dynamic> _decodeObject(String line) {
  expect(line, isNotEmpty, reason: 'blank line inside capture');
  final decoded = jsonDecode(line);
  expect(decoded, isA<Map<String, dynamic>>(),
      reason: 'line is not one JSON object: $line');
  return decoded as Map<String, dynamic>;
}

Map<String, dynamic> _room(Map<String, dynamic> frame, String room) {
  final block = frame[room];
  expect(block, isA<Map<String, dynamic>>(), reason: 'missing $room block');
  return block as Map<String, dynamic>;
}

bool _near(Object? value, num target) =>
    value is num && (value - target).abs() <= 0.05;

bool _frameHasIncubator(
  Map<String, dynamic> frame,
  num temperature, {
  num? humidity,
  bool? bulbOn,
  bool? humidifierOn,
}) {
  if (frame['type'] != 'telemetry') return false;
  final incubator = _room(frame, 'incubator');
  if (incubator['valid'] != true) return false;
  if (!_near(incubator['temperature_c'], temperature)) return false;
  if (humidity != null && !_near(incubator['humidity_percent'], humidity)) {
    return false;
  }
  if (bulbOn != null && incubator['bulb_on'] != bulbOn) return false;
  if (humidifierOn != null &&
      incubator['humidifier_on'] != humidifierOn) {
    return false;
  }
  return true;
}

bool _frameHasBrooder(
  Map<String, dynamic> frame,
  num temperature, {
  num? humidity,
  bool? bulbOn,
  bool? humidifierOn,
}) {
  if (frame['type'] != 'telemetry') return false;
  final brooder = _room(frame, 'brooder');
  if (brooder['valid'] != true) return false;
  if (!_near(brooder['temperature_c'], temperature)) return false;
  if (humidity != null && !_near(brooder['humidity_percent'], humidity)) {
    return false;
  }
  if (bulbOn != null && brooder['bulb_on'] != bulbOn) return false;
  if (humidifierOn != null && brooder['humidifier_on'] != humidifierOn) {
    return false;
  }
  return true;
}

Map<String, dynamic>? _frameWithIncubator(
  List<Map<String, dynamic>> telemetry,
  num temperature, {
  bool? bulbOn,
}) {
  for (final frame in telemetry) {
    if (_frameHasIncubator(frame, temperature, bulbOn: bulbOn)) return frame;
  }
  return null;
}

Map<String, dynamic>? _frameWithBrooder(
  List<Map<String, dynamic>> telemetry,
  num temperature, {
  num? humidity,
  bool? bulbOn,
  bool? humidifierOn,
}) {
  for (final frame in telemetry) {
    if (_frameHasBrooder(
      frame,
      temperature,
      humidity: humidity,
      bulbOn: bulbOn,
      humidifierOn: humidifierOn,
    )) {
      return frame;
    }
  }
  return null;
}
