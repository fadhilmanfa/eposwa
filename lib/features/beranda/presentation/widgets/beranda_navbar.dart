import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Navigation bar modern untuk ePOSWA.
/// Di layar lebar menampilkan menu lengkap + tombol aksi pendaftaran,
/// di layar compact/medium menampilkan brand logo + tombol aksi ringkas.
class BerandaNavbar extends StatefulWidget implements PreferredSizeWidget {
  const BerandaNavbar({
    super.key,
    this.onMenuSelected,
    this.onRegisterPressed,
  });

  final ValueChanged<String>? onMenuSelected;
  final VoidCallback? onRegisterPressed;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  State<BerandaNavbar> createState() => _BerandaNavbarState();
}

class _BerandaNavbarState extends State<BerandaNavbar> {
  String _activeMenu = 'Beranda';

  final List<String> _menuItems = const [
    'Beranda',
    'Layanan',
  ];

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
            // Brand Logo & Title
            _buildBrand(context, isCompact: isCompact),

            const SizedBox(width: 12),

            // Desktop Navigation Links (Scrollable if tightly constrained)
            if (showFullMenu) ...[
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _menuItems.map((item) {
                        final isActive = _activeMenu == item;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _NavItem(
                            label: item,
                            isActive: isActive,
                            onTap: () {
                              setState(() {
                                _activeMenu = item;
                              });
                              widget.onMenuSelected?.call(item);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              const Spacer(),
            ],

            // Right CTA Button
            _buildCtaButton(context, isCompact: !showFullMenu),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand(BuildContext context, {required bool isCompact}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onMenuSelected?.call('Beranda'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryPastel,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ePOSWA',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        letterSpacing: -0.5,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPastel,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'POSYANDU JIWA',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context, {required bool isCompact}) {
    return ElevatedButton.icon(
      onPressed: widget.onRegisterPressed ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Membuka Formulir Pendaftaran Pasien...'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
      label: Text(isCompact ? 'Daftar' : 'Pendaftaran Pasien'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 8 : 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontSize: isCompact ? 12 : 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? AppColors.primary
        : _isHovered
            ? AppColors.textDark
            : AppColors.textMuted;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primarySoft
                : _isHovered
                    ? Colors.grey.shade100
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
