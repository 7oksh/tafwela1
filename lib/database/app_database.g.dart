// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  StaffHistoryDao? _staffHistoryDaoInstance;

  StationDao? _stationDaoInstance;

  PendingWriteDao? _pendingWriteDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 3,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `staff_history` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `stationName` TEXT NOT NULL, `staffId` TEXT NOT NULL, `staffName` TEXT NOT NULL, `oldStatus` TEXT NOT NULL, `newStatus` TEXT NOT NULL, `updateTime` TEXT NOT NULL, `updateDate` TEXT NOT NULL, `responseDurationSeconds` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `stations` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `address` TEXT NOT NULL, `latitude` REAL NOT NULL, `longitude` REAL NOT NULL, `rating` REAL NOT NULL, `crowdStatus` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `isOpen` INTEGER NOT NULL, `fuelTypesJson` TEXT NOT NULL, `servicesJson` TEXT NOT NULL, `cachedAt` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `pending_writes` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `collection` TEXT NOT NULL, `docId` TEXT NOT NULL, `operation` TEXT NOT NULL, `dataJson` TEXT NOT NULL, `createdAt` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  StaffHistoryDao get staffHistoryDao {
    return _staffHistoryDaoInstance ??=
        _$StaffHistoryDao(database, changeListener);
  }

  @override
  StationDao get stationDao {
    return _stationDaoInstance ??= _$StationDao(database, changeListener);
  }

  @override
  PendingWriteDao get pendingWriteDao {
    return _pendingWriteDaoInstance ??=
        _$PendingWriteDao(database, changeListener);
  }
}

class _$StaffHistoryDao extends StaffHistoryDao {
  _$StaffHistoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _staffHistoryEntityInsertionAdapter = InsertionAdapter(
            database,
            'staff_history',
            (StaffHistoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'stationName': item.stationName,
                  'staffId': item.staffId,
                  'staffName': item.staffName,
                  'oldStatus': item.oldStatus,
                  'newStatus': item.newStatus,
                  'updateTime': item.updateTime,
                  'updateDate': item.updateDate,
                  'responseDurationSeconds': item.responseDurationSeconds
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StaffHistoryEntity>
      _staffHistoryEntityInsertionAdapter;

  @override
  Future<List<StaffHistoryEntity>> findAllHistory() async {
    return _queryAdapter.queryList(
        'SELECT * FROM staff_history ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => StaffHistoryEntity(
            id: row['id'] as int?,
            stationName: row['stationName'] as String,
            staffId: row['staffId'] as String,
            staffName: row['staffName'] as String,
            oldStatus: row['oldStatus'] as String,
            newStatus: row['newStatus'] as String,
            updateTime: row['updateTime'] as String,
            updateDate: row['updateDate'] as String,
            responseDurationSeconds: row['responseDurationSeconds'] as int));
  }

  @override
  Future<List<StaffHistoryEntity>> findHistoryByDate(String date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM staff_history WHERE updateDate = ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => StaffHistoryEntity(
            id: row['id'] as int?,
            stationName: row['stationName'] as String,
            staffId: row['staffId'] as String,
            staffName: row['staffName'] as String,
            oldStatus: row['oldStatus'] as String,
            newStatus: row['newStatus'] as String,
            updateTime: row['updateTime'] as String,
            updateDate: row['updateDate'] as String,
            responseDurationSeconds: row['responseDurationSeconds'] as int),
        arguments: [date]);
  }

