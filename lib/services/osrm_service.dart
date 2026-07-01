import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Result returned by [OsrmService.getRoute].
class OsrmRouteResult {
  final double distanceMeters;
  final int durationSeconds;
  final List<LatLng> polyline;

  const OsrmRouteResult({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polyline,
  });
}

/// Calculates driving routes via the public OSRM demo server.
class OsrmService {
  static const _baseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  /// Returns the driving route between two points, or `null` on failure.
  Future<OsrmRouteResult?> getRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    // OSRM expects coordinates as lng,lat (not lat,lng).
    final url = '$_baseUrl/$startLng,$startLat;$endLng,$endLat'
        '?overview=full&geometries=polyline';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty) return null;

      final route = routes[0] as Map<String, dynamic>;
      return OsrmRouteResult(
        distanceMeters: (route['distance'] as num).toDouble(),
        durationSeconds: (route['duration'] as num).toInt(),
        polyline: _decodePolyline(route['geometry'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  /// Decodes a Google-compatible encoded polyline string into [LatLng] points.
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      // Decode latitude
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      // Decode longitude
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
