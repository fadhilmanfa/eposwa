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
          // Header
          _buildHeaderSection(),

          const SizedBox(height: 24),

          // Search & Filters Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari ID Pendaftaran, Nama, NIK...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedProgram,
                    decoration: InputDecoration(
                      labelText: 'Filter Program',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Filter Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.heroButton,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Export Excel'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

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
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.sectionLight),
                    columns: const [
                      DataColumn(label: Text('ID Pendaftaran', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nama Peserta', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('NIK', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Program', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('No. WhatsApp', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Tgl Daftar', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filtered.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item['id']!, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))),
                          DataCell(Text(item['nama']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(item['nik']!)),
                          DataCell(Text(item['program']!)),
                          DataCell(Text(item['noHp']!)),
                          DataCell(_buildStatusBadge(item['status']!)),
                          DataCell(Text(item['tglDaftar']!)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                  tooltip: 'Lihat Detail',
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.orange),
                                  tooltip: 'Edit Data',
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                  tooltip: 'Hapus Data',
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                const Divider(height: 1),

                // Table Pagination
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menampilkan ${filtered.length} dari ${_candidates.length} total peserta',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                            child: const Text('Sebelumnya'),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
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

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF10B981),
            child: Icon(Icons.storage_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Database Pendaftaran Peserta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Kelola seluruh data peserta yang terdaftar, ekspor data, dan perbarui status verifikasi berkas.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'Terdaftar':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      case 'Verifikasi Berkas':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
      case 'Belum Lengkap':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
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
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
