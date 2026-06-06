import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// VRLBI brand palette (mirrors the live vrlbi.com site: brand blue + sun
/// yellow) wrapped in a rounded, card-first Material 3 theme — pill buttons,
/// soft cards, playful accents. Provides both [light] and [dark] variants
/// driven by a shared [_build] so component styling stays consistent.
class AppTheme {
  AppTheme._();

  /// Primary brand blue (links, icons, primary CTAs). VRLBI `#0081ff`.
  static const Color ocean = Color(0xFF0081FF);

  /// Deep navy for headings / app-bar text. VRLBI `#073855`.
  static const Color deepSea = Color(0xFF073855);

  /// Sun-yellow accent (badges, highlights, active chips). VRLBI `#FFDC00`.
  static const Color sunset = Color(0xFFFFC400);

  /// True brand yellow for fine accents on dark/colored surfaces only.
  static const Color sun = Color(0xFFFFDC00);

  /// Accessible gold for rating stars on light surfaces (≈3:1 contrast vs the
  /// brand yellow's 1.36:1, satisfying WCAG 1.4.11 for graphical objects).
  static const Color star = Color(0xFFB8860B);

  /// Sky-blue secondary (browse tiles, soft accents). VRLBI `#5dacd6`.
  static const Color seafoam = Color(0xFF2EA6E0);

  /// Warm-neutral surface (kept cool for the new scheme).
  static const Color sand = Color(0xFFEAF2FB);

  /// Favorite / love accent. VRLBI `#f5463b`.
  static const Color heart = Color(0xFFF5463B);

  /// Pale blue tint used for icon chips and category tiles.
  static const Color tint = Color(0xFFEAF3FF);

  /// App scaffold background — a barely-there cool grey-blue (light only).
  static const Color canvas = Color(0xFFF4F7FB);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: ocean,
      primary: ocean,
      secondary: sunset,
      tertiary: seafoam,
      brightness: brightness,
    );

    // Surfaces resolve from the scheme in dark mode and from the brand
    // light palette in light mode (preserves the established look).
    final cardColor = isDark ? scheme.surfaceContainerHigh : Colors.white;
    final fieldColor = isDark ? scheme.surfaceContainerHighest : Colors.white;
    final headingColor = isDark ? scheme.onSurface : deepSea;
    final borderColor = isDark ? scheme.outlineVariant : Colors.grey.shade300;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? scheme.surface : canvas,
      fontFamily: 'SF Pro',
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        // Dark glyphs on light app bars, light glyphs on dark ones.
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: headingColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: headingColor),
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
        backgroundColor: cardColor,
        selectedColor: isDark ? scheme.primaryContainer : tint,
        checkmarkColor: ocean,
        side: BorderSide(color: borderColor),
        // Explicit labels for BOTH states so chip text is never invisible.
        labelStyle: TextStyle(color: headingColor, fontWeight: FontWeight.w600),
        secondaryLabelStyle: TextStyle(
          color: headingColor,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shadowColor: ocean.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: borderColor),
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
  Format._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 0,
  );

  /// Locale-aware currency, e.g. `$7,250` (handles grouping + negatives).
  static String money(int v) => _currency.format(v);

  static String weeklyRange(int from, int? to) => to == null || to == from
      ? '${money(from)}/wk'
      : '${money(from)}–${money(to)}/wk';
}
