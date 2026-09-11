import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/widgets/import_dialogs.dart';

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

/// Satu peserta yang ada di dalam file SQL yang akan di-import.
class ImportCandidate {
  final String nik;
  final String nama;
  final String kodePeserta;

  /// true bila NIK-nya sudah terdaftar di database lokal (perlu konfirmasi).
  final bool isExisting;

  /// Jumlah skrining milik peserta ini yang ada di dalam file.
  final int skriningCount;

  const ImportCandidate({
    required this.nik,
    required this.nama,
    required this.kodePeserta,
    required this.isExisting,
    required this.skriningCount,
  });
}

class ImportService {
  /// Parsing SQL dump menjadi tabel → daftar baris (map kolom → nilai mentah).
  /// Dipakai untuk preview isi tabel yang diterima lewat berbagi instan.
  static Map<String, List<Map<String, String>>> parseSqlTables(
    String content,
  ) {
    final result = <String, List<Map<String, String>>>{};
    const tables = ['admins', 'pesertas', 'skrining_records', 'skrining_jawabans'];
    for (final table in tables) {
      result[table] = [];
    }
    for (final line in content.split('\n')) {
      final tableMatch = RegExp(
        r'INSERT INTO "(\w+)" \(([^)]+)\)\s*VALUES\s*\((.*)\)\s*;',
        caseSensitive: false,
      ).firstMatch(line);
      if (tableMatch == null) continue;
      final table = tableMatch.group(1)!.toLowerCase();
      if (!result.containsKey(table)) continue;
      final cols = tableMatch
          .group(2)!
          .split(',')
          .map((c) => c.trim().replaceAll('"', ''))
          .toList();
      final vals = _splitSqlValues(tableMatch.group(3)!);
      final row = <String, String>{};
      for (int i = 0; i < cols.length && i < vals.length; i++) {
        row[cols[i]] = vals[i].trim();
      }
      result[table]!.add(row);
    }
    return result;
  }

