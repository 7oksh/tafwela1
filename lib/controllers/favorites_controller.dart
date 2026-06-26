import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/services/database_service.dart';

class FavoritesController extends GetxController {
  FavoritesController({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;
  final _box = GetStorage('driver_favorites');

  static const _key = 'favorite_ids';

  final favoriteIds = <String>[].obs;
  final favoriteStations = <StationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadIds();
    refreshFavorites();
  }

  void _loadIds() {
    final stored = _box.read<List<dynamic>>(_key);
    favoriteIds.assignAll(stored?.map((e) => e.toString()).toList() ?? ['1', '4']);
    _persist();
  }

  void _persist() => _box.write(_key, favoriteIds);

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
    final all = await _databaseService.fetchStations();
    favoriteStations.assignAll(
      all.where((s) => favoriteIds.contains(s.id)).toList(),
    );
  }
}
