import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:allo/models/materiel.dart';

class DatabaseHelper {
  static const _databaseName = 'mon_application.db';
  static const _databaseVersion = 1;
  static const _tableName = 'materiels';

  // Créer une instance unique de DatabaseHelper
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY,
        nom TEXT NOT NULL,
        description TEXT NOT NULL,
        disponible INTEGER,
        categorie TEXT
      );
    ''');
  }

  // récupérer l'id le plus haut
  Future<int> getMaxId() async {
    final db = await database;
    final List<Map<String, dynamic>> materielsMap = await db.query(_tableName);
    int maxId = 0;
    for (int i = 0; i < materielsMap.length; i++) {
      if (materielsMap[i]['id'] > maxId) {
        maxId = materielsMap[i]['id'];
      }
    }
    return maxId;
  }

  Future<void> insertMateriel(Materiel materiel) async {
    final db = await database;
    await db.insert(
      _tableName,
      materiel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Materiel>> getAllMateriels() async {
    final db = await database;
    final List<Map<String, dynamic>> materielsMap = await db.query(_tableName);
    return List.generate(materielsMap.length, (index) {
      return Materiel.fromMap(materielsMap[index]);
    });
  }

  Future<List<Materiel>> getMaterielsDisponibles(bool disponible) async {
    final db = await database;
    final List<Map<String, dynamic>> materielsMap = await db.query(_tableName, where: 'disponible = ?', whereArgs: [disponible ? 1 : 0]);
    return List.generate(materielsMap.length, (index) {
      return Materiel.fromMap(materielsMap[index]);
    });
  }

  Future<void> updateMateriel(Materiel materiel) async {
    final db = await database;
    await db.update(
      _tableName,
      materiel.toMap(),
      where: 'id = ?',
      whereArgs: [materiel.id],
    );
  }

  Future<void> deleteMateriel(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
