import 'dart:async';

import 'package:egg_incubator_app/screens/auth/account_access_screen.dart';
import 'package:egg_incubator_app/screens/startup/auth_gate.dart';
import 'package:egg_incubator_app/services/account_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Local fake of the account port. No provider, token or network use.
class _FakeAuthenticator implements AccountAuthenticator {
  _FakeAuthenticator(this._status);

  AccountAuthStatus _status;
  final _controller = StreamController<AccountAuthStatus>.broadcast();
  final List<String> calls = [];

  void emit(AccountAuthStatus status) {
    _status = status;
    _controller.add(status);
  }

  @override
  AccountAuthStatus get status => _status;

  @override
  Stream<AccountAuthStatus> get statusChanges => _controller.stream;

  @override
  Future<AccountAuthStatus> signIn({
    required String email,
    required String password,
  }) async {
    calls.add('signIn');
    emit(AccountAuthStatus.signedIn);
    return _status;
  }

  @override
  Future<AccountAuthStatus> signUp({
    required String email,
    required String password,
  }) async {
    calls.add('signUp');
    emit(AccountAuthStatus.verificationRequired);
    return _status;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    emit(AccountAuthStatus.signedOut);
  }

  Future<void> close() => _controller.close();
}

Widget _wrap(_FakeAuthenticator auth) => MaterialApp(
  home: AuthGate(
    authenticator: auth,
    child: const Scaffold(body: Text('APP WORKSPACE')),
  ),
);

void main() {
  testWidgets('a signed-out session sees the account screen, not the app', (
    tester,
  ) async {
    final auth = _FakeAuthenticator(AccountAuthStatus.signedOut);
    addTearDown(auth.close);

    await tester.pumpWidget(_wrap(auth));
    await tester.pumpAndSettle();

    expect(find.byType(AccountAccessScreen), findsOneWidget);
    expect(find.text('APP WORKSPACE'), findsNothing);
    expect(auth.calls, isEmpty);
  });

  testWidgets('an already verified session opens the app directly', (
    tester,
  ) async {
    final auth = _FakeAuthenticator(AccountAuthStatus.signedIn);
    addTearDown(auth.close);

    await tester.pumpWidget(_wrap(auth));
    await tester.pumpAndSettle();

    expect(find.text('APP WORKSPACE'), findsOneWidget);
    expect(find.byType(AccountAccessScreen), findsNothing);
  });

  testWidgets('signing in moves from the gate into the app', (tester) async {
    final auth = _FakeAuthenticator(AccountAuthStatus.signedOut);
    addTearDown(auth.close);

    await tester.pumpWidget(_wrap(auth));
    await tester.pumpAndSettle();
    expect(find.byType(AccountAccessScreen), findsOneWidget);

    auth.emit(AccountAuthStatus.signedIn);
    await tester.pumpAndSettle();

    expect(find.text('APP WORKSPACE'), findsOneWidget);
    expect(find.byType(AccountAccessScreen), findsNothing);
  });

  testWidgets('an unverified account stays at the gate', (tester) async {
    final auth = _FakeAuthenticator(AccountAuthStatus.verificationRequired);
    addTearDown(auth.close);

    await tester.pumpWidget(_wrap(auth));
    await tester.pumpAndSettle();

    expect(find.byType(AccountAccessScreen), findsOneWidget);
    expect(find.text('APP WORKSPACE'), findsNothing);
  });

  testWidgets('signing out returns to the gate', (tester) async {
    final auth = _FakeAuthenticator(AccountAuthStatus.signedIn);
    addTearDown(auth.close);

    await tester.pumpWidget(_wrap(auth));
    await tester.pumpAndSettle();
    expect(find.text('APP WORKSPACE'), findsOneWidget);

    await auth.signOut();
    await tester.pumpAndSettle();

    expect(find.byType(AccountAccessScreen), findsOneWidget);
    expect(find.text('APP WORKSPACE'), findsNothing);
  });

  testWidgets('disposing the gate cancels its session subscription', (
    tester,
  ) async {
    final auth = _FakeAuthenticator(AccountAuthStatus.signedOut);

    await tester.pumpWidget(_wrap(auth));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    // Emitting after disposal must not throw or rebuild a dead tree.
    auth.emit(AccountAuthStatus.signedIn);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await auth.close();
  });
}
