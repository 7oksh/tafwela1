import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { user, employee }

class StoredUser {
  final String username;
  final UserRole role;
  final String? stationId;
  final String? password;

  StoredUser({
    required this.username,
    required this.role,
    this.stationId,
    this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'role': role.name,
    'stationId': stationId,
    'password': password,
  };

  static StoredUser fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String?;
    UserRole role = UserRole.user;
    if (roleStr == 'employee') role = UserRole.employee;
    return StoredUser(
      username: json['username'] as String,
      role: role,
      stationId: json['stationId'] as String?,
      password: json['password'] as String?,
    );
  }
}

/// حسابات الموظفين الجاهزة (محلي)
final Map<String, Map<String, String>> _employeeAccounts = {
  'emp_station_1': {'password': 'station1', 'stationId': 'station_1'},
  'emp_station_2': {'password': 'station2', 'stationId': 'station_2'},
  'موظف_محطة_1': {'password': '123456', 'stationId': 'station_1'},
};

class AuthService {
  static const _keyUser = 'gas_app_user';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<StoredUser?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyUser);
    if (jsonStr == null) return null;
    try {
      return StoredUser.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static String _firebaseAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل. جرّب تسجيل الدخول.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب.';
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد. أنشئ حساباً أولاً.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'invalid-credential':
        return 'البريد أو كلمة المرور غير صحيحة.';
      case 'operation-not-allowed':
        return 'تسجيل الدخول بالبريد غير مفعّل. فعّله من Firebase Console (Authentication → Sign-in method → Email/Password).';
      case 'admin-restricted-operation':
        return 'هذه العملية غير مسموحة. تحقق من إعدادات Firebase.';
      case 'configuration-not-found':
        return 'إعداد Firebase ناقص. شغّل: dart run flutterfire_cli:flutterfire configure';
      case 'network-request-failed':
        return 'تحقق من الاتصال بالإنترنت وحاول مرة أخرى.';
      case 'too-many-requests':
        return 'محاولات كثيرة. انتظر قليلاً ثم جرّب مرة أخرى.';
      default:
        debugPrint('FirebaseAuth: code=${e.code}, message=${e.message}');
        if (e.code.contains('api-key-not-valid') || e.code.contains('invalid-api-key')) {
          return 'مفتاح API غير صالح. شغّل من مجلد المشروع: dart run flutterfire_cli:flutterfire configure';
        }
        final m = e.message?.trim() ?? '';
        if (m.isEmpty || m.toLowerCase() == 'error' || m.toLowerCase().startsWith('an error occurred')) {
          return 'حدث خطأ (كود: ${e.code}). تحقق من تفعيل البريد في Firebase وحاول مرة أخرى.';
        }
        return m;
    }
  }

  /// التحقق من قوة كلمة المرور عند إنشاء حساب جديد
  static String? _passwordComplexityError(String password) {
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل وتحتوي على حرف كبير، حروف وأرقام، ورمز مثل @ أو # أو _.';
    }
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLetter = password.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSymbol = password.contains(RegExp(r'[@#_\-\!\$\%\^\&\*\(\)\+\=\.\,\?\:;]'));
    if (!hasLetter || !hasDigit || !hasUpper || !hasSymbol) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير، حروف وأرقام، ورمز مثل @ أو # أو _.';
    }
    return null;
  }

  /// تسجيل دخول المستخدم العادي عبر Firebase (بريد إلكتروني + كلمة مرور)
  /// يُرجع null عند النجاح، أو رسالة الخطأ عند الفشل.
  Future<String?> loginUser(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) return 'أدخل البريد وكلمة المرور';
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) return 'حدث خطأ. حاول مرة أخرى.';
      final stored = StoredUser(
        username: user.displayName ?? user.email ?? email.trim(),
        role: UserRole.user,
      );
      await _saveUser(stored);
      return null;
    } on FirebaseAuthException catch (e) {
      return _firebaseAuthMessage(e);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket')) {
        return 'تحقق من الاتصال بالإنترنت.';
      }
      if (msg.contains('firebase') || msg.contains('api') || msg.contains('configuration')) {
        return 'خطأ في إعداد Firebase. شغّل: dart run flutterfire_cli:flutterfire configure';
      }
      return 'حدث خطأ. تحقق من الإنترنت وإعداد Firebase وحاول مرة أخرى.';
    }
  }

  /// إنشاء حساب مستخدم جديد عبر Firebase
  /// يُرجع null عند النجاح، أو رسالة الخطأ عند الفشل.
  Future<String?> registerUser(String email, String password, String username) async {
    if (email.trim().isEmpty || password.isEmpty || username.trim().isEmpty) {
      return 'أدخل البريد واسم المستخدم وكلمة المرور';
    }
    final complexityError = _passwordComplexityError(password);
    if (complexityError != null) return complexityError;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) return 'حدث خطأ. حاول مرة أخرى.';
      await user.updateDisplayName(username.trim());
      final stored = StoredUser(
        username: username.trim(),
        role: UserRole.user,
      );
      await _saveUser(stored);
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('registerUser FirebaseAuthException: code=${e.code}, message=${e.message}');
      return _firebaseAuthMessage(e);
    } catch (e, st) {
      debugPrint('registerUser catch: $e\n$st');
      final msg = e.toString().toLowerCase();
      if (msg.contains('network') || msg.contains('socket')) {
        return 'تحقق من الاتصال بالإنترنت.';
      }
      if (msg.contains('firebase') || msg.contains('api') || msg.contains('configuration')) {
        return 'خطأ في إعداد Firebase. شغّل: dart run flutterfire_cli:flutterfire configure';
      }
      return 'حدث خطأ. تحقق من الإنترنت وإعداد Firebase وحاول مرة أخرى.';
    }
  }

  /// تسجيل دخول الموظف (محلي)
  Future<StoredUser?> loginEmployee(String username, String password) async {
    final key = username.trim();
    final data = _employeeAccounts[key];
    if (data == null || data['password'] != password) return null;
    final user = StoredUser(
      username: key,
      role: UserRole.employee,
      stationId: data['stationId'],
    );
    await _saveUser(user);
    return user;
  }

  Future<void> _saveUser(StoredUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  static void addEmployeeAccount(String username, String password, String stationId) {
    _employeeAccounts[username] = {
      'password': password,
      'stationId': stationId,
    };
  }
}
