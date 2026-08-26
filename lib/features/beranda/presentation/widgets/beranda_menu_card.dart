import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Card menu flat - responsif stepped.
class BerandaMenuCard extends StatelessWidget {
  const BerandaMenuCard({
    super.key,
    required this.label,
    required this.icon,
    required this.description,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final circle = context.scaleSize(48, medium: 56, expanded: 64, large: 72);
    final iconSize = context.scaleSize(22, medium: 26, expanded: 30);
    final labelSize = context.scaleText(11, medium: 13, expanded: 14, large: 15);
    final descSize = context.scaleText(9, medium: 10.5, expanded: 11, large: 12);
    final vPad = context.scaleSpace(12, medium: 12, expanded: 16);
    final hPad = context.scaleSpace(8, medium: 8, expanded: 12);

    return InkWell(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fitur $label segera hadir'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Column(
          children: [
            Container(
              width: circle,
              height: circle,
              decoration: const BoxDecoration(
                color: AppColors.primaryPastel,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: context.scaleSpace(12, expanded: 14)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1.2,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: context.scaleSpace(6, expanded: 8)),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: descSize,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
                height: 1.4,
                fontFamily: 'Inter',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
