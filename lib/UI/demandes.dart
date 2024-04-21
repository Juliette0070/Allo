import 'package:flutter/material.dart';
import 'package:allo/api/bdapi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:allo/models/annonce.dart';
import 'package:allo/UI/info_annonce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class WidgetDemandes extends StatefulWidget {
  const WidgetDemandes({Key? key}) : super(key: key);

  @override
  WidgetDemandesState createState() => WidgetDemandesState();
}

class WidgetDemandesState extends State<WidgetDemandes> {
  final SupabaseService supabaseService = SupabaseService(Supabase.instance.client); // Créez une instance de votre SupabaseService

  late List<Widget> _demandesWidgets = [];

  @override
  void initState() {
    super.initState();
    _loadDemandesFromAPI();
  }

  Future<void> _loadDemandesFromAPI() async {
    String uuid = Supabase.instance.client.auth.currentUser!.id;
    final annonces = await supabaseService.fetchAnnonces(uuid); // Utilisez votre SupabaseService pour récupérer les annonces
    setState(() {
      _demandesWidgets = _buildDemandesWidgets(annonces); // Mettez à jour la liste des widgets de demandes
    });
  }

  List<Widget> _buildDemandesWidgets(List<Map<String, dynamic>> annonces) {
    return annonces.map((annonce) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.help, color: Colors.blue),
          title: Text(
            annonce['nom'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(annonce['description']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnnonceDetailsPage(annonce: annonce, onUpdate: _loadDemandesFromAPI,),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: _demandesWidgets, // Utilisez la liste des widgets de demandes chargée depuis l'API
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NouvelleAnnonceScreen()),
          );
        },
        tooltip: 'Nouvelle annonce',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NouvelleAnnonceScreen extends StatefulWidget {
  const NouvelleAnnonceScreen({Key? key}) : super(key: key);

  @override
  NouvelleAnnonceScreenState createState() => NouvelleAnnonceScreenState();
}

class NouvelleAnnonceScreenState extends State<NouvelleAnnonceScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dureeController = TextEditingController();
  late List<Map<String, dynamic>> _categories = [];
  int _selectedCategorie = 1;
  final SupabaseService supabaseService = SupabaseService(Supabase.instance.client);
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _chargerCategoriesEtEtats();
    _selectedDate = DateTime.now();
  }

  Future<void> _chargerCategoriesEtEtats() async {
    _categories = await supabaseService.fetchCategories();
    setState(() {});
  }

  void _creerAnnonce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nom = _nomController.text;
    String description = _descriptionController.text;
    int categorie = _selectedCategorie;
    int duree = int.parse(_dureeController.text);
    String uuid = Supabase.instance.client.auth.currentUser!.id;
    int maxId = 0;
    List<String> annoncesJsonList = prefs.getStringList('mes_annonces') ?? [];
    for (String json in annoncesJsonList) {
      Annonce annonce = Annonce.fromJson(jsonDecode(json));
      if (annonce.idAnn > maxId) {
        maxId = annonce.idAnn;
      }
    }
    Annonce annonce = Annonce(
      maxId + 1,
      nom,
      description,
      0,
      categorie,
      uuid,
      _selectedDate,
      duree,
    );

    // Convertir l'annonce en JSON
    String annonceJson = jsonEncode(annonce.toJson());

    // Sauvegarder le JSON dans SharedPreferences
    List<String> annoncesJsonList2 = prefs.getStringList('mes_annonces') ?? [];
    annoncesJsonList2.add(annonceJson);
    prefs.setStringList('mes_annonces', annoncesJsonList2);

    Navigator.pop(context, annonce);
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Annonce'),
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
                  _selectedCategorie = newValue!;
                });
              },
              items: _categories.map((categorie) {
                return DropdownMenuItem<int>(
                  value: categorie['id'] as int,
                  child: Text(categorie['nom'] as String),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Date de début: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            TextField(
              controller: _dureeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Durée (heures)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _creerAnnonce,
              child: const Text('Créer Annonce'),
            ),
          ],
        ),
      ),
    );
  }
}
