import 'package:flutter/material.dart';
import 'package:allo/models/materiel.dart';
import 'package:allo/api/bdmateriel.dart';
import 'package:allo/UI/info_materiel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final user = Supabase.instance.client.auth.currentUser;
      var userUUID = '';
      if (user != null) {
        userUUID = user.id;
      }
      materielsFuture = DatabaseHelper.instance.getMaterielsDisponibles(userUUID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste de mes matériels'),
        automaticallyImplyLeading: false,
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
            MaterialPageRoute(
                builder: (context) => AjoutMaterielScreen(
                    onUpdate: updateMateriel
                )
            ),
          );
        },
        tooltip: 'Nouveau matériel',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AjoutMaterielScreen extends StatefulWidget {
  final Function() onUpdate;

  const AjoutMaterielScreen({Key? key, required this.onUpdate}) : super(key: key);

  @override
  AjoutMaterielScreenState createState() => AjoutMaterielScreenState();
}

class AjoutMaterielScreenState extends State<AjoutMaterielScreen> {
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedCategorie = 1; // Catégorie par défaut (autre)
  late String _userUUID; // UUID de l'utilisateur

  // Options de catégorie
  final Map<int, String> _categories = {1: 'Autre', 2: 'Catégorie 2', 3: 'Catégorie 3'};

  @override
  void initState() {
    super.initState();
    _getUserUUID(); // Appel de la fonction pour récupérer l'UUID de l'utilisateur
  }

  // Fonction pour récupérer l'UUID de l'utilisateur
  void _getUserUUID() async {
    // Récupérer l'utilisateur actuellement authentifié
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Récupérer l'UUID de l'utilisateur
      _userUUID = user.id;
    }
  }

  Future<void> _ajouterMateriel(BuildContext context) async {
    final nom = _nomController.text;
    final description = _descriptionController.text;
    final categorie = _selectedCategorie; // Utilisation de la catégorie sélectionnée
    final materiel = Materiel(
        await DatabaseHelper.instance.getMaxId() + 1,
        nom,
        description,
        _userUUID, // Utilisation de l'UUID de l'utilisateur
        categorie,
        1);
    await DatabaseHelper.instance.insertMateriel(materiel);
    // Utiliser Navigator.pop avec les données du nouveau matériel ajouté
    Navigator.pop(context, materiel);
    widget.onUpdate();
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
            DropdownButtonFormField<int>(
              value: _selectedCategorie,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedCategorie = newValue ?? 1;
                });
              },
              items: _categories.entries.map((MapEntry<int, String> categorie) {
                return DropdownMenuItem<int>(
                  value: categorie.key,
                  child: Text(categorie.value),
                );
              }).toList(),
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