import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/widgets/custom_title_bar.dart';
import 'package:eposwa/core/widgets/excel_table.dart';
import 'package:eposwa/features/skrining/domain/skrining_data.dart';
import 'package:eposwa/features/skrining/presentation/pages/skrining_form_page.dart';

/// Halaman detail skrining - minimalis, bersih, konsisten dengan Pendaftaran & Beranda.
class SkriningDetailPage extends StatefulWidget {
  final SkriningRecord record;

  const SkriningDetailPage({super.key, required this.record});

  @override
  State<SkriningDetailPage> createState() => _SkriningDetailPageState();
}

class _SkriningDetailPageState extends State<SkriningDetailPage> {
  late SkriningRecord _record;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<SkriningRecord>(
      MaterialPageRoute(builder: (_) => SkriningFormPage(initialRecord: _record)),
    );
    if (updated != null && mounted) {
      setState(() {
        _record = updated;
        _hasChanged = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data "${_record.nama}" diperbarui.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.heroButton,
        ),
      );
    }
  }

  void _handleBack() {
    if (_hasChanged) {
      Navigator.of(context).pop(_record);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final jawaban = _record.jawabanEfektif;
    final hasil = SkriningHasil.hitung(jawaban);
    final isKrisis = hasil.kategori == SkriningKategori.kritis;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Column(
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
                  onPressed: _handleBack,
                ),
                title: const Text(
                  'Detail Skrining',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    fontFamily: 'Inter',
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                    tooltip: 'Edit',
                    onPressed: _openEdit,
                  ),
                  const SizedBox(width: 4),
                ],
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(1),
                  child: Divider(height: 1, thickness: 1, color: AppColors.borderLight),
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
                        // — Header minimalis: kategori + skor
                        _buildHeaderCard(hasil, isKrisis),
                        const SizedBox(height: 20),

                        // — Rekomendasi
                        _buildSectionCard(
                          title: 'Rekomendasi Tindak Lanjut',
                          subtitle: isKrisis ? 'Prioritas tinggi — perlu penanganan segera' : 'Saran berdasarkan skor dan kategori',
                          icon: Icons.lightbulb_outline_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasil.rekomendasi,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  height: 1.6,
                                  color: Color(0xFF334155),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              if (isKrisis) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: const Border(left: BorderSide(color: Colors.redAccent, width: 3)),
                                  ),
                                  child: const Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.warning_amber_rounded, size: 16, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Segera hubungi Perawat Pembina Jiwa Puskesmas & pastikan responden dalam pengawasan.',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            height: 1.5,
                                            color: Color(0xFFB91C1C),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // — Rincian jawaban
                        _buildSectionCard(
                          title: 'Rincian Jawaban',
                          subtitle: '10 pertanyaan — geser kolom untuk melihat lengkap',
                          icon: Icons.list_alt_rounded,
                          child: ExcelTable(
                            columns: const [
                              ExcelColumn(label: 'No', flex: 0.6, minWidth: 56),
                              ExcelColumn(label: 'Pertanyaan', flex: 3.8, minWidth: 280),
                              ExcelColumn(label: 'Jawab', flex: 0.9, minWidth: 88),
                            ],
                            wrapColumns: {1},
                            rowHeight: 64,
                            rowLeftBorders: [
                              for (final q in kSkriningPertanyaan) q.isRedFlag ? Colors.redAccent : null,
                            ],
                            rows: List.generate(10, (i) {
                              final q = kSkriningPertanyaan[i];
                              final ans = jawaban.length > i ? jawaban[i] : null;
                              final isYa = ans == true;
                              final isRed = q.isRedFlag;
                              return [
                                // No — lingkaran minimalis
                                Container(
                                  width: 20,
                                  height: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isRed ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: isRed
                                          ? Colors.redAccent.withValues(alpha: 0.2)
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Text(
                                    '${q.nomor}',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isRed ? Colors.redAccent : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                // Pertanyaan + domain sebagai subtext — wrap
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      q.teks,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        height: 1.45,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      q.domain,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        height: 1.3,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                // Jawab — pill Ya/Tidak
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isYa
                                        ? (isRed ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF))
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isYa
                                          ? (isRed
                                              ? Colors.redAccent.withValues(alpha: 0.35)
                                              : AppColors.primary.withValues(alpha: 0.28))
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Text(
                                    ans == null ? '-' : isYa ? 'Ya' : 'Tidak',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: ans == null
                                          ? AppColors.textMuted
                                          : isYa
                                              ? (isRed ? Colors.redAccent : AppColors.primary)
                                              : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ];
                            }),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bottom actions — minimal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _handleBack,
                              icon: const Icon(Icons.arrow_back_rounded, size: 16),
                              label: const Text('Kembali'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF64748B),
                                side: const BorderSide(color: AppColors.borderMedium),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _openEdit,
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit Data'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.heroButton,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(SkriningHasil hasil, bool isKrisis) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top meta: nama + tanggal (minimalis — badge dipindah ke bawah skor)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _record.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 5),
                  Text(
                    _record.tanggal,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          // total skor + kategori (tanpa badge) — minimalis
          if (!isKrisis)
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    '${hasil.skor}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total skor',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                      const SizedBox(height: 4),
                      Text(
                        hasil.kategori.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kategoriColor(hasil.kategori),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: Colors.redAccent, width: 3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flag_rounded, size: 14, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Krisis psikiatri — ideasi bunuh diri terdeteksi. Skor diabaikan.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
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
              Icon(icon, color: AppColors.heroButton, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          child,
        ],
      ),
    );
  }

  Color _kategoriColor(SkriningKategori kategori) {
    switch (kategori) {
      case SkriningKategori.rendah:
        return const Color(0xFF059669);
      case SkriningKategori.sedang:
        return const Color(0xFFD97706);
      case SkriningKategori.tinggi:
        return const Color(0xFFDC2626);
      case SkriningKategori.kritis:
        return const Color(0xFFB91C1C);
    }
  }
}
