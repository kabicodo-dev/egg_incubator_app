import 'package:flutter/material.dart';
import 'package:egg_incubator_app/widgets/common/info_chip.dart';
import 'package:flutter/services.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/constants/incubation_notices.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/navigation/incubation_routes.dart';
import 'package:egg_incubator_app/screens/incubation/incubation_checklist_screen.dart';
import 'package:egg_incubator_app/widgets/species_illustration.dart';
import 'package:egg_incubator_app/widgets/selected_species_preset_card.dart';
import '../../models/farmer_notice.dart';
import '../../widgets/common/farmer_notice_card.dart';

// ══════════════════════════════════════════════
// INCUBATION SETUP — Step 1 & 2 (improved UX)
// ══════════════════════════════════════════════

class IncubationSetupScreen extends StatefulWidget {
  final SpeciesData? selectedSpecies;
  const IncubationSetupScreen({super.key, this.selectedSpecies});

  @override
  State<IncubationSetupScreen> createState() => _IncubationSetupScreenState();
}

class _IncubationSetupScreenState extends State<IncubationSetupScreen> {
  SpeciesData? _selectedSpecies;
  int _eggCount = SupabaseService.minBatchSize;
  int _currentStep = 1;
  List<SpeciesData> _speciesList = defaultSpeciesList;

  // Quantity state: [_eggCount] is the amount being chosen, [_customMode]
  // tracks the Custom quick choice (it reveals the typed amount), and
  // [_quantityError] holds the farmer-friendly message shown under the field
  // while a typed amount cannot be used. Quick choices and the +/− counter
  // always stay inside the SmartHatch capacity of 6 to 12 eggs.
  final TextEditingController _customEggController = TextEditingController(
    text: '${SupabaseService.minBatchSize}',
  );
  bool _customMode = false;
  String? _quantityError;

  // P6.1 - one active incubation: while a batch is incubating this screen
  // shows a blocking panel (and the route to the current incubation) instead
  // of the setup form. [_activeSession] is the raw Supabase row.
  bool _checkingActive = true;
  Map<String, dynamic>? _activeSession;
  bool _presetsFailed = false;

  @override
  void initState() {
    super.initState();
    _selectedSpecies = widget.selectedSpecies;
    if (_selectedSpecies != null) _currentStep = 2;
    _loadSpecies();
    _checkActiveBatch();
  }

  @override
  void dispose() {
    _customEggController.dispose();
    super.dispose();
  }

  /// Continue is only offered for a quantity SmartHatch can incubate.
  bool get _quantityIsValid =>
      _quantityError == null &&
      SupabaseService.eggQuantityError(_eggCount) == null;

  /// Quick choice: the minimum batch size or the maximum capacity.
  void _selectQuickChoice(int eggs) {
    setState(() {
      _eggCount = eggs;
      _customMode = false;
      _quantityError = null;
      _setCustomQuantityText('$eggs');
    });
  }

  /// Custom choice: keep the current amount and show the typed entry.
  void _selectCustomChoice() {
    setState(() {
      _customMode = true;
      _quantityError = SupabaseService.eggQuantityError(_eggCount);
    });
  }

  /// The +/− counter can only land between the minimum batch size and the
  /// maximum capacity, and stepping away from a quick choice is a custom
  /// amount.
  void _stepEggCount(int delta) {
    var next = _eggCount + delta;
    if (next < SupabaseService.minBatchSize) {
      next = SupabaseService.minBatchSize;
    }
    if (next > SupabaseService.maxCapacity) {
      next = SupabaseService.maxCapacity;
    }
    setState(() {
      _eggCount = next;
      _customMode = true;
      _setCustomQuantityText('$next');
      _quantityError = null;
    });
  }

