import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_version/controllers/notification/notification_controller.dart';
import 'package:new_version/views/widgets/staff/home/notification_item.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        title: Text(
          "الإشعارات",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: () => controller.notifications.clear(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "لا توجد إشعارات حالياً",
                  style: GoogleFonts.cairo(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NotificationItem(
                title: "${notification.title}: ${notification.body}",
                time: DateFormat('HH:mm').format(notification.time),
              ),
            );
          },
        );
      }),
    );
  }
}
