import 'package:shared_preferences/shared_preferences.dart';

class ThemeSharedPreferences {
  static const String _themeKey = 'theme_mode';

  // Save theme mode to shared preferences
  static Future<void> saveThemeMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // Load theme mode from shared preferences
  static Future<bool> loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Default to light mode
  }
} 
