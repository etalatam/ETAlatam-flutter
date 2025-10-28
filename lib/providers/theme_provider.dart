import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  static const String THEME_KEY = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    loadThemeFromPrefs();
  }
  
  Future<void> loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(THEME_KEY) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeToPrefs();
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveThemeToPrefs();
    notifyListeners();
  }
  
  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _saveThemeToPrefs();
    notifyListeners();
  }
  
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(THEME_KEY, _themeMode == ThemeMode.dark);
  }
  
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color.fromARGB(255, 59, 140, 135),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color.fromARGB(255, 59, 140, 135),
        secondary: Color.fromARGB(255, 59, 140, 135),
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xff1e3050),
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1e3050),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff1e3050)),
        titleTextStyle: TextStyle(
          color: const Color(0xff1e3050),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 59, 140, 135),
          foregroundColor: Colors.white,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color.fromARGB(255, 59, 140, 135);
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color.fromARGB(255, 59, 140, 135).withOpacity(0.5);
          }
          return Colors.grey.shade300;
        }),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: const Color(0xff1e3050),
          fontSize: 36,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        headlineMedium: TextStyle(
          color: const Color(0xff1e3050),
          fontSize: 28,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        headlineSmall: TextStyle(
          color: const Color(0xff1e3050),
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        titleLarge: TextStyle(
          color: const Color(0xff1e3050),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        titleMedium: TextStyle(
          color: const Color(0xff1e3050),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        bodyLarge: TextStyle(
          color: const Color(0xff1e3050),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: GoogleFonts.elMessiri().fontFamily,
        ),
        bodyMedium: TextStyle(
          color: const Color(0xff1e3050),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: GoogleFonts.elMessiri().fontFamily,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color.fromARGB(255, 205, 214, 231),
      ),
      iconTheme: const IconThemeData(
        color: Color.fromARGB(255, 48, 75, 122),
      ),
    );
  }
  
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color.fromARGB(255, 59, 140, 135),
      scaffoldBackgroundColor: const Color(0xff1e3050),
      colorScheme: const ColorScheme.dark(
        primary: Color.fromARGB(255, 59, 140, 135),
        secondary: Color.fromARGB(255, 59, 140, 135),
        surface: Color(0xff1e3050),
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xff1e3050),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 59, 140, 135),
          foregroundColor: Colors.white,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color.fromARGB(255, 59, 140, 135);
          }
          return Colors.blueGrey.shade500;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color.fromARGB(255, 59, 140, 135).withOpacity(0.5);
          }
          return Colors.grey.shade600;
        }),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: GoogleFonts.elMessiri().fontFamily,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: GoogleFonts.elMessiri().fontFamily,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color.fromARGB(255, 13, 23, 40),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }
}