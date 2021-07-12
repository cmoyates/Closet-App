import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:closetapp/models/Clothes.dart';
import 'package:closetapp/models/ClothingTypes.dart';
import 'package:closetapp/models/Outfits.dart';

class ClothesDatabase {
  // Set a static instance of this class
  static final ClothesDatabase instance = ClothesDatabase._init();
  ClothesDatabase._init();
  
  // The actual database
  static Database? _database;

  // A fancy getter for the database
  Future<Database> get database async {
    // If the database already exists return it
    if (_database != null) return _database!;
    // Otherwise open a new database and return it
    _database = await _initDB("clothes.db"); 
    return _database!;
  }

  // Initializes the database
  Future<Database> _initDB(String filePath) async {
    // Get the path where the database will go
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // Open a database there and return it
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Sets up the database when it's initially created
  Future _createDB(Database db, int version) async {

    // The different types that will be used in the SQL queries
    final idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    final textType = "TEXT NOT NULL";
    final intType = "INTEGER NOT NULL";

    // Create tables for the clothing types with the given fields
    for (var i = 0; i < clothingTypes.length; i++) {
      await db.execute('''
        CREATE TABLE ${clothingTypes[i].title} (
          ${ClothesFields.id} $idType,
          ${ClothesFields.name} $textType,
          ${ClothesFields.image} $textType
        )
        '''
      );
    }
    // Create a table for the outfits with the given fields
    await db.execute('''
      CREATE TABLE Outfits (
        ${OutfitsFields.id} $idType,
        ${OutfitsFields.name} $textType,
        ${OutfitsFields.hatIndex} $intType,
        ${OutfitsFields.jacketIndex} $intType,
        ${OutfitsFields.pantsIndex} $intType,
        ${OutfitsFields.shirtIndex} $intType,
        ${OutfitsFields.shoesIndex} $intType
      )
      '''
    );
  }

  // Add new clothes and outfits
  Future<Clothes> createClothes(String tableName, Clothes clothes) async {
    // Reference to the database
    final db = await instance.database;
    // Insert the clothes object from the parameters to the table specified and store the generated ID
    final id = await db.insert(tableName, clothes.toJson());
    // Return a copy of the clothes added with the generated ID
    return clothes.copy(id: id);
  }
  Future<Outfits> createOutfits(Outfits outfit) async {
    // Reference to the database
    final db = await instance.database;
    // Insert the outfit object from the parameters and store the generated ID
    final id = await db.insert("Outfits", outfit.toJson());
    // Return a copy of the outfit added with the generated ID
    return outfit.copy(id: id);
  }

  // Get a piece of clothing or outfit from an ID
  Future<Clothes> readClothes(String tableName, int id) async {
    // Reference to the database
    final db = await instance.database;
    // Get all entries in the specified table with the specified ID
    final maps = await db.query(
      tableName,
      columns: ClothesFields.values,
      where: "${ClothesFields.id} = ?",
      whereArgs: [id],
    );
    // If there is at least one piece of clothing in the table
    if (maps.isNotEmpty) {
      // Return the first
      return Clothes.fromJson(maps.first);
    } else {
      // Otherwise thow an error
      throw Exception("ID $id not found");
    }
  }
  Future<Outfits> readOutfits(int id) async {
    // Reference to the database
    final db = await instance.database;
    // Get all outfits from the database with the specified ID
    final maps = await db.query(
      "Outfits",
      columns: OutfitsFields.values,
      where: "${OutfitsFields.id} = ?",
      whereArgs: [id],
    );
    // If there is at least one outfit
    if (maps.isNotEmpty) {
      // Return the first
      return Outfits.fromJson(maps.first);
    } else {
      // Otherwise thow an error
      throw Exception("ID $id not found");
    }
  }

  // Return all outfits or clothes of a given type
  Future<List<Clothes>> readAllClothes(String tableName) async {
    // Reference to the database
    final db = await instance.database;
    // Get all entries from the specified table
    final result = await db.query(tableName);
    // Return those entries as a list of objects
    return result.map((json) => Clothes.fromJson(json)).toList();
  }
  Future<List<Outfits>> readAllOutfits() async {
    // Reference to the database
    final db = await instance.database;
    // Get all entries from the "Outfits" table
    final result = await db.query("Outfits");
    // Return those entries as a list of objects
    return result.map((json) => Outfits.fromJson(json)).toList();
  }

  // Update clothes or outfits specified
  Future<int> updateClothes(String tableName, Clothes clothes) async {
    // Reference to the database
    final db = await instance.database;
    // Update the entry in the database with the data from the provided object
    return db.update(
      tableName,
      clothes.toJson(),
      where: "${ClothesFields.id} = ?",
      whereArgs: [clothes.id]
    );
  }
  Future<int> updateOutfits(Outfits outfits) async {
    // Reference to the database
    final db = await instance.database;
    // Update the entry in the database with the data from the provided object
    return db.update(
      "Outfits",
      outfits.toJson(),
      where: "${OutfitsFields.id} = ?",
      whereArgs: [outfits.id]
    );
  }

  // Delete specified clothes or outfit
  Future<int> deleteClothes(String tableName, int id) async {
    // Reference to the database
    final db = await instance.database;
    // Delete the clothes with the specified ID in the specified table
    return await db.delete(
      tableName,
      where: "${ClothesFields.id} = ?",
      whereArgs: [id]
    );
  }
  Future<int> deleteOutfits(int id) async {
    // Reference to the database
    final db = await instance.database;
    // Delete the outfit with the given ID
    return await db.delete(
      "Outfits",
      where: "${OutfitsFields.id} = ?",
      whereArgs: [id]
    );
  }

  Future close() async {
    // Reference to the database
    final db = await instance.database;
    // Close the database
    db.close();
  }

  Future resetAll() async {
    // Reference to the database
    final db = await instance.database;
    // Delete everything from each of the clothing type tables
    for (var i = 0; i < clothingTypes.length; i++) {
      await db.execute("DELETE FROM ${clothingTypes[i].title}");
    }
    // Delete everything from the Outfits table
    await db.execute("DELETE FROM Outfits");
  }
}