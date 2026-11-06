import 'dart:convert';

import 'package:egg_incubator_app/screens/auth/account_access_screen.dart';
import 'package:egg_incubator_app/screens/auth/backend_test_session.dart';
import 'package:egg_incubator_app/services/test_account_client.dart';
import 'package:egg_incubator_app/services/test_backend_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Map<String, String> _values() => {
  'SMARTHATCH_ENV': 'test',
  'SUPABASE_URL': TestBackendConfiguration.projectUrl,
  'SUPABASE_PUBLISHABLE_KEY': 'sb_publishable_fictional_test_fixture',
};

String _part(Map<String, Object> value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

void main() {
  test('standalone client starts with no restored production session', () {
    final client = createTestAccountClient(
      TestBackendConfiguration.fromValues(_values()),
    );
    addTearDown(client.dispose);
    expect(client.currentSession, isNull);
    expect(client.headers['apikey'], 'sb_publishable_fictional_test_fixture');
  });

  for (final configuration in [
    <String, String>{},
    _values()..['SUPABASE_URL'] = 'https://final-project.example.invalid',
    _values()..['SUPABASE_PUBLISHABLE_KEY'] = 'sb_secret_not_allowed',
  ]) {
    testWidgets('invalid configuration never constructs an auth client', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BackendTestSession(
            configurationValues: configuration,
            clientFactory: (_) {
              calls++;
              throw StateError('must not construct a client');
            },
          ),
        ),
      );
      expect(calls, 0);
      expect(find.byType(AccountAccessScreen), findsNothing);
      expect(find.text('No backend connection was started.'), findsOneWidget);
      expect(find.textContaining('sb_secret_not_allowed'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('renders existing form with no request or hardware connection', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final transport = MockClient((request) async {
      requests.add(request);
      return http.Response('{}', 500);
    });
    addTearDown(transport.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BackendTestSession(
          configurationValues: _values(),
          clientFactory: (configuration) => GoTrueClient(
            url: '${configuration.url}/auth/v1',
            autoRefreshToken: false,
            httpClient: transport,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(requests, isEmpty);
    expect(find.byType(AccountAccessScreen), findsOneWidget);
    expect(find.textContaining('TEST ONLY'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('explicit login stays on auth screen and never queries records', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final transport = MockClient((request) async {
      requests.add(request);
      expect(request.url.host, 'zbwntspdecngnicllwlw.supabase.co');
      expect(request.url.path, '/auth/v1/token');
      expect(request.method, 'POST');
      return http.Response(
        jsonEncode({
          'access_token':
              '${_part({'alg': 'HS256', 'typ': 'JWT'})}.'
              '${_part({'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600})}'
              '.fictional-signature',
          'refresh_token': 'fictional-refresh',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': {
            'id': '00000000-0000-4000-8000-000000000001',
            'email': 'farmer@example.invalid',
            'email_confirmed_at': '2026-11-06T00:00:00Z',
            'app_metadata': <String, dynamic>{},
            'user_metadata': <String, dynamic>{},
            'created_at': '2026-11-06T00:00:00Z',
            'aud': 'authenticated',
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    addTearDown(transport.close);
    await tester.pumpWidget(
      MaterialApp(
        home: BackendTestSession(
          configurationValues: _values(),
          clientFactory: (configuration) => GoTrueClient(
            url: '${configuration.url}/auth/v1',
            autoRefreshToken: false,
            httpClient: transport,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('account-email')),
      'farmer@example.invalid',
    );
    await tester.enterText(
      find.byKey(const Key('account-password')),
      'fictional password',
    );
    await tester.ensureVisible(find.byKey(const Key('account-submit')));
    await tester.tap(find.byKey(const Key('account-submit')));
    await tester.pumpAndSettle();
    expect(requests, hasLength(1));
    expect(find.text('Signed in'), findsOneWidget);
    expect(find.byType(AccountAccessScreen), findsOneWidget);
    expect(find.textContaining('TEST ONLY'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