  /// Replaces the custom quantity text without throwing the cursor back to
  /// position zero.
  ///
  /// Writing `controller.text` clears the selection, so the caret jumped to
  /// the start of the field every time the +/− buttons were tapped. This
  /// keeps the caret where the farmer left it: at the end when it was at (or
  /// selecting up to) the end of the text, otherwise at the same spot clamped
  /// inside the new text - always a valid position, even when the field is
  /// empty.
  void _setCustomQuantityText(String text) {
    final selection = _customEggController.selection;
    final oldLength = _customEggController.text.length;
    // An unset selection (-1, as after a previous programmatic write) counts
    // as "at the end of the text" too.
    final atEnd = !selection.isValid || selection.end >= oldLength;
    final offset = atEnd
        ? text.length
        : selection.end.clamp(0, text.length).toInt();
    _customEggController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  // The typed amount is the only place an unusable value (empty, 0, below the
  // minimum or above the capacity) can appear, so the message shows right
  // where the farmer fixes it.
  void _onCustomEggCountChanged(String raw) {
    final text = raw.trim();
    setState(() {
      if (text.isEmpty) {
        _eggCount = 0;
        _quantityError = 'Please enter the number of eggs.';
        return;
      }
      final parsed = int.tryParse(text);
      _eggCount = parsed ?? 0;
      _quantityError = parsed == null
          ? 'Please enter a whole number of eggs.'
          : SupabaseService.eggQuantityError(parsed);
    });
  }

  Future<void> _loadSpecies() async {
    try {
      final presets = await SupabaseService().getPresets();
      if (presets.isNotEmpty && mounted) {
        setState(() {
          _speciesList = presets.map((p) => SpeciesData.fromPreset(p)).toList();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _presetsFailed = true);
      }
    }
  }

  /// Blocks setup while a batch is incubating (P6.1).
  ///
  /// [SupabaseService.createSession] stays the authoritative guard; this
  /// only avoids offering a form the farmer cannot use. A failed lookup
  /// (e.g. offline) falls through to the form - the start button still
  /// refuses through the service.
  Future<void> _checkActiveBatch() async {
    try {
      final active = await SupabaseService().getActiveSession();
      if (mounted) {
        setState(() {
          _activeSession = active;
          _checkingActive = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _checkingActive = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // P6.1 - one active incubation: setup closes while a batch runs.
    if (_checkingActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Incubation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final active = _activeSession;
    if (active != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your batch')),
        body: _buildBlockedByActiveBatch(active),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStep == 1 ? 'Select Species' : 'Egg Quantity'),
      ),
      body: Column(
        children: [
          if (_presetsFailed)
            const Padding(
              padding: EdgeInsets.all(16),
              child: FarmerNoticeCard(
                notice: FarmerNotice(
                  title: 'Saved species settings could not be loaded',
                  message:
                      'Showing the app’s species information instead. Check your internet connection before relying on saved settings.',
                  tone: FarmerNoticeTone.warning,
                ),
              ),
            ),
          Expanded(child: _currentStep == 1 ? _buildStep1() : _buildStep2()),
        ],
      ),
    );
  }

  // ── P6.1: blocked while a batch is incubating ──

  /// Full-screen refusal shown while another batch is running: names the
  /// batch and sends the farmer to it instead of the setup form.
  Widget _buildBlockedByActiveBatch(Map<String, dynamic> active) {
    final batchId = 'Batch #${active['id']}';
    final speciesName = (active['egg_type'] as String?) ?? 'Eggs';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpeciesIllustration(species: speciesName, size: 56),
          const SizedBox(height: 20),
          const Text(
            'Review your current batch',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$batchId ($speciesName) is still open. Review it before adding a new batch.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _openCurrentIncubation(active),
              icon: const Icon(Icons.monitor_heart_outlined, size: 20),
              label: const Text(
                'View Current Incubation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  /// Opens the farmer-facing Active Incubation screen for [active], and
  /// re-checks on return so the panel clears as soon as the batch is no
  /// longer active.
  Future<void> _openCurrentIncubation(Map<String, dynamic> active) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => activeIncubationScreenFor(active)),
    );
    if (mounted) await _checkActiveBatch();
  }

  // ── Step 1: What are you hatching? ──

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(1, 3),
          const SizedBox(height: 12),
          const Text(freshEggsOnlyNotice),
          const SizedBox(height: 24),
          const Text(
            'What are you hatching?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap to select a species',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          ..._speciesList.map((species) {
            final isSelected = _selectedSpecies?.name == species.name;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSpecies = species;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFDF3EC) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE8752A)
                          : Colors.grey.shade100,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFFE8752A).withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: isSelected ? 12 : 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SpeciesIllustration(
                        species: species.name,
                        emoji: species.emoji,
                        size: 56,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              species.name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFFE8752A)
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                InfoChip(
                                  icon: Icons.calendar_today_rounded,
                                  label: '${species.incubationDays} days',
                                ),
                                InfoChip(
                                  icon: Icons.thermostat,
                                  label: species.temperature,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              species.shortDescription.isEmpty
                                  ? species.description
                                  : species.shortDescription,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFFE8752A),
                                size: 24,
                              )
                            : const Icon(
                                Icons.chevron_right,
                                color: Colors.black38,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _selectedSpecies != null
                  ? () {
                      setState(() {
                        _currentStep = 2;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: _selectedSpecies != null ? 2 : 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Step 2: How many eggs? ──

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(2, 3),
          const SizedBox(height: 12),
          const Text(freshEggsOnlyNotice),
          const SizedBox(height: 24),
          const Text(
            'How many eggs?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set the number of ${_selectedSpecies?.name.toLowerCase() ?? 'eggs'} to incubate',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),

          // Selected species summary
          if (_selectedSpecies case final selected?)
            SelectedSpeciesPresetCard(
              species: selected,
              onChange: () => setState(() => _currentStep = 1),
            ),
          const SizedBox(height: 24),

          // Quick choices: the two supported batch sizes plus Custom.
          Text(
            'Quick choices',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuantityChoice(
                  label: '${SupabaseService.minBatchSize} eggs',
                  isSelected:
                      !_customMode && _eggCount == SupabaseService.minBatchSize,
                  onTap: () => _selectQuickChoice(SupabaseService.minBatchSize),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuantityChoice(
                  label: '${SupabaseService.maxCapacity} eggs',
                  isSelected:
                      !_customMode && _eggCount == SupabaseService.maxCapacity,
                  onTap: () => _selectQuickChoice(SupabaseService.maxCapacity),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuantityChoice(
                  label: 'Custom',
                  isSelected: _customMode,
                  onTap: _selectCustomChoice,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Egg counter with +/− buttons, held inside the capacity.
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CounterButton(
                    icon: Icons.remove,
                    onTap: _eggCount > SupabaseService.minBatchSize
                        ? () => _stepEggCount(-1)
                        : null,
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      // An emptied custom field shows a dash instead of a
                      // zero, so "0 eggs" can never appear on this screen.
                      _eggCount > 0 ? '$_eggCount' : '\u2013',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _CounterButton(
                    icon: Icons.add,
                    onTap: _eggCount < SupabaseService.maxCapacity
                        ? () => _stepEggCount(1)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'eggs',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ),

          // Custom amount: only shown for the Custom quick choice.
          if (_customMode) _buildCustomQuantity(),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _quantityIsValid
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IncubationChecklistScreen(
                            species: _selectedSpecies!,
                            eggCount: _eggCount,
                            onChangeSpecies: () {
                              Navigator.of(context).pop();
                              if (mounted) setState(() => _currentStep = 1);
                            },
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: _quantityIsValid ? 2 : 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Custom amount entry with the farmer-friendly message shown underneath.
  Widget _buildCustomQuantity() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _customEggController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onCustomEggCountChanged,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Custom quantity',
              labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              hintText:
                  'Type ${SupabaseService.minBatchSize} to ${SupabaseService.maxCapacity}',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              suffixText: 'eggs',
              suffixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE8752A),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Farmer-friendly validation message for an unusable amount.
          if (_quantityError != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 17,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _quantityError!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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

// ── Large counter +/- button ──

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFFE8752A).withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 28,
          color: onTap != null ? const Color(0xFFE8752A) : Colors.grey.shade400,
        ),
      ),
    );
  }
}

// ── Quick quantity choice (6 eggs / 12 eggs / Custom) ──

class _QuantityChoice extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuantityChoice({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF3EC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFE8752A) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primaryDarkPressed : Colors.black87,
          ),
        ),
      ),
    );
  }
}
