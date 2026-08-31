import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/widgets/custom_title_bar.dart';
import 'package:eposwa/core/widgets/pendaftar_command_dialog.dart';
import 'package:eposwa/features/skrining/domain/skrining_data.dart';

/// Form kuesioner skrining kesehatan jiwa (10 pertanyaan Ya/Tidak).
/// Mengikuti aturan skrining "Panduan Skrining Posyandu Jiwa Digital".
class SkriningFormPage extends StatefulWidget {
  const SkriningFormPage({super.key});

  @override
  State<SkriningFormPage> createState() => _SkriningFormPageState();
}

class _SkriningFormPageState extends State<SkriningFormPage> {
  final TextEditingController _namaController = TextEditingController();
  final List<bool?> _jawaban = List<bool?>.filled(10, null);

  SkriningHasil? _hasil;

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _hitungHasil() {
    if (_namaController.text.trim().isEmpty) {
      _showSnack('Nama peserta / pasien wajib diisi.');
      return;
    }
    if (!_jawaban.every((j) => j != null)) {
      _showSnack('Mohon jawab seluruh 10 pertanyaan skrining.');
      return;
    }
    setState(() {
      _hasil = SkriningHasil.hitung(_jawaban);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _simpan() {
    if (_hasil == null) return;
    final hasil = _hasil!;
    final now = DateTime.now();
    final tanggal = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final record = SkriningRecord.fromHasil(
      nama: _namaController.text.trim(),
      tanggal: tanggal,
      hasil: hasil,
    );
    Navigator.of(context).pop(record);
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
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Kembali',
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Skrining Jiwa Mandiri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'Inter',
                ),
              ),
              actions: [
                if (_hasil != null)
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _hasil = null;
                      for (var i = 0; i < _jawaban.length; i++) {
                        _jawaban[i] = null;
                      }
                    }),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Ulangi'),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: _hasil == null ? _buildForm() : _buildHasil(),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNamaField(),
              const SizedBox(height: 20),
              ...kSkriningPertanyaan.map(
                (q) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildQuestionCard(q),
                ),
              ),
              const SizedBox(height: 8),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNamaField() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Identitas Responden',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _namaController,
            readOnly: true,
            onTap: _openPendaftarCommand,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap Responden *',
              hintText: 'Klik untuk memilih pendaftar terdaftar',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.sectionLight,
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
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPendaftarCommand() async {
    final pendaftar = await showPendaftarCommandDialog(context);
    if (pendaftar != null && mounted) {
      setState(() => _namaController.text = pendaftar.nama);
    }
  }

  Widget _buildQuestionCard(SkriningPertanyaan q) {
    final index = q.nomor - 1;
    final value = _jawaban[index];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: q.isRedFlag
              ? Colors.redAccent.withValues(alpha: 0.5)
              : AppColors.borderLight,
          width: q.isRedFlag ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: q.isRedFlag
                      ? Colors.redAccent
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${q.nomor}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (q.isRedFlag)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'RED FLAG',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    Text(
                      q.teks,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      q.domain,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Ya'),
                  icon: Icon(Icons.check_rounded, size: 16),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Tidak'),
                  icon: Icon(Icons.close_rounded, size: 16),
                ),
              ],
              selected: {?value},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                setState(() => _jawaban[index] = selection.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStateProperty.all(
                  const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: _hitungHasil,
        icon: const Icon(Icons.calculate_rounded, size: 20),
        label: const Text(
          'Hitung Hasil Skrining',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.heroButton,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildHasil() {
    final hasil = _hasil!;
    final isKrisis = hasil.kategori == SkriningKategori.kritis;

    final Color bannerBg =
        isKrisis ? const Color(0xFFFEF2F2) : AppColors.badgeBgSuccess;
    final Color bannerBorder =
        isKrisis ? Colors.redAccent : AppColors.badgeTextSuccess;
    final Color bannerFg =
        isKrisis ? Colors.redAccent : AppColors.badgeTextSuccess;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bannerBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: bannerBorder, width: 1.5),
                ),
                child: Column(
                  children: [
                    Icon(
                      isKrisis
                          ? Icons.warning_amber_rounded
                          : Icons.fact_check_rounded,
                      size: 44,
                      color: bannerFg,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isKrisis
                          ? 'KRISIS PSIKIATRI'
                          : 'Hasil Skrining: ${hasil.kategori.label}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: bannerFg,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Responden: ${_namaController.text.trim()}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (!isKrisis) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: bannerBorder, width: 2),
                        ),
                        child: Text(
                          '${hasil.skor}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: bannerFg,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Total skor (jumlah jawaban "Ya" pertanyaan 1-9)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rekomendasi & Alur Kerja',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasil.rekomendasi,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: AppColors.textDark,
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
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'Segera laporkan ke Perawat Pembina Kesehatan Jiwa Puskesmas '
                          '(notifikasi prioritas tinggi P1) dan pastikan responden dalam pengawasan.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: const Text(
                    'Simpan ke Daftar Skrining',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.heroButton,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}