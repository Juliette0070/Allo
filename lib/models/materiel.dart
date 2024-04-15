class Materiel {
  int _id;
  String _nom;
  String _description;
  String _uuidUtilisateur;
  int _idCategorie;
  int _idEtat;

  Materiel(this._id, this._nom, this._description, this._uuidUtilisateur, this._idCategorie, this._idEtat);

  int get id => _id;
  String get nom => _nom;
  String get description => _description;
  String get uuidUtilisateur => _uuidUtilisateur;
  int get idCategorie => _idCategorie;
  int get idEtat => _idEtat;

  factory Materiel.fromJson(dynamic json) {
    int id = json['id'] ?? 0;
    String nom = json['nom'] ?? "";
    String description = json['description'] ?? "";
    String uuidUtilisateur = json['id_utilisateur'] ?? 0;
    int idCategorie = json['id_categorie'] ?? 0;
    int idEtat = json['id_etat'] ?? 0;
    return Materiel(id, nom, description, uuidUtilisateur, idCategorie, idEtat);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'uuid_utilisateur': uuidUtilisateur,
      'id_categorie': idCategorie,
      'id_etat': idEtat,
    };
  }

  factory Materiel.fromMap(Map<String, dynamic> map) {
    return Materiel(
      map['id'],
      map['nom'],
      map['description'],
      map['uuid_utilisateur'],
      map['id_categorie'],
      map['id_etat'],
    );
  }

  // Méthode pour récupérer tous les matériels en fonction de leur état
  static List<Materiel> getMateriels(List<Materiel> materiels, int idEtat) {
    List<Materiel> materielsDisponibles = [];
    for (var materiel in materiels) {
      if (materiel.idEtat == idEtat) {
        materielsDisponibles.add(materiel);
      }
    }
    return materielsDisponibles;
  }

  Materiel copyWith({
    int? id,
    String? nom,
    String? description,
    String? uuidUtilisateur,
    int? idCategorie,
    int? idEtat,
  }) {
    return Materiel(
      id ?? this.id,
      nom ?? this.nom,
      description ?? this.description,
      uuidUtilisateur ?? this.uuidUtilisateur,
      idCategorie ?? this.idCategorie,
      idEtat ?? this.idEtat,
    );
  }

  @override
  String toString() {
    return 'Materiel{id: $_id, nom: $_nom, description: $_description, id_utilisateur: $_uuidUtilisateur, id_categorie: $_idCategorie, id_etat: $_idEtat}';
  }
}
