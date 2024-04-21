import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:allo/api/bdapi.dart';
import 'package:allo/api/bdmateriel.dart';
import 'package:allo/models/materiel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:allo/models/annonce.dart';
import 'dart:convert';

class AnnonceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> annonce;
  final Function onUpdate;

  const AnnonceDetailsPage({Key? key, required this.annonce, required this.onUpdate}) : super(key: key);

  @override
  State<AnnonceDetailsPage> createState() => _AnnonceDetailsPageState();
}

class _AnnonceDetailsPageState extends State<AnnonceDetailsPage> {
  final SupabaseService supabaseService = SupabaseService(Supabase.instance.client);
  String categorie = "";
  String etat = "";
  List<Materiel> materiels = [];
  Map<String, dynamic>? materielSelectionne;
  late List<Map<String, dynamic>> categories = [];
  Materiel? materiel;

  @override
  void initState() {
    super.initState();
    _loadCategorieFromAPI();
    _loadEtatFromAPI();
    _loadMateriels();
    _loadCategories();
    _getMateriel();
    DatabaseHelper.instance.refreshMaterielsDisponibilite();
  }

  Future<void> _loadMateriels() async {
    // récupérer les materiels de la bd sqflite
    materiels = await DatabaseHelper.instance.getMaterielsDisponibles(Supabase.instance.client.auth.currentUser!.id);
  }

  Future<void> _loadCategorieFromAPI() async {
    final categorieBD = await supabaseService.fetchCategorieById(widget.annonce['id_categorie'] as int);
    setState(() {
      categorie = categorieBD;
    });
  }

  Future<void> _loadEtatFromAPI() async {
    String etatBD;
    if (widget.annonce['id_etat'] == null || widget.annonce['id_etat'] == 0) {
      etatBD = "Non publié";
    } else {
      etatBD = await supabaseService.fetchEtatById(widget.annonce['id_etat'] as int);
    }
    setState(() {
      etat = etatBD;
    });
  }

