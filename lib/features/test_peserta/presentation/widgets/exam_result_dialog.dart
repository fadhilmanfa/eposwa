import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

/// Modal Dialog Rapor & Detail Hasil Ujian Peserta.
class ExamResultDialog extends StatelessWidget {
  final Map<String, dynamic> testData;
  final VoidCallback? onReEvaluate;

  const ExamResultDialog({
    super.key,
    required this.testData,
    this.onReEvaluate,
  });

  @override
  Widget build(BuildContext context) {
    final status = testData['status'] as String? ?? 'Belum Ujian';
    final skor = (testData['skor'] as num?)?.toInt() ?? 0;
    final isPassed = status == 'Lulus';
    final isFailed = status == 'Tidak Lulus';
    final isPending = !isPassed && !isFailed;

    final Color statusColor = isPassed
        ? const Color(0xFF10B981)
        : (isFailed ? Colors.redAccent : const Color(0xFF3B82F6));

    final skorPengetahuan = (testData['skorPengetahuan'] as num?)?.toInt() ?? (isPassed ? 85 : 0);
    final skorPsikologis = (testData['skorPsikologis'] as num?)?.toInt() ?? (isPassed ? 90 : 0);
    final skorWawancara = (testData['skorWawancara'] as num?)?.toInt() ?? (isPassed ? 80 : 0);
    final catatan = testData['catatan']?.toString();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Rapor Hasil Ujian & Penilaian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Main Score Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.08),
                      statusColor.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      testData['nama'] ?? '-',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIK: ${testData['nik'] ?? '-'} • Program: ${testData['program'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          isPending ? '-' : '$skor',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: -1,
                            fontFamily: 'Inter',
                          ),
                        ),
                        if (!isPending)
                          const Text(
                            ' / 100',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Rincian Nilai Komponen
              const Text(
                'Rincian Komponen Nilai',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              _buildScoreRow(
                label: 'Tes Pengetahuan & Potensi (30%)',
                score: skorPengetahuan,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 10),
              _buildScoreRow(
                label: 'Skrining Kesehatan Jiwa & Sikap (40%)',
                score: skorPsikologis,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 10),
              _buildScoreRow(
                label: 'Wawancara & Observasi Kader (30%)',
                score: skorWawancara,
                color: const Color(0xFFF59E0B),
              ),

              const SizedBox(height: 20),

              // Catatan Evaluator
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notes_rounded, size: 16, color: AppColors.textMuted),
                        SizedBox(width: 6),
                        Text(
                          'Catatan & Rekomendasi Evaluator',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (catatan != null && catatan.isNotEmpty)
                          ? catatan
                          : (isPassed
                              ? 'Peserta menunjukkan pemahaman yang sangat baik dan memenuhi standar kualifikasi ePOSWA.'
                              : (isFailed
                                  ? 'Nilai belum memenuhi batas kelulusan minimal (Passing grade: 70). Disarankan mengikuti sesi remedial.'
                                  : 'Belum ada catatan evaluasi untuk peserta ini.')),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Mencetak Rapor Ujian untuk "${testData['nama']}"...',
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text(
                        'Cetak / Unduh PDF',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.heroButton,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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
  }

  Widget _buildScoreRow({
    required String label,
    required int score,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$score / 100',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100.0,
            minHeight: 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
