import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/widgets/sidebar_tile.dart';

class SettingsSectionItem {
  final int index;
  final String title;
  final IconData icon;
  final IconData activeIcon;

  const SettingsSectionItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.activeIcon,
  });
}

/// Sidebar navigasi halaman Pengaturan (gaya mengikuti sidebar utama).
class SettingsSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const SettingsSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // Tinggi tile menu 44 + separator 6 = 50
  static const double _itemPitch = 50;
  static const double _tileHeight = 44;

  static const List<SettingsSectionItem> items = [
    SettingsSectionItem(
      index: 0,
      title: 'Tampilan',
      icon: Icons.palette_outlined,
      activeIcon: Icons.palette_rounded,
    ),
    SettingsSectionItem(
      index: 1,
      title: 'Perilaku',
      icon: Icons.tune_outlined,
      activeIcon: Icons.tune_rounded,
    ),
    SettingsSectionItem(
      index: 2,
      title: 'Akun',
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts_rounded,
    ),
    SettingsSectionItem(
      index: 3,
      title: 'Versi',
      icon: Icons.info_outline_rounded,
      activeIcon: Icons.info_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final item = items[i];
              final isSelected = selectedIndex == item.index;

              return SizedBox(
                height: _tileHeight,
                child: SidebarTile(
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  title: item.title,
                  isSelected: isSelected,
                  isCollapsed: false,
                  onTap: () => onItemSelected(item.index),
                ),
              );
            },
          ),

          // Sliding active indicator (left accent bar)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: 24,
            top: 12 + selectedIndex * _itemPitch + (_tileHeight - 18) / 2,
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
    );
  }
}
