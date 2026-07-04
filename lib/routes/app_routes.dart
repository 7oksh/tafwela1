import 'package:get/get.dart';

// Views
import 'package:new_version/views/splash/splash_view.dart';
import 'package:new_version/views/intro/intro_view.dart';
import 'package:new_version/views/driver/driver_main_screen.dart';
import 'package:new_version/views/driver/driver_preferences_screen.dart';
import 'package:new_version/views/staff/main_view.dart';

// Controllers
import 'package:new_version/controllers/settings/onboarding_controller.dart';
import 'package:new_version/controllers/map/map_controller.dart';
import 'package:new_version/controllers/driver/home_controller.dart';
import 'package:new_version/services/map_tile_cache_service.dart';

import 'package:new_version/controllers/driver/driver_preferences_controller.dart';
import 'package:new_version/controllers/staff/staff_controller.dart';
import 'package:new_version/controllers/staff/nav_controller.dart';
import 'package:new_version/controllers/staff/status_controller.dart';
import 'package:new_version/controllers/notification/notification_controller.dart';
import 'package:new_version/controllers/staff/timer_controller.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const intro = '/intro';
  static const driverMain = '/driver';
  static const driverPreferences = '/driver/preferences';
  static const tripTracking = '/trip-tracking';
  static const stationDetails = '/station-details';
  static const favorites = '/favorites';
  static const profile = '/profile';
  static const staffMain = '/staff';
  static const staffReports = '/staff/reports';
  static const crowdUpdatesLog = '/staff/crowd-log';
  static const crowdTimes = '/staff/crowd-times';

  static List<GetPage<dynamic>> pages = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MapController(), fenix: true);
      }),
    ),
    GetPage(
      name: intro,
      page: () => const IntroView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OnboardingController(), fenix: true);
      }),
    ),
    GetPage(
      name: driverMain,
      page: () => const DriverMainScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController(), fenix: true);
        // Driver-only map tile cache initialization
        Get.lazyPut<MapTileCacheService>(() => MapTileCacheService(), fenix: true);
      }),
    ),
    GetPage(
      name: driverPreferences,
      page: () => const DriverPreferencesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DriverPreferencesController>(
          () => DriverPreferencesController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: staffMain,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StaffController(), fenix: true);
        Get.lazyPut(() => NavController(), fenix: true);
        Get.lazyPut(() => StatusController(), fenix: true);
        Get.lazyPut(() => NotificationController(), fenix: true);
        Get.lazyPut(() => TimerController(), fenix: true);
      }),
    ),
  ];
}
