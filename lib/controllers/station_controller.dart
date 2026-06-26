import 'package:get/get.dart';
import 'package:new_version/controllers/location_controller.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/services/database_service.dart';

class StationController extends GetxController {
  StationController({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;

  final stations = <StationModel>[].obs;
  final filteredStations = <StationModel>[].obs;
  final selectedStation = Rxn<StationModel>();
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadStations();
  }

  Future<void> loadStations() async {
    isLoading.value = true;
    try {
      final data = await _databaseService.fetchStations();
      stations.assignAll(_withDistance(data));
      _applyFilter();
    } finally {
      isLoading.value = false;
    }
  }

  List<StationModel> _withDistance(List<StationModel> list) {
    if (!Get.isRegistered<LocationController>()) return list;
    final location = Get.find<LocationController>();
    return list
        .map(
          (s) => s.copyWith(
            distanceKm: location.distanceTo(lat: s.latitude, lng: s.longitude),
          ),
        )
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  void search(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredStations.assignAll(stations);
      return;
    }
    filteredStations.assignAll(
      stations.where(
        (s) =>
            s.name.toLowerCase().contains(q) ||
            s.address.toLowerCase().contains(q),
      ),
    );
  }

  void selectStation(StationModel station) {
    selectedStation.value = station;
  }

  void clearSelection() => selectedStation.value = null;

  StationModel? findById(String id) {
    try {
      return stations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
