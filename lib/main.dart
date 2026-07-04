import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/services/notification_service.dart';
import 'package:new_version/services/connectivity_service.dart';
import 'package:new_version/services/local_database_service.dart';
import 'package:new_version/services/search_preferences_service.dart';
import 'package:new_version/services/sync_service.dart';
import 'firebase_options.dart';
import 'package:new_version/routes/app_routes.dart';
import 'package:new_version/controllers/auth/auth_controller.dart';
import 'package:new_version/services/biometric_auth_service.dart';
import 'package:dio/dio.dart';
import 'package:new_version/services/overpass_service.dart';
import 'package:new_version/services/osrm_service.dart';
import 'package:new_version/services/nominatim_service.dart';
import 'package:new_version/controllers/driver/location_controller.dart';
import 'package:new_version/controllers/driver/station_controller.dart';
import 'package:new_version/controllers/driver/favorites_controller.dart';
import 'package:new_version/controllers/driver/driver_profile_controller.dart';

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
        final settingsStorage = GetStorage('Settings');

        Get.put<GetStorage>(settingsStorage, permanent: true);
        Get.put<SearchPreferencesService>(
          SearchPreferencesService(settingsStorage),
          permanent: true,
        );
        Get.put(AuthController());

        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
          ),
        );
        Get.put(dio);
        Get.put(OverpassService(dio));
        Get.put(OsrmService(dio));
        Get.put(NominatimService(dio));
        
        Get.put(LocationController(), permanent: true);
        Get.put(StationController(), permanent: true);
        Get.put(FavoritesController(), permanent: true);
        Get.put(DriverProfileController(), permanent: true);
      }),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await GetStorage.init('Settings');
  await GetStorage.init('driver_favorites');

  // Initialize async services BEFORE runApp to guarantee dependency order
  await Get.putAsync(() async => ConnectivityService().init(), permanent: true);
  await Get.putAsync(() async => LocalDatabaseService().init(), permanent: true);
  Get.put(SyncService(), permanent: true);
  await Get.putAsync(() async => BiometricAuthService().init(), permanent: true);

  runApp(const MyApp());
}
