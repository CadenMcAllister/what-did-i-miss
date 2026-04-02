import 'package:flutter/foundation.dart';

/// App-wide state. Summary dates are date-only (no time component).
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

  DateTime? _summaryStart;
  DateTime? _summaryEnd;

  DateTime? get summaryStart => _summaryStart;
  DateTime? get summaryEnd => _summaryEnd;

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
}
