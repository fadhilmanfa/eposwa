import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

/// Halaman Greeting & Dashboard Overview - Minimalis dengan Grafik Harian.
class GreetingPage extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const GreetingPage({
    super.key,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Ringkas & Elegan
            _buildMinimalHeader(),

            const SizedBox(height: 28),

            // 2. Metrik Utama (4 Kartu Minimalis)
            _buildMetricsRow(),

            const SizedBox(height: 32),

            // 3. Grafik Statistik Harian (Gantikan Menu Utama)
            const _DailyAnalyticsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, Administrator 👋',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            fontFamily: 'Inter',
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _MinimalStatCard(
            label: 'Pendaftaran Hari Ini',
            value: '24',
            badge: '+12%',
            badgeColor: const Color(0xFF10B981),
            icon: Icons.person_add_alt_1_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MinimalStatCard(
            label: 'Sedang Ikut Ujian',
            value: '18',
            badge: 'Aktif',
            badgeColor: const Color(0xFF3B82F6),
            icon: Icons.quiz_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MinimalStatCard(
            label: 'Total Terdaftar',
            value: '1,428',
            badge: 'Tahun 2026',
            badgeColor: const Color(0xFF6B7280),
            icon: Icons.groups_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MinimalStatCard(
            label: 'Sisa Kuota',
            value: '72',
            badge: 'Gel. 1',
            badgeColor: const Color(0xFFF59E0B),
            icon: Icons.pie_chart_outline_rounded,
          ),
        ),
      ],
    );
  }
}

class _MinimalStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String badge;
  final Color badgeColor;
  final IconData icon;

  const _MinimalStatCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                ),
              ),
              Icon(icon, size: 18, color: AppColors.textMuted.withValues(alpha: 0.7)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

/// Grafik Bar Harian (Jumlah Pendaftaran & Jumlah Sudah Test per Hari)
class _DailyAnalyticsChart extends StatelessWidget {
  const _DailyAnalyticsChart();

  final List<Map<String, dynamic>> _chartData = const [
    {'day': 'Senin', 'pendaftaran': 15, 'test': 12},
    {'day': 'Selasa', 'pendaftaran': 22, 'test': 18},
    {'day': 'Rabu', 'pendaftaran': 19, 'test': 15},
    {'day': 'Kamis', 'pendaftaran': 28, 'test': 24},
    {'day': 'Jumat', 'pendaftaran': 34, 'test': 30},
    {'day': 'Sabtu', 'pendaftaran': 24, 'test': 18},
    {'day': 'Minggu', 'pendaftaran': 12, 'test': 8},
  ];

  @override
  Widget build(BuildContext context) {
    const int maxVal = 40; // Skala maksimal grafik

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
          // Header Grafik & Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
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
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              // Legend
              Row(
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
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Area Grafik Bar Harian
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Skala Y Axis (0 - 40)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [40, 30, 20, 10, 0]
                      .map(
                        (v) => Text(
                          '$v',
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

                // Area Batang Grafik
                Expanded(
                  child: Stack(
                    children: [
                      // Gridlines Horisontal
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

                      // Bar Columns
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _chartData.map((item) {
                          final pendaftaran = item['pendaftaran'] as int;
                          final test = item['test'] as int;
                          final day = item['day'] as String;

                          final pendaftaranHeight = (pendaftaran / maxVal) * 200;
                          final testHeight = (test / maxVal) * 200;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Bar Pendaftaran
                                  _BarItem(
                                    height: pendaftaranHeight,
                                    color: AppColors.primary,
                                    value: pendaftaran,
                                  ),
                                  const SizedBox(width: 6),
                                  // Bar Test
                                  _BarItem(
                                    height: testHeight,
                                    color: const Color(0xFF10B981),
                                    value: test,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                day,
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
              ],
            ),
          ),
        ],
      ),
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
}

class _BarItem extends StatefulWidget {
  final double height;
  final Color color;
  final int value;

  const _BarItem({
    required this.height,
    required this.color,
    required this.value,
  });

  @override
  State<_BarItem> createState() => _BarItemState();
}

class _BarItemState extends State<_BarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: '${widget.value} Orang',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isHovered)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${widget.value}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: widget.height,
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.color.withValues(alpha: 0.8)
                    : widget.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
