import 'package:drift/drift.dart';
import 'package:eposwa/core/database/app_database.dart';

class SkriningWithPeserta {
  final SkriningRecord skrining;
  final Peserta peserta;
  SkriningWithPeserta(this.skrining, this.peserta);
}

class SkriningRepository {
  final AppDatabase db;
  SkriningRepository(this.db);

  Future<int> insertSkrining({
    required int pesertaId,
    required String tanggal,
    required int? skor,
    required String kategori,
    required bool isRedFlag,
    required String rekomendasi,
    required List<bool?> jawaban, // length 10
    int? createdBy,
  }) async {
    return db.transaction(() async {
      final skriningId = await db
          .into(db.skriningRecords)
          .insert(
            SkriningRecordsCompanion.insert(
              pesertaId: pesertaId,
              tanggal: tanggal,
              skor: Value(skor),
              kategori: kategori,
              isRedFlag: Value(isRedFlag),
              rekomendasi: rekomendasi,
              createdBy: Value(createdBy),
            ),
          );
      for (var i = 0; i < jawaban.length; i++) {
        await db
            .into(db.skriningJawabans)
            .insert(
              SkriningJawabansCompanion.insert(
                skriningId: skriningId,
                nomor: i + 1,
                jawaban: Value(jawaban[i]),
              ),
            );
      }
      // pad to 10 if needed
      for (var i = jawaban.length; i < 10; i++) {
        await db
            .into(db.skriningJawabans)
            .insert(
              SkriningJawabansCompanion.insert(
                skriningId: skriningId,
                nomor: i + 1,
                jawaban: const Value(null),
              ),
            );
      }
      return skriningId;
    });
  }

  Future<bool> updateSkrining({
    required int skriningId,
    String? tanggal,
    int? skor,
    String? kategori,
    bool? isRedFlag,
    String? rekomendasi,
    List<bool?>? jawaban,
  }) async {
    return db.transaction(() async {
      if (tanggal != null ||
          skor != null ||
          kategori != null ||
          isRedFlag != null ||
          rekomendasi != null) {
        await (db.update(
          db.skriningRecords,
        )..where((t) => t.id.equals(skriningId))).write(
          SkriningRecordsCompanion(
            tanggal: tanggal != null ? Value(tanggal) : const Value.absent(),
            skor: skor != null ? Value(skor) : const Value.absent(),
            kategori: kategori != null ? Value(kategori) : const Value.absent(),
            isRedFlag: isRedFlag != null
                ? Value(isRedFlag)
                : const Value.absent(),
            rekomendasi: rekomendasi != null
                ? Value(rekomendasi)
                : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      if (jawaban != null) {
        for (var i = 0; i < jawaban.length && i < 10; i++) {
          final existing =
              await (db.select(db.skriningJawabans)..where(
                    (t) =>
                        t.skriningId.equals(skriningId) & t.nomor.equals(i + 1),
                  ))
                  .getSingleOrNull();
          if (existing != null) {
            await (db.update(db.skriningJawabans)
                  ..where((t) => t.id.equals(existing.id)))
                .write(SkriningJawabansCompanion(jawaban: Value(jawaban[i])));
          } else {
            await db
                .into(db.skriningJawabans)
                .insert(
                  SkriningJawabansCompanion.insert(
                    skriningId: skriningId,
                    nomor: i + 1,
                    jawaban: Value(jawaban[i]),
                  ),
                );
          }
        }
      }
      return true;
    });
  }

  Future<List<SkriningRecord>> getAll() {
    return (db.select(db.skriningRecords)..orderBy([
          (t) => OrderingTerm.desc(t.tanggal),
          (t) => OrderingTerm.desc(t.id),
        ]))
        .get();
  }

  Future<List<SkriningWithPeserta>> getAllWithPeserta() async {
    final query =
        db.select(db.skriningRecords).join([
          innerJoin(
            db.pesertas,
            db.pesertas.id.equalsExp(db.skriningRecords.pesertaId),
          ),
        ])..orderBy([
          OrderingTerm.desc(db.skriningRecords.tanggal),
          OrderingTerm.desc(db.skriningRecords.id),
        ]);
    final rows = await query.get();
    return rows.map((r) {
      return SkriningWithPeserta(
        r.readTable(db.skriningRecords),
        r.readTable(db.pesertas),
      );
    }).toList();
  }

  Future<List<SkriningRecord>> getByPesertaId(int pesertaId) {
    return (db.select(db.skriningRecords)
          ..where((t) => t.pesertaId.equals(pesertaId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.tanggal),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<List<SkriningJawaban>> getJawaban(int skriningId) {
    return (db.select(db.skriningJawabans)
          ..where((t) => t.skriningId.equals(skriningId))
          ..orderBy([(t) => OrderingTerm.asc(t.nomor)]))
        .get();
  }

  Future<SkriningRecord?> getById(int id) {
    return (db.select(
      db.skriningRecords,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> deleteSkrining(int id) {
    return (db.delete(db.skriningRecords)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<SkriningRecord>> watchAll() {
    return (db.select(
      db.skriningRecords,
    )..orderBy([(t) => OrderingTerm.desc(t.tanggal)])).watch();
  }
}
