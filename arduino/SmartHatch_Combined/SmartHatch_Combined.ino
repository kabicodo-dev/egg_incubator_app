// SmartHatch_Combined_Controller_v6.ino
// Arduino Uno / wired USB serial controller.
//
// NDJSON protocol (9600 baud, LF only):
//   app        -> Uno: {"type":"command","id":...,"actuator":...,"state":...}
//   Uno        -> app: {"type":"ack",...}                       (command processed)
//   Uno        -> app: {"type":"running",...}                   (command still in flight)
//   Uno        -> app: {"type":"telemetry",...}
//   Uno        -> app: {"type":"event",...}
//
// Commands: command (id/actuator/state), STATUS (the app polls for telemetry
// or sends STATUS with no id to request a fresh telemetry follow).
//
// Safety notes:
//   - Invalid/stale DHT readings disable the associated controlled outputs.
//   - On Uno, USB disconnect cannot be reliably detected by firmware. Local
//     control continues; the app should reconnect and request telemetry.
//   - EEPROM progress is saved periodically; power-off time is NOT counted
//     without an RTC/external clock. Stored species and elapsed runtime are
//     restored.
//   - Bench-test relay polarity, wiring, sensor failure behavior, servo
//     limits, and the complete system before connecting a live incubator.
//
// Output is NDJSON: every line is exactly one JSON object, terminated by LF.
// This is what the app's serial parser (flutter_libserialport, 9600 baud) and
// the Flutter NDJSON consumer in the repository expect.

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

// ── JSON escaping ──
void jsonEscapePrint(const char* s) { // Current command names/messages use safe ASCII only.
  while (*s) {
    if (*s == '"' || *s == '\\') Serial.print('\\');
    Serial.print(*s++);
  }
}

// One NDJSON frame: {"type":"ack","id":...,...,"v":1}\n
void emitAck(long id, const char* cmd, const char* status, const char* message) {
  Serial.print(F("{\"type\":\"ack\",\"id\":"));
  Serial.print(id);
  Serial.print(F(",\"cmd\":\""));
  jsonEscapePrint(cmd);
  Serial.print(F("\",\"status\":\""));
  jsonEscapePrint(status);
  Serial.print(F("\",\"message\":\""));
  jsonEscapePrint(message);
  Serial.print(F("\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.println(F(")"));
}

// One NDJSON frame: {"type":"running","id":...,"v":1}\n
void emitRunning(long id) {
  Serial.print(F("{\"type\":\"running\",\"id\":"));
  Serial.print(id);
  Serial.print(F(",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.println(F("))"));
}

// One NDJSON frame: {"type":"telemetry",...}\n
void printTelemetry() {
  Serial.print(F("{\"type\":\"telemetry\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.print(F(",\"uptime_ms\":"));
  Serial.print(millis());
  Serial.print(F(",\"egg_type\":\""));
  Serial.print(eggName());
  Serial.print(F("\",\"day\":"));
  Serial.print(incubationDay());
  Serial.print(F(",\"hatch_day\":"));
  Serial.print(hatchDay);
  Serial.print(F(",\"elapsed_seconds\":"));
  Serial.print(batchState.elapsedSeconds);
  Serial.print(F(",\"stage\":\""));
  Serial.print(stageName());
  Serial.print(F("\",\"batch_complete\":"));
  Serial.print(batchComplete() ? F("true") : F("false"));
  Serial.print(F(",\"incubator\":{\"valid\":"));
  Serial.print(incubatorSensorValid ? F("true") : F("false"));
  Serial.print(F(",\"temperature_c\":"));
  printFloatOrNull(incubatorTemperature, 1);
  Serial.print(F(",\"humidity_percent\":"));
  printFloatOrNull(incubatorHumidity, 1);
  Serial.print(F(",\"bulb_on\":"));
  Serial.print(incubatorBulbState ? F("true") : F("false"));
  Serial.print(F(",\"humidifier_on\":"));
  Serial.print(incubatorHumidifierState ? F("true") : F("false"));
  Serial.print(F(",\"fan_on\":"));
  Serial.print(incubatorFanState ? F("true") : F("false"));
  Serial.print(F(",\"exhaust_fan_on\":"));
  Serial.print(exhaustFanState ? F("true") : F("false"));
  Serial.print(F("},\"brooder\":{\"valid\":"));
  Serial.print(brooderSensorValid ? F("true") : F("false"));
  Serial.print(F(",\"temperature_c\":"));
  printFloatOrNull(brooderTemperature, 1);
  Serial.print(F(",\"humidity_percent\":"));
  printFloatOrNull(brooderHumidity, 1);
  Serial.print(F(",\"bulb_on\":"));
  Serial.print(brooderBulbState ? F("true") : F("false"));
  Serial.print(F(",\"humidifier_on\":"));
  Serial.print(brooderHumidifierState ? F("true") : F("false"));
  Serial.println(F("))"));
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
  Serial.print(F("{\"type\":\"ack\",\"id\":"));
  Serial.print(id);
  Serial.print(F(",\"cmd\":\""));
  jsonEscapePrint(cmd);
  Serial.print(F("\",\"status\":\""));
  jsonEscapePrint(status);
  Serial.print(F("\",\"message\":\""));
  jsonEscapePrint(message);
  Serial.print(F("\",\"v\":"));
  Serial.print(NDJSON_VERSION_MAJOR);
  Serial.println(F("))"));
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
    emitAck(id, ackCache[cached].command, ackCache[cached].status, "_duplicate_id_replayed");
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
  if (status[0] == 'r') { // "rejected"
    emitAck(id, cmd, status, message);
    return;
  }
  // A non-replay ACK is the confirmed end of the command: return here and emit
  // "running" for the duration (e.g. TURN_NOW / egg turning) so the app can
  // separate confirmation (ACK) from in-flight command state.
  if (!strcmp(cmd, "STATUS") && !strcmp(status, "accepted")) printTelemetry();
  // Running state is emitted from the relevant loops for long-lived commands.
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
  Serial.println(F("{\"type\":\"event\",\"event\":\"controller_ready\",\"protocol\":\"smarthatch-ndjson-v1\",\"baud\":9600,\"v\":1}"));
  Serial.println(F("{\"type\":\"event\",\"event\":\"new_batch_on_first_boot_only\",\"v\":1}"));
  // Boot with the NDJSON protocol so the app can drive the same relays the app uses (active-low, matching the existing relay functions).
  Serial.println(F("{\"type\":\"event\",\"event\":\"protocol_v6_ready\",\"baud\":9600,\"v\":1}"));
}

void loop() {
  // NDJSON commands from the app land on Serial first.
  handleV6CommandInLoop();
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
