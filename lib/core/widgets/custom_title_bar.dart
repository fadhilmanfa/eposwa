import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:eposwa/core/constants/app_colors.dart';

/// Custom title bar frameless untuk Windows/Linux/macOS.
/// - Area tengah bisa di-drag untuk memindahkan window.
/// - Tombol minimize / maximize / close custom (gantikan tombol sistem).
/// - Otomatis hidden di Web & Mobile.
class CustomTitleBar extends StatefulWidget {
  const CustomTitleBar({super.key, this.height = 36});

  final double height;

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar>
    with WindowListener {
  bool _isMaximized = false;
  bool _isDesktop = false;

  @override
  void initState() {
    super.initState();
    _isDesktop = !kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    if (_isDesktop) {
      windowManager.addListener(this);
      _updateMaximized();
    }
  }

  @override
  void dispose() {
    if (_isDesktop) windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _updateMaximized() async {
    if (!_isDesktop) return;
    final maximized = await windowManager.isMaximized();
    if (mounted && maximized != _isMaximized) {
      setState(() => _isMaximized = maximized);
    }
  }

  @override
  void onWindowMaximize() => _updateMaximized();

  @override
  void onWindowUnmaximize() => _updateMaximized();

  @override
  void onWindowRestore() => _updateMaximized();

  @override
  Widget build(BuildContext context) {
    // Di Web/Mobile jangan tampilkan title bar custom
    if (!_isDesktop) return const SizedBox.shrink();

    return Container(
      height: widget.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Kiri: kosong, hanya area draggable
          const Expanded(
            child: DragToMoveArea(
              child: SizedBox.expand(),
            ),
          ),

          // Tombol window controls
          _WindowButton(
            icon: Icons.minimize_rounded,
            tooltip: 'Minimize',
            onPressed: () => windowManager.minimize(),
          ),
          _WindowButton(
            icon: _isMaximized
                ? Icons.filter_none_rounded // restore icon
                : Icons.crop_square_rounded, // maximize icon
            tooltip: _isMaximized ? 'Restore' : 'Maximize',
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
          ),
          _WindowButton(
            icon: Icons.close_rounded,
            tooltip: 'Close',
            isClose: true,
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isClose = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isClose;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = _hovered
        ? (widget.isClose ? const Color(0xFFE81123) : const Color(0xFFE5E7EB))
        : Colors.transparent;
    final iconColor = _hovered && widget.isClose
        ? Colors.white
        : AppColors.textDark.withValues(alpha: 0.75);

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: 46,
            height: double.infinity,
            color: bgColor,
            child: Icon(widget.icon, size: 16, color: iconColor),
          ),
        ),
      ),
    );
  }
}
