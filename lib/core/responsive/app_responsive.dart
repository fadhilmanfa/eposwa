import 'package:flutter/material.dart';
import 'package:eposwa/core/responsive/app_breakpoints.dart';

/// Helper responsif untuk ePOSWA di Desktop, Tablet, dan Mobile.
/// Mendukung responsive scaling dan clamping yang proporsional.
extension AppResponsive on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Scale fontSize stepped.
  /// Jika medium/expanded/large diisi, nilai tersebut akan digunakan secara presisi.
  double scaleText(
    double compact, {
    double? medium,
    double? expanded,
    double? large,
  }) {
    final w = screenWidth;
    if (w >= AppBreakpoints.expanded) {
      return large ?? expanded ?? medium ?? (compact * 1.25);
    } else if (w >= AppBreakpoints.medium) {
      return expanded ?? medium ?? (compact * 1.15);
    } else if (w >= AppBreakpoints.compact) {
      return medium ?? (compact * 1.05);
    } else {
      return compact;
    }
  }

  /// Scale padding/spacing stepped.
  double scaleSpace(
    double compact, {
    double? medium,
    double? expanded,
    double? large,
  }) {
    return scaleText(compact, medium: medium, expanded: expanded, large: large);
  }

  /// Scale height/width visual (ilustrasi, circle, icon, dll).
  double scaleSize(
    double compact, {
    double? medium,
    double? expanded,
    double? large,
  }) {
    return scaleText(compact, medium: medium, expanded: expanded, large: large);
  }

  bool get isCompact => AppBreakpoints.isCompact(this);
  bool get isMedium => AppBreakpoints.isMedium(this);
  bool get isExpanded => AppBreakpoints.isExpanded(this);
  bool get isLarge => AppBreakpoints.isLarge(this);

  /// Horizontal padding standar berdasarkan breakpoint
  EdgeInsets get responsiveHorizontalPadding {
    if (isLarge) {
      return const EdgeInsets.symmetric(horizontal: 48);
    } else if (isExpanded) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else if (isMedium) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16);
    }
  }
}

/// Widget pembungkus untuk membatasi lebar maksimum konten (misal: 1200px)
/// dan memposisikannya di tengah layar dengan padding responsif.
class AppContainer extends StatelessWidget {
  const AppContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final horizontalPad = context.responsiveHorizontalPadding;
    final finalPadding = padding != null
        ? horizontalPad.add(padding!)
        : horizontalPad;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: finalPadding,
        child: child,
      ),
    );
  }
}

