import 'package:floor/floor.dart';
import 'package:new_version/database/entities/station_entity.dart';

@dao
abstract class StationDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOrUpdateStations(List<StationEntity> stations);

  @Query('SELECT * FROM stations')
  Future<List<StationEntity>> getAllStations();

  @Query('DELETE FROM stations')
  Future<void> clearStations();
}
