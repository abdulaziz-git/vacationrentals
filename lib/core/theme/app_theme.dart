import 'package:flutter/material.dart';

/// Coastal LBI palette + Material 3 theme. Ocean teal primary, sandy surfaces,
/// sunset-coral accent for primary CTAs (mirrors the "Epic Sunset" branding).
class AppTheme {
  AppTheme._();

  static const Color ocean = Color(0xFF0B6E99);
  static const Color deepSea = Color(0xFF0A3D62);
  static const Color sunset = Color(0xFFE8743B);
  static const Color sand = Color(0xFFF6F1E7);
  static const Color seafoam = Color(0xFF06A77D);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ocean,
      primary: ocean,
      secondary: sunset,
      tertiary: seafoam,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFBFAF7),
      fontFamily: 'SF Pro',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: deepSea,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: deepSea),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: sunset,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ocean,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: ocean, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ocean, width: 1.6),
        ),
      ),
    );
  }
}

/// Currency / spec formatting helpers shared across the UI.
class Format {
  static String money(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '\$$b';
  }

  static String weeklyRange(int from, int? to) =>
      to == null || to == from ? '${money(from)}/wk' : '${money(from)}–${money(to)}/wk';
}
