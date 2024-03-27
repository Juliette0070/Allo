import 'dart:convert';

import 'package:allo/main.dart';
import 'package:flutter/material.dart';

import '../models/annonce.dart';

class BDapi {
  Future<List<Annonce>> getAnnonces() async {
    final data = await supabase.from('Annonces').select('''
    id_ann, nom_ann, desc_ann, etat_ann, id_cat''');
    final todos = <Annonce>[];
    data.forEach((element) {
      todos.add(Annonce.fromJson(element));
    });
    return todos;
  }
}
