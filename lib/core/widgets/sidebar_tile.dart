import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

/// Tile navigasi sidebar dengan hover/selected yang sama untuk semua sidebar.
///
/// Sengaja memakai [MouseRegion] + [GestureDetector] (bukan [InkWell]) supaya
/// tidak ada splash/ripple Material saat tile diklik.
class SidebarTile extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;
  final String? badge;

  const SidebarTile({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
    this.badge,
  });

  @override
  State<SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<SidebarTile> {
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
        message: widget.isCollapsed ? widget.title : '',
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
                      isSelected ? widget.activeIcon : widget.icon,
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
                        widget.title,
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
                      if (widget.badge != null)
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
                            widget.badge!,
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
