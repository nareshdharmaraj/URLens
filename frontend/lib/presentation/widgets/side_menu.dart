import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/privacy/privacy_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220), // Glassy white
        border: const Border(
          right: BorderSide(color: Colors.white, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lens, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'URLens',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 16),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildMenuItem(
                    context, 
                    title: 'Home', 
                    icon: Icons.home_rounded, 
                    isActive: true,
                    onTap: () {
                       // Typically we just close drawer if on mobile or do nothing if already on home
                       // For simplicity, we just pop if it's a drawer
                       if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                         Navigator.pop(context);
                       }
                    }
                  ),
                  _buildMenuItem(
                    context, 
                    title: 'History', 
                    icon: Icons.history_rounded,
                    onTap: () => _navigateTo(context, const HistoryScreen()),
                  ),
                  _buildMenuItem(
                    context, 
                    title: 'Settings', 
                    icon: Icons.settings_rounded,
                    onTap: () => _navigateTo(context, const SettingsScreen()),
                  ),
                  _buildMenuItem(
                    context, 
                    title: 'Privacy', 
                    icon: Icons.privacy_tip_rounded,
                    onTap: () => _navigateTo(context, const PrivacyScreen()),
                  ),
                ],
              ),
            ),

            // Footer Info
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: isActive
                ? BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(50)),
                  )
                : null,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
      Navigator.pop(context); // Close drawer first
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
