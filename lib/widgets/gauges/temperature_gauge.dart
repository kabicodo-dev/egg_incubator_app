import 'dart:math';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════
// TEMPERATURE GAUGE
// ══════════════════════════════════════════════

class _TemperatureGaugePainter extends CustomPainter {
  final double normalizedValue; // 0.0 (min) to 1.0 (max)

  _TemperatureGaugePainter({required this.normalizedValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const startAngle = 3.14159; // π (left)
    const sweepAngle = 3.14159; // π (half circle)
    const strokeWidth = 14.0;

    // Background arc (full range)
    final bgPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Ideal range arc (green zone: 37.0–38.0 in a 35–40 range = 40%–60%)
    final idealStart = 0.4;
    final idealEnd = 0.6;
    final idealPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + idealStart * sweepAngle,
      (idealEnd - idealStart) * sweepAngle,
      false,
      idealPaint,
    );

    // Value arc
    final clampedValue = normalizedValue.clamp(0.0, 1.0);
    final valuePaint = Paint()
      ..color = _getTemperatureColor(clampedValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      clampedValue * sweepAngle,
      false,
      valuePaint,
    );

    // Needle dot
    final needleAngle = startAngle + clampedValue * sweepAngle;
    final needleX = center.dx + radius * cos(needleAngle);
    final needleY = center.dy + radius * sin(needleAngle);
    final dotPaint = Paint()
      ..color = _getTemperatureColor(clampedValue)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(needleX, needleY), 6, dotPaint);
    canvas.drawCircle(
      Offset(needleX, needleY),
      3,
      Paint()..color = Colors.white,
    );
  }

  static Color _getTemperatureColor(double normalized) {
    if (normalized < 0.35) return const Color(0xFF2196F3); // Blue - too low
    if (normalized > 0.65) return const Color(0xFFFF5722); // Red - too high
    return const Color(0xFF4CAF50); // Green - ideal
  }

  @override
  bool shouldRepaint(covariant _TemperatureGaugePainter oldDelegate) {
    return oldDelegate.normalizedValue != normalizedValue;
  }
}

class TemperatureGauge extends StatelessWidget {
  final double currentTemp;
  final double minTemp;
  final double maxTemp;
  final double idealMin;
  final double idealMax;

  const TemperatureGauge({
    super.key,
    required this.currentTemp,
    this.minTemp = 35.0,
    this.maxTemp = 40.0,
    this.idealMin = 37.0,
    this.idealMax = 38.0,
  });

  String get _statusText {
    if (currentTemp >= idealMin && currentTemp <= idealMax) {
      return 'Within the recommended range';
    } else if (currentTemp < idealMin) {
      return 'Below recommended range';
    } else {
      return 'Above recommended range';
    }
  }

  Color get _statusColor {
    if (currentTemp >= idealMin && currentTemp <= idealMax) {
      return const Color(0xFF4CAF50);
    } else if (currentTemp < idealMin) {
      return const Color(0xFF2196F3);
    } else {
      return const Color(0xFFFF5722);
    }
  }

  IconData get _statusIcon {
    if (currentTemp >= idealMin && currentTemp <= idealMax) {
      return Icons.check_circle_outline;
    } else if (currentTemp < idealMin) {
      return Icons.arrow_downward;
    } else {
      return Icons.arrow_upward;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized = ((currentTemp - minTemp) / (maxTemp - minTemp)).clamp(
      0.0,
      1.0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8752A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.thermostat,
                  color: Color(0xFFE8752A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Temperature',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gauge
          SizedBox(
            width: 180,
            height: 100,
            child: CustomPaint(
              painter: _TemperatureGaugePainter(normalizedValue: normalized),
            ),
          ),
          const SizedBox(height: 8),

          // Temperature value
          Text(
            '${currentTemp.toStringAsFixed(1)}\u00B0C',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon, size: 16, color: _statusColor),
                const SizedBox(width: 6),
                Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Recommended range
          Text(
            'Recommended: ${idealMin.toStringAsFixed(1)}\u00B0C – ${idealMax.toStringAsFixed(1)}\u00B0C',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
