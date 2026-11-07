import 'package:flutter/material.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import '../../models/farmer_notice.dart';
import '../../widgets/common/farmer_notice_card.dart';

// ══════════════════════════════════════════════
// EDIT PROFILE SCREEN
// ══════════════════════════════════════════════

class EditProfileScreen extends StatefulWidget {
  /// Optional service override, used by widget tests.
  const EditProfileScreen({super.key, this.service});

  final SupabaseService? service;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final SupabaseService _service;
  late final TextEditingController _nameController;
  bool _saving = false;
  FarmerNotice? _notice;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SupabaseService();
    _nameController = TextEditingController(
      text: _service.getDisplayName() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(
        () => _notice = const FarmerNotice(
          title: 'Enter your display name',
          message: 'Display name cannot be empty.',
          tone: FarmerNoticeTone.warning,
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
      _notice = null;
    });
    try {
      final saved = await _service.updateDisplayName(name);
      if (!mounted) return;
      Navigator.pop(context, saved);
    } catch (_) {
      if (!mounted) return;
      // Surface the failure instead of pretending the profile was saved.
      setState(() {
        _saving = false;
        _notice = const FarmerNotice(
          title: 'Profile was not saved',
          message: 'Could not save profile. Please try again.',
          tone: FarmerNoticeTone.error,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
                children: [
                  const SizedBox(height: 16),
                  const Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Color(0xFFE8752A),
                      child: Icon(Icons.person, size: 56, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(
                        () => _notice = const FarmerNotice(
                          title: 'Photo upload is not available yet',
                          message:
                              'Photo upload will be available in a future version.',
                          tone: FarmerNoticeTone.information,
                        ),
                      );
                    },
                    child: const Text(
                      'Change Photo',
                      style: TextStyle(color: AppColors.primaryDarkPressed),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'SmartHatch User',
                      prefixIcon: const Icon(Icons.person_outlined),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
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
