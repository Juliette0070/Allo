class Materiel {
  int _id;
  String _nom;
  String _description;
  bool _disponible;
  String _categorie;

  Materiel(this._id, this._nom, this._description, this._disponible, this._categorie);

  int get id => _id;
  String get nom => _nom;
  String get description => _description;
  bool get disponible => _disponible;
  String get categorie => _categorie;

  factory Materiel.fromJson(dynamic json) {
    int id = json['id'] ?? 0;
    String nom = json['nom'] ?? "";
    String description = json['description'] ?? "";
    bool disponible = json['disponible'] ?? true;
    String categorie = json['categorie'] ?? "";
    return Materiel(id, nom, description, disponible, categorie);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'disponible': disponible ? 1 : 0,
      'categorie': categorie,
    };
  }

  factory Materiel.fromMap(Map<String, dynamic> map) {
    return Materiel(
      map['id'],
      map['nom'],
      map['description'],
      map['disponible'] == 1,
      map['categorie'],
    );
  }

  // Méthode pour récupérer tous les matériels disponibles
  static List<Materiel> getMateriels(List<Materiel> materiels, bool disponible) {
    List<Materiel> materielsDisponibles = [];
    for (var materiel in materiels) {
      if (materiel.disponible == disponible) {
        materielsDisponibles.add(materiel);
      }
    }
    return materielsDisponibles;
  }

  Materiel copyWith({
    int? id,
    String? nom,
    String? description,
    bool? disponible,
    String? categorie,
  }) {
    return Materiel(
      id ?? this.id,
      nom ?? this.nom,
      description ?? this.description,
      disponible ?? this.disponible,
      categorie ?? this.categorie,
    );
  }

  @override
  String toString() {
    return 'Materiel{id: $_id, nom: $_nom, description: $_description, disponible: $_disponible, categorie: $_categorie}';
  }
}
