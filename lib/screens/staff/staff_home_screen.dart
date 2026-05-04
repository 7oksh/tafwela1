import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/status_controller.dart';
import '../../controllers/timer_controller.dart';
import '../../widgets/staff_home/countdown_card.dart';
import '../../widgets/staff_home/header_widget.dart';
import '../../widgets/staff_home/status_card.dart';
import '../../widgets/staff_home/warning_card.dart';

class StaffHomeScreen extends StatelessWidget {
  StaffHomeScreen({super.key});

  final timerController = Get.put(TimerController());
  final statusController = Get.find<StatusController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeaderWidget(),

              Obx(() => CountdownCard(
                minutes: timerController.minutes,
                seconds: timerController.seconds,
              )),

              Obx(() => timerController.isFinished
                  ? const WarningCard()
                  : const SizedBox()),

              const SizedBox(height: 10),


              Obx(() => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  StatusCard(
                    title: "منخفض",
                    icon: Icons.local_gas_station,
                    color: Colors.green,
                    isSelected:
                    statusController.isSelected("low"),
                    onTap: () =>
                        statusController.selectStatus("low"),
                  ),
                  StatusCard(
                    title: "متوسط",
                    icon: Icons.local_gas_station,
                    color: Colors.orange,
                    isSelected:
                    statusController.isSelected("medium"),
                    onTap: () =>
                        statusController.selectStatus("medium"),
                  ),
                  StatusCard(
                    title: "مرتفع",
                    icon: Icons.local_gas_station,
                    color: Colors.red,
                    isSelected:
                    statusController.isSelected("high"),
                    onTap: () =>
                        statusController.selectStatus("high"),
                  ),
                  StatusCard(
                    title: "لا يوجد وقود",
                    icon: Icons.block,
                    color: Colors.grey,
                    isSelected:
                    statusController.isSelected("none"),
                    onTap: () =>
                        statusController.selectStatus("none"),
                  ),
                ],
              )),

              const SizedBox(height: 20),


              Obx(() {
                final isEnabled =
                    statusController.selectedStatus.value.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: isEnabled
                          ? const Color(0xFF4A6CF7)
                          : const Color(0xFFE5E7EB),
                      boxShadow: isEnabled
                          ? [
                        BoxShadow(
                          color: const Color(0xFF4A6CF7).withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ]
                          : [],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: isEnabled
                            ? () {
                          timerController.resetTimer();
                          // update
                        }
                            : null,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: isEnabled
                                    ? Colors.white
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isEnabled
                                    ? "تحديث الحالة الآن"
                                    : "اختر الحالة أولاً",
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isEnabled
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              })

            ],
          ),
        ),
      ),
    );
  }
}
