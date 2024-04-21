import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Par exemple, une méthode pour ajouter un nouvel utilisateur à la base de données :
  Future<void> addUser(Map<String, dynamic> userData) async {
    final response = await _supabaseClient.from('users').insert([userData]);
    if (response != null) {
      throw Exception('Failed to add user');
    }
  }

  // Une méthode pour récupérer toutes les annonces de la base de données :
  Future<List<Map<String, dynamic>>> fetchAnnonces(uuid) async {
    final response = await _supabaseClient.from('ANNONCE').select().eq('id_etat', 1).not('id_utilisateur', 'eq', uuid);
    return response;
  }

  // Une méthode pour récupérer les annonces de l'utilisateur connecté :
  Future<List<Map<String, dynamic>>> fetchMesAnnonces(uuid) async {
    final response = await _supabaseClient.from('ANNONCE').select().eq('id_utilisateur', uuid);
    return response;
  }

  // Une méthode pour ajouter une nouvelle annonce à la base de données :
  Future<void> addAnnonce(Map<String, dynamic> annonceData) async {
    if (annonceData['id'] == null || annonceData['id'] <= await fetchMaxId()) {
      annonceData['id'] = await fetchMaxId() + 1;
    }
    final response = await _supabaseClient.from('ANNONCE').insert([annonceData]);
    if (response != null) {
      throw Exception('Failed to add annonce}');
    }
  }

  // Une méthode pour récupérer les categories de la base de données :
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await _supabaseClient.from('CATEGORIE').select();
    return response;
  }

  // Une méthode pour récupérer les etats de la base de données :
  Future<List<Map<String, dynamic>>> fetchEtats() async {
    final response = await _supabaseClient.from('ETAT').select();
    return response;
  }

  // Une méthode pour récupérer l'id le plus haut de la table annonce :
  Future<int> fetchMaxId() async {
    final response = await _supabaseClient.from('ANNONCE').select('id').order('id', ascending: false).limit(1);
    return response[0]['id'];
  }

  // Une méthode pour supprimer une annonce de la base de données :
  Future<void> deleteAnnonce(int idAnn) async {
    final response = await _supabaseClient.from('ANNONCE').delete().eq('id', idAnn);
    if (response != null) {
      throw Exception('Failed to delete annonce: $idAnn');
    }
  }

  // Une méthode pour récupérer un categorie par son id :
  Future<String> fetchCategorieById(int idCat) async {
    final response = await _supabaseClient.from('CATEGORIE').select().eq('id', idCat);
    return response[0]["nom"];
  }

  // Une méthode pour récupérer un etat par son id :
  Future<String> fetchEtatById(int idEtat) async {
    final response = await _supabaseClient.from('ETAT').select().eq('id', idEtat);
    return response[0]["nom"];
  }

  // Une méthode pour mettre à jour l'état d'une annonce :
  Future<void> updateEtatAnnonce(int idAnn, int idEtat) async {
    final response = await _supabaseClient.from('ANNONCE').update({'id_etat': idEtat}).eq('id', idAnn);
    if (response != null) {
      throw Exception('Failed to update etat annonce: $idAnn, $idEtat');
    }
  }

  // Une méthode pour mettre à jour le materiel d'une annonce :
  Future<void> updateMaterielAnnonce(int idAnn, String? jsonMateriel) async {
    final response = await _supabaseClient.from('ANNONCE').update({'json_materiel_pret': jsonMateriel}).eq('id', idAnn);
    if (response != null) {
      throw Exception('Failed to update materiel annonce: $idAnn, $jsonMateriel');
    }
  }

  // Une méthode pour récupérer les materiels des annonces en cours de la base de données :
  Future<List<Map<String, dynamic>>> fetchMaterielsEnCours() async {
    final response = await _supabaseClient.from('ANNONCE').select("json_materiel_pret").not("json_materiel_pret", "is", "null").or('id_etat.eq.2,id_etat.eq.4');
    return response;
  }

  // Une méthode pour récupérer les materiels des annonces finies de la base de données :
  Future<List<Map<String, dynamic>>> fetchMaterielsFinis() async {
    final response = await _supabaseClient.from('ANNONCE').select("json_materiel_pret").eq("id_etat", 3).not("json_materiel_pret", "is", "null");
    return response;
  }

  // Une méthode pour ajouter un retour à une annonce :
  Future<void> addRetour(int idAnn, String commentaire) async {
    final response = await _supabaseClient.from('ANNONCE').update({'commentaire': commentaire}).eq('id', idAnn);
    if (response != null) {
      throw Exception('Failed to add retour: $idAnn, $commentaire');
    }
  }
}
