import 'package:flutter/material.dart';
// Ta bort google_fonts här om du vill – den behövs inte i offline-läget
// import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color electricBlue = Color(0xFF00A3FF);
  static const Color safetyOrange = Color(0xFFFF7A00);
  static const Color bgDark = Color(0xFF0E1113);
  static const Color surfaceDark = Color(0xFF151A1E);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: electricBlue,
        primary: electricBlue,
        secondary: safetyOrange,
        background: bgDark,
        surface: surfaceDark,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // Använd plattformens standardtexttema (SF Pro på macOS/iOS)
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C2228),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A3138)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: electricBlue),
        ),
        hintStyle: const TextStyle(color: Color(0xFF8A96A3)),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF24303A),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
