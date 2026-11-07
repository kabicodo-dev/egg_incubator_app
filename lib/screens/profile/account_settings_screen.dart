import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/widgets/common/profile_option.dart';
import 'package:egg_incubator_app/widgets/common/section_label.dart';
import 'package:egg_incubator_app/screens/hardware/incubator_dashboard_page.dart';
import '../../models/farmer_notice.dart';
import '../../widgets/common/farmer_notice_card.dart';

// ══════════════════════════════════════════════
// ACCOUNT SETTINGS SCREEN
// ══════════════════════════════════════════════

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  FarmerNotice? _notice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Column(
        children: [
          if (_notice != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FarmerNoticeCard(notice: _notice!),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel(text: 'PROJECT TEAM TOOLS'),
                  const SizedBox(height: 10),
                  ProfileOption(
                    icon: Icons.developer_board,
                    title: 'Hardware diagnostics',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncubatorDashboardPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionLabel(text: 'DATA'),
                  const SizedBox(height: 10),
                  ProfileOption(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Backup Data',
                    onTap: () {
                      setState(
                        () => _notice = const FarmerNotice(
                          title: 'Backup is not available yet',
                          message:
                              'Cloud backup will be available in a future version.',
                          tone: FarmerNoticeTone.information,
                        ),
                      );
                    },
                  ),
                  ProfileOption(
                    icon: Icons.cloud_download_outlined,
                    title: 'Restore Data',
                    onTap: () {
                      setState(
                        () => _notice = const FarmerNotice(
                          title: 'Restore is not available yet',
                          message:
                              'Data restore will be available in a future version.',
                          tone: FarmerNoticeTone.information,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SETTINGS PLACEHOLDER SCREEN
// ══════════════════════════════════════════════

class SettingsPlaceholderScreen extends StatelessWidget {
  final String title;
  const SettingsPlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FarmerNoticeCard(
                notice: FarmerNotice(
                  title: '$title is not available yet',
                  message:
                      '$title settings will be available in a future version.',
                  tone: FarmerNoticeTone.information,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDarkPressed,
                    side: const BorderSide(color: Color(0xFFE8752A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
