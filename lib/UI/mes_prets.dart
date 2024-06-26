import 'package:flutter/material.dart';
import 'package:allo/models/materiel.dart';
import 'package:allo/api/bdmateriel.dart';
import 'package:allo/UI/info_materiel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WidgetPrets extends StatefulWidget {
  const WidgetPrets({Key? key}) : super(key: key);

  @override
  WidgetPretsState createState() => WidgetPretsState();
}

class WidgetPretsState extends State<WidgetPrets> {
  late Future<List<Materiel>> materielsFuture;

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.refreshMaterielsDisponibilite();
    updateMateriel();
  }

  void updateMateriel() {
    setState(() {
      final user = Supabase.instance.client.auth.currentUser;
      var userUUID = '';
      if (user != null) {
        userUUID = user.id;
      }
      materielsFuture = DatabaseHelper.instance.getMaterielsNonDisponibles(userUUID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste de mes prêts'),
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
              return const Center(child: Text('Aucun matériel en cours de prêt'));
            }
            return ListView.builder(
              itemCount: materiels.length,
              itemBuilder: (context, index) {
                final materiel = snapshot.data![index];
                var logo = const Icon(Icons.help, color: Colors.yellow);
                if (materiel.idEtat == 1) {logo = const Icon(Icons.check_circle, color: Colors.green);}
                else if (materiel.idEtat == 2) {logo = const Icon(Icons.cancel, color: Colors.red);}
                else if (materiel.idEtat == 3) {logo = const Icon(Icons.pending, color: Colors.orange);}
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
                      leading: logo,
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
    );
  }
}