import 'package:flutter/material.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';
import 'package:eposwa/features/beranda/presentation/widgets/beranda_menu_card.dart';

/// Grid 3 Menu Beranda - responsif padding & gap.
class BerandaMenuGrid extends StatelessWidget {
  const BerandaMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final padH = context.scaleSpace(16, medium: 16, expanded: 24, large: 32);
    final padV = context.scaleSpace(28, medium: 28, expanded: 36);
    final gap = context.scaleSpace(8, medium: 8, expanded: 12);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: BerandaMenuCard(
              label: 'Pendaftaran',
              icon: Icons.hearing_rounded,
              description: 'Kami mendengarkan semua cerita Anda tanpa ragu',
            ),
          ),
          SizedBox(width: gap),
          const Expanded(
            child: BerandaMenuCard(
              label: 'Test',
              icon: Icons.verified_user_rounded,
              description: 'Kami menjunjung tinggi kerahasiaan setiap cerita dan keluhan Anda',
            ),
          ),
          SizedBox(width: gap),
          const Expanded(
            child: BerandaMenuCard(
              label: 'Database',
              icon: Icons.menu_book_rounded,
              description: 'Berbagai pilihan artikel mengenai kesehatan mental',
            ),
          ),
        ],
      ),
    );
  }
}
