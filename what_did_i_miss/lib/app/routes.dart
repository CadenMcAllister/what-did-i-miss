import 'package:flutter/material.dart';

import '../pages/empty_page.dart';
import '../pages/home_screen.dart';
import '../pages/login_page.dart';
import '../pages/reset_password_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String resetPassword = '/reset-password';

  static Map<String, WidgetBuilder> get routes => {
    home: (ctx) => const HomeScreen(),
    login: (ctx) => const LoginPage(),
    dashboard: (ctx) => const EmptyPage(),
    resetPassword: (ctx) => const ResetPasswordPage(),
  };
}