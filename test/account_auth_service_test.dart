import 'dart:async';
import 'dart:convert';

import 'package:egg_incubator_app/services/account_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryStorage implements GotrueAsyncStorage {
  final Map<String, String> _values = {};

  @override
  Future<String?> getItem({required String key}) async => _values[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _values.remove(key);
  }
}

Map<String, dynamic> _user({bool confirmed = true, bool anonymous = false}) => {
  'id': '00000000-0000-4000-8000-000000000001',
  'aud': 'authenticated',
  'email': 'farmer@example.invalid',
  'created_at': '2026-11-06T00:00:00Z',
  'email_confirmed_at': confirmed ? '2026-11-06T00:00:00Z' : null,
  'is_anonymous': anonymous,
  'app_metadata': <String, dynamic>{},
  'user_metadata': <String, dynamic>{},
};

Map<String, dynamic> _session({
  bool confirmed = true,
  bool anonymous = false,
  int expiresIn = 3600,
}) => {
  // Unsigned local fixture only. Tests do not establish JWT signature validity.
  'access_token':
      '${_jwtPart({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${_jwtPart({'sub': '00000000-0000-4000-8000-000000000001', 'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + expiresIn})}.fictional-signature',
  'refresh_token': 'fictional-test-refresh-token',
  'token_type': 'bearer',
  'expires_in': expiresIn,
  'user': _user(confirmed: confirmed, anonymous: anonymous),
};

