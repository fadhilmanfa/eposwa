import 'dart:io';

/// Versi aplikasi beserta nomor build, hasil pembacaan `version:` di pubspec.yaml.
///
/// Contoh: `1.0.0+1` menghasilkan bagian `[1, 0, 0]` dan build `1`.
typedef PubspecVersion = ({List<String> parts, String build});

/// Membaca `version:` dari pubspec.yaml dan memecahnya menjadi bagian-bagiannya.
///
/// Menghentikan proses dengan pesan yang jelas bila pubspec tidak ada atau
/// baris `version:` tidak ditemukan.
PubspecVersion readPubspecVersion(String root) {
  final pubspec = File('$root\\pubspec.yaml');
  if (!pubspec.existsSync()) {
    fail('pubspec.yaml tidak ditemukan di $root.');
  }
  final match = RegExp(
    r'''^version:\s*["']?([^"'\s#]+)''',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync());
  if (match == null) {
    fail('Baris version: tidak ditemukan di pubspec.yaml.');
  }

  final raw = match.group(1)!;
  final plus = raw.indexOf('+');
  final number = plus < 0 ? raw : raw.substring(0, plus);
  final build = plus < 0 ? '0' : raw.substring(plus + 1);

  final parts = number.split('.');
  while (parts.length < 3) {
    parts.add('0');
  }
  return (parts: parts, build: build);
}

/// Menghentikan proses dengan pesan kesalahan.
Never fail(String message) {
  stderr.writeln('\nERROR: $message');
  exit(1);
}
