import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:allo/mytheme.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Center(
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
      ),
    );
  }
}