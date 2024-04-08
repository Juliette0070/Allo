import 'package:flutter/material.dart';
import 'package:allo/models/materiel.dart';
import 'package:allo/api/bdmateriel.dart';
import 'package:allo/UI/info_materiel.dart';

class WidgetMateriel extends StatefulWidget {
  const WidgetMateriel({Key? key}) : super(key: key);

  @override
  WidgetMaterielState createState() => WidgetMaterielState();
}

class WidgetMaterielState extends State<WidgetMateriel> {
  late Future<List<Materiel>> materielsFuture;

  @override
  void initState() {
    super.initState();
    updateMateriel();
  }

  void updateMateriel() {
    setState(() {
      materielsFuture = DatabaseHelper.instance.getMaterielsDisponibles(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des matériels'),
      ),
      body: FutureBuilder<List<Materiel>>(
        future: materielsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            final materiels = snapshot.data ?? [];
            if (materiels.isEmpty) {
              return const Center(child: Text('Aucun matériel actuellement disponible'));
            }
            return ListView.builder(
              itemCount: materiels.length,
              itemBuilder: (context, index) {
                final materiel = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaterielDetailsPage(
                            materiel: materiel,
                            onUpdate: updateMateriel
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      leading: const FlutterLogo(),
                      title: Text(
                        materiel.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(materiel.description),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjoutMaterielScreen()),
          );
        },
        tooltip: 'Nouveau matériel',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AjoutMaterielScreen extends StatefulWidget {
  const AjoutMaterielScreen({Key? key}) : super(key: key);

  @override
  AjoutMaterielScreenState createState() => AjoutMaterielScreenState();
}

class AjoutMaterielScreenState extends State<AjoutMaterielScreen> {
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categorieController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _categorieController.dispose();
    super.dispose();
  }

  Future<void> _ajouterMateriel(BuildContext context) async {
    final nom = _nomController.text;
    final description = _descriptionController.text;
    final categorie = _categorieController.text;
    final materiel = Materiel(await DatabaseHelper.instance.getMaxId() + 1, nom, description, true, categorie);
    await DatabaseHelper.instance.insertMateriel(materiel);
    // Utiliser Navigator.pop avec les données du nouveau matériel ajouté
    Navigator.pop(context, materiel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un matériel'),
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
            ElevatedButton(
              onPressed: () => _ajouterMateriel(context),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}