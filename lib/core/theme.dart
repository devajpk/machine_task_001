import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens — single source of truth for every color, radius and spacing
// used across the app. Swap these to rebrand in one place.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF9D97FF);
  static const secondary = Color(0xFFFF6584);
  static const secondaryDark = Color(0xFFFF8FA3);

  // Surface — light
  static const surfaceLight = Color(0xFFFFFFFF);
  static const backgroundLight = Color(0xFFF6F7FB);
  static const cardLight = Color(0xFFFFFFFF);

  // Surface — dark
  static const surfaceDark = Color(0xFF1E1E2C);
  static const backgroundDark = Color(0xFF13131F);
  static const cardDark = Color(0xFF252535);

  // Text — light
  static const textPrimaryLight = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF6B6B8A);

  // Text — dark
  static const textPrimaryDark = Color(0xFFEEEEFF);
  static const textSecondaryDark = Color(0xFF9898B8);

  // Semantic
  static const success = Color(0xFF4CAF82);
  static const error = Color(0xFFE05151);
  static const warning = Color(0xFFFFC107);

  // Neutral
  static const divider = Color(0x1A000000);
  static const dividerDark = Color(0x1AFFFFFF);
}

abstract final class AppRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const full = 999.0;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme factory
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      onPrimary: Colors.white,
      secondary: isDark ? AppColors.secondaryDark : AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onSurface:
          isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      surfaceContainerHighest:
          isDark ? AppColors.cardDark : AppColors.cardLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      fontFamily: 'SF Pro Display',
      // ── AppBar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      // ── Card ────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      // ── Chip ────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: (isDark ? AppColors.primaryDark : AppColors.primary)
            .withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: isDark ? AppColors.primaryDark : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      // ── ElevatedButton ──────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      // ── Input ───────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            (isDark ? AppColors.cardDark : AppColors.cardLight).withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
      ),
      // ── Divider ─────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.divider,
        space: 1,
        thickness: 1,
      ),
      // ── Text ────────────────────────────────────────────────────────────────
      textTheme: _textTheme(isDark),
    );
  }

  static TextTheme _textTheme(bool isDark) {
    final base =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final muted =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return TextTheme(
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: base,
          letterSpacing: -1),
      displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: base,
          letterSpacing: -0.5),
      headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: base,
          letterSpacing: -0.4),
      headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: base,
          letterSpacing: -0.3),
      headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: base,
          letterSpacing: -0.2),
      titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: base,
          letterSpacing: -0.1),
      titleMedium: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: base),
      titleSmall: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: muted),
      bodyLarge:
          TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: base),
      bodyMedium:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: base),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: muted),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: base,
          letterSpacing: 0.2),
    );
  }
}