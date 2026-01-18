import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color timberBrown = Color(0xFFC77A3A);
  static const Color safetyOrange = Color(0xFFE9B949);
  static const Color bgDark = Color(0xFF12100E);
  static const Color surfaceDark = Color(0xFF1B1916);
  static const Color bgLight = Color(0xFFF7F2EC);
  static const Color surfaceLight = Color(0xFFFEFBF7);
  static const Color steelBlue = Color(0xFF2D3A3F);

  static TextTheme _buildTextTheme(TextTheme base, {required bool isDark}) {
    final body = GoogleFonts.ibmPlexSansTextTheme(base);
    final heading = GoogleFonts.robotoSlabTextTheme(base).copyWith(
      displayLarge:
          GoogleFonts.robotoSlab(fontWeight: FontWeight.w600, fontSize: 48),
      displayMedium:
          GoogleFonts.robotoSlab(fontWeight: FontWeight.w600, fontSize: 40),
      displaySmall:
          GoogleFonts.robotoSlab(fontWeight: FontWeight.w600, fontSize: 32),
      headlineLarge:
          GoogleFonts.robotoSlab(fontWeight: FontWeight.w600, fontSize: 28),
      headlineMedium:
          GoogleFonts.robotoSlab(fontWeight: FontWeight.w600, fontSize: 24),
      headlineSmall:
          GoogleFonts.robotoSlab(fontWeight: FontWeight.w600, fontSize: 20),
      titleLarge:
          GoogleFonts.robotoSlab(fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium:
          GoogleFonts.robotoSlab(fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall:
          GoogleFonts.robotoSlab(fontWeight: FontWeight.w600, fontSize: 14),
    );
    final themed = body.copyWith(
      displayLarge: heading.displayLarge,
      displayMedium: heading.displayMedium,
      displaySmall: heading.displaySmall,
      headlineLarge: heading.headlineLarge,
      headlineMedium: heading.headlineMedium,
      headlineSmall: heading.headlineSmall,
      titleLarge: heading.titleLarge,
      titleMedium: heading.titleMedium,
      titleSmall: heading.titleSmall,
    );
    return themed.apply(
      bodyColor: isDark ? Colors.white : Colors.black87,
      displayColor: isDark ? Colors.white : Colors.black87,
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: timberBrown,
        primary: timberBrown,
        secondary: safetyOrange,
        surface: surfaceDark,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: _buildTextTheme(base.textTheme, isDark: true),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF221F1B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2621)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: safetyOrange),
        ),
        hintStyle: const TextStyle(color: Color(0xFFA39A92)),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: surfaceDark,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: timberBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: steelBlue,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF221E1A).withOpacity(0.96),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3A332C)),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          height: 1.3,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        waitDuration: const Duration(milliseconds: 200),
        showDuration: const Duration(seconds: 6),
        preferBelow: true,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: timberBrown,
        primary: timberBrown,
        secondary: safetyOrange,
        surface: surfaceLight,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      textTheme: _buildTextTheme(base.textTheme, isDark: false),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3EEE6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8D0C4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: safetyOrange),
        ),
        hintStyle: const TextStyle(color: Color(0xFF7B6F64)),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: surfaceLight,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: timberBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: steelBlue,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFFF2EAE1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD9CBB9)),
        ),
        textStyle: const TextStyle(
          color: Color(0xFF3B2D21),
          fontSize: 12.5,
          height: 1.3,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        waitDuration: const Duration(milliseconds: 200),
        showDuration: const Duration(seconds: 6),
        preferBelow: true,
      ),
    );
  }
}
