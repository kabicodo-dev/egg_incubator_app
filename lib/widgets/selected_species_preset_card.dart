import 'package:flutter/material.dart';
import '../models/species_data.dart';
import '../theme/app_theme.dart';
import 'species_illustration.dart';
import 'species_profile_summary.dart';

/// Selection metadata only. Change edits the form, never hardware settings.
class SelectedSpeciesPresetCard extends StatelessWidget {
  const SelectedSpeciesPresetCard({
    super.key,
    required this.species,
    this.subtitle,
    this.onChange,
  });
  final SpeciesData species;
  final String? subtitle;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('selected-species-preset'),
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderWarm),
      boxShadow: AppShadows.card,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final stackAction =
                constraints.maxWidth < 240 ||
                MediaQuery.textScalerOf(context).scale(14) > 21;
            Widget changeButton() => OutlinedButton(
              onPressed: onChange,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                side: const BorderSide(color: AppColors.primaryDark),
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: const Text('Change'),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SpeciesIllustration(
                      species: species.name,
                      emoji: species.emoji,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            species.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            subtitle ?? 'Selected preset',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onChange != null && !stackAction) ...[
                      const SizedBox(width: 6),
                      changeButton(),
                    ],
                  ],
                ),
                if (onChange != null && stackAction) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: changeButton(),
                  ),
                ],
              ],
            );
          },
        ),
        const Divider(height: 24, color: AppColors.borderWarm),
        SpeciesProfileSummary(species: species, compact: true),
      ],
    ),
  );
}
