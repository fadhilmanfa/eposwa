import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';
import 'package:eposwa/core/responsive/app_responsive.dart';

/// Footer Minimalis ePOSWA - Menampilkan Hak Cipta & Informasi Versi.
class BerandaFooter extends StatelessWidget {
  const BerandaFooter({
    super.key,
    this.version = 'v1.0.0',
  });

  final String version;

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    return Container(
      width: double.infinity,
      color: AppColors.footerDarker,
      margin: EdgeInsets.only(
        top: context.scaleSpace(40, medium: 56, expanded: 72, large: 88),
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.scaleSpace(18, medium: 22, expanded: 24),
      ),
      child: AppContainer(
        child: isCompact
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '© 2026 ePOSWA. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Versi $version',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.45),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '© 2026 ePOSWA. All rights reserved.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Versi $version',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
