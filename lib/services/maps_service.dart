import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/utils/helpers.dart';

class MapsService {
  static const defaultLocation = LatLng(30.0444, 31.2357);

  Set<Marker> buildStationMarkers({
    required List<StationModel> stations,
    required void Function(StationModel station) onTap,
    String? selectedId,
  }) {
    return stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _markerHue(station.crowdStatus),
        ),
        onTap: () => onTap(station),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: Helpers.crowdStatusLabel(station.crowdStatus),
        ),
      );
    }).toSet();
  }

  static double _markerHue(CrowdStatus status) {
    return switch (status) {
      CrowdStatus.low => BitmapDescriptor.hueGreen,
      CrowdStatus.medium => BitmapDescriptor.hueOrange,
      CrowdStatus.high => BitmapDescriptor.hueRed,
      CrowdStatus.none => BitmapDescriptor.hueAzure,
    };
  }
}
