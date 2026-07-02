import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:new_version/models/crowd_update_model.dart';
import 'package:new_version/services/local_database_service.dart';

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
