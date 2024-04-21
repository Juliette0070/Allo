import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:allo/models/materiel.dart';
import 'package:allo/api/bdapi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  static const _databaseName = 'mon_application.db';
  static const _databaseVersion = 1;
  static const _tableMateriels = 'materiels';
  static const _tableCategories = 'categories';
  static const _tableEtats = 'etats';

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
      CREATE TABLE $_tableEtats (
        id INTEGER PRIMARY KEY,
        nom TEXT NOT NULL
      );
    ''');
    await db.execute('''INSERT INTO $_tableEtats (id, nom) VALUES (1, 'disponible');''');
    await db.execute('''INSERT INTO $_tableEtats (id, nom) VALUES (2, 'en cours de pret');''');
    await db.execute('''INSERT INTO $_tableEtats (id, nom) VALUES (3, 'pret fini');''');

    await db.execute('''
      CREATE TABLE $_tableCategories (
        id INTEGER PRIMARY KEY,
        nom TEXT NOT NULL
      );
    ''');
    await db.execute('''INSERT INTO $_tableCategories (id, nom) VALUES (1, 'Autre');''');
    await db.execute('''INSERT INTO $_tableCategories (id, nom) VALUES (2, 'Informatique');''');
    await db.execute('''INSERT INTO $_tableCategories (id, nom) VALUES (3, 'Electroménager');''');
    await db.execute('''INSERT INTO $_tableCategories (id, nom) VALUES (4, 'Bricolage');''');
    await db.execute('''INSERT INTO $_tableCategories (id, nom) VALUES (5, 'Jardinage');''');
    await db.execute('''INSERT INTO $_tableCategories (id, nom) VALUES (6, 'Sport');''');
    await db.execute('''INSERT INTO $_tableCategories (id, nom) VALUES (7, 'Outillage');''');
    await db.execute('''
      CREATE TABLE $_tableMateriels (
        id INTEGER PRIMARY KEY,
        nom TEXT NOT NULL,
        description TEXT NOT NULL,
        uuid_utilisateur TEXT NOT NULL,
        id_categorie INTEGER,
        id_etat INTEGER,
        id_annonce INTEGER,
        FOREIGN KEY (id_categorie) REFERENCES categories (id),
        FOREIGN KEY (id_etat) REFERENCES etats (id)
      );
    ''');
  }

  // récupérer l'id le plus haut
  Future<int> getMaxId() async {
    final db = await database;
    final List<Map<String, dynamic>> materielsMap = await db.query(_tableMateriels);
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
      _tableMateriels,
      materiel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Materiel>> getAllMateriels() async {
    final db = await database;
    final List<Map<String, dynamic>> materielsMap = await db.query(_tableMateriels);
    return List.generate(materielsMap.length, (index) {
      return Materiel.fromMap(materielsMap[index]);
    });
  }

  Future<List<Materiel>> getMaterielsDisponibles(uuid) async {
    final db = await database;
    final List<Map<String, dynamic>> materielsMap = await db.query(_tableMateriels, where: 'id_etat = 1 and uuid_utilisateur == ?', whereArgs: [uuid]);
    return List.generate(materielsMap.length, (index) {
      return Materiel.fromMap(materielsMap[index]);
    });
  }

  Future<List<Materiel>> getMaterielsNonDisponibles(uuid) async {
    final db = await database;
    final List<Map<String, dynamic>> materielsMap = await db.query(_tableMateriels, where: '(id_etat = 2 or id_etat = 3) and uuid_utilisateur == ?', whereArgs: [uuid]);
    print(materielsMap);
    return List.generate(materielsMap.length, (index) {
      return Materiel.fromMap(materielsMap[index]);
    });
  }

  Future<void> updateMateriel(Materiel materiel) async {
    final db = await database;
    await db.update(
      _tableMateriels,
      materiel.toMap(),
      where: 'id = ?',
      whereArgs: [materiel.id],
    );
  }

  Future<void> deleteMateriel(int id) async {
    final db = await database;
    await db.delete(
      _tableMateriels,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // actualiser la disponibilité des matériels depuis supabase
  Future<void> refreshMaterielsDisponibilite() async {
    final SupabaseService supabaseService = SupabaseService(Supabase.instance.client);
    // materiels en cours de prêt
    List<Map<String, dynamic>> materielsEnCoursJson = await supabaseService.fetchMaterielsEnCours();
    List<Materiel> materielsEnCours = [];
    for (var materielJson in materielsEnCoursJson) {
      String matJson = materielJson['json_materiel_pret'];
      Map<String, dynamic> matMap = jsonDecode(matJson);
      materielsEnCours.add(Materiel.fromJson(matMap));
    }
    // materiels des prêts finis
    List<Map<String, dynamic>> materielsFinisJson = await supabaseService.fetchMaterielsFinis();
    List<Materiel> materielsFinis = [];
    for (var materielJson in materielsFinisJson) {
      String matJson = materielJson['json_materiel_pret'];
      Map<String, dynamic> matMap = jsonDecode(matJson);
      materielsFinis.add(Materiel.fromJson(matMap));
    }
    List<Materiel> materiels = await getAllMateriels();
    bool materielTrouve = false;
    for (var materiel in materiels) {
      for (var matEnCours in materielsEnCours) {
        if (materielsEgaux(materiel, matEnCours)) {
          materiel.setIdEtat(2);
          await updateMateriel(materiel);
          materielTrouve = true;
          break;
        }
      }
      for (var matFini in materielsFinis) {
        if (materielsEgaux(materiel, matFini)) {
          materiel.setIdEtat(3);
          await updateMateriel(materiel);
          materielTrouve = true;
          break;
        }
      }
      if (materielTrouve) {
        materielTrouve = false;
        continue;
      } else {
        materiel.setIdEtat(1);
        await updateMateriel(materiel);
      }
    }
  }

  // vérifie si deux matériels sont égaux
  bool materielsEgaux(Materiel mat1, Materiel mat2) {
    if (mat1.id == mat2.id && mat1.nom == mat2.nom &&
        mat1.description == mat2.description &&
        mat1.uuidUtilisateur == mat2.uuidUtilisateur &&
        mat1.idCategorie == mat2.idCategorie) {
      return true;
    }
    return false;
  }
}
