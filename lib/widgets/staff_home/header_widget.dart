import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:new_version/controllers/home/nav_controller.dart';
import 'package:new_version/controllers/notification/notification_controller.dart';
import 'package:new_version/controllers/staff_controller.dart';
import 'package:new_version/views/staff/notifications/notifications_view.dart';

Widget _buildAvatarImage(String value) {
  if (value.startsWith('data:image')) {
    final bytes = base64Decode(value.split(',').last);
    return Image.memory(bytes, fit: BoxFit.cover);
  }
  return Image.network(
    value,
    fit: BoxFit.cover,
    errorBuilder: (ctx, e, _) =>
        const Icon(Icons.person, color: Colors.white),
  );
}

class HeaderWidget extends StatelessWidget {
  HeaderWidget({super.key});

  final notificationController = Get.put(NotificationController());
  final navController = Get.find<NavController>();

  @override
  Widget build(BuildContext context) {
    final staffCtrl = Get.find<StaffController>();

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 40, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2A4D7A)],
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
                // Avatar — tapping navigates to profile tab
                GestureDetector(
                  onTap: () => navController.changeIndex(3),
                  child: Obx(() {
                    final url = staffCtrl.photoUrl.value;
                    return Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: url.isNotEmpty
                            ? _buildAvatarImage(url)
                            : const Icon(Icons.person,
                                color: Colors.white),
                      ),
                    );
                  }),
                ),

                const SizedBox(width: 12),

                // Name / station / code
                Expanded(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staffCtrl.staffName.value.isNotEmpty
                                ? 'أهلاً، ${staffCtrl.staffName.value}'
                                : 'أهلاً...',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            staffCtrl.stationName.value.isNotEmpty
                                ? staffCtrl.stationName.value
                                : '—',
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            staffCtrl.staffCode.value.isNotEmpty
                                ? staffCtrl.staffCode.value
                                : '',
                            style: GoogleFonts.cairo(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Notification bell
          Obx(() => GestureDetector(
                onTap: () {
                  notificationController.clearNotifications();
                  Get.to(() => const NotificationsView());
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
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
      ),
    );
  }
}
