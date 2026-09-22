import 'package:flutter/material.dart';

abstract final class BrandColors {
  static const forest = Color(0xFF123D2E);
  static const burgundy = Color(0xFF681E32);
  static const gold = Color(0xFFC69B45);
  static const warmWhite = Color(0xFFFFFBF3);
  static const ink = Color(0xFF201B18);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: BrandColors.forest,
    primary: BrandColors.forest,
    secondary: BrandColors.burgundy,
    tertiary: BrandColors.gold,
    surface: BrandColors.warmWhite,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: BrandColors.warmWhite,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: BrandColors.ink,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
