import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final currentTab = 0.obs;
  final showListView = false.obs;
  final showcaseDone = false.obs;

  final box = Get.find<GetStorage>();

  final GlobalKey mapKey = GlobalKey();
  final GlobalKey searchKey = GlobalKey();
  final GlobalKey filterKey = GlobalKey();
  final GlobalKey favTabKey = GlobalKey();
  final GlobalKey markerKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    _loadShowcaseStatus();
  }

  void _loadShowcaseStatus() {
    showcaseDone.value = box.read('showcase_done') ?? false;
  }

  Future<void> markShowcaseDone() async {
    showcaseDone.value = true;
    await box.write('showcase_done', true);
  }

  void changeTab(int index) {
    currentTab.value = index;

    if (index == 1) {
      showListView.value = true;
    } else if (index == 0) {
      showListView.value = false;
    }
  }

  void toggleListView() => showListView.toggle();
}