#pragma once

extern int g_servo_angle;
extern bool g_servo_attached;

class Servo {
 public:
  void attach(int) { g_servo_attached = true; }
  void detach() { g_servo_attached = false; }
  void write(int angle) { g_servo_angle = angle; }
};
