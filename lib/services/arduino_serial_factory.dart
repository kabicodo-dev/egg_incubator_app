import 'arduino_serial_service.dart';
import 'arduino_serial_stub.dart'
    if (dart.library.io) 'arduino_serial_io.dart' as impl;

/// Creates the platform-appropriate serial service.
///
/// On desktop/mobile (`dart:io`) this is the `flutter_libserialport`-backed
/// implementation; elsewhere it is a stub that reports "unsupported" instead of
/// breaking web builds.
ArduinoSerialService createArduinoSerialService() => impl.createSerialServiceImpl();
