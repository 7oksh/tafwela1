import 'package:floor/floor.dart';

@Entity(tableName: 'staff_history')
class StaffHistoryEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String stationName;
  final String staffId;
  final String staffName;
  final String oldStatus;
  final String newStatus;
  final String updateTime;
  final String updateDate;
  final int responseDurationSeconds;

  StaffHistoryEntity({
    this.id,
    required this.stationName,
    required this.staffId,
    required this.staffName,
    required this.oldStatus,
    required this.newStatus,
    required this.updateTime,
    required this.updateDate,
    required this.responseDurationSeconds,
  });
}
