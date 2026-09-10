import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

import '../../domain/aktivitas_harian.dart';
import '../../domain/chart_periode.dart';
import '../../domain/tanggal_helper.dart';
import 'bar_item.dart';
import 'chart_periode_dropdown.dart';

/// Grafik bar aktivitas (pendaftaran vs sudah test) dengan periode yang
/// dapat dipilih. Skala Y dihitung dinamis dari data yang diberikan.
class DailyAnalyticsChart extends StatelessWidget {
  final List<AktivitasHarian> aktivitas;
  final ChartPeriode periode;
  final ValueChanged<ChartPeriode> onPeriodeChanged;
  final RentangTanggal? customRange;
  final ValueChanged<RentangTanggal> onCustomRangeSelected;

  const DailyAnalyticsChart({
    super.key,
    required this.aktivitas,
    required this.periode,
    required this.onPeriodeChanged,
    required this.onCustomRangeSelected,
    this.customRange,
  });

  static const double _chartHeight = 200;

  /// Skala Y dinamis: nilai maksimum dibulatkan ke atas kelipatan 5, minimal
  /// 5 agar grafik tetap proporsional saat data kecil atau kosong.
  int get _maxVal {
    var maxValue = 0;
    for (final item in aktivitas) {
      if (item.pendaftaran > maxValue) maxValue = item.pendaftaran;
      if (item.test > maxValue) maxValue = item.test;
    }
    final raw = maxValue < 5 ? 5 : maxValue;
    return ((raw + 4) ~/ 5) * 5;
  }

  List<String> get _yLabels => [4, 3, 2, 1, 0]
      .map((i) => '${(_maxVal * i / 4).round()}')
      .toList();

  String get _emptyMessage =>
      periode == ChartPeriode.kustom && customRange == null
          ? 'Pilih rentang tanggal untuk melihat grafik'
          : 'Belum ada data pada periode ini';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 28),
          if (aktivitas.isEmpty)
            _buildEmptyState()
          else
            _buildChartArea(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        final title = const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grafik Aktivitas Harian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Perbandingan jumlah pendaftaran & peserta yang sudah test per hari',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          ],
        );

        final controls = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ChartPeriodeDropdown(
              value: periode,
              onChanged: onPeriodeChanged,
              onCustomRangeSelected: onCustomRangeSelected,
            ),
            const SizedBox(height: 12),
            _buildLegend(),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 12),
              controls,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            controls,
          ],
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(
          color: AppColors.primary,
          label: 'Jumlah Pendaftaran',
        ),
        const SizedBox(width: 20),
        _buildLegendItem(
          color: const Color(0xFF10B981),
          label: 'Sudah Test',
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 140,
      child: Center(
        child: Text(
          _emptyMessage,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildChartArea() {
    return SizedBox(
      height: 240,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Skala Y (0 - maxVal)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _yLabels
                .map(
                  (v) => Text(
                    v,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(width: 16),

          // Area batang grafik (scroll horizontal jika ruang sempit)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double minChartWidth = 340;
                final chartWidth = constraints.maxWidth < minChartWidth
                    ? minChartWidth
                    : constraints.maxWidth;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    height: constraints.maxHeight,
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (_) => Divider(
                              height: 1,
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: aktivitas.map((item) {
                            final pendaftaranHeight =
                                (item.pendaftaran / _maxVal) * _chartHeight;
                            final testHeight =
                                (item.test / _maxVal) * _chartHeight;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    BarItem(
                                      height: pendaftaranHeight,
                                      color: AppColors.primary,
                                      value: item.pendaftaran,
                                    ),
                                    const SizedBox(width: 6),
                                    BarItem(
                                      height: testHeight,
                                      color: const Color(0xFF10B981),
                                      value: item.test,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}