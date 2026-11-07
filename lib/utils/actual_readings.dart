import 'package:egg_incubator_app/controllers/arduino_controller.dart';
import 'package:egg_incubator_app/widgets/incubator_readings.dart';

ActualReadingSnapshot actualReadings(ArduinoController controller) {
  final telemetry = controller.telemetry;
  return ActualReadingSnapshot.fromReceipt(
    connected: controller.isConnected,
    temperature: telemetry?.incubatorTemperature,
    humidity: telemetry?.incubatorHumidity,
    receivedAt: telemetry?.receivedAt,
    now: DateTime.now(),
    // Existing receipt window, not a new approved acquisition-age threshold.
    staleAfter: ArduinoController.staleAfter,
  );
}
