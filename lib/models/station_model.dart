import 'package:latlong2/latlong.dart';
import 'package:new_version/models/fuel_type_model.dart';

enum CrowdStatus { low, medium, high, none }

class StationModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double rating;
  final CrowdStatus crowdStatus;
  final String imageUrl;
  final List<FuelTypeModel> fuelTypes;
  final List<String> services;
  final bool isOpen;
  final int duration;
  final List<LatLng> routePolyline;

  const StationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.rating,
    required this.crowdStatus,
    required this.imageUrl,
    required this.fuelTypes,
    this.services = const [],
    this.isOpen = true,
    this.duration = 0,
    this.routePolyline = const [],
  });

  factory StationModel.fromMap(Map<String, dynamic> map) {
    return StationModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      crowdStatus: _parseCrowdStatus(map['crowdStatus']),
      imageUrl: map['imageUrl'] as String? ?? '',
      fuelTypes: (map['fuelTypes'] as List<dynamic>?)
              ?.map((e) => FuelTypeModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      services: (map['services'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isOpen: map['isOpen'] as bool? ?? true,
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      routePolyline: (map['routePolyline'] as List<dynamic>?)
              ?.map((e) {
                final m = e as Map<String, dynamic>;
                return LatLng(
                  (m['lat'] as num).toDouble(),
                  (m['lng'] as num).toDouble(),
                );
              })
              .toList() ??
          [],
    );
  }

  static CrowdStatus _parseCrowdStatus(dynamic value) {
    return switch (value?.toString()) {
      'low' => CrowdStatus.low,
      'medium' => CrowdStatus.medium,
      'high' => CrowdStatus.high,
      'none' => CrowdStatus.none,
      _ => CrowdStatus.low,
    };
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'distanceKm': distanceKm,
        'rating': rating,
        'crowdStatus': crowdStatus.name,
        'imageUrl': imageUrl,
        'fuelTypes': fuelTypes.map((e) => e.toMap()).toList(),
        'services': services,
        'isOpen': isOpen,
        'duration': duration,
        'routePolyline': routePolyline
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
      };

  StationModel copyWith({
    double? distanceKm,
    CrowdStatus? crowdStatus,
    int? duration,
    List<LatLng>? routePolyline,
  }) {
    return StationModel(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating,
      crowdStatus: crowdStatus ?? this.crowdStatus,
      imageUrl: imageUrl,
      fuelTypes: fuelTypes,
      services: services,
      isOpen: isOpen,
      duration: duration ?? this.duration,
      routePolyline: routePolyline ?? this.routePolyline,
    );
  }
}
