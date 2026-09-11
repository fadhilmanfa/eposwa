import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/services/import_service.dart';
import 'package:flutter_test/flutter_test.dart';

String _q(String? value) =>
    value == null ? 'NULL' : "'${value.replaceAll("'", "''")}'";

String _pesertaRow({
  required int id,
  required String kode,
  required String nama,
  required String nik,
  String? alamat,
  String noHp = '081234567890',
}) {
  return 'INSERT INTO "pesertas" ("id", "kode_peserta", "nama", "nik", '
      '"jenis_kelamin", "tgl_lahir", "alamat", "no_hp", "program", '
      '"pernah_konsultasi", "pernah_dapat_obat", "status", "tgl_daftar") '
      "VALUES ($id, ${_q(kode)}, ${_q(nama)}, ${_q(nik)}, 'Laki-laki', NULL, "
      "${_q(alamat)}, ${_q(noHp)}, 'Regular Pagi', NULL, NULL, 'Terdaftar', "
      "'10/09/2026');";
}

String _skriningRow({
  required int id,
  required int pesertaId,
  required String tanggal,
  String kategori = 'rendah',
}) {
  return 'INSERT INTO "skrining_records" ("id", "peserta_id", "tanggal", "skor", '
      '"kategori", "is_red_flag", "rekomendasi") '
      "VALUES ($id, $pesertaId, '$tanggal', 3, '$kategori', 0, 'pemantauan rutin');";
}

String _jawabanRow({
  required int id,
  required int skriningId,
  required int nomor,
}) {
  return 'INSERT INTO "skrining_jawabans" ("id", "skrining_id", "nomor", "jawaban") '
      'VALUES ($id, $skriningId, $nomor, 1);';
}

