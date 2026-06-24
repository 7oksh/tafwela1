import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version/controllers/auth/auth_controller.dart';
import 'package:new_version/models/user_role.dart';

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            authController.signOut(UserRole.admin);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
