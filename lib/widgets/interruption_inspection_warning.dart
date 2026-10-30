import 'package:flutter/material.dart';

import '../controllers/interruption_inspection_controller.dart';

/// A persistent dashboard block, not a snackbar or dismissible notification.
class InterruptionInspectionWarning extends StatelessWidget {
  const InterruptionInspectionWarning({super.key, required this.controller});

  final InterruptionInspectionController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final pending = controller.pending;
      if (pending.isEmpty && controller.statusKnown) {
        return const SizedBox.shrink();
      }
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          border: Border.all(color: const Color(0xFF8D4B00)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pending.isEmpty
                  ? 'Restart/interruption status unverified'
                  : 'Inspection required after interruption',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inspect the incubator and eggs. Egg condition and survival '
              'are not verified. Reconnection does not clear this warning '
              'or establish physical Running or Stop.',
            ),
            if (pending.isEmpty)
              const Text(
                'The approved inspection-status backend adapter is not '
                'available or its status could not be read. This is not '
                'evidence that an interruption occurred.',
              ),
            for (final incident in pending) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                key: ValueKey('inspection-${incident.reference}'),
                onPressed: controller.canAcknowledge
                    ? () => controller.confirmInspection(incident)
                    : null,
                child: const Text('I inspected the incubator and eggs'),
              ),
            ],
            if (controller.busy)
              const Text('Verifying saved inspection status…'),
            if (controller.error != null) Text(controller.error!),
            const Text(
              'Inspection acknowledgment does not certify egg survival, '
              'electrical safety or successful recovery. No Start is replayed.',
            ),
          ],
        ),
      );
    },
  );
}
