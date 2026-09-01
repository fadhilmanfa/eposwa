import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:eposwa/core/database/app_database.dart';

class ExportService {
  static String _escapeSql(dynamic value) {
    if (value == null) return 'NULL';
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    if (value is bool) return value ? '1' : '0';
    if (value is String) return "'${value.replaceAll("'", "''")}'";
    return "'${value.toString().replaceAll("'", "''")}'";
  }

  /// Membuat SQL dump seluruh database sebagai string.
  /// Dipakai untuk: kirim lewat jaringan (Instan) dan opsi Simpan.
  static Future<String> exportSqlToString() async {
    final now = DateTime.now();
    final buffer = StringBuffer();
    buffer.writeln('-- ePOSWA SQL Dump');
    buffer.writeln('-- Generated: ${now.toIso8601String()}');
    buffer.writeln('-- phpMyAdmin style - compatible with ePOSWA import');
    buffer.writeln();
    buffer.writeln('PRAGMA foreign_keys=OFF;');
    buffer.writeln('BEGIN TRANSACTION;');
    buffer.writeln();
    await _dumpToBuffer(buffer);
    buffer.writeln('COMMIT;');
    return buffer.toString();
  }

  static Future<void> _dumpToBuffer(StringBuffer buffer) async {
    final db = getAppDatabase();
    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    } catch (_) {}

    final createRows = await db.customSelect(
      "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND sql NOT NULL ORDER BY CASE name WHEN 'admins' THEN 1 WHEN 'pesertas' THEN 2 WHEN 'skrining_records' THEN 3 WHEN 'skrining_jawabans' THEN 4 ELSE 5 END",
    ).get();

    for (final row in createRows) {
      final sql = row.data['sql'] as String?;
      if (sql == null) continue;
      String createSql = sql;
      if (!createSql.toUpperCase().contains('IF NOT EXISTS')) {
        createSql = createSql.replaceFirst(RegExp(r'CREATE TABLE', caseSensitive: false), 'CREATE TABLE IF NOT EXISTS');
      }
      buffer.writeln('$createSql;');
    }
    buffer.writeln();

    Future<void> dumpTable(String tableName) async {
      final rows = await db.customSelect('SELECT * FROM "$tableName"').get();
      if (rows.isEmpty) return;
      for (final row in rows) {
        final cols = row.data.keys.toList();
        final vals = cols.map((c) => _escapeSql(row.data[c])).join(', ');
        final colList = cols.map((c) => '"$c"').join(', ');
        buffer.writeln('INSERT INTO "$tableName" ($colList) VALUES ($vals);');
      }
      buffer.writeln();
    }

    await dumpTable('admins');
    await dumpTable('pesertas');
    await dumpTable('skrining_records');
    await dumpTable('skrining_jawabans');
  }

  static Future<String?> exportSql() async {
    final now = DateTime.now();
    final defaultName =
        'eposwa_backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.sql';

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Backup SQL',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['sql'],
    );
    if (savePath == null) return null;

    final buffer = StringBuffer();
    buffer.writeln('-- ePOSWA SQL Dump');
    buffer.writeln('-- Generated: ${now.toIso8601String()}');
    buffer.writeln('-- phpMyAdmin style - compatible with ePOSWA import');
    buffer.writeln();
    buffer.writeln('PRAGMA foreign_keys=OFF;');
    buffer.writeln('BEGIN TRANSACTION;');
    buffer.writeln();
    await _dumpToBuffer(buffer);
    buffer.writeln('COMMIT;');

    final file = File(savePath);
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  /// Instan: export SQL ke temp dir, copy path ke clipboard, dan buka folder.
  /// Tidak ada dialog Save — untuk berbagi cepat.
  static Future<String> exportSqlInstan() async {
    final now = DateTime.now();
    final fileName =
        'eposwa_instan_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.sql';

    final buffer = StringBuffer();
    buffer.writeln('-- ePOSWA SQL Dump (Instan)');
    buffer.writeln('-- Generated: ${now.toIso8601String()}');
    buffer.writeln('-- phpMyAdmin style - compatible with ePOSWA import');
    buffer.writeln();
    buffer.writeln('PRAGMA foreign_keys=OFF;');
    buffer.writeln('BEGIN TRANSACTION;');
    buffer.writeln();
    await _dumpToBuffer(buffer);
    buffer.writeln('COMMIT;');

    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, fileName));
    await file.writeAsString(buffer.toString());

    // Copy path to clipboard for quick share
    await Clipboard.setData(ClipboardData(text: file.path));

    // Try to open folder in Explorer (Windows) / Finder (macOS) / xdg-open (Linux)
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', [tempDir.path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [tempDir.path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [tempDir.path]);
      }
    } catch (_) {}

    return file.path;
  }
}
