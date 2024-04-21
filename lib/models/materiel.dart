class Materiel {
  int _id;
  String _nom;
  String _description;
  String _uuidUtilisateur;
  int _idCategorie;
  int _idEtat;
  int? _idAnnonce;

  Materiel(this._id, this._nom, this._description, this._uuidUtilisateur, this._idCategorie, this._idEtat, this._idAnnonce);

  int get id => _id;
  String get nom => _nom;
  String get description => _description;
  String get uuidUtilisateur => _uuidUtilisateur;
  int get idCategorie => _idCategorie;
  int get idEtat => _idEtat;
  int? get idAnnonce => _idAnnonce;

  void setIdEtat(int idEtat) {
    _idEtat = idEtat;
  }

  void setIdAnnonce(int idAnnonce) {
    _idAnnonce = idAnnonce;
  }

  factory Materiel.fromJson(Map<String, dynamic> json) {
    int id = json['id'];
    String nom = json['nom'] ?? "";
    String description = json['description'] ?? "";
    String uuidUtilisateur = json['id_utilisateur'] ?? "";
    int idCategorie = json['id_categorie'];
    int idEtat = json['id_etat'];
    int? idAnnonce = json['id_annonce'];
    return Materiel(id, nom, description, uuidUtilisateur, idCategorie, idEtat, idAnnonce);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'uuid_utilisateur': uuidUtilisateur,
      'id_categorie': idCategorie,
      'id_etat': idEtat,
      'id_annonce': idAnnonce,
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
      map['id_annonce'],
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
    int? idAnnonce,
  }) {
    return Materiel(
      id ?? this.id,
      nom ?? this.nom,
      description ?? this.description,
      uuidUtilisateur ?? this.uuidUtilisateur,
      idCategorie ?? this.idCategorie,
      idEtat ?? this.idEtat,
      idAnnonce ?? this.idAnnonce,
    );
  }

  @override
  String toString() {
    return '{"id": $_id, "nom": "$_nom", "description": "$_description", "id_utilisateur": "$_uuidUtilisateur", "id_categorie": $_idCategorie, "id_etat": $_idEtat, "id_annonce": $_idAnnonce}';
  }
}
