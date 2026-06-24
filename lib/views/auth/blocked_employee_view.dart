import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version/models/user_role.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_version/controllers/auth/auth_controller.dart';

class BlockedEmployeeView extends StatelessWidget {
  const BlockedEmployeeView({super.key});

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/201004566145?text=مرحباً، أريد الاستفسار عن سبب إيقاف الحساب.');
    if (!await launchUrl(url)) {
      Get.snackbar('خطأ', 'لا يمكن فتح واتساب');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Color(0xFF1A2A4A)),
              const SizedBox(height: 24),
              const Text(
                'تم إيقاف الحساب',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2A4A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'تم إيقاف حساب الموظف بواسطة الإدارة.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _launchWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text(
                  'التواصل عبر واتساب',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.find<AuthController>().signOut(UserRole.customer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2A4A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