  /// Preview duplikat NIK dari konten SQL (tanpa file).
  static Future<ImportPreview?> previewSqlFromContent(String content) async {
    final pesertaInserts = RegExp(r'INSERT INTO "pesertas"', caseSensitive: false).allMatches(content).length;
    final currentDb = getAppDatabase();
    final currentPesertas = await currentDb.select(currentDb.pesertas).get();
    final currentNikSet = currentPesertas.map((e) => e.nik).toSet();
    int dup = 0;
    final dupNiks = <String>[];
    final lines = content.split('\n');
    for (final line in lines) {
      final parsed = _parseInsert(line);
      if (parsed == null || parsed.table != 'pesertas') continue;
      final nik = _unquote(_rowOf(parsed)['nik']);
      if (nik.isEmpty) continue;
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

  /// Membaca satu baris `INSERT INTO "tabel" (kolom...) VALUES (...);`.
  static ({String table, List<String> cols, List<String> vals})? _parseInsert(
    String line,
  ) {
    final match = RegExp(
      r'INSERT INTO "(\w+)"\s*\(([^)]+)\)\s*VALUES\s*\((.*)\)\s*;',
      caseSensitive: false,
    ).firstMatch(line);
    if (match == null) return null;
    return (
      table: match.group(1)!.toLowerCase(),
      cols: match
          .group(2)!
          .split(',')
          .map((c) => c.trim().replaceAll('"', '').toLowerCase())
          .toList(),
      vals: _splitSqlValues(match.group(3)!),
    );
  }

  /// Membuang kutip SQL; `NULL` menjadi string kosong.
  static String _unquote(String? raw) {
    final value = (raw ?? '').trim();
    if (value == 'NULL') return '';
    if (value.length >= 2 && value.startsWith("'") && value.endsWith("'")) {
      return value.substring(1, value.length - 1).replaceAll("''", "'");
    }
    return value;
  }

  /// Menyusun map kolom → nilai mentah dari satu baris INSERT.
  static Map<String, String> _rowOf(
    ({String table, List<String> cols, List<String> vals}) parsed,
  ) {
    final map = <String, String>{};
    for (var i = 0; i < parsed.cols.length && i < parsed.vals.length; i++) {
      map[parsed.cols[i]] = parsed.vals[i].trim();
    }
    return map;
  }

  /// Mendaftar peserta yang ada di dalam file SQL beserta status konfliknya.
  /// Dipakai untuk modal pemilihan user sebelum import dijalankan.
  static Future<List<ImportCandidate>> listCandidates(String content) async {
    final db = getAppDatabase();
    final existingNiks = (await db.select(db.pesertas).get())
        .map((p) => p.nik)
        .toSet();

    final rows = <({int oldId, String nik, String nama, String kode})>[];
    final skriningPerOldId = <int, int>{};

    for (final line in content.split('\n')) {
      final parsed = _parseInsert(line);
      if (parsed == null) continue;
      final map = _rowOf(parsed);
      if (parsed.table == 'pesertas') {
        final nik = _unquote(map['nik']);
        if (nik.isEmpty) continue;
        rows.add((
          oldId: int.tryParse(map['id'] ?? '') ?? 0,
          nik: nik,
          nama: _unquote(map['nama']),
          kode: _unquote(map['kode_peserta']),
        ));
      } else if (parsed.table == 'skrining_records') {
        final oldPesertaId = int.tryParse(map['peserta_id'] ?? '') ?? 0;
        skriningPerOldId[oldPesertaId] =
            (skriningPerOldId[oldPesertaId] ?? 0) + 1;
      }
    }

    return [
      for (final row in rows)
        ImportCandidate(
          nik: row.nik,
          nama: row.nama,
          kodePeserta: row.kode,
          isExisting: existingNiks.contains(row.nik),
          skriningCount: skriningPerOldId[row.oldId] ?? 0,
        ),
    ];
  }

  /// Import dari konten SQL langsung (dipakai untuk data yang diterima
  /// lewat berbagi instan). Peserta NIK baru ditambahkan sebagai baris baru.
  ///
  /// [onlyNiks] membatasi peserta yang diproses (null = semua); NIK di luar
  /// daftar itu beserta skriningnya tidak disentuh sama sekali.
  /// [strategiesByNik] menentukan aksi untuk peserta yang NIK-nya sudah ada;
  /// NIK yang tidak tercantum memakai [strategy].
  static Future<ImportResult> importSqlFromContent(
    String content,
    ImportStrategy strategy, {
    Map<String, ImportStrategy>? strategiesByNik,
    Set<String>? onlyNiks,
  }) async {
    final currentDb = getAppDatabase();
    int imported = 0, skipped = 0, replaced = 0, merged = 0;
    final lines = content.split('\n');
    final createStatements = <String>[];
    final pesertaInserts = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('--') || trimmed.startsWith('PRAGMA') || trimmed.startsWith('BEGIN') || trimmed.startsWith('COMMIT')) continue;
      if (trimmed.toUpperCase().contains('CREATE TABLE')) {
        createStatements.add(line);
      } else if (trimmed.toUpperCase().contains('INSERT INTO "PESERTAS"')) {
        pesertaInserts.add(line);
      }
    }
    for (final stmt in createStatements) {
      try {
        await currentDb.customStatement(stmt);
      } catch (_) {}
    }
    final Map<String, int> nikToId = {};
    final existingPesertas = await currentDb.select(currentDb.pesertas).get();
    for (final p in existingPesertas) {
      nikToId[p.nik] = p.id;
    }
    // NIK yang datanya benar-benar diterima. Skrining dari file hanya
    // dimasukkan untuk NIK di sini, supaya tidak menempel ke user yang
    // ditolak (dulu bisa membuat skrining dobel).
    final acceptedNiks = <String>{};
    for (final line in pesertaInserts) {
      final parsed = _parseInsert(line);
      if (parsed == null) continue;
      final cols = parsed.cols;
      final map = _rowOf(parsed);

      final nik = _unquote(map['nik']);
      if (nik.isEmpty) continue;
      if (onlyNiks != null && !onlyNiks.contains(nik)) continue;

      final existingId = nikToId[nik];
      if (existingId != null) {
        final action = strategiesByNik?[nik] ?? strategy;
        if (action == ImportStrategy.skip) {
          skipped++;
          continue;
        } else if (action == ImportStrategy.replace) {
          final existing = await (currentDb.select(currentDb.pesertas)..where((t) => t.id.equals(existingId))).getSingleOrNull();
          if (existing != null) {
            // Ganti: skrining lama dibuang, digantikan skrining dari file.
            await (currentDb.delete(currentDb.skriningRecords)
                  ..where((t) => t.pesertaId.equals(existingId)))
                .go();
            String pick(String key, String fallback) {
              final value = _unquote(map[key]);
              return value.isEmpty ? fallback : value;
            }

            await (currentDb.update(currentDb.pesertas)..where((t) => t.id.equals(existingId))).write(
              PesertasCompanion(
                nama: Value(pick('nama', existing.nama)),
                jenisKelamin: Value(pick('jenis_kelamin', existing.jenisKelamin)),
                tglLahir: Value(_unquote(map['tgl_lahir'])),
                alamat: Value(_unquote(map['alamat'])),
                noHp: Value(pick('no_hp', existing.noHp)),
                program: Value(pick('program', existing.program)),
                status: Value(pick('status', existing.status)),
                updatedAt: Value(DateTime.now()),
              ),
            );
            acceptedNiks.add(nik);
          }
          replaced++;
        } else if (action == ImportStrategy.merge) {
          final existing = await (currentDb.select(currentDb.pesertas)..where((t) => t.id.equals(existingId))).getSingleOrNull();
          if (existing != null) {
            await (currentDb.update(currentDb.pesertas)..where((t) => t.id.equals(existingId))).write(
              PesertasCompanion(
                alamat: (existing.alamat == null || existing.alamat!.isEmpty) ? Value(_unquote(map['alamat'])) : const Value.absent(),
                noHp: existing.noHp.isEmpty ? Value(_unquote(map['no_hp'])) : const Value.absent(),
                tglLahir: existing.tglLahir == null ? Value(_unquote(map['tgl_lahir'])) : const Value.absent(),
                updatedAt: Value(DateTime.now()),
              ),
            );
            acceptedNiks.add(nik);
          }
          merged++;
        }
      } else {
        try {
          await currentDb.customStatement(line);
          final inserted = await (currentDb.select(currentDb.pesertas)..where((t) => t.nik.equals(nik))).getSingleOrNull();
          if (inserted != null) nikToId[nik] = inserted.id;
          imported++;
          acceptedNiks.add(nik);
        } catch (_) {
          try {
            final kode = map['kode_peserta'] != null ? _unquote(map['kode_peserta']) : 'REG-${DateTime.now().year}-${nikToId.length + 1}';
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
            acceptedNiks.add(nik);
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
      final parsed = _parseInsert(line);
      if (parsed == null) continue;
      final map = _rowOf(parsed);
      final id = int.tryParse(map['id'] ?? '') ?? 0;
      final nik = _unquote(map['nik']);
      if (nik.isEmpty) continue;
      oldIdToNik[id] = nik;
    }
    final oldSkriningToNew = <int, int>{};
    for (final line in skriningInserts) {
      final parsed = _parseInsert(line);
      if (parsed == null) continue;
      final map = _rowOf(parsed);
      final oldPesertaId = int.tryParse(map['peserta_id'] ?? '0') ?? 0;
      final oldSkriningId = int.tryParse(map['id'] ?? '0') ?? 0;
      final nik = oldIdToNik[oldPesertaId];
      if (nik == null) continue;
      if (!acceptedNiks.contains(nik)) continue;
      final newPesertaId = nikToId[nik];
      if (newPesertaId == null) continue;

      final tanggal = _unquote(map['tanggal']);
      final kategoriRaw = _unquote(map['kategori']);
      final kategori = kategoriRaw.isEmpty ? 'rendah' : kategoriRaw;
      final rekomendasi = _unquote(map['rekomendasi']);
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
      final parsed = _parseInsert(line);
      if (parsed == null) continue;
      final map = _rowOf(parsed);
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

    final String content;
    try {
      content = await File(picked.files.single.path!).readAsString();
    } catch (e) {
      throw Exception('Gagal membaca file SQL: $e');
    }

    final candidates = await listCandidates(content);
    if (!context.mounted) return null;
    if (candidates.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Tidak Ada Data', style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text('File ini tidak berisi data peserta untuk di-import.'),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          ],
        ),
      );
      return null;
    }

    final selected = await showImportCandidatesDialog(context, candidates);
    if (selected == null || selected.isEmpty || !context.mounted) return null;

    final conflicts = candidates
        .where((c) => c.isExisting && selected.contains(c.nik))
        .toList();
    Map<String, ImportStrategy>? strategies;
    if (conflicts.isNotEmpty) {
      strategies = await showImportConflictDialog(context, conflicts);
      if (strategies == null || !context.mounted) return null;
    }

    // Peserta yang tidak dicentang tidak disentuh sama sekali.
    return importSqlFromContent(
      content,
      ImportStrategy.skip,
      strategiesByNik: strategies,
      onlyNiks: selected,
    );
  }
}
