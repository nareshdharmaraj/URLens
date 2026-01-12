import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/download_option.dart';
import '../../../data/providers/download_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/format_utils.dart';

/// Download options bottom sheet
class DownloadOptionsSheet extends StatelessWidget {
  final String url;
  final String title;
  final String? thumbnailUrl;
  final String? platform;
  final List<DownloadOption> options;

  const DownloadOptionsSheet({
    super.key,
    required this.url,
    required this.title,
    this.thumbnailUrl,
    this.platform,
    required this.options,
  });

  static void show(
    BuildContext context, {
    required String url,
    required String title,
    String? thumbnailUrl,
    String? platform,
    required List<DownloadOption> options,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DownloadOptionsSheet(
        url: url,
        title: title,
        thumbnailUrl: thumbnailUrl,
        platform: platform,
        options: options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Categorize options
    final videoOptions = options.where((o) => o.type == 'video_audio' || o.type == null).toList();
    final audioOptions = options.where((o) => o.type == 'audio' || o.qualityLabel.contains('Audio')).toList();
    final videoOnlyOptions = options.where((o) => o.type == 'video_only' || o.qualityLabel.contains('Video Only')).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius * 2),
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding),
              child: Column(
                children: [
                  Text(
                    'Select Format',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Video'),
                Tab(text: 'Audio'),
                Tab(text: 'Video Only'),
              ],
            ),
            
            const Divider(height: 1),

            // Tab Views
            Flexible(
              child: TabBarView(
                children: [
                  _buildOptionList(context, videoOptions, Icons.videocam),
                  _buildOptionList(context, audioOptions, Icons.audiotrack),
                  _buildOptionList(context, videoOnlyOptions, Icons.videocam_off),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionList(BuildContext context, List<DownloadOption> options, IconData icon) {
    if (options.isEmpty) {
      return const Center(
        child: Text(
          'No options available',
          style: TextStyle(color: AppColors.textHint),
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.padding),
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final option = options[index];
        return _OptionTile(
          option: option,
          icon: icon,
          onTap: () {
            Navigator.pop(context);
            _startDownload(context, option);
          },
        );
      },
    );
  }

  void _startDownload(BuildContext context, DownloadOption option) {
    final fileName = '${title.replaceAll(RegExp(r'[^\w\s-]'), '')}.${option.extension}';

    context.read<DownloadProvider>().startDownload(
      url: url,
      fileName: fileName,
      option: option,
      title: title,
      thumbnailUrl: thumbnailUrl,
      platform: platform,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download started'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final DownloadOption option;
  final VoidCallback onTap;
  final IconData? icon;

  const _OptionTile({required this.option, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.padding),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          children: [
            // Format Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon ?? (option.qualityLabel.contains('Audio')
                    ? Icons.audiotrack
                    : Icons.videocam),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.qualityLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${option.extension.toUpperCase()} • ${option.fileSizeApprox != null ? FormatUtils.formatFileSize(option.fileSizeApprox) : 'Unknown size'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Download Icon
            const Icon(Icons.download, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
