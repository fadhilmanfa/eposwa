import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/features/test_peserta/presentation/widgets/exam_result_dialog.dart';
import 'package:eposwa/features/test_peserta/presentation/widgets/interactive_exam_view.dart';

/// Halaman Utama Ujian & Penilaian Peserta - Minimalis & Terfokus.
class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Map<String, dynamic>? _activeExamParticipant;
  String _selectedFilter = 'Semua';
  String _selectedProgram = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _dummyTests = [
    {
      'nama': 'Ahmad Fauzi',
      'nik': '3201984712040001',
      'program': 'Regular Pagi',
      'sesi': 'Ujian Potensi & Skrining Jiwa',
      'tanggal': '27 Agt 2026',
      'skor': 88,
      'status': 'Lulus',
      'skorPengetahuan': 85,
      'skorPsikologis': 90,
      'skorWawancara': 88,
      'catatan': 'Peserta sangat komunikatif dan memiliki motivasi tinggi.',
    },
    {
      'nama': 'Siti Aminah',
      'nik': '3201984712040002',
      'program': 'Regular Pagi',
      'sesi': 'Ujian Potensi & Skrining Jiwa',
      'tanggal': '27 Agt 2026',
      'skor': 92,
      'status': 'Lulus',
      'skorPengetahuan': 95,
      'skorPsikologis': 90,
      'skorWawancara': 90,
      'catatan': 'Hasil skrining sangat baik, memiliki pemahaman alur posyandu.',
    },
    {
      'nama': 'Budi Santoso',
      'nik': '3201984712040003',
      'program': 'Eksekutif',
      'sesi': 'Ujian Potensi & Skrining Jiwa',
      'tanggal': '27 Agt 2026',
      'skor': 0,
      'status': 'Sedang Ujian',
      'skorPengetahuan': 0,
      'skorPsikologis': 0,
      'skorWawancara': 0,
      'catatan': '',
    },
    {
      'nama': 'Dina Mariana',
      'nik': '3201984712040004',
      'program': 'Regular Sore',
      'sesi': 'Ujian Potensi & Skrining Jiwa',
      'tanggal': '28 Agt 2026',
      'skor': 0,
      'status': 'Belum Ujian',
      'skorPengetahuan': 0,
      'skorPsikologis': 0,
      'skorWawancara': 0,
      'catatan': '',
    },
    {
      'nama': 'Eko Prasetyo',
      'nik': '3201984712040005',
      'program': 'Regular Pagi',
      'sesi': 'Ujian Potensi & Skrining Jiwa',
      'tanggal': '26 Agt 2026',
      'skor': 58,
      'status': 'Tidak Lulus',
      'skorPengetahuan': 60,
      'skorPsikologis': 55,
      'skorWawancara': 60,
      'catatan': 'Nilai di bawah passing grade 70. Direkomendasikan remedial.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---
  void _startExamForParticipant(Map<String, dynamic> test) {
    setState(() {
      _activeExamParticipant = test;
    });
  }

  void _openResultDialog(Map<String, dynamic> test) {
    showDialog(
      context: context,
      builder: (context) => ExamResultDialog(
        testData: test,
        onReEvaluate: () {
          Navigator.of(context).pop();
          _startExamForParticipant(test);
        },
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> test) async {
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
                'Hapus Data Ujian',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus data ujian "${test['nama']}"? Tindakan ini tidak dapat dibatalkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
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
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sesi ujian berhasil dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If an exam is active for a specific participant, show the dedicated Exam Page
    if (_activeExamParticipant != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: InteractiveExamView(
          participant: _activeExamParticipant!,
          onCancel: () => setState(() => _activeExamParticipant = null),
          onFinishExam: (updated) {
            setState(() {
              final idx =
                  _dummyTests.indexWhere((t) => t['nik'] == updated['nik']);
              if (idx != -1) {
                _dummyTests[idx] = updated;
              }
              _activeExamParticipant = null;
            });
            _openResultDialog(updated);
          },
        ),
      );
    }

    final filteredList = _dummyTests.where((item) {
      final matchesFilter = _selectedFilter == 'Semua' ||
          item['status'].toString().toLowerCase() ==
              _selectedFilter.toLowerCase();
      final matchesProgram = _selectedProgram == 'Semua' ||
          item['program'] == _selectedProgram;
      final matchesSearch = item['nama']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          item['nik'].toString().contains(_searchController.text);
      return matchesFilter && matchesProgram && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Minimalis
          _buildHeader(),

          const SizedBox(height: 24),

          // 2. Toolbar Pencarian & Filter
          _buildFilterToolbar(),

          const SizedBox(height: 16),

          // 3. Tabel Data Peserta Ujian
          _buildTableCard(filteredList),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ujian & Penilaian Peserta',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'Inter',
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kelola skor evaluasi, input rubrik multi-aspek, dan pantau hasil seleksi peserta.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (!isNarrow) ...[
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () {
                  final pending = _dummyTests.firstWhere(
                    (t) =>
                        t['status'] == 'Sedang Ujian' ||
                        t['status'] == 'Belum Ujian',
                    orElse: () => _dummyTests.first,
                  );
                  _startExamForParticipant(pending);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.heroButton,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.quiz_outlined, size: 17),
                label: const Text(
                  'Mulai Sesi Ujian',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFilterToolbar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isNarrow) ...[
              SizedBox(
                height: 42,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari nama peserta atau NIK...',
                    hintStyle: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.heroButton, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedProgram,
                  isExpanded: true,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textDark),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.heroButton, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Semua', child: Text('Semua Program')),
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
            ] else ...[
              Row(
                children: [
                  // Search Field
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Cari nama peserta atau NIK...',
                          hintStyle: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded,
                              size: 18, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.heroButton, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Program Dropdown
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 42,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedProgram,
                        isExpanded: true,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textDark),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.heroButton, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Semua', child: Text('Semua Program')),
                          DropdownMenuItem(
                              value: 'Regular Pagi',
                              child: Text('Regular Pagi')),
                          DropdownMenuItem(
                              value: 'Regular Sore',
                              child: Text('Regular Sore')),
                          DropdownMenuItem(
                              value: 'Eksekutif', child: Text('Eksekutif')),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedProgram = val!),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Semua',
                  'Lulus',
                  'Sedang Ujian',
                  'Belum Ujian',
                  'Tidak Lulus',
                ].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = filter),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.heroButton
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.heroButton
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableCard(List<Map<String, dynamic>> filteredList) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: filteredList.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: const [
                  Icon(Icons.search_off_rounded,
                      size: 44, color: Color(0xFF94A3B8)),
                  SizedBox(height: 12),
                  Text(
                    'Tidak ada data sesi ujian yang sesuai',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
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
                        // Table Header
                        Container(
                          color: const Color(0xFFF8FAFC),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 13),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _TableHeaderText('Nama & NIK Peserta'),
                              ),
                              Expanded(
                                flex: 2,
                                child: _TableHeaderText('Program & Sesi'),
                              ),
                              Expanded(
                                flex: 2,
                                child: _TableHeaderText('Tanggal'),
                              ),
                              Expanded(
                                flex: 2,
                                child: _TableHeaderText('Skor Akhir'),
                              ),
                              Expanded(
                                flex: 2,
                                child: _TableHeaderText('Status'),
                              ),
                              Expanded(
                                flex: 2,
                                child: _TableHeaderText('Aksi'),
                              ),
                            ],
                          ),
                        ),
                        // Table Rows
                        ...filteredList.map((test) {
                          final status = test['status'] as String;
                          final hasScore =
                              status == 'Lulus' || status == 'Tidak Lulus';
                          final skor = test['skor'] as int;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF1F5F9),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // 1. Nama & NIK
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        test['nama'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.5,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        test['nik'],
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 2. Program & Sesi
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        test['program'],
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        test['sesi'] ?? 'Sesi Reguler',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 3. Tanggal
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    test['tanggal'],
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),

                                // 4. Skor Akhir (Visual Bar + Value)
                                Expanded(
                                  flex: 2,
                                  child: hasScore
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                child: LinearProgressIndicator(
                                                  value: skor / 100.0,
                                                  minHeight: 5,
                                                  backgroundColor:
                                                      const Color(0xFFF1F5F9),
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    skor >= 70
                                                        ? const Color(
                                                            0xFF10B981)
                                                        : Colors.redAccent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '$skor',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: skor >= 70
                                                    ? const Color(0xFF10B981)
                                                    : Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          '-',
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 13,
                                          ),
                                        ),
                                ),

                                // 5. Status Badge
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildStatusBadge(status),
                                  ),
                                ),

                                // 6. Aksi (Mulai Ujian / Edit Ujian, Rapor, Hapus)
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          hasScore
                                              ? Icons.edit_note_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 20,
                                          color: AppColors.heroButton,
                                        ),
                                        tooltip: hasScore
                                            ? 'Edit / Kerjakan Ulang Ujian'
                                            : 'Mulai Ujian Peserta',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () =>
                                            _startExamForParticipant(test),
                                      ),
                                      if (hasScore)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.description_outlined,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                          tooltip: 'Lihat Rapor Hasil',
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () =>
                                              _openResultDialog(test),
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: Colors.redAccent,
                                        ),
                                        tooltip: 'Hapus Data',
                                        visualDensity: VisualDensity.compact,
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

                    if (constraints.maxWidth >= 860) {
                      return table;
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: 860, child: table),
                    );
                  },
                ),

                // Table Footer (Pagination)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menampilkan ${filteredList.length} dari ${_dummyTests.length} peserta',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              side:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            child: const Text('Sebelumnya',
                                style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.heroButton,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              side:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            child: const Text('Selanjutnya',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
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
      case 'Lulus':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      case 'Tidak Lulus':
        bg = const Color(0xFFFEF2F2);
        fg = Colors.redAccent;
        break;
      case 'Sedang Ujian':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
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
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
        color: Color(0xFF475569),
        fontFamily: 'Inter',
      ),
    );
  }
}