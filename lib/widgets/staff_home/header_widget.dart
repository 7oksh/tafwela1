import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:new_version/controllers/home/nav_controller.dart';
import 'package:new_version/controllers/notification/notification_controller.dart';
import 'package:new_version/views/staff/notifications/notifications_view.dart';

class HeaderWidget extends StatelessWidget {
  HeaderWidget({super.key});

  final notificationController = Get.put(NotificationController());
  final navController = Get.find<NavController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 40, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A5F),
            Color(0xFF2A4D7A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                // avatar
                GestureDetector(
                  onTap: () {
                    navController.changeIndex(3);
                  },
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),

                const SizedBox(width: 12),

                // text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "أهلاً، أحمد محمد",
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                      Text(
                        "محطة توتال - المعادي",
                        style: GoogleFonts.cairo(color: Colors.white70),
                      ),
                      Text(
                        "STF-992#",
                        style: GoogleFonts.cairo(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          //  notification
          Obx(() => GestureDetector(
    onTap: () {
    notificationController.clearNotifications();
    Get.to(() => const NotificationsView());
    },
    child: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white.withOpacity(0.1),
    ),
    child: Stack(
    children: [
    const Icon(Icons.notifications, color: Colors.white),
    if (notificationController.hasNotification.value)
    Positioned(
    right: 0,
    top: 0,
    child: Container(
    width: 8,
    height: 8,
    decoration: const BoxDecoration(
    color: Colors.red,
    shape: BoxShape.circle,
    ),
    ),
    ),
    ],
    ),
    ),
    )),
        ],
      )
    );
  }
}
