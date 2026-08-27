import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Section Artikel Pilihan & Edukasi Kesehatan Jiwa.
class BerandaArtikelSection extends StatelessWidget {
  const BerandaArtikelSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final padV = context.scaleSpace(40, medium: 56, expanded: 64, large: 80);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: padV),
      child: AppContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section Header with Title & Action Link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'EDUKASI & WAWASAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Artikel & Panduan Kesehatan Jiwa',
                        style: TextStyle(
                          fontSize: context.scaleText(20, medium: 26, expanded: 30, large: 34),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pelajari informasi terpercaya seputar kesehatan mental, tips merawat diri, dan bimbingan keluarga.',
                        style: TextStyle(
                          fontSize: context.scaleText(13, medium: 14, expanded: 15),
                          color: AppColors.textMuted,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 24),
                  _buildAllArticlesButton(context),
                ],
              ],
            ),
            const SizedBox(height: 36),

            // Articles Grid
            _buildArticlesGrid(context, isCompact: isCompact),

            if (isCompact) ...[
              const SizedBox(height: 24),
              Center(child: _buildAllArticlesButton(context)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllArticlesButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membuka katalog seluruh artikel...'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
      label: const Text(
        'Lihat Semua Artikel',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _buildArticlesGrid(BuildContext context, {required bool isCompact}) {
    const articles = [
      _ArticleItemData(
        title: 'Mengenal Tanda Awal Stres dan Gangguan Kecemasan',
        summary:
            'Ketahui gejala dini perubahan suasana hati, pola tidur, dan cara sederhana meredakan kecemasan sehari-hari.',
        category: 'Edukasi Jiwa',
        categoryColor: Color(0xFF2563EB),
        readTime: '4 Menit Baca',
        date: '24 Agt 2026',
        icon: Icons.psychology_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFFE0E7FF), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _ArticleItemData(
        title: 'Pentingnya Peran Keluarga dalam Pemulihan Pasien',
        summary:
            'Dukungan penuh lingkungan keluarga dan komunikasi empati menjadi kunci utama stabilitas kesehatan emosional.',
        category: 'Tips Keluarga',
        categoryColor: Color(0xFF059669),
        readTime: '6 Menit Baca',
        date: '20 Agt 2026',
        icon: Icons.favorite_border_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFFD1FAE5), Color(0xFFECFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _ArticleItemData(
        title: 'Langkah Awal Skrining Mandiri di Posyandu Jiwa',
        summary:
            'Panduan lengkap pengisian instrumen skrining kuesioner dan alur rujukan bila membutuhkan bantuan medis.',
        category: 'Panduan Layanan',
        categoryColor: Color(0xFFD97706),
        readTime: '5 Menit Baca',
        date: '15 Agt 2026',
        icon: Icons.assignment_outlined,
        gradient: LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];

    if (isCompact || context.isMedium) {
      return Column(
        children: articles
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _ArticleCard(data: a),
                ))
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: articles
          .map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _ArticleCard(data: a),
                ),
              ))
          .toList(),
    );
  }
}

class _ArticleItemData {
  const _ArticleItemData({
    required this.title,
    required this.summary,
    required this.category,
    required this.categoryColor,
    required this.readTime,
    required this.date,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String summary;
  final String category;
  final Color categoryColor;
  final String readTime;
  final String date;
  final IconData icon;
  final Gradient gradient;
}

class _ArticleCard extends StatefulWidget {
  const _ArticleCard({required this.data});

  final _ArticleItemData data;

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppColors.primaryLight : AppColors.borderLight,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Membaca: ${widget.data.title}'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Header Banner
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: widget.data.gradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.data.icon,
                          size: 30,
                          color: widget.data.categoryColor,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.data.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: widget.data.categoryColor,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Card Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta (Time & Date)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule_rounded, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              widget.data.readTime,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        Text('•', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                        Text(
                          widget.data.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.data.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        height: 1.35,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Summary
                    Text(
                      widget.data.summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.5,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),

                    // Action Link
                    Row(
                      children: [
                        Text(
                          'Baca Selengkapnya',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isHovered ? AppColors.primaryDark : AppColors.primary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: _isHovered ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