  @override
  Future<List<StaffHistoryEntity>> findHistoryBetweenDates(
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM staff_history WHERE updateDate >= ?1 AND updateDate <= ?2 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => StaffHistoryEntity(id: row['id'] as int?, stationName: row['stationName'] as String, staffId: row['staffId'] as String, staffName: row['staffName'] as String, oldStatus: row['oldStatus'] as String, newStatus: row['newStatus'] as String, updateTime: row['updateTime'] as String, updateDate: row['updateDate'] as String, responseDurationSeconds: row['responseDurationSeconds'] as int),
        arguments: [startDate, endDate]);
  }

  @override
  Future<int?> findMaxResponseDurationByDate(String date) async {
    return _queryAdapter.query(
        'SELECT MAX(responseDurationSeconds) FROM staff_history WHERE updateDate = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [date]);
  }

  @override
  Future<int?> countHistoryBetweenDates(
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM staff_history WHERE updateDate >= ?1 AND updateDate <= ?2',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [startDate, endDate]);
  }

  @override
  Future<double?> findAverageResponseDurationBetweenDates(
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.query(
        'SELECT AVG(responseDurationSeconds) FROM staff_history WHERE updateDate >= ?1 AND updateDate <= ?2',
        mapper: (Map<String, Object?> row) => row.values.first as double,
        arguments: [startDate, endDate]);
  }

  @override
  Future<void> insertHistory(StaffHistoryEntity history) async {
    await _staffHistoryEntityInsertionAdapter.insert(
        history, OnConflictStrategy.abort);
  }
}

class _$StationDao extends StationDao {
  _$StationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _stationEntityInsertionAdapter = InsertionAdapter(
            database,
            'stations',
            (StationEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'address': item.address,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'rating': item.rating,
                  'crowdStatus': item.crowdStatus,
                  'imageUrl': item.imageUrl,
                  'isOpen': item.isOpen ? 1 : 0,
                  'fuelTypesJson': item.fuelTypesJson,
                  'servicesJson': item.servicesJson,
                  'cachedAt': item.cachedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StationEntity> _stationEntityInsertionAdapter;

  @override
  Future<List<StationEntity>> getAllStations() async {
    return _queryAdapter.queryList('SELECT * FROM stations',
        mapper: (Map<String, Object?> row) => StationEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            address: row['address'] as String,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double,
            rating: row['rating'] as double,
            crowdStatus: row['crowdStatus'] as String,
            imageUrl: row['imageUrl'] as String,
            isOpen: (row['isOpen'] as int) != 0,
            fuelTypesJson: row['fuelTypesJson'] as String,
            servicesJson: row['servicesJson'] as String,
            cachedAt: row['cachedAt'] as String));
  }

  @override
  Future<void> clearStations() async {
    await _queryAdapter.queryNoReturn('DELETE FROM stations');
  }

  @override
  Future<void> insertOrUpdateStations(List<StationEntity> stations) async {
    await _stationEntityInsertionAdapter.insertList(
        stations, OnConflictStrategy.replace);
  }
}

class _$PendingWriteDao extends PendingWriteDao {
  _$PendingWriteDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _pendingWriteEntityInsertionAdapter = InsertionAdapter(
            database,
            'pending_writes',
            (PendingWriteEntity item) => <String, Object?>{
                  'id': item.id,
                  'collection': item.collection,
                  'docId': item.docId,
                  'operation': item.operation,
                  'dataJson': item.dataJson,
                  'createdAt': item.createdAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PendingWriteEntity>
      _pendingWriteEntityInsertionAdapter;

  @override
  Future<List<PendingWriteEntity>> getAllPendingWrites() async {
    return _queryAdapter.queryList(
        'SELECT * FROM pending_writes ORDER BY id ASC',
        mapper: (Map<String, Object?> row) => PendingWriteEntity(
            id: row['id'] as int?,
            collection: row['collection'] as String,
            docId: row['docId'] as String,
            operation: row['operation'] as String,
            dataJson: row['dataJson'] as String,
            createdAt: row['createdAt'] as String));
  }

  @override
  Future<void> deletePendingWrite(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM pending_writes WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int> insertPendingWrite(PendingWriteEntity write) {
    return _pendingWriteEntityInsertionAdapter.insertAndReturnId(
        write, OnConflictStrategy.abort);
  }
}
