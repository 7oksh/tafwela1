import 'package:get/get.dart';
import 'package:new_version/database/app_database.dart';
import 'package:new_version/database/entities/pending_write_entity.dart';
import 'package:new_version/database/entities/staff_history_entity.dart';
import 'package:new_version/database/entities/station_entity.dart';
import 'package:new_version/database/mappers/station_mapper.dart';
import 'package:new_version/models/station_model.dart';

class LocalDatabaseService extends GetxService {
  AppDatabase? _database;

  Future<LocalDatabaseService> init() async {
    _database = await $FloorAppDatabase
        .databaseBuilder('staff_history.db')
        .addMigrations([
          AppDatabase.migration1to2,
          AppDatabase.migration2to3,
        ])
        .build();
    return this;
  }

  AppDatabase get db {
    if (_database == null) throw Exception('Database not initialized');
    return _database!;
  }

  Future<void> addHistory(StaffHistoryEntity entity) async {
    await db.staffHistoryDao.insertHistory(entity);
  }

  Future<void> cacheStations(List<StationModel> stations) async {
    final entities = stations.map((s) => StationEntity.fromModel(s)).toList();
    await db.stationDao.insertOrUpdateStations(entities);
  }

  Future<List<StationModel>> getCachedStations() async {
    final entities = await db.stationDao.getAllStations();
    return entities.map((e) => e.toModel()).toList();
  }

  Future<void> addPendingWrite({
    required String collection,
    required String docId,
    required String operation,
    required String dataJson,
  }) async {
    await db.pendingWriteDao.insertPendingWrite(
      PendingWriteEntity(
        collection: collection,
        docId: docId,
        operation: operation,
        dataJson: dataJson,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<List<PendingWriteEntity>> getPendingWrites() async {
    return db.pendingWriteDao.getAllPendingWrites();
  }

  Future<void> deletePendingWrite(int id) async {
    await db.pendingWriteDao.deletePendingWrite(id);
  }
}
