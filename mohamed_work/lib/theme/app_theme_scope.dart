import 'package:flutter/material.dart';

class AppThemeScope extends InheritedWidget {
  final bool isDarkMode;
  final VoidCallback onDarkModeChanged;

  const AppThemeScope({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required super.child,
  });

  static AppThemeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppThemeScope old) =>
      isDarkMode != old.isDarkMode || onDarkModeChanged != old.onDarkModeChanged;
}
