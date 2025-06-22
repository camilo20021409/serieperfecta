import 'package:flutter/material.dart';

const Color _customPrimaryColor = Color(0xFF6200EE);
const Color _customSecondaryColor = Color(0xFF03DAC6);
const Color _customTertiaryColor = Color(0xFF018786);
const Color _customErrorColor = Color(0xFFB00020);
const Color _customSurfaceColor = Color(0xFFFFFFFF);
const Color _customBackgroundColor = Color(0xFFFFFFFF);
const Color _customOnPrimaryColor = Color(0xFFFFFFFF);
const Color _customOnSecondaryColor = Color(0xFF000000);
const Color _customOnTertiaryColor = Color(0xFFFFFFFF);
const Color _customOnErrorColor = Color(0xFFFFFFFF);
const Color _customOnSurfaceColor = Color(0xFF000000);
const Color _customOnBackgroundColor = Color(0xFF000000);

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0});

  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        primary: _customPrimaryColor,
        secondary: _customSecondaryColor,
        tertiary: _customTertiaryColor,
        surface: _customSurfaceColor,
        background: _customBackgroundColor,
        error: _customErrorColor,
        onPrimary: _customOnPrimaryColor,
        onSecondary: _customOnSecondaryColor,
        onTertiary: _customOnTertiaryColor,
        onSurface: _customOnSurfaceColor,
        onBackground: _customOnBackgroundColor,
        onError: _customOnErrorColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _customPrimaryColor,
        foregroundColor: _customOnPrimaryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _customPrimaryColor,
          foregroundColor: _customOnPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _customPrimaryColor,
          side: const BorderSide(color: _customPrimaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _customPrimaryColor.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _customPrimaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _customPrimaryColor, width: 2),
        ),
        hintStyle: TextStyle(color: _customOnSurfaceColor.withOpacity(0.6)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _customPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: _customPrimaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: _customPrimaryColor,
        ),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
      ),
    );
  }
}
