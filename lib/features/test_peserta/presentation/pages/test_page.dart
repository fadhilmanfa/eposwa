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
          // Header Card
          _buildHeaderSection(),

          const SizedBox(height: 24),

          // Filters & Search Bar
          Row(
            children: [
              // Search input
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama peserta atau NIK...',
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
              // Filter Chips
              Wrap(
                spacing: 8,
                children: ['Semua', 'Sedang Ujian', 'Lulus', 'Tidak Lulus', 'Belum Ujian']
                    .map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = filter);
                    },
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // List Sesi Test & Hasil
          if (filteredList.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Column(
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 48, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    'Tidak ada data sesi ujian yang sesuai',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final test = filteredList[index];
                return _TestItemCard(test: test);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF8B5CF6),
            child: Icon(Icons.assignment_turned_in_rounded,
                color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ujian & Penilaian Peserta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pantau sesi ujian yang sedang berlangsung, skor penilaian, dan status hasil seleksi.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestItemCard extends StatelessWidget {
  final Map<String, dynamic> test;

  const _TestItemCard({required this.test});

  @override
  Widget build(BuildContext context) {
    final status = test['status'] as String;
    Color statusColor;
    Color statusBg;

    switch (status) {
      case 'Lulus':
        statusColor = const Color(0xFF10B981);
        statusBg = const Color(0xFFECFDF5);
        break;
      case 'Tidak Lulus':
        statusColor = Colors.redAccent;
        statusBg = const Color(0xFFFEF2F2);
        break;
      case 'Sedang Ujian':
        statusColor = const Color(0xFF3B82F6);
        statusBg = const Color(0xFFEFF6FF);
        break;
      default:
        statusColor = AppColors.textMuted;
        statusBg = AppColors.sectionLight;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: statusColor.withValues(alpha: 0.1),
            child: Icon(
              status == 'Lulus'
                  ? Icons.check_rounded
                  : (status == 'Sedang Ujian'
                      ? Icons.timer_outlined
                      : Icons.article_outlined),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test['nama'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NIK: ${test['nik']} • ${test['program']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test['sesi'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  test['tanggal'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status == 'Lulus' || status == 'Tidak Lulus'
                  ? 'Skor: ${test['skor']} ($status)'
                  : status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Detail'),
          ),
        ],
      ),
    );
  }
}
