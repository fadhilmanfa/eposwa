import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/widgets/custom_title_bar.dart';
import 'package:eposwa/features/auth/presentation/pages/add_admin_page.dart';
import 'package:eposwa/features/settings/presentation/sections/about_section.dart';
import 'package:eposwa/features/settings/presentation/sections/account_section.dart';
import 'package:eposwa/features/settings/presentation/sections/appearance_section.dart';
import 'package:eposwa/features/settings/presentation/sections/behavior_section.dart';
import 'package:eposwa/features/settings/presentation/widgets/settings_sidebar.dart';

/// Halaman Pengaturan: sidebar section + konten section aktif.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const int _accountSectionIndex = 2;

  int _selectedIndex = 0;
  final GlobalKey<AccountSectionState> _accountKey = GlobalKey();

  Future<void> _openAddAdmin() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddAdminPage()),
    );
    if (!mounted || added != true) return;
    // Segarkan tabel Akun agar admin baru langsung terlihat.
    await _accountKey.currentState?.refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Admin berhasil ditambahkan'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomTitleBar(),
        Expanded(
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                SettingsSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) =>
                      setState(() => _selectedIndex = index),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      // Section dibangun ulang saat dipilih agar datanya
                      // selalu segar (tanpa IndexedStack).
                      Expanded(child: _buildSection()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            tooltip: 'Kembali',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            SettingsSidebar.items[_selectedIndex].title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(),
          // Tombol tambah admin hanya relevan di section Akun.
          if (_selectedIndex == _accountSectionIndex)
            FilledButton(
              onPressed: _openAddAdmin,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Tambah Admin',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection() {
    switch (_selectedIndex) {
      case 1:
        return const BehaviorSection();
      case _accountSectionIndex:
        return AccountSection(key: _accountKey);
      case 3:
        return const AboutSection();
      default:
        return const AppearanceSection();
    }
  }
}
