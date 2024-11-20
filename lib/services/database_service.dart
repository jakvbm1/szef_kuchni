import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:szef_kuchni/Models/Recipe.dart';

class DatabaseService {
  static const String dbAssetPath = "sqlite/mydb.db";
  static const String dbName = "mydb.db";

  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  static Future<Database> getDatabase() async {
    final dbDirPath = await getDatabasesPath();
    final dbPath = join(dbDirPath, dbName);

    final dbExists = await databaseExists(dbPath);

    if (!dbExists) {
      try {
        await Directory(dirname(dbPath)).create(recursive: true);
      } catch (_) {}

      final ByteData data = await rootBundle.load(dbAssetPath);
      final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(dbPath);
  }

  //tu mozna dodwac funkcje do interakcji z baza
  Future<List<Recipe>> getTasks() async {
    final db = await database;
    final data = await db.query("recipes");
    List<Recipe> tasks = data
        .map(
          (e) => Recipe(
            id: e["id"] as int,
            name: e["name"] as String,
            minutes: e["minutes"] as int,
            nutrition: e["nutrition"] as String,
            steps: e["steps"] as String,
          ),
        )
        .toList();
    return tasks;
  }
}
