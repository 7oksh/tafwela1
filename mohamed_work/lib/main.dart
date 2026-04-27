import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
//import 'package:tafwela/screens/splach_screen.dart';
import 'firebase_options.dart';
import 'new_screens/splash_screen.dart';
import 'theme/app_themes.dart';
import 'theme/app_theme_scope.dart';
import 'services/theme_service.dart';
void main(){

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,

      home: const SplashScreen()));

}


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // على أندرويد: لو firebase_options لسه placeholder نستخدم google-services.json تلقائياً
//   final isAndroidWithPlaceholder = !kIsWeb &&
//       defaultTargetPlatform == TargetPlatform.android &&
//       DefaultFirebaseOptions.android.apiKey.contains('PLACEHOLDER');
//   if (isAndroidWithPlaceholder) {
//     await Firebase.initializeApp();
//   } else {
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   }
//   runApp(const GasStationApp());
// }
//
// class GasStationApp extends StatefulWidget {
//   const GasStationApp({super.key});
//
//   @override
//   State<GasStationApp> createState() => _GasStationAppState();
// }
//
// class _GasStationAppState extends State<GasStationApp> {
//   final ThemeService _themeService = ThemeService();
//   bool _isDarkMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDarkMode();
//   }
//
//   Future<void> _loadDarkMode() async {
//     final value = await _themeService.getDarkMode();
//     if (mounted) setState(() => _isDarkMode = value);
//   }
//
//   void _onDarkModeChanged() async {
//     await _loadDarkMode();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = AppThemes.themeFromDarkMode(_isDarkMode);
//     return AppThemeScope(
//       isDarkMode: _isDarkMode,
//       onDarkModeChanged: _onDarkModeChanged,
//       child: MaterialApp(
//         title: 'تفويلة',
//         debugShowCheckedModeBanner: false,
//         theme: theme,
//         home: const SplashScreen(),
//       ),
//     );
//   }
// }
