import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/app_constants.dart';
import '../app/app_state.dart';
import '../app/app_state_scope.dart';
import '../app/routes.dart';
import '../app/theme_mode_scope.dart';
import '../services/summary_reports_service.dart';
import '../services/summary_topic_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/account_app_bar_menu.dart';
import '../widgets/dashboard_topic_selection.dart';
import '../widgets/route_aware_refresh.dart';
import '../widgets/segmented_mm_dd_yy_field.dart';
import '../widgets/snackbars.dart';

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
  Timer? _topicSaveDebounce;
  StreamSubscription<AuthState>? _authTopicsSub;
  bool _generatingSummary = false;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appState = AppStateScope.of(context);
      SummaryTopicPreferences.hydrateAppState(
        Supabase.instance.client.auth.currentUser,
        appState,
      );
    });
    _authTopicsSub =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      final appState = AppStateScope.of(context);
      final e = data.event;
      if (e == AuthChangeEvent.signedIn ||
          e == AuthChangeEvent.userUpdated ||
          e == AuthChangeEvent.tokenRefreshed) {
        SummaryTopicPreferences.hydrateAppState(
          data.session?.user ?? Supabase.instance.client.auth.currentUser,
          appState,
        );
      } else if (e == AuthChangeEvent.signedOut) {
        appState.clearSummaryTopics();
      }
    });
  }

  @override
  void dispose() {
    _topicSaveDebounce?.cancel();
    _authTopicsSub?.cancel();
    super.dispose();
  }

  void _scheduleTopicPersist() {
    _topicSaveDebounce?.cancel();
    _topicSaveDebounce = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _persistTopicsNow();
    });
  }

  Future<void> _persistTopicsNow() async {
    final user = Supabase.instance.client.auth.currentUser;
    final appState = AppStateScope.of(context);
    try {
      await SummaryTopicPreferences.persist(
        user,
        appState.selectedSummaryTopics.toList(),
        appState.customSummaryTopicLabels.toList(),
      );
    } catch (_) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Could not save topics. Check your connection and try again.',
          tone: SnackBarTone.error,
        );
      }
    }
  }

  void _onTopicsUpdated(AppState appState, List<String> selected, List<String> pool) {
    appState.hydrateSummaryTopics(selected, pool);
    _scheduleTopicPersist();
  }

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

  Future<void> _onGenerateSummary(AppState appState) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showAppSnackBar(
        context,
        'Sign in to generate a summary.',
        tone: SnackBarTone.warning,
      );
      return;
    }
    final start = appState.summaryStart;
    final end = appState.summaryEnd;
    if (start == null || end == null) {
      showAppSnackBar(
        context,
        'Choose both start and end dates first.',
        tone: SnackBarTone.warning,
      );
      return;
    }
    final topics = appState.selectedSummaryTopics;
    if (topics.isEmpty) {
      showAppSnackBar(
        context,
        'Select at least one topic.',
        tone: SnackBarTone.warning,
      );
      return;
    }
    if (_startError != null || _endError != null) {
      showAppSnackBar(
        context,
        'Fix date errors before generating.',
        tone: SnackBarTone.warning,
      );
      return;
    }

    setState(() => _generatingSummary = true);
    try {
      final service = SummaryReportsService();
      final reportId = await service.invokeGenerateSummary(
        topics: topics.toList(),
        start: start,
        end: end,
      );
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.summaryReport,
        arguments: reportId,
      );
    } on FunctionException catch (e) {
      if (!mounted) return;
      final detail = e.details?.toString();
      showAppSnackBar(
        context,
        detail != null && detail.isNotEmpty
            ? 'Could not generate summary: $detail'
            : 'Could not generate summary (${e.status}).',
        tone: SnackBarTone.error,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Could not generate summary: $e',
        tone: SnackBarTone.error,
      );
    } finally {
      if (mounted) setState(() => _generatingSummary = false);
    }
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
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final maxH = constraints.maxHeight;
                final wide = maxW >= 1000;
                final contentCap = maxW.clamp(0.0, 1320.0);
                final padH = 24.0;
                final titleSize = wide ? 56.0 : 40.0;
                final nameSize = wide ? 28.0 : 22.0;

                final welcome = RichText(
                  textAlign: wide ? TextAlign.left : TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      color: colors.primaryText,
                    ),
                    children: [
                      TextSpan(
                        text: 'Welcome Back!',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: name.isEmpty ? '' : '\n$name',
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.w500,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                );

                final summaryHeader = Column(
                  crossAxisAlignment: wide
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
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
                  ],
                );

                final startField = SegmentedMmDdYyField(
                  colors: colors,
                  label: 'Start date',
                  initialDate: appState.summaryStart ?? today,
                  errorText: _startError,
                  onCommit: ({required date, errorMessage}) => _onStartCommit(
                    appState,
                    date: date,
                    errorMessage: errorMessage,
                  ),
                  onLastSegmentNext: () =>
                      _endDateFieldKey.currentState?.focusFirstSegment(),
                );
                final endField = SegmentedMmDdYyField(
                  key: _endDateFieldKey,
                  colors: colors,
                  label: 'End date',
                  initialDate: appState.summaryEnd ?? today,
                  errorText: _endError,
                  onCommit: ({required date, errorMessage}) => _onEndCommit(
                    appState,
                    date: date,
                    errorMessage: errorMessage,
                  ),
                );

                final dateBlock = wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: startField),
                          const SizedBox(width: 16),
                          Expanded(child: endField),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          startField,
                          const SizedBox(height: 12),
                          endField,
                        ],
                      );

                final topics = DashboardTopicSelection(
                  colors: colors,
                  appState: appState,
                  onTopicsUpdated: (selected, pool) =>
                      _onTopicsUpdated(appState, selected, pool),
                  onNotifyUser: (message) {
                    showAppSnackBar(
                      context,
                      message,
                      tone: SnackBarTone.warning,
                    );
                  },
                );

                final leftPane = Column(
                  crossAxisAlignment: wide
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    welcome,
                    summaryHeader,
                    dateBlock,
                    if (!wide) ...[const SizedBox(height: 28), topics],
                  ],
                );

                final mainRow = wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 46,
                            child: leftPane,
                          ),
                          const SizedBox(width: 36),
                          Expanded(
                            flex: 54,
                            child: topics,
                          ),
                        ],
                      )
                    : leftPane;

                final generateSection = Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Align(
                    alignment: wide ? Alignment.centerLeft : Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: SizedBox(
                        width: wide ? null : double.infinity,
                        child: FilledButton(
                          onPressed: _generatingSummary
                              ? null
                              : () => _onGenerateSummary(appState),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _generatingSummary
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                )
                              : const Text(
                                  'Generate summary',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                );

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: maxW,
                      minHeight: (maxH - MediaQuery.paddingOf(context).vertical)
                          .clamp(0.0, double.infinity),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: padH,
                        vertical: wide ? 28 : 20,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentCap),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              mainRow,
                              generateSection,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
