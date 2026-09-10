import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

class SidebarItemData {
  final int index;
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String? badge;

  const SidebarItemData({
    required this.index,
    required this.title,
    required this.icon,
    required this.activeIcon,
    this.badge,
  });
}

class AppSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isCollapsed,
    required this.onToggleCollapsed,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  // Tinggi tile menu 44 (padding vertikal 22 + konten 20) + separator 6 = 50
  static const double _itemPitch = 50;
  static const double _tileHeight = 44;

  final List<SidebarItemData> _items = const [
    SidebarItemData(
      index: 0,
      title: 'Beranda',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
    ),
    SidebarItemData(
      index: 1,
      title: 'Pendaftaran Peserta',
      icon: Icons.person_add_outlined,
      activeIcon: Icons.person_add_rounded,
    ),
    SidebarItemData(
      index: 2,
      title: 'Skrining & Penilaian',
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
    ),
    SidebarItemData(
      index: 3,
      title: 'Database Peserta',
      icon: Icons.storage_outlined,
      activeIcon: Icons.storage_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isCollapsed = widget.isCollapsed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // App Brand Header
          _buildHeader(),

          const SizedBox(height: 16),

          // Menu Items List
          Expanded(
            child: Stack(
              children: [
                ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    final isSelected = widget.selectedIndex == item.index;

                    return SizedBox(
                      height: _tileHeight,
                      child: _SidebarTile(
                        item: item,
                        isSelected: isSelected,
                        isCollapsed: isCollapsed,
                        onTap: () => widget.onItemSelected(item.index),
                      ),
                    );
                  },
                ),

                // Sliding active indicator (left accent bar)
                if (!isCollapsed)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: 24,
                    top: 12 +
                        widget.selectedIndex * _itemPitch +
                        (_tileHeight - 18) / 2,
                    width: 3.5,
                    height: 18,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.heroButton,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Align(
        alignment: widget.isCollapsed
            ? const Alignment(0.4, 0)
            : Alignment.centerLeft,
        child: widget.isCollapsed
            ? Image.asset(
                'assets/images/logo_kab.png',
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/ums.png',
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/logo_kab.png',
                      height: 36,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EPOSWA',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                            fontFamily: 'Inter',
                            letterSpacing: 0.5,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'DASHBOARD',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                            fontFamily: 'Inter',
                            letterSpacing: 1,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final SidebarItemData item;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.heroButton;
    final isSelected = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.isCollapsed ? widget.item.title : '',
        child: Material(
          color: isSelected
              ? activeColor.withValues(alpha: 0.10)
              : (_isHovered ? AppColors.sectionCardBg : Colors.transparent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.only(
                left: widget.isCollapsed ? 0 : 24,
                right: widget.isCollapsed ? 0 : 12,
                top: 11,
                bottom: 11,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: widget.isCollapsed
                    ? Alignment.center
                    : Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? widget.item.activeIcon : widget.item.icon,
                      color: isSelected
                          ? activeColor
                          : (_isHovered
                              ? AppColors.textDark
                              : const Color(0xFF64748B)),
                      size: 20,
                    ),
                    if (!widget.isCollapsed) ...[
                      const SizedBox(width: 10),
                      Text(
                        widget.item.title,
                        style: TextStyle(
                          color: isSelected
                              ? activeColor
                              : (_isHovered
                                  ? AppColors.textDark
                                  : const Color(0xFF475569)),
                          fontSize: 13.5,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.item.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.heroButton.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  AppColors.heroButton.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            widget.item.badge!,
                            style: const TextStyle(
                              color: AppColors.heroButton,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
