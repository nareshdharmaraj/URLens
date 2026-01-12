import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Glassy effect
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(150), // Semi-transparent
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withAlpha(20),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // automaticallyImplyLeading defaults to true, which we want:
            // - Shows Menu icon if Drawer exists (Mobile Home)
            // - Shows Back icon if Navigator has history (Settings)
            // - Shows nothing if neither (Desktop Home)
            centerTitle: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lens, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'URLens',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                if (title != 'URLens' && title.isNotEmpty) ...[
                   Container(
                     margin: const EdgeInsets.symmetric(horizontal: 12),
                     height: 20,
                     width: 1,
                     color: AppColors.textSecondary.withAlpha(50), 
                   ),
                   Flexible(
                     child: Text(
                       title,
                       overflow: TextOverflow.ellipsis,
                       style: const TextStyle(
                         fontWeight: FontWeight.w500,
                         fontSize: 18,
                         letterSpacing: 0.5,
                         color: AppColors.textSecondary,
                       ),
                     ),
                   ),
                ],
              ],
            ),
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
