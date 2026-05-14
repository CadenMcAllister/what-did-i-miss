import 'package:flutter/material.dart';

import '../pages/dashboard_page.dart';
import '../pages/home_screen.dart';
import '../pages/login_page.dart';
import '../pages/reset_password_page.dart';
import '../pages/summary_report_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String resetPassword = '/reset-password';
  static const String summaryReport = '/summary-report';

  static Map<String, WidgetBuilder> get routes => {
    home: (ctx) => const HomeScreen(),
    login: (ctx) => const LoginPage(),
    dashboard: (ctx) => const DashboardPage(),
    resetPassword: (ctx) => const ResetPasswordPage(),
    summaryReport: (ctx) {
      final args = ModalRoute.of(ctx)?.settings.arguments;
      final id = args is String ? args : '';
      return SummaryReportPage(reportId: id);
    },
  };
}