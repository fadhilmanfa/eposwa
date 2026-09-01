import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:eposwa/core/database/app_database.dart';

enum ImportStrategy { skip, replace, merge }

class ImportPreview {
  final int totalInFile;
  final int newCount;
  final int duplicateCount;
  final List<String> duplicateNiks;
  ImportPreview({required this.totalInFile, required this.newCount, required this.duplicateCount, required this.duplicateNiks});
}

class ImportResult {
  final int imported;
  final int skipped;
  final int replaced;
  final int merged;
  ImportResult({required this.imported, required this.skipped, required this.replaced, required this.merged});
}

class ImportService {
  static Future<ImportPreview?> previewSqlImport(String sqlPath) async {
    final content = await File(sqlPath).readAsString();
    final pesertaInserts = RegExp(r'INSERT INTO "pesertas"', caseSensitive: false).allMatches(content).length;
    final currentDb = getAppDatabase();
    final currentPesertas = await currentDb.select(currentDb.pesertas).get();
    final currentNikSet = currentPesertas.map((e) => e.nik).toSet();
    int dup = 0;
    final dupNiks = <String>[];
    final lines = content.split('\n');
    for (final line in lines) {
      if (!line.toUpperCase().contains('INSERT INTO "PESERTAS"')) continue;
      final colMatch = RegExp(r'INSERT INTO "pesertas" \(([^)]+)\)').firstMatch(line);
      if (colMatch == null) continue;
      final cols = colMatch.group(1)!.split(',').map((c) => c.trim().replaceAll('"', '').toLowerCase()).toList();
      final nikIdx = cols.indexOf('nik');
      if (nikIdx == -1) continue;
      final valMatch = RegExp(r'VALUES\s*\((.*)\)\s*;', caseSensitive: false).firstMatch(line);
      if (valMatch == null) continue;
      final vals = _splitSqlValues(valMatch.group(1)!);
      if (nikIdx >= vals.length) continue;
      final nikVal = vals[nikIdx].trim();
      String nik = nikVal;
      if (nik.startsWith("'") && nik.endsWith("'")) {
        nik = nik.substring(1, nik.length - 1).replaceAll("''", "'");
      }
      if (currentNikSet.contains(nik)) {
        dup++;
        dupNiks.add(nik);
      }
    }
    return ImportPreview(totalInFile: pesertaInserts, newCount: pesertaInserts - dup, duplicateCount: dup, duplicateNiks: dupNiks);
  }

