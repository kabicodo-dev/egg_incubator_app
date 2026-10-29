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

  NDJSON protocol (A-02), 9600 baud, one JSON object per line, LF only:
    app  -> Uno: {"id":101,"cmd":"STATUS"}
    Uno  -> app: {"type":"running","v":1,"id":102,"cmd":"TURN_NOW"}
    Uno  -> app: {"type":"ack","v":1,"id":102,"cmd":"TURN_NOW","status":"accepted","message":"turn_completed"}
    Uno  -> app: {"type":"ack","v":1,"id":103,"cmd":"NOPE","status":"rejected","error":{"code":"unknown_command","message":"unknown command"}}
    Uno  -> app: {"type":"telemetry","v":1,...}
    Uno  -> app: {"type":"event","v":1,"event":"...",...}

  Frame types
    ack       Terminal outcome of one command id. It confirms the firmware
              processed the command; it is NOT proof that a relay closed.
    running   Non-terminal: the command id is still in flight. A later ack for
              the same id is the only completion signal.
    telemetry Periodic state snapshot.
    event     Unsolicited lifecycle/state notice (no command id).

  Commands: STATUS, NEW_BATCH, RESET, SELECT_CHICKEN, SELECT_DUCK,
            SELECT_QUAIL, TURN_NOW
  Legacy plain-text commands are also accepted for serial-monitor testing, but
  they use synthetic ids and are not retry-safe.

  SAFETY NOTES:
  - Local regulation runs in loop() and needs no PC, USB host or network.
    USB/Serial carries commands and telemetry only.
  - Invalid/stale DHT readings disable all controlled outputs for that chamber
    and re-initialise that chamber's control state on recovery.
  - Incubator over-temperature (>= INCUBATOR_OVER_TEMP_C) forces the heater and
    humidifier OFF and keeps the circulation fan ON. This is a software cutoff
    on the same DHT11, not an independent hardware thermal fuse.
  - On Uno, USB disconnect cannot be reliably detected by firmware. Local
    control continues; the bridge should reconnect and request STATUS.
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
const float INCUBATOR_OVER_TEMP_C = 39.0f; // software cutoff; not an independent thermal fuse
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
// A-06 start identity lives in a separate EEPROM record so the existing batch
// layout at address 0 is preserved across this firmware update.
const int START_EEPROM_ADDRESS = 32;
const uint16_t START_EEPROM_MAGIC = 0x5337;
const byte START_EEPROM_VERSION = 1;
// A-02 wire version. Every outgoing frame carries "v" so the app can refuse a
// frame layout it was not built against instead of silently mis-reading it.
const byte NDJSON_VERSION_MAJOR = 1;

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

// A-06: durable association between the controller and one app/cloud batch id.
// Kept separate from BatchState so existing progress survives the upgrade.
struct StartRecord {
  uint16_t magic;
  byte version;
  byte reserved;
  uint32_t batchId;
};
StartRecord startRecord;

uint32_t activeBatchId = 0;      // 0 = no batch bound in this power cycle
bool startPending = false;       // START received, hardware not confirmed yet
bool pendingStartIsResume = false; // confirm an existing batch without resetting it
bool startConfirmed = false;     // RUNNING has been substantiated for activeBatchId
bool batchStateRestored = false; // EEPROM batch state was valid at boot
bool batchIdentityUnknown = false; // restored batch has no trustworthy batch_id
uint32_t pendingBatchId = 0;
long pendingStartCommandId = 0;
unsigned long startRequestedAt = 0;

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
// detail holds the accepted message, or the error code when status=="rejected".
// Field sizes cover the longest current command (14 chars) and error code
// (27 chars) while keeping the 8-entry RAM cache small on the Uno.
struct AckCacheEntry { bool used; long id; long batchId; char command[16]; char status[10]; char detail[32]; };
AckCacheEntry ackCache[ACK_CACHE_SIZE];
byte ackCacheNext = 0;

