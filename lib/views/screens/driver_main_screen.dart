import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version/controllers/home_controller.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/views/screens/favorites_screen.dart';
import 'package:new_version/views/screens/home_screen.dart';
import 'package:new_version/views/screens/profile_screen.dart';
import 'package:new_version/views/widgets/driver_bottom_nav.dart';
import 'package:showcaseview/showcaseview.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  late HomeController _homeCtrl;

  @override
  void initState() {
    super.initState();
    _homeCtrl = Get.find<HomeController>();

    ShowcaseView.register(
      onFinish: () => _homeCtrl.markShowcaseDone(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_homeCtrl.showcaseDone.value) {
        ShowcaseView.get().startShowCase([
          _homeCtrl.mapKey,
          _homeCtrl.searchKey,
          _homeCtrl.filterKey,
          _homeCtrl.markerKey,
          _homeCtrl.favTabKey,
        ]);
      }
    });
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        switch (_homeCtrl.currentTab.value) {
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