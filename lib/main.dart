import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:new_version/controllers/auth/auth_controller.dart';
import 'package:new_version/controllers/home/nav_controller.dart';
import 'package:new_version/controllers/home/status_controller.dart';
import 'package:new_version/controllers/home/timer_controller.dart';
import 'package:new_version/controllers/map/map_controller.dart';
import 'package:new_version/controllers/notification/notification_controller.dart';
import 'package:new_version/services/notification_service.dart';
import 'package:new_version/views/splash/splash_view.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(AuthController());
  Get.put(StatusController());
  Get.put(NotificationController());
  Get.put(TimerController());
  Get.put(NavController());
  Get.put(MapController());
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(),
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const SplashView(),
    ),
  );
}
