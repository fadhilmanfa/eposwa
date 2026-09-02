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
import 'package:eposwa/features/main_layout/presentation/widgets/share_dialogs.dart';

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
    'Formulir Data Diri',
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
    final result = await showDialog<ShareResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ShareDialog(),
    );
    if (!mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Berbagi instan dibatalkan')));
      return;
    }
    if (result.sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data berhasil dikirim ke ${result.peerName}'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    final sql = result.sql;
    if (sql == null) return;

    // 1) Preview isi tabel yang dikirim
    final action = await showDialog<(PreviewAction, String?)>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PreviewDialog(sql: sql, senderName: result.peerName),
    );
    if (!mounted) return;
    if (action == null || action.$1 == PreviewAction.cancel) return;
    if (action.$1 == PreviewAction.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data tersimpan: ${action.$2}'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    // 2) Terapkan → cek dulu NIK yang sudah ada di database lokal
    try {
      final preview = await ImportService.previewSqlFromContent(sql);
      if (!mounted) return;
      if (preview != null && preview.duplicateCount > 0) {
        final niks = preview.duplicateNiks;
        final shown = niks.take(8).join(', ');
        final more =
            niks.length > 8 ? '\n... dan ${niks.length - 8} NIK lainnya' : '';
        final lanjutkan = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
                SizedBox(width: 10),
                Text(
                  'Data Sudah Ada',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ditemukan NIK yang sudah ada di database ini:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    'Data sudah ada: NIK $shown$more',
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Lanjutkan akan menambahkan ${preview.newCount} peserta baru sebagai baris baru dan melewati ${preview.duplicateCount} data yang NIK-nya sudah ada.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
        );
        if (lanjutkan != true || !mounted) return;
      }

      final importResult = await ImportService.importSqlFromContent(
        sql,
        ImportStrategy.skip,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terapkan selesai: ${importResult.imported} peserta baru ditambahkan, ${importResult.skipped} duplikat dilewati',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal terapkan: $e'),
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
              _UpdateButton(),
              const SizedBox(width: 10),
              _ProfileMenu(
                onImport: _handleImportSql,
                onExport: _handleExportSql,
                onInstan: _handleInstanSql,
                onSambungkanPc: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Fitur "Sambungkan PC" segera hadir.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
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

class _UpdateButton extends StatefulWidget {
  const _UpdateButton();

  @override
  State<_UpdateButton> createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<_UpdateButton> {
  final MenuController _controller = MenuController();

  static const _menuStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(8),
    shadowColor: WidgetStatePropertyAll(Color(0x1E000000)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.borderLight),
      ),
    ),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
  );

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      style: _menuStyle,
      alignmentOffset: const Offset(0, 8),
      menuChildren: [
        Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Versi Baru Tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Versi 2.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _controller.close(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Update Sekarang',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      builder: (context, controller, child) {
        final isOpen = controller.isOpen;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => isOpen ? controller.close() : controller.open(),
          hoverColor: AppColors.primary.withValues(alpha: 0.08),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isOpen
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isOpen ? AppColors.primary : AppColors.borderMedium,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  size: 17,
                  color: isOpen ? AppColors.primary : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isOpen ? AppColors.primary : AppColors.primary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileMenu extends StatefulWidget {
  final VoidCallback onImport;
  final VoidCallback onExport;
  final VoidCallback onInstan;
  final VoidCallback onSambungkanPc;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _ProfileMenu({
    required this.onImport,
    required this.onExport,
    required this.onInstan,
    required this.onSambungkanPc,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  State<_ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<_ProfileMenu> {
  final MenuController _controller = MenuController();

  static const _menuStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(8),
    shadowColor: WidgetStatePropertyAll(Color(0x1E000000)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: AppColors.borderLight),
      ),
    ),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
  );

  @override
  Widget build(BuildContext context) {
    final admin = SessionService.currentAdmin;
    final displayName = admin?.namaLengkap.isNotEmpty == true
        ? admin!.namaLengkap
        : 'Admin';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';

    return MenuAnchor(
      controller: _controller,
      style: _menuStyle,
      alignmentOffset: const Offset(0, 8),
      menuChildren: [
        _ProfileDropdownCard(
          adminName: displayName,
          username: admin?.username,
          initial: initial,
          onImport: () {
            _controller.close();
            widget.onImport();
          },
          onExport: () {
            _controller.close();
            widget.onExport();
          },
          onInstan: () {
            _controller.close();
            widget.onInstan();
          },
          onSambungkanPc: () {
            _controller.close();
            widget.onSambungkanPc();
          },
          onSettings: () {
            _controller.close();
            widget.onSettings();
          },
          onLogout: () {
            _controller.close();
            widget.onLogout();
          },
        ),
      ],
      builder: (context, controller, child) {
        final isOpen = controller.isOpen;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => isOpen ? controller.close() : controller.open(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isOpen
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isOpen ? AppColors.primary : AppColors.borderMedium,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isOpen ? AppColors.primary : AppColors.textDark,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isOpen
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  size: 20,
                  color: isOpen ? AppColors.primary : AppColors.textMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileDropdownCard extends StatefulWidget {
  final String adminName;
  final String? username;
  final String initial;
  final VoidCallback onImport;
  final VoidCallback onExport;
  final VoidCallback onInstan;
  final VoidCallback onSambungkanPc;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _ProfileDropdownCard({
    required this.adminName,
    required this.username,
    required this.initial,
    required this.onImport,
    required this.onExport,
    required this.onInstan,
    required this.onSambungkanPc,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  State<_ProfileDropdownCard> createState() => _ProfileDropdownCardState();
}

class _ProfileDropdownCardState extends State<_ProfileDropdownCard> {
  bool _isBerbagiExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Profil
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.adminName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.username != null
                            ? '@${widget.username}'
                            : 'Administrator',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),

          // Menu Accordion "Berbagi Data"
          InkWell(
            onTap: () {
              setState(() {
                _isBerbagiExpanded = !_isBerbagiExpanded;
              });
            },
            hoverColor: const Color(0xFFF1F5F9),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppColors.textDark,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Berbagi Data',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isBerbagiExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submenu Items when expanded
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Container(
              color: const Color(0xFFF8FAFC),
              child: Column(
                children: [
                  _buildSubMenuItem(
                    icon: Icons.download_rounded,
                    title: 'Import Data',
                    iconColor: AppColors.primary,
                    onTap: widget.onImport,
                  ),
                  _buildSubMenuItem(
                    icon: Icons.upload_rounded,
                    title: 'Export Data',
                    iconColor: AppColors.primary,
                    onTap: widget.onExport,
                  ),
                  _buildSubMenuItem(
                    icon: Icons.bolt_rounded,
                    title: 'Instan',
                    iconColor: const Color(0xFFF59E0B),
                    onTap: widget.onInstan,
                  ),
                ],
              ),
            ),
            crossFadeState: _isBerbagiExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),

          // Sambungkan PC
          _buildMenuItem(
            icon: Icons.laptop_mac_rounded,
            title: 'Sambungkan PC',
            onTap: widget.onSambungkanPc,
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),

          // Pengaturan
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            onTap: widget.onSettings,
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),

          // Keluar
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            iconColor: const Color(0xFFEF4444),
            textColor: const Color(0xFFEF4444),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            onTap: widget.onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppColors.textDark,
    Color textColor = AppColors.textDark,
    BorderRadius? borderRadius,
  }) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      hoverColor: const Color(0xFFF1F5F9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: const Color(0xFFEEF2F6),
      child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 14, top: 9, bottom: 9),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

