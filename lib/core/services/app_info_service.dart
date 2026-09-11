import 'package:package_info_plus/package_info_plus.dart';

/// Sumber tunggal informasi versi aplikasi.
///
/// Nilai diambil dari versi build yang di-generate Flutter dari `version:` pada
/// pubspec.yaml (di Windows berasal dari resource versi `eposwa.exe`).
class AppInfoService {
  AppInfoService._();

  static const String _fallback = '1.0.0+1';

  static String _version = '';

  /// Versi aplikasi dalam format `1.0.0+1`.
  static String get version => _version.isEmpty ? _fallback : _version;

  /// Dipanggil sekali saat startup; gagal load tetap memakai [_fallback].
  static Future<void> load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final raw = info.version;
      // Sebagian platform sudah menyertakan build number di `version`.
      _version = raw.isEmpty || raw.contains('+') || info.buildNumber.isEmpty
          ? raw
          : '$raw+${info.buildNumber}';
    } catch (_) {
      _version = '';
    }
  }
}
