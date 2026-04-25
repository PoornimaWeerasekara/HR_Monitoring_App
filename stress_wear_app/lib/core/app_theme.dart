import 'package:flutter/material.dart';

/// Centralised theme tokens for the Stress Wear app.
class AppTheme {
  AppTheme._();

  // ── Colours ───────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF7C4DFF); // deep purple
  static const Color secondary    = Color(0xFF03DAC6); // teal accent
  static const Color stressRed    = Color(0xFFEF5350);
  static const Color calmGreen    = Color(0xFF66BB6A);
  static const Color surfaceDark  = Color(0xFF1E1E2E);
  static const Color cardDark     = Color(0xFF2A2A3D);

  // ── Text styles ───────────────────────────────────────────────────────────
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: Colors.white70,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    color: Colors.white54,
    letterSpacing: 1.2,
  );

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 4,
      ),
    );
  }
}
