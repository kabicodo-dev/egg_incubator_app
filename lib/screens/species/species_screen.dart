import 'package:flutter/material.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/navigation/main_navigation.dart';
import 'package:egg_incubator_app/widgets/species_profile_summary.dart';
import 'package:egg_incubator_app/screens/incubation/incubation_setup_screen.dart';
import 'package:egg_incubator_app/screens/species/species_details_screen.dart';
import 'package:egg_incubator_app/widgets/species_illustration.dart';

// ══════════════════════════════════════════════
// SPECIES SCREEN
// ══════════════════════════════════════════════

class SpeciesScreen extends StatefulWidget {
  const SpeciesScreen({super.key});

  @override
  State<SpeciesScreen> createState() => _SpeciesScreenState();
}

class _SpeciesScreenState extends State<SpeciesScreen> {
  List<SpeciesData> _species = defaultSpeciesList;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    try {
      final presets = await SupabaseService().getPresets();
      if (presets.isNotEmpty && mounted) {
        setState(() {
          _species = presets.map((p) => SpeciesData.fromPreset(p)).toList();
        });
      }
    } catch (_) {
      // Browsing remains available from bundled content while offline.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Egg Species'),
        // Same as the History tab: no arrow inside the bottom-navigation
        // shell, one when the screen was pushed (e.g. "Top Species" card).
        automaticallyImplyLeading: !TabShell.isTab(context),
      ),
      // Same as History: a pushed Species screen gets the bottom bar so the
      // main sections remain reachable (issue #14).
      bottomNavigationBar: TabShell.isTab(context)
          ? null
          : MainBottomBar(
              selectedIndex: 1,
              onSelected: (index) {
                if (index == 1) return; // already showing Species
                MainNavigation.openTab(context, index);
              },
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Short, plain-language intro under the screen heading.
              const Text(
                'Choose the type of eggs you want to incubate.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ..._species.map(
                (species) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SpeciesCard(
                    name: species.name,
                    description: species.shortDescription.isEmpty
                        ? species.description
                        : species.shortDescription,
                    emoji: species.emoji,
                    species: species,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SpeciesDetailsScreen(species: species),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final SpeciesData species;
  final String name;
  final String description;
  final String emoji;
  final VoidCallback onTap;

  const _SpeciesCard({
    required this.species,
    required this.name,
    required this.description,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Illustration badge: ~64px artwork on an 84px peach circle on normal
    // phones, slightly smaller below 360px so the text column keeps room.
    // One tappable card per species: warm white surface, soft peach
    // illustration badge, ripple feedback and a screen-reader label naming
    // the species.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppShadows.card,
      ),
      child: Semantics(
        button: true,
        label: 'Select $name',
        child: Material(
          // Transparent so the white card below still shows through; the ink
          // splash then paints above it and gives visible tap feedback.
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Local bird illustration on a soft-peach circle; a touch
                      // smaller on the narrowest phones so the text column keeps
                      // room. Falls back to the emoji if an asset cannot load.
                      SpeciesIllustration(
                        species: name,
                        emoji: emoji,
                        size: 48,
                        artwork: 38,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.chevron_right,
                          size: 22,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28, color: AppColors.borderWarm),
                  Text(
                    species.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SpeciesProfileSummary(species: species),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              IncubationSetupScreen(selectedSpecies: species),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Use $name preset'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
