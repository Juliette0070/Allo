import 'package:flutter/material.dart';
import 'package:allo/models/materiel.dart';
import 'package:allo/api/bdmateriel.dart';

class MaterielDetailsPage extends StatefulWidget {
  final Materiel materiel;
  final Function() onUpdate;

  const MaterielDetailsPage({Key? key, required this.materiel, required this.onUpdate}) : super(key: key);

  @override
  MaterielDetailsPageState createState() => MaterielDetailsPageState();
}

class MaterielDetailsPageState extends State<MaterielDetailsPage> {
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late int _selectedCategorie;
  List<Map<String, dynamic>> _categories = [];
  String _etat = '';

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.materiel.nom);
    _descriptionController = TextEditingController(text: widget.materiel.description);
    _selectedCategorie = widget.materiel.idCategorie; // Initialisation avec la catégorie actuelle du matériel
    _getCategories(); // Appel de la fonction pour récupérer les catégories
    _getEtat(); // Appel de la fonction pour récupérer l'état du matériel
  }

  void _getEtat() async {
    final db = await DatabaseHelper.instance.database;
    final etat = await db.query('etats', where: 'id = ?', whereArgs: [widget.materiel.idEtat]);
    _etat = etat[0]['nom'] as String;
    setState(() {});
  }

  void _getCategories() async {
    final db = await DatabaseHelper.instance.database;
    _categories = await db.query('categories');
    print(_categories);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du matériel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButtonFormField<int>(
              value: _selectedCategorie,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedCategorie = newValue ?? 1;
                });
              },
              items: _categories.map((Map<String, dynamic> categorie) {
                return DropdownMenuItem<int>(
                  value: categorie['id'] as int,
                  child: Text(categorie['nom'] as String),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            const SizedBox(height: 20),
            Text('État: $_etat'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateMateriel();
                  },
                  child: const Text('Modifier'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _deleteMateriel();
                  },
                  child: const Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateMateriel() async {
    final updatedMateriel = widget.materiel.copyWith(
      nom: _nomController.text,
      description: _descriptionController.text,
      idCategorie: _selectedCategorie, // Mettre à jour la catégorie avec la nouvelle valeur
    );
    await DatabaseHelper.instance.updateMateriel(updatedMateriel);
    widget.onUpdate();
    Navigator.pop(context);
  }

  Future<void> _deleteMateriel() async {
    await DatabaseHelper.instance.deleteMateriel(widget.materiel.id);
    widget.onUpdate();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
