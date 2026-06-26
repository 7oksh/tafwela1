import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_version/services/location_service.dart';
import 'package:new_version/services/maps_service.dart';

class LocationController extends GetxController {
  LocationController({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  final LocationService _locationService;

  final currentPosition = Rxn<Position>();
  final mapController = Rxn<GoogleMapController>();

  LatLng get currentLatLng {
    final pos = currentPosition.value;
    if (pos == null) return MapsService.defaultLocation;
    return LatLng(pos.latitude, pos.longitude);
  }

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
  }

  Future<void> fetchLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      currentPosition.value = position;
      await _animateToCurrentLocation();
    }
  }

  Future<void> _animateToCurrentLocation() async {
    final controller = mapController.value;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(currentLatLng, 14),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
    if (currentPosition.value != null) {
      _animateToCurrentLocation();
    }
  }

  Future<void> goToCurrentLocation() async {
    if (currentPosition.value == null) {
      await fetchLocation();
    } else {
      await _animateToCurrentLocation();
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

  @override
  void onClose() {
    mapController.value?.dispose();
    super.onClose();
  }
}
