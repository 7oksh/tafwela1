import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/controllers/driver/location_controller.dart';
import 'package:new_version/controllers/driver/station_controller.dart';
import 'package:new_version/services/connectivity_service.dart';
import 'package:new_version/services/database_service.dart';
import 'package:new_version/services/local_database_service.dart';

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
    if (Get.isRegistered<LocationController>()) {
      ever(Get.find<LocationController>().currentPosition, (_) {
        _updateDistances();
      });
    }

    _loadIds();
    refreshFavorites();
  }

  void _updateDistances() {
    if (!Get.isRegistered<LocationController>()) return;
    if (favoriteStations.isEmpty) return;
    final location = Get.find<LocationController>();
    
    favoriteStations.assignAll(
      favoriteStations.map((s) => s.copyWith(
        distanceKm: location.distanceTo(lat: s.latitude, lng: s.longitude),
      )).toList(),
    );
  }

  void _loadIds() {
    final stored = _box.read<List<dynamic>>(_key);
    favoriteIds.assignAll(stored?.map((e) => e.toString()).toList() ?? []);
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
      _cacheStationLocally(id);
    }
    _persist();
    refreshFavorites();
  }

  void _cacheStationLocally(String id) {
    try {
      if (Get.isRegistered<StationController>()) {
        final stationCtrl = Get.find<StationController>();
        final station = stationCtrl.stations.firstWhere((s) => s.id == id);
        Get.find<LocalDatabaseService>().cacheStations([station]);
      }
    } catch (_) {}
  }

  Future<void> refreshFavorites() async {
    final localDb = Get.find<LocalDatabaseService>();
    final cached = await localDb.getCachedStations();
    
    var favs = cached.where((s) => favoriteIds.contains(s.id)).toList();
    
    if (Get.isRegistered<LocationController>()) {
      final location = Get.find<LocationController>();
      favs = favs.map((s) => s.copyWith(
        distanceKm: location.distanceTo(lat: s.latitude, lng: s.longitude),
      )).toList();
    }
    
    favoriteStations.assignAll(favs);
  }
}