  void _supprimerAnnonce(BuildContext context) async {
    final supabaseClient = Supabase.instance.client;
    final userUUID = Supabase.instance.client.auth.currentUser!.id;
    final annonceUserID = widget.annonce['id_utilisateur'] as String;

    if (userUUID == annonceUserID) {
      SupabaseService supabaseService = SupabaseService(supabaseClient);
      await supabaseService.deleteAnnonce(widget.annonce['id'] as int);
      widget.onUpdate();
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur de suppression'),
            content: const Text('Vous n\'êtes pas autorisé à supprimer cette annonce.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _enregistrerModifications(Annonce annonceModifiee) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> annoncesJsonList = prefs.getStringList('mes_annonces') ?? [];
    int index = annoncesJsonList.indexWhere((json) => Annonce.fromJson(jsonDecode(json)).idAnn == annonceModifiee.idAnn);
    if (index != -1) {
      annoncesJsonList.removeAt(index);
      annoncesJsonList.add(jsonEncode(annonceModifiee.toJson()));
      await prefs.setStringList('mes_annonces', annoncesJsonList);
      widget.onUpdate();
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur de modification'),
            content: const Text('Impossible de trouver l\'annonce à modifier.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loadCategories() async {
    // Charger les catégories depuis la base de données suapbase
    final categoriesBD = await supabaseService.fetchCategories();
    setState(() {
      categories = categoriesBD;
    });
  }

  Future<void> _getMateriel() async {
    // Récupérer le matériel associé à l'annonce (deja dans l'objet annonce si dans etat 4)
    if (widget.annonce['id_etat'] == 4) {
      final mat = widget.annonce['json_materiel_pret'] as String;
      materiel = Materiel.fromJson(jsonDecode(mat));
    }
  }

  Future<void> _confirmerPretMateriel() async {
    // Confirmer le prêt du matériel
    final supabaseClient = Supabase.instance.client;
    final userUUID = Supabase.instance.client.auth.currentUser!.id;
    final annonceUserID = widget.annonce['id_utilisateur'] as String;

    if (userUUID == annonceUserID) {
      widget.annonce['id_etat'] = 2;
      final supabaseService = SupabaseService(supabaseClient);
      await supabaseService.updateEtatAnnonce(widget.annonce['id'], 2);
      widget.onUpdate();
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur de confirmation'),
            content: const Text('Vous n\'êtes pas autorisé à confirmer le prêt de ce matériel.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _refuserPretMateriel() async {
    // Refuser le prêt du matériel
    final supabaseClient = Supabase.instance.client;
    final userUUID = Supabase.instance.client.auth.currentUser!.id;
    final annonceUserID = widget.annonce['id_utilisateur'] as String;

    if (userUUID == annonceUserID) {
      widget.annonce['id_etat'] = 1;
      final supabaseService = SupabaseService(supabaseClient);
      await supabaseService.updateEtatAnnonce(widget.annonce['id'], 1);
      // remettre json_materiel_pret à null
      widget.annonce['json_materiel_pret'] = null;
      await supabaseService.updateMaterielAnnonce(widget.annonce['id'], null);
      widget.onUpdate();
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur de refus'),
            content: const Text('Vous n\'êtes pas autorisé à refuser le prêt de ce matériel.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _mettreFinAnnonce() async {
    // Mettre fin à l'annonce
    final supabaseClient = Supabase.instance.client;
    final userUUID = Supabase.instance.client.auth.currentUser!.id;
    final annonceUserID = widget.annonce['id_utilisateur'] as String;

    if (userUUID == annonceUserID) {
      widget.annonce['id_etat'] = 3;
      final supabaseService = SupabaseService(supabaseClient);
      await supabaseService.updateEtatAnnonce(widget.annonce['id'], 3);
      widget.onUpdate();
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur de fin d\'annonce'),
            content: const Text('Vous n\'êtes pas autorisé à mettre fin à cette annonce.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _cloreAnnonce() async {
    // Mettre fin à l'annonce
    final supabaseClient = Supabase.instance.client;
    final userUUID = Supabase.instance.client.auth.currentUser!.id;
    final annonceUserID = widget.annonce['id_utilisateur'] as String;

    if (userUUID == annonceUserID) {
      widget.annonce['id_etat'] = 5;
      final supabaseService = SupabaseService(supabaseClient);
      await supabaseService.updateEtatAnnonce(widget.annonce['id'], 5);
      widget.onUpdate();
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur de cloture d\'annonce'),
            content: const Text('Vous n\'êtes pas autorisé à cloturer cette annonce.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _repondreAnnonce() async {
    // Répondre à l'annonce
    final supabaseClient = Supabase.instance.client;
    final userUUID = Supabase.instance.client.auth.currentUser!.id;
    final annonceUserID = widget.annonce['id_utilisateur'] as String;

    if (userUUID != annonceUserID) {
      widget.annonce['id_etat'] = 4;
      final supabaseService = SupabaseService(supabaseClient);
      await supabaseService.updateEtatAnnonce(widget.annonce['id'], 4);
      await supabaseService.updateMaterielAnnonce(widget.annonce['id'], Materiel.fromMap(materielSelectionne??{}).toString());
      // Mettre à jour l'état du matériel et l'id de l'annonce dans le matériel
      DatabaseHelper.instance.updateMateriel(Materiel.fromMap(materielSelectionne??{}).copyWith(idAnnonce: widget.annonce['id'], idEtat: 2));
      widget.onUpdate();
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Erreur de réponse'),
            content: const Text('Vous ne pouvez pas répondre à votre propre annonce.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userUUID = Supabase.instance.client.auth.currentUser!.id;
    final annonceUserID = widget.annonce['id_utilisateur'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'annonce'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.annonce['id_etat'] == 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champs de modification pour le nom de l'annonce
                  TextFormField(
                    initialValue: widget.annonce['nom'],
                    onChanged: (value) {
                      setState(() {
                        widget.annonce['nom'] = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  // Champs de modification pour la description de l'annonce
                  TextFormField(
                    initialValue: widget.annonce['description'],
                    onChanged: (value) {
                      setState(() {
                        widget.annonce['description'] = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  // Champs de modification pour la catégorie de l'annonce
                  DropdownButtonFormField<int>(
                    value: widget.annonce['id_categorie'],
                    onChanged: (int? value) {
                      setState(() {
                        widget.annonce['id_categorie'] = value!;
                      });
                    },
                    items: categories.map<DropdownMenuItem<int>>((Map<String, dynamic> category) {
                      return DropdownMenuItem<int>(
                        value: category['id'] as int,
                        child: Text(category['nom'] as String),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Catégorie'),
                  ),
                  // Champs de modification pour la date de début de l'annonce
                  TextFormField(
                    initialValue: widget.annonce['date_debut'] ?? 'non renseignée',
                    onChanged: (value) {
                      setState(() {
                        widget.annonce['date_debut'] = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Date de début'),
                  ),
                  // Champs de modification pour la durée de l'annonce
                  TextFormField(
                    initialValue: widget.annonce['duree'] != null ? widget.annonce['duree'].toString() : '0',
                    onChanged: (value) {
                      setState(() {
                        widget.annonce['duree'] = int.parse(value);
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Durée (en heures)'),
                  ),
                  const SizedBox(height: 16),
                  // Afficher l'état de l'annonce sans possibilité de le modifier
                  Text(
                    'État: $etat',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Appeler une fonction pour enregistrer les modifications
                      _enregistrerModifications(Annonce.fromJson(widget.annonce));
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nom: ${widget.annonce['nom']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Description: \n${widget.annonce['description']}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Catégorie: $categorie',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date de début: ${widget.annonce['date_debut'] ??
                        'non renseignée'}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Durée: ${widget.annonce['duree'] != null ? widget.annonce['duree'].toString() : '0'}h',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'État: $etat',
                  ),
                  const SizedBox(height: 16),
                  if (widget.annonce['id_etat'] == 4)
                    Text(
                      'Matériel: $materiel',
                    ),
                ],
              ),
            if (widget.annonce['id_etat'] == 4 && userUUID == annonceUserID)
              ElevatedButton(
                onPressed: () {
                  _confirmerPretMateriel();
                },
                child: const Text('Confirmer le prêt'),
              ),
            if (widget.annonce['id_etat'] == 4 && userUUID == annonceUserID)
              ElevatedButton(
                onPressed: () {
                  _refuserPretMateriel();
                },
                child: const Text('Refuser le prêt'),
              ),
            if (userUUID == annonceUserID && widget.annonce['id_etat'] == 2)
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmer la fin du prêt'),
                        content: const Text('Êtes-vous sûr de vouloir mettre fin à ce prêt ?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Fermer la boîte de dialogue
                            },
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _mettreFinAnnonce(); // Appeler la fonction de fin d'annonce
                              Navigator.of(context).pop(); // Fermer la boîte de dialogue
                            },
                            child: const Text('Mettre fin au prêt'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Mettre fin au prêt'),
              ),
            if (userUUID == annonceUserID && widget.annonce['id_etat'] == 3)
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmer la cloture de l\'annonce'),
                        content: const Text('Êtes-vous sûr de vouloir cloturer cette annonce ?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Fermer la boîte de dialogue
                            },
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _cloreAnnonce(); // Appeler la fonction de cloture
                              Navigator.of(context).pop(); // Fermer la boîte de dialogue
                            },
                            child: const Text('Clore l\'annonce'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Clore l\'annonce'),
              ),
            if (userUUID == annonceUserID && (widget.annonce['id_etat'] == 1 || widget.annonce['id_etat'] == 4))
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirmer la suppression'),
                        content: const Text('Êtes-vous sûr de vouloir supprimer cette annonce ?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Fermer la boîte de dialogue
                            },
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _supprimerAnnonce(context); // Appeler la fonction de suppression
                              Navigator.of(context).pop(); // Fermer la boîte de dialogue
                            },
                            child: const Text('Supprimer'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Supprimer l\'annonce'),
              ),
            if (userUUID != annonceUserID && widget.annonce['id_etat'] == 1)
              ElevatedButton(
                onPressed: () {
                  // Afficher la liste des matériels et permettre à l'utilisateur de sélectionner un matériel
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Sélectionner un matériel'),
                        content: DropdownButton<Map<String, dynamic>>(
                          value: materielSelectionne,
                          items: materiels.map((Materiel mat) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: mat.toMap(),
                              child: Text(mat.nom),
                            );
                          }).toList(),
                          onChanged: (Map<String, dynamic>? newValue) {
                            setState(() {
                              materielSelectionne = newValue!;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Fermer la boîte de dialogue
                            },
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Mettre à jour l'état de l'annonce à "Attente confirmation"
                              setState(() {
                                _repondreAnnonce();
                              });
                              Navigator.of(context).pop(); // Fermer la boîte de dialogue
                            },
                            child: const Text('Confirmer'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Répondre à l\'annonce'),
              ),
          ],
        ),
      ),
    );
  }
}
