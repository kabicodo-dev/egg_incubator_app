// Minimal host shim for the Arduino core API used by SmartHatch_Combined.ino.
// This is ONLY for the A-02 NDJSON capture harness. It does not model AVR
// timing, relay hardware, DHT electrical behaviour or USB/Serial buffering.
#pragma once

#ifndef _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_WARNINGS
#endif

#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <cmath>
#include <string>

typedef uint8_t byte;

#define HIGH 0x1
#define LOW 0x0
#define INPUT 0x0
#define OUTPUT 0x1

#ifndef F
#define F(x) (x)
#endif

using std::isnan;

// Simulated clock (advanced by delay() and by the harness).
extern unsigned long g_now_ms;
unsigned long millis();
void delay(unsigned long ms);

void pinMode(uint8_t pin, uint8_t mode);
void digitalWrite(uint8_t pin, uint8_t value);
int digitalRead(uint8_t pin);

// Serial capture / scripted input.
extern std::string g_serial_in;
extern std::string g_serial_out;

class HostSerial {
 public:
  void begin(unsigned long) {}

  int available() { return static_cast<int>(g_serial_in.size()); }
  int read() {
    if (g_serial_in.empty()) return -1;
    int c = static_cast<unsigned char>(g_serial_in[0]);
    g_serial_in.erase(0, 1);
    return c;
  }

  size_t write(uint8_t c) {
    g_serial_out.push_back(static_cast<char>(c));
    return 1;
  }
  size_t write(const uint8_t* data, size_t n) {
    g_serial_out.append(reinterpret_cast<const char*>(data), n);
    return n;
  }

  void print(const char* s) { g_serial_out += s; }
  void print(char c) { g_serial_out.push_back(c); }
  void print(unsigned char v) { char b[8]; snprintf(b, sizeof(b), "%u", static_cast<unsigned>(v)); g_serial_out += b; }
  void print(int v) { char b[16]; snprintf(b, sizeof(b), "%d", v); g_serial_out += b; }
  void print(unsigned int v) { char b[16]; snprintf(b, sizeof(b), "%u", v); g_serial_out += b; }
  void print(long v) { char b[24]; snprintf(b, sizeof(b), "%ld", v); g_serial_out += b; }
  void print(unsigned long v) { char b[24]; snprintf(b, sizeof(b), "%lu", v); g_serial_out += b; }
  void print(double v, int digits = 2) {
    char b[32];
    snprintf(b, sizeof(b), "%.*f", digits, v);
    g_serial_out += b;
  }

  void println() { g_serial_out += "\r\n"; }
  void println(const char* s) { print(s); println(); }
  void println(char c) { print(c); println(); }
  void println(unsigned char v) { print(v); println(); }
  void println(int v) { print(v); println(); }
  void println(unsigned int v) { print(v); println(); }
  void println(long v) { print(v); println(); }
  void println(unsigned long v) { print(v); println(); }
  void println(double v, int digits = 2) { print(v, digits); println(); }
};

extern HostSerial Serial;
