import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../app/theme_mode_scope.dart';
import '../theme/app_colors.dart';
import 'account_app_bar_menu.dart';

/// App bar with the app name, light/dark toggle, and account menu.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      title: const Text(appName),
      backgroundColor: colors.tertiary,
      foregroundColor: colors.primaryText,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () {
            ThemeModeScope.of(
              context,
            ).setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
          },
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        ),
        const AccountAppBarMenu(),
      ],
    );
  }
}
