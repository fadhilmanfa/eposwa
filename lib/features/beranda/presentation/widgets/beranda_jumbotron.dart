import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Jumbotron Beranda - NGOTAK lurus total + responsif stepped untuk Windows.
/// Layout 2 kolom seperti [Image 1]: Kiri text sapaan + button, Kanan ilustrasi placeholder.
class BerandaJumbotron extends StatelessWidget {
  const BerandaJumbotron({
    super.key,
    this.title = 'Selamat Datang di ePOSWA',
    this.subtitle = 'Kelola pendaftaran dan data dengan mudah',
    this.buttonText = 'DAFTAR SEKARANG',
    this.onButtonPressed,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final padH = context.scaleSpace(20, medium: 24, expanded: 32, large: 40);
    final padVTop = context.scaleSpace(24, medium: 28, expanded: 36);
    final padVBottom = context.scaleSpace(28, medium: 32, expanded: 40);
    final gapWide = context.scaleSpace(24, medium: 28, expanded: 40);
    final gapNarrow = context.scaleSpace(20, medium: 24, expanded: 28);

    return Container(
      width: double.infinity,
      // LURUS TOTAL - tanpa lengkungan sama sekali, seperti website block
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(padH, padVTop, padH, padVBottom),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildLeftContent(context)),
                SizedBox(width: gapWide),
                Expanded(child: _buildIllustration(context)),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLeftContent(context),
                SizedBox(height: gapNarrow),
                _buildIllustration(context),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildLeftContent(BuildContext context) {
    final titleParts = title.split(' di ');
    final firstLine = titleParts.length > 1 ? '${titleParts[0]} di' : title;
    final secondLine = titleParts.length > 1 ? titleParts[1] : '';
    final titleSize = context.scaleText(20, medium: 24, expanded: 28, large: 32);
    final subtitleSize = context.scaleText(11, medium: 13, expanded: 14, large: 15);
    final buttonTextSize = context.scaleText(10, medium: 11, expanded: 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              height: 1.25,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(text: firstLine),
              if (secondLine.isNotEmpty) ...[
                const TextSpan(text: '\n'),
                TextSpan(
                  text: secondLine,
                  style: const TextStyle(color: AppColors.textDark),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: context.scaleSpace(10, medium: 10, expanded: 12)),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: subtitleSize,
            height: 1.5,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: context.scaleSpace(16, medium: 16, expanded: 20)),
        ElevatedButton(
          onPressed: onButtonPressed ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur Pendaftaran segera hadir'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.heroButton,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: context.scaleSpace(20, medium: 20, expanded: 24),
              vertical: context.scaleSpace(10, medium: 10, expanded: 12),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: TextStyle(
              fontSize: buttonTextSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontFamily: 'Inter',
            ),
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final h = context.scaleSize(150, medium: 180, expanded: 220, large: 260);
    final circle = context.scaleSize(64, medium: 64, expanded: 72);
    final iconSize = context.scaleSize(36, medium: 36, expanded: 40);
    final plantSize = context.scaleSize(28, medium: 28, expanded: 32);

    return Container(
      height: h,
      decoration: BoxDecoration(
        color: AppColors.primaryPastel.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: context.scaleSize(60, medium: 60, expanded: 72),
              decoration: BoxDecoration(
                color: const Color(0xFF7CB342).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFigure(context, color: const Color(0xFFF9A825), icon: Icons.person_rounded, size: circle, iconSize: iconSize),
              SizedBox(width: context.scaleSpace(12, expanded: 16)),
              _buildFigure(context, color: const Color(0xFF26A69A), icon: Icons.person_rounded, size: circle, iconSize: iconSize),
            ],
          ),
          Positioned(
            top: 16,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPastel,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.sectionLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 16,
            child: Icon(
              Icons.local_florist_rounded,
              size: plantSize,
              color: const Color(0xFF66BB6A).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigure(BuildContext context, {required Color color, required IconData icon, required double size, required double iconSize}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: iconSize, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Container(
          width: size,
          height: context.scaleSize(28, medium: 28, expanded: 32),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}
