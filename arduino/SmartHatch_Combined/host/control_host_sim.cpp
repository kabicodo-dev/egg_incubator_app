// A-03 host control/fail-safe harness for SmartHatch_Combined.ino.
//
// It compiles the REAL sketch source against shimmed AVR headers, records every
// digitalWrite() as a pin level, and drives setup()/loop() with scripted sensor
// readings and simulated time. stdout is the exact Serial byte stream, so the
// captured NDJSON comes from the production emit code.
//
// SCOPE: software evidence only. This harness does not model 9600-baud timing,
// USB buffering, DHT electrical behaviour, relay polarity, real temperatures,
// heater power, sensor accuracy or any physical safety property. It never
// flashes a board and never energises a load.
//
// The assertions below check the control law and the safe-state transitions.

#include "shim/Arduino.h"

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <string>

#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif

#include "../SmartHatch_Combined.ino"

// ── Shim state ──
unsigned long g_now_ms = 0;
std::string g_serial_in;
std::string g_serial_out;
HostSerial Serial;

float g_dht_temp_c[32] = {0};
float g_dht_humidity[32] = {0};
bool g_dht_fail[32] = {0};

int g_servo_angle = 90;
bool g_servo_attached = false;

EEPROMClass EEPROM;
TwoWire Wire;

static uint8_t g_pin_level[32];
static bool g_pin_is_output[32];

unsigned long millis() { return g_now_ms; }
void delay(unsigned long ms) { g_now_ms += ms; }

void pinMode(uint8_t pin, uint8_t mode) {
  if (pin < 32) g_pin_is_output[pin] = (mode == OUTPUT);
}
void digitalWrite(uint8_t pin, uint8_t value) {
  if (pin < 32) g_pin_level[pin] = value;
}
int digitalRead(uint8_t pin) { return pin < 32 ? g_pin_level[pin] : HIGH; }

