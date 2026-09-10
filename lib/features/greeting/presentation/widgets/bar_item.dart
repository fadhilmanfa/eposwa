import 'package:flutter/material.dart';

/// Satu batang grafik dengan efek hover dan tooltip.
class BarItem extends StatefulWidget {
  final double height;
  final Color color;
  final int value;

  const BarItem({
    super.key,
    required this.height,
    required this.color,
    required this.value,
  });

  @override
  State<BarItem> createState() => _BarItemState();
}

class _BarItemState extends State<BarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: '${widget.value} Orang',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isHovered)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${widget.value}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: widget.height,
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.color.withValues(alpha: 0.8)
                    : widget.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}