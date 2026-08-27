import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Section Keunggulan & Alur Posyandu Jiwa ePOSWA.
class BerandaFeaturesSection extends StatelessWidget {
  const BerandaFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final isExpanded = context.isExpanded || context.isLarge;
    final padV = context.scaleSpace(40, medium: 56, expanded: 64, large: 80);

    return Container(
      width: double.infinity,
      color: AppColors.sectionLight,
      padding: EdgeInsets.symmetric(vertical: padV),
      child: AppContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tagline Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Text(
                'KENAPA MEMILIH ePOSWA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heroButton,
                  letterSpacing: 0.8,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              'Keunggulan Pelayanan Posyandu Jiwa',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.scaleText(22, medium: 28, expanded: 32, large: 36),
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                'ePOSWA hadir untuk mendekatkan layanan kesehatan mental ke tingkat komunitas dengan sistem yang mudah, aman, dan terintegrasi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.scaleText(13, medium: 14, expanded: 15),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  height: 1.5,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Grid of 4 Features
            _buildFeaturesGrid(context, isCompact: isCompact, isExpanded: isExpanded),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, {required bool isCompact, required bool isExpanded}) {
    const features = [
      _FeatureData(
        icon: Icons.health_and_safety_rounded,
        title: 'Deteksi Dini Akurat',
        description: 'Instrumen evaluasi psikososial yang telah disesuaikan untuk skrining mandiri warga dan keluarga.',
        color: Color(0xFF0E7C7B),
      ),
      _FeatureData(
        icon: Icons.people_alt_rounded,
        title: 'Pendampingan Kader',
        description: 'Didukung kader posyandu terlatih yang siap memberikan perhatian, kunjungan, dan bimbingan emosional.',
        color: AppColors.primary,
      ),
      _FeatureData(
        icon: Icons.security_rounded,
        title: 'Privasi Terjamin 100%',
        description: 'Data riwayat kesehatan dan keluhan warga dienkripsi dengan standar keamanan privasi medis tinggi.',
        color: Color(0xFF7C3AED),
      ),
      _FeatureData(
        icon: Icons.local_hospital_rounded,
        title: 'Rujukan Terpadu',
        description: 'Terhubung langsung dengan Puskesmas dan RS Jiwa daerah bila membutuhkan penanganan klinis lanjutan.',
        color: Color(0xFFD97706),
      ),
    ];

    if (isCompact) {
      return Column(
        children: features
            .map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _FeatureCard(data: f),
                ))
            .toList(),
      );
    }

    if (isExpanded) {
      // 4 Columns on Large Screens
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: features
            .map((f) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _FeatureCard(data: f),
                  ),
                ))
            .toList(),
      );
    }

    // 2x2 Grid on Medium Screens
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _FeatureCard(data: features[0])),
            const SizedBox(width: 20),
            Expanded(child: _FeatureCard(data: features[1])),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _FeatureCard(data: features[2])),
            const SizedBox(width: 20),
            Expanded(child: _FeatureCard(data: features[3])),
          ],
        ),
      ],
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.data});

  final _FeatureData data;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? widget.data.color.withValues(alpha: 0.5) : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.data.color.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.data.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.data.icon,
                color: widget.data.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.data.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.data.description,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
                height: 1.5,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
