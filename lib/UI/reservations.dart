import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:allo/models/annonce.dart';
import 'package:allo/api/bdapi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:allo/UI/info_annonce.dart';

class WidgetReservations extends StatefulWidget {
  const WidgetReservations({Key? key}) : super(key: key);

  @override
  WidgetReservationsState createState() => WidgetReservationsState();
}

class WidgetReservationsState extends State<WidgetReservations> {
  List<Annonce> mesAnnonces = [];
  List<Annonce> toutesMesAnnonces = [];

  @override
  void initState() {
    super.initState();
    _chargerMesAnnonces();
    _chargerToutesMesAnnonces();
  }

  Future<void> _chargerMesAnnonces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> annoncesJsonList = prefs.getStringList('mes_annonces') ?? [];
    // ne garder que les annonces dont l'utilisateur est le propriétaire
    String uuid = Supabase.instance.client.auth.currentUser!.id;
    annoncesJsonList.retainWhere((json) => Annonce.fromJson(jsonDecode(json)).uuid == uuid);
    setState(() {
      mesAnnonces = annoncesJsonList.map((json) => Annonce.fromJson(jsonDecode(json))).toList();
    });
  }

  Future<void> _chargerToutesMesAnnonces() async {
    String uuid = Supabase.instance.client.auth.currentUser!.id;
    final SupabaseService supabaseService = SupabaseService(Supabase.instance.client);
    List<Map<String, dynamic>> annoncesJson = await supabaseService.fetchMesAnnonces(uuid);
    setState(() {
      toutesMesAnnonces = annoncesJson.map((json) => Annonce.fromJson(json)).toList();
    });
  }

  Future<void> _publierAnnonce(Annonce annonce) async {
    annonce.setEtatAnn(1);
    SupabaseService supabaseService = SupabaseService(Supabase.instance.client);
    await supabaseService.addAnnonce(annonce.toJson());
    _supprimerAnnonce(annonce);
    _chargerToutesMesAnnonces();
  }

  Future<void> _supprimerAnnonce(Annonce annonce) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> annoncesJsonList = prefs.getStringList('mes_annonces') ?? [];
    annoncesJsonList.removeWhere((json) => Annonce.fromJson(jsonDecode(json)).idAnn == annonce.idAnn);
    await prefs.setStringList('mes_annonces', annoncesJsonList);
    _chargerMesAnnonces();
    _chargerToutesMesAnnonces();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Mes Annonces'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Non publiées'),
              Tab(text: 'En ligne'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMesAnnoncesTab(),
            _buildToutesMesAnnoncesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMesAnnoncesTab() {
    return ListView.builder(
      itemCount: mesAnnonces.length,
      itemBuilder: (context, index) {
        final annonce = mesAnnonces[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(annonce.nomAnn),
            subtitle: Text(annonce.descAnn),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnnonceDetailsPage(annonce: annonce.toJson(), onUpdate: () {
                          setState(() {
                            _chargerMesAnnonces();
                          });
                        },
                      ),
                    ));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Supprimer l'annonce de la liste et de SharedPreferences
                    setState(() {
                      mesAnnonces.removeAt(index);
                      _supprimerAnnonce(annonce);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () {
                    // Supprimer l'annonce de la liste et de SharedPreferences
                    setState(() {
                      mesAnnonces.removeAt(index);
                      _publierAnnonce(annonce);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToutesMesAnnoncesTab() {
    return ListView.builder(
      itemCount: toutesMesAnnonces.length,
      itemBuilder: (context, index) {
        final annonce = toutesMesAnnonces[index];
        Icon? icon;
        switch (annonce.etatAnn) {
          case 0:
            icon = const Icon(Icons.not_interested, color: Colors.yellow,); // Remplacez par l'icône appropriée
            break;
          case 1:
            icon = const Icon(Icons.check_circle, color: Colors.green,); // Remplacez par l'icône appropriée
            break;
          case 2:
            icon = const Icon(Icons.pending, color: Colors.blue,); // Remplacez par l'icône appropriée
            break;
          case 3:
            icon = const Icon(Icons.message, color: Colors.orange,); // Remplacez par l'icône appropriée
            break;
          case 4:
            icon = const Icon(Icons.add_task, color: Colors.orange,); // Remplacez par l'icône appropriée
            break;
          case 5:
            icon = const Icon(Icons.inventory_2, color: Colors.blueGrey,); // Remplacez par l'icône appropriée
            break;
          default:
            icon = const Icon(Icons.error, color: Colors.red,); // Remplacez par l'icône appropriée
        }
        return Card(
          child: ListTile(
            leading: icon,
            title: Text(annonce.nomAnn),
            subtitle: Text(annonce.descAnn),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnnonceDetailsPage(annonce: annonce.toJson(), onUpdate: () {
                    setState(() {
                      _chargerToutesMesAnnonces();
                    });
                  },
                ),
              ));
            },
          ),
        );
      },
    );
  }
}
