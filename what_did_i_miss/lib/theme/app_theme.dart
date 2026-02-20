import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
	static ThemeData get lightTheme {
		return ThemeData(
			useMaterial3: true,
			fontFamily: 'Inter Tight',
			colorScheme: const ColorScheme.light(
				primary: LightAppColors.primary,
				secondary: LightAppColors.secondary,
				tertiary: LightAppColors.tertiary,
				surface: LightAppColors.secondaryBackground,
				error: LightAppColors.error,
			),
		);
	}

	static ThemeData get darkTheme {
		return ThemeData(
			useMaterial3: true,
			fontFamily: 'Inter Tight',
			colorScheme: const ColorScheme.dark(
				primary: DarkAppColors.primary,
				secondary: DarkAppColors.secondary,
				tertiary: DarkAppColors.tertiary,
				surface: DarkAppColors.secondaryBackground,
				error: DarkAppColors.error,
			),
		);
	}
}
