import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:new_version/models/station_model.dart';

/// Fetches nearby fuel stations from OpenStreetMap using Overpass API.
class OverpassService {
  static const String _baseUrl = 'https://overpass-api.de/api/interpreter';

  Future<List<StationModel>> fetchNearbyStations(double lat, double lng) async {
    final query =
        '''
[out:json][timeout:25];
(
  node["amenity"="fuel"](around:10000,$lat,$lng);
  way["amenity"="fuel"](around:10000,$lat,$lng);
  relation["amenity"="fuel"](around:10000,$lat,$lng);
);
out center;
''';

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {'data': query});

    try {
      final response = await http.get(
        uri,
        headers: const {
          'User-Agent': 'Tafwela/1.0',
          'Accept': 'application/json',
        },
      );

      debugPrint('============================');
      debugPrint('URL: $uri');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('============================');

      if (response.statusCode != 200) {
        throw Exception(
          'Overpass Error ${response.statusCode}\n${response.body}',
        );
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      final List elements = json['elements'] ?? [];

      return elements.map<StationModel>((e) {
        final tags = (e['tags'] as Map<String, dynamic>?) ?? {};

        final center = (e['center'] as Map<String, dynamic>?);

        final latitude = ((e['lat'] ?? center?['lat']) as num).toDouble();

        final longitude = ((e['lon'] ?? center?['lon']) as num).toDouble();

        return StationModel(
          id: e['id'].toString(),
          name: tags['name'] ?? 'محطة وقود',
          address: tags['addr:street'] ?? tags['addr:full'] ?? '',
          latitude: latitude,
          longitude: longitude,
          distanceKm: 0,
          rating: 0,
          crowdStatus: CrowdStatus.low,
          imageUrl: '',
          fuelTypes: const [],
          isOpen: true,
        );
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Overpass Exception: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}
