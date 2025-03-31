import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class LightTheme {
  final primarySwatch = const Color.fromARGB(255, 147, 175, 202); // container color
  final secondaryColor = const Color.fromARGB(255, 188, 204, 220); // widget (button) color
  final tertiaryColor = const Color.fromARGB(255, 217, 234, 253); // const Color(0xFF9AA6B2); // page color
}

/*
0xFFF8FAFC
0xFFD9EAFD
0xFFBCCCDC
0xFF9AA6B2
*/

class DarkTheme {
  final primarySwatch = const Color(0xFF3D7BF0); // Vibrant blue for buttons
  final secondaryColor = const Color(0xFF1E2A3D); // Dark blue for app bar
  final tertiaryColor = const Color(0xFF121212); // Very dark background
}

ThemeData buildLightTheme() {
  final lightTheme = LightTheme();
  final FlutterLocalization localization = FlutterLocalization.instance;
  return ThemeData(
    primaryColor: lightTheme.primarySwatch,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: lightTheme.primarySwatch,
      onPrimary: Colors.black,
      inversePrimary: Colors.white,
      secondary: lightTheme.secondaryColor,
      tertiary: lightTheme.tertiaryColor,
    ),
    fontFamily: localization.fontFamily,
  );
}

ThemeData buildDarkTheme() {
  final darkTheme = DarkTheme();
  final FlutterLocalization localization = FlutterLocalization.instance;
  return ThemeData(
    primaryColor: darkTheme.primarySwatch,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: darkTheme.primarySwatch,
      onPrimary: Colors.white,
      inversePrimary: Colors.black,
      secondary: darkTheme.secondaryColor,
      tertiary: darkTheme.tertiaryColor,
    ),
    fontFamily: localization.fontFamily,
  );
}
