import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/services/export_service.dart';
import 'package:eposwa/core/services/import_service.dart';
import 'package:flutter_test/flutter_test.dart';

Future<int> _insertPeserta(
  AppDatabase db, {
  required String kode,
  required String nama,
  required String nik,
}) {
  return db
      .into(db.pesertas)
      .insert(
        PesertasCompanion.insert(
          kodePeserta: kode,
          nama: nama,
          nik: nik,
          noHp: '081234567890',
          tglDaftar: '10/09/2026',
        ),
      );
}

Future<int> _insertSkrining(
  AppDatabase db, {
  required int pesertaId,
  required String tanggal,
  required String kategori,
}) {
  return db
      .into(db.skriningRecords)
      .insert(
        SkriningRecordsCompanion.insert(
          pesertaId: pesertaId,
          tanggal: tanggal,
          skor: const Value(4),
          kategori: kategori,
          rekomendasi: 'Rujuk ke Perawat Jiwa <CMHN> & jadwalkan konseling',
        ),
      );
}

void main() {
  test('export → import: hanya peserta terpilih, konflik diganti', () async {
    // ── Sumber: database berisi 2 peserta beserta skrining & jawabannya ──
    final sumber = AppDatabase.forTesting(NativeDatabase.memory());
    setAppDatabaseForTesting(sumber);

    final idAndi = await _insertPeserta(
      sumber,
      kode: 'REG-2026-001',
      nama: 'Andi',
      nik: '111',
    );
    final idBudi = await _insertPeserta(
      sumber,
      kode: 'REG-2026-002',
      nama: 'Budi',
      nik: '222',
    );
    final skriningAndi = await _insertSkrining(
      sumber,
      pesertaId: idAndi,
      tanggal: '10/09/2026',
      kategori: 'sedang',
    );
    await _insertSkrining(
      sumber,
      pesertaId: idBudi,
      tanggal: '11/09/2026',
      kategori: 'rendah',
    );
    await sumber
        .into(sumber.skriningJawabans)
        .insert(
          SkriningJawabansCompanion.insert(
            skriningId: skriningAndi,
            nomor: 1,
            jawaban: const Value(true),
          ),
        );

    final sql = await ExportService.exportSqlToString();
    await sumber.close();

    // ── Tujuan: database baru yang sudah punya 'Andi' dengan data berbeda ──
    final tujuan = AppDatabase.forTesting(NativeDatabase.memory());
    setAppDatabaseForTesting(tujuan);

    final idAndiLama = await _insertPeserta(
      tujuan,
      kode: 'REG-LAMA',
      nama: 'Andi Lama',
      nik: '111',
    );
    await _insertSkrining(
      tujuan,
      pesertaId: idAndiLama,
      tanggal: '01/01/2026',
      kategori: 'tinggi',
    );

    final candidates = await ImportService.listCandidates(sql);
    expect(candidates, hasLength(2));
    expect(candidates[0].nik, '111');
    expect(candidates[0].nama, 'Andi');
    expect(candidates[0].isExisting, isTrue);
    expect(candidates[0].skriningCount, 1);
    expect(candidates[1].nik, '222');
    expect(candidates[1].isExisting, isFalse);
    expect(candidates[1].skriningCount, 1);

    final result = await ImportService.importSqlFromContent(
      sql,
      ImportStrategy.skip,
      onlyNiks: {'111', '222'},
      strategiesByNik: {'111': ImportStrategy.replace},
    );

    expect(result.replaced, 1);
    expect(result.imported, 1);

    final pesertas = await tujuan.select(tujuan.pesertas).get();
    expect(pesertas.map((p) => p.nik).toSet(), {'111', '222'});
    final andi = pesertas.firstWhere((p) => p.nik == '111');
    expect(andi.nama, 'Andi');
    expect(andi.kodePeserta, 'REG-LAMA');

    // Skrining Andi yang lama sudah digantikan skrining dari file.
    final skrining = await tujuan.select(tujuan.skriningRecords).get();
    expect(skrining, hasLength(2));
    expect(
      skrining.where((s) => s.pesertaId == andi.id).single.kategori,
      'sedang',
    );
    expect(skrining.where((s) => s.pesertaId == andi.id).single.rekomendasi,
        contains('<CMHN>'));

    final jawaban = await tujuan.select(tujuan.skriningJawabans).get();
    expect(jawaban, hasLength(1));

    await tujuan.close();
  });
}
