import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
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
      // ensure seed if empty (for existing db without seed)
      final adminCount = await (selectOnly(
        admins,
      )..addColumns([admins.id.count()])).getSingle();
      final count = adminCount.read(admins.id.count()) ?? 0;
      if (count == 0) {
        await _seed();
      }
    },
  );

  Future<void> _seed() async {
    // seed admin
    await into(admins).insert(
      AdminsCompanion.insert(
        username: 'admin',
        passwordHash: hashPassword('admin123'),
        namaLengkap: 'Administrator',
        role: const Value('admin'),
        isActive: const Value(true),
      ),
    );

    // seed 5 peserta
    final pesertaData = [
      {
        'kode': 'REG-2026-001',
        'nama': 'Ahmad Fauzi',
        'nik': '3201984712040001',
        'jk': 'Laki-laki',
        'alamat': 'Jl. Merdeka No. 1, Surakarta',
        'noHp': '081234567890',
        'program': 'Regular Pagi',
        'status': 'Terdaftar',
        'tglDaftar': '27/08/2026',
      },
      {
        'kode': 'REG-2026-002',
        'nama': 'Siti Aminah',
        'nik': '3201984712040002',
        'jk': 'Perempuan',
        'alamat': 'Jl. Melati No. 12, Surakarta',
        'noHp': '081298765432',
        'program': 'Regular Pagi',
        'status': 'Terdaftar',
        'tglDaftar': '27/08/2026',
      },
      {
        'kode': 'REG-2026-003',
        'nama': 'Budi Santoso',
        'nik': '3201984712040003',
        'jk': 'Laki-laki',
        'alamat': 'Jl. Kenanga No. 5, Surakarta',
        'noHp': '085712345678',
        'program': 'Eksekutif',
        'status': 'Verifikasi Berkas',
        'tglDaftar': '26/08/2026',
      },
      {
        'kode': 'REG-2026-004',
        'nama': 'Dina Mariana',
        'nik': '3201984712040004',
        'jk': 'Perempuan',
        'alamat': 'Jl. Anggrek No. 8, Surakarta',
        'noHp': '081377889900',
        'program': 'Regular Sore',
        'status': 'Belum Lengkap',
        'tglDaftar': '25/08/2026',
      },
      {
        'kode': 'REG-2026-005',
        'nama': 'Eko Prasetyo',
        'nik': '3201984712040005',
        'jk': 'Laki-laki',
        'alamat': 'Jl. Mawar No. 20, Surakarta',
        'noHp': '089611223344',
        'program': 'Regular Pagi',
        'status': 'Ditolak',
        'tglDaftar': '24/08/2026',
      },
    ];

    final pesertaIds = <String, int>{};
    for (final p in pesertaData) {
      final id = await into(pesertas).insert(
        PesertasCompanion.insert(
          kodePeserta: p['kode']!,
          nama: p['nama']!,
          nik: p['nik']!,
          jenisKelamin: Value(p['jk']!),
          alamat: Value(p['alamat']),
          noHp: p['noHp']!,
          program: Value(p['program']!),
          status: Value(p['status']!),
          tglDaftar: p['tglDaftar']!,
          tglLahir: const Value(null),
        ),
      );
      pesertaIds[p['nama']!] = id;
    }

    // seed skrining: 1 per peserta, plus 1 extra for Ahmad Fauzi to demo flat 2x
    final skriningSeed = [
      {
        'nama': 'Ahmad Fauzi',
        'tanggal': '27/08/2026',
        'skor': 2,
        'kategori': 'rendah',
        'isRedFlag': false,
        'jawaban': [
          true,
          true,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
        ],
        'rekomendasi':
            'Berikan materi psikoedukasi mandiri pada aplikasi. Atur pengingat otomatis untuk skrining ulang pada Posyandu Jiwa bulan berikutnya.',
      },
      {
        'nama': 'Ahmad Fauzi',
        'tanggal': '28/08/2026',
        'skor': 5,
        'kategori': 'sedang',
        'isRedFlag': false,
        'jawaban': [
          true,
          true,
          true,
          true,
          true,
          false,
          false,
          false,
          false,
          false,
        ],
        'rekomendasi':
            'Kirimkan data responden ke antrean rujukan Perawat Jiwa Puskesmas (CMHN). Jadwalkan sesi konseling awal dan kunjungan kader.',
      },
      {
        'nama': 'Siti Aminah',
        'tanggal': '27/08/2026',
        'skor': 5,
        'kategori': 'sedang',
        'isRedFlag': false,
        'jawaban': [
          true,
          true,
          true,
          true,
          true,
          false,
          false,
          false,
          false,
          false,
        ],
        'rekomendasi':
            'Kirimkan data responden ke antrean rujukan Perawat Jiwa Puskesmas (CMHN). Jadwalkan sesi konseling awal dan kunjungan kader.',
      },
      {
        'nama': 'Budi Santoso',
        'tanggal': '26/08/2026',
        'skor': 7,
        'kategori': 'tinggi',
        'isRedFlag': false,
        'jawaban': [
          true,
          true,
          true,
          true,
          true,
          true,
          true,
          false,
          false,
          false,
        ],
        'rekomendasi':
            'Terbitkan surat rujukan elektronik (e-Rujukan) ke Dokter Umum Puskesmas / Psikolog Klinis / RSJ untuk wawancara diagnostik lanjutan (DSM-5 / PPDGJ-III).',
      },
      {
        'nama': 'Dina Mariana',
        'tanggal': '25/08/2026',
        'skor': 1,
        'kategori': 'rendah',
        'isRedFlag': false,
        'jawaban': [
          true,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
        ],
        'rekomendasi':
            'Berikan materi psikoedukasi mandiri pada aplikasi. Atur pengingat otomatis untuk skrining ulang pada Posyandu Jiwa bulan berikutnya.',
      },
      {
        'nama': 'Eko Prasetyo',
        'tanggal': '24/08/2026',
        'skor': null,
        'kategori': 'kritis',
        'isRedFlag': true,
        'jawaban': [
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          true,
        ],
        'rekomendasi':
            'PERTAHANAN DARURAT: Responden menunjukkan ideasi bunuh diri / self-harm. Skor kuesioner diabaikan dan status KRISIS PSIKIATRI (CRITICAL_ALERT) ditetapkan. Segera rujuk ke Perawat Pembina Kesehatan Jiwa Puskesmas / layanan kesehatan terdekat untuk penanganan segera.',
      },
    ];

    for (final s in skriningSeed) {
      final pesertaId = pesertaIds[s['nama'] as String]!;
      final skor = s['skor'] as int?;
      final jawaban = s['jawaban'] as List<bool>;
      final skriningId = await into(skriningRecords).insert(
        SkriningRecordsCompanion.insert(
          pesertaId: pesertaId,
          tanggal: s['tanggal'] as String,
          skor: Value(skor),
          kategori: s['kategori'] as String,
          isRedFlag: Value(s['isRedFlag'] as bool),
          rekomendasi: s['rekomendasi'] as String,
        ),
      );
      for (var i = 0; i < jawaban.length; i++) {
        await into(skriningJawabans).insert(
          SkriningJawabansCompanion.insert(
            skriningId: skriningId,
            nomor: i + 1,
            jawaban: Value(jawaban[i]),
          ),
        );
      }
    }
  }

  // helpers for file path
  static String? _dbPathOverride;
  static void setDbPathForTesting(String path) => _dbPathOverride = path;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (AppDatabase._dbPathOverride != null) {
      final file = File(AppDatabase._dbPathOverride!);
      return NativeDatabase.createInBackground(file);
    }
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'eposwa.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// singleton accessor
AppDatabase? _instance;
AppDatabase getAppDatabase() {
  _instance ??= AppDatabase();
  return _instance!;
}

void setAppDatabaseForTesting(AppDatabase db) {
  _instance = db;
}
