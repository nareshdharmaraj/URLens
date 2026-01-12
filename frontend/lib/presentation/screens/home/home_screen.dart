import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/media_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as custom;
import 'widgets/url_input_card.dart';
import 'widgets/media_preview_card.dart';
import '../../widgets/active_downloads_list.dart';
import '../../widgets/main_layout.dart';
import '../../widgets/responsive_layout.dart';
import '../download/download_options_sheet.dart';
import '../../../core/services/prefs_service.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  Future<void> _checkFirstLaunch() async {
    final isFirstLaunch = await PrefsService.checkFirstLaunch();
    if (isFirstLaunch && mounted) {
      _showDisclaimer();
    }
  }

  void _showDownloadOptions() async {
    final provider = context.read<MediaProvider>();

    if (provider.currentUrl == null) return;

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
    return MainLayout(
      title: AppConstants.appName,
      child: ResponsiveLayout(
        sideMenu: const SizedBox(), // Handled by MainLayout
        mobile: _buildContent(isDesktop: false),
        desktop: _buildContent(isDesktop: true),
      ),
    );
  }

  Widget _buildContent({required bool isDesktop}) {
    if (isDesktop) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.padding * 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel: Input & Active Downloads
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),
                  const URLInputCard(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            
            // Right Panel: Analysis Result
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  _buildDynamicContent(),
                  const SizedBox(height: 32),
                  const ActiveDownloadsList(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          const URLInputCard(),
          const SizedBox(height: 16),
          _buildDynamicContent(),
          const SizedBox(height: 24),
          const ActiveDownloadsList(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
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
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDynamicContent() {
    return Consumer<MediaProvider>(
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

        if (provider.hasMetadata && provider.currentMetadata != null) {
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

        // REMOVED SupportedPlatforms Widget as requested
        return const SizedBox.shrink();
      },
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
