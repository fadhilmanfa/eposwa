import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/features/pendaftaran/data/peserta_repository.dart';
import 'package:eposwa/features/skrining/data/skrining_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PesertaRepository pesertaRepo;
  late SkriningRepository skriningRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    setAppDatabaseForTesting(db);
    pesertaRepo = PesertaRepository(db);
    skriningRepo = SkriningRepository(db);
  });

  tearDown(() => db.close());

  Future<(int, int)> seedPesertaDenganSkrining() async {
    final pesertaId = await db
        .into(db.pesertas)
        .insert(
          PesertasCompanion.insert(
            kodePeserta: 'REG-2026-001',
            nama: 'Ahmad Fauzi',
            nik: '3201984712040001',
            noHp: '081234567890',
            tglDaftar: '10/09/2026',
          ),
        );
    final skriningId = await db
        .into(db.skriningRecords)
        .insert(
          SkriningRecordsCompanion.insert(
            pesertaId: pesertaId,
            tanggal: '10/09/2026',
            kategori: 'rendah',
            rekomendasi: 'pemantauan rutin',
          ),
        );
    await db
        .into(db.skriningJawabans)
        .insert(
          SkriningJawabansCompanion.insert(
            skriningId: skriningId,
            nomor: 1,
            jawaban: const Value(true),
          ),
        );
    return (pesertaId, skriningId);
  }

  test('foreign key aktif pada koneksi database', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data['foreign_keys'], 1);
  });

  test('hapus peserta ikut menghapus skrining dan jawabannya', () async {
    final (pesertaId, skriningId) = await seedPesertaDenganSkrining();

    expect(await skriningRepo.getAllWithPeserta(), hasLength(1));
    expect(await skriningRepo.getJawaban(skriningId), hasLength(1));

    await pesertaRepo.deletePeserta(pesertaId);

    expect(await skriningRepo.getAll(), isEmpty);
    expect(await skriningRepo.getAllWithPeserta(), isEmpty);
    expect(await skriningRepo.getJawaban(skriningId), isEmpty);
  });

  test('hapus skrining ikut menghapus jawabannya', () async {
    final (_, skriningId) = await seedPesertaDenganSkrining();

    expect(await skriningRepo.getJawaban(skriningId), hasLength(1));

    await skriningRepo.deleteSkrining(skriningId);

    expect(await skriningRepo.getJawaban(skriningId), isEmpty);
  });
}
