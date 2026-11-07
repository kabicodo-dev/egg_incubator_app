// Isolated UI acceptance fixture, never imported by the production application.
// No Supabase, transport, command, persistence or notification delivery code.
import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ReadingStatesPreview()));

class ReadingStatesPreview extends StatefulWidget {
  const ReadingStatesPreview({super.key});

  @override
  State<ReadingStatesPreview> createState() => _ReadingStatesPreviewState();
}

class _ReadingStatesPreviewState extends State<ReadingStatesPreview> {
  ActualReadingSnapshot reading = const ActualReadingSnapshot(
    state: ActualReadingState.unknown,
  );

  static const cases = <String, ActualReadingSnapshot>{
    'Fresh fixture': ActualReadingSnapshot(
      state: ActualReadingState.fresh,
      temperature: 36.2,
      humidity: 48,
    ),
    'Not updated fixture': ActualReadingSnapshot(
      state: ActualReadingState.stale,
      temperature: 36.2,
      humidity: 48,
    ),
    'Sensor unavailable fixture': ActualReadingSnapshot(
      state: ActualReadingState.unavailable,
      temperature: 36.2,
      humidity: 48,
    ),
    'Unknown fixture': ActualReadingSnapshot(
      state: ActualReadingState.unknown,
      temperature: 36.2,
      humidity: 48,
    ),
    'Disconnected fixture': ActualReadingSnapshot(
      state: ActualReadingState.disconnected,
      temperature: 36.2,
      humidity: 48,
    ),
    'Receipt only fixture': ActualReadingSnapshot(
      state: ActualReadingState.recentReceipt,
      temperature: 36.2,
      humidity: 48,
    ),
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('K-05 MOCK state verification')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SOFTWARE FIXTURES ONLY — no physical readings or connection. '
            'These controls inject test states into the actual app widget. '
            'They do not authorize a production classifier or profile.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in cases.entries)
                OutlinedButton(
                  onPressed: () => setState(() => reading = entry.value),
                  child: Text(entry.key),
                ),
            ],
          ),
          const SizedBox(height: 16),
          IncubatorReadings(
            reading: reading,
            targetTemperature: 'UNAPPROVED fixture temperature',
            targetHumidity: 'UNAPPROVED fixture humidity',
          ),
          const SizedBox(height: 16),
          const Text(
            'Operation: Unknown — no Running/Stop evidence. '
            'Cloud state: unavailable. No hardware commands are sent.',
          ),
        ],
      ),
    ),
  );
}
