import 'package:allo/api/bdapi.dart';
import 'package:flutter/material.dart';
import 'package:allo/models/materiel.dart';
import 'package:allo/api/bdmateriel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String _categorie = '';

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.materiel.nom);
    _descriptionController = TextEditingController(text: widget.materiel.description);
    _selectedCategorie = widget.materiel.idCategorie; // Initialisation avec la catégorie actuelle du matériel
    _getCategories(); // Appel de la fonction pour récupérer les catégories
    _getEtat(); // Appel de la fonction pour récupérer l'état du matériel
    _getCategorie(); // Appel de la fonction pour récupérer la catégorie du matériel
  }

  void _getEtat() async {
    final db = await DatabaseHelper.instance.database;
    final etat = await db.query('etats', where: 'id = ?', whereArgs: [widget.materiel.idEtat]);
    _etat = etat[0]['nom'] as String;
    setState(() {});
  }

  void _getCategorie() async {
    final db = await DatabaseHelper.instance.database;
    final categorie = await db.query('categories', where: 'id = ?', whereArgs: [widget.materiel.idCategorie]);
    _categorie = categorie[0]['nom'] as String;
    setState(() {});
  }

  void _getCategories() async {
    final db = await DatabaseHelper.instance.database;
    _categories = await db.query('categories');
    setState(() {});
  }

  Future<void> _faireRetour() async {
    // Afficher une popup où entrer un commentaire pour le retour
    SupabaseService supabaseService = SupabaseService(Supabase.instance.client);
    String commentaire = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Retour du matériel'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Commentaire'),
            onChanged: (String value) {
              commentaire = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                // Mettre à jour l'état du matériel
                await DatabaseHelper.instance.updateMateriel(widget.materiel.copyWith(idEtat: 1,));
                await supabaseService.addRetour(widget.materiel.idAnnonce ?? -1, commentaire);
                // Mettre à jour l'état du matériel
                final updatedMateriel = widget.materiel.copyWith(
                  idAnnonce: null,
                );
                await DatabaseHelper.instance.updateMateriel(updatedMateriel);
                widget.onUpdate();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
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
            if (widget.materiel.idEtat == 1)
              TextField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
            if (widget.materiel.idEtat == 1)
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            if (widget.materiel.idEtat == 1)
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
            if (widget.materiel.idEtat == 1)
              const SizedBox(height: 20),
            if (widget.materiel.idEtat == 2 || widget.materiel.idEtat == 3)
              Text('Nom: ${widget.materiel.nom}'),
            if (widget.materiel.idEtat == 2 || widget.materiel.idEtat == 3)
              const SizedBox(height: 20),
            if (widget.materiel.idEtat == 2 || widget.materiel.idEtat == 3)
              Text('Description: ${widget.materiel.description}'),
            if (widget.materiel.idEtat == 2 || widget.materiel.idEtat == 3)
              const SizedBox(height: 20),
            if (widget.materiel.idEtat == 2 || widget.materiel.idEtat == 3)
              Text('Catégorie: $_categorie'),
            if (widget.materiel.idEtat == 2 || widget.materiel.idEtat == 3)
              const SizedBox(height: 20),
            Text('État: $_etat'),
            const SizedBox(height: 20),
            if (widget.materiel.idEtat == 1)
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
            if (widget.materiel.idEtat == 3)
              ElevatedButton(
                onPressed: () {
                  _faireRetour();
                },
                child: const Text('Faire/modifier retour'),
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
