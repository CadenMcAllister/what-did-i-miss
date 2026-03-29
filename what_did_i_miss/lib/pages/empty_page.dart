import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/app_constants.dart';
import '../app/routes.dart';
import '../app/theme_mode_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/account_app_bar_menu.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final name = accountDisplayLabel(user);
    return Scaffold(
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
                  ThemeModeScope.of(context).setThemeMode(
                    isDark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
                tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
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
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _signOut(context),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.primaryText,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign out',
                  style: TextStyle(
                    fontFamily: 'Inter Tight',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
