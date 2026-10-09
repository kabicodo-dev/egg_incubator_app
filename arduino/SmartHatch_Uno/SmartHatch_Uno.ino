/*
 * SmartHatch Uno — USB serial controller for the SmartHatch Flutter app.
 *
 * Protocol: newline-delimited JSON (one object per line) at 9600 baud.
 *   Arduino -> app : {"type":"telemetry", ...}          (every TELEMETRY_INTERVAL_MS)
 *   app -> Arduino : {"type":"command","id":...,"actuator":...,"state":...}
 *   Arduino -> app : {"type":"ack","id":...,"success":...,...}
 *
 * Actuator names (shared with lib/services/arduino_protocol.dart):
 *   incubatorBulb, incubatorFan, exhaustFan, brooderBulb,
 *   incubatorHumidifier, brooderHumidifier, eggTurningServo
 *
 * RELAYS ARE ACTIVE-LOW:  LOW = relay ON,  HIGH = relay OFF.
 * All heating/humidification relays start OFF and stay OFF until a valid,
 * acknowledged command turns them on. Connecting USB never energizes anything.
 *
 * Required libraries (Library Manager):
 *   - "DHT sensor library" (Adafruit)
 *   - "Adafruit Unified Sensor" (dependency of the above)
 *   - Servo (bundled with the Arduino IDE)
 *
 * See docs/arduino_integration.md for wiring, upload and test steps.
 */

#include <DHT.h>
#include <Servo.h>

// ── Pin map (do not change without checking hardware wiring) ──
#define PIN_DHT_INCUBATOR   2   // Incubator DHT11
#define PIN_EGG_SERVO       3   // Incubator egg-turning servo
#define PIN_DHT_BROODER     4   // Brooder DHT11
#define PIN_RELAY_BROODER_HUMIDIFIER 5   // Brooder humidifier relay
#define PIN_RELAY_INCUBATOR_HUMIDIFIER 6 // Incubator humidifier relay
#define PIN_BUZZER_INCUBATOR 7  // Incubator buzzer
#define PIN_BUZZER_BROODER   8  // Brooder buzzer
#define PIN_RELAY_EXHAUST_FAN 9 // Exhaust / intake fan relay
#define PIN_RELAY_INCUBATOR_BULB 10 // Incubator bulb relay
#define PIN_RELAY_BROODER_BULB 11   // Brooder bulb relay
#define PIN_RELAY_INCUBATOR_FAN 12  // Incubator fan relay

#define DHTTYPE DHT11

// ── Behaviour configuration ──
static const unsigned long TELEMETRY_INTERVAL_MS = 2000;   // telemetry period
static const unsigned long SENSOR_INTERVAL_MS = 2500;      // DHT11 needs >=2s
static const unsigned long TURN_INTERVAL_MS = 4UL * 60UL * 60UL * 1000UL; // 4 h
static const int SERVO_POS_A = 25;   // egg tray position A (degrees)
static const int SERVO_POS_B = 155;  // egg tray position B (degrees)
static const int SERVO_MOVE_MS = 900; // time allowed for the sweep

struct RelayDef {
  const char* name;
  uint8_t pin;
};

// Relay-backed actuators (active-LOW). eggTurningServo is handled separately.
static const RelayDef RELAYS[] = {
  {"incubatorBulb", PIN_RELAY_INCUBATOR_BULB},
  {"incubatorFan", PIN_RELAY_INCUBATOR_FAN},
  {"exhaustFan", PIN_RELAY_EXHAUST_FAN},
  {"brooderBulb", PIN_RELAY_BROODER_BULB},
  {"incubatorHumidifier", PIN_RELAY_INCUBATOR_HUMIDIFIER},
  {"brooderHumidifier", PIN_RELAY_BROODER_HUMIDIFIER},
};
static const uint8_t RELAY_COUNT = sizeof(RELAYS) / sizeof(RELAYS[0]);

DHT incubatorDht(PIN_DHT_INCUBATOR, DHTTYPE);
DHT brooderDht(PIN_DHT_BROODER, DHTTYPE);
Servo eggServo;

// Cached sensor state (valid==false => report JSON null, never a fake value).
bool incValid = false;
bool brooderValid = false;
float incTemp = 0.0f, incHum = 0.0f;
float brooderTemp = 0.0f, brooderHum = 0.0f;

// Turning state
bool turningEnabled = true;       // auto turning on until a command disables it
bool servoToggle = false;         // alternates between position A and B
unsigned long lastTurnMillis = 0;
unsigned long turnsToday = 0;
unsigned long turnsDay = 0;

// Timers
unsigned long lastTelemetryMillis = 0;
unsigned long lastSensorMillis = 0;

// Serial command buffer
static const size_t CMD_BUFFER_SIZE = 160;
char cmdBuffer[CMD_BUFFER_SIZE];
size_t cmdLength = 0;

