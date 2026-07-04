import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/utils/exceptions.dart';

/// Fetches nearby fuel stations from OpenStreetMap using Overpass API.
class OverpassService {
  final Dio dio;
  static const String _baseUrl = 'https://overpass-api.de/api/interpreter';

  OverpassService(this.dio);

  Future<List<StationModel>> fetchNearbyStations(
    double lat,
    double lng, {
    double radiusInKm = 10,
  }) async {
    final double radiusMeters = radiusInKm * 1000;
    final query =
        '''
[out:json][timeout:25];
(
  node["amenity"="fuel"](around:$radiusMeters,$lat,$lng);
  way["amenity"="fuel"](around:$radiusMeters,$lat,$lng);
  relation["amenity"="fuel"](around:$radiusMeters,$lat,$lng);
);
out center;
''';

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {'data': query});

    try {
      final response = await dio.get(
        uri.toString(),
        options: Options(
          headers: const {
            'User-Agent': 'Tafwela/1.0',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('============================');
      debugPrint('URL: $uri');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.data}');
      debugPrint('============================');

      if (response.statusCode != 200) {
        throw Exception(
          'Overpass Error ${response.statusCode}\n${response.data}',
        );
      }

      final Map<String, dynamic> json = response.data is String
          ? jsonDecode(response.data)
          : response.data;

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
    } on DioException catch (e) {
      debugPrint('Overpass DioException: $e');
      throw ApiException(DioExceptionHandler.handle(e));
    } catch (e, stackTrace) {
      debugPrint('Overpass Exception: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}
