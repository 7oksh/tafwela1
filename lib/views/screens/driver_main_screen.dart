import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version/controllers/driver_profile_controller.dart';
import 'package:new_version/controllers/favorites_controller.dart';
import 'package:new_version/controllers/home_controller.dart';
import 'package:new_version/controllers/location_controller.dart';
import 'package:new_version/controllers/station_controller.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/views/screens/favorites_screen.dart';
import 'package:new_version/views/screens/home_screen.dart';
import 'package:new_version/views/screens/profile_screen.dart';
import 'package:new_version/views/widgets/driver_bottom_nav.dart';

class DriverMainScreen extends StatelessWidget {
  const DriverMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) Get.put(HomeController());
    if (!Get.isRegistered<LocationController>()) Get.put(LocationController());
    if (!Get.isRegistered<StationController>()) Get.put(StationController());
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController());
    }
    if (!Get.isRegistered<DriverProfileController>()) {
      Get.put(DriverProfileController());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        switch (Get.find<HomeController>().currentTab.value) {
          case 0:
          case 1:
            return const HomeScreen();
          case 2:
            return const FavoritesScreen(showBackButton: false);
          case 3:
            return const ProfileScreen(showBackButton: false);
          default:
            return const HomeScreen();
        }
      }),
      bottomNavigationBar: const DriverBottomNav(),
    );
  }
}
