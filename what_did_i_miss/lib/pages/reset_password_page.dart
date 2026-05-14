import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/app_constants.dart';
import '../app/routes.dart';
import '../theme/app_colors.dart';
import '../widgets/login_form.dart';
import '../widgets/snackbars.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      showAppSnackBar(
        context,
        'Please enter and confirm your new password.',
        tone: SnackBarTone.warning,
      );
      return;
    }
    if (password != confirm) {
      showAppSnackBar(context, 'Passwords do not match.',
          tone: SnackBarTone.warning);
      return;
    }
    if (password.length < 6) {
      showAppSnackBar(context, 'Password must be at least 6 characters.',
          tone: SnackBarTone.warning);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      if (!mounted) return;
      showAppSnackBar(context, 'Password updated. Please sign in.',
          tone: SnackBarTone.success);
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.message, tone: SnackBarTone.error);
    } catch (e, st) {
      if (!mounted) return;
      showAppSnackBar(context, 'Something went wrong. Please try again.',
          tone: SnackBarTone.error);
      assert(() {
        debugPrintStack(stackTrace: st, label: 'Reset password error');
        return true;
      }());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxCard = constraints.maxWidth.clamp(0.0, 600.0);
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxCard),
                  child: Column(
                    children: [
                      _ResetBrandingHeader(colors: colors),
                      const SizedBox(height: 28),
                      _ResetFormCard(
                        colors: colors,
                        obscurePassword: _obscurePassword,
                        obscureConfirm: _obscureConfirm,
                        passwordController: _passwordController,
                        confirmController: _confirmController,
                        isSubmitting: _isSubmitting,
                        onTogglePassword: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        onToggleConfirm: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        onSubmit: _submit,
                        onBackToSignIn: _isSubmitting ? null : _goToLogin,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResetBrandingHeader extends StatelessWidget {
  const _ResetBrandingHeader({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primaryBackground, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          },
          child: Column(
            children: [
              Text(
                appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter Tight',
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryText,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the title anytime to return to sign in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: colors.secondaryText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetFormCard extends StatelessWidget {
  const _ResetFormCard({
    required this.colors,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.passwordController,
    required this.confirmController,
    required this.isSubmitting,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
    required this.onBackToSignIn,
  });

  final AppColors colors;
  final bool obscurePassword;
  final bool obscureConfirm;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool isSubmitting;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;
  final VoidCallback? onBackToSignIn;

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: colors.secondaryText,
        fontFamily: 'Inter',
      ),
      filled: true,
      fillColor: colors.primaryBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primaryBackground, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.tertiary.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    size: 28,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set a new password',
                        style: TextStyle(
                          fontFamily: 'Inter Tight',
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: colors.primaryText,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a strong password you have not used here before. You will sign in again after saving.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 1.45,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colors.primaryBackground.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.tertiary.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HintRow(
                    colors: colors,
                    icon: Icons.check_circle_outline_rounded,
                    text: 'At least 6 characters',
                  ),
                  const SizedBox(height: 6),
                  _HintRow(
                    colors: colors,
                    icon: Icons.verified_user_outlined,
                    text: 'Both fields must match exactly',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            LoginPasswordField(
              controller: passwordController,
              obscureText: obscurePassword,
              onToggleVisibility: onTogglePassword,
              decoration: _fieldDecoration('New password'),
              onSubmitted: (_) {
                if (!isSubmitting) FocusScope.of(context).nextFocus();
              },
            ),
            const SizedBox(height: 16),
            LoginPasswordField(
              controller: confirmController,
              obscureText: obscureConfirm,
              onToggleVisibility: onToggleConfirm,
              decoration: _fieldDecoration('Confirm new password'),
              onSubmitted: (_) {
                if (!isSubmitting) onSubmit();
              },
            ),
            const SizedBox(height: 28),
            LoginPrimaryButton(
              label: 'Update password',
              onPressed: onSubmit,
              isLoading: isSubmitting,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onBackToSignIn,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Back to sign in',
                  style: TextStyle(
                    fontFamily: 'Inter Tight',
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
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({
    required this.colors,
    required this.icon,
    required this.text,
  });

  final AppColors colors;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.35,
              color: colors.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
