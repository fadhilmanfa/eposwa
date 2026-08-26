import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_artikel_section.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_footer.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_jumbotron.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_menu_grid.dart';

/// Halaman Beranda (Index) ePOSWA - responsif stepped untuk Windows.
class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logoSize = context.scaleSize(28, medium: 28, expanded: 32);
    final logoIcon = context.scaleSize(16, medium: 16, expanded: 18);
    final titleSize = context.scaleText(10, medium: 11, expanded: 12);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: logoSize,
              height: logoSize,
              decoration: const BoxDecoration(
                color: AppColors.primaryPastel,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: logoIcon,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: context.scaleSpace(8, expanded: 10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posyandu',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: AppColors.textDark,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Jiwa',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: AppColors.primary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _navItem(context, 'Beranda', isActive: true),
          _navItem(context, 'Tentang'),
          _navItem(context, 'Konseling'),
          _navItem(context, 'Kontak'),
          SizedBox(width: context.scaleSpace(8, expanded: 12)),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BerandaJumbotron(),
            BerandaMenuGrid(),
            BerandaArtikelSection(),
            BerandaFooter(),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, {bool isActive = false}) {
    final fontSize = context.scaleText(9, medium: 10, expanded: 11, large: 12);
    final hPad = context.scaleSpace(6, medium: 6, expanded: 8);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Center(
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Menu $label segera hadir'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
