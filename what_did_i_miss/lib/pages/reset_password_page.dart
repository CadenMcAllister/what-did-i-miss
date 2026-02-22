import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      showAppSnackBar(context, 'Please enter and confirm your new password.',
          tone: SnackBarTone.warning);
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.secondaryBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Set new password',
                  style: TextStyle(
                    fontFamily: 'Inter Tight',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your new password below.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: 32),
                LoginPasswordField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  decoration: InputDecoration(
                    labelText: 'New password',
                    labelStyle: TextStyle(color: colors.secondaryText),
                    filled: true,
                    fillColor: colors.primaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LoginPasswordField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  onToggleVisibility: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  decoration: InputDecoration(
                    labelText: 'Confirm new password',
                    labelStyle: TextStyle(color: colors.secondaryText),
                    filled: true,
                    fillColor: colors.primaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                LoginPrimaryButton(
                  label: 'Update password',
                  onPressed: _submit,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          ),
                  child: Text(
                    'Back to sign in',
                    style: TextStyle(color: colors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
