import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

/// Theme terpusat ePOSWA.
/// Semua warna primary diambil dari [AppColors.primary] agar konsisten.
/// Font primary: Inter (assets/fonts/Inter-*.ttf)
class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Inter';

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: _fontFamily, fontSize: 52, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.15),
        displayMedium: TextStyle(fontFamily: _fontFamily, fontSize: 44, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.2),
        displaySmall: TextStyle(fontFamily: _fontFamily, fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.25),
        headlineLarge: TextStyle(fontFamily: _fontFamily, fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3),
        headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.3),
        headlineSmall: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.35),
        titleLarge: TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.4),
        titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.4),
        titleSmall: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.4),
        bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textMuted, height: 1.6),
        bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textMuted, height: 1.5),
        bodySmall: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted, height: 1.5),
        labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        labelMedium: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        labelSmall: TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
