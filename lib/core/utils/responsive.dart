import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static const double mobileMaxWidth = 650;
  static const double tabletMaxWidth = 1100;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileMaxWidth &&
      MediaQuery.sizeOf(context).width < tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMaxWidth;

  static int gridColumns(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletMaxWidth) return desktop;
    if (width >= mobileMaxWidth) return tablet;
    return mobile;
  }

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1200) return 1140;
    return width;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletMaxWidth) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= mobileMaxWidth) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
