import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class DioExceptionHandler {
  static String handle(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهى وقت الاتصال بالخادم';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت';
      case DioExceptionType.badCertificate:
        return 'مشكلة في شهادة الأمان';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'طلب غير صالح';
          case 401:
            return 'غير مصرح لك بالدخول';
          case 403:
            return 'مرفوض';
          case 404:
            return 'غير موجود';
          case 408:
            return 'انتهى وقت الطلب';
          case 429:
            return 'طلبات كثيرة جداً، يرجى المحاولة لاحقاً';
          case 500:
            return 'خطأ في الخادم الداخلي';
          case 502:
            return 'بوابة غير صالحة';
          case 503:
            return 'الخدمة غير متوفرة';
          case 504:
            return 'انتهى وقت البوابة';
          default:
            return 'استجابة غير صالحة من الخادم';
        }
      case DioExceptionType.unknown:
      default:
        return 'حدث خطأ غير متوقع في الاتصال';
    }
  }
}

class FirebaseExceptionHandler {
  static String handle(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'كلمة المرور ضعيفة';
      case 'email-already-in-use':
        return 'الإيميل مسجل مسبقاً';
      case 'user-not-found':
        return 'الحساب غير موجود';
      case 'wrong-password':
        return 'كلمة المرور خطأ';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة';
      case 'invalid-email':
        return 'صيغة الإيميل غير صحيحة';
      case 'too-many-requests':
        return 'طلبات كثيرة جداً، يرجى المحاولة لاحقاً';
      case 'network-request-failed':
        return 'فشل الاتصال بالشبكة';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموح بها';
      case 'account-exists-with-different-credential':
        return 'هذا الإيميل مسجل بطريقة تسجيل أخرى';
      default:
        return 'خطأ: ${e.message}';
    }
  }
}
