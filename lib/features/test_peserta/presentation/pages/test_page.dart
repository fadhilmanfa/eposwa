import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _dummyTests = [
    {
      'nama': 'Ahmad Fauzi',
      'nik': '3201984712040001',
      'program': 'Regular Pagi',
      'sesi': 'Ujian Potensi Akademik',
      'tanggal': '27 Agt 2026',
      'skor': 88,
      'status': 'Lulus',
    },
    {
      'nama': 'Siti Aminah',
      'nik': '3201984712040002',
      'program': 'Regular Pagi',
      'sesi': 'Ujian Potensi Akademik',
      'tanggal': '27 Agt 2026',
      'skor': 92,
      'status': 'Lulus',
    },
    {
      'nama': 'Budi Santoso',
      'nik': '3201984712040003',
      'program': 'Eksekutif',
      'sesi': 'Tes Kemampuan Komputer',
      'tanggal': '27 Agt 2026',
      'skor': 0,
      'status': 'Sedang Ujian',
    },
    {
      'nama': 'Dina Mariana',
      'nik': '3201984712040004',
      'program': 'Regular Sore',
      'sesi': 'Ujian Bahasa Inggris',
      'tanggal': '28 Agt 2026',
      'skor': 0,
      'status': 'Belum Ujian',
    },
    {
      'nama': 'Eko Prasetyo',
      'nik': '3201984712040005',
      'program': 'Regular Pagi',
      'sesi': 'Ujian Potensi Akademik',
      'tanggal': '26 Agt 2026',
      'skor': 45,
      'status': 'Tidak Lulus',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _dummyTests.where((item) {
      final matchesFilter = _selectedFilter == 'Semua' ||
          item['status'].toString().toLowerCase() ==
              _selectedFilter.toLowerCase();
      final matchesSearch = item['nama']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          item['nik'].toString().contains(_searchController.text);
      return matchesFilter && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Ujian & Penilaian Peserta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pantau sesi ujian yang sedang berlangsung, skor penilaian, dan status hasil seleksi.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),

          const SizedBox(height: 20),

          // Search & Filter
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari nama peserta atau NIK...',
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
              const SizedBox(width: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: ['Semua', 'Sedang Ujian', 'Lulus', 'Tidak Lulus', 'Belum Ujian']
                    .map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return InkWell(
                    onTap: () => setState(() => _selectedFilter = filter),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderMedium,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
            child: filteredList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: const [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'Tidak ada data sesi ujian yang sesuai',
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
                                      flex: 3,
                                      child: _TableHeaderText('Nama Peserta'),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: _TableHeaderText('Tanggal')),
                                    Expanded(
                                        flex: 1,
                                        child: _TableHeaderText('Skor')),
                                    Expanded(
                                        flex: 2,
                                        child: _TableHeaderText('Status')),
                                    Expanded(
                                        flex: 2,
                                        child: _TableHeaderText('Aksi')),
                                  ],
                                ),
                              ),
                              ...filteredList.map((test) {
                                final status = test['status'] as String;
                                final hasScore =
                                    status == 'Lulus' || status == 'Tidak Lulus';
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
                                        flex: 3,
                                        child: Text(
                                          test['nama'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(test['tanggal']),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          hasScore ? '${test['skor']}' : '-',
                                          style: TextStyle(
                                            fontWeight: hasScore
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: hasScore
                                                ? AppColors.textDark
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: _buildStatusBadge(status),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
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
                                                  _confirmDelete(test),
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

                          if (constraints.maxWidth >= 800) {
                            return table;
                          }
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(width: 800, child: table),
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
                              'Menampilkan ${filteredList.length} dari ${_dummyTests.length} total peserta',
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

  Future<void> _confirmDelete(Map<String, dynamic> test) async {
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
                'Hapus Data Ujian',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus data ujian "${test['nama']}"? '
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
      setState(() => _dummyTests.remove(test));
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'Lulus':
        bg = AppColors.badgeBgSuccess;
        fg = AppColors.badgeTextSuccess;
        break;
      case 'Tidak Lulus':
        bg = const Color(0xFFFEF2F2);
        fg = Colors.redAccent;
        break;
      case 'Sedang Ujian':
        bg = AppColors.badgeBgInfo;
        fg = AppColors.badgeTextInfo;
        break;
      default:
        bg = AppColors.sectionLight;
        fg = AppColors.textMuted;
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