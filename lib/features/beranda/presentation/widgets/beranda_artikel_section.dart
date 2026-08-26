import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Section Artikel Pilihan Anda - responsif stepped.
class BerandaArtikelSection extends StatelessWidget {
  const BerandaArtikelSection({super.key});

  @override
  Widget build(BuildContext context) {
    final padH = context.scaleSpace(16, medium: 16, expanded: 24, large: 32);
    final padVTop = context.scaleSpace(20, medium: 20, expanded: 28);
    final padVBottom = context.scaleSpace(24, medium: 24, expanded: 32);
    final gap = context.scaleSpace(10, medium: 10, expanded: 12, large: 16);
    final titleSize = context.scaleText(12, medium: 14, expanded: 16, large: 18);

    return Container(
      width: double.infinity,
      color: AppColors.sectionLight,
      padding: EdgeInsets.fromLTRB(padH, padVTop, padH, padVBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artikel Pilihan Anda',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: context.scaleSpace(14, expanded: 16)),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return Row(
                  children: [
                    const Expanded(child: _ArtikelCard()),
                    SizedBox(width: gap),
                    const Expanded(child: _ArtikelCard()),
                    SizedBox(width: gap),
                    const Expanded(child: _ArtikelCard()),
                  ],
                );
              }
              return Row(
                children: [
                  const Expanded(child: _ArtikelCard()),
                  SizedBox(width: gap),
                  const Expanded(child: _ArtikelCard()),
                  SizedBox(width: gap),
                  const Expanded(child: _ArtikelCard()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ArtikelCard extends StatelessWidget {
  const _ArtikelCard();

  @override
  Widget build(BuildContext context) {
    final imgH = context.scaleSize(60, medium: 72, expanded: 84, large: 96);
    final titleSize = context.scaleText(10, medium: 11, expanded: 12);
    final descSize = context.scaleText(8, medium: 9, expanded: 10);
    final pad = context.scaleSpace(10, medium: 10, expanded: 12);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imgH,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: Container(
                width: context.scaleSize(32, expanded: 36),
                height: context.scaleSize(32, expanded: 36),
                decoration: BoxDecoration(
                  color: AppColors.sectionLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: context.scaleSize(18, expanded: 20),
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apa itu kesehatan Mental?',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    height: 1.3,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.scaleSpace(4, expanded: 6)),
                Text(
                  'Kesehatan Mental Adalah semacam perlindungan yang digunakan untuk mendidik ...',
                  style: TextStyle(
                    fontSize: descSize,
                    color: Colors.grey.shade600,
                    height: 1.4,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
