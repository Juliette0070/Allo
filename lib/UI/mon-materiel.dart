import 'package:flutter/material.dart';

class WidgetMateriel extends StatelessWidget {
  const WidgetMateriel({super.key});

  List<Widget> _getAllWidgetsMateriels() {
    List<Widget> listeMateriels = [];
    for (int i = 0; i < 15; i++) {
      Widget taskWidget = Card(
        child: ListTile(
          leading: const FlutterLogo(),
          title: Text(
            "Matériel n°${(i + 1)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text("Lorem ipsum"),
        ),
      );
      listeMateriels.add(taskWidget);
    }
    return listeMateriels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: _getAllWidgetsMateriels(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Nouveau matériel',
        child: const Icon(Icons.add),
      ),
    );
  }
}
