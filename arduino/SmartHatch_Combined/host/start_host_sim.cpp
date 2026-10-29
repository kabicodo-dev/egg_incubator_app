// A-06 host START/ACK/RUNNING harness for SmartHatch_Combined.ino.
//
// It compiles the REAL sketch against shimmed AVR headers, records every
// digitalWrite() as a pin level, and can override digitalRead() to simulate a
// relay-latch readback mismatch. stdout is the exact Serial byte stream.
//
// SCOPE: software evidence only. It does not model 9600-baud timing, USB/HC-05
// buffering, real relay contacts, DHT electrical behaviour, sensor accuracy or
// physical incubation. No board is flashed and no load is energised.

#include "shim/Arduino.h"

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif

#include "../SmartHatch_Combined.ino"

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
static int g_pin_read_override[32];

unsigned long millis() { return g_now_ms; }
void delay(unsigned long ms) { g_now_ms += ms; }
void pinMode(uint8_t, uint8_t) {}
void digitalWrite(uint8_t pin, uint8_t value) {
  if (pin < 32) g_pin_level[pin] = value;
}
int digitalRead(uint8_t pin) {
  if (pin < 32 && g_pin_read_override[pin] >= 0) return g_pin_read_override[pin];
  return pin < 32 ? g_pin_level[pin] : HIGH;
}

