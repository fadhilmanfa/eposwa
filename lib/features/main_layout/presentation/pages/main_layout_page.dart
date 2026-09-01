import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/widgets/custom_title_bar.dart';
import 'package:eposwa/features/main_layout/presentation/widgets/app_sidebar.dart';
import 'package:eposwa/features/greeting/presentation/pages/greeting_page.dart';
import 'package:eposwa/features/pendaftaran/presentation/pages/pendaftaran_page.dart';
import 'package:eposwa/features/test_peserta/presentation/pages/test_page.dart';
import 'package:eposwa/features/database_peserta/presentation/pages/database_page.dart';
import 'package:eposwa/features/beranda/presentation/pages/beranda_page.dart';
import 'package:eposwa/core/services/session_service.dart';
import 'package:eposwa/core/services/export_service.dart';
import 'package:eposwa/core/services/import_service.dart';
import 'package:eposwa/features/auth/presentation/pages/admin_management_page.dart';

class MainLayoutPage extends StatefulWidget {
  final int initialIndex;

  const MainLayoutPage({super.key, this.initialIndex = 0});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  late int _selectedIndex;
  bool _isSidebarCollapsed = false;

  final List<String> _pageTitles = const [
    'Beranda',
    'Formulir Pendaftaran Peserta Baru',
    'Skrining & Penilaian Jiwa',
    'Database Pendaftaran Peserta',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onSelectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Konfirmasi Keluar'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi sistem ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await SessionService.clearSession();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const BerandaPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportSql() async {
    try {
      final path = await ExportService.exportSql();
      if (!mounted) return;
      if (path == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export dibatalkan')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SQL berhasil di-export: $path'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal export: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleImportSql() async {
    try {
      final result = await ImportService.importSqlWithDialog(context);
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Import dibatalkan')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Import selesai: ${result.imported} baru, ${result.skipped} dilewati, ${result.replaced} ditimpa, ${result.merged} digabung',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal import: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleInstanSql() async {
    try {
      final path = await ExportService.exportSqlInstan();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Instan: SQL di-export ke $path (path disalin, folder dibuka)',
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal instan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. Frameless Custom Title Bar (Desktop Windows/Linux/macOS)
          const CustomTitleBar(),

          // 2. Main Dashboard Layout Body (Sidebar + Content Column)
          Expanded(
            child: Row(
              children: [
                // Left Column: App Sidebar Navigation
                AppSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onSelectTab,
                  isCollapsed: _isSidebarCollapsed,
                  onToggleCollapsed: () => setState(
                    () => _isSidebarCollapsed = !_isSidebarCollapsed,
                  ),
                ),

                // Right Column: Dashboard Content Container
                Expanded(
                  child: Column(
                    children: [
                      // Top Navbar inside Dashboard
                      _buildTopBar(),

                      // Page Content Body with IndexedStack to preserve page state
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: [
                            GreetingPage(onNavigate: _onSelectTab),
                            PendaftaranPage(
                              onSuccessSubmit: () => _onSelectTab(
                                3,
                              ), // Navigate to database on submit
                              onSubmitAndContinue: () => _onSelectTab(
                                2,
                              ), // Navigate to skrining on submit
                            ),
                            const TestPage(),
                            const DatabasePage(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          // Toggle Sidebar Collapse
          IconButton(
            icon: Icon(
              _isSidebarCollapsed
                  ? Icons.keyboard_double_arrow_right_rounded
                  : Icons.keyboard_double_arrow_left_rounded,
              size: 20,
            ),
            tooltip: _isSidebarCollapsed
                ? 'Tampilkan Sidebar'
                : 'Sembunyikan Sidebar',
            onPressed: () =>
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
          ),

          const SizedBox(width: 8),

          // Current Active Page Title
          Text(
            _pageTitles[_selectedIndex],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontFamily: 'Inter',
            ),
          ),

          const Spacer(),

          // Simple Profile Avatar
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 20),
                tooltip: 'Notifikasi',
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _ProfileMenu(
                onImport: _handleImportSql,
                onExport: _handleExportSql,
                onInstan: _handleInstanSql,
                onSettings: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminManagementPage(),
                  ),
                ),
                onLogout: _handleLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatefulWidget {
  final VoidCallback onImport;
  final VoidCallback onExport;
  final VoidCallback onInstan;
  final VoidCallback onSettings;
  final VoidCallback onLogout;
  const _ProfileMenu({
    required this.onImport,
    required this.onExport,
    required this.onInstan,
    required this.onSettings,
    required this.onLogout,
  });
  @override
  State<_ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<_ProfileMenu> {
  final MenuController _controller = MenuController();
  final MenuController _subController = MenuController();

  static const _menuStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(6),
    shadowColor: WidgetStatePropertyAll(Color(0x14000000)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        side: BorderSide(color: AppColors.borderLight),
      ),
    ),
    padding: WidgetStatePropertyAll(EdgeInsets.all(6)),
  );

  // Satu style yang sama untuk SEMUA item (termasuk Berbagi Data & submenu)
  static final ButtonStyle _itemStyle = MenuItemButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.textDark,
    overlayColor: const Color(0xFFCBD5E1),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 13.5, fontFamily: 'Inter'),
  );

  // Style submenu: lebar tetap 140 agar posisi kiri bisa diprediksi
  static final ButtonStyle _subItemStyle = _itemStyle.copyWith(
    minimumSize: const WidgetStatePropertyAll(Size(140, 40)),
  );

  Widget _item(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color iconColor = AppColors.textDark,
    Widget? trailing,
    ButtonStyle? style,
  }) {
    return MenuItemButton(
      onPressed: () {
        _controller.close();
        onTap();
      },
      style: style ?? _itemStyle,
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.textDark)),
          if (trailing != null) ...[const Spacer(), trailing],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      style: _menuStyle,
      alignmentOffset: const Offset(0, 8),
      onClose: () => _subController.close(),
      menuChildren: [
        // Berbagi Data: MenuItemButton yang sama, submenu hover di samping KIRI
        MenuAnchor(
          controller: _subController,
          style: _menuStyle,
          // submenu lebar = 140 + padding menu 12 = 152; geser ke kiri
          alignmentOffset: const Offset(-152, -40),
          menuChildren: [
            _item(
              Icons.download_rounded,
              'Import',
              widget.onImport,
              iconColor: AppColors.primary,
              style: _subItemStyle,
            ),
            _item(
              Icons.upload_rounded,
              'Export',
              widget.onExport,
              iconColor: AppColors.primary,
              style: _subItemStyle,
            ),
            _item(
              Icons.bolt_rounded,
              'Instan',
              widget.onInstan,
              iconColor: const Color(0xFFF59E0B),
              style: _subItemStyle,
            ),
          ],
          child: Listener(
            onPointerHover: (_) {
              if (!_subController.isOpen) _subController.open();
            },
            child: MenuItemButton(
              onPressed: () => _subController.isOpen
                  ? _subController.close()
                  : _subController.open(),
              style: _itemStyle,
              child: const Row(
                children: [
                  Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppColors.textDark,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Berbagi Data',
                    style: TextStyle(color: AppColors.textDark),
                  ),
                  Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, indent: 12, endIndent: 12),
        MouseRegion(
          onEnter: (_) => _subController.close(),
          child: _item(
            Icons.settings_outlined,
            'Pengaturan',
            widget.onSettings,
          ),
        ),
        const Divider(height: 1, indent: 12, endIndent: 12),
        MouseRegion(
          onEnter: (_) => _subController.close(),
          child: _item(
            Icons.logout_rounded,
            'Keluar',
            widget.onLogout,
            iconColor: const Color(0xFFEF4444),
          ),
        ),
      ],
      child: GestureDetector(
        onTap: () =>
            _controller.isOpen ? _controller.close() : _controller.open(),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
