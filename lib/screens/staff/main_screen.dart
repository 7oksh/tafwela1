import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/screens/staff/profile_screen.dart';

import '../../controllers/nav_controller.dart';



import '../../widgets/custom_bottom_nav.dart';
import 'staff_home_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final navController = Get.put(NavController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (navController.currentIndex.value) {
          case 0:
            return StaffHomeScreen();
          case 1:
            return Center(child: Text("التقارير", style: GoogleFonts.cairo()));
          case 2:
            return Center(child: Text("السجل", style: GoogleFonts.cairo()));
          case 3:
            return const ProfileScreen();
          default:
            return StaffHomeScreen();
        }
      }),

      bottomNavigationBar: CustomBottomNav(),
    );
  }
}
