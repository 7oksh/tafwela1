import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tafwela/widgets/dark_mode_button.dart';
import 'package:tafwela/theme/app_theme_scope.dart';

void main() {
  testWidgets('DarkModeButton smoke test', (WidgetTester tester) async {
    bool darkMode = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppThemeScope(
            isDarkMode: darkMode,
            onDarkModeChanged: () {
              darkMode = !darkMode;
            },
            child: const DarkModeButton(),
          ),
        ),
      ),
    );

    expect(find.byType(DarkModeButton), findsOneWidget);
  });
}
