/// Row from `summary_reports` (PostgREST snake_case keys).
class SummaryReport {
  const SummaryReport({
    required this.id,
    required this.dateStart,
    required this.dateEnd,
    required this.topics,
    required this.status,
    required this.resultMarkdown,
  });

  final String id;
  final DateTime dateStart;
  final DateTime dateEnd;
  final List<String> topics;
  final String status;
  final String? resultMarkdown;

  static DateTime _parseDate(dynamic v) {
    if (v is DateTime) return DateTime(v.year, v.month, v.day);
    if (v is String && v.isNotEmpty) {
      final d = DateTime.tryParse(v);
      if (d != null) return DateTime(d.year, d.month, d.day);
    }
    throw FormatException('Invalid date: $v');
  }

  factory SummaryReport.fromJson(Map<String, dynamic> json) {
    final topicsRaw = json['topics'];
    final topics = topicsRaw is List
        ? topicsRaw.map((e) => e.toString()).toList()
        : <String>[];

    return SummaryReport(
      id: json['id'] as String,
      dateStart: _parseDate(json['date_start']),
      dateEnd: _parseDate(json['date_end']),
      topics: topics,
      status: json['status'] as String? ?? 'unknown',
      resultMarkdown: json['result_markdown'] as String?,
    );
  }
}
