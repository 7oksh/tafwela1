import 'package:new_version/models/station_model.dart';

class CrowdUpdateModel {
  final String id;
  final String stationId;
  final String stationName;
  final String stationAddress;
  final String stationImageUrl;
  final CrowdStatus oldStatus;
  final CrowdStatus newStatus;
  final DateTime updatedAt;
  final String updatedByName;

  const CrowdUpdateModel({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.stationAddress,
    required this.stationImageUrl,
    required this.oldStatus,
    required this.newStatus,
    required this.updatedAt,
    required this.updatedByName,
  });

  factory CrowdUpdateModel.fromMap(Map<String, dynamic> map) {
    return CrowdUpdateModel(
      id: map['id'] as String? ?? '',
      stationId: map['stationId'] as String? ?? '',
      stationName: map['stationName'] as String? ?? '',
      stationAddress: map['stationAddress'] as String? ?? '',
      stationImageUrl: map['stationImageUrl'] as String? ?? '',
      oldStatus: _parseCrowdStatus(map['oldStatus']),
      newStatus: _parseCrowdStatus(map['newStatus']),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
      updatedByName: map['updatedByName'] as String? ?? 'موظف',
    );
  }

  static CrowdStatus _parseCrowdStatus(dynamic v) => switch (v?.toString()) {
        'low' => CrowdStatus.low,
        'medium' => CrowdStatus.medium,
        'high' => CrowdStatus.high,
        _ => CrowdStatus.none,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'stationId': stationId,
        'stationName': stationName,
        'stationAddress': stationAddress,
        'stationImageUrl': stationImageUrl,
        'oldStatus': oldStatus.name,
        'newStatus': newStatus.name,
        'updatedAt': updatedAt.toIso8601String(),
        'updatedByName': updatedByName,
      };
}
