import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/account_auth_service.dart';
import '../../services/test_account_client.dart';
import '../../services/test_backend_configuration.dart';
import '../../theme/app_theme.dart';
import 'account_access_screen.dart';

/// Separate development session: never navigates into legacy unscoped records.
/// The account form remains the existing UI, not a second implementation.
class BackendTestSession extends StatefulWidget {
  const BackendTestSession({
    super.key,
    required this.configurationValues,
    this.clientFactory = createTestAccountClient,
  });

  final Map<String, String> configurationValues;
  final GoTrueClient Function(TestBackendConfiguration) clientFactory;

  @override
  State<BackendTestSession> createState() => _BackendTestSessionState();
}

class _BackendTestSessionState extends State<BackendTestSession> {
  GoTrueClient? _client;
  AccountAuthService? _authenticator;
  String? _configurationError;

  @override
  void initState() {
    super.initState();
    try {
      final configuration = TestBackendConfiguration.fromValues(
        widget.configurationValues,
      );
      _client = widget.clientFactory(configuration);
      _authenticator = AccountAuthService(_client!);
    } on TestBackendConfigurationException catch (error) {
      _configurationError = error.message;
    } catch (_) {
      _configurationError = 'The isolated test account client could not start.';
    }
  }

  @override
  void dispose() {
    _client?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticator = _authenticator;
    if (authenticator == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test backend setup')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('No backend connection was started.'),
                const SizedBox(height: 16),
                Text(
                  _configurationError ?? 'Test configuration is unavailable.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Use config/supabase.test.example.json as the local template. '
                  'Do not paste keys into chat or commit local configuration.',
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        Material(
          color: AppColors.peach,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'TEST ONLY · smarthatch-test\n'
                'Account verification only. No records or hardware connection.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
        Expanded(child: AccountAccessScreen(authenticator: authenticator)),
      ],
    );
  }
}
