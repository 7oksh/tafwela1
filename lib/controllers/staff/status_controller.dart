import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_version/controllers/staff/staff_controller.dart';
import 'package:new_version/controllers/staff/timer_controller.dart';
import 'package:new_version/controllers/staff/history_controller.dart';
import 'package:new_version/controllers/staff/reports_controller.dart';
import 'package:new_version/services/local_database_service.dart';
import 'package:new_version/database/entities/staff_history_entity.dart';
import 'package:new_version/utils/app_snackbar.dart';

class StatusController extends GetxController {
  var selectedStatus = "".obs;
  final showcaseDone = false.obs;

  final box = Get.find<GetStorage>();

  // ── Showcase Keys ──
  final GlobalKey countdownKey = GlobalKey();
  final GlobalKey statusGridKey = GlobalKey();
  final GlobalKey updateBtnKey = GlobalKey();
  final GlobalKey warningKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    _loadShowcaseStatus();
  }

  void _loadShowcaseStatus() {
    showcaseDone.value = box.read('staff_showcase_done') ?? false;
  }

  Future<void> markShowcaseDone() async {
    showcaseDone.value = true;
    await box.write('staff_showcase_done', true);
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
  }

  bool isSelected(String status) {
    return selectedStatus.value == status;
  }

  Future<void> updateStationStatus() async {
    final staffCtrl = Get.find<StaffController>();
    
    // Ensure StaffController is initialized and profile is loaded
    if (!staffCtrl.isInitialized.value) {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      int retry = 0;
      while (!staffCtrl.isInitialized.value && retry < 20) {
        await Future.delayed(const Duration(milliseconds: 500));
        retry++;
      }
      if (Get.isDialogOpen ?? false) Get.back();
    }

    if (staffCtrl.stationName.value.isEmpty) {
      await staffCtrl.loadProfile();
    }

    final stationName = staffCtrl.stationName.value.trim();
    
    if (stationName.isEmpty) {
      AppSnackbar.error('اسم المحطة غير متوفر. يرجى مراجعة بيانات الحساب.', title: 'خطأ');
      return;
    }
    
    if (selectedStatus.value.isEmpty) {
      AppSnackbar.error('يرجى اختيار حالة أولاً', title: 'خطأ');
      return;
    }

    final timerCtrl = Get.find<TimerController>();
    
    // Check if LocalDatabaseService is ready
    if (!Get.isRegistered<LocalDatabaseService>()) {
       try {
         final dbService = LocalDatabaseService();
         await dbService.init();
         Get.put(dbService, permanent: true);
       } catch (e) {
         AppSnackbar.error('فشل في تهيئة قاعدة البيانات المحلية', title: 'خطأ');
         return;
       }
    }
    final dbService = Get.find<LocalDatabaseService>();

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final stationRef = FirebaseFirestore.instance.collection('stations').doc(stationName);
      final docSnapshot = await stationRef.get();

      if (!docSnapshot.exists) {
        if (Get.isDialogOpen ?? false) Get.back();
        print("Station document not found: '$stationName'");
        AppSnackbar.error('لم يتم العثور على وثيقة المحطة باسم "$stationName" في قاعدة البيانات.', title: 'خطأ');
        return;
      }

      final oldStatus = docSnapshot.data()?['status'] ?? docSnapshot.data()?['crowdStatus'] ?? 'none';
      final newStatus = selectedStatus.value;
        
      await stationRef.update({
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': staffCtrl.staffUid.value,
      });

      // Update Local Database
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final duration = 300 - timerCtrl.remaining.value;

      await dbService.addHistory(StaffHistoryEntity(
        stationName: stationName,
        staffId: staffCtrl.staffUid.value,
        staffName: staffCtrl.staffName.value,
        oldStatus: oldStatus,
        newStatus: newStatus,
        updateTime: timeStr,
        updateDate: dateStr,
        responseDurationSeconds: duration,
      ));

      // Refresh other controllers if they are active in memory
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().loadHistory();
      }
      if (Get.isRegistered<ReportsController>()) {
        Get.find<ReportsController>().loadReports();
      }

      if (Get.isDialogOpen ?? false) Get.back(); // close dialog
      AppSnackbar.success('تم تحديث حالة المحطة بنجاح', title: 'نجاح');
      
      timerCtrl.resetTimer();
      selectedStatus.value = ''; // Reset selection
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back(); // close dialog
      print("Update error: $e");
      AppSnackbar.error('فشل في تحديث الحالة: $e', title: 'خطأ');
    }
  }
}
