import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_version/services/location_service.dart';
import 'package:new_version/controllers/driver/station_controller.dart';

class LocationController extends GetxController {
  LocationController({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  final LocationService _locationService;

  final currentPosition = Rxn<Position>();
  final isMapReady = false.obs;

  /// flutter_map controller — created here, shared with the FlutterMap widget.
  final mapController = MapController();

  static const defaultLocation = LatLng(30.0444, 31.2357);

  LatLng get currentLatLng {
    final pos = currentPosition.value;
    if (pos == null) return defaultLocation;
    return LatLng(pos.latitude, pos.longitude);
  }

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
  }

  final isLocationLoading = true.obs;

  Future<void> fetchLocation() async {
    isLocationLoading.value = true;
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        currentPosition.value = position;
        _moveToCurrentLocation();
        if (Get.isRegistered<StationController>()) {
          Get.find<StationController>().refreshDistances();
        }
      }
    } finally {
      isLocationLoading.value = false;
    }
  }

  void onMapReady() {
    isMapReady.value = true;
    _moveToCurrentLocation();
  }

  void _moveToCurrentLocation() {
    if (!isMapReady.value) return;
    mapController.move(currentLatLng, 14);
  }

  Future<void> goToCurrentLocation() async {
    if (currentPosition.value == null) {
      await fetchLocation();
    } else {
      _moveToCurrentLocation();
    }
  }

  double distanceTo({required double lat, required double lng}) {
    final pos = currentPosition.value;
    if (pos == null) return 0;
    return _locationService.distanceInKm(
      fromLat: pos.latitude,
      fromLng: pos.longitude,
      toLat: lat,
      toLng: lng,
    );
  }
}
