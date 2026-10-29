// A-02 host capture harness for SmartHatch_Combined.ino.
//
// It compiles the REAL sketch source against shimmed AVR headers and drives
// setup()/loop() with scripted serial input and simulated time. stdout is the
// byte stream the sketch sent to Serial, so the captured NDJSON lines are
// produced by the production emit code (not re-typed by hand).
//
// It does NOT model 9600-baud timing, USB buffering, DHT electrical behaviour,
// relay polarity, servo torque or any safety property. No hardware is touched.

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

unsigned long millis() { return g_now_ms; }
void delay(unsigned long ms) { g_now_ms += ms; }

void pinMode(uint8_t, uint8_t) {}
void digitalWrite(uint8_t, uint8_t) {}
int digitalRead(uint8_t) { return HIGH; }

namespace {

struct Step {
  unsigned long at_ms;
  std::string line;
  bool fail_incubator_sensor = false;
};

std::string command(long id, const char* cmd) {
  char buf[96];
  snprintf(buf, sizeof(buf), "{\"id\":%ld,\"cmd\":\"%s\"}", id, cmd);
  return buf;
}

}  // namespace

int main() {
#ifdef _WIN32
  // Keep stdout byte-exact: no CRLF translation by the host C runtime.
  _setmode(_fileno(stdout), _O_BINARY);
#endif

  const uint8_t kIncubatorDhtPin = INCUBATOR_DHT_PIN;  // D2
  const uint8_t kBrooderDhtPin = BROODER_DHT_PIN;      // D4

  // Scripted, non-physical readings. These are shim inputs, not measurements.
  g_dht_temp_c[kIncubatorDhtPin] = 37.6f;
  g_dht_humidity[kIncubatorDhtPin] = 51.4f;
  g_dht_temp_c[kBrooderDhtPin] = 31.2f;
  g_dht_humidity[kBrooderDhtPin] = 49.0f;

  std::vector<Step> steps;
  // Before the first valid DHT read the frame must report nulls, not zeros.
  steps.push_back({100, command(101, "STATUS")});
  // After a valid read, exercise accepted TURN_NOW (running -> event -> ack).
  steps.push_back({3000, command(102, "TURN_NOW")});
  steps.push_back({3100, command(103, "NOPE")});
  // Duplicate id: must replay the original terminal ack, not re-run the turn.
  steps.push_back({4000, command(102, "TURN_NOW")});
  steps.push_back({4100, command(104, "NEW_BATCH")});
  steps.push_back({4200, "{\"id\":105}"});  // structured validation error
  // Exactly 120 bytes then LF: the 120th byte overflows the 120-byte line
  // buffer and must produce a structured line_too_long ack.
  steps.push_back({4300, std::string(120, 'A')});
  // Make the incubator sensor fail, then wait past SENSOR_STALE_TIMEOUT_MS.
  steps.push_back({6000, "", true});
  steps.push_back({17000, command(106, "STATUS")});

  setup();

  size_t next = 0;
  while (g_now_ms <= 19000UL) {
    if (next < steps.size() && g_now_ms >= steps[next].at_ms) {
      if (steps[next].fail_incubator_sensor) {
        g_dht_fail[kIncubatorDhtPin] = true;
      } else {
        g_serial_in += steps[next].line;
        g_serial_in += '\n';
      }
      ++next;
    }
    loop();
    g_now_ms += 100UL;
  }

  fwrite(g_serial_out.data(), 1, g_serial_out.size(), stdout);
  fflush(stdout);

  // Diagnostics go to stderr so stdout stays pure NDJSON.
  fprintf(stderr,
          "host_sim: bytes=%zu lines=%zu simulated_ms=%lu\n",
          g_serial_out.size(),
          static_cast<size_t>(std::count(g_serial_out.begin(), g_serial_out.end(), '\n')),
          g_now_ms);
  return 0;
}
