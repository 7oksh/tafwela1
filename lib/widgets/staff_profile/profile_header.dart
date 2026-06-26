import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/staff_controller.dart';
import '../../views/staff/profile/edit_profile_view.dart';

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
        Container(
          height: 120,
          width: double.infinity,
          color: const Color(0xFF1E3A5F),
        ),

        Positioned(
          top: 60,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.only(top: 70, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    )),
                const SizedBox(height: 4),
                Text(
                  'موظف محطة',
                  style: GoogleFonts.cairo(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),


        Positioned(
          top: 20,
          child: Stack(
            children: [


              GestureDetector(
                onTap: () => Get.to(() => const EditProfileView()),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    final url = staffCtrl.photoUrl.value;
                    return CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 50,
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
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
