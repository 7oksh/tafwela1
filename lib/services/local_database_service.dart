import 'package:get/get.dart';
import 'package:new_version/database/app_database.dart';
import 'package:new_version/database/entities/staff_history_entity.dart';

class LocalDatabaseService extends GetxService {
  AppDatabase? _database;

  Future<LocalDatabaseService> init() async {
    _database = await $FloorAppDatabase.databaseBuilder('staff_history.db').build();
    return this;
  }

  AppDatabase get db {
    if (_database == null) throw Exception("Database not initialized");
    return _database!;
  }

  Future<void> addHistory(StaffHistoryEntity entity) async {
    await db.staffHistoryDao.insertHistory(entity);
  }
}
