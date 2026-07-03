class PlaceResult {
  final String id;
  final String displayName;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.id,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      id: json['place_id']?.toString() ?? '',
      displayName: json['display_name'] as String? ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0,
    );
  }
}
