import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

import 'package:eposwa/features/auth/presentation/pages/login_page.dart';

/// Navigation bar modern untuk ePOSWA.
/// Di layar lebar menampilkan menu lengkap + tombol aksi pendaftaran,
/// di layar compact/medium menampilkan brand logo + tombol aksi ringkas.
class BerandaNavbar extends StatefulWidget implements PreferredSizeWidget {
  const BerandaNavbar({
    super.key,
    this.onMenuSelected,
    this.onLoginPressed,
    this.onRegisterPressed,
  });

  final ValueChanged<String>? onMenuSelected;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onRegisterPressed;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  State<BerandaNavbar> createState() => _BerandaNavbarState();
}

class _BerandaNavbarState extends State<BerandaNavbar> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    final showFullMenu = screenWidth >= 960;
    final isCompact = screenWidth < 640;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: AppContainer(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Brand Logo & Title (Flexible agar tidak overflow saat window sempit)
            Flexible(
              fit: FlexFit.loose,
              child: _buildBrand(context, isCompact: isCompact),
            ),

            const SizedBox(width: 12),

            const Spacer(),

            // Right CTA Button
            _buildCtaButton(context, isCompact: !showFullMenu),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand(BuildContext context, {required bool isCompact}) {
    // Ukuran logo responsif: lebih besar di desktop, lebih kecil di compact (mobile)
    final logoHeight = isCompact ? 36.0 : 48.0;
    final umsHeight = isCompact ? 32.0 : 42.0;
    // Sembunyikan logo UMS pada layar sangat sempit agar brand tidak overflow
    final showUmsLogo = context.screenWidth >= 480;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo UMS - paling kiri (disembunyikan saat layar sangat sempit)
        if (showUmsLogo) ...[
          Image.asset(
            'assets/images/ums.png',
            height: umsHeight,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          SizedBox(width: isCompact ? 8 : 12),
        ],
        // Logo Puskesmas
        Image.asset(
          'assets/images/puskesmas.png',
          height: logoHeight,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),

        // Divider vertikal pemisah logo partner dengan brand
        Container(
          width: 1,
          height: isCompact ? 30 : 40,
          margin: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 18),
          color: AppColors.borderLight,
        ),

        // Brand ePOSWA - hanya teks, di kanan logo
        Flexible(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => widget.onMenuSelected?.call('Beranda'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ePOSWA',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                      letterSpacing: -0.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (!isCompact)
                    const Text(
                      'Layanan Kesehatan Jiwa',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButton(BuildContext context, {required bool isCompact}) {
    return ElevatedButton.icon(
      onPressed:
          widget.onLoginPressed ??
          widget.onRegisterPressed ??
          () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const LoginPage()));
          },
      icon: const Icon(Icons.login_rounded, size: 16),
      label: const Text('Masuk'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 8 : 10,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(
          fontSize: isCompact ? 12 : 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
