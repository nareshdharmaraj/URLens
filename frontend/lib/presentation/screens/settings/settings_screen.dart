import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/main_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Settings',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Preferences'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Receive download updates'),
                      value: settings.notificationsEnabled,
                      onChanged: (value) {
                         settings.toggleNotifications(value);
                      },
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.notifications, color: AppColors.primary),
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Use dark theme'),
                      value: settings.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        settings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                      },
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.dark_mode, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(),
                 ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to privacy
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
