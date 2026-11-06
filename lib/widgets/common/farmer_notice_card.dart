import 'package:flutter/material.dart';
import '../../models/farmer_notice.dart';
import '../../theme/app_theme.dart';

/// Separate, accessible outcome/status card. Colour always has an icon + words.
class FarmerNoticeCard extends StatelessWidget {
  const FarmerNoticeCard({super.key, required this.notice, this.titleKey});
  final FarmerNotice notice;
  final Key? titleKey;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (notice.tone) {
      FarmerNoticeTone.warning => (
        AppColors.warning,
        Icons.warning_amber_rounded,
      ),
      FarmerNoticeTone.error => (AppColors.danger, Icons.error_outline),
      FarmerNoticeTone.success => (
        AppColors.success,
        Icons.check_circle_outline,
      ),
      FarmerNoticeTone.information => (
        AppColors.textSecondary,
        Icons.info_outline,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    key: titleKey,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice.message,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
