import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // 1. استيراد المكتبة الجديدة
import 'package:new_version/models/notification_model.dart';

class NotificationController extends GetxController {
  // تعريف كائن GetStorage
  final box = GetStorage();

  // الدوت
  var hasNotification = false.obs;

  // الليست
  var notifications = <NotificationModel>[].obs;

  // toggle
  var notificationsEnabled = true.obs;

  // init
  @override
  void onInit() {
    super.onInit();
    loadSettings();

    // (إضافة اختيارية ممتازة): يمكنك جعل GetStorage يراقب التغييرات تلقائياً
    // box.listenKey('notifications_enabled', (value) {
    //   notificationsEnabled.value = value ?? true;
    // });
  }

  // تحميل الحالة (لاحظ إزالة Future و async لأن القراءة فورية)
  void loadSettings() {
    notificationsEnabled.value = box.read("notifications_enabled") ?? true;
  }

  // حفظ الحالة (لاحظ إزالة Future و await لأن الكتابة فورية)
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    box.write("notifications_enabled", value);
  }

  // إضافة notification
  void addNotification(String title, String body) {
    notifications.insert(
      0,
      NotificationModel(title: title, body: body, time: DateTime.now()),
    );
    hasNotification.value = true;
  }

  // clear
  void clearNotifications() {
    hasNotification.value = false;
  }
}
