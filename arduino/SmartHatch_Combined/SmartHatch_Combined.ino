#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <DHT.h>
#include <Servo.h>
#include <EEPROM.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

/*
  SmartHatch_Combined_Controller_v6.ino
  Arduino Uno / wired USB serial controller.

  JSON line protocol (9600 baud, newline terminated):
    Windows -> Uno: {"id":101,"cmd":"STATUS"}
    Uno -> Windows: {"type":"ack","id":101,"cmd":"STATUS","status":"accepted","message":"status queued"}
    Uno -> Windows: {"type":"telemetry", ...}

  Commands: STATUS, NEW_BATCH, RESET, SELECT_CHICKEN, SELECT_DUCK,
            SELECT_QUAIL, TURN_NOW
  Legacy plain-text commands are also accepted for serial-monitor testing.

  SAFETY NOTES:
  - Invalid/stale DHT readings disable the associated controlled outputs.
  - On Uno, USB disconnect cannot be reliably detected by firmware. Local
    control continues; the Windows bridge should reconnect and request STATUS.
  - EEPROM progress is saved periodically; power-off time is NOT counted without
    an RTC/external clock. Stored species and elapsed runtime are restored.
  - Bench-test relay polarity, wiring, sensor failure behavior, servo limits,
    and the complete system before connecting a live incubator.
*/

#define DHT_TYPE DHT11

// Pins based on the SmartHatch wiring list supplied by the project.
const byte EXHAUST_FAN_RELAY_PIN = 9;       // 4-channel IN1
const byte INCUBATOR_BULB_RELAY_PIN = 10;   // 4-channel IN2
const byte BROODER_BULB_RELAY_PIN = 11;     // 4-channel IN3
const byte INCUBATOR_FAN_RELAY_PIN = 12;    // 4-channel IN4
const byte BROODER_HUMIDIFIER_RELAY_PIN = 5; // 2-channel IN1
const byte INCUBATOR_HUMIDIFIER_RELAY_PIN = 6; // 2-channel IN2
const byte INCUBATOR_DHT_PIN = 2;
const byte SERVO_PIN = 3;
const byte BROODER_DHT_PIN = 4;
const byte INCUBATOR_BUZZER_PIN = 7;
const byte BROODER_BUZZER_PIN = 8;

// Change only after physically verifying the relay module's input polarity.
const bool RELAY_ACTIVE_LOW = true;
const float INCUBATOR_HEAT_ON_C = 37.5f;
const float INCUBATOR_HEAT_OFF_C = 38.0f;
const float INCUBATOR_OVER_TEMP_C = 39.0f; // independent high-temperature cutoff
const float BROODER_HEAT_ON_C = 30.0f;
const float BROODER_HEAT_OFF_C = 32.0f;
const float BROODER_HUMIDITY_LOW = 45.0f;
const float BROODER_HUMIDITY_HIGH = 60.0f;
const unsigned long SENSOR_READ_INTERVAL_MS = 2500UL; // DHT11 minimum interval ~1s
const unsigned long SENSOR_STALE_TIMEOUT_MS = 10000UL;
const unsigned long TELEMETRY_INTERVAL_MS = 5000UL;
const unsigned long EEPROM_SAVE_INTERVAL_MS = 60000UL;
const unsigned long EGG_TURN_INTERVAL_MS = 4UL * 60UL * 60UL * 1000UL;
const unsigned long EXHAUST_OFF_MS = 30UL * 60UL * 1000UL;
const unsigned long EXHAUST_ON_MS = 30000UL;
const unsigned long BUZZER_ON_MS = 150UL;
const unsigned long BUZZER_OFF_MS = 850UL;
const int SERVO_LEFT = 0;
const int SERVO_RIGHT = 180;
const int SERVO_CENTER = 90;
const unsigned long SERVO_MOVE_DELAY_MS = 400UL;
const uint16_t EEPROM_MAGIC = 0x5636;
const int EEPROM_ADDRESS = 0;
const byte EEPROM_VERSION = 1;

