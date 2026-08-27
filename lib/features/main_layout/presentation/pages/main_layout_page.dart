import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/widgets/custom_title_bar.dart';
import 'package:eposwa/features/main_layout/presentation/widgets/app_sidebar.dart';
import 'package:eposwa/features/greeting/presentation/pages/greeting_page.dart';
import 'package:eposwa/features/pendaftaran/presentation/pages/pendaftaran_page.dart';
import 'package:eposwa/features/test_peserta/presentation/pages/test_page.dart';
import 'package:eposwa/features/database_peserta/presentation/pages/database_page.dart';
import 'package:eposwa/features/beranda/presentation/pages/beranda_page.dart';

class MainLayoutPage extends StatefulWidget {
  final int initialIndex;

  const MainLayoutPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  late int _selectedIndex;

  final List<String> _pageTitles = const [
    'Greeting & Dashboard Overview',
    'Formulir Pendaftaran Peserta Baru',
    'Ujian & Penilaian Peserta',
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
        content: const Text('Apakah Anda yakin ingin keluar dari sesi sistem ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
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
                  onLogout: _handleLogout,
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
                              onSuccessSubmit: () => _onSelectTab(3), // Navigate to database on submit
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
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      child: Row(
        children: [
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
              const CircleAvatar(
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
            ],
          ),
        ],
      ),
    );
  }
}
