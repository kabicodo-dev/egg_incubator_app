import 'dart:async';
import 'package:flutter/foundation.dart';

/// Represents the species incubation profile parameters matching the Arduino controller.
class IncubationProfile {
  final String speciesName;
  final int hatchDay;
  final int lockdownStartDay;
  final double temperatureTarget;
  final double heatOnBelow;
  final double heatOffAbove;
  final double activeHumidityLow;
  final double activeHumidityHigh;
  final double lockdownHumidityLow;
  final double lockdownHumidityHigh;
  final Duration eggTurnInterval;
  final int eepromMagic;

  const IncubationProfile({
    required this.speciesName,
    required this.hatchDay,
    required this.lockdownStartDay,
    required this.temperatureTarget,
    required this.heatOnBelow,
    required this.heatOffAbove,
    required this.activeHumidityLow,
    required this.activeHumidityHigh,
    required this.lockdownHumidityLow,
    required this.lockdownHumidityHigh,
    this.eggTurnInterval = const Duration(hours: 4),
    required this.eepromMagic,
  });

  /// Default Chicken profile matching SmartHatch_Chicken_Automatic_Stages.ino
  static const chicken = IncubationProfile(
    speciesName: 'Chicken',
    hatchDay: 21,
    lockdownStartDay: 19,
    temperatureTarget: 37.5,
    heatOnBelow: 37.5,
    heatOffAbove: 38.0,
    activeHumidityLow: 45.0,
    activeHumidityHigh: 55.0,
    lockdownHumidityLow: 65.0,
    lockdownHumidityHigh: 70.0,
    eggTurnInterval: Duration(hours: 4),
    eepromMagic: 0xC121,
  );

  /// Duck preset matching SmartHatch_Duck_Automatic_Stages.ino
  static const duck = IncubationProfile(
    speciesName: 'Duck',
    hatchDay: 28,
    lockdownStartDay: 26,
    temperatureTarget: 37.5,
    heatOnBelow: 37.5,
    heatOffAbove: 38.0,
    activeHumidityLow: 55.0,
    activeHumidityHigh: 60.0,
    lockdownHumidityLow: 70.0,
    lockdownHumidityHigh: 75.0,
    eggTurnInterval: Duration(hours: 4),
    eepromMagic: 0xD228,
  );

  /// Quail preset matching SmartHatch_Quail_Automatic_Stages.ino
  static const quail = IncubationProfile(
    speciesName: 'Quail',
    hatchDay: 18,
    lockdownStartDay: 15,
    temperatureTarget: 37.5,
    heatOnBelow: 37.5,
    heatOffAbove: 38.0,
    activeHumidityLow: 45.0,
    activeHumidityHigh: 55.0,
    lockdownHumidityLow: 65.0,
    lockdownHumidityHigh: 70.0,
    eggTurnInterval: Duration(hours: 4),
    eepromMagic: 0xA318,
  );

  /// List of all supported species profiles
  static const List<IncubationProfile> allProfiles = [chicken, duck, quail];

  /// Brooder starting guideline target low limit (°C) based on species and brooder day
  static double getBrooderTargetLow(String speciesName, int day) {
    final species = speciesName.toUpperCase();
    if (species == 'DUCK') {
      if (day <= 1) return 30.0;
      if (day <= 7) return 30.0 - (day - 1) * 0.5;
      if (day <= 14) return 27.0 - (day - 7) * (4.0 / 7.0);
      if (day <= 21) return 23.0 - (day - 14) * (4.0 / 7.0);
      if (day <= 28) return 19.0 - (day - 21) * (4.0 / 7.0);
      if (day <= 35) return 15.0 - (day - 28) * (2.0 / 7.0);
      return 13.0;
    } else {
      // Chicken and Quail share the standard weekly reduction schedule
      if (day <= 7) return 32.0;
      if (day <= 14) return 29.0;
      if (day <= 21) return 27.0;
      if (day <= 28) return 24.0;
      if (day <= 35) return 21.0;
      return 21.0;
    }
  }

  /// Brooder starting guideline target high limit (°C) based on species and brooder day
  static double getBrooderTargetHigh(String speciesName, int day) {
    final species = speciesName.toUpperCase();
    if (species == 'DUCK') {
      return getBrooderTargetLow(speciesName, day) + 2.0;
    } else {
      // Chicken and Quail
      if (day <= 7) return 35.0;
      if (day <= 14) return 32.0;
      if (day <= 21) return 29.0;
      if (day <= 28) return 27.0;
      if (day <= 35) return 24.0;
      return 21.0;
    }
  }
}

