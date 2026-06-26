import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('تنبيه', 'فعّل الـ GPS من الإعدادات');
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('تنبيه', 'محتاج إذن الموقع عشان التطبيق يشتغل');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('تنبيه', 'افتح الإعدادات وفعّل إذن الموقع');
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  double distanceInKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final meters = Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
    return meters / 1000;
  }
}
