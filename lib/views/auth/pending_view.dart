import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_view.dart';

class PendingView extends StatelessWidget {
  const PendingView({super.key});

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
              const Icon(Icons.hourglass_top, size: 80, color: Color(0xFF1A2A4A)),
              const SizedBox(height: 24),
              const Text(
                'في انتظار الموافقة',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2A4A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'تم استلام طلبك، سيتم مراجعته والموافقة عليه قريباً',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(() => LoginView());
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
