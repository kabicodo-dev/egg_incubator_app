import 'package:flutter/material.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:egg_incubator_app/dialogs/finish_batch_dialog.dart';
import 'package:egg_incubator_app/models/batch_data.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/navigation/incubation_routes.dart';
import 'package:egg_incubator_app/utils/hatchability.dart';
import 'package:egg_incubator_app/widgets/common/detail_rows.dart';
import 'package:egg_incubator_app/widgets/common/section_label.dart';
import 'package:egg_incubator_app/widgets/species_illustration.dart';
import '../../models/farmer_notice.dart';
import '../../widgets/common/farmer_notice_card.dart';

// ══════════════════════════════════════════════
// BATCH DETAILS SCREEN
// ══════════════════════════════════════════════

class BatchDetailsScreen extends StatefulWidget {
  final BatchData batch;
  const BatchDetailsScreen({super.key, required this.batch});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  Map<String, dynamic>? _reading;
  SpeciesData? _preset;

  @override
  void initState() {
    super.initState();
    _loadLiveData();
  }

  /// Loads the latest sensor reading and the preset for this batch's species.
  /// Every step degrades gracefully so the status cards always render.
  Future<void> _loadLiveData() async {
    // A completed record is historical: do not query today's sensors or presets
    // and present them as measurements/settings from this finished batch.
    if (_isCompleted) return;
    Map<String, dynamic>? reading;
    SpeciesData? preset;

    try {
      reading = await SupabaseService().getLatestReading();
    } catch (_) {
      reading = null;
    }

    try {
      final presets = await SupabaseService().getPresets();
      for (final p in presets) {
        if (p['egg_type'] == widget.batch.species) {
          preset = SpeciesData.fromPreset(p);
          break;
        }
      }
    } catch (_) {
      preset = null;
    }

    if (mounted) {
      setState(() {
        _reading = reading;
        _preset = preset;
      });
    }
  }

  SpeciesData get _species =>
      _preset ??
      defaultSpeciesList.firstWhere(
        (s) => s.name == widget.batch.species,
        orElse: () => speciesDataForName(widget.batch.species),
      );

  bool get _isCompleted => widget.batch.status.toLowerCase() == 'completed';

  /// The stored-session view of this batch: enough for the shared finish
  /// flow and the Active Incubation screen, assembled from what History
  /// already loaded.
  Map<String, dynamic> get _sessionRow => {
    'id': widget.batch.id,
    'egg_type': widget.batch.species,
    'start_date': widget.batch.startDate,
    'egg_quantity': widget.batch.eggsTotal,
    'status': widget.batch.status,
    'end_date': widget.batch.endDate,
    'eggs_hatched': widget.batch.eggsHatched,
  };

  /// The SAME validated completion flow as the Active Incubation screen
  /// (P6.4). On success the dialog performed the database update; popping
  /// back to History reloads it so the batch shows as Completed.
  Future<void> _finishFromDetails() async {
    final done = await showFinishBatchDialog(context, session: _sessionRow);
    if (done && mounted) Navigator.pop(context, true);
  }

