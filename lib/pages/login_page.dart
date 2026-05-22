import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/ambient_background.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, required this.onLogin, required this.onSkip});

  final VoidCallback onLogin;
  final VoidCallback onSkip;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  _LoginAction? _submittingAction;
  String? _errorText;

  bool get _isSubmitting => _submittingAction != null;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin(_LoginAction action) async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _submittingAction = action;
      _errorText = null;
    });

    try {
      if (action == _LoginAction.password) {
        await ref.read(authServiceProvider).signInWithEmail(
              email: _emailController.text,
              password: _passwordController.text,
            );
      } else {
        final user = await ref.read(authServiceProvider).signInWithGoogle();
        if (user == null) {
          // User cancelled
          if (mounted) {
            setState(() {
              _submittingAction = null;
            });
          }
          return;
        }
      }

      if (!mounted) return;
      widget.onLogin();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _submittingAction = null;
      });
    }
  }

  void _skipLogin() {
    if (_isSubmitting) {
      return;
    }
    FocusScope.of(context).unfocus();
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(
            colors: [AetherisColors.deepMidnight, AetherisColors.background],
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.graphic_eq_rounded,
                          size: 64,
                          color: AetherisColors.textPrimary,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Log in to Aetheris',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AetherisColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Email Field
                        Container(
                          decoration: BoxDecoration(
                            color: AetherisColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            enabled: !_isSubmitting,
                            style: const TextStyle(
                              color: AetherisColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                color: AetherisColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: AetherisColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            enabled: !_isSubmitting,
                            onSubmitted:
                                (_) => _submitLogin(_LoginAction.password),
                            style: const TextStyle(
                              color: AetherisColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: AetherisColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_errorText != null) ...[
                          Text(
                            _errorText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AetherisColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Email sign-in
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AetherisColors.textPrimary,
                              foregroundColor: AetherisColors.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed:
                                _isSubmitting
                                    ? null
                                    : () => _submitLogin(_LoginAction.password),
                            child:
                                _submittingAction == _LoginAction.password
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.12),
                                height: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: AetherisColors.textSecondary
                                      .withValues(alpha: 0.78),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.12),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google sign-in
                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AetherisColors.textPrimary,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.06,
                              ),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.16),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed:
                                _isSubmitting
                                    ? null
                                    : () => _submitLogin(_LoginAction.google),
                            child:
                                _submittingAction == _LoginAction.google
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _GoogleGlyph(),
                                        SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            'Login with Google',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Skip Button
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AetherisColors.textSecondary,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _skipLogin,
                            child: const Text(
                              'Skip (Offline Mode)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _LoginAction { password, google }

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
