import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 650) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  
  static bool isMobile(BuildContext context) => width(context) < 650;
  static bool isTablet(BuildContext context) => width(context) >= 650 && width(context) < 1100;
  static bool isDesktop(BuildContext context) => width(context) >= 1100;

  static double fontSize(BuildContext context, double size) {
    final screenWidth = width(context);
    if (screenWidth < 360) return size * 0.85;
    if (screenWidth > 1100) return size * 1.15;
    return size;
  }

  static EdgeInsets padding(BuildContext context) {
    final screenWidth = width(context);
    if (screenWidth < 360) return const EdgeInsets.all(12);
    if (screenWidth < 650) return const EdgeInsets.all(16);
    if (screenWidth < 1100) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  static double cardWidth(BuildContext context) {
    final screenWidth = width(context);
    if (screenWidth < 650) return screenWidth - 32;
    if (screenWidth < 1100) return 600;
    return 800;
  }

  static int gridCrossAxisCount(BuildContext context) {
    final screenWidth = width(context);
    if (screenWidth < 650) return 1;
    if (screenWidth < 1100) return 2;
    return 3;
  }
}
