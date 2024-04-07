import 'package:allo/mytheme.dart';
import 'package:allo/UI/demandes_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:allo/UI/mon-materiel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:allo/UI/parametres.dart';

Future<void> main() async {
  await Supabase.initialize(
    url:
        'postgres://postgres.bxbonhvpfxrehmqygibc:Z0rxjJe!&eoyO8wn74uX2e@aws-0-eu-west-2.pooler.supabase.com:5432/postgres',
    anonKey: 'Z0rxjJe!&eoyO8wn74uX2e',
  );

  runApp(const MyApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
          create: (_) {
            SettingViewModel settingViewModel = SettingViewModel();
            return settingViewModel;
        },
      child: Consumer<SettingViewModel>(
        builder: (context,SettingViewModel notifier,child){
          return MaterialApp(
            title: "All'o",
            theme: notifier.isDark ? MyTheme.dark():MyTheme.light(),
            home: const MyHomePage(title: "All'o"),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _WidgetMateriel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text("Mon matériel");
  }
}

class _WidgetSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text("Paramètres");
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = [
    WidgetDemandes(),
    _WidgetSettings(),
    const WidgetMateriel(),
    _WidgetMateriel(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WidgetSettings()),
              );
            },
          )],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.diversity_3),
            label: "Demandes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diversity_3),
            label: "Réservations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Mon matériel",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Mes prêts",
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
