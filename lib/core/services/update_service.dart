import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:eposwa/core/services/app_info_service.dart';

/// Kegagalan saat memeriksa atau mengunduh pembaruan; [message] siap ditampilkan.
class UpdateException implements Exception {
  const UpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Unduhan dibatalkan pengguna — bukan kegagalan, jadi tidak perlu pesan error.
class UpdateCancelledException implements Exception {
  const UpdateCancelledException();
}

/// Hasil satu kali pemeriksaan pembaruan dari GitHub Releases.
class UpdateCheckResult {
  const UpdateCheckResult({
    required this.hasUpdate,
    required this.currentVersion,
    this.latestVersion,
    this.notes,
    this.downloadUrl,
    this.assetName,
    this.assetSize = 0,
    this.error,
  });

  final bool hasUpdate;

  /// Versi aplikasi yang sedang dipakai, mis. `1.0.0+1`.
  final String currentVersion;

  /// Versi rilis terbaru, mis. `1.0.1`; null bila repo belum punya rilis.
  final String? latestVersion;

  /// Isi catatan rilis dari GitHub.
  final String? notes;

  /// URL unduhan berkas installer.
  final String? downloadUrl;

  /// Nama berkas installer, mis. `ePOSWA-1.0.1-Setup.exe`.
  final String? assetName;

  /// Ukuran berkas installer menurut GitHub; 0 bila tidak diketahui.
  final int assetSize;

  /// Pesan siap tampil bila pemeriksaan gagal.
  final String? error;

  /// Benar bila rilis tersedia lengkap dengan berkas installer.
  bool get canInstall => hasUpdate && downloadUrl != null;
}

/// Pemeriksa pembaruan aplikasi dari GitHub Releases repo publik.
///
/// Memakai [HttpClient] bawaan sehingga tidak perlu dependency HTTP tambahan.
class UpdateService {
  UpdateService._();

  static const String repo = 'fadhilmanfa/eposwa';
  static const String _userAgent = 'ePOSWA-Updater';
  static const Duration _timeout = Duration(seconds: 10);

  static String get releasesUrl => 'https://github.com/$repo/releases';
  static String get releasesLatestUrl => 'https://github.com/$repo/releases/latest';

