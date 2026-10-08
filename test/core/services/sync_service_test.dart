import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/services/export_service.dart';
import 'package:eposwa/core/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

Future<int> _insertPeserta(
  AppDatabase db, {
  required String kode,
  required String nama,
  required String nik,
  String? alamat,
}) {
  return db
      .into(db.pesertas)
      .insert(
        PesertasCompanion.insert(
          kodePeserta: kode,
          nama: nama,
          nik: nik,
          noHp: '081234567890',
          alamat: Value(alamat),
          tglDaftar: '10/09/2026',
        ),
      );
}

Future<int> _insertSkrining(
  AppDatabase db, {
  required int pesertaId,
  required String tanggal,
  String kategori = 'rendah',
}) {
  return db
      .into(db.skriningRecords)
      .insert(
        SkriningRecordsCompanion.insert(
          pesertaId: pesertaId,
          tanggal: tanggal,
          kategori: kategori,
          rekomendasi: 'pemantauan rutin',
        ),
      );
}

void main() {
  test('sinkron dua-arah: union identik, data kecil & besar saling melengkapi',
      () async {
    // Laptop A: 1 peserta + 1 skrining.
    final dbA = AppDatabase.forTesting(NativeDatabase.memory());
    setAppDatabaseForTesting(dbA);
    final idA = await _insertPeserta(
      dbA,
      kode: 'REG-A1',
      nama: 'Andi',
      nik: '111',
    );
    await _insertSkrining(dbA, pesertaId: idA, tanggal: '02/01/2026');
    final dumpA = await ExportService.exportSqlToString();

    // Laptop B: 3 peserta (satu NIK sama, alamat hanya di B) tanpa skrining.
    final dbB = AppDatabase.forTesting(NativeDatabase.memory());
    setAppDatabaseForTesting(dbB);
    for (final (kode, nama, nik) in [
      ('REG-B1', 'Budi', '222'),
      ('REG-B2', 'Cici', '333'),
      ('REG-B3', 'Andi B', '111'),
    ]) {
      await _insertPeserta(
        dbB,
        kode: kode,
        nama: nama,
        nik: nik,
        alamat: 'Jl. B',
      );
    }
    final dumpB = await ExportService.exportSqlToString();

    // Tukar dua arah seperti opcode 0x03 (kedua sisi union-merge).
    setAppDatabaseForTesting(dbA);
    final appliedA = await SyncService.instance.applyPeerSql(dumpB);
    setAppDatabaseForTesting(dbB);
    final appliedB = await SyncService.instance.applyPeerSql(dumpA);

    // A menerima 2 peserta baru + 1 gabung; B menerima 0 baru (skrining
    // menempel ke NIK 111 yang sudah ada).
    expect(appliedA.imported, 2);
    expect(appliedA.merged, 1);
    expect(appliedB.imported, 0);

    setAppDatabaseForTesting(dbA);
    final niksA =
        (await dbA.select(dbA.pesertas).get()).map((p) => p.nik).toSet();
    setAppDatabaseForTesting(dbB);
    final niksB =
        (await dbB.select(dbB.pesertas).get()).map((p) => p.nik).toSet();
    expect(niksA, {'111', '222', '333'});
    expect(niksB, {'111', '222', '333'});

    // NIK sama: nama lokal dipertahankan, field kosong diisi dari peer.
    setAppDatabaseForTesting(dbA);
    final andiA = (await (dbA.select(
      dbA.pesertas,
    )..where((t) => t.nik.equals('111'))).get()).single;
    expect(andiA.nama, 'Andi');
    expect(andiA.alamat, 'Jl. B');

    // Skrining A tidak hilang dan ikut ada di B.
    setAppDatabaseForTesting(dbB);
    final skrB = await dbB.select(dbB.skriningRecords).get();
    expect(skrB, hasLength(1));

    await dbA.close();
    await dbB.close();
  });

  test('sinkron berulang idempoten: tidak menggandakan skrining', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    setAppDatabaseForTesting(db);
    final id = await _insertPeserta(
      db,
      kode: 'REG-A1',
      nama: 'Andi',
      nik: '111',
    );
    await _insertSkrining(db, pesertaId: id, tanggal: '02/01/2026');
    final dump = await ExportService.exportSqlToString();

    final first = await SyncService.instance.applyPeerSql(dump);
    final second = await SyncService.instance.applyPeerSql(dump);

    expect(first.skriningSkipped, 1);
    expect(second.skriningSkipped, 1);
    expect(second.skriningAdded, 0);
    expect(await db.select(db.pesertas).get(), hasLength(1));
    expect(await db.select(db.skriningRecords).get(), hasLength(1));

    await db.close();
  });
}
