import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/services/connectivity_service.dart';
import 'package:new_version/services/database_service.dart';

class FavoritesController extends GetxController {
  FavoritesController({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;
  final _box = GetStorage('driver_favorites');

  static const _key = 'favorite_ids';

  final favoriteIds = <String>[].obs;
  final favoriteStations = <StationModel>[].obs;

  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    final connectivity = Get.find<ConnectivityService>();
    _wasOffline = !connectivity.isConnected.value;
    ever(connectivity.isConnected, (connected) {
      if (connected == true && _wasOffline) {
        refreshFavorites();
      }
      _wasOffline = connected != true;
    });
    _loadIds();
    refreshFavorites();
  }

  void _loadIds() {
    final stored = _box.read<List<dynamic>>(_key);
    favoriteIds.assignAll(stored?.map((e) => e.toString()).toList() ?? ['1', '4']);
    _persist();
  }

  Future<void> _persist() async {
    await _box.write(_key, favoriteIds);
    await _syncToFirestore();
  }

  Future<void> _syncToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _databaseService.syncFavoriteIds(uid, favoriteIds.toList());
  }

  bool isFavorite(String id) => favoriteIds.contains(id);

  void toggle(String id) {
    if (isFavorite(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    _persist();
    refreshFavorites();
  }

  Future<void> refreshFavorites() async {
    final result = await _databaseService.fetchStations();
    favoriteStations.assignAll(
      result.stations.where((s) => favoriteIds.contains(s.id)).toList(),
    );
  }
}
