import 'package:floor/floor.dart';
import 'package:new_version/database/entities/pending_write_entity.dart';

@dao
abstract class PendingWriteDao {
  @insert
  Future<int> insertPendingWrite(PendingWriteEntity write);

  @Query('SELECT * FROM pending_writes ORDER BY id ASC')
  Future<List<PendingWriteEntity>> getAllPendingWrites();

  @Query('DELETE FROM pending_writes WHERE id = :id')
  Future<void> deletePendingWrite(int id);
}
