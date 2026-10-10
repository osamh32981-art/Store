import 'package:flutter/material.dart';

class StoreTheme {
  static const ink = Color(0xFF17202A);
  static const orange = Color(0xFFFF6B35);
  static const blue = Color(0xFF2264DC);
  static ThemeData light = ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: orange), scaffoldBackgroundColor: const Color(0xFFF8F8FA), appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0), cardTheme: CardThemeData(elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(22)))));
  static ThemeData dark = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: orange, brightness: Brightness.dark), scaffoldBackgroundColor: const Color(0xFF121417), appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0));
}
