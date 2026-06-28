import 'package:flutter/material.dart';

class AppResponsive {
  const AppResponsive._(this.size);

  final Size size;

  static const tabletBreakpoint = 600.0;
  static const desktopBreakpoint = 1024.0;

  static AppResponsive of(BuildContext context) {
    return AppResponsive._(MediaQuery.sizeOf(context));
  }

  bool get isMobile => size.width < tabletBreakpoint;
  bool get isTablet {
    return size.width >= tabletBreakpoint && size.width < desktopBreakpoint;
  }

  bool get isDesktop => size.width >= desktopBreakpoint;
  bool get compactHeight => size.height < 720;
  bool get useNavigationRail => size.width >= desktopBreakpoint;
  bool get useCompactLists => size.width < 760;

  double get horizontalPadding {
    if (size.width < 360) return 16;
    if (isMobile) return 20;
    if (isTablet) return 32;
    return 40;
  }

  double get verticalPadding {
    if (compactHeight) return 16;
    return isDesktop ? 32 : 24;
  }

  double get authMaxWidth => isDesktop ? 500 : 460;
  double get contentMaxWidth => 1120;
  double get wideContentMaxWidth => 1320;
  double get sheetMaxWidth => isDesktop ? 760 : double.infinity;

  int get metricColumns {
    if (isDesktop || size.width >= 720) return 4;
    return 2;
  }

  double get metricAspectRatio {
    if (isDesktop) return 1.6;
    if (isTablet) return 1.32;
    if (size.width < 380) return 0.95;
    return 1.05;
  }
}
