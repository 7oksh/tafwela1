import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:new_version/models/user_model.dart';
import 'package:new_version/services/database_service.dart';

class DriverProfileController extends GetxController {
  DriverProfileController({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;

  final user = Rxn<UserModel>();
  final notificationsEnabled = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        user.value = _fallbackUser;
        return;
      }
      user.value = await _databaseService.fetchUser(uid) ?? _fallbackUser;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? photoUrl, // null = no change, '' = delete, 'data:...' = new photo
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    await _databaseService.updateUser(uid, data);

    user.value = user.value?.copyWith(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      photoUrl: photoUrl,
    );
  }

  static const _fallbackUser = UserModel(
    id: 'demo',
    firstName: 'أحمد',
    lastName: 'محمد',
    email: 'ahmed.mohammed@email.com',
    phone: '+966 50 123 4567',
    ordersCount: 24,
    points: 150,
  );
}
