import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_version/controllers/location_controller.dart';
import 'package:new_version/controllers/station_controller.dart';
import 'package:new_version/services/maps_service.dart';

class DriverMapView extends StatelessWidget {
  const DriverMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();
    final stationController = Get.find<StationController>();

    return Obx(() {
      final markers = MapsService().buildStationMarkers(
        stations: stationController.filteredStations,
        onTap: stationController.selectStation,
        selectedId: stationController.selectedStation.value?.id,
      );

      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: locationController.currentLatLng,
          zoom: 14,
        ),
        onMapCreated: locationController.onMapCreated,
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      );
    });
  }
}
