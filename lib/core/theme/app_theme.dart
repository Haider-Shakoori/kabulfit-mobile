import 'package:flutter/material.dart';

/// Luxury Afghan fashion identity, based on the approved KabulFit showcase.
/// Keep every screen light; product photography is the hero of the experience.
abstract final class BrandColors {
  static const burgundy = Color(0xFF74263D);
  static const deepBurgundy = Color(0xFF4B1528);
  static const gold = Color(0xFFC39B62);
  static const champagne = Color(0xFFF0E1CD);
  static const warmWhite = Color(0xFFFFFCF8);
  static const cream = Color(0xFFF7F1EA);
  static const ink = Color(0xFF292126);
  static const mutedInk = Color(0xFF786B6E);
  static const forest = Color(0xFF123D2E); // Kept for compatibility.
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: BrandColors.burgundy,
    brightness: Brightness.light,
    primary: BrandColors.burgundy,
    onPrimary: Colors.white,
    secondary: BrandColors.gold,
    tertiary: BrandColors.deepBurgundy,
    surface: BrandColors.warmWhite,
    onSurface: BrandColors.ink,
  );
  const rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: BrandColors.warmWhite,
    canvasColor: BrandColors.warmWhite,
    dividerColor: BrandColors.champagne,
    splashColor: BrandColors.champagne.withValues(alpha: .3),
    appBarTheme: const AppBarTheme(
      backgroundColor: BrandColors.warmWhite,
      foregroundColor: BrandColors.deepBurgundy,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 21,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
        color: BrandColors.deepBurgundy,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      shadowColor: Color(0x173D1529),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: rounded,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: BrandColors.deepBurgundy,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.w700,
        color: BrandColors.deepBurgundy,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        color: BrandColors.deepBurgundy,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: BrandColors.ink,
      ),
      bodyMedium: TextStyle(color: BrandColors.ink, height: 1.45),
      bodySmall: TextStyle(color: BrandColors.mutedInk),
      labelLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: .3),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BrandColors.cream,
      prefixIconColor: BrandColors.burgundy,
      hintStyle: const TextStyle(color: BrandColors.mutedInk),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: BrandColors.burgundy, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: BrandColors.burgundy,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: BrandColors.burgundy,
        side: const BorderSide(color: BrandColors.champagne),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: BrandColors.champagne,
      elevation: 8,
      height: 74,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: BrandColors.deepBurgundy,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: BrandColors.cream,
      selectedColor: BrandColors.burgundy,
      labelStyle: const TextStyle(color: BrandColors.ink),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      side: BorderSide.none,
      shape: const StadiumBorder(),
    ),
  );
}

[executed on device: businessos-dev-vps (9b1cdbf1-1a02-4fe8-9e81-8871c3eca22c)]