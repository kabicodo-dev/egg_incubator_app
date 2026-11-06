import 'package:flutter/material.dart';
import '../../models/farmer_notice.dart';
import '../../widgets/common/farmer_notice_card.dart';
import 'package:egg_incubator_app/navigation/main_navigation.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/controllers/arduino_controller.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/controllers/interruption_inspection_controller.dart';
import 'package:egg_incubator_app/widgets/interruption_inspection_warning.dart';
import 'package:egg_incubator_app/models/app_derived_schedule.dart';
import 'package:egg_incubator_app/widgets/app_derived_schedule.dart';
import 'package:egg_incubator_app/models/batch_data.dart';
import 'package:egg_incubator_app/navigation/incubation_routes.dart';
import 'package:egg_incubator_app/screens/history/batch_details_screen.dart';
import 'package:egg_incubator_app/screens/history/history_screen.dart';
import 'package:egg_incubator_app/screens/incubation/incubation_setup_screen.dart';
import 'package:egg_incubator_app/screens/profile/profile_screen.dart';
import 'package:egg_incubator_app/screens/species/species_screen.dart';
import 'package:egg_incubator_app/widgets/common/section_label.dart';
import 'package:egg_incubator_app/widgets/common/status_badge.dart';
import 'package:egg_incubator_app/widgets/hardware/live_incubator_status_card.dart';
import 'package:egg_incubator_app/widgets/species_illustration.dart';

