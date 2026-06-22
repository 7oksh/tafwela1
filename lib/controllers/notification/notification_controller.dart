import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_version/models/notification_model.dart';

class NotificationController extends GetxController {

  // الدوت
  var hasNotification = false.obs;

  // الليست
  var notifications = <NotificationModel>[].obs;

  // toggle
  var notificationsEnabled = true.obs;

  // init
  @override
  void onInit() {
    loadSettings();
    super.onInit();
  }

  // تحميل الحالة
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled.value =
        prefs.getBool("notifications_enabled") ?? true;
  }

  // حفظ الحالة
  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notifications_enabled", value);
  }

  // إضافة notification
  void addNotification(String title, String body) {
    notifications.insert(
      0,
      NotificationModel(
        title: title,
        body: body,
        time: DateTime.now(),
      ),
    );
    hasNotification.value = true;
  }

  // clear
  void clearNotifications() {
    hasNotification.value = false;
  }
}
