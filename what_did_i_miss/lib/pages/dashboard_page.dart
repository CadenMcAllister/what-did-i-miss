import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/app_constants.dart';
import '../app/theme_mode_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/account_app_bar_menu.dart';
import '../widgets/route_aware_refresh.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final name = accountDisplayLabel(user);
    return RouteAwareRefresh(
      child: Scaffold(
        backgroundColor: colors.primaryBackground,
        appBar: AppBar(
          title: const Text(
            appName,
            style: TextStyle(fontFamily: 'Inter Tight'),
          ),
          backgroundColor: colors.tertiary,
          foregroundColor: colors.primaryText,
          elevation: 0,
          actions: [
            Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    ThemeModeScope.of(
                      context,
                    ).setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                  },
                  tooltip: isDark
                      ? 'Switch to light mode'
                      : 'Switch to dark mode',
                );
              },
            ),
            const AccountAppBarMenu(),
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      color: colors.primaryText,
                    ),
                    children: [
                      TextSpan(
                        text: 'Welcome Back!',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: name.isEmpty ? '' : '\n$name',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
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
