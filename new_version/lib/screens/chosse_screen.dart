import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'The_login.dart';

class ChooseScreen extends StatelessWidget {
  const ChooseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2A4A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF243656),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.local_gas_station,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'أهلاً بكم في تفويلة',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'اختر نوع الحساب للمتابعة',
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Color(0xFF8FA8C8),
                  fontSize: 15,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 36),

              _AccountTypeCard(
                icon: FluentIcons.vehicle_car_20_regular,
                title: 'سائق',
                subtitle: 'ابحث عن أقرب محطة وتجنب الزحمة',
                onTap: () {
                  Get.to(() => Login(), arguments: 1);
                },
              ),

              const SizedBox(height: 16),

              _AccountTypeCard(
                icon: FluentIcons.gas_pump_20_regular,
                title: 'موظف محطة',
                subtitle: 'قم بتحديث حالة الزدحمة في محطتك',
                onTap: () {
                  Get.to(() => Login(), arguments: 2);
                },
              ),

              const SizedBox(height: 16),

            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF243656),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 14),
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Color(0xFF8FA8C8),
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'اختيار الحساب',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }
}