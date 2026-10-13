import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised light and dark ThemeData definitions.
/// Both themes share the same typography and shape system,
/// but swap surface / background / text colours.
class AppTheme {
  AppTheme._();

  // ── Brand Colours ──
  static const Color primaryBlue = Color(0xFF0F3A68);
  static const Color primaryBlueLight = Color(0xFF1E5090);
  static const Color accentBlue = Color(0xFF3B82F6);

  // ── Light Palette ──
  static const Color _lightBackground = Color(0xFFF8F9FA);
  static const Color _lightSurface = Colors.white;
  static const Color _lightCard = Colors.white;
  static const Color _lightScaffold = Color(0xFFEDEEEF);
  static const Color _lightTextPrimary = Color(0xFF1A1A1A);
  static const Color _lightTextSecondary = Color(0xFF4B5563);
  static const Color _lightTextHint = Color(0xFF9CA3AF);
  static const Color _lightDivider = Color(0xFFE5E7EB);

  // ── Dark Palette ──
  static const Color _darkBackground = Color(0xFF0F1419);
  static const Color _darkSurface = Color(0xFF1A2332);
  static const Color _darkCard = Color(0xFF1E293B);
  static const Color _darkScaffold = Color(0xFF0F1419);
  static const Color _darkTextPrimary = Color(0xFFF1F5F9);
  static const Color _darkTextSecondary = Color(0xFF94A3B8);
  static const Color _darkTextHint = Color(0xFF64748B);
  static const Color _darkDivider = Color(0xFF334155);

  // ─────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: _lightScaffold,
      canvasColor: _lightBackground,
      cardColor: _lightCard,
      dividerColor: _lightDivider,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: _lightSurface,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightTextPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: _lightTextPrimary),
          bodyMedium: TextStyle(color: _lightTextPrimary),
          bodySmall: TextStyle(color: _lightTextSecondary),
          titleLarge: TextStyle(color: _lightTextPrimary),
          titleMedium: TextStyle(color: _lightTextPrimary),
          titleSmall: TextStyle(color: _lightTextSecondary),
          labelLarge: TextStyle(color: _lightTextPrimary),
          labelMedium: TextStyle(color: _lightTextSecondary),
          labelSmall: TextStyle(color: _lightTextHint),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _lightTextHint),
        errorStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle:
              GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _lightTextPrimary),
        contentTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _lightTextSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedLabelStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryBlue;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryBlue.withValues(alpha: 0.4);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  // ─────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: primaryBlueLight,
      scaffoldBackgroundColor: _darkScaffold,
      canvasColor: _darkBackground,
      cardColor: _darkCard,
      dividerColor: _darkDivider,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlueLight,
        secondary: accentBlue,
        surface: _darkSurface,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkTextPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: _darkTextPrimary),
          bodyMedium: TextStyle(color: _darkTextPrimary),
          bodySmall: TextStyle(color: _darkTextSecondary),
          titleLarge: TextStyle(color: _darkTextPrimary),
          titleMedium: TextStyle(color: _darkTextPrimary),
          titleSmall: TextStyle(color: _darkTextSecondary),
          labelLarge: TextStyle(color: _darkTextPrimary),
          labelMedium: TextStyle(color: _darkTextSecondary),
          labelSmall: TextStyle(color: _darkTextHint),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _darkTextHint),
        errorStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle:
              GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _darkTextPrimary),
        contentTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _darkTextSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedLabelStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentBlue;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentBlue.withValues(alpha: 0.4);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: _darkCard,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          color: _darkTextPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _darkSurface,
      ),
    );
  }
}