namespace {

int g_checks = 0;
int g_failures = 0;

bool relayOn(uint8_t pin) {
  return g_pin_level[pin] == (RELAY_ACTIVE_LOW ? LOW : HIGH);
}

void record(const char* id, const std::string& what, bool ok) {
  ++g_checks;
  if (!ok) ++g_failures;
  fprintf(stderr, "A-03 %s %-46s %s\n", ok ? "PASS" : "FAIL", id, what.c_str());
}

void expectRelay(const char* id, uint8_t pin, bool on) {
  char what[80];
  snprintf(what, sizeof(what), "D%u relay %s (level=%u)", pin, on ? "ON" : "OFF",
           static_cast<unsigned>(g_pin_level[pin]));
  record(id, what, relayOn(pin) == on);
}

void expectTrue(const char* id, bool actual) {
  record(id, std::string("actual=") + (actual ? "true" : "false") + " expected=true", actual);
}
void expectFalse(const char* id, bool actual) {
  record(id, std::string("actual=") + (actual ? "true" : "false") + " expected=false", !actual);
}
void expectEqual(const char* id, const char* name, bool actual, bool expected) {
  char what[96];
  snprintf(what, sizeof(what), "%s=%s expected %s", name, actual ? "true" : "false",
           expected ? "true" : "false");
  record(id, what, actual == expected);
}

void checkIncubatorPinsMatchFlags(const char* id) {
  record(id, "bulb flag/pin consistent", incubatorBulbState == relayOn(INCUBATOR_BULB_RELAY_PIN));
  record(id, "humidifier flag/pin consistent", incubatorHumidifierState == relayOn(INCUBATOR_HUMIDIFIER_RELAY_PIN));
  record(id, "fan flag/pin consistent", incubatorFanState == relayOn(INCUBATOR_FAN_RELAY_PIN));
  record(id, "exhaust flag/pin consistent", exhaustFanState == relayOn(EXHAUST_FAN_RELAY_PIN));
}

void setIncubator(float temperature, float humidity) {
  g_dht_temp_c[INCUBATOR_DHT_PIN] = temperature;
  g_dht_humidity[INCUBATOR_DHT_PIN] = humidity;
}
void setBrooder(float temperature, float humidity) {
  g_dht_temp_c[BROODER_DHT_PIN] = temperature;
  g_dht_humidity[BROODER_DHT_PIN] = humidity;
}

void advanceMs(unsigned long ms) {
  const unsigned long target = g_now_ms + ms;
  while (g_now_ms < target) {
    loop();
    g_now_ms += 50UL;
  }
}

void snapshot(long id) {
  char buf[96];
  snprintf(buf, sizeof(buf), "{\"id\":%ld,\"cmd\":\"STATUS\"}", id);
  g_serial_in += buf;
  g_serial_in += '\n';
  loop();
}

void settle(long id) {
  // Longer than SENSOR_READ_INTERVAL_MS so the scripted value is actually read.
  advanceMs(3000UL);
  snapshot(id);
}

void checkAllIncubatorOff(const char* id) {
  expectFalse(id, incubatorBulbState);
  expectFalse(id, incubatorHumidifierState);
  expectFalse(id, incubatorFanState);
  expectFalse(id, exhaustFanState);
  expectRelay(id, INCUBATOR_BULB_RELAY_PIN, false);
  expectRelay(id, INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
  expectRelay(id, INCUBATOR_FAN_RELAY_PIN, false);
  expectRelay(id, EXHAUST_FAN_RELAY_PIN, false);
  checkIncubatorPinsMatchFlags(id);
}

void checkAllBrooderOff(const char* id) {
  expectFalse(id, brooderBulbState);
  expectFalse(id, brooderHumidifierState);
  expectRelay(id, BROODER_BULB_RELAY_PIN, false);
  expectRelay(id, BROODER_HUMIDIFIER_RELAY_PIN, false);
}

}  // namespace

int main() {
#ifdef _WIN32
  _setmode(_fileno(stdout), _O_BINARY);
#endif
  for (uint8_t i = 0; i < 32; ++i) g_pin_level[i] = HIGH;  // relays start OFF

  setIncubator(37.6f, 51.4f);
  setBrooder(31.2f, 49.0f);

  setup();

  // ── 1. Boot with no serial traffic: local regulation starts on its own ──
  advanceMs(3000UL);
  snapshot(201);

  expectTrue("F0-valid", incubatorSensorValid);
  expectTrue("F0-heat-on", incubatorBulbState);
  expectRelay("F0-heat-pin", INCUBATOR_BULB_RELAY_PIN, true);
  expectFalse("F0-humid-off", incubatorHumidifierState);
  expectRelay("F0-humid-pin", INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
  expectTrue("F0-fan-on", incubatorFanState);
  expectRelay("F0-fan-pin", INCUBATOR_FAN_RELAY_PIN, true);
  expectRelay("F0-exhaust-off", EXHAUST_FAN_RELAY_PIN, false);
  checkIncubatorPinsMatchFlags("F0-consistent");
  expectTrue("F0-brooder-valid", brooderSensorValid);
  expectFalse("F0-brooder-heat", brooderBulbState);
  expectFalse("F0-brooder-humid", brooderHumidifierState);

  // ── 2. Temperature hysteresis 37.5 / 38.0 °C ──
  setIncubator(37.4f, 51.4f);
  settle(202);
  expectTrue("T1-37.4-on", incubatorBulbState);
  expectRelay("T1-37.4-pin", INCUBATOR_BULB_RELAY_PIN, true);

  setIncubator(37.6f, 51.4f);
  settle(203);
  expectTrue("T2-37.6-hold-on", incubatorBulbState);

  setIncubator(37.9f, 51.4f);
  settle(204);
  expectTrue("T3-37.9-hold-on", incubatorBulbState);

  setIncubator(38.0f, 51.4f);
  settle(205);
  expectFalse("T4-38.0-off", incubatorBulbState);
  expectRelay("T4-38.0-pin", INCUBATOR_BULB_RELAY_PIN, false);

  setIncubator(38.3f, 51.4f);
  settle(206);
  expectFalse("T5-38.3-off", incubatorBulbState);

  setIncubator(37.6f, 51.4f);
  settle(207);
  expectFalse("T6-37.6-hysteresis-off", incubatorBulbState);

  setIncubator(37.5f, 51.4f);
  settle(208);
  expectTrue("T7-37.5-on", incubatorBulbState);
  expectRelay("T7-37.5-pin", INCUBATOR_BULB_RELAY_PIN, true);

  // ── 3. Humidity hysteresis 45 / 55 % (active stage) ──
  setIncubator(37.5f, 44.9f);
  settle(209);
  expectTrue("H1-44.9-on", incubatorHumidifierState);
  expectRelay("H1-44.9-pin", INCUBATOR_HUMIDIFIER_RELAY_PIN, true);

  setIncubator(37.5f, 45.0f);
  settle(210);
  expectTrue("H2-45.0-hold-on", incubatorHumidifierState);

  setIncubator(37.5f, 54.9f);
  settle(211);
  expectTrue("H3-54.9-hold-on", incubatorHumidifierState);

  setIncubator(37.5f, 55.0f);
  settle(212);
  expectFalse("H4-55.0-off", incubatorHumidifierState);
  expectRelay("H4-55.0-pin", INCUBATOR_HUMIDIFIER_RELAY_PIN, false);

  setIncubator(37.5f, 50.0f);
  settle(213);
  expectFalse("H5-50.0-hold-off", incubatorHumidifierState);

  setIncubator(37.5f, 44.9f);
  settle(214);
  expectTrue("H6-44.9-on-again", incubatorHumidifierState);

  // ── 4. Over-temperature fail-safe ──
  setIncubator(39.0f, 50.0f);
  settle(215);
  expectFalse("O1-39.0-heat-off", incubatorBulbState);
  expectRelay("O1-39.0-heat-pin", INCUBATOR_BULB_RELAY_PIN, false);
  expectFalse("O1-39.0-humid-off", incubatorHumidifierState);
  expectRelay("O1-39.0-humid-pin", INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
  expectTrue("O1-39.0-fan-on", incubatorFanState);
  expectRelay("O1-39.0-fan-pin", INCUBATOR_FAN_RELAY_PIN, true);
  checkIncubatorPinsMatchFlags("O1-consistent");

  setIncubator(39.5f, 44.9f);
  settle(216);
  expectFalse("O2-39.5-heat-off", incubatorBulbState);
  expectFalse("O2-39.5-humid-off", incubatorHumidifierState);
  expectRelay("O2-39.5-humid-pin", INCUBATOR_HUMIDIFIER_RELAY_PIN, false);
  expectTrue("O2-39.5-fan-on", incubatorFanState);

  setIncubator(38.5f, 44.9f);
  settle(217);
  expectFalse("O3-38.5-heat-off", incubatorBulbState);
  expectTrue("O3-38.5-humid-resumes", incubatorHumidifierState);

  setIncubator(37.5f, 44.9f);
  settle(218);
  expectTrue("O4-37.5-heat-recovers", incubatorBulbState);
  expectTrue("O4-37.5-humid-on", incubatorHumidifierState);

  // ── 5. Invalid/stale incubator sensor fail-safe ──
  g_dht_fail[INCUBATOR_DHT_PIN] = true;
  advanceMs(11000UL);  // > SENSOR_STALE_TIMEOUT_MS (10 s)
  snapshot(219);
  expectFalse("S1-incubator-invalid", incubatorSensorValid);
  checkAllIncubatorOff("S1-all-off");

  // Over-temperature followed by sensor loss must also end in all-off.
  g_dht_fail[INCUBATOR_DHT_PIN] = false;
  setIncubator(39.5f, 50.0f);
  settle(220);
  expectFalse("S2-overheat-heat-off", incubatorBulbState);
  g_dht_fail[INCUBATOR_DHT_PIN] = true;
  advanceMs(11000UL);
  snapshot(221);
  expectFalse("S2-invalid", incubatorSensorValid);
  checkAllIncubatorOff("S2-all-off");

  // Recovery clears the fail-safe and re-initialises control.
  g_dht_fail[INCUBATOR_DHT_PIN] = false;
  setIncubator(37.0f, 44.0f);
  settle(222);
  expectTrue("S3-recovered-valid", incubatorSensorValid);
  expectTrue("S3-heat-on", incubatorBulbState);
  expectTrue("S3-humid-on", incubatorHumidifierState);
  expectTrue("S3-fan-on", incubatorFanState);
  expectRelay("S3-fan-pin", INCUBATOR_FAN_RELAY_PIN, true);

  // Incubator regulation must continue while the brooder sensor is invalid.
  setBrooder(31.0f, 49.0f);
  g_dht_fail[BROODER_DHT_PIN] = true;
  advanceMs(11000UL);
  snapshot(223);
  expectFalse("B1-brooder-invalid", brooderSensorValid);
  checkAllBrooderOff("B1-all-off");
  expectTrue("B1-incubator-still-valid", incubatorSensorValid);
  expectTrue("B1-incubator-fan-on", incubatorFanState);

  g_dht_fail[BROODER_DHT_PIN] = false;
  setBrooder(31.0f, 49.0f);
  settle(224);
  expectTrue("B2-brooder-recovered", brooderSensorValid);
  expectFalse("B2-brooder-heat-off", brooderBulbState);
  expectFalse("B2-brooder-humid-off", brooderHumidifierState);

  // ── 6. Brooder regulation ──
  setBrooder(29.5f, 49.0f);
  settle(225);
  expectTrue("B3-29.5-heat-on", brooderBulbState);
  expectRelay("B3-29.5-heat-pin", BROODER_BULB_RELAY_PIN, true);

  setBrooder(31.0f, 49.0f);
  settle(226);
  expectTrue("B4-31.0-hold-on", brooderBulbState);

  setBrooder(32.0f, 49.0f);
  settle(227);
  expectFalse("B5-32.0-heat-off", brooderBulbState);
  expectRelay("B5-32.0-heat-pin", BROODER_BULB_RELAY_PIN, false);

  setBrooder(31.0f, 44.9f);
  settle(228);
  expectTrue("B6-44.9-humid-on", brooderHumidifierState);
  expectRelay("B6-44.9-humid-pin", BROODER_HUMIDIFIER_RELAY_PIN, true);

  setBrooder(31.0f, 60.0f);
  settle(229);
  expectFalse("B7-60.0-humid-off", brooderHumidifierState);
  expectRelay("B7-60.0-humid-pin", BROODER_HUMIDIFIER_RELAY_PIN, false);

  // ── 7. No serial input at all: regulation continues autonomously ──
  g_serial_in.clear();
  expectTrue("A1-no-pending-input", g_serial_in.empty());
  setIncubator(37.4f, 50.0f);
  advanceMs(20000UL);
  expectTrue("A1-autonomous-heat-on", incubatorBulbState);
  expectTrue("A1-autonomous-fan-on", incubatorFanState);

  expectTrue("A2-still-no-input", g_serial_in.empty());
  setIncubator(38.0f, 50.0f);
  advanceMs(20000UL);
  expectFalse("A2-autonomous-heat-off", incubatorBulbState);
  expectTrue("A2-autonomous-fan-on", incubatorFanState);
  expectTrue("A2-still-no-input-2", g_serial_in.empty());

  fwrite(g_serial_out.data(), 1, g_serial_out.size(), stdout);
  fflush(stdout);

  fprintf(stderr,
          "A-03 control_host_sim: checks=%d failures=%d bytes=%zu lines=%zu simulated_ms=%lu\n",
          g_checks, g_failures, g_serial_out.size(),
          static_cast<size_t>(std::count(g_serial_out.begin(), g_serial_out.end(), '\n')),
          g_now_ms);
  return g_failures == 0 ? 0 : 1;
}
