import 'package:get/get.dart';
import 'package:new_version/controllers/driver/location_controller.dart';
import 'package:new_version/models/place_result.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/services/connectivity_service.dart';
import 'package:new_version/services/database_service.dart';
import 'package:new_version/services/nominatim_service.dart';
import 'package:new_version/services/osrm_service.dart';
import 'package:new_version/services/overpass_service.dart';
import 'package:new_version/utils/exceptions.dart';
import 'package:new_version/utils/app_snackbar.dart';
import 'package:new_version/services/search_preferences_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:new_version/services/local_database_service.dart';

class StationController extends GetxController {
  StationController({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  Position? _lastRoutePosition;

  bool _isUpdatingRoute = false;

  final DatabaseService _databaseService;
  final OverpassService _overpassService = Get.find<OverpassService>();
  final OsrmService _osrmService = Get.find<OsrmService>();
  final NominatimService _nominatimService = Get.find<NominatimService>();
  final SearchPreferencesService _preferences =
      Get.find<SearchPreferencesService>();

  final stations = <StationModel>[].obs;
  final filteredStations = <StationModel>[].obs;
  final selectedStation = Rxn<StationModel>();
  final isLoading = false.obs;
  final isFindingFastest = false.obs;
  final searchQuery = ''.obs;
  final isFromCache = false.obs;

  // External place search
  final placeResults = <PlaceResult>[].obs;
  final isSearchingPlaces = false.obs;

  bool _wasOffline = false;
  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    final connectivity = Get.find<ConnectivityService>();
    _wasOffline = !connectivity.isConnected.value;
    ever(connectivity.isConnected, (connected) {
      // Intentionally empty to prevent auto-fetch on reconnect,
      // as requested by the architectural constraints.
      _wasOffline = connected != true;
    });
  }

  Future<void> loadStations() async {
    isLoading.value = true;
    try {
      final result = await _databaseService.fetchStations();
      isFromCache.value = result.fromCache;
      stations.assignAll(_withDistance(result.stations));
      _applyFilter();
      _applySorting();
    } finally {
      isLoading.value = false;
    }
  }

  void refreshDistances() {
    if (stations.isEmpty) return;
    stations.assignAll(_withDistance(stations.toList()));
    _applyFilter();
    _applySorting();
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
        .toList();
  }

  void search(String query) {
    searchQuery.value = query;
    _applyFilter();
    _applySorting();
  }

  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    Iterable<StationModel> result = stations;

    if (_preferences.openStationsOnly) {
      result = result.where((s) => s.isOpen);
    }

    if (q.isNotEmpty) {
      result = result.where(
        (s) =>
            s.name.toLowerCase().contains(q) ||
            s.address.toLowerCase().contains(q),
      );
    }

    filteredStations.assignAll(result);
  }

