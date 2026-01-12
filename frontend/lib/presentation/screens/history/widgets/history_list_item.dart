import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../data/models/download_record.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../widgets/platform_icon.dart';

/// History list item widget
class HistoryListItem extends StatelessWidget {
  final DownloadRecord record;
  final VoidCallback onDelete;

  const HistoryListItem({
    super.key,
    required this.record,
    required this.onDelete,
  });

  Future<void> _openFile(BuildContext context) async {
    try {
      final result = await OpenFile.open(record.localFilePath);
      if (result.type != ResultType.done) {
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Could not open file: ${result.message}')),
           );
         }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
         // Share plus might check file existence, but let's be safe
         await Share.shareXFiles([XFile(record.localFilePath)]);
      } else {
         await Share.shareXFiles([XFile(record.localFilePath)]);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing file: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _locateFile(BuildContext context) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer.exe', ['/select,${record.localFilePath}']);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', record.localFilePath]);
      } else if (Platform.isLinux) {
        // Try dbus-send or nautilus
        await Process.run('xdg-open', [File(record.localFilePath).parent.path]);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error locating file: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return Card(
      child: InkWell(
        onTap: () => _openFile(context),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: record.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: record.thumbnailUrl!,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 60,
                          color: AppColors.surface,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 60,
                          color: AppColors.surface,
                          child: Icon(
                            FileUtils.isVideo(record.localFilePath)
                                ? Icons.videocam
                                : FileUtils.isAudio(record.localFilePath)
                                ? Icons.audiotrack
                                : Icons.image,
                            color: AppColors.textHint,
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 60,
                        color: AppColors.surface,
                        child: Icon(
                          FileUtils.isVideo(record.localFilePath)
                              ? Icons.videocam
                              : FileUtils.isAudio(record.localFilePath)
                              ? Icons.audiotrack
                              : Icons.image,
                          color: AppColors.textHint,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Platform & Date
                    Row(
                      children: [
                        if (record.platform != null) ...[
                          PlatformIcon(platform: record.platform!, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            record.platform!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          FormatUtils.formatDate(record.downloadDate),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // File Size
                    if (record.fileSize != null)
                      Text(
                        FormatUtils.formatFileSize(record.fileSize),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new, size: 20),
                        SizedBox(width: 8),
                        Text('Open'),
                      ],
                    ),
                  ),
                  if (isDesktop)
                    const PopupMenuItem(
                      value: 'locate',
                      child: Row(
                        children: [
                          Icon(Icons.folder_open, size: 20),
                          SizedBox(width: 8),
                          Text('Locate File'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'open':
                      _openFile(context);
                      break;
                    case 'locate':
                      _locateFile(context);
                      break;
                    case 'share':
                      _shareFile(context);
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
