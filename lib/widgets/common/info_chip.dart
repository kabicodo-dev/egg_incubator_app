import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';

// ── Small info chip (calendar / thermostat) ──

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  /// When true the chip uses the warm SmartHatch palette (soft peach surface,
  /// dark orange icon). The default keeps the original cool-grey look so
  /// other screens are unaffected.
  final bool warm;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.warm = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warm ? AppColors.peach : const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: warm ? AppColors.primaryDark : Colors.black45,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: warm ? AppColors.textSecondary : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
