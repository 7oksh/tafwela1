import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_version/models/user_role.dart';
import 'package:new_version/utils/social_auth_config.dart';
import 'package:new_version/views/auth/login_view.dart';
import 'package:new_version/views/auth/pending_view.dart';
import 'package:new_version/views/auth/blocked_employee_view.dart';
import 'package:new_version/views/admin/admin_main_view.dart';
import 'package:new_version/utils/routes.dart';
import 'package:new_version/utils/exceptions.dart';
import '../../services/connectivity_service.dart';
import 'package:new_version/utils/app_snackbar.dart';

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
      AppSnackbar.warning('تأكد من اتصالك بالإنترنت', title: 'لا يوجد اتصال');
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
      AppSnackbar.warning('فشل تسجيل الدخول بجوجل', title: 'تنبيه');
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
        AppSnackbar.warning(
          result.message ?? 'فشل تسجيل الدخول بفيسبوك',
          title: 'تنبيه',
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
      AppSnackbar.warning('فشل تسجيل الدخول بفيسبوك', title: 'تنبيه');
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
          Get.offAllNamed(AppRoutes.staffMain);
        } else if (status == 'denied') {
          Get.offAll(() => const BlockedEmployeeView());
        } else {
          Get.offAll(() => const PendingView());
        }
      } else {
        AppSnackbar.error('حسابك مش مسجل كموظف', title: 'خطأ');
      }
    } else if (userType == UserRole.admin) {
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) {
        Get.offAll(() => const AdminMainView());
      } else {
        AppSnackbar.warning('هذا الحساب ليس مسؤولاً', title: 'تنبيه');
      }
    } else {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Get.offAllNamed(AppRoutes.driverMain);
      } else {
        AppSnackbar.error('حسابك مش مسجل كسائق', title: 'خطأ');
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
      Get.offAllNamed(AppRoutes.driverMain);
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
    final message = FirebaseExceptionHandler.handle(e);
    AppSnackbar.warning(
      message,
      title: 'تنبيه',
      position: SnackPosition.BOTTOM,
    );
  }
}
