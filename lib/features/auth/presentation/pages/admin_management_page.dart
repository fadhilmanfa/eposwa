import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/features/auth/data/auth_repository.dart';

class AdminManagementPage extends StatefulWidget {
  const AdminManagementPage({super.key});

  @override
  State<AdminManagementPage> createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  late AuthRepository _repo;
  List<Admin> _admins = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = AuthRepository(getAppDatabase());
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.getAllAdmins();
    if (!mounted) return;
    setState(() {
      _admins = list;
      _loading = false;
    });
  }

  Future<void> _showAddDialog() async {
    final usernameCtrl = TextEditingController();
    final namaCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'admin';
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Tambah Admin',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username *',
                    hintText: 'mis. kader01',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi *',
                    hintText: 'min 6 karakter',
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('admin')),
                    DropdownMenuItem(value: 'kader', child: Text('kader')),
                    DropdownMenuItem(value: 'perawat', child: Text('perawat')),
                  ],
                  onChanged: (v) => role = v ?? 'admin',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              try {
                await _repo.createAdmin(
                  username: usernameCtrl.text.trim(),
                  password: passCtrl.text,
                  namaLengkap: namaCtrl.text.trim(),
                  role: role,
                );
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Gagal: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result == true) {
      await _load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin ditambahkan'),
            backgroundColor: AppColors.primary,
          ),
        );
    }
  }

  Future<void> _toggleActive(Admin a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(a.isActive ? 'Nonaktifkan Admin?' : 'Aktifkan Admin?'),
        content: Text('Username: ${a.username}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: a.isActive
                  ? Colors.redAccent
                  : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(a.isActive ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _repo.setActive(a.id, !a.isActive);
    await _load();
  }

  Future<void> _resetPassword(Admin a) async {
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Kata Sandi'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Kata sandi baru untuk ${a.username}',
            ),
            validator: (v) =>
                v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await _repo.resetPassword(a.id, passCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (ok == true) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kata sandi direset'),
            backgroundColor: AppColors.primary,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Manajemen Admin',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Admin'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _admins.isEmpty
          ? const Center(child: Text('Belum ada admin'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF8FAFC),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Username',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Nama Lengkap',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Role',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Aksi',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                    rows: _admins.map((a) {
                      return DataRow(
                        cells: [
                          DataCell(Text(a.username)),
                          DataCell(Text(a.namaLengkap)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.role,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: a.isActive
                                    ? const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.12)
                                    : Colors.redAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.isActive ? 'Aktif' : 'Nonaktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: a.isActive
                                      ? const Color(0xFF10B981)
                                      : Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: a.isActive
                                      ? 'Nonaktifkan'
                                      : 'Aktifkan',
                                  icon: Icon(
                                    a.isActive
                                        ? Icons.block_rounded
                                        : Icons.check_circle_rounded,
                                    size: 18,
                                    color: a.isActive
                                        ? Colors.redAccent
                                        : const Color(0xFF10B981),
                                  ),
                                  onPressed: () => _toggleActive(a),
                                ),
                                IconButton(
                                  tooltip: 'Reset password',
                                  icon: const Icon(
                                    Icons.lock_reset_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () => _resetPassword(a),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}
