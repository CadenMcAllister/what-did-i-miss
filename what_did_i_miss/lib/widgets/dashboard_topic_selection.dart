import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../app/suggested_summary_topics.dart';
import '../theme/app_colors.dart';

const int _kMaxSelectedTopics = 24;
const int _kMaxCustomPool = 16;
const int _kMaxLabelLength = 64;

typedef TopicsUpdated = void Function(List<String> selected, List<String> customPool);

/// Suggested chips, custom topic entry, and chip list — calls [onTopicsUpdated] with new lists.
class DashboardTopicSelection extends StatefulWidget {
  const DashboardTopicSelection({
    super.key,
    required this.colors,
    required this.appState,
    required this.onTopicsUpdated,
    this.onNotifyUser,
  });

  final AppColors colors;
  final AppState appState;
  final TopicsUpdated onTopicsUpdated;
  final void Function(String message)? onNotifyUser;

  @override
  State<DashboardTopicSelection> createState() => _DashboardTopicSelectionState();
}

class _DashboardTopicSelectionState extends State<DashboardTopicSelection> {
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _emit(List<String> selected, List<String> customPool) {
    widget.onTopicsUpdated(selected, customPool);
  }

  bool _labelExists(String label, List<String> pool) {
    final lower = label.toLowerCase();
    for (final s in suggestedSummaryTopics) {
      if (s.toLowerCase() == lower) return true;
    }
    for (final p in pool) {
      if (p.toLowerCase() == lower) return true;
    }
    return false;
  }

  void _toggleSuggested(String topic) {
    final sel = List<String>.from(widget.appState.selectedSummaryTopics);
    final pool = List<String>.from(widget.appState.customSummaryTopicLabels);
    if (sel.contains(topic)) {
      sel.remove(topic);
    } else {
      if (sel.length >= _kMaxSelectedTopics) {
        widget.onNotifyUser?.call('You can select up to $_kMaxSelectedTopics topics.');
        return;
      }
      sel.add(topic);
    }
    _emit(sel, pool);
  }

  void _addCustom() {
    var label = _customController.text.trim();
    if (label.isEmpty) return;
    if (label.length > _kMaxLabelLength) {
      label = label.substring(0, _kMaxLabelLength);
    }
    final sel = List<String>.from(widget.appState.selectedSummaryTopics);
    final pool = List<String>.from(widget.appState.customSummaryTopicLabels);
    if (_labelExists(label, pool)) {
      widget.onNotifyUser?.call('That topic is already listed.');
      return;
    }
    if (pool.length >= _kMaxCustomPool) {
      widget.onNotifyUser?.call('You can add up to $_kMaxCustomPool custom topics.');
      return;
    }
    pool.add(label);
    if (sel.length < _kMaxSelectedTopics) {
      sel.add(label);
    } else {
      widget.onNotifyUser?.call('Topic added but not selected (selection limit reached).');
    }
    _customController.clear();
    _emit(sel, pool);
  }

  void _removeCustom(String label) {
    final sel = List<String>.from(widget.appState.selectedSummaryTopics);
    final pool = List<String>.from(widget.appState.customSummaryTopicLabels);
    pool.remove(label);
    sel.remove(label);
    _emit(sel, pool);
  }

  void _toggleCustomSelected(String label) {
    final sel = List<String>.from(widget.appState.selectedSummaryTopics);
    final pool = List<String>.from(widget.appState.customSummaryTopicLabels);
    if (sel.contains(label)) {
      sel.remove(label);
    } else {
      if (sel.length >= _kMaxSelectedTopics) {
        widget.onNotifyUser?.call('You can select up to $_kMaxSelectedTopics topics.');
        return;
      }
      sel.add(label);
    }
    _emit(sel, pool);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final selected = widget.appState.selectedSummaryTopics;
    final customPool = widget.appState.customSummaryTopicLabels;

    final selectedChipBg = colors.primary.withValues(alpha: 0.44);
    final unselectedChipBg = colors.primaryBackground.withValues(alpha: 0.55);
    const chipLabelOnPrimary = Color(0xFFFFFFFF);

    TextStyle chipLabelFor(bool isSelected) => TextStyle(
          fontFamily: 'Inter Tight',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? chipLabelOnPrimary : colors.primaryText,
        );

    return Material(
      color: colors.secondaryBackground,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Topics for your summary',
              style: TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Suggestions below; add your own topics. Choices are saved to your account and load again next time.',
              style: TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.35,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Suggested',
              style: TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final topic in suggestedSummaryTopics)
                  FilterChip(
                    label: Text(
                      topic,
                      style: chipLabelFor(selected.contains(topic)),
                    ),
                    selected: selected.contains(topic),
                    onSelected: (_) => _toggleSuggested(topic),
                    showCheckmark: true,
                    checkmarkColor: selected.contains(topic)
                        ? chipLabelOnPrimary
                        : colors.primaryText,
                    pressElevation: 0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    color: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return selectedChipBg;
                      }
                      return unselectedChipBg;
                    }),
                    side: WidgetStateBorderSide.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return BorderSide(
                          color: colors.primary,
                          width: 2,
                        );
                      }
                      return BorderSide(
                        color: colors.primaryText.withValues(alpha: 0.14),
                        width: 1,
                      );
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Custom topics',
              style: TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _customController,
                    textInputAction: TextInputAction.done,
                    maxLength: _kMaxLabelLength,
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.primaryText,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'e.g. Seattle city council',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter Tight',
                        color: colors.secondaryText.withValues(alpha: 0.8),
                      ),
                      filled: true,
                      fillColor: colors.primaryBackground.withValues(alpha: 0.45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.primaryText.withValues(alpha: 0.12),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colors.primaryText.withValues(alpha: 0.12),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: colors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addCustom(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addCustom,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.primaryText,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (customPool.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final label in customPool)
                    Builder(
                      builder: (context) {
                        final isSel = selected.contains(label);
                        return InputChip(
                          label: Text(
                            label,
                            style: chipLabelFor(isSel),
                          ),
                          selected: isSel,
                          onSelected: (_) => _toggleCustomSelected(label),
                          onDeleted: () => _removeCustom(label),
                          deleteIconColor: isSel
                              ? chipLabelOnPrimary.withValues(alpha: 0.88)
                              : colors.primaryText.withValues(alpha: 0.5),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          color: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return selectedChipBg;
                            }
                            return unselectedChipBg;
                          }),
                          side: WidgetStateBorderSide.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return BorderSide(
                                color: colors.primary,
                                width: 2,
                              );
                            }
                            return BorderSide(
                              color: colors.primaryText.withValues(alpha: 0.14),
                              width: 1,
                            );
                          }),
                        );
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Auto-saves a moment after you change selections.',
              style: TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colors.secondaryText.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
