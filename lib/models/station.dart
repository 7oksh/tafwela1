import '../services/station_status_service.dart';

/// نموذج بيانات محطة البنزين
class Station {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> services; // الخدمات المتاحة (مثل: بنزين 95، ديزل، غسيل سيارات)
  final double? distanceKm; // المسافة بالكيلومتر من موقع المستخدم (اختياري)

  // تقييم العملاء
  CrowdStatus? customerStatus;
  DateTime? customerLastUpdate;

  // حالة موظف المحطة
  CrowdStatus? employeeStatus;
  DateTime? employeeLastUpdate;

  Station({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.services = const [],
    this.distanceKm,
    this.customerStatus,
    this.customerLastUpdate,
    this.employeeStatus,
    this.employeeLastUpdate,
  });

  /// الحصول على لون حالة معينة
  int colorForStatus(CrowdStatus? s) {
    switch (s) {
      case CrowdStatus.crowded:
        return 0xFFFF5252; // أحمر
      case CrowdStatus.medium:
        return 0xFFFFA726; // برتقالي
      case CrowdStatus.quiet:
        return 0xFF66BB6A; // أخضر
      case CrowdStatus.noFuel:
        return 0xFF757575; // رمادي غامق
      default:
        return 0xFF9E9E9E; // رمادي
    }
  }

  /// الحصول على أيقونة حالة معينة
  String iconForStatus(CrowdStatus? s) {
    switch (s) {
      case CrowdStatus.crowded:
        return '🔴';
      case CrowdStatus.medium:
        return '🟠';
      case CrowdStatus.quiet:
        return '🟢';
      case CrowdStatus.noFuel:
        return '🚫';
      default:
        return '⚪';
    }
  }

  /// نسخ المحطة مع تحديث الحالة
  Station copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? services,
    double? distanceKm,
    CrowdStatus? customerStatus,
    DateTime? customerLastUpdate,
    CrowdStatus? employeeStatus,
    DateTime? employeeLastUpdate,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      services: services ?? this.services,
      distanceKm: distanceKm ?? this.distanceKm,
      customerStatus: customerStatus ?? this.customerStatus,
      customerLastUpdate: customerLastUpdate ?? this.customerLastUpdate,
      employeeStatus: employeeStatus ?? this.employeeStatus,
      employeeLastUpdate: employeeLastUpdate ?? this.employeeLastUpdate,
    );
  }
}
