import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/download_record.dart';

/// Database helper for SQLite operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.downloadHistoryTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_url TEXT NOT NULL,
        title TEXT NOT NULL,
        thumbnail_url TEXT,
        platform TEXT,
        local_file_path TEXT NOT NULL,
        file_size INTEGER,
        download_date TEXT NOT NULL
      )
    ''');

    // Create index on download_date for faster queries
    await db.execute('''
      CREATE INDEX idx_download_date 
      ON ${AppConstants.downloadHistoryTable}(download_date DESC)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades in future versions
  }

  // Insert download record
  Future<int> insertDownload(DownloadRecord record) async {
    final db = await database;
    return await db.insert(
      AppConstants.downloadHistoryTable,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all downloads
  Future<List<DownloadRecord>> getAllDownloads() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.downloadHistoryTable,
      orderBy: 'download_date DESC',
    );

    return List.generate(maps.length, (i) => DownloadRecord.fromMap(maps[i]));
  }

  // Get download by ID
  Future<DownloadRecord?> getDownloadById(int id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.downloadHistoryTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DownloadRecord.fromMap(maps.first);
  }

  // Search downloads by title
  Future<List<DownloadRecord>> searchDownloads(String query) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.downloadHistoryTable,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'download_date DESC',
    );

    return List.generate(maps.length, (i) => DownloadRecord.fromMap(maps[i]));
  }

  // Filter downloads by platform
  Future<List<DownloadRecord>> getDownloadsByPlatform(String platform) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.downloadHistoryTable,
      where: 'platform = ?',
      whereArgs: [platform],
      orderBy: 'download_date DESC',
    );

    return List.generate(maps.length, (i) => DownloadRecord.fromMap(maps[i]));
  }

  // Update download record
  Future<int> updateDownload(DownloadRecord record) async {
    final db = await database;
    return await db.update(
      AppConstants.downloadHistoryTable,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Delete download record
  Future<int> deleteDownload(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.downloadHistoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all downloads
  Future<int> clearAllDownloads() async {
    final db = await database;
    return await db.delete(AppConstants.downloadHistoryTable);
  }

  // Get download count
  Future<int> getDownloadCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.downloadHistoryTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