// For production, confirm these values against the capstone's approved incubation reference.
enum EggType : byte { EGG_CHICKEN = 1, EGG_DUCK = 2, EGG_QUAIL = 3 };
EggType selectedEgg = EGG_CHICKEN;
byte hatchDay = 21;
byte lockdownStartDay = 19;
float activeHumidityLow = 45.0f, activeHumidityHigh = 55.0f;
float lockdownHumidityLow = 65.0f, lockdownHumidityHigh = 70.0f;

struct BatchState {
  uint16_t magic;
  byte version;
  byte eggType;
  uint32_t elapsedSeconds;
};
BatchState batchState;

DHT incubatorDHT(INCUBATOR_DHT_PIN, DHT_TYPE);
DHT brooderDHT(BROODER_DHT_PIN, DHT_TYPE);
Servo eggTurner;
LiquidCrystal_I2C lcd(0x27, 16, 2);

float incubatorTemperature = NAN, incubatorHumidity = NAN;
float brooderTemperature = NAN, brooderHumidity = NAN;
bool incubatorSensorValid = false, brooderSensorValid = false;
unsigned long lastIncubatorGoodRead = 0, lastBrooderGoodRead = 0;
unsigned long lastSensorRead = 0, lastTelemetry = 0, lastLcd = 0;
unsigned long lastProgressSave = 0, lastProgressTick = 0, lastEggTurn = 0;
unsigned long exhaustTimerStarted = 0;
bool incubatorBulbState = false, incubatorHumidifierState = false;
bool incubatorFanState = false, exhaustFanState = false;
bool brooderBulbState = false, brooderHumidifierState = false;
bool exhaustCycleOn = false;
bool incubatorHeatInitialized = false, incubatorHumidityInitialized = false;
bool brooderHeatInitialized = false, brooderHumidityInitialized = false;
char serialLine[120];
byte serialLineLength = 0;

// Recent command IDs protect side-effect commands from retransmission.
const byte ACK_CACHE_SIZE = 8;
struct AckCacheEntry { bool used; long id; char command[24]; char status[12]; char message[40]; };
AckCacheEntry ackCache[ACK_CACHE_SIZE];
byte ackCacheNext = 0;

const char* eggName() {
  if (selectedEgg == EGG_DUCK) return "duck";
  if (selectedEgg == EGG_QUAIL) return "quail";
  return "chicken";
}

void applyEggProfile(EggType type) {
  selectedEgg = type;
  if (type == EGG_CHICKEN) {
    hatchDay = 21; lockdownStartDay = 19;
    activeHumidityLow = 45; activeHumidityHigh = 55;
    lockdownHumidityLow = 65; lockdownHumidityHigh = 70;
  } else if (type == EGG_DUCK) {
    hatchDay = 28; lockdownStartDay = 26;
    activeHumidityLow = 55; activeHumidityHigh = 60;
    lockdownHumidityLow = 70; lockdownHumidityHigh = 75;
  } else {
    hatchDay = 18; lockdownStartDay = 15;
    activeHumidityLow = 45; activeHumidityHigh = 55;
    lockdownHumidityLow = 65; lockdownHumidityHigh = 70;
  }
}

void setRelay(byte pin, bool on) {
  digitalWrite(pin, RELAY_ACTIVE_LOW ? (on ? LOW : HIGH) : (on ? HIGH : LOW));
}
void initRelayOff(byte pin) {
  // Set output latch to OFF before switching pin to OUTPUT to reduce startup glitches.
  digitalWrite(pin, RELAY_ACTIVE_LOW ? HIGH : LOW);
  pinMode(pin, OUTPUT);
}