// Snprintf-based float formatting (AVR printf has no float support by default).
void fmtFloatOrNull(bool valid, float value, char* out, size_t outLen) {
  if (valid) {
    dtostrf(value, 0, 2, out);
  } else {
    strncpy(out, "null", outLen - 1);
    out[outLen - 1] = '\0';
  }
}

// Relay helper: active-LOW, so ON writes LOW.
void writeRelay(uint8_t pin, bool on) {
  digitalWrite(pin, on ? LOW : HIGH);
}

// Safe startup: drive the pin HIGH (relay OFF) BEFORE enabling the output so a
// reset/boot can never briefly energize a heating or humidification load.
void initRelayPin(uint8_t pin) {
  digitalWrite(pin, HIGH);
  pinMode(pin, OUTPUT);
  digitalWrite(pin, HIGH);
}

void initAllHardware() {
  for (uint8_t i = 0; i < RELAY_COUNT; i++) {
    initRelayPin(RELAYS[i].pin);
  }
  // Buzzers default silent (active-HIGH assumption); not part of the protocol.
  pinMode(PIN_BUZZER_INCUBATOR, OUTPUT);
  digitalWrite(PIN_BUZZER_INCUBATOR, LOW);
  pinMode(PIN_BUZZER_BROODER, OUTPUT);
  digitalWrite(PIN_BUZZER_BROODER, LOW);

  // Servo stays detached until a turn is actually performed.
  eggServo.detach();
}

// ── Minimal JSON value extraction (no external JSON library) ──
const char* jsonFindValue(const char* json, const char* key) {
  char pattern[32];
  snprintf(pattern, sizeof(pattern), "\"%s\"", key);
  const char* p = strstr(json, pattern);
  if (p == nullptr) return nullptr;
  p += strlen(pattern);
  while (*p == ' ' || *p == '\t') p++;
  if (*p != ':') return nullptr;
  p++;
  while (*p == ' ' || *p == '\t') p++;
  return p;
}

bool jsonGetString(const char* json, const char* key, char* out, size_t outLen) {
  const char* p = jsonFindValue(json, key);
  if (p == nullptr || *p != '"') return false;
  p++;
  size_t i = 0;
  while (*p != '\0' && *p != '"' && i < outLen - 1) {
    out[i++] = *p++;
  }
  out[i] = '\0';
  return (*p == '"');
}

bool jsonGetBool(const char* json, const char* key, bool* out) {
  const char* p = jsonFindValue(json, key);
  if (p == nullptr) return false;
  if (strncmp(p, "true", 4) == 0) {
    *out = true;
    return true;
  }
  if (strncmp(p, "false", 5) == 0) {
    *out = false;
    return true;
  }
  return false;
}

bool isRelayActuator(const char* name, uint8_t* pinOut) {
  for (uint8_t i = 0; i < RELAY_COUNT; i++) {
    if (strcmp(name, RELAYS[i].name) == 0) {
      if (pinOut != nullptr) *pinOut = RELAYS[i].pin;
      return true;
    }
  }
  return false;
}

bool isKnownActuator(const char* name) {
  return isRelayActuator(name, nullptr) || strcmp(name, "eggTurningServo") == 0;
}

// ── Turning ──
void performTurn() {
  int target = servoToggle ? SERVO_POS_A : SERVO_POS_B;
  servoToggle = !servoToggle;
  eggServo.attach(PIN_EGG_SERVO);
  eggServo.write(target);
  delay(SERVO_MOVE_MS);
  eggServo.detach();
  lastTurnMillis = millis();
  turnsToday++;
}

// ── Outgoing messages ──
void sendAck(const char* id, bool success, const char* actuator, bool stateOn,
             const char* error) {
  char buf[192];
  if (success) {
    snprintf(buf, sizeof(buf),
             "{\"type\":\"ack\",\"id\":\"%s\",\"success\":true,"
             "\"actuator\":\"%s\",\"state\":%s,\"hardwareVerified\":false}",
             id, actuator, stateOn ? "true" : "false");
  } else {
    snprintf(buf, sizeof(buf),
             "{\"type\":\"ack\",\"id\":\"%s\",\"success\":false,"
             "\"error\":\"%s\"}",
             id, error);
  }
  Serial.println(buf);
}

