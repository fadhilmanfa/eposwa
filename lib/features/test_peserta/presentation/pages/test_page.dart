import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/core/widgets/excel_table.dart';
import 'package:eposwa/features/skrining/domain/skrining_data.dart';
import 'package:eposwa/features/skrining/presentation/pages/skrining_form_page.dart';

/// Halaman "Skrining & Penilaian" - daftar orang yang telah menjalani skrining jiwa.
class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<SkriningRecord> _dummySkrining = [
    const SkriningRecord(
      nama: 'Ahmad Fauzi',
      tanggal: '27 Agt 2026',
      skor: 2,
      kategori: SkriningKategori.rendah,
    ),
    const SkriningRecord(
      nama: 'Siti Aminah',
      tanggal: '27 Agt 2026',
      skor: 5,
      kategori: SkriningKategori.sedang,
    ),
    const SkriningRecord(
      nama: 'Budi Santoso',
      tanggal: '26 Agt 2026',
      skor: 7,
      kategori: SkriningKategori.tinggi,
    ),
    const SkriningRecord(
      nama: 'Dina Mariana',
      tanggal: '25 Agt 2026',
      skor: 1,
      kategori: SkriningKategori.rendah,
    ),
    const SkriningRecord(
      nama: 'Eko Prasetyo',
      tanggal: '24 Agt 2026',
      kategori: SkriningKategori.kritis,
      isRedFlag: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openSkriningBaru() async {
    final record = await Navigator.of(context).push<SkriningRecord>(
      MaterialPageRoute(builder: (context) => const SkriningFormPage()),
    );
    if (record != null && mounted) {
      setState(() => _dummySkrining.insert(0, record));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _dummySkrining.where((item) {
      final matchesFilter = _selectedFilter == 'Semua' ||
          item.kategori.label.toLowerCase() ==
              _selectedFilter.toLowerCase();
      final matchesSearch = item.nama
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          item.skorLabel.contains(_searchController.text);
      return matchesFilter && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skrining & Penilaian Jiwa',
                  style: TextStyle(
                    fontSize: context.scaleText(20,
                        expanded: 22, large: 24),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Search + Filter popup + Skrining Baru (kanan)
          LayoutBuilder(
            builder: (context, constraints) {
              final searchField = SizedBox(
                height: 44,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama peserta...',
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
              );

              final isFilterActive = _selectedFilter != 'Semua';
              final filterLabel =
                  isFilterActive ? 'Filter: $_selectedFilter' : 'Filter';
              final filterBtn = PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                onSelected: (v) => setState(() => _selectedFilter = v),
                itemBuilder: (context) => [
                  for (final f in [
                    'Semua',
                    SkriningKategori.rendah.label,
                    SkriningKategori.sedang.label,
                    SkriningKategori.tinggi.label,
                    SkriningKategori.kritis.label,
                  ])
                    PopupMenuItem<String>(
                      value: f,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            child: _selectedFilter == f
                                ? const Icon(Icons.check_rounded,
                                    size: 16, color: AppColors.primary)
                                : null,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: _selectedFilter == f
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _selectedFilter == f
                                    ? AppColors.primary
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isFilterActive
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isFilterActive
                          ? AppColors.primary
                          : AppColors.borderMedium,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 18,
                        color: isFilterActive
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filterLabel,
                        style: TextStyle(
                          fontSize:
                              context.scaleText(13, medium: 13.5, expanded: 14),
                          fontWeight: FontWeight.w600,
                          height: 1,
                          color: isFilterActive
                              ? AppColors.primary
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down_rounded,
                          size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ),
              );

              final skriningBtn = SizedBox(
                height: 44,
                child: FilledButton.icon(
                  onPressed: _openSkriningBaru,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Skrining Baru',
                    style: TextStyle(
                      fontSize:
                          context.scaleText(13, medium: 13.5, expanded: 14),
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.heroButton,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    maximumSize: const Size(double.infinity, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              );

              if (constraints.maxWidth >= 640) {
                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 12),
                    filterBtn,
                    const SizedBox(width: 12),
                    skriningBtn,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchField,
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      filterBtn,
                      const Spacer(),
                      skriningBtn,
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Data Table Card - Excel-like
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
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
                          'Tidak ada data skrining yang sesuai',
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
                      ExcelTable(
                        columns: const [
                          ExcelColumn(
                              label: 'Nama Peserta', flex: 3, minWidth: 160),
                          ExcelColumn(label: 'Tanggal', flex: 1.8, minWidth: 110),
                          ExcelColumn(label: 'Skor', flex: 1, minWidth: 80),
                          ExcelColumn(
                              label: 'Kategori Risiko', flex: 2.2, minWidth: 140),
                          ExcelColumn(label: 'Aksi', flex: 1.6, minWidth: 110),
                        ],
                        rows: filteredList.map((record) {
                          return [
                            Text(
                              record.nama,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.scaleText(13.5,
                                      medium: 14, expanded: 14.5)),
                            ),
                            Text(
                              record.tanggal,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: context.scaleText(13,
                                      medium: 13.5, expanded: 14)),
                            ),
                            Text(
                              record.skorLabel,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: record.isRedFlag
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: record.isRedFlag
                                    ? Colors.redAccent
                                    : AppColors.textDark,
                                fontSize: context.scaleText(
                                    record.isRedFlag ? 11 : 13.5,
                                    medium: record.isRedFlag ? 11.5 : 14,
                                    expanded:
                                        record.isRedFlag ? 12 : 14.5),
                              ),
                            ),
                            _buildStatusBadge(record),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18, color: Colors.orange),
                                  tooltip: 'Edit Data',
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Colors.redAccent),
                                  tooltip: 'Hapus Data',
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  onPressed: () => _confirmDelete(record),
                                ),
                              ],
                            ),
                          ];
                        }).toList(),
                      ),
                      const Divider(height: 1),

                      // Table Footer
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            Text(
                              'Menampilkan ${filteredList.length} dari ${_dummySkrining.length} total peserta',
                              style: TextStyle(
                                  fontSize: context.scaleText(12,
                                      medium: 12.5, expanded: 13),
                                  color: AppColors.textMuted),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.scaleText(12,
                                            medium: 12.5, expanded: 13)),
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

  Future<void> _confirmDelete(SkriningRecord record) async {
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
                'Hapus Data Skrining',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus data skrining "${record.nama}"? '
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
      setState(() => _dummySkrining.remove(record));
    }
  }

  Widget _buildStatusBadge(SkriningRecord record) {
    Color bg;
    Color fg;

    switch (record.kategori) {
      case SkriningKategori.rendah:
        bg = AppColors.badgeBgSuccess;
        fg = AppColors.badgeTextSuccess;
        break;
      case SkriningKategori.sedang:
        bg = AppColors.badgeBgWarning;
        fg = AppColors.badgeTextWarning;
        break;
      case SkriningKategori.tinggi:
        bg = const Color(0xFFFEF2F2);
        fg = Colors.redAccent;
        break;
      case SkriningKategori.kritis:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        record.kategori.label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: context.scaleText(
            record.isRedFlag ? 10.5 : 11.5,
            medium: record.isRedFlag ? 11 : 12,
            expanded: record.isRedFlag ? 11.5 : 12.5,
          ),
        ),
      ),
    );
  }
}
