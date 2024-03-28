import 'package:allo/mytheme.dart';
import 'package:allo/UI/demandes_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:allo/UI/mon-materiel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// void main() {
//   runApp(const MyApp());
// }

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

class SettingViewModel extends ChangeNotifier{
  late bool _isDark;
  late SettingRepository _settingRepository;
  bool get isDark => _isDark;
  SettingViewModel() {
    _isDark = false;
    _settingRepository = SettingRepository();
    getSettings();
  }
  //Switching the themes
  set isDark(bool value) {
    _isDark = value;
    _settingRepository.saveSettings(value);
    notifyListeners();
  }
  getSettings() async {
    _isDark = await _settingRepository.getSettings();
    notifyListeners();
  }
}

class SettingRepository{
  static const THEME_KEY = "darkMode";

  saveSettings(bool value) async {
    SharedPreferences sharedPreferences = await
    SharedPreferences.getInstance();
    sharedPreferences.setBool(THEME_KEY, value);
  }

  Future<bool> getSettings() async {
    SharedPreferences sharedPreferences = await
    SharedPreferences.getInstance();
    return sharedPreferences.getBool(THEME_KEY) ?? false;
  }
}

class WidgetSettings extends StatefulWidget{
  const WidgetSettings({super.key});
  @override
  State<WidgetSettings> createState() => _EcranSettingsState();
}

class _EcranSettingsState extends State<WidgetSettings>{
  @override
  Widget build(BuildContext context){
    return Center(
      child: SettingsList(
        darkTheme: SettingsThemeData(
            settingsListBackground: MyTheme.dark().scaffoldBackgroundColor,
            settingsSectionBackground: MyTheme.dark().scaffoldBackgroundColor
        ),
        lightTheme: SettingsThemeData(
            settingsListBackground: MyTheme.light().scaffoldBackgroundColor,
            settingsSectionBackground: MyTheme.light().scaffoldBackgroundColor
        ),
        sections: [
          SettingsSection(
              title: const Text('Theme'),
              tiles: [
                SettingsTile.switchTile(
                  initialValue: context.watch<SettingViewModel>().isDark,
                  onToggle: (bool value) {context.read<SettingViewModel>().isDark=value;},
                  title: const Text('Dark mode'),
                  leading: const Icon(Icons.invert_colors),)
              ])
        ],
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
    WidgetMateriel(),
    WidgetSettings()
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
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.diversity_3),
            label: "Demandes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Mon matériel",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Paramètres"
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
