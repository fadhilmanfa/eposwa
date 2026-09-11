import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/services/xlsx_writer.dart';

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

  /// Membangun 3 sheet laporan (Peserta, Skrining, Jawaban Skrining).
  static Future<List<XlsxSheet>> _buildReportSheets() async {
    final db = getAppDatabase();

    final peserta = await db.customSelect(
      'SELECT id, kode_peserta, nama, nik, jenis_kelamin, tgl_lahir, alamat, '
      'no_hp, program, pernah_konsultasi, pernah_dapat_obat, status, tgl_daftar '
      'FROM pesertas ORDER BY id',
    ).get();

    final skrining = await db.customSelect(
      'SELECT s.id, s.peserta_id, p.kode_peserta, p.nama AS nama_peserta, '
      's.tanggal, s.skor, s.kategori, s.is_red_flag, s.rekomendasi '
      'FROM skrining_records s '
      'JOIN pesertas p ON p.id = s.peserta_id ORDER BY s.id',
    ).get();

    final jawaban = await db.customSelect(
      'SELECT j.skrining_id, p.nama AS nama_peserta, s.tanggal, j.nomor, j.jawaban '
      'FROM skrining_jawabans j '
      'JOIN skrining_records s ON s.id = j.skrining_id '
      'JOIN pesertas p ON p.id = s.peserta_id '
      'ORDER BY j.skrining_id, j.nomor',
    ).get();

    return [
      XlsxSheet('Peserta', [
        const [
          'ID',
          'Kode Peserta',
          'Nama',
          'NIK',
          'Jenis Kelamin',
          'Tanggal Lahir',
          'Alamat',
          'No. HP',
          'Program',
          'Pernah Konsultasi',
          'Pernah Dapat Obat',
          'Status',
          'Tanggal Daftar',
        ],
        for (final row in peserta)
          [
            row.data['id'],
            _text(row.data['kode_peserta']),
            _text(row.data['nama']),
            _text(row.data['nik']),
            _text(row.data['jenis_kelamin']),
            _text(row.data['tgl_lahir']),
            _text(row.data['alamat']),
            _text(row.data['no_hp']),
            _text(row.data['program']),
            _yesNo(row.data['pernah_konsultasi']),
            _yesNo(row.data['pernah_dapat_obat']),
            _text(row.data['status']),
            _text(row.data['tgl_daftar']),
          ],
      ]),
      XlsxSheet('Skrining', [
        const [
          'ID Skrining',
          'ID Peserta',
          'Kode Peserta',
          'Nama Peserta',
          'Tanggal',
          'Skor',
          'Kategori',
          'Red Flag',
          'Rekomendasi',
        ],
        for (final row in skrining)
          [
            row.data['id'],
            row.data['peserta_id'],
            _text(row.data['kode_peserta']),
            _text(row.data['nama_peserta']),
            _text(row.data['tanggal']),
            _text(row.data['skor']),
            _text(row.data['kategori']),
            _yesNo(row.data['is_red_flag']),
            _text(row.data['rekomendasi']),
          ],
      ]),
      XlsxSheet('Jawaban Skrining', [
        const [
          'ID Skrining',
          'Nama Peserta',
          'Tanggal',
          'Nomor',
          'Jawaban',
        ],
        for (final row in jawaban)
          [
            row.data['skrining_id'],
            _text(row.data['nama_peserta']),
            _text(row.data['tanggal']),
            row.data['nomor'],
            _yesNo(row.data['jawaban']),
          ],
      ]),
    ];
  }

  static String _text(Object? value) => value == null ? '-' : value.toString();

  static String _yesNo(Object? value) {
    if (value == null) return '-';
    return (value == 1 || value == true) ? 'Ya' : 'Tidak';
  }

  /// Bytes file .xlsx (dipisah dari dialog simpan agar mudah diuji).
  static Future<List<int>> buildExcelBytes() async {
    return XlsxWriter.build(await _buildReportSheets());
  }

  /// true bila sudah ada data peserta/skrining/jawaban untuk dilaporkan.
  static Future<bool> hasReportData() async {
    final row = await getAppDatabase()
        .customSelect(
          'SELECT (SELECT COUNT(*) FROM pesertas) + '
          '(SELECT COUNT(*) FROM skrining_records) + '
          '(SELECT COUNT(*) FROM skrining_jawabans) AS total',
        )
        .getSingle();
    return (row.data['total'] as int? ?? 0) > 0;
  }

  /// Simpan laporan Excel (.xlsx) lewat dialog Save.
  static Future<String?> exportExcel() async {
    final now = DateTime.now();
    final defaultName =
        'eposwa_data_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.xlsx';

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Data Excel',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (savePath == null) return null;

    final bytes = await buildExcelBytes();
    final file = File(savePath);
    await file.writeAsBytes(bytes, flush: true);
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
