import 'package:flutter/material.dart';
import 'package:allo/api/bdapi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final annonces = await supabaseService.fetchAnnonces(); // Utilisez votre SupabaseService pour récupérer les annonces
    print(annonces);
    setState(() {
      _demandesWidgets = _buildDemandesWidgets(annonces); // Mettez à jour la liste des widgets de demandes
    });
  }

  List<Widget> _buildDemandesWidgets(List<Map<String, dynamic>> annonces) {
    return annonces.map((annonce) {
      return Card(
        child: ListTile(
          leading: const FlutterLogo(),
          title: Text(
            annonce['nom'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(annonce['description']),
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
          // Ajoutez ici votre logique pour créer une nouvelle demande
        },
        tooltip: 'Nouvelle demande',
        child: const Icon(Icons.add),
      ),
    );
  }
}
