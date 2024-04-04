import 'package:allo/api/bdapi.dart';
import 'package:allo/models/annonce.dart';
import 'package:flutter/material.dart';

class WidgetDemandes extends StatelessWidget {
  List<Widget> _getAllWidgetsDemandes() {
    late Future<List<Annonce>> annonces = BDapi.getAnnonces();
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
    // return FutureBuilder(
    //     future: BDapi.getAnnonces(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         return ListView.builder(
    //             itemCount: snapshot.data?.length,
    //             itemBuilder: (context, index) {
    //               return Card(
    //                 elevation: 6,
    //                 margin: const EdgeInsets.all(10),
    //                 child: ListTile(
    //                   leading: CircleAvatar(
    //                     backgroundColor: Colors.lightBlue,
    //                     child:
    //                         Text(snapshot.data?[index].idAnn.toString() ?? '0'),
    //                   ),
    //                   title: Text(snapshot.data?[index].nomAnn ?? ""),
    //                   trailing: Text(snapshot.data?[index].descAnn ?? ""),
    //                 ),
    //               );
    //             });
    //       } else if (snapshot.hasError) {
    //         return Text('${snapshot.error}');
    //       } else {
    //         return const Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       }
    //     });
  }
}
