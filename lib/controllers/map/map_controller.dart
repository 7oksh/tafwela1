import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:new_version/utils/app_snackbar.dart';

class MapController extends GetxController {
  final currentPosition = Rx<Position?>(null);

  void setPosition(Position pos) {
    currentPosition.value = pos;
  }

  Future<void> requestPermissionAndLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppSnackbar.warning(
          'فعّل الـ GPS من الإعدادات',
          title: 'تنبيه',
          position: SnackPosition.BOTTOM,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppSnackbar.warning(
            'محتاج إذن الموقع عشان التطبيق يشتغل',
            title: 'تنبيه',
            position: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppSnackbar.warning(
          'افتح الإعدادات وفعّل إذن الموقع',
          title: 'تنبيه',
          position: SnackPosition.BOTTOM,
        );
        await Geolocator.openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      currentPosition.value = position;
    } on PlatformException catch (e) {
      AppSnackbar.error(
        'حدث خطأ في النظام: ${e.message}',
        title: 'خطأ',
        position: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppSnackbar.error(
        'تعذر الحصول على الموقع',
        title: 'خطأ',
        position: SnackPosition.BOTTOM,
      );
    }
  }
}
