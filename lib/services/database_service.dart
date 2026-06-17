import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'session.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE session(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            token TEXT,
            userId TEXT,
            name TEXT,
            currency TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE notifications(
            id TEXT PRIMARY KEY,
            title TEXT,
            message TEXT,
            type TEXT,
            isRead INTEGER,
            createdAt TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE notifications(
              id TEXT PRIMARY KEY,
              title TEXT,
              message TEXT,
              type TEXT,
              isRead INTEGER,
              createdAt TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          // Double check if notifications table exists, if not create it
          final tableCheck = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='notifications'",
          );
          if (tableCheck.isEmpty) {
            await db.execute('''
              CREATE TABLE notifications(
                id TEXT PRIMARY KEY,
                title TEXT,
                message TEXT,
                type TEXT,
                isRead INTEGER,
                createdAt TEXT
              )
            ''');
          }
        }
      },
    );
  }

  // Session methods
  Future<void> saveSession({
    required String token,
    required String userId,
    required String name,
    required String currency,
  }) async {
    final db = await database;
    await db.delete('session'); // Keep only one row
    await db.insert('session', {
      'token': token,
      'userId': userId,
      'name': name,
      'currency': currency,
    });
  }

  Future<Map<String, dynamic>?> getSession() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('session');
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete('session');
  }

  // Notification methods
  Future<void> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    await db.insert('notifications', {
      'id': notification['id'],
      'title': notification['title'],
      'message': notification['message'],
      'type': notification['type'],
      'isRead': notification['isRead'] ? 1 : 0,
      'createdAt': (notification['createdAt'] as DateTime).toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return {
        'id': maps[i]['id'],
        'title': maps[i]['title'],
        'message': maps[i]['message'],
        'type': maps[i]['type'],
        'isRead': maps[i]['isRead'] == 1,
        'createdAt': DateTime.parse(maps[i]['createdAt']),
      };
    });
  }

  Future<void> updateNotificationReadStatus(String id, bool isRead) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isRead': isRead ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllNotificationsAsRead() async {
    final db = await database;
    await db.update('notifications', {'isRead': 1});
  }

  Future<void> deleteNotification(String id) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllNotifications() async {
    final db = await database;
    await db.delete('notifications');
  }
}
