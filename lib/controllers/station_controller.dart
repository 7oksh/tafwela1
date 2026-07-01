import 'package:get/get.dart';
import 'package:new_version/controllers/location_controller.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/services/database_service.dart';
import 'package:new_version/services/osrm_service.dart';
import 'package:new_version/services/overpass_service.dart';

class StationController extends GetxController {
  StationController({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  final DatabaseService _databaseService;
  final OverpassService _overpassService = OverpassService();
  final OsrmService _osrmService = OsrmService();

  final stations = <StationModel>[].obs;
  final filteredStations = <StationModel>[].obs;
  final selectedStation = Rxn<StationModel>();
  final isLoading = false.obs;
  final isFindingFastest = false.obs;
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

  // ── Find the nearest & fastest gas station ────────────────────────────────

  /// Fetches nearby stations from Overpass, calculates driving route via OSRM
  /// for each, sorts by duration, and selects the fastest one.
  Future<void> findFastestNearbyStation() async {
    if (!Get.isRegistered<LocationController>()) return;
    final location = Get.find<LocationController>();
    final userLat = location.currentLatLng.latitude;
    final userLng = location.currentLatLng.longitude;

    isFindingFastest.value = true;
    try {
      // 1. Fetch nearby fuel stations from Overpass API
      final nearby =
          await _overpassService.fetchNearbyStations(userLat, userLng);

      if (nearby.isEmpty) {
        Get.snackbar('تنبيه', 'لم يتم العثور على محطات وقود قريبة');
        return;
      }

      // 2. Get driving route for each station via OSRM
      final List<StationModel> routed = [];
      for (final station in nearby) {
        final route = await _osrmService.getRoute(
          userLat,
          userLng,
          station.latitude,
          station.longitude,
        );
        if (route != null) {
          routed.add(station.copyWith(
            duration: route.durationSeconds,
            routePolyline: route.polyline,
            distanceKm: route.distanceMeters / 1000,
          ));
        } else {
          routed.add(station.copyWith(
            distanceKm: location.distanceTo(
              lat: station.latitude,
              lng: station.longitude,
            ),
          ));
        }
      }

      // 3. Sort by driving duration (ascending — fastest first)
      routed.sort((a, b) => a.duration.compareTo(b.duration));

      // 4. Update reactive state
      stations.assignAll(routed);
      _applyFilter();
      if (routed.isNotEmpty) {
        selectedStation.value = routed.first;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر البحث عن المحطات القريبة');
    } finally {
      isFindingFastest.value = false;
    }
  }
}
