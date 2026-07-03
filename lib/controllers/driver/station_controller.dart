import 'package:get/get.dart';
import 'package:new_version/controllers/driver/location_controller.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/services/connectivity_service.dart';
import 'package:new_version/services/database_service.dart';
import 'package:new_version/services/osrm_service.dart';
import 'package:new_version/services/overpass_service.dart';
import 'package:new_version/utils/exceptions.dart';
import 'package:new_version/utils/app_snackbar.dart';
import 'package:geolocator/geolocator.dart';

class StationController extends GetxController {
  StationController({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  Position? _lastRoutePosition;

  bool _isUpdatingRoute = false;

  final DatabaseService _databaseService;
  final OverpassService _overpassService = Get.find<OverpassService>();
  final OsrmService _osrmService = Get.find<OsrmService>();

  final stations = <StationModel>[].obs;
  final filteredStations = <StationModel>[].obs;
  final selectedStation = Rxn<StationModel>();
  final isLoading = false.obs;
  final isFindingFastest = false.obs;
  final searchQuery = ''.obs;
  final isFromCache = false.obs;

  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    final connectivity = Get.find<ConnectivityService>();
    _wasOffline = !connectivity.isConnected.value;
    ever(connectivity.isConnected, (connected) {
      if (connected == true && _wasOffline) {
        loadStations();
      }
      _wasOffline = connected != true;
    });
    loadStations();
  }

  Future<void> loadStations() async {
    isLoading.value = true;
    try {
      final result = await _databaseService.fetchStations();
      isFromCache.value = result.fromCache;
      stations.assignAll(_withDistance(result.stations));
      _applyFilter();
    } finally {
      isLoading.value = false;
    }
  }

  void refreshDistances() {
    if (stations.isEmpty) return;
    stations.assignAll(_withDistance(stations.toList()));
    _applyFilter();
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

  void clearSelection() {
    selectedStation.value = null;
  }

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
        AppSnackbar.warning('لم يتم العثور على محطات وقود قريبة', title: 'تنبيه');
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
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('حدث خطأ غير متوقع');
    } finally {
      isFindingFastest.value = false;
    }
  }
  Future<void> updateRouteIfNeeded() async {
    final station = selectedStation.value;
    if (station == null) return;

    if (!Get.isRegistered<LocationController>()) return;

    final location = Get.find<LocationController>();
    final current = location.currentPosition.value;

    if (current == null) return;

    // أول مرة نخزن الموقع
    if (_lastRoutePosition == null) {
      _lastRoutePosition = current;
      return;
    }

    // إعادة الحساب بعد التحرك 20 متر
    final moved = Geolocator.distanceBetween(
      _lastRoutePosition!.latitude,
      _lastRoutePosition!.longitude,
      current.latitude,
      current.longitude,
    );

    if (moved < 20) return;

    // منع أكثر من Request في نفس الوقت
    if (_isUpdatingRoute) return;
    _isUpdatingRoute = true;

    try {
      final route = await _osrmService.getRoute(
        current.latitude,
        current.longitude,
        station.latitude,
        station.longitude,
      );

      if (route == null) return;

      final updatedStation = station.copyWith(
        distanceKm: route.distanceMeters / 1000,
        duration: route.durationSeconds,
        routePolyline: route.polyline,
      );

      // تحديث المحطة المختارة
      selectedStation.value = updatedStation;

      // تحديث القائمة أيضاً
      stations.assignAll(
        stations.map((s) {
          if (s.id == updatedStation.id) {
            return updatedStation;
          }
          return s;
        }).toList(),
      );

      _applyFilter();

      _lastRoutePosition = current;
    } finally {
      _isUpdatingRoute = false;
    }
  }
}