void allIncubatorControlledOutputsOff() {
  incubatorBulbState = false;
  incubatorHumidifierState = false;
  exhaustFanState = false;
  setRelay(INCUBATOR_BULB_RELAY_PIN, false);
  setRelay(INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
  setRelay(EXHAUST_FAN_RELAY_PIN, false);
}
void allBrooderControlledOutputsOff() {
  brooderBulbState = false;
  brooderHumidifierState = false;
  setRelay(BROODER_BULB_RELAY_PIN, false);
  setRelay(BROODER_HUMIDIFIER_RELAY_PIN, false);
}

void saveBatchState() {
  batchState.magic = EEPROM_MAGIC;
  batchState.version = EEPROM_VERSION;
  batchState.eggType = (byte)selectedEgg;
  EEPROM.put(EEPROM_ADDRESS, batchState);
}
byte incubationDay() {
  uint32_t d = batchState.elapsedSeconds / 86400UL + 1UL;
  if (d > hatchDay) d = hatchDay;
  return (byte)d;
}
bool lockdown() { return incubationDay() >= lockdownStartDay; }
bool batchComplete() { return batchState.elapsedSeconds >= (uint32_t)hatchDay * 86400UL; }
const char* stageName() {
  if (batchComplete()) return "complete";
  return lockdown() ? "lockdown" : "active";
}
float humidityLowTarget() { return lockdown() ? lockdownHumidityLow : activeHumidityLow; }
float humidityHighTarget() { return lockdown() ? lockdownHumidityHigh : activeHumidityHigh; }

void startNewBatch() {
  batchState.magic = EEPROM_MAGIC;
  batchState.version = EEPROM_VERSION;
  batchState.eggType = (byte)selectedEgg;
  batchState.elapsedSeconds = 0;
  saveBatchState();
  lastProgressTick = millis();
  lastProgressSave = millis();
  lastEggTurn = millis();
  incubatorHeatInitialized = false;
  incubatorHumidityInitialized = false;
  Serial.println(F("{\"type\":\"event\",\"event\":\"batch_started\",\"day\":1}"));
}

void loadBatchState() {
  EEPROM.get(EEPROM_ADDRESS, batchState);
  bool valid = batchState.magic == EEPROM_MAGIC &&
               batchState.version == EEPROM_VERSION &&
               batchState.eggType >= EGG_CHICKEN && batchState.eggType <= EGG_QUAIL &&
               batchState.elapsedSeconds <= 28UL * 86400UL;
  if (!valid) {
    applyEggProfile(EGG_CHICKEN);
    batchState.elapsedSeconds = 0;
    startNewBatch();
    return;
  }
  applyEggProfile((EggType)batchState.eggType);
  if (batchState.elapsedSeconds > (uint32_t)hatchDay * 86400UL)
    batchState.elapsedSeconds = (uint32_t)hatchDay * 86400UL;
  lastProgressTick = millis();
  lastProgressSave = millis();
  lastEggTurn = millis();
}

void updateIncubationTimer() {
  unsigned long now = millis();
  unsigned long delta = now - lastProgressTick;
  if (delta >= 1000UL) {
    uint32_t addSeconds = delta / 1000UL;
    uint32_t maxSeconds = (uint32_t)hatchDay * 86400UL;
    if (batchState.elapsedSeconds < maxSeconds) {
      uint32_t remaining = maxSeconds - batchState.elapsedSeconds;
      batchState.elapsedSeconds += (addSeconds > remaining) ? remaining : addSeconds;
    }
    lastProgressTick += addSeconds * 1000UL;
  }
  if (now - lastProgressSave >= EEPROM_SAVE_INTERVAL_MS) {
    saveBatchState();
    lastProgressSave = now;
  }
}

bool validDhtPair(float t, float h) {
  return !isnan(t) && !isnan(h) && t >= -20.0f && t <= 80.0f && h >= 0.0f && h <= 100.0f;
}
void readSensors() {
  unsigned long now = millis();
  if (now - lastSensorRead < SENSOR_READ_INTERVAL_MS) return;
  lastSensorRead = now;
  float t1 = incubatorDHT.readTemperature();
  float h1 = incubatorDHT.readHumidity();
  if (validDhtPair(t1, h1)) {
    incubatorTemperature = t1; incubatorHumidity = h1;
    incubatorSensorValid = true; lastIncubatorGoodRead = now;
  }
  float t2 = brooderDHT.readTemperature();
  float h2 = brooderDHT.readHumidity();
  if (validDhtPair(t2, h2)) {
    brooderTemperature = t2; brooderHumidity = h2;
    brooderSensorValid = true; lastBrooderGoodRead = now;
  }
}
void updateSensorValidity() {
  unsigned long now = millis();
  if (lastIncubatorGoodRead == 0 || now - lastIncubatorGoodRead > SENSOR_STALE_TIMEOUT_MS)
    incubatorSensorValid = false;
  if (lastBrooderGoodRead == 0 || now - lastBrooderGoodRead > SENSOR_STALE_TIMEOUT_MS)
    brooderSensorValid = false;
}

void controlIncubator() {
  if (!incubatorSensorValid) {
    allIncubatorControlledOutputsOff();
    incubatorHeatInitialized = false;
    incubatorHumidityInitialized = false;
    return;
  }
  // Independent over-temperature cutoff. This is not a substitute for a hardware thermal fuse.
  if (incubatorTemperature >= INCUBATOR_OVER_TEMP_C) {
    incubatorBulbState = false;
    setRelay(INCUBATOR_BULB_RELAY_PIN, false);
  } else {
    if (!incubatorHeatInitialized) {
      incubatorBulbState = incubatorTemperature < INCUBATOR_HEAT_OFF_C;
      incubatorHeatInitialized = true;
    }
    if (incubatorTemperature <= INCUBATOR_HEAT_ON_C) incubatorBulbState = true;
    if (incubatorTemperature >= INCUBATOR_HEAT_OFF_C) incubatorBulbState = false;
    setRelay(INCUBATOR_BULB_RELAY_PIN, incubatorBulbState);
  }
  if (!incubatorHumidityInitialized) {
    incubatorHumidifierState = incubatorHumidity < humidityLowTarget();
    incubatorHumidityInitialized = true;
  }
  if (incubatorHumidity < humidityLowTarget()) incubatorHumidifierState = true;
  if (incubatorHumidity >= humidityHighTarget()) incubatorHumidifierState = false;
  setRelay(INCUBATOR_HUMIDIFIER_RELAY_PIN, incubatorHumidifierState);

  // Forced-air circulation fan runs continuously when incubator sensor data is valid.
  incubatorFanState = true;
  setRelay(INCUBATOR_FAN_RELAY_PIN, true);
  controlExhaustFan();
}

void controlExhaustFan() {
  if (!incubatorSensorValid || lockdown() || batchComplete()) {
    exhaustCycleOn = false; exhaustFanState = false;
    setRelay(EXHAUST_FAN_RELAY_PIN, false); return;
  }
  unsigned long now = millis();
  unsigned long duration = exhaustCycleOn ? EXHAUST_ON_MS : EXHAUST_OFF_MS;
  if (now - exhaustTimerStarted >= duration) {
    exhaustCycleOn = !exhaustCycleOn;
    exhaustTimerStarted = now;
  }
  exhaustFanState = exhaustCycleOn;
  setRelay(EXHAUST_FAN_RELAY_PIN, exhaustFanState);
}

void controlBrooder() {
  if (!brooderSensorValid) { allBrooderControlledOutputsOff(); brooderHeatInitialized = false; brooderHumidityInitialized = false; return; }
  if (brooderTemperature <= BROODER_HEAT_ON_C) brooderBulbState = true;
  if (brooderTemperature >= BROODER_HEAT_OFF_C) brooderBulbState = false;
  setRelay(BROODER_BULB_RELAY_PIN, brooderBulbState);
  if (brooderHumidity < BROODER_HUMIDITY_LOW) brooderHumidifierState = true;
  if (brooderHumidity >= BROODER_HUMIDITY_HIGH) brooderHumidifierState = false;
  setRelay(BROODER_HUMIDIFIER_RELAY_PIN, brooderHumidifierState);
  brooderHeatInitialized = true; brooderHumidityInitialized = true;
}

void performEggTurn() {
  if (lockdown() || batchComplete() || !incubatorSensorValid) return;
  eggTurner.write(SERVO_LEFT); delay(SERVO_MOVE_DELAY_MS);
  eggTurner.write(SERVO_RIGHT); delay(SERVO_MOVE_DELAY_MS);
  eggTurner.write(SERVO_CENTER);
  Serial.println(F("{\"type\":\"event\",\"event\":\"egg_turn_completed\"}"));
}
void controlEggTurning() {
  if (lockdown() || batchComplete() || !incubatorSensorValid) return;
  if (millis() - lastEggTurn >= EGG_TURN_INTERVAL_MS) {
    lastEggTurn = millis();
    performEggTurn();
  }
}

void updateBuzzer(byte pin, bool error, byte index) {
  static unsigned long changedAt[2] = {0, 0};
  static bool state[2] = {false, false};
  unsigned long now = millis();
  if (!error) { state[index] = false; digitalWrite(pin, LOW); changedAt[index] = now; return; }
  unsigned long interval = state[index] ? BUZZER_ON_MS : BUZZER_OFF_MS;
  if (now - changedAt[index] >= interval) {
    state[index] = !state[index]; changedAt[index] = now;
    digitalWrite(pin, state[index] ? HIGH : LOW);
  }
}
void updateBuzzers() {
  updateBuzzer(INCUBATOR_BUZZER_PIN, !incubatorSensorValid, 0);
  updateBuzzer(BROODER_BUZZER_PIN, !brooderSensorValid, 1);
}

void printFloatOrNull(float value, byte decimals) {
  if (isnan(value)) Serial.print(F("null")); else Serial.print(value, decimals);
}
void printTelemetry() {
  Serial.print(F("{\"type\":\"telemetry\",\"uptime_ms\":")); Serial.print(millis());
  Serial.print(F(",\"egg_type\":\"")); Serial.print(eggName()); Serial.print(F("\",\"day\":")); Serial.print(incubationDay());
  Serial.print(F(",\"hatch_day\":")); Serial.print(hatchDay);
  Serial.print(F(",\"elapsed_seconds\":")); Serial.print(batchState.elapsedSeconds);
  Serial.print(F(",\"stage\":\"")); Serial.print(stageName()); Serial.print(F("\",\"batch_complete\":")); Serial.print(batchComplete() ? F("true") : F("false"));
  Serial.print(F(",\"incubator\":{\"valid\":")); Serial.print(incubatorSensorValid ? F("true") : F("false"));
  Serial.print(F(",\"temperature_c\":")); printFloatOrNull(incubatorTemperature, 1);
  Serial.print(F(",\"humidity_percent\":")); printFloatOrNull(incubatorHumidity, 1);
  Serial.print(F(",\"bulb_on\":")); Serial.print(incubatorBulbState ? F("true") : F("false"));
  Serial.print(F(",\"humidifier_on\":")); Serial.print(incubatorHumidifierState ? F("true") : F("false"));
  Serial.print(F(",\"fan_on\":")); Serial.print(incubatorFanState ? F("true") : F("false"));
  Serial.print(F(",\"exhaust_fan_on\":")); Serial.print(exhaustFanState ? F("true") : F("false")); Serial.print('}');
  Serial.print(F(",\"brooder\":{\"valid\":")); Serial.print(brooderSensorValid ? F("true") : F("false"));
  Serial.print(F(",\"temperature_c\":")); printFloatOrNull(brooderTemperature, 1);
  Serial.print(F(",\"humidity_percent\":")); printFloatOrNull(brooderHumidity, 1);
  Serial.print(F(",\"bulb_on\":")); Serial.print(brooderBulbState ? F("true") : F("false"));
  Serial.print(F(",\"humidifier_on\":")); Serial.print(brooderHumidifierState ? F("true") : F("false")); Serial.println(F("}}"));
}
void printLcd() {
  if (millis() - lastLcd < 1500UL) return;
  lastLcd = millis();
  lcd.setCursor(0, 0);
  if (!incubatorSensorValid) lcd.print(F("T:ERR    H:ERR  "));
  else { lcd.print(F("T:")); lcd.print(incubatorTemperature, 1); lcd.print(F("C H:")); lcd.print((int)incubatorHumidity); lcd.print(F("%   ")); }
  lcd.setCursor(0, 1); lcd.print(eggName()); lcd.print(F(" D"));
  byte d = incubationDay(); if (d < 10) lcd.print('0'); lcd.print(d); lcd.print('/');
  if (hatchDay < 10) lcd.print('0'); lcd.print(hatchDay);
  lcd.print(lockdown() ? F(" LOCK ") : F(" ACT  "));
}

void jsonEscapePrint(const char* s) { // Current command names/messages use safe ASCII only.
  while (*s) { if (*s == '"' || *s == '\\') Serial.print('\\'); Serial.print(*s++); }
}
void emitAck(long id, const char* cmd, const char* status, const char* message) {
  Serial.print(F("{\"type\":\"ack\",\"id\":")); Serial.print(id);
  Serial.print(F(",\"cmd\":\"")); jsonEscapePrint(cmd);
  Serial.print(F("\",\"status\":\"")); jsonEscapePrint(status);
  Serial.print(F("\",\"message\":\"")); jsonEscapePrint(message); Serial.println(F("\"}"));
}
int findCachedAck(long id) {
  for (byte i = 0; i < ACK_CACHE_SIZE; i++) if (ackCache[i].used && ackCache[i].id == id) return i;
  return -1;
}
void cacheAck(long id, const char* cmd, const char* status, const char* message) {
  AckCacheEntry &e = ackCache[ackCacheNext]; e.used = true; e.id = id;
  strncpy(e.command, cmd, sizeof(e.command)-1); e.command[sizeof(e.command)-1] = '\0';
  strncpy(e.status, status, sizeof(e.status)-1); e.status[sizeof(e.status)-1] = '\0';
  strncpy(e.message, message, sizeof(e.message)-1); e.message[sizeof(e.message)-1] = '\0';
  ackCacheNext = (ackCacheNext + 1) % ACK_CACHE_SIZE;
}
void handleCommand(long id, const char* cmd) {
  int cached = findCachedAck(id);
  if (cached >= 0) {
    // Same ID is replayed without repeating the command's side effect.
    emitAck(id, ackCache[cached].command, ackCache[cached].status, "duplicate_id_replayed");
    return;
  }
  const char* status = "accepted"; const char* message = "command applied";
  if (!strcmp(cmd, "STATUS")) {
    message = "telemetry_follows";
  } else if (!strcmp(cmd, "NEW_BATCH") || !strcmp(cmd, "RESET")) {
    startNewBatch();
  } else if (!strcmp(cmd, "SELECT_CHICKEN")) {
    applyEggProfile(EGG_CHICKEN); startNewBatch();
  } else if (!strcmp(cmd, "SELECT_DUCK")) {
    applyEggProfile(EGG_DUCK); startNewBatch();
  } else if (!strcmp(cmd, "SELECT_QUAIL")) {
    applyEggProfile(EGG_QUAIL); startNewBatch();
  } else if (!strcmp(cmd, "TURN_NOW")) {
    if (!incubatorSensorValid) { status = "rejected"; message = "incubator_sensor_invalid"; }
    else if (lockdown() || batchComplete()) { status = "rejected"; message = "turning_disabled_for_stage"; }
    else { performEggTurn(); message = "turn_completed"; }
  } else {
    status = "rejected"; message = "unknown_command";
  }
  cacheAck(id, cmd, status, message);
  emitAck(id, cmd, status, message);
  if (!strcmp(cmd, "STATUS") && !strcmp(status, "accepted")) printTelemetry();
}

bool extractJsonLong(const char* line, const char* key, long &value) {
  char needle[20]; snprintf(needle, sizeof(needle), "\"%s\"", key);
  const char* p = strstr(line, needle); if (!p) return false;
  p = strchr(p, ':'); if (!p) return false; p++;
  while (*p == ' ' || *p == '\t') p++;
  char* endPtr; value = strtol(p, &endPtr, 10);
  return endPtr != p;
}
bool extractJsonString(const char* line, const char* key, char* out, size_t outSize) {
  char needle[20]; snprintf(needle, sizeof(needle), "\"%s\"", key);
  const char* p = strstr(line, needle); if (!p) return false;
  p = strchr(p, ':'); if (!p) return false; p++;
  while (*p == ' ' || *p == '\t') p++;
  if (*p != '"') return false; p++;
  size_t n = 0;
  while (*p && *p != '"' && n < outSize - 1) { if (*p == '\\' && p[1]) p++; out[n++] = *p++; }
  out[n] = '\0'; return *p == '"';
}
void normalizeCommand(char* cmd) {
  for (byte i = 0; cmd[i]; i++) {
    if (cmd[i] == ' ') cmd[i] = '_';
    else if (cmd[i] >= 'a' && cmd[i] <= 'z') cmd[i] = cmd[i] - 'a' + 'A';
  }
  if (!strcmp(cmd, "SELECT_CHICKEN")) return;
}
void processLine(char* line) {
  while (*line == ' ' || *line == '\t') line++;
  if (!*line) return;
  long id = 0; char cmd[32];
  if (*line == '{') {
    if (!extractJsonLong(line, "id", id) || !extractJsonString(line, "cmd", cmd, sizeof(cmd))) {
      emitAck(-1, "INVALID_JSON", "rejected", "required_id_or_cmd_missing"); return;
    }
    normalizeCommand(cmd);
    handleCommand(id, cmd);
  } else {
    // Plain-text compatibility for Arduino Serial Monitor.
    strncpy(cmd, line, sizeof(cmd)-1); cmd[sizeof(cmd)-1] = '\0';
    for (byte i = 0; cmd[i]; i++) if (cmd[i] >= 'a' && cmd[i] <= 'z') cmd[i] -= 32;
    if (!strcmp(cmd, "SELECT CHICKEN")) strcpy(cmd, "SELECT_CHICKEN");
    else if (!strcmp(cmd, "SELECT DUCK")) strcpy(cmd, "SELECT_DUCK");
    else if (!strcmp(cmd, "SELECT QUAIL")) strcpy(cmd, "SELECT_QUAIL");
    else if (!strcmp(cmd, "NEW BATCH")) strcpy(cmd, "NEW_BATCH");
    // Plain-text commands use a synthetic ID. Do not use this mode for retry-sensitive production control.
    static long syntheticId = 1000000L;
    handleCommand(syntheticId++, cmd);
  }
}
void readSerialLines() {
  while (Serial.available() > 0) {
    char c = (char)Serial.read();
    if (c == '\r') continue;
    if (c == '\n') {
      serialLine[serialLineLength] = '\0';
      processLine(serialLine);
      serialLineLength = 0;
    } else if (serialLineLength < sizeof(serialLine)-1) {
      serialLine[serialLineLength++] = c;
    } else {
      serialLineLength = 0;
      emitAck(-1, "LINE", "rejected", "line_too_long");
    }
  }
}

void setup() {
  Serial.begin(9600);
  applyEggProfile(EGG_CHICKEN);

  initRelayOff(EXHAUST_FAN_RELAY_PIN);
  initRelayOff(INCUBATOR_BULB_RELAY_PIN);
  initRelayOff(BROODER_BULB_RELAY_PIN);
  initRelayOff(INCUBATOR_FAN_RELAY_PIN);
  initRelayOff(BROODER_HUMIDIFIER_RELAY_PIN);
  initRelayOff(INCUBATOR_HUMIDIFIER_RELAY_PIN);
  pinMode(INCUBATOR_BUZZER_PIN, OUTPUT); digitalWrite(INCUBATOR_BUZZER_PIN, LOW);
  pinMode(BROODER_BUZZER_PIN, OUTPUT); digitalWrite(BROODER_BUZZER_PIN, LOW);

  Wire.begin();
  lcd.init(); lcd.backlight(); lcd.clear();
  lcd.setCursor(0,0); lcd.print(F("SmartHatch v6"));
  lcd.setCursor(0,1); lcd.print(F("Starting safely"));

  incubatorDHT.begin(); brooderDHT.begin();
  eggTurner.attach(SERVO_PIN); eggTurner.write(SERVO_CENTER);
  loadBatchState();
  lastSensorRead = millis() - SENSOR_READ_INTERVAL_MS;
  lastTelemetry = millis();
  exhaustTimerStarted = millis();
  for (byte i = 0; i < ACK_CACHE_SIZE; i++) ackCache[i].used = false;
  Serial.println(F("{\"type\":\"event\",\"event\":\"controller_ready\",\"protocol\":\"smarthatch-json-v1\",\"baud\":9600}"));
  Serial.println(F("{\"type\":\"event\",\"event\":\"new_batch_on_first_boot_only\"}"));
}

void loop() {
  readSerialLines();
  updateIncubationTimer();
  readSensors();
  updateSensorValidity();
  controlIncubator();
  controlBrooder();
  controlEggTurning();
  updateBuzzers();
  printLcd();
  if (millis() - lastTelemetry >= TELEMETRY_INTERVAL_MS) {
    lastTelemetry = millis();
    printTelemetry();
  }
}
