import 'package:flutter/material.dart';

import '../models/confirmed_incubation_time.dart';

/// Receives a current trusted snapshot, not a saved session date or receipt time.
/// The eventual approved time adapter owns refreshing/invalidating the snapshot.
class ConfirmedStartProgress extends StatelessWidget {
  const ConfirmedStartProgress({super.key, this.time});

  final ConfirmedIncubationTime? time;

  @override
  Widget build(BuildContext context) {
    final start = time?.manilaStartLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time?.dayLabel ?? 'Waiting for confirmed start',
          key: const ValueKey('confirmed-incubation-day'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        if (start != null) Text('Confirmed Start: $start'),
      ],
    );
  }
}
