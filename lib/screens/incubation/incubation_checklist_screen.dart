import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/constants/incubation_notices.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/widgets/selected_species_preset_card.dart';
import 'package:egg_incubator_app/models/farmer_notice.dart';
import 'package:egg_incubator_app/widgets/common/farmer_notice_card.dart';

// ══════════════════════════════════════════════
// INCUBATION CHECKLIST — Step 3 (improved UX)
// ══════════════════════════════════════════════

class IncubationChecklistScreen extends StatefulWidget {
  final SpeciesData species;
  final int eggCount;
  final VoidCallback? onChangeSpecies;
  const IncubationChecklistScreen({
    super.key,
    required this.species,
    required this.eggCount,
    this.onChangeSpecies,
  });

  @override
  State<IncubationChecklistScreen> createState() =>
      _IncubationChecklistScreenState();
}

class _IncubationChecklistScreenState extends State<IncubationChecklistScreen> {
  final List<String> _checklistItems = [
    'Incubator is clean',
    'Temperature is stable',
    'Water level is checked',
    'Eggs are properly positioned',
  ];
  final List<bool> _checked = [false, false, false, false];

  bool get _allChecked => _checked.every((c) => c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incubation Checklist')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FarmerNoticeCard(
                  notice: FarmerNotice(
                    title: 'Incubation cannot start from this app yet',
                    message:
                        'This version cannot send a Start command to the incubator. You can review your setup, but checking these items will not start it. Do not restart an incubation that is already running.',
                    tone: FarmerNoticeTone.warning,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStepIndicator(3, 3),
                const SizedBox(height: 8),
                const Text(
                  'Step 3 of 3 · Review & check',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Text(freshEggsOnlyNotice),
                const SizedBox(height: 16),
                SelectedSpeciesPresetCard(
                  species: widget.species,
                  subtitle:
                      '${widget.eggCount} eggs \u2022 ${widget.species.incubationDays} days',
                  onChange: widget.onChangeSpecies,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.fact_check_outlined,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Check the incubator',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_allChecked)
                      const Icon(Icons.task_alt, color: AppColors.success),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _allChecked
                      ? 'Your checks are complete.'
                      : 'Tick each item after checking it yourself.',
                  style: TextStyle(
                    fontSize: 13,
                    color: _allChecked
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.borderWarm),
                  ),
                  child: Column(
                    children: List.generate(
                      _checklistItems.length,
                      (index) => Column(
                        children: [
                          if (index > 0)
                            const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: AppColors.borderWarm,
                            ),
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: CheckboxListTile(
                              value: _checked[index],
                              onChanged: (val) {
                                setState(() {
                                  _checked[index] = val ?? false;
                                });
                              },
                              title: Text(
                                _checklistItems[index],
                                style: const TextStyle(fontSize: 15),
                              ),
                              activeColor: AppColors.success,
                              controlAffinity: ListTileControlAffinity.leading,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'These are your manual checks, not an automatic hardware test.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    // Fail closed until a real, authorized controller lifecycle
                    // adapter exists. A serial/simulator connection or cloud row
                    // is not evidence that a physical Start can be admitted.
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.borderWarm,
                      disabledForegroundColor: AppColors.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Incubation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int current, int total) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFE8752A) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
