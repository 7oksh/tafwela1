import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService extends GetxService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<BiometricAuthService> init() async {
    return this;
  }

  /// Check if the device has biometric capabilities OR device credentials (PIN/Pattern/Password).
  Future<bool> isAuthenticationAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      return false;
    }
  }

  /// Authenticate using biometrics or device credentials.
  /// Returns `true` if authentication succeeded.
  /// If device has no screen lock, it shows a friendly snackbar and returns `false`.
  Future<bool> authenticate({String reason = 'يرجى تأكيد هويتك للمتابعة'}) async {
    final bool isAvailable = await isAuthenticationAvailable();
    if (!isAvailable) {
      Get.snackbar(
        'مطلوب قفل الشاشة',
        'لحمايتك، يرجى تفعيل قفل الشاشة (بصمة، وجه، رمز، أو نمط) في إعدادات جهازك قبل تغيير كلمة المرور.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled' || e.code == 'PasscodeNotSet') {
        Get.snackbar(
          'مطلوب قفل الشاشة',
          'لحمايتك، يرجى تفعيل قفل الشاشة (بصمة، وجه، رمز، أو نمط) في إعدادات جهازك قبل تغيير كلمة المرور.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        Get.snackbar(
          'خطأ في المصادقة',
          'تم قفل المصادقة بسبب محاولات فاشلة كثيرة. يرجى المحاولة لاحقاً.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء المصادقة. يرجى المحاولة مرة أخرى.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    } catch (e) {
      print('exception on authenticate');
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
