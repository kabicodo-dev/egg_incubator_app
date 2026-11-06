import 'package:flutter/material.dart';

import 'app.dart';
import 'screens/auth/backend_test_session.dart';

/// Explicit test-only entry point. Does not call the existing .env/anonymous
/// bootstrap or enter any production/batch routes after authentication.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const SmartHatchApp(
      home: BackendTestSession(
        configurationValues: {
          'SMARTHATCH_ENV': String.fromEnvironment('SMARTHATCH_ENV'),
          'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL'),
          'SUPABASE_PUBLISHABLE_KEY': String.fromEnvironment(
            'SUPABASE_PUBLISHABLE_KEY',
          ),
        },
      ),
    ),
  );
}
