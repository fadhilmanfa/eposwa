import 'package:flutter/material.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_menu_card.dart';

/// Grid 3 Card Layanan - Rata kiri & mengambang (floating) naik menimpa setengah jumbotron.
class BerandaMenuGrid extends StatelessWidget {
  const BerandaMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    // Nilai overlap untuk menaikkan 3 kartu ke setengah jumbotron
    final overlap = context.scaleSpace(50, medium: 80, expanded: 110, large: 130);
    final padBottom = context.scaleSpace(32, medium: 48, expanded: 64);

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Transform.translate(
        offset: Offset(0, -overlap),
        child: Padding(
          padding: EdgeInsets.only(bottom: padBottom > overlap ? padBottom - overlap : 8),
          child: AppContainer(
            alignment: Alignment.centerLeft,
            child: isCompact ? _buildCompactCards() : _buildWideCards(),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCards() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BerandaMenuCard(
            label: 'Pendaftaran Pasien',
            icon: Icons.how_to_reg_rounded,
            description: 'Daftarkan diri atau anggota keluarga Anda untuk mendapatkan pendampingan berkala dari kader.',
          ),
          SizedBox(height: 16),
          BerandaMenuCard(
            label: 'Skrining Jiwa Mandiri',
            icon: Icons.quiz_rounded,
            description: 'Evaluasi kondisi psikologis dengan kuesioner tervalidasi dan rekomendasi tindak lanjut.',
          ),
          SizedBox(height: 16),
          BerandaMenuCard(
            label: 'Database & Rekapitulasi',
            icon: Icons.analytics_rounded,
            description: 'Pengelolaan data rekam posyandu, statistik kunjungan, serta arsip rujukan ke Puskesmas.',
          ),
        ],
      ),
    );
  }

  Widget _buildWideCards() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BerandaMenuCard(
              label: 'Pendaftaran Pasien',
              icon: Icons.how_to_reg_rounded,
              description: 'Daftarkan diri atau anggota keluarga Anda untuk mendapatkan pendampingan berkala dari kader.',
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: BerandaMenuCard(
              label: 'Skrining Jiwa Mandiri',
              icon: Icons.quiz_rounded,
              description: 'Evaluasi kondisi psikologis dengan kuesioner tervalidasi dan rekomendasi tindak lanjut.',
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: BerandaMenuCard(
              label: 'Database & Rekapitulasi',
              icon: Icons.analytics_rounded,
              description: 'Pengelolaan data rekam posyandu, statistik kunjungan, serta arsip rujukan ke Puskesmas.',
            ),
          ),
        ],
      ),
    );
  }
}
