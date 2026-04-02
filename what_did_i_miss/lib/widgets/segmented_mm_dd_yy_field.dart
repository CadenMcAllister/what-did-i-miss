import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Fires when the user leaves all three segments (after a frame), with a parsed
/// calendar date or a structural error. [date] is null if inputs are incomplete or invalid.
typedef SegmentedDateCommitCallback = void Function({
  required DateTime? date,
  String? errorMessage,
});

/// Three tappable parts (MM / DD / YY) like `04/02/26`; focused segment is highlighted.
class SegmentedMmDdYyField extends StatefulWidget {
  const SegmentedMmDdYyField({
    super.key,
    required this.colors,
    required this.label,
    required this.initialDate,
    required this.onCommit,
    this.errorText,
    this.onLastSegmentNext,
  });

  final AppColors colors;
  final String label;
  final DateTime initialDate;
  final SegmentedDateCommitCallback onCommit;
  final String? errorText;

  /// After the user presses "next" on the year segment (e.g. move to the next date row).
  final VoidCallback? onLastSegmentNext;

  @override
  SegmentedMmDdYyFieldState createState() => SegmentedMmDdYyFieldState();
}

class SegmentedMmDdYyFieldState extends State<SegmentedMmDdYyField> {
  late final TextEditingController _monthC;
  late final TextEditingController _dayC;
  late final TextEditingController _yearC;
  late final FocusNode _monthF;
  late final FocusNode _dayF;
  late final FocusNode _yearF;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDate;
    _monthC = TextEditingController(text: d.month.toString().padLeft(2, '0'));
    _dayC = TextEditingController(text: d.day.toString().padLeft(2, '0'));
    final yy = d.year % 100;
    _yearC = TextEditingController(text: yy.toString().padLeft(2, '0'));
    _monthF = FocusNode();
    _dayF = FocusNode();
    _yearF = FocusNode();
    for (final n in [_monthF, _dayF, _yearF]) {
      n.addListener(_onAnyFocusChange);
    }
  }

  static bool _sameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void didUpdateWidget(SegmentedMmDdYyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameCalendarDay(widget.initialDate, oldWidget.initialDate)) {
      final d = widget.initialDate;
      _monthC.text = d.month.toString().padLeft(2, '0');
      _dayC.text = d.day.toString().padLeft(2, '0');
      final yy = d.year % 100;
      _yearC.text = yy.toString().padLeft(2, '0');
    }
  }

  void _onAnyFocusChange() {
    setState(() {});
    _scheduleCommitCheck();
  }

  void _scheduleCommitCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_monthF.hasFocus && !_dayF.hasFocus && !_yearF.hasFocus) {
        _emitCommit();
      }
    });
  }

  @override
  void dispose() {
    for (final n in [_monthF, _dayF, _yearF]) {
      n.removeListener(_onAnyFocusChange);
    }
    _monthC.dispose();
    _dayC.dispose();
    _yearC.dispose();
    _monthF.dispose();
    _dayF.dispose();
    _yearF.dispose();
    super.dispose();
  }

  static int _fullYearFromYy(int yy) {
    final nowY = DateTime.now().year;
    final century = nowY ~/ 100 * 100;
    var y = century + yy;
    if (y > nowY + 80) y -= 100;
    if (y < nowY - 100) y += 100;
    return y;
  }

  void _emitCommit() {
    final ms = _monthC.text.trim();
    final ds = _dayC.text.trim();
    final ys = _yearC.text.trim();
    if (ms.isEmpty || ds.isEmpty || ys.isEmpty) {
      widget.onCommit(
        date: null,
        errorMessage: 'Enter month, day, and year',
      );
      return;
    }
    final month = int.tryParse(ms);
    final day = int.tryParse(ds);
    final yy = int.tryParse(ys);
    if (month == null || day == null || yy == null) {
      widget.onCommit(date: null, errorMessage: 'Enter a valid date');
      return;
    }
    if (yy < 0 || yy > 99) {
      widget.onCommit(date: null, errorMessage: 'Enter a valid date');
      return;
    }
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      widget.onCommit(date: null, errorMessage: 'Enter a valid date');
      return;
    }
    final fullY = _fullYearFromYy(yy);
    final DateTime parsed;
    try {
      parsed = DateTime(fullY, month, day);
    } catch (_) {
      widget.onCommit(date: null, errorMessage: 'Enter a valid date');
      return;
    }
    if (parsed.month != month || parsed.day != day) {
      widget.onCommit(date: null, errorMessage: 'Enter a valid date');
      return;
    }
    widget.onCommit(date: parsed, errorMessage: null);
  }

  void _selectAll(TextEditingController c) {
    if (c.text.isEmpty) return;
    c.selection = TextSelection(baseOffset: 0, extentOffset: c.text.length);
  }

  void focusFirstSegment() {
    _monthF.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) => _selectAll(_monthC));
  }

  Widget _slash() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '/',
        style: TextStyle(
          fontFamily: 'Inter Tight',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: widget.colors.secondaryText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Material(
      color: colors.secondaryBackground,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 22,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _SegmentBox(
                        colors: colors,
                        label: 'Month',
                        controller: _monthC,
                        focusNode: _monthF,
                        textInputAction: TextInputAction.next,
                        onTap: () {
                          _monthF.requestFocus();
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _selectAll(_monthC));
                        },
                        onChanged: (v) {
                          if (v.length >= 2) _dayF.requestFocus();
                        },
                        onSubmitted: (_) {
                          _dayF.requestFocus();
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _selectAll(_dayC));
                        },
                      ),
                      _slash(),
                      _SegmentBox(
                        colors: colors,
                        label: 'Day',
                        controller: _dayC,
                        focusNode: _dayF,
                        textInputAction: TextInputAction.next,
                        onTap: () {
                          _dayF.requestFocus();
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _selectAll(_dayC));
                        },
                        onChanged: (v) {
                          if (v.length >= 2) _yearF.requestFocus();
                        },
                        onSubmitted: (_) {
                          _yearF.requestFocus();
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _selectAll(_yearC));
                        },
                      ),
                      _slash(),
                      _SegmentBox(
                        colors: colors,
                        label: 'Year',
                        controller: _yearC,
                        focusNode: _yearF,
                        textInputAction: widget.onLastSegmentNext != null
                            ? TextInputAction.next
                            : TextInputAction.done,
                        onTap: () {
                          _yearF.requestFocus();
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _selectAll(_yearC));
                        },
                        onChanged: (_) {},
                        onSubmitted: (_) {
                          _scheduleCommitCheck();
                          widget.onLastSegmentNext?.call();
                        },
                      ),
                    ],
                  ),
                  if (widget.errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.errorText!,
                      style: TextStyle(
                        fontFamily: 'Inter Tight',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.error,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentBox extends StatelessWidget {
  const _SegmentBox({
    required this.colors,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    required this.onTap,
    required this.onChanged,
    required this.onSubmitted,
  });

  final AppColors colors;
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    final borderColor = focused
        ? colors.primary
        : colors.primaryText.withValues(alpha: 0.14);
    final fill = focused
        ? colors.primary.withValues(alpha: 0.12)
        : colors.primaryBackground.withValues(alpha: 0.35);

    return Semantics(
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: 44,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: focused ? 2 : 1),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              maxLength: 2,
              keyboardType: TextInputType.number,
              textInputAction: textInputAction,
              style: TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.primaryText,
                height: 1.2,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                counterText: '',
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onTap: () =>
                  controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: controller.text.length,
                  ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
        ),
      ),
    );
  }
}
