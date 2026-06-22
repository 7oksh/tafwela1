import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/Map_controller.dart';
import 'package:new_version/screens/splash_screen.dart';
import 'package:new_version/services/ConnectivityService.dart';

import 'package:new_version/services/notification_service.dart';

import 'controllers/AuthController.dart';
import 'controllers/nav_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/status_controller.dart';
import 'controllers/timer_controller.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController());
  Get.put(StatusController());
  Get.put(NotificationController());
  Get.put(TimerController());
  Get.put(NavController());
  Get.put(MapController());
  await Get.putAsync(
        () => ConnectivityService().init(),
  );
  runApp(MyApp());
}

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
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: SplashScreen(),
    );
  }
}
