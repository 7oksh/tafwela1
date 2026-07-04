import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:new_version/models/place_result.dart';

/// Geocoding service using OpenStreetMap's Nominatim API.
class NominatimService {
  final Dio dio;
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  NominatimService(this.dio);

  /// Search for places by query string.
  /// Returns a list of up to 8 results, biased toward the user's location if provided.
  Future<List<PlaceResult>> search(
    String query, {
    double? lat,
    double? lng,
  }) async {
    if (query.trim().isEmpty) return [];

    final params = {
      'q': query,
      'format': 'json',
      'limit': '8',
      'addressdetails': '1',
      if (lat != null && lng != null)
        'viewbox': '${lng - 0.3},${lat + 0.3},${lng + 0.3},${lat - 0.3}',
      if (lat != null) 'bounded': '0',
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);

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

      debugPrint('Nominatim search: ${uri.toString()}');
      debugPrint('Nominatim status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Nominatim error: ${response.data}');
        return [];
      }

      final List<dynamic> json = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      return await compute(_parseNominatimIsolate, json);
    } catch (e, stackTrace) {
      debugPrint('Nominatim exception: $e');
      debugPrint(stackTrace.toString());
      return []; // Never throw to the UI
    }
  }
}

/// Pure top-level function for background isolate processing
List<PlaceResult> _parseNominatimIsolate(List<dynamic> json) {
  return json
      .map((e) => PlaceResult.fromJson(e as Map<String, dynamic>))
      .toList();
}
