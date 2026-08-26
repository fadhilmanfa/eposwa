import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Footer Beranda - responsif stepped.
class BerandaFooter extends StatelessWidget {
  const BerandaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final padH = context.scaleSpace(16, medium: 16, expanded: 24, large: 32);
    final padVTop = context.scaleSpace(20, medium: 20, expanded: 24);
    final padVBottom = context.scaleSpace(24, medium: 24, expanded: 28);

    return Container(
      width: double.infinity,
      color: AppColors.footerDark,
      padding: EdgeInsets.fromLTRB(padH, padVTop, padH, padVBottom),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: _KontakColumn()),
                SizedBox(width: context.scaleSpace(24, expanded: 32)),
                const Expanded(child: _AlamatColumn()),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _KontakColumn(),
              SizedBox(height: context.scaleSpace(20, expanded: 24)),
              const _AlamatColumn(),
            ],
          );
        },
      ),
    );
  }
}

class _KontakColumn extends StatelessWidget {
  const _KontakColumn();

  @override
  Widget build(BuildContext context) {
    final titleSize = context.scaleText(11, medium: 12, expanded: 13);
    final textSize = context.scaleText(9, medium: 10, expanded: 11);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kontak Kami',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: context.scaleSpace(10, expanded: 12)),
        _footerRow(context, Icons.phone_rounded, '081-123-456-789', textSize),
        SizedBox(height: context.scaleSpace(6, expanded: 8)),
        _footerRow(context, Icons.email_rounded, 'layanankesehatanjiwa@gmail.com', textSize),
      ],
    );
  }

  Widget _footerRow(BuildContext context, IconData icon, String text, double textSize) {
    final circle = context.scaleSize(20, medium: 20, expanded: 24);
    final iconSize = context.scaleSize(11, medium: 11, expanded: 13);

    return Row(
      children: [
        Container(
          width: circle,
          height: circle,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: iconSize, color: Colors.white),
        ),
        SizedBox(width: context.scaleSpace(8, expanded: 10)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}

class _AlamatColumn extends StatelessWidget {
  const _AlamatColumn();

  @override
  Widget build(BuildContext context) {
    final titleSize = context.scaleText(11, medium: 12, expanded: 13);
    final textSize = context.scaleText(9, medium: 10, expanded: 11);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat Kami',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: context.scaleSpace(10, expanded: 12)),
        Text(
          'Balai Warga RW 05, Jl. Melati No.\n12, Kelurahan Sindangrasa,\nKec. Bogor Timur',
          style: TextStyle(
            fontSize: textSize,
            color: Colors.white.withValues(alpha: 0.75),
            height: 1.5,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
