import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/summary_report.dart';
import '../services/summary_reports_service.dart';
import '../theme/app_colors.dart';

/// Light cleanup so model output spacing reads more evenly in the client.
String _normalizeMarkdownForDisplay(String raw) {
  var s = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  s = s.replaceAll(RegExp(r'\n{4,}'), '\n\n\n');
  return s.trim();
}

/// Shows a single `summary_reports` row loaded from Supabase (by [reportId]).
class SummaryReportPage extends StatefulWidget {
  const SummaryReportPage({super.key, required this.reportId});

  final String reportId;

  @override
  State<SummaryReportPage> createState() => _SummaryReportPageState();
}

class _SummaryReportPageState extends State<SummaryReportPage> {
  final _service = SummaryReportsService();

  SummaryReport? _report;
  Object? _error;
  bool _loading = true;
  int _pollAttempt = 0;

  static const _maxPolls = 40;
  static const _pollDelay = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    if (widget.reportId.isEmpty) {
      _loading = false;
      _error = StateError('Missing report id');
    } else {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      while (true) {
        final row = await _service.fetchReportById(widget.reportId);
        if (!mounted) return;

        if (row == null) {
          setState(() {
            _report = null;
            _loading = false;
            _error = StateError('Report not found or you do not have access.');
          });
          return;
        }

        final stillProcessing =
            row.status == 'processing' && _pollAttempt < _maxPolls;
        if (stillProcessing) {
          _pollAttempt++;
          await Future<void>.delayed(_pollDelay);
          if (!mounted) return;
          continue;
        }

        setState(() {
          _report = row;
          _loading = false;
        });
        return;
      }
    } catch (e, st) {
      debugPrint('SummaryReportPage load error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  String _periodLabel(SummaryReport r) {
    final a = SummaryReportsService.formatDateOnly(r.dateStart);
    final b = SummaryReportsService.formatDateOnly(r.dateEnd);
    return '$a — $b';
  }

  MarkdownStyleSheet _markdownStyle(
    BuildContext context,
    AppColors colors,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final divider = colors.secondaryText.withValues(alpha: 0.22);
    final quoteBg =
        colors.secondaryBackground.withValues(alpha: isDark ? 0.55 : 0.75);
    final codeBg = colors.secondaryBackground;
    final codeBorder = colors.primary.withValues(alpha: 0.28);

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      blockSpacing: 14,
      p: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.55,
        color: colors.primaryText,
      ),
      pPadding: const EdgeInsets.only(bottom: 2),
      h1: TextStyle(
        fontFamily: 'Inter Tight',
        fontWeight: FontWeight.w700,
        fontSize: 26,
        height: 1.22,
        color: colors.primaryText,
      ),
      h1Padding: const EdgeInsets.only(top: 4, bottom: 10),
      h2: TextStyle(
        fontFamily: 'Inter Tight',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.28,
        color: colors.primaryText,
      ),
      h2Padding: const EdgeInsets.only(top: 18, bottom: 8),
      h3: TextStyle(
        fontFamily: 'Inter Tight',
        fontWeight: FontWeight.w600,
        fontSize: 17,
        height: 1.3,
        color: colors.primaryText,
      ),
      h3Padding: const EdgeInsets.only(top: 14, bottom: 6),
      h4: TextStyle(
        fontFamily: 'Inter Tight',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.32,
        color: colors.primaryText,
      ),
      h4Padding: const EdgeInsets.only(top: 12, bottom: 4),
      em: TextStyle(
        fontFamily: 'Inter',
        fontStyle: FontStyle.italic,
        color: colors.primaryText.withValues(alpha: 0.92),
      ),
      strong: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        color: colors.primaryText,
      ),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13.5,
        height: 1.38,
        color: colors.primaryText,
        backgroundColor: codeBg.withValues(alpha: 0.95),
      ),
      codeblockPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      codeblockDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: codeBorder),
      ),
      blockquote: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        height: 1.48,
        color: colors.secondaryText,
        fontStyle: FontStyle.italic,
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      blockquoteDecoration: BoxDecoration(
        color: quoteBg,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: colors.primary, width: 3),
        ),
      ),
      listIndent: 22,
      listBullet: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.5,
        color: colors.primaryText,
      ),
      listBulletPadding: const EdgeInsets.only(right: 8, top: 2),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: divider),
        ),
      ),
      a: TextStyle(
        fontFamily: 'Inter',
        color: colors.primary,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
      ),
      tableBorder: TableBorder.all(color: divider, width: 1),
      tableCellsPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      tableCellsDecoration: BoxDecoration(
        color: colors.primaryBackground.withValues(alpha: isDark ? 0.35 : 0.65),
      ),
      tableHead: TextStyle(
        fontFamily: 'Inter Tight',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: colors.primaryText,
      ),
      tableBody: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.42,
        color: colors.primaryText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Your summary',
          style: TextStyle(fontFamily: 'Inter Tight'),
        ),
        backgroundColor: colors.tertiary,
        foregroundColor: colors.primaryText,
        elevation: 0,
        actions: [
          if (!_loading && widget.reportId.isNotEmpty)
            IconButton(
              tooltip: 'Refresh',
              onPressed: () {
                _pollAttempt = 0;
                unawaited(_load());
              },
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: _buildBody(context, colors, isDark),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppColors colors,
    bool isDark,
  ) {
    if (widget.reportId.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Missing report id.',
            style: TextStyle(color: colors.error, fontFamily: 'Inter Tight'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading your saved summary from your account…',
              style: TextStyle(
                fontFamily: 'Inter Tight',
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 12),
              Text(
                _error.toString(),
                style: TextStyle(
                  fontFamily: 'Inter Tight',
                  color: colors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  _pollAttempt = 0;
                  unawaited(_load());
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final report = _report;
    if (report == null) {
      return const SizedBox.shrink();
    }

    final rawMd = report.resultMarkdown ?? '';
    final md = _normalizeMarkdownForDisplay(rawMd);
    final sheet = _markdownStyle(context, colors, isDark);
    final cardFill = colors.secondaryBackground.withValues(alpha: isDark ? 0.42 : 0.55);
    final cardBorder = colors.tertiary.withValues(alpha: 0.55);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.clamp(0.0, 900.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _periodLabel(report),
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text('Status: ${report.status}'),
                        backgroundColor: colors.secondaryBackground,
                        labelStyle: TextStyle(
                          fontFamily: 'Inter Tight',
                          fontSize: 13,
                          color: colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  if (report.topics.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Topics: ${report.topics.join(', ')}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 1.35,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (md.isEmpty)
                    Text(
                      'This report has no markdown body yet (status: ${report.status}).',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: colors.secondaryText,
                      ),
                    )
                  else ...[
                    Material(
                      color: cardFill,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: cardBorder, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                        child: MarkdownBody(
                          data: md,
                          selectable: true,
                          styleSheet: sheet,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
