import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static String? _lastMessage;
  static DateTime? _lastTime;

  static void error(
      String message, {
        String? title,
        Color? backgroundColor,
        Color? textColor,
        Duration? duration,
        SnackPosition? position,
      }) {
    _show(
      title: title ?? 'خطأ',
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: duration,
      position: position,
    );
  }

  static void success(
      String message, {
        String? title,
        Color? backgroundColor,
        Color? textColor,
        Duration? duration,
        SnackPosition? position,
      }) {
    _show(
      title: title ?? 'نجاح',
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: duration,
      position: position,
    );
  }

  static void warning(
      String message, {
        String? title,
        Color? backgroundColor,
        Color? textColor,
        Duration? duration,
        SnackPosition? position,
      }) {
    _show(
      title: title ?? 'تنبيه',
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: duration,
      position: position,
    );
  }

  static void _show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration? duration,
    SnackPosition? position,
  }) {
    final now = DateTime.now();

    // منع التكرار (spam)
    if (_lastMessage == message &&
        _lastTime != null &&
        now.difference(_lastTime!).inMilliseconds < 800) {
      return;
    }

    _lastMessage = message;
    _lastTime = now;

    // اقفل الحالي
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    // 🔥 أهم تعديل هنا
    SnackPosition finalPosition;

    if (position != null) {
      // لو developer محدد position → استخدمه
      finalPosition = position;
    } else {
      // لو مفيش → خليك smart مع الكيبورد
      final context = Get.context;
      final bottomInset = context != null
          ? MediaQuery.of(context).viewInsets.bottom
          : 0.0;

      finalPosition = bottomInset > 0
          ? SnackPosition.TOP
          : SnackPosition.BOTTOM;
    }

    // ⏱ duration default
    final finalDuration = duration ?? const Duration(seconds: 2);

    Get.snackbar(
      title,
      message,
      snackPosition: finalPosition,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: finalDuration,
    );
  }
}