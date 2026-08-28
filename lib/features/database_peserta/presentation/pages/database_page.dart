import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedProgram = 'Semua';
  String _selectedStatus = 'Semua';

  final List<Map<String, String>> _candidates = [
    {
      'id': 'REG-2026-001',
      'nama': 'Ahmad Fauzi',
      'nik': '3201984712040001',
      'program': 'Regular Pagi',
      'noHp': '081234567890',
      'status': 'Terdaftar',
      'tglDaftar': '27/08/2026',
    },
    {
      'id': 'REG-2026-002',
      'nama': 'Siti Aminah',
      'nik': '3201984712040002',
      'program': 'Regular Pagi',
      'noHp': '081298765432',
      'status': 'Terdaftar',
      'tglDaftar': '27/08/2026',
    },
    {
      'id': 'REG-2026-003',
      'nama': 'Budi Santoso',
      'nik': '3201984712040003',
      'program': 'Eksekutif',
      'noHp': '085712345678',
      'status': 'Verifikasi Berkas',
      'tglDaftar': '26/08/2026',
    },
    {
      'id': 'REG-2026-004',
      'nama': 'Dina Mariana',
      'nik': '3201984712040004',
      'program': 'Regular Sore',
      'noHp': '081377889900',
      'status': 'Belum Lengkap',
      'tglDaftar': '25/08/2026',
    },
    {
      'id': 'REG-2026-005',
      'nama': 'Eko Prasetyo',
      'nik': '3201984712040005',
      'program': 'Regular Pagi',
      'noHp': '089611223344',
      'status': 'Ditolak',
      'tglDaftar': '24/08/2026',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _candidates.where((item) {
      final matchesSearch = item['nama']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          item['nik']!.contains(_searchController.text) ||
          item['id']!.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesProgram = _selectedProgram == 'Semua' ||
          item['program'] == _selectedProgram;
      final matchesStatus =
          _selectedStatus == 'Semua' || item['status'] == _selectedStatus;
      return matchesSearch && matchesProgram && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Database Pendaftaran Peserta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kelola seluruh data peserta yang terdaftar, ekspor data, dan perbarui status verifikasi berkas.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),

          const SizedBox(height: 20),

          // Search & Filter
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari ID Pendaftaran, Nama, NIK...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedProgram,
                    isExpanded: true,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textDark),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua Program')),
                      DropdownMenuItem(
                          value: 'Regular Pagi', child: Text('Regular Pagi')),
                      DropdownMenuItem(
                          value: 'Regular Sore', child: Text('Regular Sore')),
                      DropdownMenuItem(
                          value: 'Eksekutif', child: Text('Eksekutif')),
                    ],
                    onChanged: (val) => setState(() => _selectedProgram = val!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    isExpanded: true,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textDark),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua Status')),
                      DropdownMenuItem(
                          value: 'Terdaftar', child: Text('Terdaftar')),
                      DropdownMenuItem(
                          value: 'Verifikasi Berkas', child: Text('Verifikasi Berkas')),
                      DropdownMenuItem(
                          value: 'Belum Lengkap', child: Text('Belum Lengkap')),
                      DropdownMenuItem(value: 'Ditolak', child: Text('Ditolak')),
                    ],
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.heroButton,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export Excel',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Data Table Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: const [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'Tidak ada data peserta yang sesuai',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final table = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                color: AppColors.sectionLight,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: const Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: _TableHeaderText('ID Pendaftaran')),
                                    Expanded(
                                        flex: 3,
                                        child: _TableHeaderText('Nama Peserta')),
                                    Expanded(
                                        flex: 3,
                                        child: _TableHeaderText('NIK')),
                                    Expanded(
                                        flex: 2,
                                        child: _TableHeaderText('Program')),
                                    Expanded(
                                        flex: 2,
                                        child: _TableHeaderText('No. WhatsApp')),
                                    Expanded(
                                        flex: 2,
                                        child: _TableHeaderText('Status')),
                                    Expanded(
                                        flex: 2,
                                        child: _TableHeaderText('Tgl Daftar')),
                                    Expanded(
                                        flex: 2,
                                        child: _TableHeaderText('Aksi')),
                                  ],
                                ),
                              ),
                              ...filtered.map((item) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: AppColors.borderLight),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item['id']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          item['nama']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          item['nik']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item['program']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item['noHp']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: _buildStatusBadge(item['status']!),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(item['tglDaftar']!),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.visibility_outlined,
                                                  size: 18,
                                                  color: AppColors.primary),
                                              tooltip: 'Lihat Detail',
                                              visualDensity:
                                                  VisualDensity.compact,
                                              onPressed: () {},
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 18,
                                                  color: Colors.orange),
                                              tooltip: 'Edit Data',
                                              visualDensity:
                                                  VisualDensity.compact,
                                              onPressed: () {},
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 18,
                                                  color: Colors.redAccent),
                                              tooltip: 'Hapus Data',
                                              visualDensity:
                                                  VisualDensity.compact,
                                              onPressed: () =>
                                                  _confirmDelete(item),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );

                          if (constraints.maxWidth >= 900) {
                            return table;
                          }
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(width: 900, child: table),
                          );
                        },
                      ),

                      const Divider(height: 1),

                      // Table Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${filtered.length} dari ${_candidates.length} total peserta',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                            ),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                      visualDensity:
                                          VisualDensity.compact),
                                  child: const Text('Sebelumnya'),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '1',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                      visualDensity:
                                          VisualDensity.compact),
                                  child: const Text('Selanjutnya'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, String> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        constraints: const BoxConstraints(maxWidth: 360),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                'Hapus Data Peserta',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus data peserta "${item['nama']}"? '
                'Tindakan ini tidak dapat dibatalkan.',
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

    if (confirmed == true && mounted) {
      setState(() => _candidates.remove(item));
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'Terdaftar':
        bg = AppColors.badgeBgSuccess;
        fg = AppColors.badgeTextSuccess;
        break;
      case 'Verifikasi Berkas':
        bg = AppColors.badgeBgInfo;
        fg = AppColors.badgeTextInfo;
        break;
      case 'Belum Lengkap':
        bg = AppColors.badgeBgWarning;
        fg = AppColors.badgeTextWarning;
        break;
      default:
        bg = const Color(0xFFFEF2F2);
        fg = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;

  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    );
  }
}