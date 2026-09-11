import 'dart:io';

import 'package:eposwa/core/database/db_safety.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// Memastikan database pengguna tidak pernah rusak saat aplikasi diperbarui:
/// cadangan dibuat sebelum migrasi skema dan dipulihkan bila proses sebelumnya
/// terputus di tengah migrasi.
void main() {
  late Directory dir;
  late File dbFile;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('eposwa-db-safety-');
    dbFile = File(p.join(dir.path, 'eposwa.db'));
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  /// Membuat database versi [version] berisi satu baris peserta.
  void seedDatabase({required int version}) {
    final db = sqlite3.open(dbFile.path);
    try {
      db.execute('CREATE TABLE IF NOT EXISTS pesertas (id INTEGER PRIMARY KEY, nama TEXT)');
      db.execute("INSERT INTO pesertas (nama) VALUES ('Ahmad')");
      db.userVersion = version;
    } finally {
      db.close();
    }
  }

  List<File> backupFiles() {
    final backupDir = Directory(p.join(dir.path, 'backups'));
    if (!backupDir.existsSync()) return const [];
    return backupDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.db'))
        .toList();
  }

  File marker() => File('${dbFile.path}.upgrading');

  test('membuat cadangan dan penanda saat versi berkas lebih lama', () async {
    seedDatabase(version: 1);

    await DbSafety.prepare(dbFile, schemaVersion: 2);

    final backups = backupFiles();
    expect(backups, hasLength(1));
    expect(marker().existsSync(), isTrue);

    final backup = sqlite3.open(backups.single.path);
    try {
      expect(backup.select('SELECT nama FROM pesertas').single['nama'], 'Ahmad');
    } finally {
      backup.close();
    }
  });

  test('tidak membuat cadangan bila versi sudah sama', () async {
    seedDatabase(version: 2);

    await DbSafety.prepare(dbFile, schemaVersion: 2);

    expect(backupFiles(), isEmpty);
    expect(marker().existsSync(), isFalse);
  });

  test('tidak melakukan apa-apa bila berkas database belum ada', () async {
    await DbSafety.prepare(dbFile, schemaVersion: 2);

    expect(backupFiles(), isEmpty);
    expect(marker().existsSync(), isFalse);
  });

  test('afterOpenSuccess menghapus penanda upgrade', () async {
    seedDatabase(version: 1);
    await DbSafety.prepare(dbFile, schemaVersion: 2);
    expect(marker().existsSync(), isTrue);

    await DbSafety.afterOpenSuccess();

    expect(marker().existsSync(), isFalse);
  });

  test('memulihkan database bila migrasi sebelumnya terputus', () async {
    seedDatabase(version: 1);
    await DbSafety.prepare(dbFile, schemaVersion: 2);

    // Simulasi migrasi yang berhenti di tengah: tabel sudah hilang, versi
    // masih lama, dan penanda belum sempat dihapus.
    final broken = sqlite3.open(dbFile.path);
    try {
      broken.execute('DROP TABLE pesertas');
    } finally {
      broken.close();
    }

    await DbSafety.prepare(dbFile, schemaVersion: 2);

    final restored = sqlite3.open(dbFile.path);
    try {
      expect(restored.select('SELECT nama FROM pesertas').single['nama'], 'Ahmad');
    } finally {
      restored.close();
    }
  });

  test('tidak memulihkan bila versi ternyata sudah selesai dimigrasi', () async {
    seedDatabase(version: 2);
    final db = sqlite3.open(dbFile.path);
    try {
      db.execute('DROP TABLE pesertas');
    } finally {
      db.close();
    }
    marker().writeAsStringSync('sisa penanda dari migrasi yang sukses');

    await DbSafety.prepare(dbFile, schemaVersion: 2);

    expect(marker().existsSync(), isFalse);
    final check = sqlite3.open(dbFile.path);
    try {
      final tables = check.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='pesertas'",
      );
      expect(tables, isEmpty, reason: 'data hasil migrasi tidak boleh ditimpa');
    } finally {
      check.close();
    }
  });

  test('menyimpan paling banyak tiga cadangan terbaru', () async {
    seedDatabase(version: 1);

    for (var i = 0; i < 5; i++) {
      await DbSafety.prepare(dbFile, schemaVersion: 2);
    }

    expect(backupFiles().length, DbSafety.maxBackups);
  });
}
