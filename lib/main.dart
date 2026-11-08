import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:egg_incubator_app/app.dart';
import 'package:egg_incubator_app/config/supabase_config.dart';
import 'package:egg_incubator_app/screens/startup/missing_config_screen.dart';

export 'app_exports.dart';

// ──────────────────────────────────────────────
// App Entry Point
// ──────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Public settings arrive as build-time definitions, never as a bundled asset.
  final config = SupabaseConfig.fromEnvironment();
  final missing = missingSupabaseConfigKeys(
    url: config.url,
    anonKey: config.anonKey,
  );

  if (missing.isNotEmpty) {
    // Explain the missing settings instead of crashing or starting a
    // half-configured cloud session.
    runApp(SmartHatchApp(home: MissingConfigScreen(missingKeys: missing)));
    return;
  }

  await Supabase.initialize(
    url: config.normalizedUrl,
    publishableKey: config.normalizedAnonKey,
  );

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    await Supabase.instance.client.auth.signInAnonymously();
  }

  runApp(const SmartHatchApp());
}
