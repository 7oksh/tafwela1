import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/station.dart';
import 'station_status_service.dart';

/// خدمة إدارة محطات البنزين (مصادر حقيقية من OpenStreetMap + كاش)
class StationsService {
  final StationStatusService _statusService = StationStatusService();

  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const _cacheKey = 'tafwela_osm_stations_cache';
  static const _cacheTimeKey = 'tafwela_osm_stations_cache_time';
  static const _cacheMaxAgeHours = 24;

  /// محطات تجريبية كاحتياطي عند فشل الشبكة
  static List<Station> get _fallbackStations => [
    Station(
      id: 'station_1',
      name: 'محطة موبيل - المعادي',
      address: 'طريق كورنيش المعادي، المعادي، القاهرة',
      latitude: 29.9608,
      longitude: 31.2700,
      services: ['بنزين 95', 'بنزين 92', 'ديزل', 'غسيل سيارات'],
    ),
    Station(
      id: 'station_2',
      name: 'محطة شل - مدينة نصر',
      address: 'طريق النصر، مدينة نصر، القاهرة',
      latitude: 30.0626,
      longitude: 31.3197,
      services: ['بنزين 95', 'ديزل', 'كوفي شوب'],
    ),
    Station(
      id: 'station_3',
      name: 'محطة توتال - الزمالك',
      address: 'كورنيش النيل، الزمالك، القاهرة',
      latitude: 30.0615,
      longitude: 31.2195,
      services: ['بنزين 95', 'بنزين 92', 'ديزل'],
    ),
    Station(
      id: 'station_4',
      name: 'محطة إكسون موبيل - مصر الجديدة',
      address: 'طريق صلاح سالم، مصر الجديدة، القاهرة',
      latitude: 30.0875,
      longitude: 31.3244,
      services: ['بنزين 95', 'ديزل', 'غسيل سيارات', 'مطعم'],
    ),
    Station(
      id: 'station_5',
      name: 'محطة شل - المهندسين',
      address: 'شارع جامعة الدول العربية، المهندسين، الجيزة',
      latitude: 30.0626,
      longitude: 31.2000,
      services: ['بنزين 95', 'بنزين 92', 'ديزل', 'كوفي شوب'],
    ),
    Station(
      id: 'station_6',
      name: 'محطة موبيل - التجمع الخامس',
      address: 'طريق القاهرة السويس، التجمع الخامس، القاهرة',
      latitude: 30.0131,
      longitude: 31.4908,
      services: ['بنزين 95', 'ديزل', 'غسيل سيارات'],
    ),
  ];

  /// تحويل نتيجة Overpass إلى قائمة محطات
  List<Station> _parseOverpassElements(List<dynamic> elements) {
    final stations = <Station>[];
    for (final e in elements) {
      final map = e as Map<String, dynamic>;
      if (map['type'] != 'node' || map['lat'] == null || map['lon'] == null) continue;
      final id = map['id'] as int;
      final lat = (map['lat'] as num).toDouble();
      final lng = (map['lon'] as num).toDouble();
      final tags = map['tags'] as Map<String, dynamic>? ?? {};
      final name = _tag(tags, 'name') ?? _tag(tags, 'brand') ?? 'محطة وقود';
      final address = _buildAddress(tags);
      stations.add(Station(
        id: 'osm_$id',
        name: name,
        address: address,
        latitude: lat,
        longitude: lng,
        services: const [],
      ));
    }
    return stations;
  }

  /// جلب المحطات حول موقعك (نصف قطر ~35 كم) عشان الأقرب يظهروا
  Future<List<Station>> _fetchNearPosition(double lat, double lon) async {
    const delta = 0.32; // تقريباً 35 كم
    final south = lat - delta;
    final north = lat + delta;
    final west = lon - delta;
    final east = lon + delta;
    final query = '''
[out:json][timeout:25];
node["amenity"="fuel"]($south,$west,$north,$east);
out body;
''';
    try {
      final res = await http
          .post(Uri.parse(_overpassUrl), body: {'data': query})
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>? ?? [];
      return _parseOverpassElements(elements);
    } catch (_) {
      return [];
    }
  }

  /// جلب كل المحطات من OpenStreetMap (مصر)
  Future<List<Station>> _fetchFromOverpass() async {
    const query = '''
[out:json][timeout:45];
node["amenity"="fuel"](22,24.5,31.6,37);
out body 2000;
''';
    try {
      final res = await http
          .post(
        Uri.parse(_overpassUrl),
        body: {'data': query},
      )
          .timeout(const Duration(seconds: 35));
      if (res.statusCode != 200) return _fallbackStations;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>? ?? [];
      final stations = _parseOverpassElements(elements);
      return stations.isEmpty ? _fallbackStations : stations;
    } catch (_) {
      return _fallbackStations;
    }
  }

