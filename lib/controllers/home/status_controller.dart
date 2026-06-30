import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
}
