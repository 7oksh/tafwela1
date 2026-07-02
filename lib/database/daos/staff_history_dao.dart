import 'package:floor/floor.dart';
import 'package:new_version/database/entities/staff_history_entity.dart';

@dao
abstract class StaffHistoryDao {
  @Query('SELECT * FROM staff_history ORDER BY id DESC')
  Future<List<StaffHistoryEntity>> findAllHistory();

  @Query('SELECT * FROM staff_history WHERE updateDate = :date ORDER BY id DESC')
  Future<List<StaffHistoryEntity>> findHistoryByDate(String date);

  @Query('SELECT * FROM staff_history WHERE updateDate >= :startDate AND updateDate <= :endDate ORDER BY id DESC')
  Future<List<StaffHistoryEntity>> findHistoryBetweenDates(String startDate, String endDate);

  @Query('SELECT MAX(responseDurationSeconds) FROM staff_history WHERE updateDate = :date')
  Future<int?> findMaxResponseDurationByDate(String date);

  @Query('SELECT COUNT(*) FROM staff_history WHERE updateDate >= :startDate AND updateDate <= :endDate')
  Future<int?> countHistoryBetweenDates(String startDate, String endDate);

  @Query('SELECT AVG(responseDurationSeconds) FROM staff_history WHERE updateDate >= :startDate AND updateDate <= :endDate')
  Future<double?> findAverageResponseDurationBetweenDates(String startDate, String endDate);

  @insert
  Future<void> insertHistory(StaffHistoryEntity history);
}
