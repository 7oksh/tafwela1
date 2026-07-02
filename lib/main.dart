import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/services/notification_service.dart';
import 'package:new_version/services/connectivity_service.dart';
import 'firebase_options.dart';
import 'package:new_version/utils/routes.dart';
import 'package:new_version/controllers/auth/auth_controller.dart';
import 'package:new_version/services/biometric_auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      getPages: AppRoutes.pages,
      initialRoute: AppRoutes.splash,
      initialBinding: BindingsBuilder(() {
        Get.put(GetStorage('Settings'));
        Get.put(AuthController());
      }),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init('Settings');

  // Initialize async services BEFORE runApp to guarantee dependency order
  await Get.putAsync(() async => ConnectivityService().init());
  await Get.putAsync(() async => BiometricAuthService().init());

  runApp(const MyApp());
}
