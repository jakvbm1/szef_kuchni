import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';

class DatabaseService {
  //=====================================================
  //============== CONNECTING TO DATABASE ===============
  //=====================================================

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
      // Copy database from assets
      ByteData data = await rootBundle.load(join("assets","master_db.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await io.File(path).writeAsBytes(bytes, flush: true);
    }

    var database = await openDatabase(
      path, 
      version: 2, // Increment version number on database upgrade
      onUpgrade: (db, oldVersion, newVersion) async {
        //=========== HANDLE DATABASE UPGRADES ============
        // Example:
        if (oldVersion < 2) {
          // Create favourites table if it doesn't exist
          await db.execute('''
            CREATE TABLE IF NOT EXISTS favourites (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              recipe_id INTEGER,
              is_favourite INTEGER DEFAULT 0,
              FOREIGN KEY (recipe_id) REFERENCES recipes (id)
            )
          ''');
        }
      }
    );
    return database;
  }
  
  //=====================================================
  //=================== FUNCTIONS =======================
  //=====================================================

  Future<List<Recipe>> getRecipeNames({
    required int batchNumber,
    required int batchSize,
    required int minTime,
    required int maxTime,
    required List<String> selectedIngredients,
    required List<String> selectedCategories,
    String? enteredKeyword,
  }) async {
    var dbClient = await db;
    List<Recipe> recipeNames = [];

    // Base query
    String query = '''
      SELECT DISTINCT r.id, r.name, r.minutes, r.nutrition, r.steps, 
             COALESCE(f.is_favourite, 0) as is_favourite
      FROM recipes r
      LEFT JOIN ingredients_linking il ON r.id = il.recipe_id
      LEFT JOIN ingredients i ON il.ingredient_id = i.id
      LEFT JOIN tags_linking tl ON r.id = tl.recipe_id
      LEFT JOIN tags t ON tl.tag_id = t.id
      LEFT JOIN favourites f ON r.id = f.recipe_id
      WHERE 1=1
    ''';
    List<dynamic> params = [];

    // Add filters if present
    if (minTime > 0) {
      query += ' AND r.minutes >= ?';
      params.add(minTime);
    }
    if (maxTime > 0) {
      query += ' AND r.minutes <= ?';
      params.add(maxTime);
    }
    if (selectedIngredients.isNotEmpty) {
      String ingredientsFilter = selectedIngredients.map((_) => 'i.name LIKE ?').join(' OR ');
      query += ' AND ($ingredientsFilter)';
      params.addAll(selectedIngredients.map((ingredient) => '%$ingredient%'));
    }
    if (selectedCategories.isNotEmpty) {
      String categoriesFilter = selectedCategories.map((_) => 't.name LIKE ?').join(' OR ');
      query += ' AND ($categoriesFilter)';
      params.addAll(selectedCategories.map((category) => '%$category%'));
    }
    if (enteredKeyword != null && enteredKeyword.isNotEmpty) {
      query += ' AND r.name LIKE ?';
      params.add('%$enteredKeyword%');
    }

    // Add LIMIT and OFFSET for batching
    int offset = (batchNumber - 1) * batchSize;
    query += ' LIMIT ? OFFSET ?';
    params.add(batchSize);
    params.add(offset);

    // Execute the query
    List<Map> rawQuery = await dbClient!.rawQuery(query, params);

    // Process the results
    for (int i = 0; i < rawQuery.length; i++) {
      recipeNames.add(Recipe(
        id: rawQuery[i]["id"],
        name: rawQuery[i]["name"],
        minutes: rawQuery[i]["minutes"],
        nutrition: rawQuery[i]["nutrition"],
        steps: rawQuery[i]["steps"],
        isFavourite: rawQuery[i]["is_favourite"] == 1,  // Convert integer to boolean
      ));
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

  Future<List<String>> getRecipeIngredients(int id) async 
  {
    var dbClient = await db;
    List<String> ingredients = [];
    List<Map> rawQuery = await dbClient!.rawQuery
    (
      '''SELECT name from ingredients LEFT JOIN ingredients_linking
      ON ingredients.id = ingredients_linking.ingredient_id
      WHERE ingredients_linking.recipe_id = ${id}
      '''
    

    );

    for (int i=0; i < rawQuery.length; i++)
    {
      ingredients.add(rawQuery[i]["name"]);
    }
    return ingredients;
  }

  Future<void> addRecipeToFavourites(int id) async
  {
   var dbClient = await db;
   await dbClient!.rawUpdate
   (
    '''UPDATE favourites
        SET is_favourite = 1
        WHERE recipe_id = $id
      
     '''
   );
  }

  Future<void> remRecipeFromFavourites(int id) async
  {
   var dbClient = await db;
   await dbClient!.rawUpdate
   (
    '''UPDATE favourites
        SET is_favourite = 0
        WHERE recipe_id = $id    
     '''
   );
  }
}