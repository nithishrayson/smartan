import 'package:path_provider/path_provider.dart';
import 'package:smartan/models/ImageMetadata.dart';
import 'package:smartan/models/pose_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _db;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb('images.db');
    return _db!;
  }

  Future<Database> _initDb(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 2, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE images (
        id TEXT PRIMARY KEY,
        localPath TEXT,
        remoteUrl TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<void> insertImage(ImageMetadata image) async {
    final db = await database;
    print("Inserting: ${image.toMap()}");
    await db.insert(
      'images',
      image.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ImageMetadata>> getAllImages() async {
    final db = await database;
    final maps = await db.query('images');
    print('📸 Query returned ${maps.length} rows');
    return maps.map((m) => ImageMetadata.fromMap(m)).toList();
  }

  Future<void> deleteImage(String id) async {
    final db = await database;
    await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllImages() async {
    final db = await database;
    await db.delete('images');
  }

  Future<void> printDatabasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'images.db');
    print('📁 SQLite DB Path: $dbPath');
  }

  Future<Database> openLocalDb() async {
    final path = join(await getDatabasesPath(), 'images.db');
    return openDatabase(path);
  }

  Future<List<PoseEntry>> fetchLocalEntries(Database db) async {
    final rows = await db.query('pose_entries');
    return rows.map((row) => PoseEntry.fromSql(row)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
