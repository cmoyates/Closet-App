import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:closetapp/models/Clothes.dart';
import 'package:closetapp/models/ClothingTypes.dart';

class ClothesDatabase {
  static final ClothesDatabase instance = ClothesDatabase._init();

  static Database? _database;

  ClothesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB("clothes.db"); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {

    final idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    final textType = "TEXT NOT NULL";


    for (var i = 0; i < clothingTypes.length; i++) {
      await db.execute('''
        CREATE TABLE ${clothingTypes[i].title} (
          ${ClothesFields.id} $idType,
          ${ClothesFields.name} $textType,
          ${ClothesFields.image} $textType
        )
        ''');
      }
    }


  Future<Clothes> create(String tableName, Clothes clothes) async {
    final db = await instance.database;

    final id = await db.insert(tableName, clothes.toJson());

    return clothes.copy(id: id);
  }

  Future<Clothes> readClothes(String tableName, int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableName,
      columns: ClothesFields.values,
      where: "${ClothesFields.id} = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Clothes.fromJson(maps.first);
    } else {
      throw Exception("ID $id not found");
    }
  }

  Future<List<Clothes>> readAllClothes(String tableName) async {
    final db = await instance.database;

    final result = await db.query(tableName);
    
    return result.map((json) => Clothes.fromJson(json)).toList();
  }

  Future<int> update(String tableName, Clothes clothes) async {
    final db = await instance.database;

    return db.update(
      tableName,
      clothes.toJson(),
      where: "${ClothesFields.id} = ?",
      whereArgs: [clothes.id]
    );
  }

  Future<int> delete(String tableName, int id) async {
    final db = await instance.database;

    return await db.delete(
      tableName,
      where: "${ClothesFields.id} = ?",
      whereArgs: [id]
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  Future resetAll() async {
    final db = await instance.database;

    for (var i = 0; i < clothingTypes.length; i++) {
      await db.execute("DELETE FROM ${clothingTypes[i].title}");
    }
  }
}