  static List<String> _splitSqlValues(String raw) {
    final result = <String>[];
    final buf = StringBuffer();
    bool inQuote = false;
    for (int i = 0; i < raw.length; i++) {
      final c = raw[i];
      if (c == "'") {
        if (inQuote && i + 1 < raw.length && raw[i + 1] == "'") {
          buf.write("''");
          i++;
        } else {
          inQuote = !inQuote;
          buf.write(c);
        }
      } else if (c == ',' && !inQuote) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    if (buf.isNotEmpty) result.add(buf.toString());
    return result;
  }

  static Future<ImportResult> importSql(String sqlPath, ImportStrategy strategy) async {
    final content = await File(sqlPath).readAsString();
    final currentDb = getAppDatabase();
    int imported = 0, skipped = 0, replaced = 0, merged = 0;
    final lines = content.split('\n');
    final nonPesertaStatements = <String>[];
    final pesertaInserts = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('--') || trimmed.startsWith('PRAGMA') || trimmed.startsWith('BEGIN') || trimmed.startsWith('COMMIT')) continue;
      if (trimmed.toUpperCase().contains('CREATE TABLE')) {
        nonPesertaStatements.add(line);
      } else if (trimmed.toUpperCase().contains('INSERT INTO "PESERTAS"')) {
        pesertaInserts.add(line);
      } else if (trimmed.toUpperCase().startsWith('INSERT INTO')) {
        nonPesertaStatements.add(line);
      }
    }
    for (final stmt in nonPesertaStatements.where((s) => s.toUpperCase().contains('CREATE TABLE'))) {
      try {
        await currentDb.customStatement(stmt);
      } catch (_) {}
    }
    final Map<String, int> nikToId = {};
    final existingPesertas = await currentDb.select(currentDb.pesertas).get();
    for (final p in existingPesertas) {
      nikToId[p.nik] = p.id;
    }
    for (final line in pesertaInserts) {
      final colMatch = RegExp(r'INSERT INTO "pesertas" \(([^)]+)\)').firstMatch(line);
      final valMatch = RegExp(r'VALUES\s*\((.*)\)\s*;', caseSensitive: false).firstMatch(line);
      if (colMatch == null || valMatch == null) continue;
      final cols = colMatch.group(1)!.split(',').map((c) => c.trim().replaceAll('"', '')).toList();
      final vals = _splitSqlValues(valMatch.group(1)!);
      final map = <String, String>{};
      for (int i = 0; i < cols.length && i < vals.length; i++) {
        map[cols[i].toLowerCase()] = vals[i].trim();
      }
      String unquote(String v) {
        v = v.trim();
        if (v == 'NULL') return '';
        if (v.startsWith("'") && v.endsWith("'")) return v.substring(1, v.length - 1).replaceAll("''", "'");
        return v;
      }

      final nik = unquote(map['nik'] ?? '');
      if (nik.isEmpty) continue;
      if (nikToId.containsKey(nik)) {
        final existingId = nikToId[nik]!;
        if (strategy == ImportStrategy.skip) {
          skipped++;
          continue;
        } else if (strategy == ImportStrategy.replace) {
          final existing = await (currentDb.select(currentDb.pesertas)..where((t) => t.id.equals(existingId))).getSingleOrNull();
          if (existing != null) {
            await (currentDb.update(currentDb.pesertas)..where((t) => t.id.equals(existingId))).write(
              PesertasCompanion(
                nama: Value(unquote(map['nama'] ?? existing.nama)),
                jenisKelamin: Value(unquote(map['jenis_kelamin'] ?? existing.jenisKelamin)),
                tglLahir: Value(unquote(map['tgl_lahir'] ?? '')),
                alamat: Value(unquote(map['alamat'] ?? '')),
                noHp: Value(unquote(map['no_hp'] ?? existing.noHp)),
                program: Value(unquote(map['program'] ?? existing.program)),
                status: Value(unquote(map['status'] ?? existing.status)),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
          replaced++;
        } else if (strategy == ImportStrategy.merge) {
          final existing = await (currentDb.select(currentDb.pesertas)..where((t) => t.id.equals(existingId))).getSingleOrNull();
          if (existing != null) {
            await (currentDb.update(currentDb.pesertas)..where((t) => t.id.equals(existingId))).write(
              PesertasCompanion(
                alamat: (existing.alamat == null || existing.alamat!.isEmpty) ? Value(unquote(map['alamat'] ?? '')) : const Value.absent(),
                noHp: existing.noHp.isEmpty ? Value(unquote(map['no_hp'] ?? '')) : const Value.absent(),
                tglLahir: existing.tglLahir == null ? Value(unquote(map['tgl_lahir'] ?? '')) : const Value.absent(),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
          merged++;
        }
      } else {
        try {
          await currentDb.customStatement(line);
          final inserted = await (currentDb.select(currentDb.pesertas)..where((t) => t.nik.equals(nik))).getSingleOrNull();
          if (inserted != null) nikToId[nik] = inserted.id;
          imported++;
        } catch (_) {
          try {
            final kode = map['kode_peserta'] != null ? unquote(map['kode_peserta']!) : 'REG-${DateTime.now().year}-${nikToId.length + 1}';
            final colsWithoutId = cols.where((c) => c.toLowerCase() != 'id').toList();
            final valsWithoutId = <String>[];
            for (final c in colsWithoutId) {
              valsWithoutId.add(map[c.toLowerCase()] ?? 'NULL');
            }
            final kodeIdx = colsWithoutId.indexWhere((c) => c.toLowerCase() == 'kode_peserta');
            if (kodeIdx != -1) {
              String newKode = kode;
              int suffix = 1;
              while (await (currentDb.select(currentDb.pesertas)..where((t) => t.kodePeserta.equals(newKode))).getSingleOrNull() != null) {
                newKode = '${kode}_$suffix';
                suffix++;
              }
              valsWithoutId[kodeIdx] = "'${newKode.replaceAll("'", "''")}'";
            }
            final newStmt = 'INSERT INTO "pesertas" (${colsWithoutId.map((c) => '"$c"').join(', ')}) VALUES (${valsWithoutId.join(', ')});';
            await currentDb.customStatement(newStmt);
            final inserted = await (currentDb.select(currentDb.pesertas)..where((t) => t.nik.equals(nik))).getSingleOrNull();
            if (inserted != null) nikToId[nik] = inserted.id;
            imported++;
          } catch (_) {
            skipped++;
          }
        }
      }
    }
    final skriningInserts = lines.where((l) => l.toUpperCase().contains('INSERT INTO "SKRINING_RECORDS"')).toList();
    final jawabanInserts = lines.where((l) => l.toUpperCase().contains('INSERT INTO "SKRINING_JAWABANS"')).toList();
    final oldIdToNik = <int, String>{};
    for (final line in pesertaInserts) {
      final colMatch = RegExp(r'INSERT INTO "pesertas" \(([^)]+)\)').firstMatch(line);
      final valMatch = RegExp(r'VALUES\s*\((.*)\)\s*;', caseSensitive: false).firstMatch(line);
      if (colMatch == null || valMatch == null) continue;
      final cols = colMatch.group(1)!.split(',').map((c) => c.trim().replaceAll('"', '').toLowerCase()).toList();
      final vals = _splitSqlValues(valMatch.group(1)!);
      final idIdx = cols.indexOf('id');
      final nikIdx = cols.indexOf('nik');
      if (idIdx == -1 || nikIdx == -1) continue;
      final idVal = vals[idIdx].trim();
      final nikVal = vals[nikIdx].trim();
      final id = int.tryParse(idVal) ?? 0;
      String nik = nikVal;
      if (nik.startsWith("'") && nik.endsWith("'")) nik = nik.substring(1, nik.length - 1).replaceAll("''", "'");
      oldIdToNik[id] = nik;
    }
    final oldSkriningToNew = <int, int>{};
    for (final line in skriningInserts) {
      final colMatch = RegExp(r'INSERT INTO "skrining_records" \(([^)]+)\)', caseSensitive: false).firstMatch(line);
      final valMatch = RegExp(r'VALUES\s*\((.*)\)\s*;', caseSensitive: false).firstMatch(line);
      if (colMatch == null || valMatch == null) continue;
      final cols = colMatch.group(1)!.split(',').map((c) => c.trim().replaceAll('"', '').toLowerCase()).toList();
      final vals = _splitSqlValues(valMatch.group(1)!);
      final map = <String, String>{};
      for (int i = 0; i < cols.length && i < vals.length; i++) {
        map[cols[i]] = vals[i].trim();
      }
      final oldPesertaId = int.tryParse(map['peserta_id'] ?? '0') ?? 0;
      final oldSkriningId = int.tryParse(map['id'] ?? '0') ?? 0;
      final nik = oldIdToNik[oldPesertaId];
      if (nik == null) continue;
      final newPesertaId = nikToId[nik];
      if (newPesertaId == null) continue;
      String unquote2(String v) {
        v = v.trim();
        if (v == 'NULL') return '';
        if (v.startsWith("'") && v.endsWith("'")) return v.substring(1, v.length - 1).replaceAll("''", "'");
        return v;
      }

      final tanggal = unquote2(map['tanggal'] ?? '');
      final kategori = unquote2(map['kategori'] ?? 'rendah');
      final rekomendasi = unquote2(map['rekomendasi'] ?? '');
      final skorStr = map['skor']?.trim() ?? 'NULL';
      final skor = skorStr == 'NULL' ? null : int.tryParse(skorStr);
      final isRedFlag = (map['is_red_flag']?.trim() ?? '0') == '1';
      try {
        final newId = await currentDb.into(currentDb.skriningRecords).insert(
              SkriningRecordsCompanion.insert(
                pesertaId: newPesertaId,
                tanggal: tanggal,
                skor: Value(skor),
                kategori: kategori,
                isRedFlag: Value(isRedFlag),
                rekomendasi: rekomendasi,
              ),
            );
        oldSkriningToNew[oldSkriningId] = newId;
      } catch (_) {}
    }
    for (final line in jawabanInserts) {
      final colMatch = RegExp(r'INSERT INTO "skrining_jawabans" \(([^)]+)\)', caseSensitive: false).firstMatch(line);
      final valMatch = RegExp(r'VALUES\s*\((.*)\)\s*;', caseSensitive: false).firstMatch(line);
      if (colMatch == null || valMatch == null) continue;
      final cols = colMatch.group(1)!.split(',').map((c) => c.trim().replaceAll('"', '').toLowerCase()).toList();
      final vals = _splitSqlValues(valMatch.group(1)!);
      final map = <String, String>{};
      for (int i = 0; i < cols.length && i < vals.length; i++) {
        map[cols[i]] = vals[i].trim();
      }
      final oldSkriningId = int.tryParse(map['skrining_id'] ?? '0') ?? 0;
      final newSkriningId = oldSkriningToNew[oldSkriningId];
      if (newSkriningId == null) continue;
      final nomor = int.tryParse(map['nomor'] ?? '0') ?? 0;
      final jawabanStr = map['jawaban']?.trim() ?? 'NULL';
      bool? jawaban;
      if (jawabanStr == '1') jawaban = true;
      if (jawabanStr == '0') jawaban = false;
      try {
        await currentDb.into(currentDb.skriningJawabans).insert(
              SkriningJawabansCompanion.insert(
                skriningId: newSkriningId,
                nomor: nomor,
                jawaban: Value(jawaban),
              ),
            );
      } catch (_) {}
    }
    return ImportResult(imported: imported, skipped: skipped, replaced: replaced, merged: merged);
  }

  static Future<ImportResult?> importSqlWithDialog(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Pilih File SQL',
      type: FileType.custom,
      allowedExtensions: ['sql'],
    );
    if (picked == null || picked.files.single.path == null) return null;
    final path = picked.files.single.path!;
    ImportPreview preview;
    try {
      preview = (await previewSqlImport(path))!;
    } catch (e) {
      throw Exception('Gagal membaca file SQL: $e');
    }
    if (!context.mounted) return null;
    ImportStrategy? strategy = ImportStrategy.skip;
    if (preview.duplicateCount > 0) {
      strategy = await showDialog<ImportStrategy>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Duplikat Ditemukan', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File berisi ${preview.totalInFile} peserta.'),
              const SizedBox(height: 8),
              Text('${preview.newCount} baru, ${preview.duplicateCount} duplikat (NIK sama).'),
              const SizedBox(height: 12),
              const Text('Pilih aksi untuk data duplikat:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('• Lewati: jangan import yang duplikat\n• Timpa: ganti data lama dengan data baru\n• Gabung: hanya isi field yang masih kosong'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            TextButton(onPressed: () => Navigator.pop(ctx, ImportStrategy.skip), child: const Text('Lewati')),
            TextButton(onPressed: () => Navigator.pop(ctx, ImportStrategy.merge), child: const Text('Gabung')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, ImportStrategy.replace), child: const Text('Timpa')),
          ],
        ),
      );
      if (strategy == null) return null;
    }
    return importSql(path, strategy);
  }
}
