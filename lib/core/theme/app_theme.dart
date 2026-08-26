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
        displayLarge: TextStyle(fontFamily: _fontFamily),
        displayMedium: TextStyle(fontFamily: _fontFamily),
        displaySmall: TextStyle(fontFamily: _fontFamily),
        headlineLarge: TextStyle(fontFamily: _fontFamily),
        headlineMedium: TextStyle(fontFamily: _fontFamily),
        headlineSmall: TextStyle(fontFamily: _fontFamily),
        titleLarge: TextStyle(fontFamily: _fontFamily),
        titleMedium: TextStyle(fontFamily: _fontFamily),
        titleSmall: TextStyle(fontFamily: _fontFamily),
        bodyLarge: TextStyle(fontFamily: _fontFamily),
        bodyMedium: TextStyle(fontFamily: _fontFamily),
        bodySmall: TextStyle(fontFamily: _fontFamily),
        labelLarge: TextStyle(fontFamily: _fontFamily),
        labelMedium: TextStyle(fontFamily: _fontFamily),
        labelSmall: TextStyle(fontFamily: _fontFamily),
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
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          textStyle: TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
