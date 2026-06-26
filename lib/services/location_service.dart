import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('تنبيه', 'الرجاء تفعيل خدمة الموقع (GPS)');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('تنبيه', 'تم رفض إذن الوصول للموقع');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('تنبيه', 'إذن الموقع مرفوض نهائياً، يرجى تفعيله من الإعدادات');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } on PlatformException catch (e) {
      Get.snackbar('خطأ في الموقع', 'حدث خطأ في النظام: ${e.message}');
      return null;
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر الحصول على الموقع الحالي');
      return null;
    }
  }

  double distanceInKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    try {
      final meters = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
      return meters / 1000;
    } catch (e) {
      return 0;
    }
  }
}
