import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:new_version/controllers/staff_controller.dart';
import 'package:new_version/widgets/staff_profile/logout_button.dart';
import 'package:new_version/widgets/staff_profile/profile_header.dart';
import 'package:new_version/widgets/staff_profile/settings_section.dart';
import 'package:new_version/widgets/staff_profile/staff_info_card.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final staffCtrl = Get.find<StaffController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ملف الموظف',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileHeader(),
            const SizedBox(height: 100),
            Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          title: 'المحطة الحالية',
                          value: staffCtrl.stationName.value.isNotEmpty
                              ? staffCtrl.stationName.value
                              : '—',
                          icon: Icons.local_gas_station,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoCard(
                          title: 'رقم الموظف',
                          value: staffCtrl.staffCode.value.isNotEmpty
                              ? staffCtrl.staffCode.value
                              : '—',
                          icon: Icons.badge,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            SettingsSection(),
            const SizedBox(height: 20),
            LogoutButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
