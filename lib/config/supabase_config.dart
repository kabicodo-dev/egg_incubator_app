/// Public client configuration for the hosted Supabase project.
///
/// Values are supplied at build/run time (`--dart-define` or
/// `--dart-define-from-file`) instead of being packaged as a Flutter asset, so
/// no configuration file is bundled into the app.
///
/// Only the public URL and publishable/anon key belong here. Privileged keys
/// (for example a `service_role` key) must never be supplied to a client build.
class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  /// Reads the compile-time definitions for this build.
  factory SupabaseConfig.fromEnvironment() => const SupabaseConfig(
    url: String.fromEnvironment('SUPABASE_URL'),
    anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final String url;
  final String anonKey;

  String get normalizedUrl => url.trim();

  String get normalizedAnonKey => anonKey.trim();

  bool get isComplete => missingSupabaseConfigKeys(url: url, anonKey: anonKey).isEmpty;
}

/// Names of the required settings that are missing or unusable.
///
/// Returns variable **names only** so a startup message can explain what to
/// supply without ever rendering a configuration value.
List<String> missingSupabaseConfigKeys({
  required String url,
  required String anonKey,
}) {
  final missing = <String>[];
  if (!isUsableSupabaseUrl(url)) missing.add('SUPABASE_URL');
  if (anonKey.trim().isEmpty) missing.add('SUPABASE_ANON_KEY');
  return missing;
}

/// Accepts a hosted HTTPS project URL, or plain HTTP on a loopback host for a
/// local `supabase start` stack. Credentials, paths, queries and fragments are
/// rejected because they are not part of a project URL.
bool isUsableSupabaseUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) return false;
  if (uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      (uri.path.isNotEmpty && uri.path != '/')) {
    return false;
  }
  if (uri.scheme == 'https') return true;
  return uri.scheme == 'http' &&
      const {'localhost', '127.0.0.1', '::1'}.contains(uri.host);
}
