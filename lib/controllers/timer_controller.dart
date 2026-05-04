import 'dart:async';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../services/notification_service.dart';
import 'notification_controller.dart';

class TimerController extends GetxController {

  // الوقت يبدأ 5 دقائق
  RxInt remaining = (5 * 60).obs;

  Timer? timer;

  final notificationController =
  Get.find<NotificationController>();

  final player = AudioPlayer();

  bool hasPlayed = false;

  @override
  void onInit() {
    super.onInit();

    startTimer();
  }

  // تشغيل التايمر
  void startTimer() {

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (t) {

        if (remaining.value > 0) {

          remaining.value--;

        } else {

          t.cancel();

          if (!hasPlayed) {

            hasPlayed = true;

            playAlert();

            if (notificationController
                .notificationsEnabled.value) {

              NotificationService.showNotification(
                title: "⚠️ انتهى الوقت",
                body: "يرجى تنفيذ التحديث الآن",
              );

              notificationController.addNotification(
                "⚠️ انتهى الوقت",
                "يرجى تنفيذ التحديث الآن",
              );
            }
          }
        }
      },
    );
  }

  // إعادة التايمر لـ 5 دقائق
  void resetTimer() {

    timer?.cancel();

    hasPlayed = false;

    remaining.value = 5 * 60;

    startTimer();
  }

  Future<void> playAlert() async {

    try {

      await player.setAsset(
        'lib/assets/sounds/alert.mp3',
      );

      await player.play();

    } catch (e) {

      print("Audio error: $e");
    }
  }

  int get minutes => remaining.value ~/ 60;

  int get seconds => remaining.value % 60;

  bool get isFinished => remaining.value <= 0;

  @override
  void onClose() {

    timer?.cancel();

    player.dispose();

    super.onClose();
  }
}