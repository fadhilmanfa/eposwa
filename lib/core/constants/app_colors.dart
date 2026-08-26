import 'package:flutter/material.dart';

/// Centralized color palette untuk ePOSWA.
/// Semua warna primary diambil dari sini agar konsisten & mudah diubah.
///
/// Cara pakai: `AppColors.primary`, `AppColors.primaryLight`, dll.
class AppColors {
  AppColors._();

  /// Warna biru utama ePOSWA - default #1565C0
  static const Color primary = Color(0xFF1565C0);

  /// Varian lebih terang untuk gradient jumbotron
  static const Color primaryLight = Color(0xFF1E88E5);

  /// Varian lebih gelap untuk gradient / pressed state
  static const Color primaryDark = Color(0xFF0D47A1);

  /// Warna sekunder (aksen)
  static const Color secondary = Color(0xFF03A9F4);

  /// Background scaffold
  static const Color background = Color(0xFFF5F7FB);

  /// Surface / card background
  static const Color surface = Colors.white;

  /// Text colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Colors.white;
  static const Color textMuted = Color(0xFF6B7280);

  /// Warna pastel untuk replikasi layout website (gambar)
  static const Color primaryPastel = Color(0xFFE3F2FD);
  static const Color sectionLight = Color(0xFFEAF6FF);
  static const Color footerDark = Color(0xFF263238);
  static const Color heroButton = Color(0xFF0E7C7B);

  /// Gradient untuk jumbotron/header
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
