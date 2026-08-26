import 'package:flutter/material.dart';

/// Breakpoint terpusat untuk responsif Windows & lainnya.
/// Mengikuti Material 3 Window Size Class (compact/medium/expanded/large).
class AppBreakpoints {
  AppBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMedium(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= compact && w < medium;
  }

  static bool isExpanded(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= medium && w < expanded;
  }

  static bool isLarge(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;
}
