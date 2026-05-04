import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime time;

  AppNotification({
    required this.title,
    required this.body,
    required this.time,
  });
}

class NotificationController extends GetxController {

  //  الدوت
  var hasNotification = false.obs;

  //  الليست
  var notifications = <AppNotification>[].obs;

  // toggle
  var notificationsEnabled = true.obs;

  //  init
  @override
  void onInit() {
    loadSettings();
    super.onInit();
  }

  //  تحميل الحالة
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notificationsEnabled.value =
        prefs.getBool("notifications_enabled") ?? true;
  }

  //  حفظ الحالة
  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notifications_enabled", value);
  }

  //  إضاف notification
  void addNotification(String title, String body) {
    notifications.insert(
      0,
      AppNotification(
        title: title,
        body: body,
        time: DateTime.now(),
      ),
    );

    hasNotification.value = true;
  }

  //  clear
  void clearNotifications() {
    hasNotification.value = false;
  }
}