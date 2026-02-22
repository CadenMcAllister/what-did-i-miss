import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import 'app_constants.dart';
import 'routes.dart';
import '../theme/app_theme.dart';
import 'theme_mode_scope.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleInitialAuthRedirect());
  }

  Future<void> _handleInitialAuthRedirect() async {
    await Future<void>.delayed(Duration.zero);
    try {
      final uri = await AppLinks().getInitialLink();
      if (uri == null) return;
      final path = uri.path;
      if (path.contains('reset-password') || uri.host == 'reset-password') {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.resetPassword,
          (route) => false,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeScope(
      themeMode: _themeMode,
      setThemeMode: _setThemeMode,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        initialRoute: AppRoutes.home,
        routes: AppRoutes.routes,
      ),
    );
  }
}
