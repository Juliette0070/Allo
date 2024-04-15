import 'package:flutter/material.dart';

class WidgetDemandes extends StatelessWidget {
  const WidgetDemandes({super.key});

  List<Widget> _getAllWidgetsDemandes() {
    List<Widget> listeDemandes = [];
    for (int i = 0; i < 15; i++) {
      Widget taskWidget = Card(
        child: ListTile(
          leading: const FlutterLogo(),
          title: Text(
            "Demande n°${(i + 1)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("Lorem ipsum"),
        ),
      );
      listeDemandes.add(taskWidget);
    }
    return listeDemandes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: _getAllWidgetsDemandes(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Nouvelle demande',
        child: const Icon(Icons.add),
      ),
    );
  }
}
