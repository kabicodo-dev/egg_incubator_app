import 'package:flutter/material.dart';
import '../models/confirmed_incubation_time.dart';
import '../models/egg_turning_progress.dart';
import '../models/farmer_notice.dart';
import '../models/species_data.dart';
import '../theme/app_theme.dart';
import 'incubator_readings.dart';
import 'species_illustration.dart';
import 'reading_dial_tile.dart';

/// One read-only batch card. All values are explicit presentation inputs.
/// Missing evidence stays unknown; it never enables commands or completes a batch.
class CurrentBatchOverview extends StatelessWidget {
  const CurrentBatchOverview({
    super.key,
    required this.species,
    required this.batchId,
    required this.eggCount,
    required this.reading,
    this.time,
    this.turning,
  });
  final SpeciesData species;
  final String batchId;
  final int eggCount;
  final ActualReadingSnapshot reading;
  final ConfirmedIncubationTime? time;
  final EggTurningProgress? turning;

  bool get hasTemperature =>
      reading.canShowReportedValues && reading.temperature?.isFinite == true;
  bool get hasHumidity =>
      reading.canShowReportedValues && reading.humidity?.isFinite == true;

  List<FarmerNotice> get notices {
    if (reading.state == ActualReadingState.disconnected) {
      return const [
        FarmerNotice(
          title: 'Incubator disconnected',
          message:
              'The app has lost its link to the incubator. Check your phone’s Bluetooth connection before relying on monitoring. The incubator may still be running.',
          tone: FarmerNoticeTone.warning,
        ),
      ];
    }
    if (!hasTemperature &&
        !hasHumidity &&
        time?.day == null &&
        turning?.hasValidCounts != true) {
      return const [
        FarmerNotice(
          title: 'No incubator updates',
          message:
              'Readings, the day count and recent turns are unavailable. Check the incubator and Bluetooth connection.',
          tone: FarmerNoticeTone.warning,
        ),
      ];
    }
    return [
      if (!hasTemperature || !hasHumidity)
        FarmerNotice(
          title: reading.state == ActualReadingState.disconnected
              ? 'Incubator disconnected'
              : reading.state == ActualReadingState.stale
              ? 'Readings are out of date'
              : 'Sensor readings unavailable',
          message: reading.state == ActualReadingState.disconnected
              ? 'Check your phone’s Bluetooth connection. The incubator may still be running.'
              : 'The app cannot confirm current sensor readings. Check the incubator and connection.',
          tone: FarmerNoticeTone.warning,
        ),
      if (time?.day == null)
        FarmerNotice(
          title: time?.startUtc == null
              ? 'Start time missing'
              : 'Day count unavailable',
          message: time?.startUtc == null
              ? 'The incubation day needs the original start time. Check when this batch was started.'
              : 'Elapsed time is not confirmed. Check the connection for a time update.',
          tone: FarmerNoticeTone.warning,
        ),
      if (turning?.hasValidCounts != true)
        const FarmerNotice(
          title: 'Egg-turning update missing',
          message:
              'The app cannot confirm recent turns. Check the egg tray and connection.',
          tone: FarmerNoticeTone.warning,
        ),
    ];
  }

  String get dayText => time?.day == null
      ? '—/${species.incubationDays > 0 ? species.incubationDays : '—'}'
      : '${time!.day}/${species.incubationDays > 0 ? species.incubationDays : '—'}';

  DateTime? get expectedHatchUtc =>
      time?.startUtc == null || species.incubationDays <= 0
      ? null
      : time!.startUtc!.add(Duration(days: species.incubationDays));

  static String formatHatch(DateTime utc) {
    final date = utc.add(const Duration(hours: 8));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    return '${date.day} ${months[date.month - 1]} ${date.year} · $hour:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final hatch = expectedHatchUtc;
    final elapsed = time?.elapsed;
    final progress = elapsed == null || species.incubationDays <= 0
        ? null
        : (elapsed.inSeconds / Duration(days: species.incubationDays).inSeconds)
              .clamp(0.0, 1.0);
    return Container(
      key: const ValueKey('current-batch-overview'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              key: const ValueKey('centered-batch-header'),
              children: [
                SpeciesIllustration(
                  species: species.name,
                  emoji: species.emoji,
                  size: 52,
                ),
                const SizedBox(height: 8),
                Text(
                  species.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  batchId,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$eggCount eggs set',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32, color: AppColors.borderWarm),
          LayoutBuilder(
            builder: (context, constraints) {
              final day = _metric(
                Icons.calendar_today_outlined,
                'Incubation day',
                dayText,
                'confirmed-incubation-day',
                footer: progress == null
                    ? null
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          color: AppColors.primaryDark,
                          backgroundColor: AppColors.peach,
                        ),
                      ),
              );
              final turns = _metric(
                Icons.sync,
                'Egg turning',
                turning?.countLabel ?? '—',
                'turning-progress',
                subtitle: [
                  if (turning?.hasValidCounts == true) 'Turns today',
                  ?turning?.intervalLabel,
                  ?turning?.nextTurnLabel,
                ].join(' · '),
              );
              return constraints.maxWidth < 280 ||
                      MediaQuery.textScalerOf(context).scale(14) > 21
                  ? Column(children: [day, const SizedBox(height: 12), turns])
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: day),
                          const SizedBox(width: 12),
                          Expanded(child: turns),
                        ],
                      ),
                    );
            },
          ),
          const SizedBox(height: 20),
          Semantics(
            liveRegion: true,
            child: Row(
              key: const ValueKey('overview-reading-freshness'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  reading.canShowReportedValues
                      ? Icons.update
                      : Icons.warning_amber_rounded,
                  color: reading.canShowReportedValues
                      ? AppColors.textSecondary
                      : AppColors.warning,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reading.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: reading.canShowReportedValues
                          ? AppColors.textSecondary
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              Widget temperature() => ReadingDialTile(
                label: 'Temperature',
                formattedValue: reading.valueText(reading.temperature, '°C'),
                valueKey: 'actual-temperature',
                value: hasTemperature ? reading.temperature : null,
                scaleMaximum: 50,
                scaleUnit: '°C',
              );
              Widget humidity() => ReadingDialTile(
                label: 'Humidity',
                formattedValue: reading.valueText(reading.humidity, '%'),
                valueKey: 'actual-humidity',
                value: hasHumidity ? reading.humidity : null,
                scaleMaximum: 100,
                scaleUnit: '% RH',
              );
              return constraints.maxWidth < 280 ||
                      MediaQuery.textScalerOf(context).scale(14) > 21
                  ? Column(
                      children: [
                        temperature(),
                        const SizedBox(height: 8),
                        humidity(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: temperature()),
                        const SizedBox(width: 12),
                        Expanded(child: humidity()),
                      ],
                    );
            },
          ),
          const Divider(height: 32, color: AppColors.borderWarm),
          const Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 18,
                color: AppColors.primaryDark,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Expected hatch',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hatch == null ? '—' : formatHatch(hatch),
            key: const ValueKey('expected-hatch'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          if (hatch != null)
            const Text(
              'Estimated · Philippine time',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _metric(
    IconData icon,
    String label,
    String value,
    String valueKey, {
    String? subtitle,
    Widget? footer,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          key: ValueKey(valueKey),
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
        ),
        if (subtitle?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        if (footer != null) ...[const SizedBox(height: 12), footer],
      ],
    ),
  );
}