  void _applySorting() {
    final sortType = _preferences.sortType;
    final list = filteredStations.toList();
    if (sortType == SortType.distance) {
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (sortType == SortType.crowd) {
      list.sort((a, b) {
        int crowdValue(CrowdStatus s) {
          switch (s) {
            case CrowdStatus.low:
              return 0;
            case CrowdStatus.medium:
              return 1;
            case CrowdStatus.high:
              return 2;
            case CrowdStatus.none:
              return 3;
          }
        }

        final aVal = crowdValue(a.crowdStatus);
        final bVal = crowdValue(b.crowdStatus);
        if (aVal != bVal) return aVal.compareTo(bVal);
        return a.distanceKm.compareTo(b.distanceKm);
      });
    } else if (sortType == SortType.rating) {
      list.sort((a, b) {
        if (b.rating != a.rating) {
          return b.rating.compareTo(a.rating);
        }
        return a.distanceKm.compareTo(b.distanceKm);
      });
    }
    filteredStations.assignAll(list);
  }

  void selectStation(StationModel station) {
    selectedStation.value = station;
    loadRouteForStation(station);
  }

  void clearSelection() {
    selectedStation.value = null;
  }

  void endTrip() {
    final current = selectedStation.value;
    if (current != null) {
      // Reset the route on the station so DriverMapView stops drawing it
      final cleared = current.copyWith(routePolyline: [], duration: 0);
      final idx = stations.indexWhere((s) => s.id == current.id);
      if (idx != -1) stations[idx] = cleared;
    }
    selectedStation.value = null;
    _applyFilter();
    _applySorting();
  }

  StationModel? findById(String id) {
    try {
      return stations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── External place search ──────────────────────────────────────────────────

  /// Search for external places using Nominatim geocoding API.
  /// Only runs when online and query is at least 3 characters.
  Future<void> searchExternalPlaces(String query) async {
    if (query.trim().length < 3) {
      placeResults.clear();
      return;
    }

    // Only search if online
    if (!Get.isRegistered<ConnectivityService>() ||
        !Get.find<ConnectivityService>().isConnected.value) {
      placeResults.clear();
      return;
    }

    isSearchingPlaces.value = true;
    try {
      final location = Get.isRegistered<LocationController>()
          ? Get.find<LocationController>()
          : null;

      final results = await _nominatimService.search(
        query,
        lat: location?.currentLatLng.latitude,
        lng: location?.currentLatLng.longitude,
      );

      placeResults.assignAll(results);
    } finally {
      isSearchingPlaces.value = false;
    }
  }

  // ── Find the nearest & fastest gas station ────────────────────────────────



  Future<void> applyPreferencesAndSearch() async {
    if (_isFetching) return;
    if (!Get.isRegistered<LocationController>()) return;
    final location = Get.find<LocationController>();
    final userLat = location.currentLatLng.latitude;
    final userLng = location.currentLatLng.longitude;

    _isFetching = true;
    isLoading.value = true;
    try {
      final radius = _preferences.maxDistance;
      final nearby = await _overpassService.fetchNearbyStations(
        userLat,
        userLng,
        radiusInKm: radius,
      );

      if (nearby.isEmpty) {
        AppSnackbar.warning(
          'لم يتم العثور على محطات وقود قريبة',
          title: 'تنبيه',
        );
        stations.clear();
        _applyFilter();
        _applySorting();
        selectedStation.value = null;
        return;
      }

      stations.assignAll(_withDistance(nearby));
      
      if (Get.isRegistered<LocalDatabaseService>()) {
        await Get.find<LocalDatabaseService>().cacheStations(stations.toList());
      }
      
      _applyFilter();
      _applySorting();

      if (filteredStations.isNotEmpty) {
        selectedStation.value = filteredStations.first;
      } else {
        selectedStation.value = null;
      }

      _resolveMissingAddressesInBackground();
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('حدث خطأ غير متوقع');
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  /// Fetches nearby stations from Overpass, calculates driving route via OSRM
  /// for each, sorts by duration, and selects the fastest one.
  Future<void> findFastestNearbyStation() async {
    if (_isFetching) return;
    if (!Get.isRegistered<LocationController>()) return;
    final location = Get.find<LocationController>();
    final userLat = location.currentLatLng.latitude;
    final userLng = location.currentLatLng.longitude;

    _isFetching = true;
    isFindingFastest.value = true;
    try {
      // 1. Fetch nearby fuel stations from Overpass API
      final radius = _preferences.maxDistance;
      final nearby = await _overpassService.fetchNearbyStations(
        userLat,
        userLng,
        radiusInKm: radius,
      );

      if (nearby.isEmpty) {
        AppSnackbar.warning(
          'لم يتم العثور على محطات وقود قريبة',
          title: 'تنبيه',
        );
        return;
      }

      stations.assignAll(_withDistance(nearby));
      
      if (Get.isRegistered<LocalDatabaseService>()) {
        await Get.find<LocalDatabaseService>().cacheStations(stations.toList());
      }

      _applyFilter();
      _applySorting();

      _resolveMissingAddressesInBackground();

      if (filteredStations.isNotEmpty) {
        selectedStation.value = filteredStations.first;
      } else {
        selectedStation.value = null;
      }
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (_) {
      AppSnackbar.error('حدث خطأ غير متوقع');
    } finally {
      isFindingFastest.value = false;
      _isFetching = false;
    }
  }

  /// Lazy route loading for a single station when selected
  Future<void> loadRouteForStation(StationModel station) async {
    if (!Get.isRegistered<LocationController>()) return;
    final location = Get.find<LocationController>();
    final userLat = location.currentLatLng.latitude;
    final userLng = location.currentLatLng.longitude;

    isLoading.value = true;
    try {
      final route = await _osrmService.getRoute(
        userLat,
        userLng,
        station.latitude,
        station.longitude,
      );

      if (route != null) {
        final updatedStation = station.copyWith(
          duration: route.durationSeconds,
          routePolyline: route.polyline,
          distanceKm: route.distanceMeters / 1000,
        );

        selectedStation.value = updatedStation;

        final index = stations.indexWhere((s) => s.id == station.id);
        if (index != -1) {
          stations[index] = updatedStation;
          _applyFilter();
          _applySorting();
        }
      } else {
        selectedStation.value = station;
      }
    } catch (_) {
      AppSnackbar.error('حدث خطأ أثناء جلب المسار');
    } finally {
      isLoading.value = false;
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
      _applySorting();
      _lastRoutePosition = current;
    } finally {
      _isUpdatingRoute = false;
    }
  }

  void _resolveMissingAddressesInBackground() {
    Future.microtask(() async {
      final stationsToResolve = stations.where((s) => s.address.trim().isEmpty).toList();
      
      for (final s in stationsToResolve) {
        try {
          final placemarks = await geo.placemarkFromCoordinates(s.latitude, s.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final parts = <String>[];
            if (p.subLocality?.isNotEmpty == true) parts.add(p.subLocality!);
            if (p.locality?.isNotEmpty == true) parts.add(p.locality!);
            
            var newAddress = parts.join('، ');
            if (newAddress.isEmpty && p.administrativeArea?.isNotEmpty == true) {
              newAddress = p.administrativeArea!;
            }
            
            if (newAddress.isNotEmpty) {
              final index = stations.indexWhere((st) => st.id == s.id);
              if (index != -1) {
                final updatedStation = stations[index].copyWith(address: newAddress);
                stations[index] = updatedStation;
                
                final filteredIndex = filteredStations.indexWhere((st) => st.id == s.id);
                if (filteredIndex != -1) {
                  filteredStations[filteredIndex] = updatedStation;
                }
                
                if (selectedStation.value?.id == updatedStation.id) {
                  selectedStation.value = selectedStation.value?.copyWith(address: newAddress);
                }
                
                if (Get.isRegistered<LocalDatabaseService>()) {
                  Get.find<LocalDatabaseService>().cacheStations([updatedStation]);
                }
              }
            }
          }
        } catch (_) {}
        // Sequential delay to prevent rate-limiting and keep UI smooth
        await Future.delayed(const Duration(milliseconds: 300));
      }
    });
  }
}
