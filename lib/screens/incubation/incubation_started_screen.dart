import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/navigation/main_navigation.dart';
import 'package:egg_incubator_app/screens/incubation/active_incubation_screen.dart';
import 'package:egg_incubator_app/widgets/common/detail_rows.dart';
import 'package:egg_incubator_app/widgets/species_illustration.dart';

// ══════════════════════════════════════════════
// INCUBATION STARTED CONFIRMATION
// ══════════════════════════════════════════════

class IncubationStartedScreen extends StatelessWidget {
  final SpeciesData species;
  final int eggCount;
  final int sessionId;
  const IncubationStartedScreen({
    super.key,
    required this.species,
    required this.eggCount,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final batchNum = 'Batch #$sessionId';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Batch record saved',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This saves your batch details. It does not start the incubator.',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      DetailRow(label: 'Batch', value: batchNum),
                      const SizedBox(height: 12),
                      DetailRow(
                        label: 'Species',
                        leading: SpeciesIllustration(
                          species: species.name,
                          emoji: species.emoji,
                          size: 32,
                        ),
                        value: species.name,
                      ),
                      const SizedBox(height: 12),
                      DetailRow(label: 'Eggs', value: '$eggCount'),
                      const SizedBox(height: 12),
                      DetailRow(label: 'Start Date', value: 'Unavailable'),
                      const SizedBox(height: 12),
                      DetailRow(
                        label: 'Expected Hatch',
                        value: 'Not available yet',
                      ),
                      const SizedBox(height: 12),
                      DetailRow(
                        label: 'Batch settings',
                        value: 'Not available',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainNavigation(),
                        ),
                        (route) => false,
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
                      'Back to Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActiveIncubationScreen(
                            species: species,
                            eggCount: eggCount,
                            batchId: batchNum,
                            sessionId: sessionId,
                            startDate: null,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View Incubation',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkPressed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
