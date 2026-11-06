import 'package:flutter/material.dart';
import '../models/farmer_notice.dart';
import 'common/farmer_notice_card.dart';

/// Presentation state only; receipt freshness is not measurement-time proof.
enum ActualReadingState {
  recentReceipt,
  fresh,
  stale,
  unknown,
  unavailable,
  disconnected,
}

/// Internal UI input, NOT wire/API field names. An approved adapter must map
/// the backend's classification without recalculating freshness on the phone.
enum BackendReadingFreshness { fresh, notUpdated, sensorUnavailable, unknown }

class ActualReadingSnapshot {
  const ActualReadingSnapshot({
    required this.state,
    this.temperature,
    this.humidity,
  });

  factory ActualReadingSnapshot.fromBackendClassification({
    required BackendReadingFreshness? freshness,
    double? temperature,
    double? humidity,
    // Only verified incubator-link evidence may set this, never Wi-Fi loss,
    // cloud Active, an ACK, or absence of readings. This is not Stop evidence.
    bool verifiedIncubatorDisconnected = false,
  }) {
    return ActualReadingSnapshot(
      state: verifiedIncubatorDisconnected
          ? ActualReadingState.disconnected
          : switch (freshness) {
              BackendReadingFreshness.fresh => ActualReadingState.fresh,
              BackendReadingFreshness.notUpdated => ActualReadingState.stale,
              BackendReadingFreshness.sensorUnavailable =>
                ActualReadingState.unavailable,
              BackendReadingFreshness.unknown ||
              null => ActualReadingState.unknown,
            },
      temperature: temperature,
      humidity: humidity,
    );
  }

  factory ActualReadingSnapshot.fromReceipt({
    required bool connected,
    required double? temperature,
    required double? humidity,
    required DateTime? receivedAt,
    required DateTime now,
    required Duration staleAfter,
  }) {
    final age = receivedAt == null ? null : now.difference(receivedAt);
    final state = !connected
        ? ActualReadingState.unavailable
        : age == null || age.isNegative
        ? ActualReadingState.unknown
        : age > staleAfter
        ? ActualReadingState.stale
        : ActualReadingState.recentReceipt;
    return ActualReadingSnapshot(
      state: state,
      temperature: temperature,
      humidity: humidity,
    );
  }

  final ActualReadingState state;
  final double? temperature;
  final double? humidity;

  bool get canShowReportedValues => state == ActualReadingState.fresh;

  String get label => switch (state) {
    ActualReadingState.fresh => 'Reading up to date',
    ActualReadingState.stale => 'Reading not updated',
    ActualReadingState.unavailable => 'Reading unavailable',
    ActualReadingState.disconnected => 'Incubator disconnected',
    ActualReadingState.unknown ||
    ActualReadingState.recentReceipt => 'Reading time unavailable',
  };

  String valueText(double? value, String unit) =>
      canShowReportedValues && value != null && value.isFinite
      ? '${value.toStringAsFixed(1)} $unit'
      : '—';

  String get message => switch (state) {
    ActualReadingState.fresh =>
      'These are sensor readings, not confirmation that the incubator is running.',
    ActualReadingState.recentReceipt =>
      'An update arrived, but its reading time could not be checked.',
    ActualReadingState.stale =>
      'No recent reading. Check the incubator before relying on the app.',
    ActualReadingState.unknown =>
      'The app cannot check when this reading was taken.',
    ActualReadingState.unavailable =>
      'No current reading. Check the incubator and the connection.',
    ActualReadingState.disconnected =>
      'Check the Bluetooth connection. The incubator may still be running.',
  };
}

/// No target fallback, commands, writes, timers or profile selection.
/// Callers supply configured targets, never inferred measurement values.
class IncubatorReadings extends StatelessWidget {
  const IncubatorReadings({
    super.key,
    required this.reading,
    this.targetTemperature,
    this.targetHumidity,
    this.targetsApproved = false,
  });

  final ActualReadingSnapshot reading;
  final String? targetTemperature;
  final String? targetHumidity;
  // Presentation input only. No production caller sets this without approval.
  final bool targetsApproved;

  @override
  Widget build(BuildContext context) {
    Widget values({required bool actual}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          actual ? 'Current readings' : 'Batch settings',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Temperature'),
        Text(
          actual
              ? reading.valueText(reading.temperature, '°C')
              : targetsApproved
              ? targetTemperature ?? '—'
              : '—',
          key: ValueKey(actual ? 'actual-temperature' : 'target-temperature'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text('Humidity'),
        Text(
          actual
              ? reading.valueText(reading.humidity, '%')
              : targetsApproved
              ? targetHumidity ?? '—'
              : '—',
          key: ValueKey(actual ? 'actual-humidity' : 'target-humidity'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FarmerNoticeCard(
          titleKey: const ValueKey('reading-status-label'),
          notice: FarmerNotice(
            title: reading.label,
            message: reading.message,
            tone: reading.canShowReportedValues
                ? FarmerNoticeTone.information
                : FarmerNoticeTone.warning,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            Widget block(bool actual) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: actual ? const Color(0xFFFFF4E8) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: values(actual: actual),
            );
            if (constraints.maxWidth < 360 ||
                MediaQuery.textScalerOf(context).scale(16) > 24) {
              return Column(
                children: [
                  block(true),
                  const SizedBox(height: 8),
                  block(false),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: block(true)),
                const SizedBox(width: 8),
                Expanded(child: block(false)),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        if (reading.canShowReportedValues &&
            (reading.temperature == null ||
                !reading.temperature!.isFinite ||
                reading.humidity == null ||
                !reading.humidity!.isFinite))
          const FarmerNoticeCard(
            notice: FarmerNotice(
              title: 'Some sensor readings are unavailable.',
              message:
                  'A sensor value is missing or invalid. Check the incubator before relying on the available readings.',
              tone: FarmerNoticeTone.warning,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          !targetsApproved ||
                  targetTemperature == null ||
                  targetHumidity == null
              ? 'Batch settings are not available.'
              : 'Settings are shown for comparison, not as sensor readings.',
        ),
      ],
    );
  }
}
