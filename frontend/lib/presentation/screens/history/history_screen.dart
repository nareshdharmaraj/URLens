import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/history_provider.dart';
import '../../../data/models/download_record.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/main_layout.dart';
import 'widgets/history_list_item.dart';

/// History screen - Shows download history
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadDownloads();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<HistoryProvider>().refresh();
  }

  void _search(String query) {
    context.read<HistoryProvider>().searchDownloads(query);
  }

  void _showDeleteConfirmation(DownloadRecord record) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Delete "${record.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context
                  .read<HistoryProvider>()
                  .deleteDownload(record.id!);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Download deleted'
                          : 'Failed to delete download',
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Delete all downloads? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<HistoryProvider>().clearAll();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All downloads cleared')),
                );
              }
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'History',
      child: Column(
        children: [
          // Header with Clear All
          Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Downloads',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Consumer<HistoryProvider>(
                  builder: (context, provider, child) {
                    if (provider.hasDownloads) {
                      return TextButton.icon(
                        onPressed: _showClearAllConfirmation,
                        icon: const Icon(Icons.delete_sweep, color: AppColors.error),
                        label: const Text(
                          'Clear All',
                          style: TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search downloads...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
              onChanged: _search,
            ),
          ),

          // Content
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator(message: 'Loading history...');
                }

                if (!provider.hasDownloads) {
                  return EmptyState(
                    icon: Icons.download_outlined,
                    title: 'No Downloads Yet',
                    message: 'Your downloaded media will appear here',
                    action: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.padding,
                    ),
                    itemCount: provider.downloads.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final record = provider.downloads[index];
                      return HistoryListItem(
                        record: record,
                        onDelete: () => _showDeleteConfirmation(record),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
