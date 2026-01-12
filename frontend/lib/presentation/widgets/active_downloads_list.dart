import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/download_provider.dart';
import '../../core/theme/app_colors.dart';


class ActiveDownloadsList extends StatelessWidget {
  const ActiveDownloadsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, provider, _) {
        if (!provider.hasActiveDownloads) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.downloading, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Active Downloads',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.activeTasksList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = provider.activeTasksList[index];
                  return _ActiveDownloadItem(task: task);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveDownloadItem extends StatelessWidget {
  final DownloadTask task;

  const _ActiveDownloadItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                        Text(
                          task.status == 'downloading'
                              ? '${(task.progress * 100).toInt()}% • ${task.option.qualityLabel}'
                              : (task.status == 'failed' && task.error != null) 
                                  ? task.error! 
                                  : task.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: task.status == 'failed'
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (task.status == 'downloading')
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    color: AppColors.error,
                    onPressed: () {
                      context.read<DownloadProvider>().cancelDownload(task.id);
                    },
                    tooltip: 'Cancel',
                  )
                else if (task.status == 'failed')
                   IconButton(
                    icon: const Icon(Icons.refresh),
                    color: AppColors.primary,
                    onPressed: () {
                      context.read<DownloadProvider>().retryDownload(task.id);
                    },
                    tooltip: 'Retry',
                  ),
              ],
            ),
            if (task.status == 'downloading') ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: task.progress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