namespace {

int g_checks = 0;
int g_failures = 0;

void record(const char* id, const std::string& what, bool ok) {
  ++g_checks;
  if (!ok) ++g_failures;
  fprintf(stderr, "A-06 %s %-46s %s\n", ok ? "PASS" : "FAIL", id, what.c_str());
}

void expect(const char* id, const std::string& what, bool ok) {
  record(id, what, ok);
}

std::vector<std::string> linesOf(const std::string& text) {
  std::vector<std::string> out;
  size_t start = 0;
  while (start < text.size()) {
    size_t end = text.find('\n', start);
    if (end == std::string::npos) break;
    out.push_back(text.substr(start, end - start));
    start = end + 1;
  }
  return out;
}

bool lineHas(const std::string& line, std::initializer_list<const char*> needles) {
  for (const char* needle : needles) {
    if (line.find(needle) == std::string::npos) return false;
  }
  return true;
}

int findLine(const std::string& text, std::initializer_list<const char*> needles) {
  int index = 0;
  for (const std::string& line : linesOf(text)) {
    if (lineHas(line, needles)) return index;
    ++index;
  }
  return -1;
}

int countLines(const std::string& text, std::initializer_list<const char*> needles) {
  int count = 0;
  for (const std::string& line : linesOf(text)) {
    if (lineHas(line, needles)) ++count;
  }
  return count;
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

void sendLine(const std::string& line) {
  g_serial_in += line;
  g_serial_in += '\n';
}

void sendStart(long id, long batchId) {
  char buf[96];
  if (batchId > 0) {
    snprintf(buf, sizeof(buf), "{\"id\":%ld,\"cmd\":\"START\",\"batch_id\":%ld}", id, batchId);
  } else {
    snprintf(buf, sizeof(buf), "{\"id\":%ld,\"cmd\":\"START\"}", id);
  }
  sendLine(buf);
}

void sendCommand(long id, const char* cmd) {
  char buf[96];
  snprintf(buf, sizeof(buf), "{\"id\":%ld,\"cmd\":\"%s\"}", id, cmd);
  sendLine(buf);
}

std::string tailSince(size_t mark) { return g_serial_out.substr(mark); }

void expectStartAck(const char* checkId, const std::string& text, long commandId,
                    long batchId, const char* message) {
  char needleId[32], needleBatch[32], needleMessage[64];
  snprintf(needleId, sizeof(needleId), "\"command_id\":%ld", commandId);
  snprintf(needleBatch, sizeof(needleBatch), "\"batch_id\":%ld", batchId);
  snprintf(needleMessage, sizeof(needleMessage), "\"message\":\"%s\"", message);
  const bool present = findLine(text, {"\"type\":\"ack\"", "\"cmd\":\"START\"",
                                       needleId, needleBatch, needleMessage}) >= 0;
  expect(checkId, std::string("START ack ") + message + " with ids", present);
}

void expectStartRunning(const char* checkId, const std::string& text, long commandId,
                        long batchId) {
  char needleId[32], needleBatch[32];
  snprintf(needleId, sizeof(needleId), "\"command_id\":%ld", commandId);
  snprintf(needleBatch, sizeof(needleBatch), "\"batch_id\":%ld", batchId);
  const bool present = findLine(text, {"\"type\":\"running\"", "\"cmd\":\"START\"",
                                       needleId, needleBatch, "\"status\":\"running\""}) >= 0;
  expect(checkId, "START running status with ids", present);
}

bool ackBeforeRunning(const std::string& text, long commandId) {
  char needleId[32];
  snprintf(needleId, sizeof(needleId), "\"id\":%ld", commandId);
  const int ack = findLine(text, {"\"type\":\"ack\"", "\"cmd\":\"START\"", needleId});
  const int running = findLine(text, {"\"type\":\"running\"", "\"cmd\":\"START\"", needleId});
  return ack >= 0 && running >= 0 && ack < running;
}

bool hasNoStartRunning(const std::string& text, long commandId) {
  char needleId[32];
  snprintf(needleId, sizeof(needleId), "\"id\":%ld", commandId);
  return findLine(text, {"\"type\":\"running\"", "\"cmd\":\"START\"", needleId}) < 0;
}

}  // namespace

int main() {
#ifdef _WIN32
  _setmode(_fileno(stdout), _O_BINARY);
#endif
  for (uint8_t i = 0; i < 32; ++i) {
    g_pin_level[i] = HIGH;
    g_pin_read_override[i] = -1;
  }

  setIncubator(37.6f, 51.4f);
  setBrooder(31.2f, 49.0f);
  setup();

  // ── 1. ACK is receipt only; a fresh sensor read and output latch check must
  //       happen before RUNNING. START is sent 500 ms after the last read. ──
  advanceMs(3000UL);
  size_t mark = g_serial_out.size();
  sendStart(301, 7001);
  loop();
  std::string first = tailSince(mark);
  expectStartAck("A1-ack", first, 301, 7001, "start_received");
  expect("A1-no-running-yet", "no RUNNING in the receipt pass", hasNoStartRunning(first, 301));
  expect("A1-pending", "start is pending after ACK", startPending);
  expect("A1-not-confirmed", "startConfirmed is still false", !startConfirmed);
  expect("A1-batch-unbound", "activeBatchId is still 0", activeBatchId == 0);

  advanceMs(3000UL);  // fresh DHT read + control pass at ~5 s
  std::string confirmed = tailSince(mark);
  expect("A2-confirmed", "activeBatchId bound", activeBatchId == 7001);
  expect("A2-confirmed-flag", "startConfirmed true", startConfirmed);
  expect("A2-pending-cleared", "startPending false", !startPending);
  expectStartRunning("A2-running", confirmed, 301, 7001);
  expect("A2-order", "ACK precedes RUNNING", ackBeforeRunning(confirmed, 301));
  expect("A2-elapsed-start", "original Start begins at RUNNING", batchState.elapsedSeconds <= 1);

  // ── 2. Duplicate same command id must replay, not restart. ──
  advanceMs(5000UL);
  uint32_t elapsedBeforeDuplicate = batchState.elapsedSeconds;
  mark = g_serial_out.size();
  sendStart(301, 7001);
  loop();
  std::string duplicate = tailSince(mark);
  expectStartAck("D1-ack-replay", duplicate, 301, 7001, "start_received");
  expectStartRunning("D1-running-replay", duplicate, 301, 7001);
  expect("D1-no-reset", "elapsed did not reset",
         batchState.elapsedSeconds >= elapsedBeforeDuplicate);
  expect("D1-no-batch-started", "no second batch_started event",
         countLines(duplicate, {"\"event\":\"batch_started\""}) == 0);

  // ── 3. Same batch id with a new command id is idempotent. ──
  mark = g_serial_out.size();
  sendStart(302, 7001);
  loop();
  std::string sameBatch = tailSince(mark);
  expectStartAck("D2-ack", sameBatch, 302, 7001, "start_already_running");
  expectStartRunning("D2-running", sameBatch, 302, 7001);
  expect("D2-no-reset", "elapsed still not reset",
         batchState.elapsedSeconds >= elapsedBeforeDuplicate);

  // ── 4. A different batch id while one is active is rejected. ──
  mark = g_serial_out.size();
  sendStart(303, 7002);
  loop();
  std::string different = tailSince(mark);
  expect("D3-rejected", "different batch rejected",
         findLine(different, {"\"type\":\"ack\"", "\"cmd\":\"START\"", "\"id\":303",
                              "\"error\":{\"code\":\"batch_already_running\""}) >= 0);
  expect("D3-no-running", "no RUNNING for rejected batch", hasNoStartRunning(different, 303));
  expect("D3-bound-stable", "activeBatchId unchanged", activeBatchId == 7001);

  // ── 5. Missing batch_id is rejected before any state change. ──
  mark = g_serial_out.size();
  sendStart(304, 0);
  loop();
  std::string missing = tailSince(mark);
  expect("D4-invalid", "missing batch_id rejected",
         findLine(missing, {"\"type\":\"ack\"", "\"cmd\":\"START\"", "\"id\":304",
                            "\"error\":{\"code\":\"invalid_batch_id\""}) >= 0);
  expect("D4-no-running", "no RUNNING for invalid batch", hasNoStartRunning(missing, 304));

  // ── 6. Sensor failure: ACK is receipt only; RUNNING waits for a fresh valid
  //       reading for both chambers. ──
  sendCommand(305, "NEW_BATCH");
  loop();
  expect("S0-reset", "NEW_BATCH clears active batch", activeBatchId == 0);
  g_dht_fail[INCUBATOR_DHT_PIN] = true;
  advanceMs(11000UL);  // beyond SENSOR_STALE_TIMEOUT_MS
  expect("S0b-invalid", "incubator sensor invalid before START", !incubatorSensorValid);
  mark = g_serial_out.size();
  sendStart(306, 7003);
  loop();
  std::string sensorPending = tailSince(mark);
  expectStartAck("S1-ack", sensorPending, 306, 7003, "start_received");
  expect("S1-no-running", "no RUNNING while incubator sensor invalid",
         hasNoStartRunning(sensorPending, 306));
  advanceMs(6000UL);  // force at least one invalid telemetry frame
  expect("S2-no-running", "still no RUNNING after another invalid pass",
         hasNoStartRunning(tailSince(mark), 306));
  expect("S2-still-pending", "still pending after another invalid pass", startPending);
  g_dht_fail[INCUBATOR_DHT_PIN] = false;
  setIncubator(37.6f, 51.4f);
  advanceMs(3000UL);
  expect("S3-confirmed", "RUNNING after both sensors recover", !startPending && startConfirmed);
  expect("S3-batch", "batch 7003 bound", activeBatchId == 7003);

  // ── 7. Actuator latch mismatch: ACK is receipt only; RUNNING waits until the
  //       MCU output latch agrees with the control law. ──
  sendCommand(307, "NEW_BATCH");
  loop();
  g_pin_read_override[INCUBATOR_FAN_RELAY_PIN] = HIGH;  // fan commanded ON
  mark = g_serial_out.size();
  sendStart(308, 7004);
  loop();
  std::string actuatorPending = tailSince(mark);
  expectStartAck("L1-ack", actuatorPending, 308, 7004, "start_received");
  advanceMs(6000UL);  // force at least one control/telemetry pass while mismatched
  expect("L1-no-running", "no RUNNING on relay readback mismatch",
         hasNoStartRunning(tailSince(mark), 308));
  expect("L2-still-pending", "still pending on mismatch", startPending);
  g_pin_read_override[INCUBATOR_FAN_RELAY_PIN] = -1;
  advanceMs(1000UL);
  expect("L3-confirmed", "RUNNING after latch matches", !startPending && startConfirmed);
  expect("L3-batch", "batch 7004 bound", activeBatchId == 7004);

  // ── 8. EEPROM reload simulation: the start identity survives a RAM reset and
  //       a duplicate START does not reset the batch timer. ──
  advanceMs(5000UL);
  saveBatchState();
  uint32_t elapsedBeforeReload = batchState.elapsedSeconds;
  g_now_ms = 1000UL;  // first post-reboot read; avoid the 0 sentinel
  activeBatchId = 0;
  startConfirmed = false;
  startPending = false;
  pendingStartIsResume = false;
  incubatorSensorValid = false;
  brooderSensorValid = false;
  lastIncubatorGoodRead = 0;
  lastBrooderGoodRead = 0;
  lastSensorRead = g_now_ms - SENSOR_READ_INTERVAL_MS;  // force the first read
  incubatorHeatInitialized = false;
  incubatorHumidityInitialized = false;
  brooderHeatInitialized = false;
  brooderHumidityInitialized = false;
  for (byte i = 0; i < ACK_CACHE_SIZE; ++i) ackCache[i].used = false;
  loadBatchState();
  loadStartRecord();
  expect("R1-restored", "start identity restored from EEPROM", activeBatchId == 7004);
  expect("R1-sensors-invalid", "sensor state starts invalid after reboot",
         !incubatorSensorValid && !brooderSensorValid);
  expect("R2-elapsed-restored", "elapsed restored", batchState.elapsedSeconds >= elapsedBeforeReload);
  mark = g_serial_out.size();
  sendStart(309, 7004);
  loop();
  std::string reload = tailSince(mark);
  expectStartAck("R3-ack", reload, 309, 7004, "start_already_running");
  expect("R3-valid", "reload sensors valid after first loop",
         incubatorSensorValid && brooderSensorValid);
  expect("R3-actuators", "reload actuators match", actuatorsMatchControl());
  expectStartRunning("R3-running", reload, 309, 7004);
  expect("R3-no-reset", "reload duplicate did not reset elapsed",
         batchState.elapsedSeconds >= elapsedBeforeReload);

  // ── 9. Explicit NEW_BATCH clears the start identity and allows a new batch. ──
  sendCommand(310, "NEW_BATCH");
  loop();
  expect("N1-cleared", "NEW_BATCH clears activeBatchId", activeBatchId == 0);
  mark = g_serial_out.size();
  sendStart(311, 7005);
  loop();
  advanceMs(3000UL);
  expect("N2-confirmed", "new batch 7005 confirmed", activeBatchId == 7005 && startConfirmed);

  // ── 10. A completed batch is not restarted by a duplicate START. ──
  batchState.elapsedSeconds = (uint32_t)hatchDay * 86400UL;
  saveBatchState();
  mark = g_serial_out.size();
  sendStart(312, 7005);
  loop();
  std::string complete = tailSince(mark);
  expect("C1-rejected", "completed batch rejected",
         findLine(complete, {"\"type\":\"ack\"", "\"cmd\":\"START\"", "\"id\":312",
                             "\"error\":{\"code\":\"batch_already_complete\""}) >= 0);
  expect("C1-no-running", "no RUNNING for completed batch", hasNoStartRunning(complete, 312));

  fwrite(g_serial_out.data(), 1, g_serial_out.size(), stdout);
  fflush(stdout);

  fprintf(stderr,
          "A-06 start_host_sim: checks=%d failures=%d bytes=%zu lines=%zu simulated_ms=%lu\n",
          g_checks, g_failures, g_serial_out.size(),
          static_cast<size_t>(std::count(g_serial_out.begin(), g_serial_out.end(), '\n')),
          g_now_ms);
  return g_failures == 0 ? 0 : 1;
}
