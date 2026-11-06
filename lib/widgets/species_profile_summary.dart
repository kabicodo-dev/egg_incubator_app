import 'package:flutter/material.dart';
import '../models/species_data.dart';
import '../theme/app_theme.dart';

/// Read-only species settings, never measured values or command inputs.
class SpeciesProfileSummary extends StatelessWidget {
  const SpeciesProfileSummary({
    super.key,
    required this.species,
    this.compact = false,
  });
  final SpeciesData species;
  final bool compact;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          constraints.maxWidth < (compact ? 225 : 270) ||
          MediaQuery.textScalerOf(context).scale(14) > 21;
      final width = stacked
          ? constraints.maxWidth
          : (constraints.maxWidth - 16) / 3;
      final values = <(String, String)>[
        ('Temperature', species.temperature),
        ('Humidity', '${species.targetHumidity}% RH'),
        (
          compact ? 'Duration' : 'Incubation Duration',
          '${species.incubationDays} days',
        ),
      ];
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (label, value) in values)
            Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}
