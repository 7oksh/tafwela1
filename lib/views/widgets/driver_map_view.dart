import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:new_version/controllers/location_controller.dart';
import 'package:new_version/controllers/station_controller.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/views/widgets/station_map_pin.dart';

class DriverMapView extends StatelessWidget {
  const DriverMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final locationCtrl = Get.find<LocationController>();
    final stationCtrl = Get.find<StationController>();

    return Obx(() {
      final stations = stationCtrl.filteredStations;
      final selected = stationCtrl.selectedStation.value;

      // Build markers from station list using the existing StationMapPin widget
      final markers = stations.map((station) {
        return Marker(
          point: LatLng(station.latitude, station.longitude),
          width: 150,
          height: 120,
          child: StationMapPin(
            station: station,
            isSelected: selected?.id == station.id,
            onTap: () => stationCtrl.selectStation(station),
          ),
        );
      }).toList();
      // User Marker
      markers.add(
        Marker(
          point: locationCtrl.currentLatLng,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 35,
          ),
        ),
      );
      // Route polyline for selected station
      final routePoints = selected?.routePolyline ?? [];

      if (locationCtrl.isLocationLoading.value &&
          locationCtrl.currentPosition.value == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        );
      }

      return Stack(
        children: [
          FlutterMap(
            mapController: locationCtrl.mapController,
            options: MapOptions(
              initialCenter: locationCtrl.currentLatLng,
              initialZoom: 14,
              onMapReady: locationCtrl.onMapReady,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tafwela.app',
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: AppColors.primaryBlue,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(markers: markers),
            ],
          ),

          // FAB: Find Fastest Nearby Station
          Positioned(
            bottom: 170,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'findFastest',
              onPressed: stationCtrl.isFindingFastest.value
                  ? null
                  : stationCtrl.findFastestNearbyStation,
              backgroundColor: stationCtrl.isFindingFastest.value
                  ? AppColors.textSecondary
                  : AppColors.primaryBlue,
              child: stationCtrl.isFindingFastest.value
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
                  : const Icon(
                Icons.rocket_launch,
                color: AppColors.white,
              ),
            ),
          ),

          Positioned(
            bottom: 240,
            right: 16,
            child: Obx(() {
              if (stationCtrl.selectedStation.value == null) {
                return const SizedBox();
              }

              return FloatingActionButton.small(
                heroTag: 'clearRoute',
                backgroundColor: Colors.white,
                onPressed: stationCtrl.clearSelection,
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}
