import 'package:flutter/material.dart';
import 'package:eposwa/core/constants/app_colors.dart';

/// Card Menu Layanan modern untuk ePOSWA - Bersih & clickable langsung pada seluruh card.
class BerandaMenuCard extends StatefulWidget {
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
  State<BerandaMenuCard> createState() => _BerandaMenuCardState();
}

class _BerandaMenuCardState extends State<BerandaMenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.primaryLight : AppColors.borderLight,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: _isHovered ? 28 : 20,
              offset: Offset(0, _isHovered ? 12 : 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Membuka modul ${widget.label}...'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _isHovered ? AppColors.primary : AppColors.primaryPastel,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 28,
                    color: _isHovered ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Card Title
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),

                // Card Description
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                    height: 1.55,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
