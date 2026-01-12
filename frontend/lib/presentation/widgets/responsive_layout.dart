import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final Widget? sideMenu; // Added side menu support

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.sideMenu,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800; // Increased breakpoint for tablet

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          // Desktop: Show Side Menu + Desktop Layout
          if (sideMenu != null) {
              return Row(
                  children: [
                      sideMenu!,
                      Expanded(child: desktop),
                  ],
              );
          }
          return desktop;
        } else if (constraints.maxWidth >= 800) {
           // Tablet: Show Side Menu (if fits) + Tablet/Desktop Layout
           if (sideMenu != null) {
              return Row(
                  children: [
                      sideMenu!,
                      Expanded(child: tablet ?? desktop),
                  ],
              );
           }
          return tablet ?? desktop;
        } else {
          // Mobile: Just mobile layout (SideMenu will be in Drawer)
          return mobile;
        }
      },
    );
  }
}
