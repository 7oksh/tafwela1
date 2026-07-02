import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version/controllers/home/nav_controller.dart';
import 'package:new_version/controllers/home/status_controller.dart';

import 'package:new_version/views/staff/home/staff_home_view.dart';
import 'package:new_version/views/staff/profile/profile_view.dart';
import 'package:new_version/views/staff/history/history_view.dart';
import 'package:new_version/views/staff/reports/reports_view.dart';
import 'package:new_version/widgets/common/custom_bottom_nav.dart';
import 'package:showcaseview/showcaseview.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late final NavController _navController;
  late final StatusController _statusCtrl;

  @override
  void initState() {
    super.initState();
    _navController = Get.find<NavController>();
    _statusCtrl    = Get.find<StatusController>();
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        // _statusCtrl.markShowcaseDone();
      },
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_statusCtrl.showcaseDone.value) {
            ShowCaseWidget.of(context).startShowCase([
              _statusCtrl.countdownKey,
              _statusCtrl.statusGridKey,
              _statusCtrl.updateBtnKey,
            ]);
          }
        });

        return Scaffold(
          body: Obx(() {
            switch (_navController.currentIndex.value) {
              case 0:
                return StaffHomeView();
              case 1:
                return HistoryView();
              case 2:
                return ReportsView();
              case 3:
                return const ProfileView();
              default:
                return StaffHomeView();
            }
          }),
          bottomNavigationBar: CustomBottomNav(),
        );
      },
    );
  }
}