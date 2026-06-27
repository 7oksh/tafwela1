import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  final currentTab = 0.obs;
  final showListView = false.obs;
  final showcaseDone = false.obs;


  final GlobalKey mapKey       = GlobalKey();
  final GlobalKey searchKey    = GlobalKey();
  final GlobalKey filterKey    = GlobalKey();
  final GlobalKey favTabKey    = GlobalKey();
  final GlobalKey markerKey    = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    _loadShowcaseStatus();
  }

  Future<void> _loadShowcaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    showcaseDone.value = prefs.getBool('showcase_done') ?? false;
  }

  Future<void> markShowcaseDone() async {
    showcaseDone.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showcase_done', true);
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