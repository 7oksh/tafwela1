import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:new_version/models/crowd_update_model.dart';
import 'package:new_version/models/station_model.dart';

class StaffController extends GetxController {
  final updates = <CrowdUpdateModel>[].obs;
  final isLoading = false.obs;

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
    loadProfile();
    _loadMockUpdates();
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
        stationName.value = d['stationName'] as String? ?? '';
        staffUid.value = uid;
        staffCode.value = d['staffCode'] as String? ??
            'STF-${uid.substring(0, 6).toUpperCase()}';
        staffEmail.value = d['email'] as String? ?? '';
        staffPhone.value = d['phone'] as String? ?? '';
        photoUrl.value = d['photoUrl'] as String? ?? '';
      }
    } catch (_) {
      // keep empty values; UI will show placeholders
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
      final fn = firstName ?? staffName.value.split(' ').first;
      final ln = lastName ?? staffName.value.split(' ').skip(1).join(' ');
      staffName.value = '$fn $ln'.trim();
    }
    if (phone != null) staffPhone.value = phone;
    if (newPhotoUrl != null) photoUrl.value = newPhotoUrl;
  }

  void _loadMockUpdates() {
    updates.assignAll([
      CrowdUpdateModel(
        id: '1',
        stationId: 's1',
        stationName: 'محطة النور',
        stationAddress: 'شارع الملك فهد - جدة',
        stationImageUrl: '',
        oldStatus: CrowdStatus.low,
        newStatus: CrowdStatus.high,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        updatedByName: 'أحمد محمد',
      ),
      CrowdUpdateModel(
        id: '2',
        stationId: 's2',
        stationName: 'محطة الأمل',
        stationAddress: 'حي النزهة - الرياض',
        stationImageUrl: '',
        oldStatus: CrowdStatus.high,
        newStatus: CrowdStatus.medium,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedByName: 'سارة علي',
      ),
      CrowdUpdateModel(
        id: '3',
        stationId: 's3',
        stationName: 'محطة الفجر',
        stationAddress: 'طريق الملك عبدالله - مكة',
        stationImageUrl: '',
        oldStatus: CrowdStatus.medium,
        newStatus: CrowdStatus.low,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedByName: 'محمد خالد',
      ),
      CrowdUpdateModel(
        id: '4',
        stationId: 's4',
        stationName: 'محطة الربوة',
        stationAddress: 'شارع التحلية - جدة',
        stationImageUrl: '',
        oldStatus: CrowdStatus.none,
        newStatus: CrowdStatus.high,
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedByName: 'أحمد محمد',
      ),
      CrowdUpdateModel(
        id: '5',
        stationId: 's1',
        stationName: 'محطة النور',
        stationAddress: 'شارع الملك فهد - جدة',
        stationImageUrl: '',
        oldStatus: CrowdStatus.medium,
        newStatus: CrowdStatus.low,
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedByName: 'أحمد محمد',
      ),
      CrowdUpdateModel(
        id: '6',
        stationId: 's5',
        stationName: 'محطة الوفاء',
        stationAddress: 'حي الروضة - الدمام',
        stationImageUrl: '',
        oldStatus: CrowdStatus.low,
        newStatus: CrowdStatus.none,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedByName: 'ليلى أحمد',
      ),
    ]);
  }

  void addUpdate(CrowdUpdateModel update) {
    updates.insert(0, update);
  }
}
