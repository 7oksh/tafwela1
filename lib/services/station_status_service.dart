import 'package:shared_preferences/shared_preferences.dart';

/// حالة الازدحام في المحطة
enum CrowdStatus {
  crowded,  // مزدحم
  medium,   // متوسط
  quiet,    // هادئ
  noFuel,   // لا يوجد بنزين
}

extension CrowdStatusX on CrowdStatus {
  String get label {
    switch (this) {
      case CrowdStatus.crowded: return 'مزدحم';
      case CrowdStatus.medium: return 'متوسط';
      case CrowdStatus.quiet: return 'هادئ';
      case CrowdStatus.noFuel: return 'لا يوجد بنزين';
    }
  }

  String get value => name;
}

class StationStatusService {
  static String _statusKey(String stationId) => 'station_${stationId}_status';
  static String _timeKey(String stationId) => 'station_${stationId}_lastUpdate';

  Future<void> setStatus(String stationId, CrowdStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey(stationId), status.value);
    await prefs.setString(_timeKey(stationId), DateTime.now().toIso8601String());
  }

  Future<CrowdStatus?> getStatus(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_statusKey(stationId));
    if (v == null) return null;
    switch (v) {
      case 'crowded': return CrowdStatus.crowded;
      case 'medium': return CrowdStatus.medium;
      case 'quiet': return CrowdStatus.quiet;
      case 'noFuel': return CrowdStatus.noFuel;
      default: return null;
    }
  }

  Future<DateTime?> getLastUpdate(String stationId) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_timeKey(stationId));
    if (v == null) return null;
    return DateTime.tryParse(v);
  }
}
