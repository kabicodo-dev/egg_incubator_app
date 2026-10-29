#pragma once
#include <stdint.h>

// The LCD is display-only and not part of the NDJSON wire contract.
class LiquidCrystal_I2C {
 public:
  LiquidCrystal_I2C(uint8_t, uint8_t, uint8_t) {}
  void init() {}
  void backlight() {}
  void clear() {}
  void setCursor(uint8_t, uint8_t) {}
  void print(const char*) {}
  void print(char) {}
  void print(unsigned char) {}
  void print(int) {}
  void print(double, int = 2) {}
};
