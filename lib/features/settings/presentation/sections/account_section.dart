import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/core/services/session_service.dart';
import 'package:eposwa/core/widgets/excel_table.dart';
import 'package:eposwa/features/auth/data/auth_repository.dart';

class AccountSection extends StatefulWidget {
  const AccountSection({super.key});

  @override
  State<AccountSection> createState() => AccountSectionState();
}

class AccountSectionState extends State<AccountSection> {
  final AuthRepository _repo = AuthRepository(getAppDatabase());

  List<Admin> _admins = [];
  bool _loading = true;

  int? _sortColumnIndex;
  SortDirection? _sortDirection;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Muat ulang data dari database. Dipanggil dari luar (SettingsPage) setelah
  /// menambah admin agar tabel selalu segar.
  Future<void> refresh() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.getAllAdmins();
    if (!mounted) return;
    setState(() {
      _admins = list;
      _loading = false;
    });
  }

  bool _isCurrentSession(Admin admin) =>
      admin.id == SessionService.currentAdmin?.id;

  void _onSort(int col) {
    setState(() {
      if (_sortColumnIndex != col) {
        _sortColumnIndex = col;
        _sortDirection = SortDirection.asc;
      } else if (_sortDirection == SortDirection.asc) {
        _sortDirection = SortDirection.desc;
      } else {
        _sortColumnIndex = null;
        _sortDirection = null;
      }
    });
  }

  List<Admin> _applySort(List<Admin> source) {
    final col = _sortColumnIndex;
    if (col == null) return source;
    final dir = _sortDirection == SortDirection.desc ? -1 : 1;
    final sorted = List<Admin>.from(source);
    switch (col) {
      case 0:
        sorted.sort(
          (a, b) =>
              dir *
              a.username.toLowerCase().compareTo(b.username.toLowerCase()),
        );
        break;
      case 1:
        sorted.sort(
          (a, b) =>
              dir *
              a.namaLengkap.toLowerCase().compareTo(
                b.namaLengkap.toLowerCase(),
              ),
        );
        break;
      default:
        return source;
    }
    return sorted;
  }

  void _showMessage(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _confirmDelete(Admin admin) async {
    // Pengaman: akun yang sedang dipakai login tidak boleh dihapus.
    if (_isCurrentSession(admin)) {
      _showMessage(
        'Tidak bisa menghapus akun yang sedang digunakan untuk login.',
      );
      return;
    }

    // Pengaman: minimal harus tersisa satu admin agar aplikasi tetap bisa login.
    if (_admins.length <= 1) {
      _showMessage(
        'Tidak bisa menghapus admin terakhir. Minimal harus ada satu admin '
        'agar aplikasi dapat digunakan.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        constraints: const BoxConstraints(maxWidth: 360),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus Admin',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus admin '
                '"${admin.username}"? Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.borderMedium),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    await _repo.deleteAdmin(admin.id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Admin "${admin.username}" dihapus'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          // Kartu tabel mengisi tinggi area konten (tidak lagi melayang
          // mengikuti jumlah baris).
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _buildTableCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard() {
    final sorted = _applySort(_admins);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : sorted.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Baris tabel mengisi sisa tinggi kartu. Bila barisnya banyak,
                // hanya area ini yang scroll; header dan footer tetap di tempat.
                Expanded(
                  child: SingleChildScrollView(
                    child: ExcelTable(
                      columns: const [
                        ExcelColumn(
                          label: 'Username',
                          flex: 2.4,
                          minWidth: 150,
                        ),
                        ExcelColumn(
                          label: 'Nama Lengkap',
                          flex: 3,
                          minWidth: 160,
                        ),
                        ExcelColumn(
                          label: 'Login',
                          flex: 2,
                          minWidth: 130,
                          sortable: false,
                        ),
                        ExcelColumn(
                          label: 'Aksi',
                          flex: 1.6,
                          minWidth: 100,
                          sortable: false,
                        ),
                      ],
                      sortColumnIndex: _sortColumnIndex,
                      sortDirection: _sortDirection,
                      onSort: _onSort,
                      rows: sorted.map((a) {
                        return [
                          Text(
                            a.username,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: context.scaleText(
                                13.5,
                                medium: 14,
                                expanded: 14.5,
                              ),
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            a.namaLengkap,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: context.scaleText(
                                13,
                                medium: 13.5,
                                expanded: 14,
                              ),
                            ),
                          ),
                          _isCurrentSession(a)
                              ? _buildSedangLoginBadge()
                              : const SizedBox.shrink(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Hapus',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () => _confirmDelete(a),
                              ),
                            ],
                          ),
                        ];
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _buildFooter(sorted.length),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.manage_accounts_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada admin',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(int jumlah) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Text(
            'Menampilkan $jumlah dari ${_admins.length} total admin',
            style: TextStyle(
              fontSize: context.scaleText(12, medium: 12.5, expanded: 13),
              color: AppColors.textMuted,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Sebelumnya'),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: context.scaleText(12, medium: 12.5, expanded: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Selanjutnya'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSedangLoginBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badgeBgSuccess,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Sedang Login',
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.badgeTextSuccess,
          fontWeight: FontWeight.bold,
          fontSize: context.scaleText(11, medium: 11.5, expanded: 12),
        ),
      ),
    );
  }
}
