import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:new_version/database/entities/staff_history_entity.dart';
import 'package:new_version/database/daos/staff_history_dao.dart';

part 'app_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [StaffHistoryEntity])
abstract class AppDatabase extends FloorDatabase {
  StaffHistoryDao get staffHistoryDao;
}
