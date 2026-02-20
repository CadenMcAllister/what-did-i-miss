import 'package:flutter/material.dart';

class LightAppColors {
  static const primary = Color(0xFF4A90E2);
  static const secondary = Color(0xFF6A7BA2);
  static const tertiary = Color(0xFFA6B8E0);
  static const alternate = Color(0xFFECEFF4);
  static const primaryText = Color(0xFF455369);
  static const secondaryText = Color(0xFF6B7280);
  static const primaryBackground = Color(0xFFF8FAFC);
  static const secondaryBackground = Color(0xFFE5EAF0);
  static const accent1 = Color(0xFFFFAD5A);
  static const accent2 = Color(0xFF57D8A4);
  static const accent3 = Color(0xFF7F5AF0);
  static const accent4 = Color(0xFFFFD166);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
}

class DarkAppColors {
  static const primary = Color(0xFF60A5FA);
  static const secondary = Color(0xFF9CA3AF);
  static const tertiary = Color(0xFF3B3F54);
  static const alternate = Color(0xFF111827);
  static const primaryText = Color(0xFFF9FAFB);
  static const secondaryText = Color(0xFFD1D5DB);
  static const primaryBackground = Color(0xFF111827);
  static const secondaryBackground = Color(0xFF1E2533);
  static const accent1 = Color(0xFFFDBA74);
  static const accent2 = Color(0xFF34D399);
  static const accent3 = Color(0xFFC084FC);
  static const accent4 = Color(0xFFFCD34D);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFF87171);
  static const warning = Color(0xFFFBBF24);
  static const info = Color(0xFF60A5FA);
}

/// Theme-aware color palette. Use [AppColors.of(context)] in build methods.
class AppColors {
  const AppColors._({
    required this.primary,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.tertiary,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });

  final Color primary;
  final Color primaryText;
  final Color secondaryText;
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color tertiary;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.light) {
      return const AppColors._(
        primary: LightAppColors.primary,
        primaryText: LightAppColors.primaryText,
        secondaryText: LightAppColors.secondaryText,
        primaryBackground: LightAppColors.primaryBackground,
        secondaryBackground: LightAppColors.secondaryBackground,
        tertiary: LightAppColors.tertiary,
        success: LightAppColors.success,
        error: LightAppColors.error,
        warning: LightAppColors.warning,
        info: LightAppColors.info,
      );
    } else {
      return const AppColors._(
        primary: DarkAppColors.primary,
        primaryText: DarkAppColors.primaryText,
        secondaryText: DarkAppColors.secondaryText,
        primaryBackground: DarkAppColors.primaryBackground,
        secondaryBackground: DarkAppColors.secondaryBackground,
        tertiary: DarkAppColors.tertiary,
        success: DarkAppColors.success,
        error: DarkAppColors.error,
        warning: DarkAppColors.warning,
        info: DarkAppColors.info,
      );
    }
  }
}