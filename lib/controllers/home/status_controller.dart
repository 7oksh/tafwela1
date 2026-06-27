import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusController extends GetxController {
  var selectedStatus = "".obs;
  final showcaseDone = false.obs;

  // ── Showcase Keys ──
  final GlobalKey countdownKey  = GlobalKey();
  final GlobalKey statusGridKey = GlobalKey();
  final GlobalKey updateBtnKey  = GlobalKey();
  final GlobalKey warningKey    = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    _loadShowcaseStatus();
  }

  Future<void> _loadShowcaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    showcaseDone.value = prefs.getBool('staff_showcase_done') ?? false;
  }

  Future<void> markShowcaseDone() async {
    showcaseDone.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('staff_showcase_done', true);
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
  }

  bool isSelected(String status) {
    return selectedStatus.value == status;
  }
}