// ══════════════════════════════════════════════
// HOME SCREEN — Improved hierarchy
// ══════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.inspectionController, this.notice});
  final FarmerNotice? notice;

  final InterruptionInspectionController? inspectionController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final InterruptionInspectionController _inspectionController;
  List<BatchData> _batches = [];
  bool _loading = true;
  bool _tabActive = true;
  FarmerNotice? _loadError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TabShell.isActive(context);
    if (active && !_tabActive) _loadData();
    _tabActive = active;
  }

  final ArduinoController _arduino = ArduinoController.instance;

  @override
  void initState() {
    super.initState();
    _inspectionController =
        widget.inspectionController ?? InterruptionInspectionController();
    _inspectionController.refresh();
    _arduino.addListener(_onArduinoChanged);
    _loadData();
  }

  void _onArduinoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _arduino.removeListener(_onArduinoChanged);
    if (widget.inspectionController == null) _inspectionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final sessions = await SupabaseService().getSessions();
      if (mounted) {
        setState(() {
          _batches = sessions.map((s) => BatchData.fromSession(s)).toList();
          _loading = false;
          _loadError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = const FarmerNotice(
            title: 'Batch records could not be loaded',
            message:
                'The app could not retrieve your saved batches. Check your internet connection and reopen Home. Incubator operation is not confirmed by this screen.',
            tone: FarmerNoticeTone.error,
          );
        });
      }
    }
  }

  /// Home's primary full-width pill in the readable dark orange with white
  /// AA-contrast labels. The label is flexible, so the button can never
  /// overflow on narrow screens - it shortens with an ellipsis instead.
  Widget _primaryPill({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          minimumSize: const Size(48, 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          foregroundColor: Colors.white,
          shadowColor: AppColors.primaryDark.withValues(alpha: 0.35),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalBatches = _batches.length;
    final completedBatches = _batches
        .where((b) => b.status == 'Completed')
        .toList();
    final bestRate = completedBatches.isNotEmpty
        ? completedBatches
              .map((b) => b.eggsTotal > 0 ? b.eggsHatched / b.eggsTotal : 0.0)
              .reduce((a, b) => a > b ? a : b)
        : 0.0;
    final topSpecies = _batches.isNotEmpty
        ? (() {
            final counts = <String, int>{};
            for (final b in _batches) {
              counts[b.species] = (counts[b.species] ?? 0) + 1;
            }
            return (counts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .first
                .key;
          })()
        : '-';

    // P6.2 - at most ONE batch is ever Active (enforced in the service and
    // by the database index), so the first Active row IS the current batch.
    final activeBatch = _batches.cast<BatchData?>().firstWhere(
      (b) => b!.status == 'Active',
      orElse: () => null,
    );
    // "Last Batch" shows only the most recently COMPLETED batch - an
    // incubating batch is never presented as a finished result.
    final lastCompleted = completedBatches.isNotEmpty
        ? completedBatches.first
        : null;

    return SafeArea(
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
            _HomeHeader(
              onProfileTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            if (widget.notice != null) ...[
              FarmerNoticeCard(notice: widget.notice!),
              const SizedBox(height: 20),
            ],
            if (_loadError != null) ...[
              FarmerNoticeCard(notice: _loadError!),
              const SizedBox(height: 20),
            ],

            // Primary action: a full-width pill in the readable dark orange
            // with white AA-contrast labels. The label is flexible, so the
            // button can never overflow on narrow screens - it shortens with
            // an ellipsis instead.
            //
            // P6.2 - one active batch: while a batch is incubating, Home
            // offers only "View Active Incubation"; "Start New Incubation"
            // appears solely when no batch is running.
            if (activeBatch != null) ...[
              const SectionLabel(text: 'CURRENT INCUBATION'),
              const SizedBox(height: 10),
              _CurrentIncubationCard(
                batch: activeBatch,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          activeIncubationScreenForBatch(activeBatch),
                    ),
                  );
                  if (mounted) _loadData();
                },
              ),
              const SizedBox(height: 16),
              _primaryPill(
                icon: Icons.visibility_outlined,
                label: 'View Active Incubation',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          activeIncubationScreenForBatch(activeBatch),
                    ),
                  );
                  if (mounted) _loadData();
                },
              ),
            ] else
              _primaryPill(
                icon: Icons.add,
                label: 'Start a new incubation',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncubationSetupScreen(),
                    ),
                  );
                  // Returning from setup/starting a batch refreshes Home so
                  // the Current Incubation card appears immediately.
                  if (mounted) _loadData();
                },
              ),
            const SizedBox(height: 24),

            InterruptionInspectionWarning(controller: _inspectionController),
            const SizedBox(height: 16),
            // Live incubator status (visible on the dashboard, no navigation needed)
            LiveIncubatorStatusCard(controller: _arduino),
            const SizedBox(height: 24),

            const SectionLabel(text: 'OVERVIEW'),
            const SizedBox(height: 10),
            _OverviewCards(
              totalBatches: '$totalBatches',
              bestSuccess: '${(bestRate * 100).round()}%',
              topSpecies: topSpecies,
              onTotalBatchesTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
              onBestSuccessTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
              onTopSpeciesTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SpeciesScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            // P6.2 - only a COMPLETED batch is shown as a finished result;
            // active batches live in the Current Incubation card above.
            const SectionLabel(text: 'LAST COMPLETED BATCH'),
            const SizedBox(height: 10),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (lastCompleted != null)
              _LastBatchCard(
                batch: lastCompleted,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BatchDetailsScreen(batch: lastCompleted),
                    ),
                  );
                  if (mounted) _loadData();
                },
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.primaryDark.withValues(alpha: 0.12),
                  ),
                ),
                child: Center(
                  child: Text(
                    _batches.isEmpty
                        ? 'No batches yet. Start your first incubation!'
                        : 'No completed batches yet. Your hatch results '
                              'will appear here.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// The farmer's single source of truth for the batch incubating right now
/// (P6.2): real batch number, species, egg quantity, actual start date, the
/// saved date retained as metadata, not confirmed elapsed-time evidence.
/// The whole card opens
/// the Active Incubation screen.
class _CurrentIncubationCard extends StatelessWidget {
  const _CurrentIncubationCard({required this.batch, required this.onTap});

  final BatchData batch;
  final VoidCallback onTap;

  static String _formatDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasSchedule =
        AppDerivedSchedule.fromStoredStart(
          batch.appStartDate,
          DateTime.now(),
        ).day !=
        null;
    final start = hasSchedule ? DateTime.tryParse(batch.appStartDate!) : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppShadows.card,
      ),
      child: Semantics(
        button: true,
        label: 'Open current incubation, ${batch.batchNumber}',
        child: Material(
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
                      SpeciesIllustration(species: batch.species, size: 48),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${batch.batchNumber} \u00B7 ${batch.species}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${batch.eggsTotal} eggs \u00B7 '
                              '${start == null ? 'Start date unavailable' : 'App start date: ${_formatDate(start)}'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const StatusBadge(
                    label: 'Open batch',
                    color: AppColors.warning,
                    icon: Icons.play_circle_outline,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // No approved original-Start mapping exists for BatchData.
                  AppSchedule(storedStart: batch.appStartDate),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  const _HomeHeader({required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dateStr = '${days[now.weekday - 1]}, ${months[now.month]} ${now.day}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Brand mark: the SmartHatch logo on a soft peach badge
                  // (matches the onboarding branding; egg icon as fallback).
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.peach,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Semantics(
                        image: true,
                        label: 'SmartHatch logo',
                        excludeSemantics: true,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.egg_outlined,
                                      size: 20,
                                      color: AppColors.primaryDark,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'SmartHatch',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Profile shortcut - a 48px target, labelled for screen readers.
        Semantics(
          button: true,
          label: 'Open profile',
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onProfileTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryDark.withValues(alpha: 0.16),
                  ),
                  boxShadow: AppShadows.card,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewCards extends StatelessWidget {
  final String totalBatches;
  final String bestSuccess;
  final String topSpecies;
  final VoidCallback onTotalBatchesTap;
  final VoidCallback onBestSuccessTap;
  final VoidCallback onTopSpeciesTap;

  const _OverviewCards({
    required this.totalBatches,
    required this.bestSuccess,
    required this.topSpecies,
    required this.onTotalBatchesTap,
    required this.onBestSuccessTap,
    required this.onTopSpeciesTap,
  });

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight + stretch gives the three cards one shared height
    // (tidy aligned bottoms) without assuming a fixed height - stretch alone
    // is invalid inside the scroll view's unbounded height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTotalBatchesTap,
              child: _OverviewCard(
                value: totalBatches,
                label: 'TOTAL BATCHES',
                supportingText: 'completed',
                icon: Icons.inventory_2_outlined,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: GestureDetector(
              onTap: onBestSuccessTap,
              child: _OverviewCard(
                value: bestSuccess,
                label: 'BEST HATCH\nSUCCESS',
                supportingText: 'batch success',
                icon: Icons.emoji_events_outlined,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: GestureDetector(
              onTap: onTopSpeciesTap,
              child: _OverviewCard(
                value: topSpecies,
                label: 'TOP SPECIES',
                supportingText: '',
                icon: Icons.egg_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String value;
  final String label;
  final String supportingText;
  final IconData icon;

  const _OverviewCard({
    required this.value,
    required this.label,
    required this.supportingText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.10),
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warm icon badge keeps the accent friendly and on-brand.
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.peach,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(height: 12),
          // Scales long values (e.g. a species name) down instead of clipping
          // them on narrow screens.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
              height: 1.3,
            ),
          ),
          if (supportingText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              supportingText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LastBatchCard extends StatelessWidget {
  final BatchData batch;

  /// Opens the full details of this batch. The whole card is tappable,
  /// including the "View Details" footer.
  final VoidCallback onTap;

  const _LastBatchCard({required this.batch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hatchRate = batch.eggsTotal > 0
        ? batch.eggsHatched / batch.eggsTotal
        : 0.0;
    final percentage = '${(hatchRate * 100).round()}%';

    return Container(
      decoration: BoxDecoration(
        // Subtle cream highlight + warm hairline: noticeable, but clearly a
        // summary card - not an "active/incubating" status.
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.14),
        ),
        boxShadow: AppShadows.card,
      ),
      // The whole card is one navigation target: a farmer can tap anywhere -
      // including the "View Details" footer - to open the batch details.
      child: Semantics(
        button: true,
        label: 'View details for ${batch.batchNumber}',
        child: Material(
          // Transparent so the cream card below still shows through; the ink
          // splash then paints above it and gives visible tap feedback.
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Batch's species illustration; unknown species keep a
                      // generic egg mark in the same peach circle.
                      SpeciesIllustration(species: batch.species, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batch.batchNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${batch.species.toUpperCase()} \u2022 ${batch.startDate}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          // Hatch percentage only - green here is a result
                          // figure, not a claim that the batch is running.
                          color: AppColors.success.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadius.badge),
                        ),
                        child: Text(
                          percentage,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: const Color(0x14000000)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RESULT',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${batch.eggsHatched}/${batch.eggsTotal} hatched',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0x1F000000),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVG TEMP',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              batch.temperature,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Navigation affordance, styled like the History card's
                  // orange "View details" link with its chevron.
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                    ],
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
