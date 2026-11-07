import 'package:flutter/material.dart';
import 'package:egg_incubator_app/widgets/common/profile_option.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/screens/profile/account_settings_screen.dart';
import 'package:egg_incubator_app/screens/profile/edit_profile_screen.dart';
import 'package:egg_incubator_app/widgets/common/section_label.dart';
import '../../models/farmer_notice.dart';
import '../../widgets/common/farmer_notice_card.dart';

// ══════════════════════════════════════════════
// PROFILE SCREEN
// ══════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  /// Optional service override, used by widget tests.
  const ProfileScreen({super.key, this.service});

  final SupabaseService? service;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _fallbackName = 'SmartHatch User';

  late final SupabaseService _service;
  String _displayName = _fallbackName;
  FarmerNotice? _notice;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SupabaseService();
    _displayName = _service.getDisplayName() ?? _fallbackName;
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => EditProfileScreen(service: _service),
      ),
    );
    if (!mounted) return;
    setState(() {
      _displayName = updated ?? _service.getDisplayName() ?? _fallbackName;
      if (updated != null) {
        _notice = const FarmerNotice(
          title: 'Profile updated!',
          message: 'Your display name has been saved.',
          tone: FarmerNoticeTone.success,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: Column(
          children: [
            if (_notice != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: FarmerNoticeCard(notice: _notice!),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Color(0xFFE8752A),
                        child: Icon(
                          Icons.person,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel(text: 'ACCOUNT'),
                    const SizedBox(height: 10),
                    ProfileOption(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: _openEditProfile,
                    ),
                    ProfileOption(
                      icon: Icons.person_outline,
                      title: 'Account',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const SectionLabel(text: 'SETTINGS'),
                    const SizedBox(height: 10),
                    ProfileOption(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPlaceholderScreen(
                              title: 'Notifications',
                            ),
                          ),
                        );
                      },
                    ),
                    ProfileOption(
                      icon: Icons.thermostat_outlined,
                      title: 'Temperature Unit',
                      subtitle: 'Celsius',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPlaceholderScreen(
                              title: 'Temperature Unit',
                            ),
                          ),
                        );
                      },
                    ),
                    ProfileOption(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPlaceholderScreen(
                              title: 'Language',
                            ),
                          ),
                        );
                      },
                    ),
                    ProfileOption(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPlaceholderScreen(
                              title: 'Dark Mode',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const SectionLabel(text: 'ABOUT'),
                    const SizedBox(height: 10),
                    ProfileOption(
                      icon: Icons.info_outline,
                      title: 'App Version',
                      subtitle: '1.0.0',
                      onTap: () {
                        setState(
                          () => _notice = const FarmerNotice(
                            title: 'App version',
                            message: 'SmartHatch v1.0.0',
                            tone: FarmerNoticeTone.information,
                          ),
                        );
                      },
                    ),
                    ProfileOption(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        setState(
                          () => _notice = const FarmerNotice(
                            title: 'Help & Support is not available yet',
                            message:
                                'Help & Support will be available in a future version.',
                            tone: FarmerNoticeTone.information,
                          ),
                        );
                      },
                    ),
                    ProfileOption(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        setState(
                          () => _notice = const FarmerNotice(
                            title: 'Privacy Policy is not available yet',
                            message:
                                'Privacy Policy will be available in a future version.',
                            tone: FarmerNoticeTone.information,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
