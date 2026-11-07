import 'dart:convert';

import 'package:egg_incubator_app/services/test_backend_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

String _encode(Map<String, Object> value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

String _legacyKey({String role = 'anon', String? reference}) =>
    '${_encode({'alg': 'HS256', 'typ': 'JWT'})}.'
    '${_encode({'role': role, 'ref': reference ?? TestBackendConfiguration.projectReference})}'
    '.fictional-signature';

Map<String, String> _values() => {
  'SMARTHATCH_ENV': 'test',
  'SUPABASE_URL': TestBackendConfiguration.projectUrl,
  'SUPABASE_PUBLISHABLE_KEY': 'sb_publishable_fictional_test_fixture',
};

void main() {
  test('accepts the fixed test target with a public key shape', () {
    final configuration = TestBackendConfiguration.fromValues(_values());
    expect(configuration.url, TestBackendConfiguration.projectUrl);
    expect(configuration.toString(), isNot(contains(configuration.clientKey)));
  });

  test('normalizes only harmless outer URL whitespace and trailing slash', () {
    final configuration = TestBackendConfiguration.fromValues(
      _values()..['SUPABASE_URL'] = ' ${TestBackendConfiguration.projectUrl}/ ',
    );
    expect(configuration.url, TestBackendConfiguration.projectUrl);
  });

  for (final environment in ['', 'production', 'final', 'TEST']) {
    test('refuses environment "$environment"', () {
      expect(
        () => TestBackendConfiguration.fromValues(
          _values()..['SMARTHATCH_ENV'] = environment,
        ),
        throwsA(
          isA<TestBackendConfigurationException>().having(
            (error) => error.failure,
            'failure',
            TestBackendConfigurationFailure.missingEnvironment,
          ),
        ),
      );
    });
  }

  for (final url in [
    '',
    'https://another-project.supabase.co',
    'http://zbwntspdecngnicllwlw.supabase.co',
    '${TestBackendConfiguration.projectUrl}:443',
    'https://person@zbwntspdecngnicllwlw.supabase.co',
    '${TestBackendConfiguration.projectUrl}/auth/v1',
    '${TestBackendConfiguration.projectUrl}?redirect=elsewhere',
    '${TestBackendConfiguration.projectUrl}#fragment',
    '${TestBackendConfiguration.projectUrl}.example.invalid',
  ]) {
    test('refuses a non-canonical/wrong project URL: $url', () {
      expect(
        () => TestBackendConfiguration.fromValues(
          _values()..['SUPABASE_URL'] = url,
        ),
        throwsA(
          isA<TestBackendConfigurationException>().having(
            (error) => error.failure,
            'failure',
            TestBackendConfigurationFailure.wrongProject,
          ),
        ),
      );
    });
  }

  test('missing configuration never falls back to .env or a final project', () {
    expect(
      () => TestBackendConfiguration.fromValues({}),
      throwsA(isA<TestBackendConfigurationException>()),
    );
  });

  test('missing public key has safe setup feedback', () {
    expect(
      () => TestBackendConfiguration.fromValues(
        _values()..['SUPABASE_PUBLISHABLE_KEY'] = '',
      ),
      throwsA(
        isA<TestBackendConfigurationException>().having(
          (error) => error.failure,
          'failure',
          TestBackendConfigurationFailure.missingClientKey,
        ),
      ),
    );
  });

  test('accepts legacy anon claims for the exact test project only', () {
    final configuration = TestBackendConfiguration.fromValues(
      _values()..['SUPABASE_PUBLISHABLE_KEY'] = _legacyKey(),
    );
    expect(configuration.url, TestBackendConfiguration.projectUrl);
  });

  for (final key in [
    'sb_secret_do_not_use',
    _legacyKey(role: 'service_role'),
    _legacyKey(role: 'authenticated'),
    _legacyKey(reference: 'another-project'),
    'unknown-client-config',
    'header.not-base64.signature',
    'sb_publishable_has spaces',
    'sb_secret_prefix.${_encode({'role': 'anon', 'ref': TestBackendConfiguration.projectReference})}.signature',
  ]) {
    test('rejects unsafe key shape without echoing its contents', () {
      expect(
        () => TestBackendConfiguration.fromValues(
          _values()..['SUPABASE_PUBLISHABLE_KEY'] = key,
        ),
        throwsA(
          isA<TestBackendConfigurationException>()
              .having(
                (error) => error.failure,
                'failure',
                TestBackendConfigurationFailure.unsafeClientKey,
              )
              .having(
                (error) => error.toString(),
                'message',
                isNot(contains(key)),
              ),
        ),
      );
    });
  }
}
