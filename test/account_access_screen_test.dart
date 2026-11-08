import 'package:egg_incubator_app/screens/auth/account_access_screen.dart';
import 'package:egg_incubator_app/services/account_auth_service.dart';
import 'package:egg_incubator_app/widgets/common/farmer_notice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Local fake of the narrow account port. No provider, token or network use.
class _FakeAuthenticator implements AccountAuthenticator {
  _FakeAuthenticator({this.failure});

  final AccountAuthException? failure;

  final List<String> calls = [];
  final List<String> emails = [];

  @override
  AccountAuthStatus get status => AccountAuthStatus.signedOut;

  @override
  Stream<AccountAuthStatus> get statusChanges => const Stream.empty();

  @override
  Future<void> signOut() async {}

  @override
  Future<AccountAuthStatus> signIn({
    required String email,
    required String password,
  }) async {
    calls.add('signIn');
    emails.add(email);
    if (failure != null) throw failure!;
    return AccountAuthStatus.signedIn;
  }

  @override
  Future<AccountAuthStatus> signUp({
    required String email,
    required String password,
  }) async {
    calls.add('signUp');
    emails.add(email);
    if (failure != null) throw failure!;
    return AccountAuthStatus.verificationRequired;
  }
}

Future<void> _pump(
  WidgetTester tester,
  AccountAuthenticator authenticator, {
  VoidCallback? onSignedIn,
  double width = 390,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    MaterialApp(
      home: AccountAccessScreen(
        authenticator: authenticator,
        onSignedIn: onSignedIn,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  String email = 'farmer@example.invalid',
  String password = 'correct horse battery',
  String? confirm,
}) async {
  await tester.enterText(find.byKey(const Key('account-email')), email);
  await tester.enterText(find.byKey(const Key('account-password')), password);
  if (confirm != null) {
    await tester.enterText(find.byKey(const Key('account-confirm')), confirm);
  }
  await tester.tap(find.byKey(const Key('account-submit')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'signs in with trimmed email and confirms without claiming access',
    (tester) async {
      final auth = _FakeAuthenticator();
      var signedInCalls = 0;
      await _pump(tester, auth, onSignedIn: () => signedInCalls++);

      await _fillAndSubmit(tester, email: '  farmer@example.invalid  ');

      expect(auth.calls, ['signIn']);
      expect(auth.emails.single, '  farmer@example.invalid  ');
      expect(signedInCalls, 1);
      expect(find.text('Signed in'), findsOneWidget);
      expect(find.textContaining('team assigns them'), findsOneWidget);
      // Signing in must not imply a running or connected incubator.
      expect(find.textContaining('does not start incubation'), findsOneWidget);
    },
  );

  testWidgets('sign-up requires matching confirmation before any request', (
    tester,
  ) async {
    final auth = _FakeAuthenticator();
    await _pump(tester, auth);
    await tester.tap(find.byKey(const Key('account-switch-mode')));
    await tester.pumpAndSettle();

    await _fillAndSubmit(
      tester,
      password: 'correct horse battery',
      confirm: 'different password',
    );

    expect(auth.calls, isEmpty);
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('sign-up shows the verification step and does not sign in', (
    tester,
  ) async {
    final auth = _FakeAuthenticator();
    var signedInCalls = 0;
    await _pump(tester, auth, onSignedIn: () => signedInCalls++);
    await tester.tap(find.byKey(const Key('account-switch-mode')));
    await tester.pumpAndSettle();

    await _fillAndSubmit(tester, confirm: 'correct horse battery');

    expect(auth.calls, ['signUp']);
    expect(signedInCalls, 0);
    expect(find.text('Verify your email'), findsOneWidget);
  });

  testWidgets(
    'provider failure shows safe wording and never echoes the password',
    (tester) async {
      final auth = _FakeAuthenticator(
        failure: const AccountAuthException(AccountAuthFailure.rejected),
      );
      await _pump(tester, auth);

      await _fillAndSubmit(tester, password: 'secret-value-123');

      expect(find.text('Sign-in was not completed'), findsOneWidget);
      expect(
        find.text(
          'We could not complete that request. Check your details and try again.',
        ),
        findsOneWidget,
      );
      // The typed value stays in its own obscured field; no notice repeats it.
      expect(
        find.descendant(
          of: find.byType(FarmerNoticeCard),
          matching: find.textContaining('secret-value-123'),
        ),
        findsNothing,
      );
    },
  );
  testWidgets('unavailable service keeps the farmer informed', (tester) async {
    final auth = _FakeAuthenticator(
      failure: const AccountAuthException(AccountAuthFailure.unavailable),
    );
    await _pump(tester, auth);

    await _fillAndSubmit(tester);

    expect(
      find.text('The account service is unavailable. Please try again later.'),
      findsOneWidget,
    );
  });

  for (final (width, scale) in [(320.0, 1.0), (320.0, 2.0), (390.0, 1.0)]) {
    testWidgets('sign-up form renders without overflow at $width / $scale x', (
      tester,
    ) async {
      final auth = _FakeAuthenticator();
      await _pump(tester, auth, width: width, scale: scale);
      await tester.ensureVisible(find.byKey(const Key('account-switch-mode')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('account-switch-mode')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.byKey(const Key('account-confirm')), findsOneWidget);
    });
  }
}
