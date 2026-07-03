import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_version/models/crowd_update_model.dart';
import 'package:new_version/models/user_role.dart';
import 'package:new_version/services/connectivity_service.dart';
import 'package:new_version/services/local_database_service.dart';
import 'package:new_version/views/auth/blocked_employee_view.dart';
import 'package:new_version/views/auth/login_view.dart';

class StaffController extends GetxController {
  final updates = <CrowdUpdateModel>[].obs;
  final isLoading = false.obs;
  final isInitialized = false.obs;

  // Profile fields – populated from Firestore after login
  final staffName = ''.obs;
  final stationName = ''.obs;
  final staffUid = ''.obs;
  final staffCode = ''.obs;
  final staffEmail = ''.obs;
  final staffPhone = ''.obs;
  final photoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initAll();
    _setupOfflineRevalidation();
  }

  Future<void> _initAll() async {
    try {
      isLoading.value = true;
      await _initLocalDb();
      await loadProfile();
    } finally {
      isInitialized.value = true;
      isLoading.value = false;
    }
  }

  /// Re-validate staff status when connectivity is restored after being offline
  void _setupOfflineRevalidation() {
    if (!Get.isRegistered<ConnectivityService>()) return;
    
    final connectivity = Get.find<ConnectivityService>();
    ever(connectivity.isConnected, (isConnected) async {
      if (isConnected) {
        await _revalidateStaffStatus();
      }
    });
  }

  Future<void> _revalidateStaffStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final staffDoc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(uid)
          .get();

      if (!staffDoc.exists) {
        // Staff doc deleted - sign out
        await _handleInvalidStaff();
        return;
      }

      final status = staffDoc.data()?['status'];
      if (status == 'denied') {
        // Staff was blocked while offline
        await _handleBlockedStaff();
      }
    } catch (e) {
      // Silently fail - user can continue working offline
      print("Error re-validating staff status: $e");
    }
  }

  Future<void> _handleInvalidStaff() async {
    final box = GetStorage('Settings');
    await box.remove('lastUserRole');
    await box.remove('lastUserUid');
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => LoginView(), arguments: UserRole.staff);
  }

  Future<void> _handleBlockedStaff() async {
    final box = GetStorage('Settings');
    await box.remove('lastUserRole');
    await box.remove('lastUserUid');
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const BlockedEmployeeView());
  }

  Future<void> _initLocalDb() async {
    if (!Get.isRegistered<LocalDatabaseService>()) {
      final dbService = LocalDatabaseService();
      await dbService.init();
      Get.put(dbService, permanent: true);
    }
  }

  Future<void> loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(uid)
          .get();
      if (doc.exists) {
        final d = doc.data()!;
        staffName.value =
            '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
        stationName.value = (d['stationName'] as String? ?? '').trim();
        staffUid.value = uid;
        staffCode.value = d['staffCode'] as String? ??
            'STF-${uid.substring(0, 6).toUpperCase()}';
        staffEmail.value = d['email'] as String? ?? '';
        staffPhone.value = d['phone'] as String? ?? '';
        photoUrl.value = d['photoUrl'] as String? ?? '';
      }
    } catch (e) {
      print("Error loading staff profile: $e");
    }
  }

  /// Called from EditProfileView after a successful save.
  void updateProfileLocally({
    String? firstName,
    String? lastName,
    String? phone,
    String? newPhotoUrl,
  }) {
    if (firstName != null || lastName != null) {
      final fn = firstName ?? (staffName.value.isNotEmpty ? staffName.value.split(' ').first : '');
      final ln = lastName ?? (staffName.value.split(' ').length > 1 ? staffName.value.split(' ').skip(1).join(' ') : '');
      staffName.value = '$fn $ln'.trim();
    }
    if (phone != null) staffPhone.value = phone;
    if (newPhotoUrl != null) photoUrl.value = newPhotoUrl;
  }

  void addUpdate(CrowdUpdateModel update) {
    updates.insert(0, update);
  }
}
