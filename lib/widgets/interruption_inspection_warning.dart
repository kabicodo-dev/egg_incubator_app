import 'package:flutter/material.dart';

import '../controllers/interruption_inspection_controller.dart';
import '../theme/app_theme.dart';

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    pending.isEmpty
                        ? 'Incubator status unavailable'
                        : 'Check after interruption',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pending.isEmpty
                  ? 'Check the incubator and eggs before continuing.'
                  : 'An interruption was reported. Check the incubator and eggs.',
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
            if (controller.busy) const Text('Checking status…'),
            if (controller.error != null && pending.isNotEmpty)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Couldn’t confirm the update. Please try again.',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}
