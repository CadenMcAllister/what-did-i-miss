import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/app_route_observer.dart';
import '../app/app_state.dart';
import '../app/app_state_scope.dart';
import '../app/routes.dart';
import '../models/summary_report.dart';
import '../services/summary_reports_service.dart';
import '../services/summary_topic_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/account_app_bar_menu.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/dashboard_topic_selection.dart';
import '../widgets/segmented_mm_dd_yy_field.dart';
import '../widgets/snackbars.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with RouteAware {
  final GlobalKey<SegmentedMmDdYyFieldState> _endDateFieldKey =
      GlobalKey<SegmentedMmDdYyFieldState>();

  String? _startError;
  String? _endError;
  Timer? _topicSaveDebounce;
  StreamSubscription<AuthState>? _authTopicsSub;
  bool _generatingSummary = false;
  List<SummaryReport> _recentReports = [];
  bool _reportsLoading = false;
  String? _reportsError;

  static const double _sectionGap = 32;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Widget _sectionHeading(
    AppColors colors,
    String text, {
    TextAlign textAlign = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.primaryText,
        ),
      ),
    );
  }

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
      unawaited(_loadRecentReports());
    });
    _authTopicsSub = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
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
        unawaited(_loadRecentReports());
      } else if (e == AuthChangeEvent.signedOut) {
        appState.clearSummaryTopics();
        if (mounted) {
          setState(() {
            _recentReports = [];
            _reportsError = null;
            _reportsLoading = false;
          });
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    unawaited(_loadRecentReports());
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _topicSaveDebounce?.cancel();
    _authTopicsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentReports() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _recentReports = [];
        _reportsLoading = false;
        _reportsError = null;
      });
      return;
    }
    setState(() {
      _reportsLoading = true;
      _reportsError = null;
    });
    try {
      final list = await SummaryReportsService().listMyRecentReports(limit: 25);
      if (!mounted) return;
      setState(() {
        _recentReports = list;
        _reportsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reportsError = e.toString();
        _reportsLoading = false;
      });
    }
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

  void _onTopicsUpdated(
    AppState appState,
    List<String> selected,
    List<String> pool,
  ) {
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
      await _loadRecentReports();
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

  Widget _statusPill(AppColors colors, String status) {
    final s = status.toLowerCase();
    Color fg = colors.secondaryText;
    Color bg = colors.secondaryBackground;
    if (s == 'completed') {
      fg = colors.success;
      bg = colors.success.withValues(alpha: 0.14);
    } else if (s.contains('error') || s == 'failed') {
      fg = colors.error;
      bg = colors.error.withValues(alpha: 0.12);
    } else if (s == 'processing') {
      fg = colors.warning;
      bg = colors.warning.withValues(alpha: 0.14);
    } else if (s == 'completed_with_errors') {
      fg = colors.warning;
      bg = colors.warning.withValues(alpha: 0.12);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildRecentSummariesSection(
    BuildContext context,
    AppColors colors, {
    required User? user,
    required bool wide,
    required double contentMaxWidth,
  }) {
    final maxReadable = contentMaxWidth.clamp(320.0, 800.0);
    return Padding(
      padding: const EdgeInsets.only(top: _sectionGap * 1.5),
      child: Align(
        alignment: wide ? Alignment.centerLeft : Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxReadable),
          child: Column(
            crossAxisAlignment: wide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.stretch,
            children: [
              _sectionHeading(
                colors,
                'Recent summaries',
                textAlign: wide ? TextAlign.left : TextAlign.center,
              ),
              if (user == null)
                Text(
                  'Sign in to see your summaries.',
                  style: TextStyle(fontSize: 14, color: colors.secondaryText),
                )
              else if (_reportsLoading && _recentReports.isEmpty)
                LinearProgressIndicator(
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(99),
                  color: colors.primary,
                  backgroundColor: colors.secondaryBackground,
                )
              else if (_reportsError != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Could not load your summaries.\n$_reportsError',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.error,
                        height: 1.35,
                      ),
                    ),
                    TextButton(
                      onPressed: () => unawaited(_loadRecentReports()),
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else if (_recentReports.isEmpty)
                Text(
                  'No summaries yet.',
                  style: TextStyle(fontSize: 14, color: colors.secondaryText),
                )
              else
                Column(
                  children: [
                    for (final r in _recentReports)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: colors.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.summaryReport,
                                arguments: r.id,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${SummaryReportsService.formatDateOnly(r.dateStart)} → ${SummaryReportsService.formatDateOnly(r.dateEnd)}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: colors.primaryText,
                                          ),
                                        ),
                                        if (r.topics.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            r.topics.join(', '),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: colors.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _statusPill(colors, r.status),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 20,
                                    color: colors.secondaryText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final name = accountDisplayLabel(user);
    final today = _dateOnly(DateTime.now());
    final appState = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      appBar: const AppTopBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final maxH = constraints.maxHeight;
          final wide = maxW >= 1000;
          final contentCap = maxW.clamp(0.0, 1320.0);
          final padH = 24.0;

          final welcome = Text(
            name.isEmpty ? 'Welcome back' : 'Welcome back, $name',
            textAlign: wide ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: wide ? 36 : 28,
              fontWeight: FontWeight.w600,
              color: colors.primaryText,
            ),
          );

          final summaryHeader = Padding(
            padding: const EdgeInsets.only(top: 24),
            child: _sectionHeading(
              colors,
              'Summary period',
              textAlign: wide ? TextAlign.left : TextAlign.center,
            ),
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
            onCommit: ({required date, errorMessage}) =>
                _onEndCommit(appState, date: date, errorMessage: errorMessage),
          );

          final dateBlock = Wrap(
            alignment: wide ? WrapAlignment.start : WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [startField, endField],
          );

          final topics = DashboardTopicSelection(
            colors: colors,
            appState: appState,
            onTopicsUpdated: (selected, pool) =>
                _onTopicsUpdated(appState, selected, pool),
            onNotifyUser: (message) {
              showAppSnackBar(context, message, tone: SnackBarTone.warning);
            },
          );

          final generateSection = Padding(
            padding: EdgeInsets.only(top: wide ? 24 : _sectionGap),
            child: Align(
              alignment: wide ? Alignment.centerLeft : Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: wide
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: wide ? null : double.infinity,
                      child: FilledButton(
                        onPressed: _generatingSummary
                            ? null
                            : () => _onGenerateSummary(appState),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'May take a few minutes... or less; You can come back soon.',
                      textAlign: wide ? TextAlign.left : TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
              if (wide)
                generateSection
              else ...[
                const SizedBox(height: _sectionGap),
                topics,
                generateSection,
              ],
            ],
          );

          final mainRow = wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 46, child: leftPane),
                    const SizedBox(width: _sectionGap),
                    Expanded(flex: 54, child: topics),
                  ],
                )
              : leftPane;

          final recentSummariesSection = _buildRecentSummariesSection(
            context,
            colors,
            user: user,
            wide: wide,
            contentMaxWidth: contentCap,
          );

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: maxW,
                minHeight: (maxH - MediaQuery.paddingOf(context).vertical)
                    .clamp(0.0, double.infinity),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padH, vertical: padH),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentCap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [mainRow, recentSummariesSection],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
