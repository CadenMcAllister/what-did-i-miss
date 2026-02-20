import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Theme-aware email field for login/create account forms.
class LoginEmailField extends StatelessWidget {
  const LoginEmailField({
    super.key,
    required this.controller,
    this.decoration,
  });

  final TextEditingController controller;
  final InputDecoration? decoration;

  static InputDecoration _defaultDecoration(BuildContext context) {
    final colors = AppColors.of(context);
    return InputDecoration(
      labelText: 'Email',
      labelStyle: TextStyle(color: colors.secondaryText),
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
    final base = _defaultDecoration(context);
    final effective = decoration != null
        ? base.copyWith(
            labelText: decoration!.labelText ?? base.labelText,
            labelStyle: decoration!.labelStyle ?? base.labelStyle,
            fillColor: decoration!.fillColor ?? base.fillColor,
            filled: decoration!.filled ?? base.filled,
            border: decoration!.border ?? base.border,
          )
        : base;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: effective,
    );
  }
}

/// Theme-aware password field with visibility toggle.
class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.decoration,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final InputDecoration? decoration;

  static InputDecoration _defaultDecoration(
    BuildContext context, {
    required Widget suffixIcon,
  }) {
    final colors = AppColors.of(context);
    return InputDecoration(
      labelText: 'Password',
      labelStyle: TextStyle(color: colors.secondaryText),
      filled: true,
      fillColor: colors.primaryBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final suffixIcon = IconButton(
      onPressed: onToggleVisibility,
      icon: Icon(
        obscureText ? Icons.visibility_off : Icons.visibility,
        color: colors.secondaryText,
      ),
      tooltip: obscureText ? 'Show password' : 'Hide password',
    );
    final base = _defaultDecoration(context, suffixIcon: suffixIcon);
    final effective = decoration != null
        ? base.copyWith(
            labelText: decoration!.labelText ?? base.labelText,
            labelStyle: decoration!.labelStyle ?? base.labelStyle,
            fillColor: decoration!.fillColor ?? base.fillColor,
            filled: decoration!.filled ?? base.filled,
            border: decoration!.border ?? base.border,
          )
        : base;
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      obscureText: obscureText,
      decoration: effective,
    );
  }
}

/// Primary action button with optional loading state.
class LoginPrimaryButton extends StatelessWidget {
  const LoginPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.primaryText,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter Tight',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
