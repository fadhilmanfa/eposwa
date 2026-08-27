import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Jumbotron Hero Beranda - Bersih, megah di layar lebar & siap untuk floating cards.
class BerandaJumbotron extends StatelessWidget {
  const BerandaJumbotron({
    super.key,
    this.title = 'Selamat Datang di ePOSWA',
    this.subtitle =
        'Platform digital Posyandu Jiwa untuk deteksi dini, pendampingan kesehatan mental, dan pengelolaan data warga secara terpadu.',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final minHeight = context.scaleSize(360, medium: 420, expanded: 480, large: 520);
    final padVTop = context.scaleSpace(40, medium: 56, expanded: 72, large: 84);
    // Beri ruang di bawah untuk card yang naik menimpa setengah jumbotron
    final padVBottom = context.scaleSpace(80, medium: 110, expanded: 140, large: 160);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        image: DecorationImage(
          image: AssetImage('assets/images/jumbo.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: const BoxDecoration(
          gradient: AppColors.heroOverlayGradient,
        ),
        padding: EdgeInsets.fromLTRB(0, padVTop, 0, padVBottom),
        child: AppContainer(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: _buildHeroContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    final titleParts = title.split(' di ');
    final firstLine = titleParts.length > 1 ? '${titleParts[0]} di' : title;
    final secondLine = titleParts.length > 1 ? titleParts[1] : '';

    final titleSize = context.scaleText(28, medium: 36, expanded: 46, large: 52);
    final subtitleSize = context.scaleText(14, medium: 15, expanded: 16, large: 17);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Title
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              height: 1.18,
              letterSpacing: -0.8,
              fontFamily: 'Inter',
              shadows: const [
                Shadow(color: Colors.black54, blurRadius: 14, offset: Offset(0, 3)),
              ],
            ),
            children: [
              TextSpan(text: firstLine),
              if (secondLine.isNotEmpty) ...[
                const TextSpan(text: '\n'),
                TextSpan(
                  text: secondLine,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: subtitleSize,
            height: 1.6,
            fontFamily: 'Inter',
            shadows: const [
              Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
        ),
      ],
    );
  }
}
