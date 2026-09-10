import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/database/app_database.dart';
import 'package:eposwa/core/widgets/custom_title_bar.dart';

/// Halaman detail identitas peserta — menampilkan seluruh data formulir
/// pendaftaran (Data Diri & Riwayat Kesehatan Jiwa).
/// Dibuka dari tombol "Lihat Detail" di halaman detail peserta.
class IdentitasDetailPage extends StatelessWidget {
  final Peserta peserta;

  const IdentitasDetailPage({super.key, required this.peserta});

  String _yaTidak(bool? value) {
    if (value == null) return '-';
    return value ? 'Ya' : 'Tidak';
  }

  @override
  Widget build(BuildContext context) {
    final p = peserta;
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
                'Detail Identitas',
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
                      _buildSection(
                        title: 'Data Diri',
                        icon: Icons.person_outline_rounded,
                        rows: [
                          ('Nama Lengkap', p.nama),
                          ('NIK', p.nik),
                          ('Tanggal Lahir', p.tglLahir ?? '-'),
                          ('Jenis Kelamin', p.jenisKelamin),
                          ('No. HP / WhatsApp', p.noHp),
                          ('Alamat', p.alamat ?? '-'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Riwayat Kesehatan Jiwa',
                        icon: Icons.psychology_outlined,
                        rows: [
                          ('Pernah konsultasi jiwa sebelumnya?',
                              _yaTidak(p.pernahKonsultasi)),
                          ('Pernah mendapatkan obat sebelumnya?',
                              _yaTidak(p.pernahDapatObat)),
                        ],
                      ),
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<(String, String)> rows,
  }) {
    return Container(
      width: double.infinity,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _detailRow(rows[i].$1, rows[i].$2),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 220,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
