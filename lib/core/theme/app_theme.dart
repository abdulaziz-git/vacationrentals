import 'package:flutter/material.dart';

/// VRLBI brand palette (mirrors the live vrlbi.com site: brand blue + sun
/// yellow) wrapped in a rounded, card-first Material 3 theme inspired by the
/// "Rent House" reference layout — pill buttons, soft cards, playful accents.
///
/// Constant names are kept stable (ocean / deepSea / sunset / seafoam / sand)
/// so existing widgets re-skin automatically; only their VALUES + roles moved
/// to the blue/yellow scheme.
class AppTheme {
  AppTheme._();

  /// Primary brand blue (links, icons, primary CTAs). VRLBI `#0081ff`.
  static const Color ocean = Color(0xFF0081FF);

  /// Deep navy for headings / app-bar text. VRLBI `#073855`.
  static const Color deepSea = Color(0xFF073855);

  /// Sun-yellow accent (badges, highlights, active chips). VRLBI `#FFDC00`.
  static const Color sunset = Color(0xFFFFC400);

  /// True brand yellow for rating stars / fine accents.
  static const Color sun = Color(0xFFFFDC00);

  /// Sky-blue secondary (browse tiles, soft accents). VRLBI `#5dacd6`.
  static const Color seafoam = Color(0xFF2EA6E0);

  /// Warm-neutral surface (kept cool for the new scheme).
  static const Color sand = Color(0xFFEAF2FB);

  /// Favorite / love accent. VRLBI `#f5463b`.
  static const Color heart = Color(0xFFF5463B);

  /// Pale blue tint used for icon chips and category tiles.
  static const Color tint = Color(0xFFEAF3FF);

  /// App scaffold background — a barely-there cool grey-blue.
  static const Color canvas = Color(0xFFF4F7FB);

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
      scaffoldBackgroundColor: canvas,
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
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: deepSea),
      ),
      // Pill-shaped primary CTAs in brand blue (reference "Rental Now" style).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ocean,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ocean,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: ocean, width: 1.4),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ocean,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.white,
        selectedColor: tint,
        checkmarkColor: ocean,
        side: BorderSide(color: Colors.grey.shade300),
        // Explicit dark labels for BOTH states so text is never invisible
        // (unselected on white, selected on the light-blue tint).
        labelStyle: const TextStyle(
          color: deepSea,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: deepSea,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shadowColor: ocean.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
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

  static String weeklyRange(int from, int? to) => to == null || to == from
      ? '${money(from)}/wk'
      : '${money(from)}–${money(to)}/wk';
}
