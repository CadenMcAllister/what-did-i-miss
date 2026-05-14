import 'package:flutter/foundation.dart';

/// App-wide state. Summary dates are date-only; topic lists are mirrored from Supabase metadata.
class AppState extends ChangeNotifier {
  AppState() {
    final t = _dateOnly(DateTime.now());
    _summaryStart = t;
    _summaryEnd = t;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _sameCalendarDay(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _sameStringList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  DateTime? _summaryStart;
  DateTime? _summaryEnd;

  DateTime? get summaryStart => _summaryStart;
  DateTime? get summaryEnd => _summaryEnd;

  final List<String> _selectedSummaryTopics = [];
  final List<String> _customSummaryTopicLabels = [];

  /// Topics selected for the summary (suggested names and/or custom labels).
  List<String> get selectedSummaryTopics => List.unmodifiable(_selectedSummaryTopics);

  /// Custom labels the user has added (each may or may not be in [selectedSummaryTopics]).
  List<String> get customSummaryTopicLabels =>
      List.unmodifiable(_customSummaryTopicLabels);

  void setSummaryStart(DateTime? value) {
    final v = value == null ? null : _dateOnly(value);
    if (_sameCalendarDay(_summaryStart, v)) return;
    _summaryStart = v;
    notifyListeners();
  }

  void setSummaryEnd(DateTime? value) {
    final v = value == null ? null : _dateOnly(value);
    if (_sameCalendarDay(_summaryEnd, v)) return;
    _summaryEnd = v;
    notifyListeners();
  }

  /// Replaces topic lists (e.g. after load from Supabase or local edits).
  void hydrateSummaryTopics(List<String> selected, List<String> customLabels) {
    if (_sameStringList(_selectedSummaryTopics, selected) &&
        _sameStringList(_customSummaryTopicLabels, customLabels)) {
      return;
    }
    _selectedSummaryTopics
      ..clear()
      ..addAll(selected);
    _customSummaryTopicLabels
      ..clear()
      ..addAll(customLabels);
    notifyListeners();
  }

  void clearSummaryTopics() {
    if (_selectedSummaryTopics.isEmpty && _customSummaryTopicLabels.isEmpty) {
      return;
    }
    _selectedSummaryTopics.clear();
    _customSummaryTopicLabels.clear();
    notifyListeners();
  }
}
