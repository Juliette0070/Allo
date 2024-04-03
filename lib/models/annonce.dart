class Annonce {
  int _idAnn;
  String _nomAnn;
  String _descAnn;
  Enum _etatAnn;
  int _idCat;

  Annonce(this._idAnn, this._nomAnn, this._descAnn, this._etatAnn, this._idCat);

  int get idAnn => _idAnn;

  String get nomAnn => _nomAnn;

  String get descAnn => _descAnn;

  Enum get etatAnn => _etatAnn;

  int get idCat => _idCat;

  factory Annonce.fromJson(dynamic json) {
    int idAnn = json['idAnn'] ?? 0;
    String nomAnn = json['nomAnn'] ?? "";
    String descAnn = json['descAnn'] ?? "";
    Enum etatAnn = json['etatAnn'] ?? "";
    int idCat = json['idCat'] ?? 0;
    return Annonce(idAnn, nomAnn, descAnn, etatAnn, idCat);
  }
}