  String? _tag(Map<String, dynamic> tags, String key) {
    final v = tags[key];
    if (v == null) return null;
    return v is String ? v : v.toString();
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    final street = _tag(tags, 'addr:street');
    final city = _tag(tags, 'addr:city');
    final suburb = _tag(tags, 'addr:suburb');
    final full = _tag(tags, 'addr:full');
    if (full != null && full.isNotEmpty) return full;
    if (street != null && street.isNotEmpty) parts.add(street);
    if (suburb != null && suburb.isNotEmpty) parts.add(suburb);
    if (city != null && city.isNotEmpty) parts.add(city);
    return parts.isEmpty ? 'مصر' : parts.join('، ');
  }

  Future<List<Station>> _getCachedStations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_cacheKey);
    final timeStr = prefs.getString(_cacheTimeKey);
    if (jsonStr == null || timeStr == null) return [];
    final cachedAt = DateTime.tryParse(timeStr);
    if (cachedAt == null ||
        DateTime.now().difference(cachedAt).inHours > _cacheMaxAgeHours) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => _stationFromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _setCachedStations(List<Station> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final list = stations.map((s) => _stationToJson(s)).toList();
    await prefs.setString(_cacheKey, jsonEncode(list));
    await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
  }

  Map<String, dynamic> _stationToJson(Station s) => {
    'id': s.id,
    'name': s.name,
    'address': s.address,
    'latitude': s.latitude,
    'longitude': s.longitude,
    'services': s.services,
  };

  Station _stationFromJson(Map<String, dynamic> json) => Station(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    services: (json['services'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  /// إضافة حالة الازدحام لكل محطة
  Future<List<Station>> _withStatus(List<Station> stations) async {
    final result = <Station>[];
    for (final s in stations) {
      final cStatus = await _statusService.getStatus(s.id, 'customer');
      final cUpdate = await _statusService.getLastUpdate(s.id, 'customer');
      final eStatus = await _statusService.getStatus(s.id, 'employee');
      final eUpdate = await _statusService.getLastUpdate(s.id, 'employee');

      result.add(s.copyWith(
        customerStatus: cStatus,
        customerLastUpdate: cUpdate,
        employeeStatus: eStatus,
        employeeLastUpdate: eUpdate,
      ));
    }
    return result;
  }

  /// الحصول على جميع المحطات (من الكاش أو من النت ثم كاش)
  Future<List<Station>> getAllStations() async {
    var stations = await _getCachedStations();
    if (stations.isEmpty) {
      stations = await _fetchFromOverpass();
      if (stations.isNotEmpty) await _setCachedStations(stations);
    }
    return _withStatus(stations);
  }

  /// عندما نعرف موقع المستخدم: نجلب المحطات حوله من النت ثم ندمج مع الكاش
  /// عشان الأقرب (اللي ممكن مش يكونوا في الكاش أو محدودين) يظهروا كلهم
  Future<List<Station>> getStationsWithNearbyFirst(double lat, double lon) async {
    final nearby = await _fetchNearPosition(lat, lon);
    var all = await _getCachedStations();
    if (all.isEmpty) {
      all = await _fetchFromOverpass();
      if (all.isNotEmpty) await _setCachedStations(all);
    }
    final nearbyIds = {for (final s in nearby) s.id};
    final merged = <Station>[...nearby];
    for (final s in all) {
      if (!nearbyIds.contains(s.id)) merged.add(s);
    }
    return _withStatus(merged);
  }

  /// إعادة جلب المحطات من الإنترنت وتحديث الكاش (مثلاً من زر "تحديث")
  Future<List<Station>> refreshStationsFromNetwork() async {
    final stations = await _fetchFromOverpass();
    if (stations.isNotEmpty) await _setCachedStations(stations);
    return _withStatus(stations);
  }

  Future<Station?> getStationById(String id) async {
    final all = await getAllStations();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Station>> searchStations(String query) async {
    final allStations = await getAllStations();
    if (query.isEmpty) return allStations;
    final lowerQuery = query.toLowerCase();
    return allStations.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
          s.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<Station>> filterByStatus(CrowdStatus? status) async {
    final allStations = await getAllStations();
    if (status == null) return allStations;
    return allStations.where((s) {
      final currentStatus = s.employeeStatus ?? s.customerStatus;
      return currentStatus == status;
    }).toList();
  }
}
