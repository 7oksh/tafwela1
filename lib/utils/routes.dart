import 'package:get/get.dart';
import 'package:new_version/views/screens/driver_main_screen.dart';
import 'package:new_version/views/screens/driver_preferences_screen.dart';
import 'package:new_version/views/staff/home/crowd_times_view.dart';
import 'package:new_version/views/staff/home/crowd_updates_log_view.dart';
import 'package:new_version/views/staff/reports/staff_reports_view.dart';

abstract final class AppRoutes {
  static const driverMain = '/driver';
  static const driverPreferences = '/driver/preferences';
  static const tripTracking = '/trip-tracking';
  static const stationDetails = '/station-details';
  static const favorites = '/favorites';
  static const profile = '/profile';
  static const staffReports = '/staff/reports';
  static const crowdUpdatesLog = '/staff/crowd-log';
  static const crowdTimes = '/staff/crowd-times';

  static List<GetPage<dynamic>> pages = [
    GetPage(name: driverMain, page: () => const DriverMainScreen()),
    GetPage(
        name: driverPreferences,
        page: () => const DriverPreferencesScreen()),
    GetPage(
        name: staffReports, page: () => const StaffReportsView()),
    GetPage(
        name: crowdUpdatesLog,
        page: () => const CrowdUpdatesLogView()),
    GetPage(
        name: crowdTimes,
        page: () => CrowdTimesView()),
  ];
}
