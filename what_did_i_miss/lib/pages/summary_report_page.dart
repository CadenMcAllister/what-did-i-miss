import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/summary_report.dart';
import '../services/summary_reports_service.dart';
import '../theme/app_colors.dart';

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
              'Loading report…',
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

    final md = report.resultMarkdown?.trim() ?? '';
    final sheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 1.45,
        color: colors.primaryText,
      ),
      h1: TextStyle(
        fontFamily: 'Inter Tight',
        fontWeight: FontWeight.w700,
        fontSize: 28,
        color: colors.primaryText,
      ),
      h2: TextStyle(
        fontFamily: 'Inter Tight',
        fontWeight: FontWeight.w600,
        fontSize: 22,
        color: colors.primaryText,
      ),
      h3: TextStyle(
        fontFamily: 'Inter Tight',
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: colors.primaryText,
      ),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: colors.primaryText,
        backgroundColor: isDark
            ? colors.secondaryBackground
            : colors.secondaryBackground,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark
            ? colors.secondaryBackground
            : colors.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      a: TextStyle(
        fontFamily: 'Inter',
        color: colors.primary,
        decoration: TextDecoration.underline,
      ),
      blockquote: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: colors.secondaryText,
        fontStyle: FontStyle.italic,
      ),
    );

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
                      Chip(
                        label: Text(
                          report.id.length >= 8
                              ? 'ID ${report.id.substring(0, 8)}…'
                              : 'ID ${report.id}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: colors.tertiary.withValues(alpha: 0.5),
                        labelStyle: TextStyle(
                          fontFamily: 'Inter Tight',
                          fontSize: 12,
                          color: colors.secondaryText,
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
                  else
                    MarkdownBody(
                      data: md,
                      selectable: true,
                      styleSheet: sheet,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
