import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/screens/incubation/incubation_setup_screen.dart';
import 'package:egg_incubator_app/widgets/common/detail_rows.dart';
import 'package:egg_incubator_app/widgets/common/section_label.dart';
import 'package:egg_incubator_app/widgets/species_illustration.dart';

// ══════════════════════════════════════════════
// SPECIES DETAILS SCREEN
// ══════════════════════════════════════════════

class SpeciesDetailsScreen extends StatelessWidget {
  final SpeciesData species;
  const SpeciesDetailsScreen({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(species.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SpeciesIllustration(
                species: species.name,
                emoji: species.emoji,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              species.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            InfoRow(
              icon: Icons.calendar_today,
              label: 'Incubation Duration',
              value: '${species.incubationDays} days',
            ),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.thermostat,
              label: 'Temperature',
              value: species.temperature,
            ),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.water_drop_outlined,
              label: 'Humidity',
              value: '${species.targetHumidity}% RH',
            ),
            const SizedBox(height: 8),
            const Text(
              'Temperature and humidity are settings, not live readings.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            const SectionLabel(text: 'ABOUT THIS SPECIES'),
            const SizedBox(height: 8),
            Text(
              species.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          IncubationSetupScreen(selectedSpecies: species),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
