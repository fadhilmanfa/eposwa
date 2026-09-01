import 'package:shared_preferences/shared_preferences.dart';
import 'package:eposwa/core/database/app_database.dart';

class SessionService {
  static const _kAdminId = 'session_admin_id';
  static const _kUsername = 'session_username';
  static const _kNamaLengkap = 'session_nama_lengkap';
  static const _kRemember = 'session_remember';

  static Admin? currentAdmin;

  static Future<void> saveSession(Admin admin, {bool remember = false}) async {
    currentAdmin = admin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAdminId, admin.id);
    await prefs.setString(_kUsername, admin.username);
    await prefs.setString(_kNamaLengkap, admin.namaLengkap);
    await prefs.setBool(_kRemember, remember);
  }

  static Future<void> clearSession() async {
    currentAdmin = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAdminId);
    await prefs.remove(_kUsername);
    await prefs.remove(_kNamaLengkap);
    // keep remember flag? clear anyway
  }

  static Future<Admin?> loadRememberedAdmin(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_kRemember) ?? false;
    if (!remember) return null;
    final id = prefs.getInt(_kAdminId);
    if (id == null) return null;
    final admin = await (db.select(
      db.admins,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (admin != null && admin.isActive) {
      currentAdmin = admin;
      return admin;
    }
    return null;
  }

  static Future<String?> getRememberedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_kRemember) ?? false;
    if (!remember) return null;
    return prefs.getString(_kUsername);
  }
}
