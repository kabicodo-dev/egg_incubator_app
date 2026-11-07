import 'dart:convert';

enum TestBackendConfigurationFailure {
  missingEnvironment,
  wrongProject,
  missingClientKey,
  unsafeClientKey,
}

class TestBackendConfigurationException implements Exception {
  const TestBackendConfigurationException(this.failure);

  final TestBackendConfigurationFailure failure;

  String get message => switch (failure) {
    TestBackendConfigurationFailure.missingEnvironment =>
      'Set SMARTHATCH_ENV to test for this separate test launcher.',
    TestBackendConfigurationFailure.wrongProject =>
      'This launcher only accepts the confirmed smarthatch-test project URL.',
    TestBackendConfigurationFailure.missingClientKey =>
      'Configure the test project publishable or legacy anon client key locally.',
    TestBackendConfigurationFailure.unsafeClientKey =>
      'Use only the test project publishable or legacy anon client key. '
          'Secret, service-role and user-session keys are not allowed.',
  };

  @override
  String toString() => message;
}

/// Fixed to Kath's supplied test project; no final-project or .env fallback.
///
/// Key checks prevent obvious privileged/wrong-project configuration. They do
/// not validate JWT signatures or establish authorization. The provider remains
/// responsible for checking the actual key and enforcing server-side policies.
class TestBackendConfiguration {
  const TestBackendConfiguration._(this.url, this.clientKey);

  static const projectReference = 'zbwntspdecngnicllwlw';
  static const projectUrl = 'https://zbwntspdecngnicllwlw.supabase.co';

  final String url;
  final String clientKey;

  factory TestBackendConfiguration.fromValues(Map<String, String> values) {
    if (values['SMARTHATCH_ENV'] != 'test') {
      throw const TestBackendConfigurationException(
        TestBackendConfigurationFailure.missingEnvironment,
      );
    }
    final rawUrl = values['SUPABASE_URL']?.trim() ?? '';
    final uri = Uri.tryParse(rawUrl);
    if ((rawUrl != projectUrl && rawUrl != '$projectUrl/') ||
        uri == null ||
        uri.scheme != 'https' ||
        uri.host != '$projectReference.supabase.co' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const TestBackendConfigurationException(
        TestBackendConfigurationFailure.wrongProject,
      );
    }
    final key = values['SUPABASE_PUBLISHABLE_KEY']?.trim() ?? '';
    if (key.isEmpty) {
      throw const TestBackendConfigurationException(
        TestBackendConfigurationFailure.missingClientKey,
      );
    }
    if (!_isAllowedClientKey(key)) {
      throw const TestBackendConfigurationException(
        TestBackendConfigurationFailure.unsafeClientKey,
      );
    }
    return TestBackendConfiguration._(projectUrl, key);
  }

  static bool _isAllowedClientKey(String key) {
    if (key.startsWith('sb_secret_')) return false;
    if (RegExp(r'^sb_publishable_[A-Za-z0-9_-]+$').hasMatch(key)) {
      // Opaque publishable keys have no locally inspectable project claim.
      return true;
    }
    final parts = key.split('.');
    if (parts.length != 3 || parts.any((part) => part.isEmpty)) return false;
    try {
      final header = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[0]))),
      );
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return header is Map<String, dynamic> &&
          header['alg'] == 'HS256' &&
          payload is Map<String, dynamic> &&
          payload['role'] == 'anon' &&
          payload['ref'] == projectReference;
    } catch (_) {
      return false;
    }
  }

  @override
  String toString() => 'TestBackendConfiguration(smarthatch-test)';
}
