import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication only: this never grants record, admin or controller access.
enum AccountAuthStatus { signedOut, verificationRequired, signedIn }

enum AccountAuthFailure {
  invalidInput,
  verificationRequired,
  rejected,
  unavailable,
}

/// Safe UI feedback without exposing provider responses, passwords or tokens.
class AccountAuthException implements Exception {
  const AccountAuthException(this.failure);

  final AccountAuthFailure failure;

  String get message => switch (failure) {
    AccountAuthFailure.invalidInput =>
      'Enter a valid email address and your password.',
    AccountAuthFailure.verificationRequired =>
      'Verify your email before signing in.',
    AccountAuthFailure.rejected =>
      'We could not complete that request. Check your details and try again.',
    AccountAuthFailure.unavailable =>
      'The account service is unavailable. Please try again later.',
  };

  @override
  String toString() => message;
}

/// The account operations the sign-in UI may call.
///
/// Screens depend on this narrow port so widget tests can exercise the flow
/// without a provider client, tokens or network access. It grants no record,
/// admin or controller access.
abstract interface class AccountAuthenticator {
  AccountAuthStatus get status;

  /// Emits whenever the local session changes, including sign-out.
  Stream<AccountAuthStatus> get statusChanges;

  Future<AccountAuthStatus> signUp({
    required String email,
    required String password,
  });

  Future<AccountAuthStatus> signIn({
    required String email,
    required String password,
  });

  /// Ends the local session. This is not a hardware or batch action.
  Future<void> signOut();
}

/// UI-independent implementation of the approved email/password account flow.
///
/// Inject `Supabase.instance.client.auth` after approved environment setup.
/// The caller owns the client, persistence and subscription lifecycle. This
/// service is deliberately not wired into existing startup/screens while their
/// UI is being revised. It neither signs in anonymously nor assigns records.
/// Hosted email confirmation, redirect configuration, RLS and Android callbacks
/// still require separate environment/integration verification.
class AccountAuthService implements AccountAuthenticator {
  AccountAuthService(this._auth);

  final GoTrueClient _auth;
  bool _requestPending = false;

  /// Local session changes only; never a server authorization signal.
  @override
  Stream<AccountAuthStatus> get statusChanges =>
      _auth.onAuthStateChange.map((_) => status).distinct();

  @override
  Future<void> signOut() => _auth.signOut();

  /// Local session evidence only, not a server authorization or hardware gate.
  @override
  AccountAuthStatus get status {
    final session = _auth.currentSession;
    final user = session?.user;
    if (session == null ||
        session.expiresAt == null ||
        session.isExpired ||
        user == null ||
        user.isAnonymous) {
      return AccountAuthStatus.signedOut;
    }
    if (user.email == null || user.email!.trim().isEmpty) {
      return AccountAuthStatus.signedOut;
    }
    return user.emailConfirmedAt?.isNotEmpty == true
        ? AccountAuthStatus.signedIn
        : AccountAuthStatus.verificationRequired;
  }

  /// No client-selected role, incubator assignment or account conversion.
  /// An existing session must be explicitly handled before creating an account.
  @override
  Future<AccountAuthStatus> signUp({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _validate(email, password);
    if (_requestPending || _auth.currentSession != null) {
      throw const AccountAuthException(AccountAuthFailure.rejected);
    }
    _requestPending = true;
    try {
      final response = await _auth.signUp(
        email: normalizedEmail,
        password: password,
      );
      if (response.user == null) {
        throw const AccountAuthException(AccountAuthFailure.unavailable);
      }
      // A signup response alone is never a verified signed-in session. The
      // provider may return an obfuscated user for an existing email address.
      return status == AccountAuthStatus.signedIn
          ? AccountAuthStatus.signedIn
          : AccountAuthStatus.verificationRequired;
    } on AuthException catch (error) {
      throw _safeFailure(error);
    } on AccountAuthException {
      rethrow;
    } catch (_) {
      throw const AccountAuthException(AccountAuthFailure.unavailable);
    } finally {
      _requestPending = false;
    }
  }

  @override
  Future<AccountAuthStatus> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _validate(email, password);
    // Account switches need an explicit protected-logout flow first. Do not
    // silently replace an anonymous or another user's existing session.
    if (_requestPending || _auth.currentSession != null) {
      throw const AccountAuthException(AccountAuthFailure.rejected);
    }
    _requestPending = true;
    try {
      await _auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      final result = status;
      if (result == AccountAuthStatus.verificationRequired) {
        throw const AccountAuthException(
          AccountAuthFailure.verificationRequired,
        );
      }
      if (result != AccountAuthStatus.signedIn) {
        throw const AccountAuthException(AccountAuthFailure.unavailable);
      }
      return result;
    } on AuthException catch (error) {
      throw _safeFailure(error);
    } on AccountAuthException {
      rethrow;
    } catch (_) {
      throw const AccountAuthException(AccountAuthFailure.unavailable);
    } finally {
      _requestPending = false;
    }
  }

  static String _validate(String email, String password) {
    final normalizedEmail = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalizedEmail) ||
        password.isEmpty) {
      throw const AccountAuthException(AccountAuthFailure.invalidInput);
    }
    // Passwords are not trimmed, logged, retained or assigned a guessed policy.
    // Actual strength/rate limits are enforced by the configured provider.
    return normalizedEmail;
  }

  static AccountAuthException _safeFailure(AuthException error) {
    if (error.code == 'email_not_confirmed') {
      return const AccountAuthException(
        AccountAuthFailure.verificationRequired,
      );
    }
    final statusCode = int.tryParse(error.statusCode ?? '');
    if (error is AuthRetryableFetchException ||
        statusCode == null ||
        statusCode >= 500) {
      return const AccountAuthException(AccountAuthFailure.unavailable);
    }
    return const AccountAuthException(AccountAuthFailure.rejected);
  }
}
