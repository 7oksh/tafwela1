import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_version/utils/app_snackbar.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppSnackbar.warning('الرجاء تفعيل خدمة الموقع (GPS)', title: 'تنبيه');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppSnackbar.warning('تم رفض إذن الوصول للموقع', title: 'تنبيه');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppSnackbar.warning('إذن الموقع مرفوض نهائياً، يرجى تفعيله من الإعدادات', title: 'تنبيه');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } on PlatformException catch (e) {
      AppSnackbar.error('حدث خطأ في النظام: ${e.message}', title: 'خطأ في الموقع');
      return null;
    } catch (e) {
      AppSnackbar.error('تعذر الحصول على الموقع الحالي', title: 'خطأ');
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
