import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'responsive_layout.dart';
import 'custom_app_bar.dart';
import 'footer.dart';
import 'side_menu.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showBackButton;

  const MainLayout({
    super.key,
    required this.child,
    this.title = AppConstants.appName,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: isMobile ? const SideMenu() : null,
      appBar: CustomAppBar(
        title: title,
        showBackButton: showBackButton,
        actions: [], // Actions are in SideMenu now
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ResponsiveLayout(
            sideMenu: const SideMenu(),
            mobile: Column(
              children: [
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: child,
                  ),
                ),
                const Footer(),
              ],
            ),
            desktop: Column(
              children: [
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: child,
                  ),
                ),
                const Footer(), // Generic Footer for desktop too
              ],
            ),
          ),
        ),
      ),
    );
  }
}
