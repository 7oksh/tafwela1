import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/nav_controller.dart';

class CustomBottomNav extends StatelessWidget {
  CustomBottomNav({super.key});

  final navController = Get.find<NavController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          item(Icons.home, "الرئيسية", 0),
          item(Icons.history, "السجل", 2),
          item(Icons.bar_chart, "التقارير", 1),
          item(Icons.person, "الملف", 3),
        ],
      ),
    ));
  }

  Widget item(IconData icon, String text, int index) {
    final isSelected = navController.currentIndex.value == index;

    return GestureDetector(
      onTap: () => navController.changeIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}