import 'package:flutter/material.dart';

class WidgetDemandes extends StatelessWidget {
  List<Widget> _getAllWidgetsDemandes() {
    // List<Task> tasks = Task.generateTask(7);
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
    return ListView(
      padding: const EdgeInsets.all(8),
      children: _getAllWidgetsDemandes(),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return Text("Demandes");
//   }
// }