void sendTelemetry() {
  char tInc[10], hInc[10], tBro[10], hBro[10];
  fmtFloatOrNull(incValid, incTemp, tInc, sizeof(tInc));
  fmtFloatOrNull(incValid, incHum, hInc, sizeof(hInc));
  fmtFloatOrNull(brooderValid, brooderTemp, tBro, sizeof(tBro));
  fmtFloatOrNull(brooderValid, brooderHum, hBro, sizeof(hBro));

  // Actuator states: relays are active-LOW, so ON == (pin reads LOW).
  bool bulb = (digitalRead(PIN_RELAY_INCUBATOR_BULB) == LOW);
  bool incFan = (digitalRead(PIN_RELAY_INCUBATOR_FAN) == LOW);
  bool exhaust = (digitalRead(PIN_RELAY_EXHAUST_FAN) == LOW);
  bool broBulb = (digitalRead(PIN_RELAY_BROODER_BULB) == LOW);
  bool incHum = (digitalRead(PIN_RELAY_INCUBATOR_HUMIDIFIER) == LOW);
  bool broHum = (digitalRead(PIN_RELAY_BROODER_HUMIDIFIER) == LOW);

  unsigned long secondsSinceTurn =
      (millis() - lastTurnMillis) / 1000UL;

  char buf[400];
  snprintf(buf, sizeof(buf),
           "{\"type\":\"telemetry\","
           "\"incubator\":{\"temperature\":%s,\"humidity\":%s},"
           "\"brooder\":{\"temperature\":%s,\"humidity\":%s},"
           "\"actuators\":{\"incubatorBulb\":%s,\"incubatorFan\":%s,"
           "\"exhaustFan\":%s,\"brooderBulb\":%s,\"incubatorHumidifier\":%s,"
           "\"brooderHumidifier\":%s,\"eggTurningServo\":%s},"
           "\"turning\":{\"intervalMinutes\":%lu,\"turnsToday\":%lu,"
           "\"secondsSinceLastTurn\":%lu,\"active\":%s}}",
           tInc, hInc, tBro, hBro,
           bulb ? "true" : "false", incFan ? "true" : "false",
           exhaust ? "true" : "false", broBulb ? "true" : "false",
           incHum ? "true" : "false", broHum ? "true" : "false",
           turningEnabled ? "true" : "false",
           TURN_INTERVAL_MS / 60000UL, turnsToday, secondsSinceTurn,
           turningEnabled ? "true" : "false");
  Serial.println(buf);
}

// ── Incoming commands ──
void handleCommand(const char* line) {
  char type[16];
  if (!jsonGetString(line, "type", type, sizeof(type))) {
    return; // no type -> ignore malformed input, never actuate
  }
  if (strcmp(type, "command") != 0) {
    return; // unknown message types are ignored safely
  }

  char id[24] = "";
  char actuator[24] = "";
  bool state = false;
  jsonGetString(line, "id", id, sizeof(id));

  if (!jsonGetString(line, "actuator", actuator, sizeof(actuator))) {
    sendAck(id, false, "", false, "Missing actuator");
    return;
  }
  if (!jsonGetBool(line, "state", &state)) {
    sendAck(id, false, actuator, false, "Missing or invalid state");
    return;
  }
  if (!isKnownActuator(actuator)) {
    sendAck(id, false, actuator, false, "Invalid actuator");
    return;
  }

  if (strcmp(actuator, "eggTurningServo") == 0) {
    // Enable/disable the automatic 4-hour turning schedule (not a manual sweep).
    turningEnabled = state;
  } else {
    uint8_t pin = 0;
    isRelayActuator(actuator, &pin);
    writeRelay(pin, state);
  }

  sendAck(id, true, actuator, state, "");
}

void pollSerial() {
  while (Serial.available() > 0) {
    char c = (char)Serial.read();
    if (c == '\n') {
      cmdBuffer[cmdLength] = '\0';
      if (cmdLength > 0) handleCommand(cmdBuffer);
      cmdLength = 0;
    } else if (c != '\r') {
      if (cmdLength < CMD_BUFFER_SIZE - 1) {
        cmdBuffer[cmdLength++] = c;
      } else {
        cmdLength = 0; // overflow: drop the line rather than mis-parse it
      }
    }
  }
}

void readSensors() {
  float t = incubatorDht.readTemperature();
  float h = incubatorDht.readHumidity();
  if (!isnan(t) && !isnan(h)) {
    incTemp = t;
    incHum = h;
    incValid = true;
  } else {
    incValid = false; // never report stale readings as current
  }

  t = brooderDht.readTemperature();
  h = brooderDht.readHumidity();
  if (!isnan(t) && !isnan(h)) {
    brooderTemp = t;
    brooderHum = h;
    brooderValid = true;
  } else {
    brooderValid = false;
  }
}

void checkTurningSchedule() {
  unsigned long currentDay = millis() / 86400000UL;
  if (currentDay != turnsDay) {
    turnsDay = currentDay;
    turnsToday = 0;
  }

  if (!turningEnabled) return;
  if (millis() - lastTurnMillis >= TURN_INTERVAL_MS) {
    performTurn();
  }
}

void setup() {
  Serial.begin(9600);
  initAllHardware();

  incubatorDht.begin();
  brooderDht.begin();

  // First automatic turn happens one full interval from now, so a reset never
  // immediately moves the trays.
  lastTurnMillis = millis();
  turnsDay = millis() / 86400000UL;
  turnsToday = 0;
}

void loop() {
  pollSerial();

  unsigned long now = millis();
  if (now - lastSensorMillis >= SENSOR_INTERVAL_MS) {
    lastSensorMillis = now;
    readSensors();
  }
  if (now - lastTelemetryMillis >= TELEMETRY_INTERVAL_MS) {
    lastTelemetryMillis = now;
    sendTelemetry();
  }

  checkTurningSchedule();
}
