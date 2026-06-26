import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_version/models/user_role.dart';
import 'package:new_version/utils/social_auth_config.dart';
import 'package:new_version/views/auth/login_view.dart';
import 'package:new_version/views/auth/pending_view.dart';
import 'package:new_version/views/staff/main_view.dart';
import 'package:new_version/views/auth/blocked_employee_view.dart';
import 'package:new_version/views/admin/admin_main_view.dart';
import 'package:new_version/views/screens/driver_main_screen.dart';
import '../../services/connectivity_service.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final ConnectivityService connectivity = Get.find<ConnectivityService>();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: SocialAuthConfig.googleWebClientId,
  );

  bool checkInternet() {
    if (!connectivity.isConnected.value) {
      Get.snackbar('لا يوجد اتصال', 'تأكد من اتصالك بالإنترنت');
      return false;
    }
    return true;
  }

  Future<void> loginUser({
    required String email,
    required String password,
    required UserRole userType,
  }) async {
    if (!checkInternet()) return;
    isLoading.value = true;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await _routeAuthenticatedUser(credential.user!.uid, userType);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle({required UserRole userType}) async {
    if (!checkInternet()) return;
    isLoading.value = true;
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _handleSocialLogin(userCredential.user!, userType);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (_) {
      Get.snackbar('تنبيه', 'فشل تسجيل الدخول بجوجل');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook({required UserRole userType}) async {
    if (!checkInternet()) return;
    isLoading.value = true;
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.cancelled) return;
      if (result.status != LoginStatus.success || result.accessToken == null) {
        Get.snackbar(
          'تنبيه',
          result.message ?? 'فشل تسجيل الدخول بفيسبوك',
        );
        return;
      }

      final credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      await _handleSocialLogin(userCredential.user!, userType);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (_) {
      Get.snackbar('تنبيه', 'فشل تسجيل الدخول بفيسبوك');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleSocialLogin(User user, UserRole userType) async {
    if (userType == UserRole.customer) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _createSocialCustomer(user);
      }
    }
    await _routeAuthenticatedUser(user.uid, userType);
  }

  Future<void> _createSocialCustomer(User user) async {
    final displayName = user.displayName?.trim() ?? '';
    final nameParts = displayName.split(RegExp(r'\s+'));
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    await _firestore.collection('users').doc(user.uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'phone': user.phoneNumber ?? '',
      'email': user.email ?? '',
      'role': 'customer',
      'status': 'approved',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _routeAuthenticatedUser(String uid, UserRole userType) async {
    if (userType == UserRole.staff) {
      final staffDoc = await _firestore.collection('staff').doc(uid).get();
      if (staffDoc.exists) {
        final status = staffDoc.data()?['status'];
        if (status == 'approved') {
          Get.offAll(() => MainView());
        } else if (status == 'denied') {
          Get.offAll(() => const BlockedEmployeeView());
        } else {
          Get.offAll(() => const PendingView());
        }
      } else {
        Get.snackbar('خطأ', 'حسابك مش مسجل كموظف');
      }
    } else if (userType == UserRole.admin) {
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) {
        Get.offAll(() => const AdminMainView());
      } else {
        Get.snackbar('تنبيه', 'هذا الحساب ليس مسؤولاً');
      }
    } else {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Get.offAll(() => const DriverMainScreen());
      } else {
        Get.snackbar('خطأ', 'حسابك مش مسجل كسائق');
      }
    }
  }

  Future<void> registerCustomer({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    if (!checkInternet()) return;
    isLoading.value = true;
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'role': 'customer',
        'status': 'approved',
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.offAll(() => const DriverMainScreen());
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerStaff({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String stationName,
  }) async {
    if (!checkInternet()) return;
    isLoading.value = true;
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final uid = credential.user!.uid;
      final staffCode = 'STF-${uid.substring(0, 6).toUpperCase()}';
      await _firestore.collection('staff').doc(uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'stationName': stationName.trim(),
        'staffId': uid,
        'staffCode': staffCode,
        'role': 'staff',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.offAll(() => const PendingView());
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut(UserRole userType) async {
    await Future.wait([
      _googleSignIn.signOut(),
      FacebookAuth.instance.logOut(),
      _auth.signOut(),
    ]);

    Get.offAll(
      () => LoginView(),
      arguments: userType,
    );
  }

  void _handleAuthError(FirebaseAuthException e) {
    final message = switch (e.code) {
      'weak-password' => 'كلمة المرور ضعيفة',
      'email-already-in-use' => 'الإيميل مسجل مسبقاً',
      'user-not-found' => 'الحساب غير موجود',
      'wrong-password' => 'كلمة المرور خطأ',
      'invalid-credential' => 'بيانات الدخول غير صحيحة',
      'account-exists-with-different-credential' =>
        'هذا الإيميل مسجل بطريقة تسجيل أخرى',
      _ => 'خطأ: ${e.message}',
    };
    Get.snackbar('تنبيه', message, snackPosition: SnackPosition.BOTTOM);
  }
}
