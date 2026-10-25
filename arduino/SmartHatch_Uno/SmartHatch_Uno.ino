#include <DHT.h>
#include <Servo.h>
#include <EEPROM.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

// ============================================================
// SMARTHATCH AUTOMATION
// Keeps the original Arduino pin assignments and DHT11 sensors.
// Both DHT11 sensors are sampled every 2 seconds. Actuator automation starts
// only after the UI/UX sends a valid EGG:<type> command.
// ============================================================

#define DHT_TYPE DHT11

// Automatic control is enabled. Incubator automation starts only after
// the UI sends EGG:CHICKEN, EGG:DUCK, or EGG:QUAIL.
const bool ENABLE_INCUBATOR_CONTROL = true;
const bool ENABLE_BROODER_CONTROL = true;

// Incubator temperature control (forced-air incubator, starting values)
const float INCUBATOR_HEAT_ON_BELOW_C  = 37.3;
const float INCUBATOR_HEAT_OFF_ABOVE_C = 37.7;
const float INCUBATOR_EXHAUST_ON_ABOVE_C = 37.7;
const float INCUBATOR_EXHAUST_OFF_BELOW_C = 37.5;

// Intervals
const unsigned long SENSOR_READ_INTERVAL_MS = 2000UL;
const unsigned long ONE_DAY_MS = 86400000UL;
const unsigned long SERVO_TURN_INTERVAL_MS = 2UL * 60UL * 60UL * 1000UL; // every 2 hours

// Servo: keep home angle from the original code. Calibrate side angles
// to your actual egg-tray mechanism before operating with eggs.
const int INCUBATOR_SERVO_HOME_ANGLE = 90;
const int INCUBATOR_SERVO_SIDE_A_ANGLE = 45;
const int INCUBATOR_SERVO_SIDE_B_ANGLE = 135;

// ============================================================
// ORIGINAL PIN ASSIGNMENTS -- UNCHANGED
// ============================================================
const byte EXHAUST_INTAKE_RELAY_PIN = 9;   // 4-channel IN1
const byte INCUBATOR_BULB_RELAY_PIN = 10;  // 4-channel IN2
const byte BROODER_BULB_RELAY_PIN = 11;    // 4-channel IN3
const byte INCUBATOR_FAN_RELAY_PIN = 12;   // 4-channel IN4
const byte BROODER_HUMIDIFIER_RELAY_PIN = 5;    // 2-channel IN1
const byte INCUBATOR_HUMIDIFIER_RELAY_PIN = 6;  // 2-channel IN2
const byte INCUBATOR_DHT_PIN = 2;
const byte INCUBATOR_BUZZER_PIN = 7;
const byte BROODER_DHT_PIN = 4;
const byte BROODER_BUZZER_PIN = 8;
const byte INCUBATOR_SERVO_PIN = 3;

const bool RELAY_ACTIVE_LOW = true;

DHT incubatorDht(INCUBATOR_DHT_PIN, DHT_TYPE);
DHT brooderDht(BROODER_DHT_PIN, DHT_TYPE);
Servo incubatorServo;

// ============================================================
// EGG SELECTION AND AUTOMATION STATE
// ============================================================
enum EggType : byte { EGG_NONE = 0, EGG_CHICKEN, EGG_DUCK, EGG_QUAIL };
EggType selectedEgg = EGG_NONE;

// Initial day is Day 8, as requested. Current day is saved in EEPROM.
const byte EEPROM_MAGIC_ADDRESS = 0;
const byte EEPROM_DAY_ADDRESS = 1;
const byte EEPROM_MAGIC_VALUE = 0x53;
int incubationDay = 8;
unsigned long lastIncubationDayTick = 0;

// Brooder counting begins only when the UI sends BROODER_START after
// hatchlings have physically been moved into the brooder.
bool brooderActive = false;
int brooderDay = 0;
unsigned long lastBrooderDayTick = 0;

bool incubatorBulbOn = false;
bool incubatorHumidifierOn = false;
bool brooderBulbOn = false;
bool brooderHumidifierOn = false;
bool exhaustFanOn = false;

unsigned long lastSensorRead = 0;
unsigned long lastServoTurn = 0;
bool servoAtSideB = false;
bool servoHadBeenTurning = false;

char serialLine[48];
byte serialLineLength = 0;

