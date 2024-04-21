class Annonce {
  // idAnn, nomAnn, descAnn, etatAnn, idCat

  int _idAnn;
  String _nomAnn;
  String _descAnn;
  int _etatAnn;
  int _idCat;
  String _uuid;
  DateTime _dateAnn;
  int _dureeAnn; // en heures

  Annonce(this._idAnn, this._nomAnn, this._descAnn, this._etatAnn, this._idCat, this._uuid, this._dateAnn, this._dureeAnn);

  int get idAnn => _idAnn;

  String get nomAnn => _nomAnn;

  String get descAnn => _descAnn;

  int get etatAnn => _etatAnn;

  int get idCat => _idCat;

  String get uuid => _uuid;

  DateTime get dateAnn => _dateAnn;

  int get dureeAnn => _dureeAnn;

  void setEtatAnn(int etat) {
    _etatAnn = etat;
  }

  factory Annonce.fromJson(dynamic json) {
    int idAnn = json['id'] ?? 0;
    String nomAnn = json['nom'] ?? "";
    String descAnn = json['description'] ?? "";
    int etatAnn = json['id_etat'] ?? 0;
    int idCat = json['id_categorie'] ?? 0;
    String uuid = json['id_utilisateur'] ?? 0;
    String dateAnnString = json['date_debut'] ?? "";
    DateTime dateAnn;
    if (dateAnnString == "") {dateAnn = DateTime.now();}
    else {dateAnn = DateTime.parse(dateAnnString);}
    int dureeAnn = json['duree'] ?? 0;
    return Annonce(idAnn, nomAnn, descAnn, etatAnn, idCat, uuid, dateAnn, dureeAnn);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _idAnn,
      'nom': _nomAnn,
      'description': _descAnn,
      'id_etat': _etatAnn,
      'id_categorie': _idCat,
      'id_utilisateur': _uuid,
      'date_debut': _dateAnn.toIso8601String(),
      'duree': _dureeAnn
    };
  }
}
