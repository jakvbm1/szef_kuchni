import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:szef_kuchni_v2/models/name.dart';

class DatabaseService {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initializeDatabase();
    return _db;
  }

  initializeDatabase() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "master_db.db");
    bool dbExists = await io.File(path).exists();
    if (!dbExists) {
      ByteData data = await rootBundle.load(join("assets","master_db.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await io.File(path).writeAsBytes(bytes, flush: true);
    }

    var database = await openDatabase(path, version: 1);
    return database;
  }

  Future<List<NameModel>> getRecipeNames({
    required int fromId, 
    required int toId
  }) async {
    var dbClient = await db;
    List<NameModel> recipeNames = [];
    List<Map> rawQuery = await dbClient!.rawQuery(
      'SELECT id, name FROM recipes WHERE id BETWEEN ? AND ?',
      [fromId, toId]
    );
    
    for(int i = 0; i < rawQuery.length; i++) {
      recipeNames.add(NameModel(rawQuery[i]["id"], rawQuery[i]["name"]));
    }
    return recipeNames;
  }


  Future<List<NameModel>> getFilteredResults(String enteredKeyword) async {
    var dbClient = await db;
    String keyword = enteredKeyword.toLowerCase();
    
    // Create letter swap variations
    List<String> variations = [keyword];
    for (int i = 0; i < keyword.length - 1; i++) {
      var chars = keyword.split('');
      var temp = chars[i];
      chars[i] = chars[i + 1];
      chars[i + 1] = temp;
      variations.add(chars.join());
    }
    
    String whereClause = variations.map((v) => 'LOWER(name) LIKE ?').join(' OR ');
    List<String> params = variations.map((v) => '%$v%').toList();
    
    params.addAll([keyword, '$keyword%']);
    
    List<Map> rawQuery = await dbClient!.rawQuery(
      '''SELECT id, name FROM recipes 
         WHERE $whereClause
         ORDER BY 
           CASE 
             WHEN LOWER(name) = ? THEN 1
             WHEN LOWER(name) LIKE ? THEN 2
             ELSE 3
           END
         LIMIT 40''',
      params
    );
    
    List<NameModel> recipeNames = [];
    for(int i = 0; i < rawQuery.length; i++) {
      recipeNames.add(NameModel(rawQuery[i]["id"], rawQuery[i]["name"]));
    }
    return recipeNames;
  }


  Future<List<String>> getIngredientsNames() async {
    var dbClient = await db;
    List<String> ingredientNames = [];
    List<Map> rawQuery = await dbClient!.rawQuery(
      'SELECT name FROM ingredients'
    );
    
    for(int i = 0; i < rawQuery.length; i++) {
      ingredientNames.add(rawQuery[i]["name"]);
    }
    return ingredientNames;
  }

  Future<List<String>> getCategoriesNames() async {
    var dbClient = await db;
    List<String> categoryNames = [];
    List<Map> rawQuery = await dbClient!.rawQuery(
      'SELECT name FROM tags'
    );
    
    for(int i = 0; i < rawQuery.length; i++) {
      categoryNames.add(rawQuery[i]["name"]);
    }
    return categoryNames;
  }
}