import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/app_constants.dart';
import '../app/app_state.dart';
import '../app/app_state_scope.dart';
import '../app/theme_mode_scope.dart';
import '../theme/app_colors.dart';
import '../widgets/account_app_bar_menu.dart';
import '../widgets/route_aware_refresh.dart';
import '../widgets/segmented_mm_dd_yy_field.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<SegmentedMmDdYyFieldState> _endDateFieldKey =
      GlobalKey<SegmentedMmDdYyFieldState>();

  String? _startError;
  String? _endError;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _onStartCommit(
    AppState appState, {
    required DateTime? date,
    String? errorMessage,
  }) {
    if (errorMessage != null) {
      setState(() => _startError = errorMessage);
      return;
    }
    if (date == null) return;

    final today = _dateOnly(DateTime.now());
    final earliest = DateTime(today.year - 10, 1, 1);

    if (date.isBefore(earliest)) {
      setState(() => _startError = 'Date is too far in the past');
      return;
    }
    if (date.isAfter(today)) {
      setState(() => _startError = "Start can't be after today");
      return;
    }
    if (appState.summaryEnd != null && date.isAfter(appState.summaryEnd!)) {
      setState(() => _startError = 'Start must be on or before end date');
      return;
    }

    appState.setSummaryStart(date);
    setState(() => _startError = null);
  }

  void _onEndCommit(
    AppState appState, {
    required DateTime? date,
    String? errorMessage,
  }) {
    if (errorMessage != null) {
      setState(() => _endError = errorMessage);
      return;
    }
    if (date == null) return;

    final today = _dateOnly(DateTime.now());
    final earliest = DateTime(today.year - 10, 1, 1);

    if (date.isBefore(earliest)) {
      setState(() => _endError = 'Date is too far in the past');
      return;
    }
    if (date.isAfter(today)) {
      setState(() => _endError = "End can't be after today");
      return;
    }
    if (appState.summaryStart != null &&
        date.isBefore(appState.summaryStart!)) {
      setState(() => _endError = 'End must be on or after start date');
      return;
    }

    appState.setSummaryEnd(date);
    setState(() => _endError = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final name = accountDisplayLabel(user);
    final today = _dateOnly(DateTime.now());
    final appState = AppStateScope.of(context);

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
        body: ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            return SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        const SizedBox(height: 40),
                        Text(
                          'Summary period',
                          style: TextStyle(
                            fontFamily: 'Inter Tight',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap month, day, or year to edit that part. Use two digits each (e.g. 04/02/26). Today is filled in to start.',
                          style: TextStyle(
                            fontFamily: 'Inter Tight',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                            color: colors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SegmentedMmDdYyField(
                          colors: colors,
                          label: 'Start date',
                          initialDate: appState.summaryStart ?? today,
                          errorText: _startError,
                          onCommit: ({required date, errorMessage}) =>
                              _onStartCommit(
                            appState,
                            date: date,
                            errorMessage: errorMessage,
                          ),
                          onLastSegmentNext: () => _endDateFieldKey
                              .currentState
                              ?.focusFirstSegment(),
                        ),
                        const SizedBox(height: 12),
                        SegmentedMmDdYyField(
                          key: _endDateFieldKey,
                          colors: colors,
                          label: 'End date',
                          initialDate: appState.summaryEnd ?? today,
                          errorText: _endError,
                          onCommit: ({required date, errorMessage}) =>
                              _onEndCommit(
                            appState,
                            date: date,
                            errorMessage: errorMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
