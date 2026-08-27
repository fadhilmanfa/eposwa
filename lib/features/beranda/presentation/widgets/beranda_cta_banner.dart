import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Section Call-To-Action (CTA) Banner sebelum Footer.
class BerandaCtaBanner extends StatelessWidget {
  const BerandaCtaBanner({
    super.key,
    this.onCtaPressed,
  });

  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final padV = context.scaleSpace(32, medium: 48, expanded: 56);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: padV),
      child: AppContainer(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: context.scaleSpace(24, medium: 40, expanded: 48),
            vertical: context.scaleSpace(32, medium: 40, expanded: 44),
          ),
          decoration: BoxDecoration(
            gradient: AppColors.ctaGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextContent(context),
                    const SizedBox(height: 24),
                    _buildCtaButton(context, isFullWidth: true),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildTextContent(context),
                  ),
                  const SizedBox(width: 32),
                  _buildCtaButton(context, isFullWidth: false),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.headset_mic_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'LAYANAN KONSULTASI & BANTUAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.6,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Jangan Ragu untuk Berkonsultasi',
          style: TextStyle(
            fontSize: context.scaleText(20, medium: 24, expanded: 28),
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kesehatan jiwa Anda sama pentingnya dengan kesehatan fisik. Kader ePOSWA siap mendengarkan tanpa menghakimi.',
          style: TextStyle(
            fontSize: context.scaleText(13, medium: 14, expanded: 15),
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.5,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButton(BuildContext context, {required bool isFullWidth}) {
    final btn = ElevatedButton.icon(
      onPressed: onCtaPressed ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menghubungkan ke layanan Posyandu Jiwa...'),
                backgroundColor: AppColors.primaryDark,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
      icon: const Icon(Icons.forum_rounded, size: 18, color: AppColors.primaryDark),
      label: const Text('Mulai Konsultasi'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter',
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}
