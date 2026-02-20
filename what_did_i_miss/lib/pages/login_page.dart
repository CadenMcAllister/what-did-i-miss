import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/routes.dart';
import '../theme/app_colors.dart';
import '../widgets/login_form.dart';
import '../widgets/snackbars.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isSigningUp = false;
  bool _isLoggingIn = false;
  bool _isResettingPassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showAppSnackBar(context, 'Email and password are required.',
          tone: SnackBarTone.warning);
      return;
    }

    setState(() {
      _isSigningUp = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (response.session != null) {
        showAppSnackBar(context, 'Account created successfully.',
            tone: SnackBarTone.success);
        return;
      }
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (!mounted) return;
        showAppSnackBar(context, 'Account already exists, please log in.',
            tone: SnackBarTone.warning);
        return;
      } on AuthException {
        if (!mounted) return;
      }
      showAppSnackBar(context, 'Check your email to confirm your account.',
          tone: SnackBarTone.info);
    } on AuthException catch (error) {
      if (!mounted) return;
      final message = error.message.toLowerCase();
      if (error.statusCode == '409' ||
          message.contains('already registered') ||
          message.contains('already exists') ||
          message.contains('duplicate')) {
        showAppSnackBar(context, 'That account already exists.',
            tone: SnackBarTone.warning);
        return;
      }
      showAppSnackBar(context, error.message, tone: SnackBarTone.error);
    } catch (e, st) {
      if (!mounted) return;
      final message = e is Exception ? e.toString() : 'Something went wrong. Please try again.';
      showAppSnackBar(context, message, tone: SnackBarTone.error);
      assert(() {
        debugPrintStack(stackTrace: st, label: 'SignUp error');
        return true;
      }());
    } finally {
      if (mounted) {
        setState(() {
          _isSigningUp = false;
        });
      }
    }
  }

  Future<void> _signIn() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      showAppSnackBar(context, 'Email and password are required.',
          tone: SnackBarTone.warning);
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      showAppSnackBar(context, 'Logged in successfully.',
          tone: SnackBarTone.success);
    } on AuthException catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.message, tone: SnackBarTone.error);
    } catch (e, st) {
      if (!mounted) return;
      final message = e is Exception ? e.toString() : 'Something went wrong. Please try again.';
      showAppSnackBar(context, message, tone: SnackBarTone.error);
      assert(() {
        debugPrintStack(stackTrace: st, label: 'SignIn error');
        return true;
      }());
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _loginEmailController.text.trim();

    if (email.isEmpty) {
      showAppSnackBar(context, 'Enter your email to reset your password.',
          tone: SnackBarTone.warning);
      return;
    }

    setState(() {
      _isResettingPassword = true;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      showAppSnackBar(context, 'Password reset email sent.',
          tone: SnackBarTone.success);
    } on AuthException catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.message, tone: SnackBarTone.error);
    } catch (e, st) {
      if (!mounted) return;
      final message = e is Exception ? e.toString() : 'Something went wrong. Please try again.';
      showAppSnackBar(context, message, tone: SnackBarTone.error);
      assert(() {
        debugPrintStack(stackTrace: st, label: 'Password reset error');
        return true;
      }());
    } finally {
      if (mounted) {
        setState(() {
          _isResettingPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.of(context).secondaryBackground,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: 230,
              margin: const EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'What Did I Miss?',
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).primaryText,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 600,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppColors.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.of(context).primaryBackground, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TabBar(
                    dividerColor: AppColors.of(context).tertiary,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.only(top: 12),
                    tabAlignment: TabAlignment.center,
                    tabs: const [
                      Tab(child: Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                      Tab(child: Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  color: AppColors.of(context).primaryText,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 24),
                                child: Text(
                                  'Let\'s get started by filling out the form below.',
                                  style: TextStyle(
                                    color: AppColors.of(context).secondaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: LoginEmailField(controller: _emailController),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: LoginPasswordField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              LoginPrimaryButton(
                                label: 'Create Account',
                                onPressed: _signUp,
                                isLoading: _isSigningUp,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  color: AppColors.of(context).primaryText,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 24),
                                child: Text(
                                  'Welcome back. Enter your credentials to continue.',
                                  style: TextStyle(
                                    color: AppColors.of(context).secondaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: LoginEmailField(controller: _loginEmailController),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: LoginPasswordField(
                                  controller: _loginPasswordController,
                                  obscureText: _obscurePassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              LoginPrimaryButton(
                                label: 'Log In',
                                onPressed: _signIn,
                                isLoading: _isLoggingIn,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: _isResettingPassword ? null : _sendPasswordReset,
                                    child: _isResettingPassword
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text('Forgot password?'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
