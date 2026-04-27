import 'package:flutter/material.dart';
import 'package:tafwela/services/theme_service.dart';
import '../theme/app_theme_scope.dart';

class DarkModeButton extends StatelessWidget {
  const DarkModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppThemeScope.of(context);

    return IconButton(
      icon: Icon(scope.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () async {
        await ThemeService().setDarkMode(!scope.isDarkMode);
        scope.onDarkModeChanged();
      },
      tooltip: scope.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
    );
  }
}
