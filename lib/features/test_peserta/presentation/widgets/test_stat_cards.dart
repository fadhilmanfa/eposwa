import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

/// Komponen 4 kartu KPI minimalis untuk halaman Ujian & Penilaian Peserta.
class TestStatCards extends StatelessWidget {
  final int totalPeserta;
  final int totalLulus;
  final int totalSedangUjian;
  final double rataRataSkor;

  const TestStatCards({
    super.key,
    required this.totalPeserta,
    required this.totalLulus,
    required this.totalSedangUjian,
    required this.rataRataSkor,
  });

  @override
  Widget build(BuildContext context) {
    final double passingRate = totalPeserta > 0
        ? (totalLulus / totalPeserta * 100)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;

        if (isNarrow) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MinimalStatCard(
                      label: 'Total Peserta',
                      value: '$totalPeserta',
                      badge: 'Terdaftar',
                      badgeColor: const Color(0xFF64748B),
                      icon: Icons.groups_outlined,
                      accentColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MinimalStatCard(
                      label: 'Lulus Seleksi',
                      value: '$totalLulus',
                      badge: '${passingRate.toStringAsFixed(0)}%',
                      badgeColor: const Color(0xFF10B981),
                      icon: Icons.check_circle_outline_rounded,
                      accentColor: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MinimalStatCard(
                      label: 'Sedang / Menunggu',
                      value: '$totalSedangUjian',
                      badge: 'Proses',
                      badgeColor: const Color(0xFF3B82F6),
                      icon: Icons.pending_actions_rounded,
                      accentColor: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MinimalStatCard(
                      label: 'Rata-rata Skor',
                      value: rataRataSkor > 0
                          ? rataRataSkor.toStringAsFixed(1)
                          : '-',
                      badge: 'Skala 100',
                      badgeColor: const Color(0xFF8B5CF6),
                      icon: Icons.analytics_outlined,
                      accentColor: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _MinimalStatCard(
                label: 'Total Peserta Diuji',
                value: '$totalPeserta',
                badge: 'Tahun 2026',
                badgeColor: const Color(0xFF64748B),
                icon: Icons.groups_outlined,
                accentColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MinimalStatCard(
                label: 'Lulus Seleksi',
                value: '$totalLulus',
                badge: '${passingRate.toStringAsFixed(1)}%',
                badgeColor: const Color(0xFF10B981),
                icon: Icons.check_circle_outline_rounded,
                accentColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MinimalStatCard(
                label: 'Sedang / Menunggu',
                value: '$totalSedangUjian',
                badge: 'Antrean',
                badgeColor: const Color(0xFF3B82F6),
                icon: Icons.pending_actions_rounded,
                accentColor: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MinimalStatCard(
                label: 'Rata-rata Skor',
                value: rataRataSkor > 0 ? rataRataSkor.toStringAsFixed(1) : '-',
                badge: 'Skala 100',
                badgeColor: const Color(0xFF8B5CF6),
                icon: Icons.analytics_outlined,
                accentColor: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MinimalStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String badge;
  final Color badgeColor;
  final IconData icon;
  final Color accentColor;

  const _MinimalStatCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'Inter',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
