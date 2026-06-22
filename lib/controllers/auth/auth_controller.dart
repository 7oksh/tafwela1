import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version/views/auth/login_view.dart';
import 'package:new_version/views/auth/pending_view.dart';
import 'package:new_version/views/staff/main_view.dart';

import '../../services/connectivity_service.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final isLoading = false.obs;
  final ConnectivityService connectivity = Get.find<ConnectivityService>();

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
    required int userType, // 1 للسائق، 2 للموظف
  }) async {
    if (!checkInternet()) return;
    isLoading.value = true;
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = credential.user!.uid;

      if (userType == 2) {
        // البحث في كولكشن الموظفين مباشرة
        var staffDoc = await _firestore.collection('staff').doc(uid).get();
        if (staffDoc.exists) {
          final status = staffDoc.data()?['status'];
          if (status == 'approved') {
            Get.offAll(() => MainView());
          } else {
            Get.offAll(() => const PendingView());
          }
        } else {
          Get.snackbar('خطأ', 'حسابك مش مسجل كموظف');
        }
      } else {
        // البحث في كولكشن المستخدمين (السائقين) مباشرة
        var userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          Get.offAll(
            () => const Scaffold(body: Center(child: Text("واجهة السائق"))),
          );
        } else {
          Get.snackbar('خطأ', 'حسابك مش مسجل كسائق');
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
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
      Get.offAll(() => const Scaffold());
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
      await _firestore.collection('staff').doc(credential.user!.uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'stationName': stationName.trim(),
        'staffId': credential.user!.uid,
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

  Future<void> signOut() async {
    await _auth.signOut();
    Get.offAll(() => LoginView());
  }

  void _handleAuthError(FirebaseAuthException e) {
    final message = switch (e.code) {
      'weak-password' => 'كلمة المرور ضعيفة',
      'email-already-in-use' => 'الإيميل مسجل مسبقاً',
      'user-not-found' => 'الحساب غير موجود',
      'wrong-password' => 'كلمة المرور خطأ',
      'invalid-credential' => 'بيانات الدخول غير صحيحة',
      _ => 'خطأ: ${e.message}',
    };
    Get.snackbar('تنبيه', message, snackPosition: SnackPosition.BOTTOM);
  }
}
