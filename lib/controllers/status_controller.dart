import 'package:get/get.dart';

class StatusController extends GetxController {
  var selectedStatus = "".obs;

  void selectStatus(String status) {
    selectedStatus.value = status;
  }

  bool isSelected(String status) {
    return selectedStatus.value == status;
  }
}