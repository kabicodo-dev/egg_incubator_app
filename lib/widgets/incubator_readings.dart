import 'package:flutter/material.dart';

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

  bool get canShowReportedValues =>
      state == ActualReadingState.recentReceipt ||
      state == ActualReadingState.fresh;

  String get label => switch (state) {
    ActualReadingState.fresh => 'Fresh',
    ActualReadingState.stale => 'Reading Not Updated',
    ActualReadingState.unavailable => 'Sensor Unavailable',
    ActualReadingState.disconnected => 'Incubator Disconnected',
    ActualReadingState.unknown ||
    ActualReadingState.recentReceipt => 'Unknown Freshness',
  };

  String valueText(double? value, String unit) =>
      canShowReportedValues && value != null && value.isFinite
      ? '${value.toStringAsFixed(1)} $unit'
      : '—';

  String get message => switch (state) {
    ActualReadingState.fresh =>
      'Backend classifies this reading as fresh; this does not verify '
          'physical Running or target application.',
    ActualReadingState.recentReceipt =>
      'Recently received; measurement age and source/batch association are '
          'unverified. Not verified live.',
    ActualReadingState.stale =>
      'Reading Not Updated — last received data is not live.',
    ActualReadingState.unknown =>
      'Unknown Freshness — waiting for a trustworthy reading time.',
    ActualReadingState.unavailable =>
      'Sensor Unavailable — no current physical reading. '
          'Connection loss does not prove incubation stopped.',
    ActualReadingState.disconnected =>
      'Incubator link disconnection verified; autonomous incubation may '
          'continue. This does not confirm Stop.',
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
  });

  final ActualReadingSnapshot reading;
  final String? targetTemperature;
  final String? targetHumidity;

  @override
  Widget build(BuildContext context) {
    Widget values({required bool actual}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          actual ? 'Actual' : 'Target',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Temperature'),
        Text(
          actual
              ? reading.valueText(reading.temperature, '°C')
              : targetTemperature ?? '—',
          key: ValueKey(actual ? 'actual-temperature' : 'target-temperature'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text('Humidity'),
        Text(
          actual
              ? reading.valueText(reading.humidity, '%')
              : targetHumidity ?? '—',
          key: ValueKey(actual ? 'actual-humidity' : 'target-humidity'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Text(
          reading.label,
          key: const ValueKey('reading-status-label'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(reading.message),
        if (reading.canShowReportedValues &&
            (reading.temperature == null ||
                !reading.temperature!.isFinite ||
                reading.humidity == null ||
                !reading.humidity!.isFinite))
          const Text('Sensor Unavailable — missing or invalid actual values.'),
        const SizedBox(height: 4),
        Text(
          targetTemperature == null || targetHumidity == null
              ? 'Target unavailable — approved active profile required.'
              : 'Read-only configured targets; approval and physical '
                    'application are not verified.',
        ),
      ],
    );
  }
}