// Explicit prototypes keep this sketch buildable outside the Arduino prototype
// generator (the host NDJSON harness compiles the same file with shimmed AVR
// headers). Declarations are identical to the later definitions.
const char* eggName();
void applyEggProfile(EggType type);
void setRelay(byte pin, bool on);
void initRelayOff(byte pin);
void allIncubatorControlledOutputsOff();
void allBrooderControlledOutputsOff();
void saveBatchState();
void saveStartRecord();
void clearStartRecord();
void loadStartRecord();
byte incubationDay();
uint32_t elapsedDay();
bool lockdown();
bool batchComplete();
const char* stageName();
float humidityLowTarget();
float humidityHighTarget();
void startNewBatch();
void loadBatchState();
void updateIncubationTimer();
void updatePendingStart();
bool relayLevelMatches(byte pin, bool on);
bool actuatorsMatchControl();
bool validDhtPair(float t, float h);
void readSensors();
void updateSensorValidity();
void controlIncubator();
void controlExhaustFan();
void controlBrooder();
void performEggTurn();
void controlEggTurning();
void updateBuzzer(byte pin, bool error, byte index);
void updateBuzzers();
void printFloatOrNull(bool valid, float value, byte decimals);
void printTelemetry();
void printLcd();
void jsonEscapePrint(const char* s);
void endFrame();
void printErrorMessage(const char* code);
void emitAck(long id, const char* cmd, const char* status, const char* detail, long batchId = 0);
void emitRunning(long id, const char* cmd, long batchId = 0, bool confirmed = false);
int findCachedAck(long id);
void cacheAck(long id, const char* cmd, const char* status, const char* detail, long batchId = 0);
void handleCommand(long id, const char* cmd, bool hasBatchId, long batchId);
bool extractJsonLong(const char* line, const char* key, long &value);
bool extractJsonString(const char* line, const char* key, char* out, size_t outSize);
void normalizeCommand(char* cmd);
void processLine(char* line);
void readSerialLines();

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
  // A-03: the circulation fan is a controlled output too. Leaving it energised
  // while the chamber has no valid temperature reading was a fail-safe gap.
  incubatorFanState = false;
  exhaustFanState = false;
  setRelay(INCUBATOR_BULB_RELAY_PIN, false);
  setRelay(INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
  setRelay(INCUBATOR_FAN_RELAY_PIN, false);
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

void saveStartRecord() {
  startRecord.magic = START_EEPROM_MAGIC;
  startRecord.version = START_EEPROM_VERSION;
  startRecord.reserved = 0;
  startRecord.batchId = activeBatchId;
  EEPROM.put(START_EEPROM_ADDRESS, startRecord);
}

void clearStartRecord() {
  startRecord.magic = 0;
  startRecord.version = 0;
  startRecord.reserved = 0;
  startRecord.batchId = 0;
  EEPROM.put(START_EEPROM_ADDRESS, startRecord);
  activeBatchId = 0;
  startConfirmed = false;
  startPending = false;
  pendingStartIsResume = false;
  batchIdentityUnknown = false;
}

void loadStartRecord() {
  EEPROM.get(START_EEPROM_ADDRESS, startRecord);
  bool valid = startRecord.magic == START_EEPROM_MAGIC &&
               startRecord.version == START_EEPROM_VERSION &&
               startRecord.batchId > 0;
  if (valid && batchStateRestored) {
    activeBatchId = startRecord.batchId;
    startConfirmed = true;
    batchIdentityUnknown = false;
    return;
  }
  activeBatchId = 0;
  startConfirmed = false;
  if (valid) {
    // A start record without a matching batch state is not trustworthy.
    startRecord.magic = 0;
    EEPROM.put(START_EEPROM_ADDRESS, startRecord);
  }
}

byte incubationDay() {  // display/stage day (capped at the hatch day)
  uint32_t d = batchState.elapsedSeconds / 86400UL + 1UL;
  if (d > hatchDay) d = hatchDay;
  return (byte)d;
}
// A-02 Day N for telemetry: floor(elapsed_seconds / 86400) + 1, uncapped, from
// the firmware's substantiated original Start. Not a wall-clock day.
uint32_t elapsedDay() {
  return batchState.elapsedSeconds / 86400UL + 1UL;
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
  batchIdentityUnknown = false;
  saveBatchState();
  lastProgressTick = millis();
  lastProgressSave = millis();
  lastEggTurn = millis();
  incubatorHeatInitialized = false;
  incubatorHumidityInitialized = false;
  Serial.print(F("{\"type\":\"event\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.print(F(",\"event\":\"batch_started\",\"egg_type\":\""));
  Serial.print(eggName());
  Serial.print(F("\",\"day\":1}"));
  endFrame();
}

void loadBatchState() {
  EEPROM.get(EEPROM_ADDRESS, batchState);
  bool valid = batchState.magic == EEPROM_MAGIC &&
               batchState.version == EEPROM_VERSION &&
               batchState.eggType >= EGG_CHICKEN && batchState.eggType <= EGG_QUAIL &&
               batchState.elapsedSeconds <= 28UL * 86400UL;
  if (!valid) {
    batchStateRestored = false;
    batchIdentityUnknown = false;
    applyEggProfile(EGG_CHICKEN);
    batchState.elapsedSeconds = 0;
    startNewBatch();
    return;
  }
  batchStateRestored = true;
  batchIdentityUnknown = true;  // cleared by a valid StartRecord or explicit NEW_BATCH
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

  // Over-temperature fail-safe. Software cutoff on the same DHT11; it is not a
  // substitute for an independent hardware thermal fuse.
  if (incubatorTemperature >= INCUBATOR_OVER_TEMP_C) {
    incubatorBulbState = false;
    setRelay(INCUBATOR_BULB_RELAY_PIN, false);
    // Stop adding humidity while the chamber is above the cutoff.
    incubatorHumidifierState = false;
    setRelay(INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
  } else {
    if (!incubatorHeatInitialized) {
      incubatorBulbState = incubatorTemperature < INCUBATOR_HEAT_OFF_C;
      incubatorHeatInitialized = true;
    }
    if (incubatorTemperature <= INCUBATOR_HEAT_ON_C) incubatorBulbState = true;
    if (incubatorTemperature >= INCUBATOR_HEAT_OFF_C) incubatorBulbState = false;
    setRelay(INCUBATOR_BULB_RELAY_PIN, incubatorBulbState);

    if (!incubatorHumidityInitialized) {
      incubatorHumidifierState = incubatorHumidity < humidityLowTarget();
      incubatorHumidityInitialized = true;
    }
    if (incubatorHumidity < humidityLowTarget()) incubatorHumidifierState = true;
    if (incubatorHumidity >= humidityHighTarget()) incubatorHumidifierState = false;
    setRelay(INCUBATOR_HUMIDIFIER_RELAY_PIN, incubatorHumidifierState);
  }

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

// A-06 confirmation is the MCU output latch plus fresh sensor validity. It is
// not independent proof that a relay contact actually closed.
bool relayLevelMatches(byte pin, bool on) {
  byte expected = RELAY_ACTIVE_LOW ? (on ? LOW : HIGH) : (on ? HIGH : LOW);
  return digitalRead(pin) == expected;
}

bool actuatorsMatchControl() {
  return relayLevelMatches(INCUBATOR_BULB_RELAY_PIN, incubatorBulbState) &&
         relayLevelMatches(INCUBATOR_HUMIDIFIER_RELAY_PIN, incubatorHumidifierState) &&
         relayLevelMatches(INCUBATOR_FAN_RELAY_PIN, incubatorFanState) &&
         relayLevelMatches(EXHAUST_FAN_RELAY_PIN, exhaustFanState) &&
         relayLevelMatches(BROODER_BULB_RELAY_PIN, brooderBulbState) &&
         relayLevelMatches(BROODER_HUMIDIFIER_RELAY_PIN, brooderHumidifierState);
}

// A START is acknowledged as soon as it is received. This function is the
// second phase: it emits RUNNING only after fresh reads for both chambers and
// the relay output latches agree with the control law.
void updatePendingStart() {
  if (!startPending) return;
  if (lastIncubatorGoodRead < startRequestedAt || lastBrooderGoodRead < startRequestedAt) return;
  if (!incubatorSensorValid || !brooderSensorValid) return;
  if (!actuatorsMatchControl()) return;

  const bool resume = pendingStartIsResume;
  const uint32_t confirmedBatchId = pendingBatchId;
  startPending = false;
  pendingStartIsResume = false;
  if (!resume) {
    // Crash-safe order: clear the old identity, write the fresh batch state,
    // then publish the new identity. A power cut between steps leaves an
    // uncertain batch that START must not silently adopt.
    clearStartRecord();
    // Original Start is this confirmation, not the ACK receipt.
    startNewBatch();
  }
  activeBatchId = confirmedBatchId;
  startConfirmed = true;
  saveStartRecord();
  emitRunning(pendingStartCommandId, "START", (long)activeBatchId, true);
}

void performEggTurn() {
  if (lockdown() || batchComplete() || !incubatorSensorValid) return;
  eggTurner.write(SERVO_LEFT); delay(SERVO_MOVE_DELAY_MS);
  eggTurner.write(SERVO_RIGHT); delay(SERVO_MOVE_DELAY_MS);
  eggTurner.write(SERVO_CENTER);
  Serial.print(F("{\"type\":\"event\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.print(F(",\"event\":\"egg_turn_completed\"}"));
  endFrame();
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

// A stale/unavailable reading must never be serialized as a current value.
void printFloatOrNull(bool valid, float value, byte decimals) {
  if (!valid || isnan(value)) Serial.print(F("null")); else Serial.print(value, decimals);
}
void printTelemetry() {
  Serial.print(F("{\"type\":\"telemetry\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.print(F(",\"uptime_ms\":")); Serial.print(millis());
  Serial.print(F(",\"egg_type\":\"")); Serial.print(eggName()); Serial.print(F("\",\"day\":")); Serial.print(elapsedDay());
  Serial.print(F(",\"hatch_day\":")); Serial.print(hatchDay);
  Serial.print(F(",\"elapsed_seconds\":")); Serial.print(batchState.elapsedSeconds);
  Serial.print(F(",\"stage\":\"")); Serial.print(stageName()); Serial.print(F("\",\"batch_complete\":")); Serial.print(batchComplete() ? F("true") : F("false"));
  Serial.print(F(",\"incubator\":{\"valid\":")); Serial.print(incubatorSensorValid ? F("true") : F("false"));
  Serial.print(F(",\"temperature_c\":")); printFloatOrNull(incubatorSensorValid, incubatorTemperature, 1);
  Serial.print(F(",\"humidity_percent\":")); printFloatOrNull(incubatorSensorValid, incubatorHumidity, 1);
  Serial.print(F(",\"bulb_on\":")); Serial.print(incubatorBulbState ? F("true") : F("false"));
  Serial.print(F(",\"humidifier_on\":")); Serial.print(incubatorHumidifierState ? F("true") : F("false"));
  Serial.print(F(",\"fan_on\":")); Serial.print(incubatorFanState ? F("true") : F("false"));
  Serial.print(F(",\"exhaust_fan_on\":")); Serial.print(exhaustFanState ? F("true") : F("false")); Serial.print('}');
  Serial.print(F(",\"brooder\":{\"valid\":")); Serial.print(brooderSensorValid ? F("true") : F("false"));
  Serial.print(F(",\"temperature_c\":")); printFloatOrNull(brooderSensorValid, brooderTemperature, 1);
  Serial.print(F(",\"humidity_percent\":")); printFloatOrNull(brooderSensorValid, brooderHumidity, 1);
  Serial.print(F(",\"bulb_on\":")); Serial.print(brooderBulbState ? F("true") : F("false"));
  Serial.print(F(",\"humidifier_on\":")); Serial.print(brooderHumidifierState ? F("true") : F("false")); Serial.print(F("}}"));
  endFrame();
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

// A-02 framing: exactly one JSON object followed by a single LF. Arduino's
// println() emits CRLF, so every frame uses this helper instead.
void endFrame() { Serial.print('\n'); }

// Stable error vocabulary. The app should branch on these codes, not on prose.
// Prints straight to Serial so the prose stays in flash (Uno SRAM is tight).
void printErrorMessage(const char* code) {
  if (!strcmp(code, "unknown_command")) Serial.print(F("unknown command"));
  else if (!strcmp(code, "incubator_sensor_invalid")) Serial.print(F("incubator sensor reading is invalid"));
  else if (!strcmp(code, "turning_disabled_for_stage")) Serial.print(F("egg turning is disabled for the current stage"));
  else if (!strcmp(code, "line_too_long")) Serial.print(F("serial line exceeds buffer"));
  else if (!strcmp(code, "required_id_or_cmd_missing")) Serial.print(F("required id or cmd missing"));
  else if (!strcmp(code, "invalid_batch_id")) Serial.print(F("batch_id missing or invalid"));
  else if (!strcmp(code, "batch_already_running")) Serial.print(F("another batch is already running"));
  else if (!strcmp(code, "batch_already_complete")) Serial.print(F("batch is already complete"));
  else Serial.print(F("command rejected"));
}

// Terminal command outcome. detail is the accepted message, or the error code
// when status == "rejected". An ack confirms processing only, never that a
// relay physically switched.
void emitAck(long id, const char* cmd, const char* status, const char* detail, long batchId) {
  Serial.print(F("{\"type\":\"ack\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.print(F(",\"id\":"));
  Serial.print(id);
  if (!strcmp(cmd, "START")) {
    Serial.print(F(",\"command_id\":"));
    Serial.print(id);
    Serial.print(F(",\"batch_id\":"));
    Serial.print(batchId);
  }
  Serial.print(F(",\"cmd\":\""));
  jsonEscapePrint(cmd);
  Serial.print(F("\",\"status\":\""));
  jsonEscapePrint(status);
  Serial.print('"');
  if (!strcmp(status, "rejected")) {
    Serial.print(F(",\"error\":{\"code\":\""));
    jsonEscapePrint(detail);
    Serial.print(F("\",\"message\":\""));
    printErrorMessage(detail);
    Serial.print(F("\"}"));
  } else {
    Serial.print(F(",\"message\":\""));
    jsonEscapePrint(detail);
    Serial.print('"');
  }
  Serial.print('}');
  endFrame();
}

// Non-terminal: this command id is still in flight. A later ack for the same
// id is the only completion signal.
void emitRunning(long id, const char* cmd, long batchId, bool confirmed) {
  Serial.print(F("{\"type\":\"running\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.print(F(",\"id\":"));
  Serial.print(id);
  Serial.print(F(",\"cmd\":\""));
  jsonEscapePrint(cmd);
  Serial.print('"');
  if (!strcmp(cmd, "START")) {
    Serial.print(F(",\"command_id\":"));
    Serial.print(id);
    Serial.print(F(",\"batch_id\":"));
    Serial.print(batchId);
    if (confirmed) Serial.print(F(",\"status\":\"running\""));
  }
  Serial.print('}');
  endFrame();
}

int findCachedAck(long id) {
  for (byte i = 0; i < ACK_CACHE_SIZE; i++) if (ackCache[i].used && ackCache[i].id == id) return i;
  return -1;
}
void cacheAck(long id, const char* cmd, const char* status, const char* detail, long batchId) {
  AckCacheEntry &e = ackCache[ackCacheNext]; e.used = true; e.id = id; e.batchId = batchId;
  strncpy(e.command, cmd, sizeof(e.command)-1); e.command[sizeof(e.command)-1] = '\0';
  strncpy(e.status, status, sizeof(e.status)-1); e.status[sizeof(e.status)-1] = '\0';
  strncpy(e.detail, detail, sizeof(e.detail)-1); e.detail[sizeof(e.detail)-1] = '\0';
  ackCacheNext = (ackCacheNext + 1) % ACK_CACHE_SIZE;
}
void handleCommand(long id, const char* cmd, bool hasBatchId, long batchId) {
  int cached = findCachedAck(id);
  if (cached >= 0) {
    // Same id: repeat the original terminal ack without repeating the side
    // effect. The cache is RAM-only best effort, not durable recovery.
    emitAck(id, ackCache[cached].command, ackCache[cached].status, ackCache[cached].detail,
            ackCache[cached].batchId);
    if (!strcmp(ackCache[cached].command, "START") &&
        !strcmp(ackCache[cached].status, "accepted") &&
        activeBatchId == (uint32_t)ackCache[cached].batchId &&
        startConfirmed && !batchComplete()) {
      // A retry may arrive after a reconnect. Re-assert RUNNING only when the
      // current hardware still confirms; otherwise re-confirm asynchronously.
      if (incubatorSensorValid && brooderSensorValid && actuatorsMatchControl()) {
        emitRunning(id, "START", ackCache[cached].batchId, true);
      } else {
        pendingBatchId = activeBatchId;
        pendingStartCommandId = id;
        startPending = true;
        pendingStartIsResume = true;
        startRequestedAt = millis();
      }
    }
    return;
  }
  const char* status = "accepted"; const char* detail = "command_applied";
  if (!strcmp(cmd, "STATUS")) {
    detail = "telemetry_follows";
  } else if (!strcmp(cmd, "NEW_BATCH") || !strcmp(cmd, "RESET")) {
    clearStartRecord();
    startNewBatch();
  } else if (!strcmp(cmd, "SELECT_CHICKEN")) {
    clearStartRecord();
    applyEggProfile(EGG_CHICKEN); startNewBatch();
  } else if (!strcmp(cmd, "SELECT_DUCK")) {
    clearStartRecord();
    applyEggProfile(EGG_DUCK); startNewBatch();
  } else if (!strcmp(cmd, "SELECT_QUAIL")) {
    clearStartRecord();
    applyEggProfile(EGG_QUAIL); startNewBatch();
  } else if (!strcmp(cmd, "START")) {
    if (!hasBatchId || batchId <= 0) {
      status = "rejected"; detail = "invalid_batch_id";
    } else if (activeBatchId == (uint32_t)batchId) {
      if (batchComplete()) { status = "rejected"; detail = "batch_already_complete"; }
      else { detail = "start_already_running"; }
    } else if (activeBatchId != 0) {
      status = "rejected"; detail = "batch_already_running";
    } else if (startPending) {
      if (pendingBatchId == (uint32_t)batchId) {
        detail = "start_received";
        pendingStartCommandId = id;  // latest retry receives the eventual RUNNING
      } else {
        status = "rejected"; detail = "batch_already_running";
      }
    } else if (batchIdentityUnknown && !batchComplete()) {
      // A restored batch is already in progress but has no trustworthy
      // start record. Never reset it automatically; require an explicit
      // NEW_BATCH/SELECT to replace it.
      status = "rejected"; detail = "batch_already_running";
    } else {
      pendingBatchId = (uint32_t)batchId;
      pendingStartCommandId = id;
      startPending = true;
      startRequestedAt = millis();
      detail = "start_received";
    }
  } else if (!strcmp(cmd, "TURN_NOW")) {
    if (!incubatorSensorValid) { status = "rejected"; detail = "incubator_sensor_invalid"; }
    else if (lockdown() || batchComplete()) { status = "rejected"; detail = "turning_disabled_for_stage"; }
    else {
      emitRunning(id, cmd);   // TURN_NOW in-flight; the later ack is completion
      performEggTurn();
      detail = "turn_completed";
    }
  } else {
    status = "rejected"; detail = "unknown_command";
  }
  cacheAck(id, cmd, status, detail, batchId);
  emitAck(id, cmd, status, detail, batchId);
  if (!strcmp(cmd, "START") && !strcmp(status, "accepted") &&
      activeBatchId == (uint32_t)batchId && startConfirmed && !batchComplete()) {
    if (incubatorSensorValid && brooderSensorValid && actuatorsMatchControl()) {
      emitRunning(id, cmd, batchId, true);
    } else {
      pendingBatchId = activeBatchId;
      pendingStartCommandId = id;
      startPending = true;
      pendingStartIsResume = true;
      startRequestedAt = millis();
    }
  }
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
  long id = 0; char cmd[32]; long batchId = 0;
  if (*line == '{') {
    if (!extractJsonLong(line, "id", id) || !extractJsonString(line, "cmd", cmd, sizeof(cmd))) {
      emitAck(-1, "INVALID_JSON", "rejected", "required_id_or_cmd_missing"); return;
    }
    bool hasBatchId = extractJsonLong(line, "batch_id", batchId);
    normalizeCommand(cmd);
    handleCommand(id, cmd, hasBatchId, batchId);
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
    handleCommand(syntheticId++, cmd, false, 0);
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
  loadStartRecord();
  lastSensorRead = millis() - SENSOR_READ_INTERVAL_MS;
  lastTelemetry = millis();
  exhaustTimerStarted = millis();
  for (byte i = 0; i < ACK_CACHE_SIZE; i++) ackCache[i].used = false;

  Serial.print(F("{\"type\":\"event\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.print(F(",\"event\":\"controller_ready\",\"protocol\":\"smarthatch-ndjson-v1\",\"baud\":9600}"));
  endFrame();

  // Truthful state notice. The previous sketch claimed "new_batch_on_first_boot_only"
  // on every boot; this reports what was actually restored from EEPROM.
  Serial.print(F("{\"type\":\"event\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.print(F(",\"event\":\"batch_state_restored\",\"egg_type\":\""));
  Serial.print(eggName());
  Serial.print(F("\",\"day\":"));
  Serial.print(elapsedDay());
  Serial.print(F(",\"elapsed_seconds\":"));
  Serial.print(batchState.elapsedSeconds);
  Serial.print('}');
  endFrame();
}

void loop() {
  readSerialLines();
  updateIncubationTimer();
  readSensors();
  updateSensorValidity();
  controlIncubator();
  controlBrooder();
  updatePendingStart();
  controlEggTurning();
  updateBuzzers();
  printLcd();
  if (millis() - lastTelemetry >= TELEMETRY_INTERVAL_MS) {
    lastTelemetry = millis();
    printTelemetry();
  }
}
