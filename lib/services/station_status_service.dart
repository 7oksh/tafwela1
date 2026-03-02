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
  static String _statusKey(String stationId, String role) => 'station_${stationId}_${role}_status';
  static String _timeKey(String stationId, String role) => 'station_${stationId}_${role}_lastUpdate';

  Future<void> setStatus(String stationId, CrowdStatus status, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey(stationId, role), status.value);
    await prefs.setString(_timeKey(stationId, role), DateTime.now().toIso8601String());
  }

  Future<void> clearStatus(String stationId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statusKey(stationId, role));
    await prefs.remove(_timeKey(stationId, role));
  }

  Future<CrowdStatus?> getStatus(String stationId, String role) async {
    final lastUpdate = await getLastUpdate(stationId, role);
    if (lastUpdate == null) return null;

    // Check if the update is older than 4 hours
    final diff = DateTime.now().difference(lastUpdate);
    if (diff.inHours >= 4) {
      await clearStatus(stationId, role);
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_statusKey(stationId, role));
    if (v == null) return null;
    switch (v) {
      case 'crowded': return CrowdStatus.crowded;
      case 'medium': return CrowdStatus.medium;
      case 'quiet': return CrowdStatus.quiet;
      case 'noFuel': return CrowdStatus.noFuel;
      default: return null;
    }
  }

  Future<DateTime?> getLastUpdate(String stationId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_timeKey(stationId, role));
    if (v == null) return null;
    return DateTime.tryParse(v);
  }
}
