import 'package:flutter/material.dart';
import '../models/app_derived_schedule.dart';

class AppSchedule extends StatelessWidget {
  const AppSchedule({super.key, required this.storedStart, this.now});
  final Object? storedStart;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final schedule = AppDerivedSchedule.fromStoredStart(
      storedStart,
      now ?? DateTime.now(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          schedule.day == null
              ? 'Saved start date unavailable'
              : 'Saved start: ${storedStart.toString().substring(0, 10)}',
          key: const ValueKey('app-derived-schedule'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const Text('The incubation day needs a confirmed start time.'),
      ],
    );
  }
}
