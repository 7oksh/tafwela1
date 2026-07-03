import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:new_version/database/entities/staff_history_entity.dart';
import 'package:new_version/database/entities/station_entity.dart';
import 'package:new_version/database/entities/pending_write_entity.dart';
import 'package:new_version/database/daos/staff_history_dao.dart';
import 'package:new_version/database/daos/station_dao.dart';
import 'package:new_version/database/daos/pending_write_dao.dart';

part 'app_database.g.dart';

@Database(
  version: 3,
  entities: [
    StaffHistoryEntity,
    StationEntity,
    PendingWriteEntity,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  StaffHistoryDao get staffHistoryDao;
  StationDao get stationDao;
  PendingWriteDao get pendingWriteDao;

  static Migration get migration1to2 => Migration(1, 2, (database) async {
        await database.execute('''
          CREATE TABLE IF NOT EXISTS `stations` (
            `id` TEXT NOT NULL,
            `name` TEXT NOT NULL,
            `address` TEXT NOT NULL,
            `latitude` REAL NOT NULL,
            `longitude` REAL NOT NULL,
            `rating` REAL NOT NULL,
            `crowdStatus` TEXT NOT NULL,
            `imageUrl` TEXT NOT NULL,
            `isOpen` INTEGER NOT NULL,
            `fuelTypesJson` TEXT NOT NULL,
            `servicesJson` TEXT NOT NULL,
            `cachedAt` TEXT NOT NULL,
            PRIMARY KEY (`id`)
          )
        ''');
      });

  static Migration get migration2to3 => Migration(2, 3, (database) async {
        await database.execute('''
          CREATE TABLE IF NOT EXISTS `pending_writes` (
            `id` INTEGER PRIMARY KEY AUTOINCREMENT,
            `collection` TEXT NOT NULL,
            `docId` TEXT NOT NULL,
            `operation` TEXT NOT NULL,
            `dataJson` TEXT NOT NULL,
            `createdAt` TEXT NOT NULL
          )
        ''');
      });
}
