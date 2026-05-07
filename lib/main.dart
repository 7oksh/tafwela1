import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/screens/splash_screen.dart';
import 'package:new_version/screens/staff/main_screen.dart';
import 'package:new_version/services/notification_service.dart';

import 'controllers/nav_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/status_controller.dart';
import 'controllers/timer_controller.dart';

import 'firebase_options.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await NotificationService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
   );
  
  Get.put(StatusController());
  Get.put(NotificationController());
  Get.put(TimerController());
  Get.put(NavController());

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
      home: SplashScreen(),
    ),
  );
}
