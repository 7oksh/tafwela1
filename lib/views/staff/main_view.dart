import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:new_version/controllers/home/nav_controller.dart';
import 'package:new_version/controllers/staff_controller.dart';
import 'package:new_version/views/staff/home/crowd_times_view.dart';
import 'package:new_version/views/staff/home/staff_home_view.dart';
import 'package:new_version/views/staff/profile/profile_view.dart';
import 'package:new_version/widgets/common/custom_bottom_nav.dart';

import 'reports/staff_reports_view.dart';

class MainView extends StatelessWidget {
  MainView({super.key}) {
    Get.put(StaffController());
  }

  final navController = Get.put(NavController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (navController.currentIndex.value) {
          case 0:
            return StaffHomeView();
          case 1:
            return StaffReportsView();
          case 2:
            return CrowdTimesView();
          case 3:
            return const ProfileView();
          default:
            return StaffHomeView();
        }
      }),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
