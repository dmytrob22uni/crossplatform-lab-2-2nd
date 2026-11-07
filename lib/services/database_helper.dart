import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/app_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('app_database.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2, // Incremented version to force recreation/schema update
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN sort_order INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE posts ADD COLUMN sort_order INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0
      )
    ''');
  }

  Future<List<UserItem>> getUsers() async {
    final db = await instance.database;
    final maps = await db.query('users', orderBy: 'sort_order ASC');
    return maps.map((map) => UserItem.fromMap(map)).toList();
  }

  Future<List<PostItem>> getPosts() async {
    final db = await instance.database;
    final maps = await db.query('posts', orderBy: 'sort_order ASC');
    return maps.map((map) => PostItem.fromMap(map)).toList();
  }

  Future<List<FeedItem>> getAllFeedItems() async {
    final users = await getUsers();
    final posts = await getPosts();
    final all = [...users, ...posts];
    all.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return all;
  }

  Future<void> upsertItems(List<UserItem> users, List<PostItem> posts) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var user in users) {
      batch.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var post in posts) {
      batch.insert(
        'posts',
        post.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> updateItemOrder(int id, bool isUser, int newIndex) async {
    final db = await instance.database;
    final table = isUser ? 'users' : 'posts';
    await db.update(
      table,
      {'sort_order': newIndex},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePost(int id) async {
    final db = await instance.database;
    await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllData() async {
    final db = await instance.database;
    await db.delete('users');
    await db.delete('posts');
  }
}
