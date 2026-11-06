import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A measurement display, never a health/status classifier. The labelled chart
/// scale is not an approved operating range; numeric values are never clamped.
class ReadingDialTile extends StatelessWidget {
  const ReadingDialTile({
    super.key,
    required this.label,
    required this.formattedValue,
    required this.valueKey,
    required this.value,
    required this.scaleMaximum,
    required this.scaleUnit,
  });
  final String label;
  final String formattedValue;
  final String valueKey;
  final double? value;
  final double scaleMaximum;
  final String scaleUnit;

  @override
  Widget build(BuildContext context) {
    final available = value?.isFinite == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Tooltip(
            message: 'Display scale only—not a safe operating range.',
            child: ExcludeSemantics(
              child: SizedBox(
                width: 100,
                height: 54,
                child: CustomPaint(
                  painter: ReadingDialPainter(
                    fraction: available
                        ? (value! / scaleMaximum).clamp(0.0, 1.0)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedValue,
            key: ValueKey(valueKey),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '0–${scaleMaximum.toInt()} $scaleUnit scale',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ReadingDialPainter extends CustomPainter {
  const ReadingDialPainter({required this.fraction});
  final double? fraction;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height - 6),
      radius: math.min(size.width / 2, size.height - 6) - 5,
    );
    final track = Paint()
      ..color = AppColors.borderWarm
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, track);
    if (fraction != null && fraction! > 0) {
      canvas.drawArc(
        rect,
        math.pi,
        math.pi * fraction!,
        false,
        Paint()
          ..color = AppColors.primaryDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(ReadingDialPainter oldDelegate) =>
      fraction != oldDelegate.fraction;
}
