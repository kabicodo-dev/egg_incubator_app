import 'package:flutter/material.dart';
import 'package:egg_incubator_app/controllers/arduino_controller.dart';
import 'package:egg_incubator_app/dialogs/finish_batch_dialog.dart';
import 'package:egg_incubator_app/models/confirmed_incubation_time.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/navigation/main_navigation.dart';
import 'package:egg_incubator_app/screens/history/history_screen.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/utils/actual_readings.dart';
import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:egg_incubator_app/models/egg_turning_progress.dart';
import 'package:egg_incubator_app/models/farmer_notice.dart';
import 'package:egg_incubator_app/widgets/common/farmer_notice_card.dart';
import 'package:egg_incubator_app/widgets/current_batch_overview.dart';

/// Farmer monitoring and manual record entry only. No actuator/serial controls.
class ActiveIncubationScreen extends StatefulWidget {
  const ActiveIncubationScreen({
    super.key,
    required this.species,
    required this.eggCount,
    required this.batchId,
    required this.sessionId,
    required this.startDate,
    this.confirmedTime,
    this.readingSnapshot,
    this.turningProgress,
    this.notices = const [],
  });

  final SpeciesData species;
  final int eggCount;
  final String batchId;
  final int sessionId;
  final DateTime? startDate;
  final ConfirmedIncubationTime? confirmedTime;
  // Explicit UI snapshots for an eventual approved adapter / isolated fixtures.
  // No legacy receipt-time or controller fallback is promoted to these inputs.
  final ActualReadingSnapshot? readingSnapshot;
  final EggTurningProgress? turningProgress;
  final List<FarmerNotice> notices;

  @override
  State<ActiveIncubationScreen> createState() => _ActiveIncubationScreenState();
}

class _ActiveIncubationScreenState extends State<ActiveIncubationScreen> {
  final ArduinoController _arduino = ArduinoController.instance;
  Map<String, dynamic>? _session;
  bool _sessionLoading = true;
  bool _sessionMissing = false;

  @override
  void initState() {
    super.initState();
    _arduino.addListener(_onArduinoChanged);
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final row = await SupabaseService().getSessionById(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _session = row;
        _sessionMissing = row == null;
        _sessionLoading = false;
      });
    } catch (_) {
      // Retain the supplied record for viewing offline. A missing read never
      // invents a row; result entry remains disabled without a loaded session.
      if (mounted) setState(() => _sessionLoading = false);
    }
  }

  bool get _isActive =>
      !_sessionMissing &&
      (_session == null || '${_session!['status']}'.toLowerCase() == 'active');

  Future<void> _confirmFinish() async {
    final session = _session;
    if (session == null) return;
    final done = await showFinishBatchDialog(context, session: session);
    if (done && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigation(
            notice: FarmerNotice(
              title: 'Hatch results saved',
              message:
                  '${widget.batchId} completed. Hatch results saved in History.',
              tone: FarmerNoticeTone.success,
            ),
          ),
        ),
        (route) => false,
      );
    }
  }

  void _goHome() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const MainNavigation()),
    (route) => false,
  );

  void _onArduinoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _arduino.removeListener(_onArduinoChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Current Incubation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_isActive) {
      final completed = _session?['status'] == 'Completed';
      return Scaffold(
        appBar: AppBar(title: const Text('Batch record')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                completed
                    ? Icons.check_circle_outline
                    : _sessionMissing
                    ? Icons.error_outline
                    : Icons.folder_outlined,
                size: 48,
                color: completed
                    ? AppColors.success
                    : _sessionMissing
                    ? AppColors.danger
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                _sessionMissing
                    ? 'Batch record unavailable'
                    : 'This batch record is closed',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _sessionMissing
                    ? 'We couldn’t find ${widget.batchId}. Check History.'
                    : 'View the saved hatch results in History.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
                child: const Text('View History'),
              ),
              TextButton(
                onPressed: _goHome,
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final species = widget.species;
    final speciesName = _session?['egg_type'] as String? ?? species.name;
    final eggs = _session?['egg_quantity'] as int? ?? widget.eggCount;
    final reading = widget.readingSnapshot ?? actualReadings(_arduino);
    final overview = CurrentBatchOverview(
      species: speciesName == species.name
          ? species
          : speciesDataForName(speciesName),
      batchId: widget.batchId,
      eggCount: eggs,
      reading: reading,
      time: widget.confirmedTime,
      turning: widget.turningProgress,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Current Incubation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                overview,
                for (final notice in [
                  ...overview.notices,
                  ...widget.notices,
                ]) ...[
                  const SizedBox(height: 16),
                  FarmerNoticeCard(notice: notice),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _session == null ? null : _confirmFinish,
                    icon: const Icon(Icons.assignment_turned_in_outlined),
                    label: const Text('Finish Batch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(48, 54),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Save the hatch count and close this batch record. This does not switch off the incubator.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _goHome,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.borderWarm),
                      minimumSize: const Size(48, 50),
                    ),
                    child: const Text('Back to Dashboard'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    minimumSize: const Size(48, 48),
                  ),
                  child: const Text('View History'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