String _jwtPart(Map<String, Object> value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

void main() {
  late GoTrueClient auth;
  late AccountAuthService service;
  late MockClient httpClient;
  late List<http.Request> requests;
  late Map<String, dynamic> responseBody;
  late int responseStatus;
  Completer<void>? requestGate;

  setUp(() {
    requests = [];
    responseBody = _session();
    responseStatus = 200;
    requestGate = null;
    httpClient = MockClient((request) async {
      requests.add(request);
      if (requestGate != null) await requestGate!.future;
      // Any unexpected route fails locally. No real network client is created.
      expect(request.url.host, 'account-test.example.invalid');
      expect(request.method, 'POST');
      expect(request.url.path, anyOf('/auth/v1/signup', '/auth/v1/token'));
      return http.Response(
        jsonEncode(responseBody),
        responseStatus,
        headers: {
          'content-type': 'application/json',
          'x-supabase-api-version': '2024-01-01',
        },
      );
    });
    auth = GoTrueClient(
      url: 'https://account-test.example.invalid/auth/v1',
      autoRefreshToken: false,
      httpClient: httpClient,
      asyncStorage: _MemoryStorage(),
    );
    service = AccountAuthService(auth);
  });

  tearDown(() {
    auth.dispose();
    httpClient.close();
  });

  test('starts signed out without anonymous sign-in or any request', () {
    expect(service.status, AccountAuthStatus.signedOut);
    expect(requests, isEmpty);
  });

  for (final email in ['', 'missing-at', 'person@', 'a b@example.invalid']) {
    test('invalid email is refused before any request: $email', () async {
      await expectLater(
        service.signUp(email: email, password: 'fictional password'),
        throwsA(
          isA<AccountAuthException>().having(
            (e) => e.failure,
            'failure',
            AccountAuthFailure.invalidInput,
          ),
        ),
      );
      expect(requests, isEmpty);
    });
  }

  test('empty password is refused before any request', () async {
    await expectLater(
      service.signIn(email: 'farmer@example.invalid', password: ''),
      throwsA(isA<AccountAuthException>()),
    );
    expect(requests, isEmpty);
  });

  test('signup without a session requires email verification', () async {
    responseBody = _user(confirmed: false);
    expect(
      await service.signUp(
        email: ' farmer@example.invalid ',
        password: ' keep exact spaces ',
      ),
      AccountAuthStatus.verificationRequired,
    );
    expect(service.status, AccountAuthStatus.signedOut);
    expect(requests, hasLength(1));
    expect(requests.single.url.path, '/auth/v1/signup');
    final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
    expect(body['email'], 'farmer@example.invalid');
    expect(body['password'], ' keep exact spaces ');
    expect(body.containsKey('role'), isFalse);
    expect(body.containsKey('controller_id'), isFalse);
  });

  test('confirmed session can sign in without installation approval', () async {
    expect(
      await service.signIn(
        email: 'farmer@example.invalid',
        password: 'fictional password',
      ),
      AccountAuthStatus.signedIn,
    );
    expect(service.status, AccountAuthStatus.signedIn);
    expect(requests, hasLength(1));
    expect(requests.single.url.queryParameters['grant_type'], 'password');
    // No PostgREST/assignment/RPC or hardware operations are part of login.
    expect(requests.single.url.path, '/auth/v1/token');
  });

  test('unverified response cannot grant signed-in status', () async {
    responseBody = _session(confirmed: false);
    await expectLater(
      service.signIn(
        email: 'farmer@example.invalid',
        password: 'fictional password',
      ),
      throwsA(
        isA<AccountAuthException>().having(
          (e) => e.failure,
          'failure',
          AccountAuthFailure.verificationRequired,
        ),
      ),
    );
    expect(service.status, AccountAuthStatus.verificationRequired);
  });

  test('anonymous response is not accepted as an ordinary account', () async {
    responseBody = _session(anonymous: true);
    await expectLater(
      service.signIn(
        email: 'farmer@example.invalid',
        password: 'fictional password',
      ),
      throwsA(isA<AccountAuthException>()),
    );
    expect(service.status, AccountAuthStatus.signedOut);
  });

  test('signup session still needs confirmed email evidence', () async {
    responseBody = _session(confirmed: false);
    expect(
      await service.signUp(
        email: 'farmer@example.invalid',
        password: 'fictional password',
      ),
      AccountAuthStatus.verificationRequired,
    );
  });

  test('null user signup response is not a success', () async {
    responseBody = {};
    await expectLater(
      service.signUp(
        email: 'farmer@example.invalid',
        password: 'fictional password',
      ),
      throwsA(isA<AccountAuthException>()),
    );
  });

  for (final operation in ['signup', 'signin']) {
    test('$operation cannot silently replace an existing account', () async {
      await service.signIn(
        email: 'farmer@example.invalid',
        password: 'fictional password',
      );
      final attempt = operation == 'signup'
          ? service.signUp(email: 'another@example.invalid', password: 'secret')
          : service.signIn(
              email: 'another@example.invalid',
              password: 'secret',
            );
      await expectLater(attempt, throwsA(isA<AccountAuthException>()));
      expect(requests, hasLength(1));
    });
  }

  test('provider verification error becomes safe feedback', () async {
    responseStatus = 400;
    responseBody = {
      'code': 'email_not_confirmed',
      'msg': 'provider details must not reach the UI',
    };
    await expectLater(
      service.signIn(email: 'farmer@example.invalid', password: 'secret'),
      throwsA(
        isA<AccountAuthException>()
            .having(
              (e) => e.failure,
              'failure',
              AccountAuthFailure.verificationRequired,
            )
            .having(
              (e) => e.toString(),
              'message',
              isNot(contains('provider details')),
            ),
      ),
    );
  });

  test('provider rejection never exposes response contents', () async {
    responseStatus = 400;
    responseBody = {
      'code': 'invalid_credentials',
      'msg': 'sensitive-provider-debug-text',
    };
    await expectLater(
      service.signIn(email: 'farmer@example.invalid', password: 'secret'),
      throwsA(
        isA<AccountAuthException>()
            .having((e) => e.failure, 'failure', AccountAuthFailure.rejected)
            .having(
              (e) => e.toString(),
              'message',
              isNot(contains('sensitive')),
            ),
      ),
    );
    expect(service.status, AccountAuthStatus.signedOut);
  });

  test(
    'pending login prevents concurrent signup/account replacement',
    () async {
      requestGate = Completer<void>();
      final login = service.signIn(
        email: 'farmer@example.invalid',
        password: 'fictional password',
      );
      await expectLater(
        service.signUp(email: 'another@example.invalid', password: 'secret'),
        throwsA(isA<AccountAuthException>()),
      );
      requestGate!.complete();
      expect(await login, AccountAuthStatus.signedIn);
      expect(requests, hasLength(1));
    },
  );

  test(
    'failed request releases the pending guard for deliberate retry',
    () async {
      responseStatus = 400;
      responseBody = {'code': 'invalid_credentials', 'msg': 'Invalid login'};
      await expectLater(
        service.signIn(email: 'farmer@example.invalid', password: 'secret'),
        throwsA(isA<AccountAuthException>()),
      );
      responseStatus = 200;
      responseBody = _session();
      expect(
        await service.signIn(
          email: 'farmer@example.invalid',
          password: 'fictional password',
        ),
        AccountAuthStatus.signedIn,
      );
      expect(requests, hasLength(2));
    },
  );

  test('expired response does not establish signed-in status', () async {
    responseBody = _session(expiresIn: -3600);
    await expectLater(
      service.signIn(email: 'farmer@example.invalid', password: 'secret'),
      throwsA(isA<AccountAuthException>()),
    );
    expect(service.status, AccountAuthStatus.signedOut);
  });

  test('unparseable expiry does not establish signed-in status', () async {
    responseBody = _session()..['access_token'] = 'not-a-jwt';
    await expectLater(
      service.signIn(email: 'farmer@example.invalid', password: 'secret'),
      throwsA(isA<AccountAuthException>()),
    );
    expect(service.status, AccountAuthStatus.signedOut);
  });
}
