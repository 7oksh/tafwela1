import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentTab = 0.obs;
  final showListView = false.obs;

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
