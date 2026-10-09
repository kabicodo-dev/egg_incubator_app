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
}

/// Incubator and Brooder controller logic translated from the Arduino sketch.
/// This controller manages state, timer, stage calculation, relay evaluation,
/// sensor readings, and alerts.
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

  // Actuator / Relay states
  bool incubatorBulbState = false;
  bool incubatorHumidifierState = false;
  bool incubatorFanState = true; // Always ON by default for forced-air circulation
  bool exhaustFanState = false;
  bool brooderBulbState = false;
  bool brooderHumidifierState = false;

  // Egg turning tracking
  DateTime? lastEggTurnTime;

  // Brooder settings constants matching the Arduino sketch
  static const double brooderHeatOnBelow = 30.0;
  static const double brooderHeatOffAbove = 32.0;
  static const double brooderHumidityLow = 45.0;
  static const double brooderHumidityHigh = 60.0;

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

  // ============================================================
  // SENSOR UPDATES & RELAY CONTROL LOGIC
  // ============================================================

  /// Updates sensor values and evaluates relay states following the exact
  /// hysteresis rules from the Arduino sketch.
  void updateSensors({
    double? incTemp,
    double? incHumidity,
    double? broodTemp,
    double? broodHumidity,
  }) {
    incubatorTemperature = incTemp;
    incubatorHumidity = incHumidity;
    brooderTemperature = broodTemp;
    brooderHumidity = broodHumidity;

    _evaluateIncubatorHeating();
    _evaluateIncubatorHumidifier();
    _evaluateBrooderHeating();
    _evaluateBrooderHumidifier();

    notifyListeners();
  }

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

  /// Control Brooder Bulb with hysteresis (ON <= 30.0°C, OFF >= 32.0°C)
  void _evaluateBrooderHeating() {
    if (brooderTemperature == null || brooderTemperature!.isNaN) {
      brooderBulbState = false;
      return;
    }
    if (brooderTemperature! <= brooderHeatOnBelow) {
      brooderBulbState = true;
    } else if (brooderTemperature! >= brooderHeatOffAbove) {
      brooderBulbState = false;
    }
  }

  /// Control Brooder Humidifier (ON < 45%, OFF >= 60%)
  void _evaluateBrooderHumidifier() {
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
      brooderTemperature!.isNaN ||
      brooderHumidity!.isNaN;

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
    };
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