String _dump(List<String> statements) =>
    '-- eposwa SQL Dump\nBEGIN TRANSACTION;\n${statements.join('\n')}\nCOMMIT;\n';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    setAppDatabaseForTesting(db);
  });

  tearDown(() => db.close());

  Future<int> insertExistingPeserta({
    required String nik,
    required String nama,
    String? alamat,
  }) {
    return db
        .into(db.pesertas)
        .insert(
          PesertasCompanion.insert(
            kodePeserta: 'REG-LAMA-$nik',
            nama: nama,
            nik: nik,
            noHp: '0800000000',
            alamat: Value(alamat),
            tglDaftar: '01/01/2026',
          ),
        );
  }

  Future<void> insertExistingSkrining(int pesertaId, String rekomendasi) async {
    await db
        .into(db.skriningRecords)
        .insert(
          SkriningRecordsCompanion.insert(
            pesertaId: pesertaId,
            tanggal: '01/01/2026',
            kategori: 'rendah',
            rekomendasi: rekomendasi,
          ),
        );
  }

  test('listCandidates menandai konflik dan menghitung skrining', () async {
    await insertExistingPeserta(nik: '111', nama: 'Lama');
    final content = _dump([
      _pesertaRow(id: 1, kode: 'REG-A', nama: 'Lama', nik: '111'),
      _pesertaRow(id: 2, kode: 'REG-B', nama: 'Baru', nik: '222'),
      _skriningRow(id: 1, pesertaId: 2, tanggal: '10/09/2026'),
      _skriningRow(id: 2, pesertaId: 2, tanggal: '11/09/2026'),
    ]);

    final candidates = await ImportService.listCandidates(content);

    expect(candidates, hasLength(2));
    expect(candidates[0].nik, '111');
    expect(candidates[0].nama, 'Lama');
    expect(candidates[0].isExisting, isTrue);
    expect(candidates[0].skriningCount, 0);
    expect(candidates[1].nik, '222');
    expect(candidates[1].nama, 'Baru');
    expect(candidates[1].isExisting, isFalse);
    expect(candidates[1].skriningCount, 2);
  });

  test('hanya peserta terpilih yang di-import', () async {
    final content = _dump([
      _pesertaRow(id: 1, kode: 'REG-A', nama: 'Satu', nik: '111'),
      _pesertaRow(id: 2, kode: 'REG-B', nama: 'Dua', nik: '222'),
      _skriningRow(id: 1, pesertaId: 1, tanggal: '10/09/2026'),
      _skriningRow(id: 2, pesertaId: 2, tanggal: '10/09/2026'),
      _jawabanRow(id: 1, skriningId: 2, nomor: 1),
    ]);

    final result = await ImportService.importSqlFromContent(
      content,
      ImportStrategy.skip,
      onlyNiks: {'222'},
    );

    expect(result.imported, 1);
    final pesertas = await db.select(db.pesertas).get();
    expect(pesertas.map((p) => p.nik), ['222']);
    expect(await db.select(db.skriningRecords).get(), hasLength(1));
    expect(await db.select(db.skriningJawabans).get(), hasLength(1));
  });

  test('Tolak: peserta lama tidak berubah dan skrining tidak dobel', () async {
    final id = await insertExistingPeserta(nik: '111', nama: 'Lama');
    await insertExistingSkrining(id, 'skrining lama');

    final content = _dump([
      _pesertaRow(id: 1, kode: 'REG-A', nama: 'Baru', nik: '111', noHp: '089999'),
      _skriningRow(id: 1, pesertaId: 1, tanggal: '10/09/2026'),
    ]);

    final result = await ImportService.importSqlFromContent(
      content,
      ImportStrategy.skip,
      strategiesByNik: {'111': ImportStrategy.skip},
      onlyNiks: {'111'},
    );

    expect(result.skipped, 1);
    expect(result.imported, 0);
    final peserta = (await db.select(db.pesertas).get()).single;
    expect(peserta.nama, 'Lama');
    expect(peserta.noHp, '0800000000');

    final skrining = await db.select(db.skriningRecords).get();
    expect(skrining, hasLength(1));
    expect(skrining.single.rekomendasi, 'skrining lama');
  });

  test('Gabung: hanya field yang kosong diisi dari file', () async {
    await insertExistingPeserta(nik: '111', nama: 'Lama');

    final content = _dump([
      _pesertaRow(
        id: 1,
        kode: 'REG-A',
        nama: 'Baru',
        nik: '111',
        alamat: 'Jl. Baru',
        noHp: '089999',
      ),
    ]);

    final result = await ImportService.importSqlFromContent(
      content,
      ImportStrategy.skip,
      strategiesByNik: {'111': ImportStrategy.merge},
      onlyNiks: {'111'},
    );

    expect(result.merged, 1);
    final peserta = (await db.select(db.pesertas).get()).single;
    expect(peserta.nama, 'Lama');
    expect(peserta.noHp, '0800000000');
    expect(peserta.alamat, 'Jl. Baru');
  });

  test('Ganti: data peserta ditimpa dan skrining lama digantikan', () async {
    final id = await insertExistingPeserta(
      nik: '111',
      nama: 'Lama',
      alamat: 'Jl. Lama',
    );
    await insertExistingSkrining(id, 'skrining lama');
    final oldSkriningId = (await db.select(db.skriningRecords).get()).single.id;
    await db
        .into(db.skriningJawabans)
        .insert(
          SkriningJawabansCompanion.insert(
            skriningId: oldSkriningId,
            nomor: 1,
            jawaban: const Value(true),
          ),
        );

    final content = _dump([
      _pesertaRow(
        id: 1,
        kode: 'REG-A',
        nama: 'Baru',
        nik: '111',
        alamat: 'Jl. Baru',
        noHp: '089999',
      ),
      _skriningRow(
        id: 5,
        pesertaId: 1,
        tanggal: '10/09/2026',
        kategori: 'tinggi',
      ),
    ]);

    final result = await ImportService.importSqlFromContent(
      content,
      ImportStrategy.skip,
      strategiesByNik: {'111': ImportStrategy.replace},
      onlyNiks: {'111'},
    );

    expect(result.replaced, 1);
    final peserta = (await db.select(db.pesertas).get()).single;
    expect(peserta.nama, 'Baru');
    expect(peserta.alamat, 'Jl. Baru');
    expect(peserta.noHp, '089999');

    final skrining = await db.select(db.skriningRecords).get();
    expect(skrining, hasLength(1));
    expect(skrining.single.kategori, 'tinggi');
    expect(await db.select(db.skriningJawabans).get(), isEmpty);
  });
}
