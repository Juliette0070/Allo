class Materiel {
  int _id;
  String _nom;
  String _description;
  bool _disponible;

  Materiel(this._id, this._nom, this._description, this._disponible);

  int get id => _id;
  String get nom => _nom;
  String get description => _description;
  bool get disponible => _disponible;

  factory Materiel.fromJson(dynamic json) {
    int id = json['id'] ?? 0;
    String nom = json['nom'] ?? "";
    String description = json['description'] ?? "";
    bool disponible = json['disponible'] ?? true;
    return Materiel(id, nom, description, disponible);
  }
}
