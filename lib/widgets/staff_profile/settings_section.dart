import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:new_version/controllers/notification/notification_controller.dart';
import 'package:new_version/views/staff/profile/change_password_view.dart';

class SettingsSection extends StatelessWidget {

  SettingsSection({super.key});

  final controller =
  Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),

      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(0.05),

            blurRadius: 15,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(

        children: [

          /// Notifications
          _settingItem(

            title: "تنبيهات النظام",

            subtitle:
            "تحديثات المحطة والرسائل",

            icon:
            Icons.notifications_none,

            trailing: Obx(() => Switch(

              value: controller
                  .notificationsEnabled
                  .value,

              onChanged: (val) {

                controller
                    .toggleNotifications(
                  val,
                );
              },
            )),
          ),

          _divider(),

          /// Password
          _settingItem(

            title:
            "كلمة المرور والأمان",

            subtitle:
            "تغيير الرمز السري",

            icon:
            Icons.shield_outlined,

            onTap: () {

              Get.to(
                    () =>
                    ChangePasswordView(),
              );
            },
          ),

          _divider(),

          /// Language
          _settingItem(

            title: "اللغة",

            subtitle:
            "العربية (المملكة العربية السعودية)",

            icon: Icons.language,

            onTap: () {

              // language screen
            },
          ),
        ],
      ),
    );
  }

  Widget _settingItem({

    required String title,

    required String subtitle,

    required IconData icon,

    Widget? trailing,

    VoidCallback? onTap,
  }) {

    return InkWell(

      onTap: onTap,

      child: Padding(

        padding:
        const EdgeInsets.symmetric(

          horizontal: 16,

          vertical: 14,
        ),

        child: Row(

          children: [

            // Icon
            Container(

              padding:
              const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color:
                Colors.grey.shade100,

                shape: BoxShape.circle,
              ),

              child: Icon(

                icon,

                color:
                Colors.grey.shade700,
              ),
            ),

            const SizedBox(width: 12),

            // Text
            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.end,

                children: [

                  Text(

                    title,

                    style:
                    GoogleFonts.cairo(

                      fontSize: 16,

                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  Text(

                    subtitle,

                    style:
                    GoogleFonts.cairo(

                      fontSize: 13,

                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Trailing
            trailing ??

                Icon(

                  Icons.arrow_back_ios_new,

                  size: 16,

                  color: Colors.grey,
                ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {

    return Divider(

      height: 1,

      thickness: 0.6,

      color: Colors.grey.shade200,
    );
  }
}