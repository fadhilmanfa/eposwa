import 'package:flutter/material.dart';
import 'package:eposwa/core/widgets/custom_title_bar.dart';
import 'package:eposwa/features/auth/presentation/pages/login_page.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_footer.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_jumbotron.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_menu_grid.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_navbar.dart';

/// Halaman Beranda (Landing Page) ePOSWA.
/// Minimalis, bersih, 3 card mengambang di atas jumbotron (z-index tinggi),
/// dan footer selalu menempel di bagian paling bawah layar.
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _berandaKey = GlobalKey();
  final GlobalKey _layananKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleMenuSelection(String menu) {
    switch (menu) {
      case 'Beranda':
        _scrollToSection(_berandaKey);
        break;
      case 'Layanan':
      default:
        _scrollToSection(_layananKey);
        break;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom frameless title bar (hanya tampil di Windows/Linux/macOS)
          const CustomTitleBar(),

          // Top Responsive Navbar
          BerandaNavbar(
            onMenuSelected: _handleMenuSelection,
            onLoginPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            onRegisterPressed: () => _scrollToSection(_layananKey),
          ),

          // Scrollable Content
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Hero Jumbotron + Floating Menu Grid dalam satu Sliver
                // Menjamin paint order kartu selalu berada DI ATAS (z-index lebih tinggi) Jumbotron
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Hero Jumbotron (Dilukis pertama di layer bawah)
                      Container(
                        key: _berandaKey,
                        child: const BerandaJumbotron(),
                      ),

                      // 2. Floating 3 Service Cards Grid (Dilukis kedua di layer atas)
                      Container(
                        key: _layananKey,
                        child: const BerandaMenuGrid(),
                      ),
                    ],
                  ),
                ),

                // 3. SliverFillRemaining untuk mendorong footer ke dasar layar.
                // Pakai Align (bukan Column + Spacer) agar tidak terjadi error
                // RenderFlex saat tinggi window lebih kecil dari total konten
                // di atasnya (jumbotron + menu grid sudah memenuhi viewport).
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: BerandaFooter(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
