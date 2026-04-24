import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../../models/video_sync_item.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDB('videos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE videos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filePath TEXT NOT NULL,
        duration INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        serverId TEXT
      )
    ''');
  }

  Future<int> insertVideo(VideoSyncItem item) async {
    final db = await instance.database;
    return await db.insert('videos', item.toMap());
  }

  Future<List<VideoSyncItem>> getVideosNeedSync() async {
    final db = await instance.database;
    final result = await db.query(
      'videos',
      where: 'syncStatus != ?',
      whereArgs: [SyncStatus.synced.name],
    );
    return result.map((json) => VideoSyncItem.fromMap(json)).toList();
  }

  Future<int> updateVideoStatus(
    int id,
    SyncStatus status, {
    String? serverId,
  }) async {
    final db = await instance.database;
    final Map<String, dynamic> values = {'syncStatus': status.name};
    if (serverId != null) values['serverId'] = serverId;

    return await db.update('videos', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteVideo(int id) async {
    final db = await instance.database;
    return await db.delete('videos', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
