import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:new_version/controllers/auth/auth_controller.dart';
import 'package:new_version/models/user_role.dart';

class LogoutButton extends StatelessWidget {
  LogoutButton({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // TODO: logout action
          authController.signOut(UserRole.staff);
        },
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "تسجيل الخروج",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}