import 'package:flutter/material.dart';
import 'package:eposwa/core/responsive/app_breakpoints.dart';

/// Helper responsif stepped untuk Windows.
/// Base adalah compact (<600). Medium/Expanded/Large override jika disediakan.
/// Selalu clamp 0.85x - 1.3x dari compact agar tidak terlalu kecil/besar.
/// Hormati MediaQuery.textScaler: tidak override, biarkan Text scaling sistem tetap bekerja.
extension AppResponsive on BuildContext {
  /// Scale fontSize stepped + clamp.
  double scaleText(
    double compact, {
    double? medium,
    double? expanded,
    double? large,
  }) {
    final w = MediaQuery.sizeOf(this).width;
    double base;
    if (w >= AppBreakpoints.expanded) {
      base = large ?? expanded ?? medium ?? compact * 1.3;
    } else if (w >= AppBreakpoints.medium) {
      base = expanded ?? medium ?? compact * 1.15;
    } else if (w >= AppBreakpoints.compact) {
      base = medium ?? compact * 1.1;
    } else {
      base = compact;
    }
    final min = compact * 0.85;
    final max = compact * 1.3;
    return base.clamp(min, max);
  }

  /// Scale padding/spacing stepped.
  double scaleSpace(double compact, {double? medium, double? expanded, double? large}) {
    return scaleText(compact, medium: medium, expanded: expanded, large: large);
  }

  /// Scale height/width visual (ilustrasi, circle, dll).
  double scaleSize(double compact, {double? medium, double? expanded, double? large}) {
    return scaleText(compact, medium: medium, expanded: expanded, large: large);
  }

  bool get isCompact => AppBreakpoints.isCompact(this);
  bool get isMedium => AppBreakpoints.isMedium(this);
  bool get isExpanded => AppBreakpoints.isExpanded(this);
  bool get isLarge => AppBreakpoints.isLarge(this);
}
