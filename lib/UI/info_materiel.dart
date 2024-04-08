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
  late TextEditingController _categorieController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.materiel.nom);
    _descriptionController = TextEditingController(text: widget.materiel.description);
    _categorieController = TextEditingController(text: widget.materiel.categorie);
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
            TextField(
              controller: _categorieController,
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            const SizedBox(height: 20),
            Text(
              'Disponible : ${widget.materiel.disponible ? 'Oui' : 'Non'}',
              style: const TextStyle(fontSize: 16),
            ),
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
      categorie: _categorieController.text,
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
    _categorieController.dispose();
    super.dispose();
  }
}

