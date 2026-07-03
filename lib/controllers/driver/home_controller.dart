import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_version/controllers/driver/station_controller.dart';
import 'package:new_version/services/connectivity_service.dart';

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

  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    final connectivity = Get.find<ConnectivityService>();
    _wasOffline = !connectivity.isConnected.value;
    ever(connectivity.isConnected, (connected) {
      if (connected == true && _wasOffline) {
        _reloadOnReconnect();
      }
      _wasOffline = connected != true;
    });
    _loadShowcaseStatus();
  }

  void _reloadOnReconnect() {
    if (Get.isRegistered<StationController>()) {
      Get.find<StationController>().loadStations();
    }
  }

  void _loadShowcaseStatus() {
    showcaseDone.value = box.read('home_showcase_done') ?? false;
  }

  Future<void> markShowcaseDone() async {
    showcaseDone.value = true;
    await box.write('home_showcase_done', true);
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