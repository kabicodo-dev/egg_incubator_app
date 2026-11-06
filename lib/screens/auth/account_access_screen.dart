import 'package:flutter/material.dart';
import 'package:egg_incubator_app/models/farmer_notice.dart';
import 'package:egg_incubator_app/services/account_auth_service.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/widgets/common/farmer_notice_card.dart';

// ══════════════════════════════════════════════
// ACCOUNT ACCESS SCREEN
// ══════════════════════════════════════════════

/// Email/password sign-in and sign-up for the approved account flow.
///
/// This screen is intentionally **not** wired into startup yet: hosted email
/// confirmation, redirect configuration and Android callbacks still need
/// verification. Signing in never assigns incubator records, starts incubation
/// or connects to hardware.
class AccountAccessScreen extends StatefulWidget {
  const AccountAccessScreen({
    super.key,
    required this.authenticator,
    this.onSignedIn,
  });

  final AccountAuthenticator authenticator;
  final VoidCallback? onSignedIn;

  @override
  State<AccountAccessScreen> createState() => _AccountAccessScreenState();
}

enum _AccessMode { signIn, signUp }

class _AccountAccessScreenState extends State<AccountAccessScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  _AccessMode _mode = _AccessMode.signIn;
  bool _obscurePassword = true;
  bool _submitting = false;
  FarmerNotice? _notice;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isSignUp => _mode == _AccessMode.signUp;

  void _switchMode(_AccessMode mode) {
    if (_submitting || mode == _mode) return;
    setState(() {
      _mode = mode;
      _notice = null;
      _confirmController.clear();
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;

    if (_isSignUp && _passwordController.text != _confirmController.text) {
      setState(
        () => _notice = const FarmerNotice(
          title: 'Passwords do not match',
          message: 'Re-enter the same password in both fields.',
          tone: FarmerNoticeTone.warning,
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _notice = null;
    });

    try {
      final result = _isSignUp
          ? await widget.authenticator.signUp(
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await widget.authenticator.signIn(
              email: _emailController.text,
              password: _passwordController.text,
            );
      if (!mounted) return;

      if (result == AccountAuthStatus.verificationRequired) {
        setState(() {
          _submitting = false;
          _notice = const FarmerNotice(
            title: 'Verify your email',
            message:
                'Open the verification link we sent to your email address, '
                'then come back and sign in.',
            tone: FarmerNoticeTone.information,
          );
        });
        return;
      }

      setState(() {
        _submitting = false;
        _notice = const FarmerNotice(
          title: 'Signed in',
          message:
              'Your account is ready. Incubator records appear only after the '
              'team assigns them to this account.',
          tone: FarmerNoticeTone.success,
        );
        _passwordController.clear();
        _confirmController.clear();
      });
      widget.onSignedIn?.call();
    } on AccountAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _notice = FarmerNotice(
          title: _isSignUp
              ? 'Account was not created'
              : 'Sign-in was not completed',
          message: error.message,
          tone: FarmerNoticeTone.error,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _notice = const FarmerNotice(
          title: 'Account service unavailable',
          message: 'Please check your connection and try again.',
          tone: FarmerNoticeTone.error,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionLabel = _isSignUp ? 'Create account' : 'Sign in';

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SmartHatch account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? 'Create an account with your email address. The team '
                              'assigns your incubator records afterwards.'
                        : 'Sign in to see the incubator records assigned to '
                              'your account.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_notice != null) ...[
                    FarmerNoticeCard(notice: _notice!),
                    const SizedBox(height: 20),
                  ],
                  TextField(
                    key: const Key('account-email'),
                    controller: _emailController,
                    enabled: !_submitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: _decoration(
                      label: 'Email address',
                      icon: Icons.mail_outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('account-password'),
                    controller: _passwordController,
                    enabled: !_submitting,
                    obscureText: _obscurePassword,
                    textInputAction: _isSignUp
                        ? TextInputAction.next
                        : TextInputAction.done,
                    autofillHints: [
                      _isSignUp
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    onSubmitted: (_) {
                      if (!_isSignUp) _submit();
                    },
                    decoration:
                        _decoration(
                          label: 'Password',
                          icon: Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: _submitting
                                ? null
                                : () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                          ),
                        ),
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('account-confirm'),
                      controller: _confirmController,
                      enabled: !_submitting,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onSubmitted: (_) => _submit(),
                      decoration: _decoration(
                        label: 'Confirm password',
                        icon: Icons.lock_outline,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      key: const Key('account-submit'),
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        elevation: 2,
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              actionLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    key: const Key('account-switch-mode'),
                    onPressed: _submitting
                        ? null
                        : () => _switchMode(
                            _isSignUp ? _AccessMode.signIn : _AccessMode.signUp,
                          ),
                    child: Text(
                      _isSignUp
                          ? 'I already have an account'
                          : 'Create an account',
                      style: const TextStyle(
                        color: AppColors.primaryDarkPressed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Signing in does not start incubation, send commands or '
                    'connect to the incubator.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