/// Incubator and Brooder controller logic translated from the Arduino sketch.
/// This controller manages state, timer, stage calculation, relay evaluation,
/// sensor readings, and alerts.

/// Source of a set of sensor readings.
///
/// Physical readings come from the Arduino telemetry stream; simulated
/// readings come from the local hardware-console slider preview. The two are
/// never mixed, and only fresh physical readings may be labeled "live".
enum SensorDataSource {
  /// Readings received from the physical Arduino hardware over serial.
  physical,
  /// Readings from the local simulator sliders (hardware console preview).
  simulated,
  /// No valid reading available (e.g. connected but no fresh telemetry yet).
  none,
}

class IncubatorController extends ChangeNotifier {
  /// Incubation and candling constants
  static const int defaultStartDay = 7; // Hatching starts after Day 7 candling (fertile eggs)
  static const int candlingDays = 7;
  static const int minEggCount = 6;
  static const int maxEggCount = 12;

  // Current active incubation profile (defaults to Chicken)
  IncubationProfile profile;

  // Batch starting configuration
  int startDay = defaultStartDay;
  int eggCount = minEggCount; // Starts from 6-12 eggs (0 is strictly not allowed)
  bool isFertileCandled = true; // Indicates eggs have passed Day 7 candling

  // Incubation batch timer state (tracks elapsed time in the incubator)
  int elapsedSeconds = 0;
  DateTime? batchStartTime;
  Timer? _tickerTimer;

  // Sensor Readings (Null if error / disconnected)
  double? incubatorTemperature;
  double? incubatorHumidity;
  double? brooderTemperature;
  double? brooderHumidity;

  /// Source of the latest sensor readings: physical (Arduino telemetry),
  /// simulated (local slider preview), or none (no valid reading available).
  ///
  /// Physical and simulated readings are never mixed: [updateSensors] records
  /// which source provided the current values so the UI can label live
  /// readings correctly and never present simulated data as live hardware.
  SensorDataSource _sensorSource = SensorDataSource.none;

  /// Receipt timestamp of the last physical (Arduino) sensor reading, used for
  /// staleness checks. Null when no physical reading has ever been received.
  DateTime? _lastPhysicalReceivedAt;

  /// Staleness window for physical readings. Matches the ArduinoController
  /// staleness window (HW-01) so a reading is "live" only while fresh.
  static const Duration sensorStaleAfter = Duration(seconds: 6);

  // Actuator / Relay states
  bool incubatorBulbState = false;
  bool incubatorHumidifierState = false;
  bool incubatorFanState = true; // Always ON by default for forced-air circulation
  bool exhaustFanState = false;
  bool brooderBulbState = false;
  bool brooderHumidifierState = false;

  // Egg turning tracking
  DateTime? lastEggTurnTime;

// Post-incubation Brooder Stage controls (matching Arduino Uno Brooder Controller)
  bool brooderStarted = false;
  int brooderDay = 1;
  DateTime? brooderStartTime;
  bool brooderBuzzerAlarm = false;
  String? brooderAlarmMessage;

  /// When an Arduino is connected, relay states come from hardware telemetry
  /// (and user commands) instead of the local hysteresis evaluation.
  bool externalControl = false;

  // Brooder settings constants matching the Arduino sketch
  static const double brooderHumidityLow = 45.0;
  static const double brooderHumidityHigh = 60.0;

  /// Dynamic target low temperature for the current brooder day
  double get brooderTargetLow =>
      IncubationProfile.getBrooderTargetLow(profile.speciesName, brooderDay);

  /// Dynamic target high temperature for the current brooder day
  double get brooderTargetHigh =>
      IncubationProfile.getBrooderTargetHigh(profile.speciesName, brooderDay);

IncubatorController({
  this.profile = IncubationProfile.chicken,
  int initialEggs = minEggCount,
  int initialDay = defaultStartDay,
}) {
    startNewBatch(profile, initialEggs, initialDay);
    _startTicker();
  }

  // ============================================================
  // EGG COUNT & VALIDATION LOGIC
  // ============================================================

