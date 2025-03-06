import 'package:blockchain_university_voting_system/database/theme_shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemeMode();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Load saved theme mode when initializing
  Future<void> _loadThemeMode() async {
    _isDarkMode = await ThemeSharedPreferences.loadThemeMode();
    notifyListeners();
  }

  // Toggle theme and save preference
  void toggleTheme(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    await ThemeSharedPreferences.saveThemeMode(isDarkMode);
    notifyListeners();
  }

  // Method to directly set theme mode
  void setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      await ThemeSharedPreferences.saveThemeMode(value);
      notifyListeners();
    }
  }

  void savePreferences() {}
}
