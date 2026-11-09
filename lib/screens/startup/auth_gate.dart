import 'dart:async';

import 'package:flutter/material.dart';
import 'package:egg_incubator_app/screens/auth/account_access_screen.dart';
import 'package:egg_incubator_app/services/account_auth_service.dart';

/// Requires a verified account before the app's records are reachable.
///
/// The public landing page stays outside this gate. Signing in is a local
/// session change only: it never starts incubation, assigns records or connects
/// to hardware, and a role or assignment is still enforced by the server.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.authenticator, required this.child});

  final AccountAuthenticator authenticator;

  /// Shown only when the local session is a verified, non-anonymous account.
  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AccountAuthStatus _status = AccountAuthStatus.signedOut;
  StreamSubscription<AccountAuthStatus>? _subscription;

  @override
  void initState() {
    super.initState();
    _status = widget.authenticator.status;
    _subscription = widget.authenticator.statusChanges.listen((status) {
      if (!mounted || status == _status) return;
      setState(() => _status = status);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == AccountAuthStatus.signedIn) return widget.child;
    return AccountAccessScreen(authenticator: widget.authenticator);
  }
}
