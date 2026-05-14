import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/summary_report.dart';

/// Edge function name and table name match Supabase project configuration.
class SummaryReportsService {
  SummaryReportsService([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static String formatDateOnly(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  /// Calls `generate_summary` with the signed-in user's JWT. Returns new row id.
  Future<String> invokeGenerateSummary({
    required List<String> topics,
    required DateTime start,
    required DateTime end,
  }) async {
    final trimmed = topics.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    if (trimmed.isEmpty) {
      throw StateError('No topics to summarize');
    }

    final res = await _client.functions.invoke(
      'generate_summary',
      body: <String, dynamic>{
        'topics': trimmed,
        'startDate': formatDateOnly(start),
        'endDate': formatDateOnly(end),
      },
    );

    final data = res.data;
    if (data is! Map) {
      throw FormatException('Unexpected response from generate_summary');
    }
    final map = Map<String, dynamic>.from(data);
    final id =
        map['reportId'] as String? ??
        map['report_id'] as String? ??
        map['id'] as String?;
    if (id == null || id.isEmpty) {
      throw FormatException('Missing report id in generate_summary response');
    }
    return id;
  }

  /// Loads one row the user may read (enforce RLS on `summary_reports` in Supabase).
  Future<SummaryReport?> fetchReportById(String reportId) async {
    final row = await _client
        .from('summary_reports')
        .select()
        .eq('id', reportId)
        .maybeSingle();
    if (row == null) return null;
    return SummaryReport.fromJson(Map<String, dynamic>.from(row));
  }
}
