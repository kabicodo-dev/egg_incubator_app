#pragma once
#include <stdint.h>

#define DHT11 11
#define DHT22 22

// Scripted DHT11 stub. g_dht_fail[pin] makes both reads return NaN, which the
// firmware must treat as "sensor invalid" (never a stale reading).
extern float g_dht_temp_c[32];
extern float g_dht_humidity[32];
extern bool g_dht_fail[32];

class DHT {
 public:
  DHT(uint8_t pin, uint8_t) : pin_(pin) {}
  void begin() {}
  float readTemperature() { return g_dht_fail[pin_] ? NAN : g_dht_temp_c[pin_]; }
  float readHumidity() { return g_dht_fail[pin_] ? NAN : g_dht_humidity[pin_]; }

 private:
  uint8_t pin_;
};
