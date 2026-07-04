import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:new_version/models/station_model.dart';

/// Service for caching station data locally using GetStorage.
/// Cache expires after 30 minutes.
class StationCacheService {
  static const String _cacheKey = 'cached_stations';
  static const String _timestampKey = 'cached_stations_time';
  static const Duration _cacheExpiration = Duration(minutes: 30);

  final GetStorage _storage;

  StationCacheService() : _storage = GetStorage('Settings');

  /// Save stations to local cache with current timestamp
  Future<void> saveStations(List<StationModel> stations) async {
    try {
      final jsonList = stations.map((s) => s.toMap()).toList();
      await _storage.write(_cacheKey, jsonEncode(jsonList));
      await _storage.write(_timestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Silent fail - caching is non-critical
      print('Error saving stations to cache: $e');
    }
  }

  /// Get cached stations if available and not expired
  List<StationModel>? getCachedStations() {
    if (_isCacheExpired()) return null;

    try {
      final jsonString = _storage.read<String>(_cacheKey);
      if (jsonString == null) return null;

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => StationModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error reading cached stations: $e');
      return null;
    }
  }

  /// Check if cached data exists
  bool get hasCachedData {
    return _storage.hasData(_cacheKey) && 
           _storage.hasData(_timestampKey) &&
           !_isCacheExpired();
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _storage.remove(_cacheKey);
    await _storage.remove(_timestampKey);
  }

  /// Check if cache has expired (30 minutes)
  bool _isCacheExpired() {
    final timestampString = _storage.read<String>(_timestampKey);
    if (timestampString == null) return true;

    try {
      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();
      return now.difference(timestamp) > _cacheExpiration;
    } catch (e) {
      return true;
    }
  }
}
