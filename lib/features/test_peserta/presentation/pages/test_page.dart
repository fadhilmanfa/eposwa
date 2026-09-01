import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/database/app_database.dart' hide SkriningRecord;
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/core/services/export_service.dart';
import 'package:eposwa/core/services/import_service.dart';
import 'package:eposwa/core/widgets/excel_table.dart';
import 'package:eposwa/features/skrining/data/skrining_repository.dart';
import 'package:eposwa/features/skrining/domain/skrining_data.dart';
import 'package:eposwa/features/skrining/presentation/pages/skrining_detail_page.dart';
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
  int? _sortColumnIndex;
  SortDirection? _sortDirection;
  List<SkriningWithPeserta> _items = [];
  bool _loading = true;
  late SkriningRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = SkriningRepository(getAppDatabase());
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.getAllWithPeserta();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _handleExport() async {
    try {
      final path = await ExportService.exportSql();
      if (!mounted) return;
      if (path == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export dibatalkan')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SQL di-export: $path'), backgroundColor: AppColors.primary));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal export: $e'), backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _handleImport() async {
    try {
      final result = await ImportService.importSqlWithDialog(context);
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import dibatalkan')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import: ${result.imported} baru, ${result.skipped} lewati, ${result.replaced} timpa, ${result.merged} gabung'), backgroundColor: AppColors.primary));
        await _load();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal import: $e'), backgroundColor: Colors.redAccent));
    }
  }

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
      await _load();
    }
  }

  Future<void> _openEdit(SkriningWithPeserta item) async {
    // Convert to SkriningRecord for form
    final rec = item.skrining;
    final jawabanRows = await _repo.getJawaban(rec.id);
    final jawaban = List<bool?>.generate(10, (i) {
      final row = jawabanRows.where((j) => j.nomor == i + 1).firstOrNull;
      return row?.jawaban;
    });
    final kategori = SkriningKategori.values.firstWhere((k) => k.name == rec.kategori, orElse: () => SkriningKategori.rendah);
    final record = SkriningRecord(
      nama: item.peserta.nama,
      tanggal: rec.tanggal,
      skor: rec.skor,
      kategori: kategori,
      isRedFlag: rec.isRedFlag,
      jawaban: jawaban,
    );
    if (!mounted) return;
    final updated = await Navigator.of(context).push<SkriningRecord>(
      MaterialPageRoute(builder: (context) => SkriningFormPage(initialRecord: record)),
    );
    if (updated != null && mounted) {
      // update DB record
      final newKategori = updated.kategori.name;
      final hasil = SkriningHasil.hitung(updated.jawaban);
      await _repo.updateSkrining(
        skriningId: rec.id,
        tanggal: updated.tanggal,
        skor: hasil.skor,
        kategori: newKategori,
        isRedFlag: hasil.isRedFlag,
        rekomendasi: hasil.rekomendasi,
        jawaban: updated.jawaban,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data skrining "${updated.nama}" berhasil diperbarui.'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.primary),
        );
      }
    }
  }

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

  List<SkriningWithPeserta> _applySort(List<SkriningWithPeserta> source) {
    final col = _sortColumnIndex;
    if (col == null) return source;
    final dir = _sortDirection == SortDirection.desc ? -1 : 1;
    final sorted = List<SkriningWithPeserta>.from(source);
    switch (col) {
      case 0:
        sorted.sort((a, b) => dir * a.peserta.nama.toLowerCase().compareTo(b.peserta.nama.toLowerCase()));
        break;
      case 1:
        sorted.sort((a, b) => dir * _parseTanggal(a.skrining.tanggal).compareTo(_parseTanggal(b.skrining.tanggal)));
        break;
      case 2:
        sorted.sort((a, b) => dir * (a.skrining.skor ?? 0).compareTo(b.skrining.skor ?? 0));
        break;
      case 3:
        sorted.sort((a, b) => dir * a.skrining.kategori.compareTo(b.skrining.kategori));
        break;
    }
    return sorted;
  }

  DateTime _parseTanggal(String s) {
    final parts = s.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }
    return DateTime(1970);
  }

  String _skorLabelDb(dynamic r) => (r.isRedFlag as bool) ? 'RED FLAG' : '${(r.skor as int?) ?? 0}';
  String _kategoriLabel(String kategori) {
    switch (kategori) {
      case 'rendah':
        return 'Risiko Rendah';
      case 'sedang':
        return 'Risiko Sedang';
      case 'tinggi':
        return 'Risiko Tinggi';
      case 'kritis':
        return 'KRITIS';
      default:
        return kategori;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final filteredList = _items.where((item) {
      final kategoriLabel = _kategoriLabel(item.skrining.kategori);
      final matchesFilter = _selectedFilter == 'Semua' || kategoriLabel.toLowerCase() == _selectedFilter.toLowerCase();
      final q = _searchController.text.toLowerCase();
      final matchesSearch = item.peserta.nama.toLowerCase().contains(q) ||
          item.skrining.tanggal.toLowerCase().contains(q) ||
          _skorLabelDb(item.skrining).toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
    final sortedList = _applySort(filteredList);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

              final exportBtn = OutlinedButton.icon(
                onPressed: _handleExport,
                icon: const Icon(Icons.upload_rounded, size: 16),
                label: const Text('Export SQL'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              );
              final importBtn = FilledButton.icon(
                onPressed: _handleImport,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Import SQL'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    const SizedBox(width: 8),
                    exportBtn,
                    const SizedBox(width: 8),
                    importBtn,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchField,
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [filterBtn, skriningBtn, exportBtn, importBtn]),
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
                          ExcelColumn(label: 'Tgl Daftar', flex: 1.8, minWidth: 110),
                          ExcelColumn(label: 'Skor', flex: 1, minWidth: 80),
                          ExcelColumn(
                              label: 'Kategori Risiko', flex: 2.2, minWidth: 140),
                          ExcelColumn(
                              label: 'Aksi',
                              flex: 2.2,
                              minWidth: 130,
                              sortable: false),
                        ],
                        sortColumnIndex: _sortColumnIndex,
                        sortDirection: _sortDirection,
                        onSort: _onSort,
                        rows: sortedList.map((item) {
                          final record = item.skrining;
                          final nama = item.peserta.nama;
                          final skorLabel = record.isRedFlag ? 'RED FLAG' : '${record.skor ?? 0}';
                          final kategoriLabel = _kategoriLabel(record.kategori);
                          return [
                            Text(
                              nama,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.scaleText(13.5, medium: 14, expanded: 14.5), color: AppColors.textDark),
                            ),
                            Text(
                              record.tanggal,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: context.scaleText(13, medium: 13.5, expanded: 14)),
                            ),
                            Text(
                              skorLabel,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: record.isRedFlag ? FontWeight.w800 : FontWeight.w600,
                                color: record.isRedFlag ? Colors.redAccent : AppColors.textDark,
                                fontSize: context.scaleText(record.isRedFlag ? 11 : 13.5, medium: record.isRedFlag ? 11.5 : 14, expanded: record.isRedFlag ? 12 : 14.5),
                              ),
                            ),
                            _buildStatusBadgeForKategori(kategoriLabel, record.isRedFlag),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                  tooltip: 'Lihat Detail',
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () => _showDetail(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.orange),
                                  tooltip: 'Edit Data',
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () => _openEdit(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                  tooltip: 'Hapus Data',
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () => _confirmDelete(item),
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
                              'Menampilkan ${sortedList.length} dari ${_items.length} total sesi',
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

  Future<void> _showDetail(SkriningWithPeserta item) async {
    final rec = item.skrining;
    final jawabanRows = await _repo.getJawaban(rec.id);
    final jawaban = List<bool?>.generate(10, (i) {
      final row = jawabanRows.where((j) => j.nomor == i + 1).firstOrNull;
      return row?.jawaban;
    });
    final kategori = SkriningKategori.values.firstWhere((k) => k.name == rec.kategori, orElse: () => SkriningKategori.rendah);
    final record = SkriningRecord(nama: item.peserta.nama, tanggal: rec.tanggal, skor: rec.skor, kategori: kategori, isRedFlag: rec.isRedFlag, jawaban: jawaban);
    if (!mounted) return;
    final updated = await Navigator.of(context).push<SkriningRecord>(MaterialPageRoute(builder: (_) => SkriningDetailPage(record: record)));
    if (updated != null && mounted) {
      final hasil = SkriningHasil.hitung(updated.jawaban);
      await _repo.updateSkrining(skriningId: rec.id, tanggal: updated.tanggal, skor: hasil.skor, kategori: updated.kategori.name, isRedFlag: hasil.isRedFlag, rekomendasi: hasil.rekomendasi, jawaban: updated.jawaban);
      await _load();
    }
  }

  Future<void> _confirmDelete(SkriningWithPeserta item) async {
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
              Container(width: 56, height: 56, decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle), child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28)),
              const SizedBox(height: 16),
              const Text('Hapus Data Skrining', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Apakah Anda yakin ingin menghapus data skrining "${item.peserta.nama}"? Tindakan ini tidak dapat dibatalkan.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context, false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: AppColors.borderMedium), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Batal', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && mounted) {
      await _repo.deleteSkrining(item.skrining.id);
      await _load();
    }
  }

  Widget _buildStatusBadgeForKategori(String label, bool isRedFlag) {
    Color bg;
    Color fg;
    if (label == 'Risiko Rendah') {
      bg = AppColors.badgeBgSuccess;
      fg = AppColors.badgeTextSuccess;
    } else if (label == 'Risiko Sedang') {
      bg = AppColors.badgeBgWarning;
      fg = AppColors.badgeTextWarning;
    } else if (label == 'Risiko Tinggi') {
      bg = const Color(0xFFFEF2F2);
      fg = Colors.redAccent;
    } else {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: context.scaleText(isRedFlag ? 10.5 : 11.5, medium: isRedFlag ? 11 : 12, expanded: isRedFlag ? 11.5 : 12.5))),
    );
  }
}