  double? _liveValue(List<String> keys) {
    final reading = _reading;
    if (reading == null) return null;
    for (final key in keys) {
      final value = reading[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  double? get _liveTemperature => _liveValue(['temperature', 'temp']);

  double? get _liveHumidity => _liveValue(['humidity', 'relative_humidity']);

  // The current API returns a global latest row, not authenticated, batch-bound
  // measurement-time evidence. Do not promote it (or a target) to Actual.
  ActualReadingSnapshot get _batchReading => ActualReadingSnapshot(
    state: _reading == null
        ? ActualReadingState.unavailable
        : ActualReadingState.unknown,
    temperature: _liveTemperature,
    humidity: _liveHumidity,
  );

  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;
    final speciesData = _species;
    final reading = _batchReading;

    final String statusText;
    final String statusHint;
    final Color statusColor;
    final IconData statusIcon;
    if (_isCompleted) {
      statusText = 'Completed';
      statusHint =
          'Hatch results saved. This does not switch off the incubator.';
      statusColor = const Color(0xFF4CAF50);
      statusIcon = Icons.check_circle;
    } else {
      statusText = 'Open';
      statusHint = 'The app cannot confirm whether the incubator is running.';
      statusColor = Colors.grey.shade500;
      statusIcon = Icons.pause_circle_outline;
    }

    return Scaffold(
      appBar: AppBar(title: Text(batch.batchNumber)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              // Quail batch → quail illustration, etc.; species presets
              // without a preset (e.g. 'Goose') resolve to the same
              // fallback species the emoji path used before.
              child: SpeciesIllustration(
                species: speciesData.name,
                emoji: speciesData.emoji,
                size: 80,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                batch.batchNumber,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${batch.species} \u2022 ${batch.status}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 24),

            if (_isCompleted) ...[
              const FarmerNoticeCard(
                notice: FarmerNotice(
                  title: 'Completed',
                  message:
                      'This batch record is closed. Review its saved hatch results and dates below.',
                  tone: FarmerNoticeTone.success,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── ACTIVE BATCH ACTIONS (P6.4) ──
            // An incubating batch is opened or finished right here, through
            // the exact same validated flow as the Current Incubation
            // screen. A completed batch offers neither - results never
            // revert to incubating.
            if (!_isCompleted) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => activeIncubationScreenFor(_sessionRow),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  label: const Text(
                    'View Current Incubation',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _finishFromDetails,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'Finish Batch',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: BorderSide(color: AppColors.primaryDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  DetailRow(label: 'Species', value: batch.species),
                  const SizedBox(height: 12),
                  DetailRow(label: 'Start Date', value: batch.startDate),
                  const SizedBox(height: 12),
                  DetailRow(
                    label: 'Completed Date',
                    value: batch.endDate.isEmpty
                        ? 'Unavailable'
                        : batch.endDate,
                  ),
                  const SizedBox(height: 12),
                  DetailRow(
                    label: 'Eggs set',
                    value: batch.eggsTotal > 0
                        ? '${batch.eggsTotal}'
                        : 'Unavailable',
                  ),
                  // Hatch results only exist once the farmer finishes the
                  // batch - an incubating batch shows no fabricated counts.
                  if (_isCompleted) ...[
                    const SizedBox(height: 12),
                    DetailRow(
                      label: 'Hatched',
                      value: batch.hasRecordedHatchCount
                          ? '${batch.eggsHatched}'
                          : 'Unavailable',
                    ),
                    const SizedBox(height: 12),
                    DetailRow(
                      label: 'Hatchability',
                      value: historicalHatchability(
                        batch.eggsTotal,
                        batch.eggsHatched,
                        batch.hasRecordedHatchCount,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  DetailRow(
                    label: 'Saved temperature setting',
                    value: batch.temperature,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── TEMPERATURE / HUMIDITY / PROGRESS / STATUS CARDS ──
            if (!_isCompleted) ...[
              const SectionLabel(text: 'BATCH STATUS'),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _BatchStatCard(
                        icon: Icons.thermostat,
                        color: const Color(0xFFE8752A),
                        label: 'Temperature',
                        value: reading.valueText(reading.temperature, '°C'),
                        subtitle: 'No verified reading for this batch',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BatchStatCard(
                        icon: Icons.water_drop_outlined,
                        color: const Color(0xFF2196F3),
                        label: 'Humidity',
                        value: reading.valueText(reading.humidity, '%'),
                        subtitle: 'No verified reading for this batch',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FarmerNoticeCard(
                notice: FarmerNotice(
                  title: reading.label,
                  message: reading.message,
                  tone: FarmerNoticeTone.warning,
                ),
              ),
              const Text('Saved settings are not sensor readings.'),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _BatchStatCard(
                        icon: Icons.timelapse_outlined,
                        color: const Color(0xFF9C27B0),
                        label: 'Incubation Progress',
                        value: 'Day count unavailable',
                        subtitle: 'Start time not confirmed',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BatchStatCard(
                        icon: statusIcon,
                        color: statusColor,
                        label: 'Batch record',
                        value: statusText,
                        subtitle: statusHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDarkPressed,
                  side: const BorderSide(color: Color(0xFFE8752A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back',
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

class _BatchStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String subtitle;

  const _BatchStatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
