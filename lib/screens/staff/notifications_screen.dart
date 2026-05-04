import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/staff_home/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      "تم تحديث حالة المحطة إلى مزدحم",
      "لا يوجد وقود بنزين 92",
      "تم تغيير الحالة إلى متوسط",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        title: Text(
          "الإشعارات",
          style: GoogleFonts.cairo(),
        ),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NotificationItem(
              title: notifications[index],
              time: "${(index + 1) * 5} min",
            ),
          );
        },
      ),
    );
  }
}
