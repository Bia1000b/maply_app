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

  VisitDao? _visitDaoInstance;

  PictureDao? _pictureDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `Visit` (`id` INTEGER NOT NULL, `description` TEXT NOT NULL, `rating` REAL NOT NULL, `date` TEXT NOT NULL, `placeName` TEXT NOT NULL, `placeLocation` TEXT NOT NULL, `placeDescription` TEXT NOT NULL, `category` TEXT NOT NULL, `latitude` REAL NOT NULL, `longitude` REAL NOT NULL, `favorite` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Picture` (`id` INTEGER NOT NULL, `visitId` INTEGER NOT NULL, `filePath` TEXT NOT NULL, `description` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  VisitDao get visitDao {
    return _visitDaoInstance ??= _$VisitDao(database, changeListener);
  }

  @override
  PictureDao get pictureDao {
    return _pictureDaoInstance ??= _$PictureDao(database, changeListener);
  }
}

class _$VisitDao extends VisitDao {
  _$VisitDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _visitInsertionAdapter = InsertionAdapter(
            database,
            'Visit',
            (Visit item) => <String, Object?>{
                  'id': item.id,
                  'description': item.description,
                  'rating': item.rating,
                  'date': item.date,
                  'placeName': item.placeName,
                  'placeLocation': item.placeLocation,
                  'placeDescription': item.placeDescription,
                  'category': item.category,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'favorite': item.favorite ? 1 : 0
                }),
        _visitDeletionAdapter = DeletionAdapter(
            database,
            'Visit',
            ['id'],
            (Visit item) => <String, Object?>{
                  'id': item.id,
                  'description': item.description,
                  'rating': item.rating,
                  'date': item.date,
                  'placeName': item.placeName,
                  'placeLocation': item.placeLocation,
                  'placeDescription': item.placeDescription,
                  'category': item.category,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'favorite': item.favorite ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Visit> _visitInsertionAdapter;

  final DeletionAdapter<Visit> _visitDeletionAdapter;

  @override
  Future<List<Visit>> findVisitsByPlaceId(int placeId) async {
    return _queryAdapter.queryList('SELECT * FROM Visit WHERE placeId = ?1',
        mapper: (Map<String, Object?> row) => Visit(
            id: row['id'] as int,
            description: row['description'] as String,
            rating: row['rating'] as double,
            date: row['date'] as String,
            placeName: row['placeName'] as String,
            placeLocation: row['placeLocation'] as String,
            placeDescription: row['placeDescription'] as String,
            category: row['category'] as String,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double,
            favorite: (row['favorite'] as int) != 0),
        arguments: [placeId]);
  }

  @override
  Future<void> insertVisit(Visit visit) async {
    await _visitInsertionAdapter.insert(visit, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteVisit(Visit visit) async {
    await _visitDeletionAdapter.delete(visit);
  }
}

class _$PictureDao extends PictureDao {
  _$PictureDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _pictureInsertionAdapter = InsertionAdapter(
            database,
            'Picture',
            (Picture item) => <String, Object?>{
                  'id': item.id,
                  'visitId': item.visitId,
                  'filePath': item.filePath,
                  'description': item.description
                }),
        _pictureDeletionAdapter = DeletionAdapter(
            database,
            'Picture',
            ['id'],
            (Picture item) => <String, Object?>{
                  'id': item.id,
                  'visitId': item.visitId,
                  'filePath': item.filePath,
                  'description': item.description
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Picture> _pictureInsertionAdapter;

  final DeletionAdapter<Picture> _pictureDeletionAdapter;

  @override
  Future<List<Picture>> findPicturesByVisitId(int visitId) async {
    return _queryAdapter.queryList('SELECT * FROM Picture WHERE visitId = ?1',
        mapper: (Map<String, Object?> row) => Picture(
            id: row['id'] as int,
            visitId: row['visitId'] as int,
            filePath: row['filePath'] as String,
            description: row['description'] as String),
        arguments: [visitId]);
  }

  @override
  Future<void> insertPicture(Picture picture) async {
    await _pictureInsertionAdapter.insert(picture, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePicture(Picture picture) async {
    await _pictureDeletionAdapter.delete(picture);
  }
}
