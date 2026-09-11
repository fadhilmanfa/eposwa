import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// Pengaman berkas database: cadangan sebelum migrasi skema dan pemulihan
/// otomatis bila proses sebelumnya terputus di tengah migrasi.
///
/// Dipanggil dari [AppDatabase] pada dua titik: `_openConnection` (sebelum
/// database dibuka) dan `beforeOpen` (setelah migrasi sukses). Seluruh
/// kegagalan di kelas ini hanya dicatat ke `backups/update-log.txt` dan tidak
/// pernah menghalangi aplikasi dibuka.
///
/// Batas yang disadari: bila versi baru tetap gagal migrasi setelah dipulihkan
/// (artinya bug pada kode migrasinya, bukan pada datanya), aplikasi akan gagal
/// terbuka berulang. Data tetap utuh di berkas cadangan dan bisa dipulihkan
/// manual — jauh lebih baik daripada skema yang tertinggal setengah jadi.
class DbSafety {
  DbSafety._();

  /// Jumlah berkas cadangan yang disimpan; yang lebih lama dihapus otomatis.
  static const int maxBackups = 3;

  /// Berkas database yang sedang dipakai proses ini, diisi oleh [prepare].
  static File? currentFile;

  /// Dipanggil sebelum database dibuka.
  ///
  /// Bila berkas ada dan versinya lebih lama dari [schemaVersion], migrasi akan
  /// berjalan sehingga cadangan dibuat lebih dulu. Bila sebelumnya migrasi
  /// terputus (penanda `*.upgrading` masih ada), database dipulihkan dari
  /// cadangan terbaru sebelum migrasi diulang.
  static Future<void> prepare(File dbFile, {required int schemaVersion}) async {
    currentFile = dbFile;
    try {
      final marker = File(_markerPath(dbFile));

      if (marker.existsSync()) {
        _recoverInterruptedMigration(dbFile, marker, schemaVersion);
      }

      if (!dbFile.existsSync()) return;

      final version = _readUserVersion(dbFile);
      if (version <= 0 || version >= schemaVersion) return;

      await _createBackup(dbFile, version, marker);
      _log(
        dbFile,
        'Cadangan dibuat sebelum migrasi skema v$version → v$schemaVersion.',
      );
    } catch (error, stackTrace) {
      _log(dbFile, 'Gagal menyiapkan pengaman database: $error\n$stackTrace');
    }
  }

  /// Dipanggil setelah database berhasil dibuka dan migrasinya selesai, jadi
  /// penanda hanya terhapus kalau pembukaan benar-benar sukses.
  static Future<void> afterOpenSuccess() async {
    final dbFile = currentFile;
    if (dbFile == null) return;
    final marker = File(_markerPath(dbFile));
    if (!marker.existsSync()) return;
    try {
      marker.deleteSync();
      _log(dbFile, 'Migrasi selesai; penanda upgrade dihapus.');
    } catch (error) {
      _log(dbFile, 'Gagal menghapus penanda upgrade: $error');
    }
  }

  /// Pemulihan setelah migrasi terputus.
  ///
  /// Kalau versi berkas ternyata sudah sama dengan target, migrasinya
  /// sebenarnya tuntas — penanda cukup dihapus tanpa menyentuh data. Selain itu
  /// berkas dikembalikan dari cadangan terbaru, lalu proses pemanggil akan
  /// membuat cadangan baru untuk percobaan migrasi berikutnya.
  static void _recoverInterruptedMigration(
    File dbFile,
    File marker,
    int schemaVersion,
  ) {
    int version;
    try {
      version = _readUserVersion(dbFile);
    } catch (_) {
      version = -1;
    }

    if (version >= schemaVersion) {
      marker.deleteSync();
      _log(dbFile, 'Migrasi ternyata sudah selesai; penanda upgrade dihapus.');
      return;
    }

    final backup = _latestBackup(dbFile);
    if (backup == null) {
      marker.deleteSync();
      _log(
        dbFile,
        'Migrasi terputus tapi tidak ada cadangan; migrasi akan diulang.',
      );
      return;
    }

    backup.copySync(dbFile.path);
    for (final suffix in const ['-wal', '-shm']) {
      final sideCar = File('${dbFile.path}$suffix');
      if (sideCar.existsSync()) sideCar.deleteSync();
    }
    marker.deleteSync();
    _log(
      dbFile,
      'Migrasi terputus terdeteksi; database dipulihkan dari '
      '${p.basename(backup.path)}.',
    );
  }

  /// Membuat cadangan memakai SQLite Online Backup API — bukan salin berkas
  /// mentah — supaya isi cadangan dijamin konsisten.
  static Future<void> _createBackup(
    File dbFile,
    int version,
    File marker,
  ) async {
    final dir = _backupDir(dbFile)..createSync(recursive: true);
    final dest = _uniqueBackupFile(dir, version);

    final source = sqlite3.open(dbFile.path);
    try {
      final target = sqlite3.open(dest.path);
      try {
        await source.backup(target).drain<void>();
      } finally {
        target.close();
      }
    } finally {
      source.close();
    }

    marker.writeAsStringSync(
      'cadangan=${p.basename(dest.path)}\n'
      'versi=$version\n'
      'waktu=${DateTime.now().toIso8601String()}\n',
    );

    _pruneBackups(dir);
  }

  static File _uniqueBackupFile(Directory dir, int version) {
    final stamp = _timestamp(DateTime.now());
    var dest = File(p.join(dir.path, 'eposwa-v$version-$stamp.db'));
    var counter = 1;
    while (dest.existsSync()) {
      dest = File(p.join(dir.path, 'eposwa-v$version-$stamp-$counter.db'));
      counter++;
    }
    return dest;
  }

  static void _pruneBackups(Directory dir) {
    final backups =
        dir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.db'))
            .toList()
          ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    for (final file in backups.skip(maxBackups)) {
      file.deleteSync();
    }
  }

  static File? _latestBackup(File dbFile) {
    final dir = _backupDir(dbFile);
    if (!dir.existsSync()) return null;
    final backups =
        dir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.db'))
            .toList()
          ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    return backups.isEmpty ? null : backups.first;
  }

  /// Versi skema disimpan drift di `PRAGMA user_version`.
  static int _readUserVersion(File dbFile) {
    final db = sqlite3.open(dbFile.path);
    try {
      return db.userVersion;
    } finally {
      db.close();
    }
  }

  static Directory _backupDir(File dbFile) =>
      Directory(p.join(dbFile.parent.path, 'backups'));

  static String _markerPath(File dbFile) => '${dbFile.path}.upgrading';

  static String _timestamp(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}-'
        '${two(time.hour)}${two(time.minute)}${two(time.second)}-'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }

  static void _log(File dbFile, String message) {
    try {
      final dir = _backupDir(dbFile)..createSync(recursive: true);
      File(p.join(dir.path, 'update-log.txt')).writeAsStringSync(
        '[${DateTime.now().toIso8601String()}] $message\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Catatan hanya untuk diagnosa; kegagalan menulis tidak boleh mengganggu.
    }
  }
}
