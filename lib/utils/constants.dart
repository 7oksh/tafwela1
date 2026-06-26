import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF0B245B);
  static const navyDark = Color(0xFF1A2A4A);
  static const navyHeader = Color(0xFF1E3A5F);
  static const primaryBlue = Color(0xFF245DFF);
  static const accentBlue = Color(0xFF4A6CF7);
  static const background = Color(0xFFF5F7FA);
  static const cardBackground = Color(0xFFF5F6FA);
  static const textMuted = Color(0xFF8FA8C8);
  static const textSecondary = Color(0xFFB0BEC5);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFE53935);
  static const white = Colors.white;
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 30;
}

abstract final class AppStrings {
  static const appName = 'تفويلة';
  static const favorites = 'المفضلة';
  static const profile = 'الملف الشخصي';
  static const editProfile = 'تعديل البيانات';
  static const changePassword = 'تغيير كلمة المرور';
  static const saveChanges = 'حفظ التغييرات';
  static const updatePassword = 'تحديث كلمة المرور';
  static const logout = 'تسجيل الخروج';
  static const navigate = 'توجيه';
  static const startTrip = 'ابدأ الرحلة';
  static const searchHint = 'ابحث عن محطة وقود...';
}
