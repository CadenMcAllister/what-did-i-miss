import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_constants.dart';
import 'app_route_observer.dart';
import 'app_state.dart';
import 'app_state_scope.dart';
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
  final AppState _appState = AppState();

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _handleInitialAuthRedirect(),
    );
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
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
    return AppStateScope(
      notifier: _appState,
      child: ThemeModeScope(
        setThemeMode: _setThemeMode,
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          navigatorObservers: [appRouteObserver],
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          // On web, setting [initialRoute] overrides the browser URL and always
          // opens `/`. Omit it so `/reset-password` and other deep links work.
          initialRoute: kIsWeb ? null : AppRoutes.home,
          routes: AppRoutes.routes,
        ),
      ),
    );
  }
}
