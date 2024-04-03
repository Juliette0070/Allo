import 'dart:convert';

import 'package:allo/main.dart';
import 'package:flutter/material.dart';

import '../models/annonce.dart';

class BDapi {
  static Future<List<Annonce>> getAnnonces() async {
    final data = await supabase.from('Annonces').select('''*''');
    final todos = <Annonce>[];
    data.forEach((element) {
      todos.add(Annonce.fromJson(element));
    });
    return todos;
  }
}
