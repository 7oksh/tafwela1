import 'package:get/get.dart';

// Views
import 'package:new_version/views/splash/splash_view.dart';
import 'package:new_version/views/screens/driver_main_screen.dart';
import 'package:new_version/views/screens/driver_preferences_screen.dart';
import 'package:new_version/views/staff/main_view.dart';
import 'package:new_version/views/staff/home/crowd_times_view.dart';
import 'package:new_version/views/staff/home/crowd_updates_log_view.dart';
import 'package:new_version/views/staff/reports/staff_reports_view.dart';

// Splash Controllers
import 'package:new_version/controllers/settings/onboarding_controller.dart';
import 'package:new_version/controllers/map/map_controller.dart';

// Driver Controllers
import 'package:new_version/controllers/home_controller.dart';
import 'package:new_version/controllers/location_controller.dart';
import 'package:new_version/controllers/station_controller.dart';
import 'package:new_version/controllers/favorites_controller.dart';
import 'package:new_version/controllers/driver_profile_controller.dart';

// Staff Controllers
import 'package:new_version/controllers/staff_controller.dart';
import 'package:new_version/controllers/home/nav_controller.dart';
import 'package:new_version/controllers/home/status_controller.dart';
import 'package:new_version/controllers/notification/notification_controller.dart';
import 'package:new_version/controllers/home/timer_controller.dart';

import '../views/intro/intro_view.dart';

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
        Get.lazyPut(() => MapController());
      }),
    ),
    GetPage(
      name: intro,
      page: () => const IntroView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OnboardingController());
      }),
    ),
    GetPage(
      name: driverMain,
      page: () => const DriverMainScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => LocationController());
        Get.lazyPut(() => StationController());
        Get.lazyPut(() => FavoritesController());
        Get.lazyPut(() => DriverProfileController());
      }),
    ),
    GetPage(
      name: driverPreferences,
      page: () => const DriverPreferencesScreen(),
    ),
    GetPage(
      name: staffMain,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StaffController());
        Get.lazyPut(() => NavController());
        Get.lazyPut(() => StatusController());
        Get.lazyPut(() => NotificationController());
        Get.lazyPut(() => TimerController());
      }),
    ),
    GetPage(
      name: staffReports,
      page: () => const StaffReportsView(),
    ),
    GetPage(
      name: crowdUpdatesLog,
      page: () => const CrowdUpdatesLogView(),
    ),
    GetPage(
      name: crowdTimes,
      page: () => CrowdTimesView(),
    ),
  ];
}
