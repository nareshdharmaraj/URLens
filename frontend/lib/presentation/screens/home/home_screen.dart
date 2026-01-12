import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/media_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as custom;
import 'widgets/url_input_card.dart';
import 'widgets/media_preview_card.dart';
import '../download/download_options_sheet.dart';
import '../history/history_screen.dart';

/// Home screen - Main screen for URL input and analysis
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Show disclaimer on first launch (simplified - in production, check if it's first launch)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  Future<void> _checkFirstLaunch() async {
    // In production, use SharedPreferences to check if it's first launch
    // For now, we'll skip showing the disclaimer on every launch
  }

  void _showDownloadOptions() async {
    final provider = context.read<MediaProvider>();

    if (provider.currentUrl == null) return;

    // Fetch download options if not already fetched
    if (!provider.hasOptions) {
      await provider.fetchDownloadOptions(provider.currentUrl!);
    }

    if (!mounted) return;

    if (provider.hasOptions && provider.downloadOptions != null) {
      DownloadOptionsSheet.show(
        context,
        url: provider.currentUrl!,
        title: provider.currentMetadata?.title ?? 'Media',
        thumbnailUrl: provider.currentMetadata?.thumbnailUrl,
        platform: provider.currentMetadata?.platform,
        options: provider.downloadOptions!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.download, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            tooltip: 'Download History',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'About',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Section
              Text(
                'Download Media from Any Platform',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Paste a URL to get started',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // URL Input Card
              const URLInputCard(),
              const SizedBox(height: 24),

              // Content based on state
              Consumer<MediaProvider>(
                builder: (context, provider, child) {
                  if (provider.isAnalyzing) {
                    return const LoadingIndicator(message: 'Analyzing URL...');
                  }

                  if (provider.error != null) {
                    return custom.ErrorWidget(
                      message: provider.error!,
                      onRetry: () {
                        provider.clearError();
                      },
                    );
                  }

                  if (provider.hasMetadata &&
                      provider.currentMetadata != null) {
                    return Column(
                      children: [
                        MediaPreviewCard(
                          metadata: provider.currentMetadata!,
                          onDownload: _showDownloadOptions,
                        ),
                        if (provider.isFetchingOptions) ...[
                          const SizedBox(height: 16),
                          const LoadingIndicator(
                            message: 'Fetching download options...',
                          ),
                        ],
                      ],
                    );
                  }

                  return _buildSupportedPlatforms();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportedPlatforms() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  'Supported Platforms',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        'YouTube',
                        'Instagram',
                        'Twitter',
                        'Facebook',
                        'TikTok',
                        'Vimeo',
                        '& more...',
                      ]
                      .map(
                        (platform) => Chip(
                          label: Text(
                            platform,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${AppConstants.appVersion}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(AppConstants.appDescription),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDisclaimer();
              },
              child: const Text('View Disclaimer'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDisclaimer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disclaimer & Terms'),
        content: SingleChildScrollView(
          child: Text(
            AppConstants.disclaimer,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }
}
