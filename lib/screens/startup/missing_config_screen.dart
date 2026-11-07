import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';

/// Shown instead of the app when the build has no usable Supabase settings.
///
/// It names the missing settings and the command that supplies them. It never
/// displays a configuration value, and it does not attempt a network call.
class MissingConfigScreen extends StatelessWidget {
  const MissingConfigScreen({super.key, required this.missingKeys});

  final List<String> missingKeys;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.settings_suggest_outlined,
                    size: 48,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SmartHatch needs its project settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This build was started without the public Supabase '
                    'settings, so the app cannot open any records. Nothing was '
                    'changed and no connection was attempted.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Missing or unusable: ${missingKeys.join(', ')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'To run locally, copy .env.example to .env with your '
                    'project values, then start the app with:',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderWarm),
                    ),
                    child: const SelectableText(
                      'flutter run --dart-define-from-file=.env',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Only the public project URL and publishable/anon key '
                    'belong in that file. Never add a service_role or other '
                    'privileged key, and never commit the file.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
