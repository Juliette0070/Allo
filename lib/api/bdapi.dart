import 'package:supabase_flutter/supabase_flutter.dart';

//class BDapi {
//  Future<List<Annonce>> getAnnonces() async {
//    final data = await supabase.from('Annonces').select('''
//    id_ann, nom_ann, desc_ann, etat_ann, id_cat''');
//    final todos = <Annonce>[];
//    data.forEach((element) {
//      todos.add(Annonce.fromJson(element));
//    });
//    return todos;
//  }
//}


class SupabaseService {
  final SupabaseClient _supabaseClient;

  SupabaseService(this._supabaseClient);

  Future<List<Map<String, dynamic>>> fetchUserData() async {
    final response = await _supabaseClient.from('users').select();
    if (response.isEmpty) {
      throw Exception('Failed to fetch user data');
    }
    return response;
  }

  // Ajoutez d'autres méthodes ici pour effectuer des opérations sur la base de données Supabase, telles que l'insertion, la mise à jour ou la suppression des données.

  // Par exemple, une méthode pour ajouter un nouvel utilisateur à la base de données :
  Future<void> addUser(Map<String, dynamic> userData) async {
    final response = await _supabaseClient.from('users').insert([userData]);
    if (response.error != null) {
      throw Exception('Failed to add user: ${response.error!.message}');
    }
  }

  // Une méthode pour récupérer toutes les annonces de la base de données :
  Future<List<Map<String, dynamic>>> fetchAnnonces() async {
    final response = await _supabaseClient.from('ANNONCE').select();
    if (response.isEmpty) {
      throw Exception('Failed to fetch annonces (or no data available)');
    }
    return response;
  }
}