// ============================================================
// BASIC OUTPUT HELPERS
// ============================================================
void setRelay(byte pin, bool on) {
  bool outputHigh = RELAY_ACTIVE_LOW ? !on : on;
  digitalWrite(pin, outputHigh ? HIGH : LOW);
}

void setBuzzer(byte pin, bool on) {
  digitalWrite(pin, on ? HIGH : LOW);
}

void allOutputsOff() {
  setRelay(EXHAUST_INTAKE_RELAY_PIN, false);
  setRelay(INCUBATOR_BULB_RELAY_PIN, false);
  setRelay(BROODER_BULB_RELAY_PIN, false);
  setRelay(INCUBATOR_FAN_RELAY_PIN, false);
  setRelay(BROODER_HUMIDIFIER_RELAY_PIN, false);
  setRelay(INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
  setBuzzer(INCUBATOR_BUZZER_PIN, false);
  setBuzzer(BROODER_BUZZER_PIN, false);
}

const char* eggName(EggType egg) {
  switch (egg) {
    case EGG_CHICKEN: return "CHICKEN";
    case EGG_DUCK:    return "DUCK";
    case EGG_QUAIL:   return "QUAIL";
    default:          return "NONE";
  }
}

int incubationDurationDays() {
  switch (selectedEgg) {
    case EGG_CHICKEN: return 21;
    case EGG_DUCK:    return 28; // common domestic duck; breed may vary
    case EGG_QUAIL:   return 18; // common Coturnix quail; species may vary
    default:          return 28;
  }
}

// Day on which turning must have stopped. The condition below stops
// turning at the start of this day.
int stopTurningDay() {
  switch (selectedEgg) {
    case EGG_CHICKEN: return 18;
    case EGG_DUCK:    return 25;
    case EGG_QUAIL:   return 14;
    default:          return 1;
  }
}

// Humidity lockdown begins one day after the chicken turn-stop day,
// Day 26 for common domestic ducks, and Day 15 for common Coturnix quail.
int lockdownHumidityStartDay() {
  switch (selectedEgg) {
    case EGG_CHICKEN: return 19;
    case EGG_DUCK:    return 26;
    case EGG_QUAIL:   return 15;
    default:          return 99;
  }
}

void saveIncubationDay() {
  EEPROM.update(EEPROM_MAGIC_ADDRESS, EEPROM_MAGIC_VALUE);
  EEPROM.update(EEPROM_DAY_ADDRESS, (byte)incubationDay);
}

void loadIncubationDay() {
  byte magic = EEPROM.read(EEPROM_MAGIC_ADDRESS);
  byte savedDay = EEPROM.read(EEPROM_DAY_ADDRESS);
  if (magic == EEPROM_MAGIC_VALUE && savedDay >= 1 && savedDay <= 40) {
    incubationDay = savedDay;
  } else {
    incubationDay = 8;
    saveIncubationDay();
  }
}

void setIncubationDayFromCommand(int day) {
  if (day < 1) day = 1;
  if (day > 40) day = 40;
  incubationDay = day;
  lastIncubationDayTick = millis();
  saveIncubationDay();
}

// ============================================================
// SPECIES-SPECIFIC INCUBATOR HUMIDITY TARGETS
// ============================================================
void getIncubatorHumidityLimits(float &lowPercent, float &highPercent) {
  bool lockdown = incubationDay >= lockdownHumidityStartDay();

  if (lockdown) {
    switch (selectedEgg) {
      case EGG_CHICKEN:
        lowPercent = 65.0; highPercent = 70.0; return;
      case EGG_DUCK:
        lowPercent = 65.0; highPercent = 75.0; return;
      case EGG_QUAIL:
        lowPercent = 65.0; highPercent = 70.0; return;
      default:
        lowPercent = 55.0; highPercent = 65.0; return;
    }
  }

  switch (selectedEgg) {
    case EGG_CHICKEN:
    case EGG_QUAIL:
      lowPercent = 45.0; highPercent = 55.0; return;
    case EGG_DUCK:
      lowPercent = 55.0; highPercent = 60.0; return;
    default:
      lowPercent = 50.0; highPercent = 60.0; return;
  }
}

// ============================================================
// BROODER STAGE TEMPERATURE
// Based on the uploaded SmartHatch Brooder Stages reference guide.
// Chicken/quail ranges are represented by their midpoints. Duck values
// are interpolated between the guide's approximate age milestones.
// ============================================================
float getBrooderTargetC(int day) {
  if (day < 1) day = 1;

  if (selectedEgg == EGG_DUCK) {
    const int days[6] = {1, 7, 14, 21, 28, 35};
    const float temps[6] = {30.0, 27.0, 23.0, 19.0, 15.0, 13.0};
    if (day <= days[0]) return temps[0];
    for (byte i = 0; i < 5; i++) {
      if (day <= days[i + 1]) {
        float fraction = (float)(day - days[i]) / (float)(days[i + 1] - days[i]);
        return temps[i] + fraction * (temps[i + 1] - temps[i]);
      }
    }
    return 13.0;
  }

  // Chicken and quail weekly ranges converted to midpoint targets.
  if (day <= 7)  return 33.5; // 32-35 C
  if (day <= 14) return 30.5; // 29-32 C
  if (day <= 21) return 28.0; // 27-29 C
  if (day <= 28) return 25.5; // 24-27 C
  if (day <= 35) return 22.5; // 21-24 C
  return 21.0;                // ambient conditions may be sufficient
}

// ============================================================
// INCUBATOR AUTOMATION
// ============================================================
void controlIncubator(float temperatureC, float humidityPercent) {
  // Heating uses hysteresis to reduce relay chatter.
  if (temperatureC <= INCUBATOR_HEAT_ON_BELOW_C) incubatorBulbOn = true;
  if (temperatureC >= INCUBATOR_HEAT_OFF_ABOVE_C) incubatorBulbOn = false;
  setRelay(INCUBATOR_BULB_RELAY_PIN, incubatorBulbOn);

  float humidityLow, humidityHigh;
  getIncubatorHumidityLimits(humidityLow, humidityHigh);
  if (humidityPercent <= humidityLow) incubatorHumidifierOn = true;
  if (humidityPercent >= humidityHigh) incubatorHumidifierOn = false;
  setRelay(INCUBATOR_HUMIDIFIER_RELAY_PIN, incubatorHumidifierOn);

  // D12 is treated as the incubator air-circulation fan and runs while
  // an egg type is selected. D9 is an additional high-temperature vent.
  setRelay(INCUBATOR_FAN_RELAY_PIN, true);
  if (temperatureC >= INCUBATOR_EXHAUST_ON_ABOVE_C) exhaustFanOn = true;
  if (temperatureC <= INCUBATOR_EXHAUST_OFF_BELOW_C) exhaustFanOn = false;
  setRelay(EXHAUST_INTAKE_RELAY_PIN, exhaustFanOn);
}

bool eggTurningAllowed() {
  if (selectedEgg == EGG_NONE) return false;
  if (incubationDay >= stopTurningDay()) return false;
  if (incubationDay >= lockdownHumidityStartDay()) return false;
  return true;
}

void updateServoTurning() {
  if (!eggTurningAllowed()) {
    if (servoHadBeenTurning) {
      incubatorServo.write(INCUBATOR_SERVO_HOME_ANGLE);
      servoHadBeenTurning = false;
    }
    return;
  }

  if (millis() - lastServoTurn >= SERVO_TURN_INTERVAL_MS) {
    servoAtSideB = !servoAtSideB;
    incubatorServo.write(servoAtSideB ? INCUBATOR_SERVO_SIDE_B_ANGLE
                                      : INCUBATOR_SERVO_SIDE_A_ANGLE);
    lastServoTurn = millis();
    servoHadBeenTurning = true;
  }
}

// ============================================================
// BROODER AUTOMATION
// Humidity target is intentionally not automated from the reference guide:
// it does not prescribe one universal brooder RH target. Keep bedding dry.
// ============================================================
void controlBrooder(float temperatureC) {
  float targetC = getBrooderTargetC(brooderDay);
  if (temperatureC <= targetC - 0.5) brooderBulbOn = true;
  if (temperatureC >= targetC + 0.5) brooderBulbOn = false;
  setRelay(BROODER_BULB_RELAY_PIN, brooderBulbOn);

  // No universal brooder humidity setpoint is specified in the supplied guide.
  brooderHumidifierOn = false;
  setRelay(BROODER_HUMIDIFIER_RELAY_PIN, false);
}

void updateDayCounters() {
  unsigned long now = millis();

  // Count incubation days up to the normal incubation duration. The UI can
  // resync this with INCUBATION_DAY:n if the Arduino was powered off.
  if (selectedEgg != EGG_NONE) {
    while (now - lastIncubationDayTick >= ONE_DAY_MS) {
      lastIncubationDayTick += ONE_DAY_MS;
      if (incubationDay < incubationDurationDays()) {
        incubationDay++;
        saveIncubationDay();
      }
    }
  }

  if (brooderActive) {
    while (now - lastBrooderDayTick >= ONE_DAY_MS) {
      lastBrooderDayTick += ONE_DAY_MS;
      if (brooderDay < 60) brooderDay++;
    }
  }
}

// ============================================================
// SERIAL COMMANDS FROM UI/UX (end each command with newline)
// PING / HEARTBEAT -> PONG,SMARTHATCH (connection/heartbeat check)
// EGG:CHICKEN | EGG:DUCK | EGG:QUAIL
// INCUBATION_DAY:8  (can resync current day after restart)
// BROODER_START     (send once when hatchlings enter the brooder)
// BROODER_DAY:1     (resyncs brooder day and activates brooder control)
// BROODER_STOP
// ============================================================
void sendAck(const char *message) {
  Serial.print(F("ACK,"));
  Serial.println(message);
}

void handleCommand(char *command) {
  for (byte i = 0; command[i] != '\0'; i++) {
    command[i] = (char)toupper((unsigned char)command[i]);
  }

  // Connection handshake: the Flutter app sends PING\n after opening a port.
  // Only this firmware responds with the exact SmartHatch identifier.
  if (strcmp(command, "PING") == 0 || strcmp(command, "HEARTBEAT") == 0) {
    Serial.println(F("PONG,SMARTHATCH"));
    return;
  }

  if (strncmp(command, "EGG:", 4) == 0) {
    if (strcmp(command + 4, "NONE") == 0) {
      // Deselecting the egg type stops actuator automation, but both DHT11
      // sensors continue to be sampled and reported in STATUS messages.
      selectedEgg = EGG_NONE;
      brooderActive = false;
      incubatorBulbOn = false;
      incubatorHumidifierOn = false;
      brooderBulbOn = false;
      brooderHumidifierOn = false;
      exhaustFanOn = false;
      allOutputsOff();
      incubatorServo.write(INCUBATOR_SERVO_HOME_ANGLE);
      servoHadBeenTurning = false;
      sendAck("EGG_CLEARED");
      return;
    }

    EggType newEgg = EGG_NONE;
    if (strcmp(command + 4, "CHICKEN") == 0) newEgg = EGG_CHICKEN;
    else if (strcmp(command + 4, "DUCK") == 0) newEgg = EGG_DUCK;
    else if (strcmp(command + 4, "QUAIL") == 0) newEgg = EGG_QUAIL;
    else {
      sendAck("ERROR,UNKNOWN_EGG_TYPE");
      return;
    }

    selectedEgg = newEgg;
    // Do not count time from before the user selected an egg. The UI should
    // send INCUBATION_DAY:<current day> immediately after this command when
    // synchronizing a batch already in progress (e.g. Day 8).
    lastIncubationDayTick = millis();
    lastServoTurn = millis();
    servoAtSideB = false;
    servoHadBeenTurning = false;
    incubatorServo.write(INCUBATOR_SERVO_HOME_ANGLE);
    sendAck(eggName(selectedEgg));
    return;
  }

  if (strncmp(command, "INCUBATION_DAY:", 15) == 0) {
    if (selectedEgg == EGG_NONE) {
      sendAck("ERROR,SELECT_EGG_FIRST");
      return;
    }
    int day = atoi(command + 15);
    if (day >= 1 && day <= 40) {
      setIncubationDayFromCommand(day);
      sendAck("INCUBATION_DAY_SET");
    } else {
      sendAck("ERROR,INVALID_INCUBATION_DAY");
    }
    return;
  }

  if (strcmp(command, "BROODER_START") == 0) {
    if (selectedEgg == EGG_NONE) {
      sendAck("ERROR,SELECT_EGG_FIRST");
      return;
    }
    brooderActive = true;
    brooderDay = 1;
    lastBrooderDayTick = millis();
    brooderBulbOn = false;
    brooderHumidifierOn = false;
    sendAck("BROODER_DAY_1");
    return;
  }

  if (strncmp(command, "BROODER_DAY:", 12) == 0) {
    if (selectedEgg == EGG_NONE) {
      sendAck("ERROR,SELECT_EGG_FIRST");
      return;
    }
    int day = atoi(command + 12);
    if (day >= 1 && day <= 60) {
      brooderActive = true;
      brooderDay = day;
      lastBrooderDayTick = millis();
      sendAck("BROODER_DAY_SET");
    } else {
      sendAck("ERROR,INVALID_BROODER_DAY");
    }
    return;
  }

  if (strcmp(command, "BROODER_STOP") == 0) {
    brooderActive = false;
    brooderBulbOn = false;
    brooderHumidifierOn = false;
    setRelay(BROODER_BULB_RELAY_PIN, false);
    setRelay(BROODER_HUMIDIFIER_RELAY_PIN, false);
    sendAck("BROODER_STOPPED");
    return;
  }

  sendAck("ERROR,UNKNOWN_COMMAND");
}

void readSerialCommands() {
  while (Serial.available() > 0) {
    char c = (char)Serial.read();
    if (c == '\r') continue;

    if (c == '\n') {
      serialLine[serialLineLength] = '\0';
      if (serialLineLength > 0) handleCommand(serialLine);
      serialLineLength = 0;
    } else if (serialLineLength < sizeof(serialLine) - 1) {
      serialLine[serialLineLength++] = c;
    } else {
      serialLineLength = 0; // discard an overlong command
    }
  }
}

void printValueOrNA(float value, byte decimals) {
  if (isnan(value)) Serial.print(F("NA"));
  else Serial.print(value, decimals);
}

const char* currentIncubationStage() {
  if (selectedEgg == EGG_NONE) return "WAIT_SELECTION";
  if (incubationDay >= incubationDurationDays()) return "INCUBATION_COMPLETE";
  if (incubationDay >= lockdownHumidityStartDay()) return "LOCKDOWN";
  return "INCUBATION";
}

void printStatus(float incubatorT, float incubatorH, float brooderT, float brooderH,
                 bool incubatorReadingOK, bool brooderReadingOK) {
  Serial.print(F("STATUS,EGG=")); Serial.print(eggName(selectedEgg));
  Serial.print(F(",STAGE=")); Serial.print(currentIncubationStage());
  Serial.print(F(",INC_SENSOR_OK=")); Serial.print(incubatorReadingOK ? 1 : 0);
  Serial.print(F(",BROODER_SENSOR_OK=")); Serial.print(brooderReadingOK ? 1 : 0);
  Serial.print(F(",INCUBATION_DAY=")); Serial.print(incubationDay);
  Serial.print(F(",INCUBATION_TOTAL=")); Serial.print(incubationDurationDays());
  Serial.print(F(",LOCKDOWN="));
  Serial.print((selectedEgg != EGG_NONE && incubationDay >= lockdownHumidityStartDay()) ? 1 : 0);
  Serial.print(F(",TURNING=")); Serial.print(eggTurningAllowed() ? 1 : 0);
  Serial.print(F(",BROODER_ACTIVE=")); Serial.print(brooderActive ? 1 : 0);
  Serial.print(F(",BROODER_DAY=")); Serial.print(brooderDay);
  Serial.print(F(",BROODER_TARGET_C="));
  if (brooderActive && selectedEgg != EGG_NONE) Serial.print(getBrooderTargetC(brooderDay), 1);
  else Serial.print(F("NA"));
  Serial.print(F(",INC_T=")); printValueOrNA(incubatorT, 1);
  Serial.print(F(",INC_H=")); printValueOrNA(incubatorH, 1);
  Serial.print(F(",BROODER_T=")); printValueOrNA(brooderT, 1);
  Serial.print(F(",BROODER_H=")); printValueOrNA(brooderH, 1);
  Serial.print(F(",IBULB=")); Serial.print(incubatorBulbOn ? 1 : 0);
  Serial.print(F(",IHUM=")); Serial.print(incubatorHumidifierOn ? 1 : 0);
  Serial.print(F(",IFAN=")); Serial.print(selectedEgg != EGG_NONE ? 1 : 0);
  Serial.print(F(",VENT=")); Serial.print(exhaustFanOn ? 1 : 0);
  Serial.print(F(",BBULB=")); Serial.print(brooderBulbOn ? 1 : 0);
  Serial.print(F(",BHUM=")); Serial.println(brooderHumidifierOn ? 1 : 0);
}

// ============================================================
// SETUP AND LOOP
// ============================================================
void setup() {
  pinMode(EXHAUST_INTAKE_RELAY_PIN, OUTPUT);
  pinMode(INCUBATOR_BULB_RELAY_PIN, OUTPUT);
  pinMode(BROODER_BULB_RELAY_PIN, OUTPUT);
  pinMode(INCUBATOR_FAN_RELAY_PIN, OUTPUT);
  pinMode(BROODER_HUMIDIFIER_RELAY_PIN, OUTPUT);
  pinMode(INCUBATOR_HUMIDIFIER_RELAY_PIN, OUTPUT);
  pinMode(INCUBATOR_BUZZER_PIN, OUTPUT);
  pinMode(BROODER_BUZZER_PIN, OUTPUT);
  allOutputsOff();

  incubatorDht.begin();
  brooderDht.begin();

  incubatorServo.attach(INCUBATOR_SERVO_PIN);
  incubatorServo.write(INCUBATOR_SERVO_HOME_ANGLE);

  loadIncubationDay();
  lastIncubationDayTick = millis();
  lastServoTurn = millis();
  lastSensorRead = millis();

  Serial.begin(9600);
  Serial.println(F("READY,SMARTHATCH,9600"));
  Serial.println(F("INFO,SEND_PING_FOR_CONNECTION_CHECK"));
}

void loop() {
  readSerialCommands();
  updateDayCounters();
  updateServoTurning();

  if (millis() - lastSensorRead < SENSOR_READ_INTERVAL_MS) return;
  lastSensorRead = millis();

  float incubatorT = incubatorDht.readTemperature();
  float incubatorH = incubatorDht.readHumidity();
  float brooderT = brooderDht.readTemperature();
  float brooderH = brooderDht.readHumidity();

  bool incubatorReadingOK = !isnan(incubatorT) && !isnan(incubatorH);
  bool brooderReadingOK = !isnan(brooderT) && !isnan(brooderH);

  if (ENABLE_INCUBATOR_CONTROL && selectedEgg != EGG_NONE) {
    if (incubatorReadingOK) {
      controlIncubator(incubatorT, incubatorH);
      setBuzzer(INCUBATOR_BUZZER_PIN, false);
    } else {
      // Sensor failure: heater and humidifier OFF; circulation fan stays ON.
      incubatorBulbOn = false;
      incubatorHumidifierOn = false;
      exhaustFanOn = false;
      setRelay(INCUBATOR_BULB_RELAY_PIN, false);
      setRelay(INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
      setRelay(EXHAUST_INTAKE_RELAY_PIN, false);
      setRelay(INCUBATOR_FAN_RELAY_PIN, true);
      setBuzzer(INCUBATOR_BUZZER_PIN, true);
    }
  } else {
    incubatorBulbOn = false;
    incubatorHumidifierOn = false;
    exhaustFanOn = false;
    setRelay(INCUBATOR_BULB_RELAY_PIN, false);
    setRelay(INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
    setRelay(EXHAUST_INTAKE_RELAY_PIN, false);
    setRelay(INCUBATOR_FAN_RELAY_PIN, false);
    setBuzzer(INCUBATOR_BUZZER_PIN, false);
  }

  if (ENABLE_BROODER_CONTROL && brooderActive && selectedEgg != EGG_NONE) {
    if (brooderReadingOK) {
      controlBrooder(brooderT);
      setBuzzer(BROODER_BUZZER_PIN, false);
    } else {
      brooderBulbOn = false;
      brooderHumidifierOn = false;
      setRelay(BROODER_BULB_RELAY_PIN, false);
      setRelay(BROODER_HUMIDIFIER_RELAY_PIN, false);
      setBuzzer(BROODER_BUZZER_PIN, true);
    }
  } else {
    brooderBulbOn = false;
    brooderHumidifierOn = false;
    setRelay(BROODER_BULB_RELAY_PIN, false);
    setRelay(BROODER_HUMIDIFIER_RELAY_PIN, false);
    setBuzzer(BROODER_BUZZER_PIN, false);
  }

  printStatus(incubatorT, incubatorH, brooderT, brooderH,
              incubatorReadingOK, brooderReadingOK);
}
