import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/core/widgets/excel_table.dart';
import 'package:eposwa/features/database_peserta/presentation/pages/peserta_detail_page.dart';
import 'package:eposwa/features/pendaftaran/data/peserta_repository.dart';
import 'package:eposwa/features/skrining/data/skrining_repository.dart';
import 'package:eposwa/features/skrining/domain/skrining_data.dart'
    show SkriningKategori, SkriningKategoriX;

class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => DatabasePageState();
}

class DatabasePageState extends State<DatabasePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedKategori = 'Semua';
  int? _sortColumnIndex;
  SortDirection? _sortDirection;
  List<Peserta> _pesertas = [];
  Map<int, SkriningRecord> _latestSkrining = {};
  bool _loading = true;
  late PesertaRepository _repo;
  late SkriningRepository _skriningRepo;

  static const _kategoriOrder = [
    'Risiko Rendah',
    'Risiko Sedang',
    'Risiko Tinggi',
    'KRITIS',
    'Belum Skrining',
  ];

  int _kategoriRank(String label) {
    final idx = _kategoriOrder.indexOf(label);
    return idx == -1 ? _kategoriOrder.length : idx;
  }

  String _kategoriLabel(String kategori) {
    switch (kategori) {
      case 'rendah':
        return SkriningKategori.rendah.label;
      case 'sedang':
        return SkriningKategori.sedang.label;
      case 'tinggi':
        return SkriningKategori.tinggi.label;
      case 'kritis':
        return SkriningKategori.kritis.label;
      default:
        return kategori;
    }
  }

  String _kategoriOfPeserta(Peserta item) {
    final rec = _latestSkrining[item.id];
    if (rec == null) return 'Belum Skrining';
    return _kategoriLabel(rec.kategori);
  }

  bool _isRedFlag(Peserta item) => _latestSkrining[item.id]?.isRedFlag ?? false;

  DateTime _parseTgl(String s) {
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

  List<Peserta> _applySort(List<Peserta> source) {
    final col = _sortColumnIndex;
    if (col == null) return source;
    final dir = _sortDirection == SortDirection.desc ? -1 : 1;
    final sorted = List<Peserta>.from(source);
    switch (col) {
      case 0:
        sorted.sort((a, b) => dir * a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
        break;
      case 1:
        sorted.sort((a, b) => dir * _parseTgl(a.tglDaftar).compareTo(_parseTgl(b.tglDaftar)));
        break;
      case 3:
        sorted.sort((a, b) => dir * _kategoriRank(_kategoriOfPeserta(a)).compareTo(_kategoriRank(_kategoriOfPeserta(b))));
        break;
    }
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _repo = PesertaRepository(getAppDatabase());
    _skriningRepo = SkriningRepository(getAppDatabase());
    _load();
  }

  /// Muat ulang data dari database. Dipanggil dari luar (mis. MainLayout)
  /// setiap kali halaman Database menjadi tab aktif agar "Risiko Terakhir"
  /// selalu segar setelah ada skrining/update dari halaman lain.
  Future<void> refresh() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.getAll();
    final allSkrining = await _skriningRepo.getAll();
    final latest = <int, SkriningRecord>{};
    for (final rec in allSkrining) {
      final existing = latest[rec.pesertaId];
      if (existing == null ||
          _parseTgl(rec.tanggal).isAfter(_parseTgl(existing.tanggal)) ||
          (_parseTgl(rec.tanggal).isAtSameMomentAs(
                  _parseTgl(existing.tanggal)) &&
              rec.id > existing.id)) {
        latest[rec.pesertaId] = rec;
      }
    }
    if (!mounted) return;
    setState(() {
      _pesertas = list;
      _latestSkrining = latest;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final filtered = _pesertas.where((item) {
      final q = _searchController.text.toLowerCase();
      final kategoriLabel = _kategoriOfPeserta(item);
      final matchesSearch = q.isEmpty ||
          item.nama.toLowerCase().contains(q) ||
          item.noHp.contains(q) ||
          item.tglDaftar.toLowerCase().contains(q) ||
          kategoriLabel.toLowerCase().contains(q);
      final matchesKategori =
          _selectedKategori == 'Semua' || kategoriLabel == _selectedKategori;
      return matchesSearch && matchesKategori;
    }).toList();
    final sorted = _applySort(filtered);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter — disamakan dengan Skrining & Penilaian
          LayoutBuilder(
            builder: (context, constraints) {
              final searchField = SizedBox(
                height: 44,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari Nama, No. WhatsApp...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.borderLight, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.borderLight, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              );

              final isFilterActive = _selectedKategori != 'Semua';
              final filterLabel = isFilterActive
                  ? 'Filter: $_selectedKategori'
                  : 'Filter';

              const kategoriOptions = [
                'Semua',
                'Risiko Rendah',
                'Risiko Sedang',
                'Risiko Tinggi',
                'KRITIS',
                'Belum Skrining',
              ];

              PopupMenuItem<String> buildOption(String value, bool selected) {
                return PopupMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                size: 16, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          value.split(':').last,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final filterBtn = PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                onSelected: (v) => setState(() => _selectedKategori = v),
                itemBuilder: (context) => [
                  for (final s in kategoriOptions)
                    buildOption(s, _selectedKategori == s),
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
                      Flexible(
                        child: Text(
                          filterLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down_rounded,
                          size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ),
              );

              if (constraints.maxWidth >= 640) {
                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 12),
                    filterBtn,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchField,
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [filterBtn]),
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
                      ExcelTable(
                        columns: const [
                          ExcelColumn(
                              label: 'Nama Peserta', flex: 3, minWidth: 150),
                          ExcelColumn(
                              label: 'Tgl Daftar', flex: 1.4, minWidth: 110),
                          ExcelColumn(
                              label: 'No. WhatsApp',
                              flex: 2,
                              minWidth: 130,
                              sortable: false),
                          ExcelColumn(label: 'Risiko Terakhir', flex: 2, minWidth: 140),
                          ExcelColumn(
                              label: 'Aksi',
                              flex: 1.6,
                              minWidth: 120,
                              sortable: false),
                        ],
                        sortColumnIndex: _sortColumnIndex,
                        sortDirection: _sortDirection,
                        onSort: _onSort,
                        rows: sorted.map((item) {
                          final kategoriLabel = _kategoriOfPeserta(item);
                          final isRedFlag = _isRedFlag(item);
                          return [
                            Text(
                              item.nama,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: context.scaleText(13.5, medium: 14, expanded: 14.5),
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              item.tglDaftar,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: context.scaleText(13, medium: 13.5, expanded: 14)),
                            ),
                            Text(
                              item.noHp,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: context.scaleText(13, medium: 13.5, expanded: 14)),
                            ),
                            _buildKategoriBadge(kategoriLabel, isRedFlag),
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
                              'Menampilkan ${sorted.length} dari ${_pesertas.length} total peserta',
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

  Future<void> _showDetail(Peserta item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PesertaDetailPage(peserta: item)),
    );
    if (mounted) await _load();
  }

  Future<void> _confirmDelete(Peserta item) async {
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
                decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Hapus Data Peserta', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Apakah Anda yakin ingin menghapus data peserta "${item.nama}"? Tindakan ini tidak dapat dibatalkan.',
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: AppColors.borderMedium), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Batal', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w600)),
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
      await _repo.deletePeserta(item.id);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Peserta "${item.nama}" dihapus'), backgroundColor: Colors.redAccent));
    }
  }

  Widget _buildKategoriBadge(String label, bool isRedFlag) {
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
    } else if (label == 'Belum Skrining') {
      bg = AppColors.sectionCardBg;
      fg = AppColors.textMuted;
    } else {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: context.scaleText(isRedFlag ? 10.5 : 11,
              medium: isRedFlag ? 11 : 11.5, expanded: isRedFlag ? 11.5 : 12),
        ),
      ),
    );
  }
}
