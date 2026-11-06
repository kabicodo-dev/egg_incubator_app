import 'package:flutter/material.dart';
import 'package:egg_incubator_app/controllers/arduino_controller.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:egg_incubator_app/utils/actual_readings.dart';

// Diagnostic callers may use this too; no source-confirmed turning adapter yet.
String eggTurningDetail(ArduinoController controller) =>
    'No egg-turning update';

class EggTurningStatus extends StatelessWidget {
  const EggTurningStatus({super.key, required this.controller});
  final ArduinoController controller;
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Icon(Icons.sync, size: 16, color: AppColors.textSecondary),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          'Egg turning: No update',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    ],
  );
}

/// Farmer summary only. Serial/USB tools stay in the separate diagnostics page.
class LiveIncubatorStatusCard extends StatelessWidget {
  const LiveIncubatorStatusCard({super.key, required this.controller});
  final ArduinoController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sensors_off, color: AppColors.textSecondary, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Incubator Readings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'No updates from the incubator. Check the incubator and your phone’s Bluetooth connection.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 12),
          IncubatorReadings(reading: actualReadings(controller)),
          const Divider(height: 24),
          EggTurningStatus(controller: controller),
        ],
      ),
    ),
  );
}
