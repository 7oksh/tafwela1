import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/home/nav_controller.dart';
import 'package:new_version/controllers/home/status_controller.dart';
import 'package:new_version/controllers/staff_controller.dart';
import 'package:new_version/views/staff/home/crowd_times_view.dart';
import 'package:new_version/views/staff/home/staff_home_view.dart';
import 'package:new_version/views/staff/profile/profile_view.dart';
import 'package:new_version/widgets/common/custom_bottom_nav.dart';
import 'package:showcaseview/showcaseview.dart';
import 'reports/staff_reports_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late final NavController _navController;
  late final StatusController _statusCtrl;

  @override
  void initState() {
    super.initState();
    Get.put(StaffController());
    _navController = Get.put(NavController());
    _statusCtrl    = Get.find<StatusController>();
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        // اختياري — لو عايز تحفظ إن الـ tour خلص
        // _statusCtrl.markShowcaseDone();
      },
      builder: (context) {
        // ── ابدأ الـ Showcase بعد الـ build مباشرة ──
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_statusCtrl.showcaseDone.value) {
            ShowCaseWidget.of(context).startShowCase([
              _statusCtrl.countdownKey,
              _statusCtrl.statusGridKey,
              _statusCtrl.updateBtnKey,
            ]);
          }
        });

        return Scaffold(
          body: Obx(() {
            switch (_navController.currentIndex.value) {
              case 0:
                return StaffHomeView();
              case 1:
                return StaffReportsView();
              case 2:
                return CrowdTimesView();
              case 3:
                return const ProfileView();
              default:
                return StaffHomeView();
            }
          }),
          bottomNavigationBar: CustomBottomNav(),
        );
      },
    );
  }
}