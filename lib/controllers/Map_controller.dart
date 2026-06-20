import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class MapController extends GetxController {
  final currentPosition = Rx<Position?>(null);

  void setPosition(Position pos) {
    currentPosition.value = pos;
  }

  Future<void> requestPermissionAndLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('تنبيه', 'فعّل الـ GPS من الإعدادات',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('تنبيه', 'محتاج إذن الموقع عشان التطبيق يشتغل',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('تنبيه', 'افتح الإعدادات وفعّل إذن الموقع',
          snackPosition: SnackPosition.BOTTOM);
      await Geolocator.openAppSettings();
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentPosition.value = position;
  }
}