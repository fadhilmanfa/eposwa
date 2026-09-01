import 'package:drift/drift.dart';
import 'package:eposwa/core/database/app_database.dart';

class AuthRepository {
  final AppDatabase db;
  AuthRepository(this.db);

  Future<Admin?> login(String username, String password) async {
    final q = username.trim().toLowerCase();
    if (q.isEmpty) return null;
    final row = await (db.select(
      db.admins,
    )..where((t) => t.username.lower().equals(q))).getSingleOrNull();
    if (row == null) return null;
    if (!row.isActive) return null;
    if (!verifyPassword(password, row.passwordHash)) return null;
    // update lastLoginAt
    await (db.update(db.admins)..where((t) => t.id.equals(row.id))).write(
      AdminsCompanion(
        lastLoginAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return row;
  }

  Future<List<Admin>> getAllAdmins() {
    return (db.select(
      db.admins,
    )..orderBy([(t) => OrderingTerm.asc(t.username)])).get();
  }

  Future<int> createAdmin({
    required String username,
    required String password,
    required String namaLengkap,
    String role = 'admin',
  }) {
    return db
        .into(db.admins)
        .insert(
          AdminsCompanion.insert(
            username: username.trim(),
            passwordHash: hashPassword(password),
            namaLengkap: namaLengkap.trim(),
            role: Value(role),
            isActive: const Value(true),
          ),
        );
  }

  Future<bool> updateAdmin(
    int id, {
    String? namaLengkap,
    String? role,
    bool? isActive,
  }) async {
    final comp = AdminsCompanion(
      namaLengkap: namaLengkap != null
          ? Value(namaLengkap)
          : const Value.absent(),
      role: role != null ? Value(role) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
    final count = await (db.update(
      db.admins,
    )..where((t) => t.id.equals(id))).write(comp);
    return count > 0;
  }

  Future<bool> resetPassword(int id, String newPassword) async {
    final count = await (db.update(db.admins)..where((t) => t.id.equals(id)))
        .write(
          AdminsCompanion(
            passwordHash: Value(hashPassword(newPassword)),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return count > 0;
  }

  Future<bool> setActive(int id, bool active) =>
      updateAdmin(id, isActive: active);

  Future<Admin?> getById(int id) {
    return (db.select(
      db.admins,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
