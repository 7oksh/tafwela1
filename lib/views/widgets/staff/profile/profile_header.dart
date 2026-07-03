import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/staff/staff_controller.dart';
import 'package:new_version/views/staff/profile/edit_profile_view.dart';

ImageProvider _resolvePhoto(String value) {
  if (value.isEmpty) {
    return const AssetImage('lib/assets/images/profile.png');
  }
  if (value.startsWith('data:image')) {
    return MemoryImage(base64Decode(value.split(',').last));
  }
  return NetworkImage(value);
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final staffCtrl = Get.find<StaffController>();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Blue background
        Container(
          height: 140, // Increased height
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF1E3A5F),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        // Info Card
        Positioned(
          top: 80, // Lowered
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.only(top: 85, bottom: 25), // Increased padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Obx(() => Text(
                      staffCtrl.staffName.value.isNotEmpty
                          ? staffCtrl.staffName.value
                          : 'جاري التحميل...',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    )),
                const SizedBox(height: 6),
                Text(
                  'موظف محطة',
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Profile Picture
        Positioned(
          top: 30, // Lowered
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Get.to(() => const EditProfileView()),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    final url = staffCtrl.photoUrl.value;
                    return CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 54,
                        backgroundImage: _resolvePhoto(url),
                      ),
                    );
                  }),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => Get.to(() => const EditProfileView()),
                  child: Container(
                    padding: const EdgeInsets.all(8), // More space
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5A8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
