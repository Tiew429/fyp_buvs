import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class LightTheme {
  final primarySwatch = const Color(0xFFD9EAFD); // container color
  final secondaryColor = const Color(0xFFBCCCDC); // widget (button) color
  final tertiaryColor = const Color(0xFF9AA6B2); // page color
}

/*
0xFFF8FAFC
0xFFD9EAFD
0xFFBCCCDC
0xFF9AA6B2
*/

class DarkTheme {
  final primarySwatch = const Color(0xFF1E201E);
  final secondaryColor = const Color(0xFF56584F);
  final tertiaryColor = const Color(0xFF697565);
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
