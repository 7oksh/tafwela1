import 'package:geolocator/geolocator.dart';

/// خدمة التعامل مع صلاحيات وموقع المستخدم
class LocationService {
  /// طلب صلاحية الموقع أولاً (عشان نافذة الصلاحية تظهر فعلاً)
  /// ثم التحقق من تشغيل خدمة الموقع
  Future<bool> _ensurePermission() async {
    // 1) نطلب صلاحية التطبيق أولاً (لو مطلوبة) عشان الـ dialog يظهر
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // 2) بعد ما الصلاحية ممنوحة، نتأكد إن خدمة الموقع مفعّلة على الجهاز
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    return true;
  }

  /// إرجاع موقع المستخدم الحالي أو null في حالة الخطأ / الرفض
  Future<Position?> getCurrentPosition() async {
    try {
      final ok = await _ensurePermission();
      if (!ok) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
  }
}

