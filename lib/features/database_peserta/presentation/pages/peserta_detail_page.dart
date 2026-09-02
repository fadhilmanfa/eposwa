import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/core/widgets/custom_title_bar.dart';
import 'package:eposwa/core/widgets/excel_table.dart';
import 'package:eposwa/features/database_peserta/presentation/pages/identitas_detail_page.dart';
import 'package:eposwa/features/skrining/data/skrining_repository.dart';
import 'package:eposwa/features/skrining/domain/skrining_data.dart' as ui;
import 'package:eposwa/features/skrining/presentation/pages/skrining_detail_page.dart';

/// Halaman detail peserta — info peserta + riwayat skrining (bisa berkali-kali).
/// Dibuka dari ikon mata di tabel Database Peserta.
class PesertaDetailPage extends StatefulWidget {
  final Peserta peserta;

  const PesertaDetailPage({super.key, required this.peserta});

  @override
  State<PesertaDetailPage> createState() => _PesertaDetailPageState();
}

class _PesertaDetailPageState extends State<PesertaDetailPage> {
  late SkriningRepository _repo;
  List<SkriningRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = SkriningRepository(getAppDatabase());
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.getByPesertaId(widget.peserta.id);
    if (!mounted) return;
    setState(() {
      _records = list;
      _loading = false;
    });
  }

  Future<void> _openDetail(SkriningRecord rec) async {
    final jawabanRows = await _repo.getJawaban(rec.id);
    final jawaban = List<bool?>.generate(10, (i) {
      final row = jawabanRows.where((j) => j.nomor == i + 1).firstOrNull;
      return row?.jawaban;
    });
    final kategori = ui.SkriningKategori.values.firstWhere(
      (k) => k.name == rec.kategori,
      orElse: () => ui.SkriningKategori.rendah,
    );
    final record = ui.SkriningRecord(
      nama: widget.peserta.nama,
      tanggal: rec.tanggal,
      skor: rec.skor,
      kategori: kategori,
      isRedFlag: rec.isRedFlag,
      jawaban: jawaban,
    );
    if (!mounted) return;
    final updated = await Navigator.of(context).push<ui.SkriningRecord>(
      MaterialPageRoute(builder: (_) => SkriningDetailPage(record: record)),
    );
    if (updated != null && mounted) {
      final hasil = ui.SkriningHasil.hitung(updated.jawaban);
      await _repo.updateSkrining(
        skriningId: rec.id,
        tanggal: updated.tanggal,
        skor: hasil.skor,
        kategori: updated.kategori.name,
        isRedFlag: hasil.isRedFlag,
        rekomendasi: hasil.rekomendasi,
        jawaban: updated.jawaban,
      );
      await _load();
    }
  }

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
    return Column(
      children: [
        const CustomTitleBar(),
        Expanded(
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                tooltip: 'Kembali',
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Detail Peserta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'Inter',
                ),
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child:
                    Divider(height: 1, thickness: 1, color: AppColors.borderLight),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      _buildRiwayatCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final p = widget.peserta;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _detailRow('NIK', p.nik),
          _detailRow('No. WhatsApp', p.noHp),
          _detailRow('Tanggal Daftar', p.tglDaftar),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => IdentitasDetailPage(peserta: widget.peserta),
                  ),
                );
              },
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('Lihat Detail',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                const Icon(Icons.fact_check_outlined,
                    color: AppColors.heroButton, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Skrining',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        _loading
                            ? 'Memuat...'
                            : '${_records.length} sesi skrining',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: const [
                  Icon(Icons.fact_check_outlined,
                      size: 40, color: AppColors.textMuted),
                  SizedBox(height: 10),
                  Text(
                    'Belum ada riwayat skrining untuk peserta ini.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: ExcelTable(
                columns: const [
                  ExcelColumn(
                      label: 'Tgl Skrining', flex: 1.8, minWidth: 120),
                  ExcelColumn(label: 'Skor', flex: 1, minWidth: 80),
                  ExcelColumn(
                      label: 'Kategori Risiko', flex: 2.2, minWidth: 140),
                  ExcelColumn(
                      label: 'Aksi',
                      flex: 1.2,
                      minWidth: 90,
                      sortable: false),
                ],
                rows: _records.map((rec) {
                  final kategoriLabel = _kategoriLabel(rec.kategori);
                  return [
                    Text(
                      rec.tanggal,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize:
                              context.scaleText(13, medium: 13.5, expanded: 14)),
                    ),
                    Text(
                      rec.isRedFlag ? 'RED FLAG' : '${rec.skor ?? 0}',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight:
                            rec.isRedFlag ? FontWeight.w800 : FontWeight.w600,
                        color: rec.isRedFlag
                            ? Colors.redAccent
                            : AppColors.textDark,
                        fontSize: context.scaleText(
                            rec.isRedFlag ? 11 : 13.5,
                            medium: rec.isRedFlag ? 11.5 : 14,
                            expanded: rec.isRedFlag ? 12 : 14.5),
                      ),
                    ),
                    _buildKategoriBadge(kategoriLabel, rec.isRedFlag),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined,
                              size: 18, color: AppColors.primary),
                          tooltip: 'Lihat Detail',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 32, minHeight: 32),
                          onPressed: () => _openDetail(rec),
                        ),
                      ],
                    ),
                  ];
                }).toList(),
              ),
            ),
          if (!_loading && _records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Menampilkan ${_records.length} dari ${_records.length} total sesi',
                style: TextStyle(
                    fontSize:
                        context.scaleText(12, medium: 12.5, expanded: 13),
                    color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
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
    } else {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: context.scaleText(isRedFlag ? 10.5 : 11.5,
              medium: isRedFlag ? 11 : 12, expanded: isRedFlag ? 11.5 : 12.5),
        ),
      ),
    );
  }
}
