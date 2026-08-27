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
  static const Color primarySoft = Color(0xFFEFF6FF);
  static const Color sectionLight = Color(0xFFF8FAFC);
  static const Color sectionCardBg = Color(0xFFF1F5F9);
  static const Color footerDark = Color(0xFF1E293B);
  static const Color footerDarker = Color(0xFF0F172A);
  static const Color heroButton = Color(0xFF0E7C7B);
  static const Color heroButtonHover = Color(0xFF0B6665);

  /// Border & Divider
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);

  /// Status & Badges
  static const Color badgeBgSuccess = Color(0xFFECFDF5);
  static const Color badgeTextSuccess = Color(0xFF059669);
  static const Color badgeBgInfo = Color(0xFFEFF6FF);
  static const Color badgeTextInfo = Color(0xFF2563EB);
  static const Color badgeBgWarning = Color(0xFFFFFBEB);
  static const Color badgeTextWarning = Color(0xFFD97706);

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

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [
      Color(0xEE0B192C),
      Color(0xCC0F2744),
      Color(0x881E3E62),
      Colors.transparent,
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF0E7C7B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
