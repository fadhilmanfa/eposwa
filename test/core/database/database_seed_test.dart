import 'package:drift/native.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Memastikan database yang baru dibuat benar-benar bersih: hanya berisi akun
/// admin default yang diperlukan untuk login, tanpa data peserta/skrining.
///
/// Ini melindungi aplikasi dari ikut terkirimnya data contoh ke pengguna.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    setAppDatabaseForTesting(db);
  });

  tearDown(() => db.close());

  test('database baru hanya berisi akun admin default', () async {
    final admins = await db.select(db.admins).get();

    expect(admins, hasLength(1));
    expect(admins.single.username, 'admin');
    expect(admins.single.role, 'admin');
    expect(admins.single.isActive, isTrue);
  });

  test('database baru tidak berisi data peserta maupun skrining', () async {
    expect(await db.select(db.pesertas).get(), isEmpty);
    expect(await db.select(db.skriningRecords).get(), isEmpty);
    expect(await db.select(db.skriningJawabans).get(), isEmpty);
  });

  test('akun admin default bisa dipakai login', () async {
    final admin = await (db.select(
      db.admins,
    )..where((t) => t.username.equals('admin'))).getSingle();

    expect(verifyPassword('admin123', admin.passwordHash), isTrue);
  });
}
