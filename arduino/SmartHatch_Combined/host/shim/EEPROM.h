#pragma once
#include <stdint.h>
#include <string.h>

// Zeroed EEPROM => invalid magic => firmware reports a fresh batch at boot.
class EEPROMClass {
 public:
  template <typename T>
  void get(int address, T& value) {
    memcpy(&value, memory_ + address, sizeof(T));
  }
  template <typename T>
  void put(int address, const T& value) {
    memcpy(memory_ + address, &value, sizeof(T));
  }

 private:
  uint8_t memory_[1024] = {0};
};

extern EEPROMClass EEPROM;