  /// Membuka halaman Releases di browser default (fallback saat cert/proxy bermasalah).
  static Future<void> openReleasesPage() async {
    final url = releasesLatestUrl;
    try {
      if (Platform.isWindows) {
        await Process.start('cmd', ['/c', 'start', '', url], runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.start('open', [url]);
      } else if (Platform.isLinux) {
        await Process.start('xdg-open', [url]);
      } else {
        throw const UpdateException('Tidak dapat membuka browser di platform ini.');
      }
    } catch (e) {
      if (e is UpdateException) rethrow;
      throw UpdateException('Gagal membuka browser: $e');
    }
  }

  /// Hasil pemeriksaan terakhir; dipakai ulang saat tombol Update diklik.
  static UpdateCheckResult? lastResult;

  static bool _isCertError(Object error) {
    if (error is HandshakeException) return true;
    final s = error.toString();
    return s.contains('CERTIFICATE_VERIFY_FAILED') ||
        s.contains('HandshakeException') ||
        s.contains('Handshake error');
  }

  static String _friendlyCertMessage() =>
      'Koneksi aman gagal memverifikasi sertifikat. '
      'Periksa tanggal & waktu Windows, pastikan Windows Update aktif, '
      'atau coba lagi di jaringan tanpa proxy/VPN. '
      'Jika tetap gagal, gunakan tombol Buka di GitHub untuk unduh manual.';

  static String _sanitizeError(Object error) {
    var msg = error.toString().replaceAll(RegExp(r'\s*\(.*handshake\.cc:\d+\)'), '').trim();
    msg = msg.replaceAll(RegExp(r'^HandshakeException:[^:]*:\s*'), '');
    msg = msg.replaceAll('OS Error: ', '');
    if (msg.length > 220) msg = '${msg.substring(0, 220)}…';
    return msg;
  }

  static HttpClient _newClient({bool insecure = false}) {
    final c = HttpClient()..connectionTimeout = _timeout;
    if (insecure) c.badCertificateCallback = (cert, host, port) => true;
    return c;
  }

  static Future<UpdateCheckResult> _checkWith(HttpClient client, String current) async {
    final request = await client.getUrl(
      Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
    );
    request.headers
      ..set(HttpHeaders.userAgentHeader, _userAgent)
      ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
    final response = await request.close().timeout(_timeout);
    if (response.statusCode == HttpStatus.notFound) {
      return UpdateCheckResult(hasUpdate: false, currentVersion: current);
    }
    if (response.statusCode != HttpStatus.ok) {
      return UpdateCheckResult(
        hasUpdate: false,
        currentVersion: current,
        error: 'Server pembaruan menolak permintaan (${response.statusCode}).',
      );
    }
    final body = await response.transform(utf8.decoder).join();
    final release = jsonDecode(body) as Map<String, dynamic>;
    final tag = (release['tag_name'] as String?)?.trim() ?? '';
    if (tag.isEmpty) {
      return UpdateCheckResult(
        hasUpdate: false,
        currentVersion: current,
        error: 'Rilis terbaru tidak menyertakan nomor versi.',
      );
    }
    final latest = tag.startsWith('v') ? tag.substring(1) : tag;
    final asset = _pickAsset(release['assets']);
    if (asset == null) {
      return UpdateCheckResult(
        hasUpdate: false,
        currentVersion: current,
        latestVersion: latest,
        error: 'Rilis $tag tidak menyertakan berkas installer.',
      );
    }
    return UpdateCheckResult(
      hasUpdate: compareVersions(latest, current) > 0,
      currentVersion: current,
      latestVersion: latest,
      notes: (release['body'] as String?)?.trim(),
      downloadUrl: asset['browser_download_url'] as String?,
      assetName: asset['name'] as String?,
      assetSize: (asset['size'] as num?)?.toInt() ?? 0,
    );
  }

  /// Mengambil rilis terbaru dan membandingkannya dengan versi terpasang.
  ///
  /// Menangani `CERTIFICATE_VERIFY_FAILED` (HandshakeException dari BoringSSL
  /// di Windows) secara khusus: dicoba sekali lagi dengan
  /// `badCertificateCallback` agar update tetap bisa jalan di mesin dengan
  /// root-CA bermasalah / proxy korporat. Bila tetap gagal, pesan ramah
  /// tanpa jejak `handshake.cc` ditampilkan.
  static Future<UpdateCheckResult> check() async {
    final current = AppInfoService.version;
    final secureClient = _newClient(insecure: false);
    try {
      final result = await _checkWith(secureClient, current);
      return lastResult = result;
    } on SocketException {
      return lastResult = UpdateCheckResult(
        hasUpdate: false,
        currentVersion: current,
        error: 'Tidak dapat terhubung ke server pembaruan.',
      );
    } on TimeoutException {
      return lastResult = UpdateCheckResult(
        hasUpdate: false,
        currentVersion: current,
        error: 'Koneksi ke server pembaruan habis waktu.',
      );
    } catch (error) {
      if (_isCertError(error)) {
        final insecureClient = _newClient(insecure: true);
        try {
          final retry = await _checkWith(insecureClient, current);
          return lastResult = retry;
        } catch (_) {
          // fallback ke pesan ramah di bawah
        } finally {
          insecureClient.close(force: true);
        }
        return lastResult = UpdateCheckResult(
          hasUpdate: false,
          currentVersion: current,
          error: _friendlyCertMessage(),
        );
      }
      return lastResult = UpdateCheckResult(
        hasUpdate: false,
        currentVersion: current,
        error: 'Gagal memeriksa pembaruan: ${_sanitizeError(error)}',
      );
    } finally {
      secureClient.close(force: true);
    }
  }

  /// Berkas installer dari daftar aset release: `*Setup.exe` diutamakan.
  static Map<String, dynamic>? _pickAsset(Object? assets) {
    if (assets is! List) return null;
    final candidates = assets.whereType<Map<String, dynamic>>().toList();

    String nameOf(Map<String, dynamic> asset) =>
        (asset['name'] as String? ?? '').toLowerCase();

    for (final asset in candidates) {
      if (nameOf(asset).endsWith('setup.exe')) return asset;
    }
    for (final asset in candidates) {
      if (nameOf(asset).endsWith('.exe')) return asset;
    }
    return null;
  }

  /// Memecah versi menjadi bagian angka dan nomor build.
  ///
  /// `v1.0.1` → `[1, 0, 1]` build 0; `1.0.0+7` → `[1, 0, 0]` build 7. Bagian
  /// yang bukan angka dihitung 0 sehingga tag rusak tidak melempar exception.
  static ({List<int> parts, int build}) parseVersion(String raw) {
    final cleaned = raw.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final plus = cleaned.indexOf('+');
    final number = plus < 0 ? cleaned : cleaned.substring(0, plus);
    final build = plus < 0 ? '' : cleaned.substring(plus + 1);

    return (
      parts: number.split('.').map((part) => int.tryParse(part.trim()) ?? 0).toList(),
      build: int.tryParse(build.trim()) ?? 0,
    );
  }

  /// Membandingkan dua versi secara numerik per bagian.
  ///
  /// Mengembalikan nilai > 0 bila [a] lebih baru dari [b]. Nomor build dipakai
  /// sebagai penentu terakhir bila bagian versinya sama.
  static int compareVersions(String a, String b) {
    final left = parseVersion(a);
    final right = parseVersion(b);
    final length = left.parts.length > right.parts.length
        ? left.parts.length
        : right.parts.length;

    for (var i = 0; i < length; i++) {
      final leftPart = i < left.parts.length ? left.parts[i] : 0;
      final rightPart = i < right.parts.length ? right.parts[i] : 0;
      if (leftPart != rightPart) return leftPart.compareTo(rightPart);
    }
    return left.build.compareTo(right.build);
  }

  static Future<File> _downloadWith(
    HttpClient client,
    String url,
    File partial,
    int expected, {
    required void Function(int received, int total) onProgress,
    bool Function()? isCancelled,
  }) async {
    final request = await client.getUrl(Uri.parse(url));
    request.headers
      ..set(HttpHeaders.userAgentHeader, _userAgent)
      ..set(HttpHeaders.acceptHeader, 'application/octet-stream');
    request.followRedirects = true;
    final response = await request.close().timeout(_timeout);
    if (response.statusCode != HttpStatus.ok) {
      throw UpdateException('Gagal mengunduh installer (${response.statusCode}).');
    }
    final total = response.contentLength > 0 ? response.contentLength : expected;
    final sink = partial.openWrite();
    var received = 0;
    var lastEmit = 0;
    final watch = Stopwatch()..start();
    try {
      await for (final chunk in response) {
        if (isCancelled?.call() ?? false) throw const UpdateCancelledException();
        sink.add(chunk);
        received += chunk.length;
        if (watch.elapsedMilliseconds - lastEmit >= 200 ||
            (total > 0 && received >= total)) {
          lastEmit = watch.elapsedMilliseconds;
          onProgress(received, total);
        }
      }
    } finally {
      watch.stop();
      await sink.close();
    }
    if (isCancelled?.call() ?? false) throw const UpdateCancelledException();
    final expectedSize = expected > 0 ? expected : total;
    if (expectedSize > 0 && received != expectedSize) {
      throw const UpdateException('Unduhan tidak lengkap. Silakan coba lagi.');
    }
    return partial;
  }

  /// Mengunduh installer [result] ke folder sementara aplikasi.
  ///
  /// [onProgress] dipanggil paling sering ~5×/detik. Bila [isCancelled]
  /// mengembalikan true, unduhan dihentikan dan [UpdateCancelledException]
  /// dilempar. Ukuran berkas dicocokkan dengan metadata GitHub sebagai
  /// pengaman terhadap unduhan yang terputus.
  /// Menangani CERTIFICATE_VERIFY_FAILED dengan retry insecure.
  static Future<File> download(
    UpdateCheckResult result, {
    required void Function(int received, int total) onProgress,
    bool Function()? isCancelled,
  }) async {
    final url = result.downloadUrl;
    final name = result.assetName;
    if (url == null || name == null) {
      throw const UpdateException('Rilis tidak menyertakan berkas installer.');
    }
    final dir = Directory(p.join(Directory.systemTemp.path, 'eposwa-update'))
      ..createSync(recursive: true);
    _cleanOldInstallers(dir, keep: name);
    final target = File(p.join(dir.path, name));
    final expected = result.assetSize;
    if (target.existsSync() && (expected == 0 || target.lengthSync() == expected)) {
      onProgress(expected, expected);
      return target;
    }
    final partial = File('${target.path}.part');
    if (partial.existsSync()) partial.deleteSync();

    Future<File> attempt({required bool insecure}) async {
      final client = _newClient(insecure: insecure);
      try {
        final tmp = await _downloadWith(client, url, partial, expected,
            onProgress: onProgress, isCancelled: isCancelled);
        return tmp.renameSync(target.path);
      } finally {
        client.close(force: true);
      }
    }

    try {
      return await attempt(insecure: false);
    } on UpdateCancelledException {
      if (partial.existsSync()) partial.deleteSync();
      rethrow;
    } catch (error) {
      if (error is UpdateCancelledException) rethrow;
      if (error is UpdateException) {
        if (partial.existsSync()) partial.deleteSync();
        rethrow;
      }
      if (_isCertError(error)) {
        if (partial.existsSync()) partial.deleteSync();
        try {
          return await attempt(insecure: true);
        } on UpdateCancelledException {
          if (partial.existsSync()) partial.deleteSync();
          rethrow;
        } catch (retryError) {
          if (retryError is UpdateCancelledException) rethrow;
          if (retryError is UpdateException) rethrow;
          if (partial.existsSync()) partial.deleteSync();
          if (_isCertError(retryError)) {
            throw UpdateException(_friendlyCertMessage());
          }
          throw UpdateException('Gagal mengunduh installer: ${_sanitizeError(retryError)}');
        }
      }
      if (partial.existsSync()) partial.deleteSync();
      throw UpdateException('Gagal mengunduh installer: ${_sanitizeError(error)}');
    }
  }

  /// Menghapus installer versi lain supaya folder sementara tidak menumpuk.
  static void _cleanOldInstallers(Directory dir, {required String keep}) {
    for (final entry in dir.listSync()) {
      if (entry is! File) continue;
      if (p.basename(entry.path) == keep) continue;
      try {
        entry.deleteSync();
      } catch (_) {
        // Berkas mungkin masih terkunci proses lain; abaikan.
      }
    }
  }

  /// Membuka installer dengan wizard normal (memicu UAC). Pemanggil yang
  /// menutup aplikasi setelah ini supaya berkasnya bisa diganti.
  static Future<void> launchInstaller(File file) async {
    if (!Platform.isWindows) {
      throw const UpdateException(
        'Pemasangan otomatis hanya tersedia di Windows.',
      );
    }
    await Process.start(file.path, const [], mode: ProcessStartMode.detached);
  }
}
