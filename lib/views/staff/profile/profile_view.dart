import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:new_version/widgets/staff_profile/logout_button.dart';
import 'package:new_version/widgets/staff_profile/profile_header.dart';
import 'package:new_version/widgets/staff_profile/settings_section.dart';
import 'package:new_version/widgets/staff_profile/staff_info_card.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "ملف الموظف",
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
            // profile pic
            const ProfileHeader(),
            const SizedBox(height: 100),
            // المحطة - رقم الموظف
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Expanded(
                    child: InfoCard(
                      title: "المحطة الحالية",
                      value: "محطة النور - جدة",
                      icon: Icons.local_gas_station,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: InfoCard(
                      title: "رقم الموظف",
                      value: "#STAFF-8842",
                      icon: Icons.badge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SettingsSection(),
            const SizedBox(height: 20),
            const LogoutButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
