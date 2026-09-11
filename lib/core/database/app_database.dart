import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:eposwa/core/database/db_safety.dart';

part 'app_database.g.dart';

String _hashPassword(String password, String salt) {
  final bytes = utf8.encode('$salt::$password');
  return sha256.convert(bytes).toString();
}

String hashPassword(String password) {
  // simple salted hash for local desktop; not for production server
  const salt = 'eposwa_salt_v1';
  return _hashPassword(password, salt);
}

bool verifyPassword(String password, String hash) {
  return hashPassword(password) == hash;
}

// ── Tables ──

class Admins extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username =>
      text().customConstraint('UNIQUE NOT NULL COLLATE NOCASE')();
  TextColumn get passwordHash => text().named('password_hash')();
  TextColumn get namaLengkap => text().named('nama_lengkap')();
  TextColumn get role => text().withDefault(const Constant('admin'))();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
  DateTimeColumn get lastLoginAt =>
      dateTime().named('last_login_at').nullable()();
}

class Pesertas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kodePeserta =>
      text().named('kode_peserta').customConstraint('UNIQUE NOT NULL')();
  TextColumn get nama => text()();
  TextColumn get nik => text().customConstraint('UNIQUE NOT NULL')();
  TextColumn get jenisKelamin =>
      text().named('jenis_kelamin').withDefault(const Constant('Laki-laki'))();
  TextColumn get tglLahir => text().named('tgl_lahir').nullable()();
  TextColumn get alamat => text().nullable()();
  TextColumn get noHp => text().named('no_hp')();
  TextColumn get program => text().withDefault(const Constant('-'))();
  BoolColumn get pernahKonsultasi =>
      boolean().named('pernah_konsultasi').nullable()();
  BoolColumn get pernahDapatObat =>
      boolean().named('pernah_dapat_obat').nullable()();
  TextColumn get status => text().withDefault(const Constant('Terdaftar'))();
  TextColumn get tglDaftar => text().named('tgl_daftar')();
  IntColumn get createdBy => integer()
      .named('created_by')
      .nullable()
      .customConstraint('NULL REFERENCES admins(id) ON DELETE SET NULL')();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}

class SkriningRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pesertaId => integer()
      .named('peserta_id')
      .customConstraint('NOT NULL REFERENCES pesertas(id) ON DELETE CASCADE')();
  TextColumn get tanggal => text()();
  IntColumn get skor => integer().nullable()();
  TextColumn get kategori => text()();
  BoolColumn get isRedFlag =>
      boolean().named('is_red_flag').withDefault(const Constant(false))();
  TextColumn get rekomendasi => text()();
  IntColumn get createdBy => integer()
      .named('created_by')
      .nullable()
      .customConstraint('NULL REFERENCES admins(id) ON DELETE SET NULL')();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}

class SkriningJawabans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get skriningId => integer()
      .named('skrining_id')
      .customConstraint(
        'NOT NULL REFERENCES skrining_records(id) ON DELETE CASCADE',
      )();
  IntColumn get nomor => integer()();
  BoolColumn get jawaban => boolean().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {skriningId, nomor},
  ];
}

@DriftDatabase(tables: [Admins, Pesertas, SkriningRecords, SkriningJawabans])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  /// Versi skema saat ini; dipakai [DbSafety] untuk mengenali kebutuhan migrasi.
  static const int currentSchemaVersion = 2;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedAdmin();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Kolom jadwal kunjungan dihapus dari formulir pendaftaran.
        await m.alterTable(
          TableMigration(
            pesertas,
            columnTransformer: {
              pesertas.pernahKonsultasi: pesertas.pernahKonsultasi,
              pesertas.pernahDapatObat: pesertas.pernahDapatObat,
            },
          ),
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) return;
      // pastikan akun admin default tersedia agar bisa login
      final adminCount = await (selectOnly(
        admins,
      )..addColumns([admins.id.count()])).getSingle();
      final count = adminCount.read(admins.id.count()) ?? 0;
      if (count == 0) {
        await _seedAdmin();
      }
      // Penanda upgrade hanya dihapus setelah pembukaan benar-benar sukses.
      await DbSafety.afterOpenSuccess();
    },
  );

  Future<void> _seedAdmin() async {
    await into(admins).insert(
      AdminsCompanion.insert(
        username: 'admin',
        passwordHash: hashPassword('admin123'),
        namaLengkap: 'Administrator',
        role: const Value('admin'),
        isActive: const Value(true),
      ),
    );
  }

  // helpers for file path
  static String? _dbPathOverride;
  static void setDbPathForTesting(String path) => _dbPathOverride = path;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = AppDatabase._dbPathOverride != null
        ? File(AppDatabase._dbPathOverride!)
        : File(p.join((await getApplicationSupportDirectory()).path, 'eposwa.db'));
    await DbSafety.prepare(
      file,
      schemaVersion: AppDatabase.currentSchemaVersion,
    );
    return NativeDatabase.createInBackground(file);
  });
}

// singleton accessor
AppDatabase? _instance;
AppDatabase getAppDatabase() {
  _instance ??= AppDatabase();
  return _instance!;
}

/// Menutup koneksi database secara bersih sebelum aplikasi diganti installer.
///
/// `wal_checkpoint` hanya berlaku bila mode WAL aktif; kalau tidak, diabaikan
/// (pola sama seperti export_service.dart).
Future<void> closeAppDatabaseForUpdate() async {
  final db = _instance;
  if (db == null) return;
  try {
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  } catch (_) {}
  await db.close();
  _instance = null;
}

void setAppDatabaseForTesting(AppDatabase db) {
  _instance = db;
}
