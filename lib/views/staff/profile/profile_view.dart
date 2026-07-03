import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:new_version/controllers/staff/staff_controller.dart';
import 'package:new_version/views/widgets/staff/profile/logout_button.dart';
import 'package:new_version/views/widgets/staff/profile/profile_header.dart';
import 'package:new_version/views/widgets/staff/profile/settings_section.dart';
import 'package:new_version/views/widgets/staff/profile/staff_info_card.dart';

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
            
            // Increased spacing to account for the overlapping white card in ProfileHeader
            const SizedBox(height: 140),
            
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
                      const SizedBox(width: 16),
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
            
            const SizedBox(height: 24),
            
            // SettingsSection already has its own internal vertical margins
            SettingsSection(),
            
            const SizedBox(height: 10),
            
            LogoutButton(),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
