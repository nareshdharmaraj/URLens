// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../widgets/main_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/data_sources/local/database_helper.dart';
import '../privacy/privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all download history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await DatabaseHelper.instance.clearAllDownloads();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('History cleared successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear history: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Settings',
      showBackButton: true,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance', Icons.palette_outlined),
          _buildAppearanceCard(),

          const SizedBox(height: 24),

          // Download Settings
          _buildSectionHeader('Downloads', Icons.download_outlined),
          _buildDownloadCard(),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader('Notifications', Icons.notifications_outlined),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: const Text(
                        'Download Notifications',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Get notified when downloads complete',
                      ),
                      value: settings.notificationsEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (value) {
                        settings.toggleNotifications(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Notifications enabled'
                                  : 'Notifications disabled',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      secondary: _buildIconContainer(
                        Icons.notifications_active,
                        AppColors.accent,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),



          const SizedBox(height: 24),

          // Storage Section
          _buildSectionHeader('Storage', Icons.storage_outlined),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: _buildIconContainer(
                    Icons.delete_sweep,
                    AppColors.error,
                  ),
                  title: const Text(
                    'Clear History',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Remove all download history'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  onTap: _clearHistory,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About', Icons.info_outline),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: _buildIconContainer(Icons.info, AppColors.info),
                  title: const Text(
                    'Version',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    '$_version ($_buildNumber)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: _buildIconContainer(
                    Icons.privacy_tip,
                    AppColors.warning,
                  ),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyScreen(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: _buildIconContainer(
                    Icons.bug_report,
                    AppColors.accent,
                  ),
                  title: const Text(
                    'Report an Issue',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Help us improve URLens'),
                  trailing: const Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  onTap: () => _launchURL('https://github.com/issues'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  'Made with ❤️ by URLens Team',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© ${DateTime.now().year} URLens. All rights reserved.',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildAppearanceCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: _buildIconContainer(
                  Icons.brightness_6,
                  AppColors.secondary,
                ),
                title: const Text(
                  'Theme Mode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  settings.themeMode == ThemeMode.dark
                      ? 'Dark'
                      : settings.themeMode == ThemeMode.light
                      ? 'Light'
                      : 'System Default',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textHint,
                ),
                onTap: () => _showThemeDialog(context, settings),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: _buildIconContainer(
                  Icons.video_library,
                  AppColors.primary,
                ),
                title: const Text(
                  'Default Quality',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(settings.defaultQuality),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textHint,
                ),
                onTap: () => _showQualityDialog(context, settings),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: const Text(
                  'Auto-merge Audio & Video',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Automatically merge separate streams'),
                value: settings.autoMergeStreams,
                activeTrackColor: AppColors.primary,
                onChanged: (value) {
                  settings.setAutoMergeStreams(value);
                },
                secondary: _buildIconContainer(
                  Icons.merge_type,
                  AppColors.success,
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: _buildIconContainer(Icons.folder, AppColors.warning),
                title: const Text(
                  'Download Location',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(settings.downloadPath),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textHint,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Download location: ${settings.downloadPath}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQualityDialog(BuildContext context, SettingsProvider settings) {
    final qualities = ['Best Available', '1080p', '720p', '480p', '360p'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: qualities.map((quality) {
            return RadioListTile<String>(
              title: Text(quality),
              value: quality,
              groupValue: settings.defaultQuality,
              onChanged: (String? value) {
                if (value != null) {
                  settings.setDefaultQuality(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
