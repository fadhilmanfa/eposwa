import 'package:drift/drift.dart';
import 'package:eposwa/core/database/app_database.dart';

class PesertaRepository {
  final AppDatabase db;
  PesertaRepository(this.db);

  Future<List<Peserta>> getAll() {
    return (db.select(db.pesertas)..orderBy([
          (t) => OrderingTerm.desc(t.tglDaftar),
          (t) => OrderingTerm.desc(t.id),
        ]))
        .get();
  }

  Future<List<Peserta>> search(String query, String status) async {
    final q = query.trim().toLowerCase();
    final sel = db.select(db.pesertas);
    if (q.isNotEmpty) {
      sel.where(
        (t) =>
            t.nama.lower().like('%$q%') |
            t.noHp.like('%$q%') |
            t.nik.like('%$q%'),
      );
    }
    if (status != 'Semua') {
      sel.where((t) => t.status.equals(status));
    }
    sel.orderBy([
      (t) => OrderingTerm.desc(t.tglDaftar),
      (t) => OrderingTerm.desc(t.id),
    ]);
    return sel.get();
  }

  Future<Peserta?> getById(int id) {
    return (db.select(
      db.pesertas,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Peserta?> getByNik(String nik) {
    return (db.select(
      db.pesertas,
    )..where((t) => t.nik.equals(nik.trim()))).getSingleOrNull();
  }

  Future<Peserta?> getByNama(String nama) {
    final q = nama.trim().toLowerCase();
    return (db.select(
      db.pesertas,
    )..where((t) => t.nama.lower().equals(q))).getSingleOrNull();
  }

  Future<String> _generateKode() async {
    final year = DateTime.now().year;
    final prefix = 'REG-$year-';
    final count = await (db.selectOnly(
      db.pesertas,
    )..addColumns([db.pesertas.id.count()])).getSingle();
    final total = count.read(db.pesertas.id.count()) ?? 0;
    // find max existing kode for this year to avoid collision after deletes
    final existing = await (db.select(
      db.pesertas,
    )..where((t) => t.kodePeserta.like('$prefix%'))).get();
    int maxNum = 0;
    for (final p in existing) {
      final suffix = p.kodePeserta.replaceFirst(prefix, '');
      final n = int.tryParse(suffix) ?? 0;
      if (n > maxNum) maxNum = n;
    }
    final next = maxNum + 1;
    // also ensure > total
    final candidate = next > total ? next : total + 1;
    return '$prefix${candidate.toString().padLeft(3, '0')}';
  }

  Future<int> insertPeserta({
    required String nama,
    required String nik,
    required String noHp,
    String jenisKelamin = 'Laki-laki',
    String? tglLahir,
    String? alamat,
    String program = '-',
    bool? pernahKonsultasi,
    bool? pernahDapatObat,
    String? tglKunjungan,
    String? jamKunjungan,
    String status = 'Terdaftar',
    String? tglDaftar,
    int? createdBy,
  }) async {
    final kode = await _generateKode();
    final now = DateTime.now();
    final tglDaftarVal =
        tglDaftar ??
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return db
        .into(db.pesertas)
        .insert(
          PesertasCompanion.insert(
            kodePeserta: kode,
            nama: nama.trim(),
            nik: nik.trim(),
            jenisKelamin: Value(jenisKelamin),
            tglLahir: Value(tglLahir),
            alamat: Value(alamat),
            noHp: noHp.trim(),
            program: Value(program),
            pernahKonsultasi: Value(pernahKonsultasi),
            pernahDapatObat: Value(pernahDapatObat),
            tglKunjungan: Value(tglKunjungan),
            jamKunjungan: Value(jamKunjungan),
            status: Value(status),
            tglDaftar: tglDaftarVal,
            createdBy: Value(createdBy),
          ),
        );
  }

  Future<bool> updatePeserta(PesertasCompanion data, int id) async {
    final count = await (db.update(db.pesertas)..where((t) => t.id.equals(id)))
        .write(data.copyWith(updatedAt: Value(DateTime.now())));
    return count > 0;
  }

  Future<int> deletePeserta(int id) {
    return (db.delete(db.pesertas)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Peserta>> watchAll() {
    return (db.select(
      db.pesertas,
    )..orderBy([(t) => OrderingTerm.desc(t.tglDaftar)])).watch();
  }
}
