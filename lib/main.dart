import 'package:allo/mytheme.dart';
import 'package:allo/UI/demandes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:allo/UI/mon_materiel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:allo/UI/parametres.dart';
import 'package:allo/UI/mes_prets.dart';
import 'package:allo/UI/reservations.dart';
import 'package:allo/UI/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:
        'https://wjaarazmugtqnolxixuc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqYWFyYXptdWd0cW5vbHhpeHVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTI1NDI2ODIsImV4cCI6MjAyODExODY4Mn0.SCGG3uQfzyEBW8b1UmyUH3VHcLu3hIzUV3l-QRyKfyU',
  );

  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'All O',
      home: Login(),
    );
  }
}

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

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = [
    const WidgetDemandes(),
    const WidgetReservations(),
    const WidgetMateriel(),
    const WidgetPrets(),
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
