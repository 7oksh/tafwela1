import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:new_version/utils/app_snackbar.dart';

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
      AppSnackbar.warning(
        'لحمايتك، يرجى تفعيل قفل الشاشة (بصمة، وجه، رمز، أو نمط) في إعدادات جهازك قبل تغيير كلمة المرور.',
        title: 'مطلوب قفل الشاشة',
        position: SnackPosition.BOTTOM,
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
        AppSnackbar.warning(
          'لحمايتك، يرجى تفعيل قفل الشاشة (بصمة، وجه، رمز، أو نمط) في إعدادات جهازك قبل تغيير كلمة المرور.',
          title: 'مطلوب قفل الشاشة',
          position: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        AppSnackbar.error(
          'تم قفل المصادقة بسبب محاولات فاشلة كثيرة. يرجى المحاولة لاحقاً.',
          title: 'خطأ في المصادقة',
          position: SnackPosition.BOTTOM,
        );
      } else {
        AppSnackbar.error(
          'حدث خطأ أثناء المصادقة. يرجى المحاولة مرة أخرى.',
          title: 'خطأ',
          position: SnackPosition.BOTTOM,
        );
      }
      return false;
    } catch (e) {
      print('exception on authenticate');
      AppSnackbar.error(
        'حدث خطأ غير متوقع.',
        title: 'خطأ',
        position: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