  /// Validates egg count according to SmartHatch specifications:
  /// - The system shall NOT allow 0 eggs.
  /// - Valid egg range is between 6 and 12 eggs.
  static String? validateEggCount(int? count) {
    if (count == null || count == 0) {
      return 'Egg count cannot be 0. The system does not allow 0 eggs.';
    }
    if (count < minEggCount) {
      return 'Minimum batch size is $minEggCount fertile eggs. Received: $count';
    }
    if (count > maxEggCount) {
      return 'Maximum batch capacity is $maxEggCount fertile eggs. Received: $count';
    }
    return null;
  }

  /// Sets the number of fertile eggs in the incubator batch (strictly 6 to 12 eggs)
  void setEggCount(int count) {
    final validationError = validateEggCount(count);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }
    eggCount = count;
    notifyListeners();
  }

  // ============================================================
  // BATCH & TIMER LOGIC
  // ============================================================

  /// Starts a new batch starting after Day 7 candling with fertile eggs (6 to 12 eggs).
  /// Strictly prevents starting with 0 eggs.
  void startNewBatch([
    IncubationProfile? newProfile,
    int? eggs,
    int? initialDay,
  ]) {
    final targetEggs = eggs ?? eggCount;
    final targetStartDay = initialDay ?? startDay;

    // Strict validation: system shall not allow 0 eggs
    final validationError = validateEggCount(targetEggs);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    if (newProfile != null) {
      profile = newProfile;
    }
    eggCount = targetEggs;
    startDay = targetStartDay;
    isFertileCandled = true;
    elapsedSeconds = 0;
    batchStartTime = DateTime.now();
    lastEggTurnTime = DateTime.now();
    incubatorBulbState = false;
    incubatorHumidifierState = false;
    brooderBulbState = false;
    brooderHumidifierState = false;
    notifyListeners();
  }

  /// Starts a 1-second ticker to update incubation time in real time
  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (batchStartTime != null) {
        final totalElapsed = DateTime.now().difference(batchStartTime!).inSeconds;
        final totalRemainingDays = profile.hatchDay - startDay;
        final maxSeconds = totalRemainingDays > 0 ? totalRemainingDays * 86400 : 0;
        elapsedSeconds = totalElapsed.clamp(0, maxSeconds);
        notifyListeners();
      }
    });
  }

  /// Calculates current incubation day starting from Day 7 (after 7 days candling)
  /// e.g. Day 7, Day 8, up to hatchDay.
  int get currentIncubationDay {
    final day = startDay + (elapsedSeconds ~/ 86400);
    return day > profile.hatchDay ? profile.hatchDay : day;
  }

  /// Determines if the batch has entered the Lockdown / Hatching stage
  bool get isLockdown => currentIncubationDay >= profile.lockdownStartDay;

  /// Determines if incubation has reached final hatch day
  bool get isBatchComplete =>
      currentIncubationDay >= profile.hatchDay &&
      elapsedSeconds >= ((profile.hatchDay - startDay) * 86400);

  /// Returns textual stage name
  String get stageName {
    if (isBatchComplete) return 'BATCH COMPLETE';
    if (isLockdown) return 'LOCKDOWN / HATCHING';
    return 'ACTIVE INCUBATION';
  }

  /// Current target humidity low limit based on stage
  double get humidityLowLimit =>
      isLockdown ? profile.lockdownHumidityLow : profile.activeHumidityLow;

  /// Current target humidity high limit based on stage
  double get humidityHighLimit =>
      isLockdown ? profile.lockdownHumidityHigh : profile.activeHumidityHigh;

  /// Returns remaining time until lockdown or hatch from the current day
  Duration get remainingTime {
    final totalDurationSeconds = (profile.hatchDay - startDay) * 86400;
    final remainingSec = totalDurationSeconds - elapsedSeconds;
    return Duration(
      seconds: remainingSec.clamp(0, totalDurationSeconds > 0 ? totalDurationSeconds : 0),
    );
  }

  /// Starts the post-incubation brooding stage (triggered via UI or physical A0 button)
  void startBrooding() {
    brooderStarted = true;
    brooderStartTime = DateTime.now();
    brooderDay = 1;
    brooderBulbState = false;
    brooderBuzzerAlarm = false;
    brooderAlarmMessage = null;
    _evaluateBrooderHeating();
    _evaluateBrooderHumidifier();
    notifyListeners();
  }

  /// Stops or resets the brooder stage
  void stopBrooding() {
    brooderStarted = false;
    brooderBulbState = false;
    brooderBuzzerAlarm = false;
    brooderAlarmMessage = null;
    notifyListeners();
  }

  /// Sets or simulates the current brooder day (Day 1 - 42)
  void setBrooderDay(int day) {
    brooderDay = day.clamp(1, 60);
    _evaluateBrooderHeating();
    notifyListeners();
  }

  // ============================================================
  // SENSOR UPDATES & RELAY CONTROL LOGIC
  // ============================================================

  /// Updates sensor values and evaluates relay states following the exact
  /// hysteresis rules from the Arduino sketch.
  ///
  /// [source] records where the readings came from so physical and simulated
  /// values are never mixed and only fresh physical readings are labeled live.
  /// When [source] is [SensorDataSource.physical], [receivedAt] is the
  /// app-side receipt timestamp of the telemetry frame (used for staleness).
  void updateSensors({
    double? incTemp,
    double? incHumidity,
    double? broodTemp,
    double? broodHumidity,
    SensorDataSource source = SensorDataSource.none,
    DateTime? receivedAt,
  }) {
    incubatorTemperature = incTemp;
    incubatorHumidity = incHumidity;
    brooderTemperature = broodTemp;
    brooderHumidity = broodHumidity;

    _sensorSource = source;
    if (source == SensorDataSource.physical && receivedAt != null) {
      _lastPhysicalReceivedAt = receivedAt;
    }

    // While an Arduino owns the relays, keep the readings but do not override
    // its reported actuator states with local hysteresis.
    if (!externalControl) {
      _evaluateIncubatorHeating();
      _evaluateIncubatorHumidifier();
      _evaluateBrooderHeating();
      _evaluateBrooderHumidifier();
    }

    notifyListeners();
  }

  /// Source of the current sensor readings.
  SensorDataSource get sensorSource => _sensorSource;

  /// Receipt timestamp of the last physical (Arduino) sensor reading.
  DateTime? get sensorLastReceivedAt => _lastPhysicalReceivedAt;

  /// True only when the current readings are fresh physical (live) readings.
  ///
  /// Simulated readings are never live, and a physical reading older than
  /// [sensorStaleAfter] is stale and not live. Individual chamber values may
  /// still be `null` (sensor error) even while the frame is live; those are
  /// reported separately via [hasIncubatorSensorError] /
  /// [hasBrooderSensorError] and shown as 'ERROR' by the UI.
  bool get sensorsAreLive =>
      _sensorSource == SensorDataSource.physical &&
      _lastPhysicalReceivedAt != null &&
      DateTime.now().difference(_lastPhysicalReceivedAt!) <= sensorStaleAfter;

  /// True when the current readings are simulated (never labeled live).
  bool get sensorsAreSimulated => _sensorSource == SensorDataSource.simulated;

  /// Applies relay states reported by the connected Arduino.
  void applyActuatorStates(Map<String, bool> states) {
    if (states.containsKey('incubatorBulb')) {
      incubatorBulbState = states['incubatorBulb']!;
    }
    if (states.containsKey('incubatorHumidifier')) {
      incubatorHumidifierState = states['incubatorHumidifier']!;
    }
    if (states.containsKey('incubatorFan')) {
      incubatorFanState = states['incubatorFan']!;
    }
    if (states.containsKey('exhaustFan')) {
      exhaustFanState = states['exhaustFan']!;
    }
    if (states.containsKey('brooderBulb')) {
      brooderBulbState = states['brooderBulb']!;
    }
    if (states.containsKey('brooderHumidifier')) {
      brooderHumidifierState = states['brooderHumidifier']!;
    }
    notifyListeners();
  }

  /// Scheduled egg turns per day from the profile's interval (0 during
  /// lockdown, when turning is halted).
  int get scheduledTurnsPerDay =>
      isLockdown ? 0 : (1440 ~/ profile.eggTurnInterval.inMinutes);

  /// Control Incubator Bulb with hysteresis (ON <= 37.5°C, OFF >= 38.0°C)
  void _evaluateIncubatorHeating() {
    if (incubatorTemperature == null || incubatorTemperature!.isNaN) {
      incubatorBulbState = false;
      return;
    }
    if (incubatorTemperature! <= profile.heatOnBelow) {
      incubatorBulbState = true;
    } else if (incubatorTemperature! >= profile.heatOffAbove) {
      incubatorBulbState = false;
    }
  }

  /// Control Incubator Humidifier based on stage low/high limits
  void _evaluateIncubatorHumidifier() {
    if (incubatorHumidity == null || incubatorHumidity!.isNaN) {
      incubatorHumidifierState = false;
      return;
    }
    if (incubatorHumidity! < humidityLowLimit) {
      incubatorHumidifierState = true;
    } else if (incubatorHumidity! >= humidityHighLimit) {
      incubatorHumidifierState = false;
    }
  }

  /// Control Brooder Bulb with species/day target schedule and safety cutoff.
  /// Matches Arduino Uno SmartHatch Post-Incubation Brooder Controller.
  void _evaluateBrooderHeating() {
    if (!brooderStarted) {
      brooderBulbState = false;
      brooderBuzzerAlarm = false;
      brooderAlarmMessage = null;
      return;
    }

    // Sensor failure: switch heater off and sound alarm (D8 buzzer)
    if (brooderTemperature == null ||
        brooderTemperature!.isNaN ||
        brooderHumidity == null ||
        brooderHumidity!.isNaN) {
      brooderBulbState = false;
      brooderBuzzerAlarm = true;
      brooderAlarmMessage = 'ERROR: Brooder DHT11 reading failed! Brooder bulb OFF.';
      return;
    }

    final low = brooderTargetLow;
    final high = brooderTargetHigh;

    // Conservative safety cutoff (< 10°C or > 40°C)
    if (brooderTemperature! < 10.0 || brooderTemperature! > 40.0) {
      brooderBulbState = false;
      brooderBuzzerAlarm = true;
      brooderAlarmMessage =
          'CRITICAL SAFETY CUTOFF: Brooder temperature (${brooderTemperature!.toStringAsFixed(1)}°C) out of safe range (10–40°C)! Bulb OFF.';
    } else {
      brooderBuzzerAlarm = false;
      brooderAlarmMessage = null;

      // Hysteresis: avoid rapid relay switching.
      if (brooderTemperature! < low) {
        brooderBulbState = true;
      } else if (brooderTemperature! >= high) {
        brooderBulbState = false;
      }
    }
  }

  /// Control Brooder Humidifier (ON < 45%, OFF >= 60%)
  void _evaluateBrooderHumidifier() {
    if (!brooderStarted) {
      brooderHumidifierState = false;
      return;
    }
    if (brooderHumidity == null || brooderHumidity!.isNaN) {
      brooderHumidifierState = false;
      return;
    }
    if (brooderHumidity! < brooderHumidityLow) {
      brooderHumidifierState = true;
    } else if (brooderHumidity! >= brooderHumidityHigh) {
      brooderHumidifierState = false;
    }
  }

  // ============================================================
  // TURNING & ALERT LOGIC
  // ============================================================

  /// Returns egg turning status
  String get eggTurningStatus {
    if (isLockdown) return 'STOPPED (LOCKDOWN)';
    return 'ACTIVE (EVERY 4 HOURS)';
  }

  /// Sensor error detection for incubator
  bool get hasIncubatorSensorError =>
      incubatorTemperature == null ||
      incubatorHumidity == null ||
      incubatorTemperature!.isNaN ||
      incubatorHumidity!.isNaN;

  /// Sensor error detection for brooder
  bool get hasBrooderSensorError =>
      brooderTemperature == null ||
      brooderHumidity == null ||
      brooderHumidity!.isNaN ||
      brooderTemperature!.isNaN;

  /// Generates the Serial / Supabase sync payload to transmit to Arduino
  Map<String, dynamic> toSyncPayload() {
    return {
      'species': profile.speciesName,
      'eeprom_magic': '0x${profile.eepromMagic.toRadixString(16).toUpperCase()}',
      'hatch_day': profile.hatchDay,
      'lockdown_day': profile.lockdownStartDay,
      'start_day': startDay,
      'candling_days': candlingDays,
      'egg_count': eggCount,
      'is_fertile_verified': isFertileCandled,
      'target_temperature': profile.temperatureTarget,
      'humidity_low': humidityLowLimit,
      'humidity_high': humidityHighLimit,
      'elapsed_seconds': elapsedSeconds,
      'current_day': currentIncubationDay,
      'stage': stageName,
      'turning_active': !isLockdown,
      'brooder_started': brooderStarted,
      'brooder_day': brooderDay,
      'brooder_target_low': brooderTargetLow,
      'brooder_target_high': brooderTargetHigh,
      'brooder_bulb_state': brooderBulbState,
      'brooder_buzzer_alarm': brooderBuzzerAlarm,
    };
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
