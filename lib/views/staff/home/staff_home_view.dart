import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/staff/status_controller.dart';
import 'package:new_version/controllers/staff/timer_controller.dart';
import 'package:new_version/views/widgets/staff/home/countdown_card.dart';
import 'package:new_version/views/widgets/staff/home/header_widget.dart';
import 'package:new_version/views/widgets/staff/home/status_card.dart';
import 'package:new_version/views/widgets/staff/home/warning_card.dart';
import 'package:showcaseview/showcaseview.dart';

class StaffHomeView extends StatefulWidget {
  const StaffHomeView({super.key});

  @override
  State<StaffHomeView> createState() => _StaffHomeViewState();
}

class _StaffHomeViewState extends State<StaffHomeView> {
  late final TimerController _timerCtrl;
  late final StatusController _statusCtrl;

  @override
  void initState() {
    super.initState();
    _timerCtrl = Get.find<TimerController>();
    _statusCtrl = Get.find<StatusController>();

    // ابدأ التايمر فقط عند دخول الموظف لصفحة الرئيسية
    _timerCtrl.startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeaderWidget(),

              // ── Showcase 1: CountdownCard ──
              Obx(
                () => Showcase(
                  key: _statusCtrl.countdownKey,
                  title: 'مؤقت التحديث',
                  description:
                      'بيحسب الوقت من آخر تحديث — لازم تحدث قبل ما الوقت ينتهي',
                  titleTextStyle: _titleStyle,
                  descTextStyle: _descStyle,
                  tooltipBackgroundColor: Colors.white,
                  child: CountdownCard(
                    minutes: _timerCtrl.minutes,
                    seconds: _timerCtrl.seconds,
                  ),
                ),
              ),

              // ── WarningCard (لو الوقت خلص) ──
              Obx(
                () => _timerCtrl.isFinished
                    ? Showcase(
                        key: _statusCtrl.warningKey,
                        title: 'تحذير!',
                        description:
                            'الوقت انتهى — السائقين محتاجين تحديث فوري للحالة',
                        titleTextStyle: _titleStyle.copyWith(color: Colors.red),
                        descTextStyle: _descStyle,
                        tooltipBackgroundColor: Colors.white,
                        child: const WarningCard(),
                      )
                    : const SizedBox(),
              ),

              const SizedBox(height: 10),

              // ── Showcase 2: Status Grid ──
              Showcase(
                key: _statusCtrl.statusGridKey,
                title: 'حالة الازدحام',
                description:
                    'اختار الحالة الحالية للمحطة عشان السائقين يشوفوها على الخريطة',
                titleTextStyle: _titleStyle,
                descTextStyle: _descStyle,
                tooltipBackgroundColor: Colors.white,
                targetBorderRadius: BorderRadius.circular(16),
                child: Obx(
                  () => GridView.count(
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
                        isSelected: _statusCtrl.isSelected("low"),
                        onTap: () => _statusCtrl.selectStatus("low"),
                      ),
                      StatusCard(
                        title: "متوسط",
                        icon: Icons.local_gas_station,
                        color: Colors.orange,
                        isSelected: _statusCtrl.isSelected("medium"),
                        onTap: () => _statusCtrl.selectStatus("medium"),
                      ),
                      StatusCard(
                        title: "مرتفع",
                        icon: Icons.local_gas_station,
                        color: Colors.red,
                        isSelected: _statusCtrl.isSelected("high"),
                        onTap: () => _statusCtrl.selectStatus("high"),
                      ),
                      StatusCard(
                        title: "لا يوجد وقود",
                        icon: Icons.block,
                        color: Colors.grey,
                        isSelected: _statusCtrl.isSelected("none"),
                        onTap: () => _statusCtrl.selectStatus("none"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Showcase 3: Update Button ──
              Obx(() {
                final isEnabled = _statusCtrl.selectedStatus.value.isNotEmpty;

                return Showcase(
                  key: _statusCtrl.updateBtnKey,
                  title: 'تحديث الحالة',
                  description:
                      'بعد ما تختار الحالة اضغط هنا عشان تبلغ كل السائقين فوراً',
                  titleTextStyle: _titleStyle,
                  descTextStyle: _descStyle,
                  tooltipBackgroundColor: Colors.white,
                  targetBorderRadius: BorderRadius.circular(30),
                  child: Padding(
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
                                  color: const Color(
                                    0xFF4A6CF7,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: isEnabled
                              ? () {
                                  _statusCtrl.updateStationStatus();
                                }
                              : null,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: isEnabled ? Colors.white : Colors.grey,
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
                  ),
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _titleStyle => GoogleFonts.cairo(
    color: const Color(0xFF1A1A2E),
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  TextStyle get _descStyle =>
      GoogleFonts.cairo(color: const Color(0xFF1A1A2E), fontSize: 13);
}
