import 'package:flutter/material.dart';

class ThemeModeScope extends InheritedWidget {
  const ThemeModeScope({
    super.key,
    required this.setThemeMode,
    required super.child,
  });

  final void Function(ThemeMode) setThemeMode;

  static ThemeModeScope of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ThemeModeScope>();
    assert(
      scope != null,
      'ThemeModeScope not found. Wrap app in ThemeModeScope.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(ThemeModeScope oldWidget) => false;
}
