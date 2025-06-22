import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum AppThemeMode {
  light,
  dark,

}

class ThemeService extends ChangeNotifier {
  AppThemeMode _currentThemeMode = AppThemeMode.light;
  static const String _themeKey =
      'app_theme_mode';

  ThemeService() {
    _loadThemeFromPreferences();
  }

  AppThemeMode get currentThemeMode => _currentThemeMode;

  Future<void> _loadThemeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < AppThemeMode.values.length) {
      _currentThemeMode = AppThemeMode.values[themeIndex];
    }

    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode themeMode) async {
    if (_currentThemeMode != themeMode) {
      _currentThemeMode = themeMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
      notifyListeners();
    }
  }
  ThemeData getAppTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepPurple,
          colorScheme:
              ColorScheme.fromSwatch(
                primarySwatch: Colors.deepPurple,
                accentColor: Colors.deepPurpleAccent,
                brightness: Brightness
                    .light,
              ).copyWith(
                secondary: Colors.deepOrangeAccent,
                error: Colors.redAccent,
              ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            // Const es válido aquí
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontSize: 16.0),
            bodyMedium: TextStyle(fontSize: 14.0),
          ),
        );
      case AppThemeMode.dark:
        return ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
          colorScheme:
              ColorScheme.fromSwatch(
                primarySwatch: Colors.indigo,
                accentColor:
                    Colors.tealAccent,
                brightness: Brightness
                    .dark,
              ).copyWith(
                secondary: Colors.tealAccent,
                error: Colors.redAccent,
                surface: Colors.grey[850],
              ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
          ),
          scaffoldBackgroundColor:
              Colors.grey[900],
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey[800],
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            fillColor: Colors.grey[700],
            filled: true,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            titleMedium: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
            bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
            bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
          ),
        );
      default:
        return getAppTheme(AppThemeMode.light); 
    }
  }
}
