import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/download_option.dart';
import '../models/download_record.dart';
import '../repositories/download_repository.dart';
import '../../core/services/notification_service.dart';

/// Download task model
class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  final DownloadOption option;
  final String? title;
  final String? thumbnailUrl;
  final String? platform;
  double progress;
  String status; // downloading, completed, failed, cancelled
  String? filePath;
  String? error;
  CancelToken? cancelToken;

  DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    required this.option,
    this.title,
    this.thumbnailUrl,
    this.platform,
    this.progress = 0.0,
    this.status = 'downloading',
    this.filePath,
    this.error,
    this.cancelToken,
  });
}

/// Provider for download management
class DownloadProvider with ChangeNotifier {
  final DownloadRepository _repository;

  DownloadProvider({DownloadRepository? repository})
    : _repository = repository ?? DownloadRepository();

  // State variables
  final Map<String, DownloadTask> _activeTasks = {};

  // Getters
  Map<String, DownloadTask> get activeTasks => Map.unmodifiable(_activeTasks);
  List<DownloadTask> get activeTasksList => _activeTasks.values.toList();
  int get activeDownloadCount => _activeTasks.length;
  bool get hasActiveDownloads => _activeTasks.isNotEmpty;

  /// Start download
  Future<void> startDownload({
    required String url,
    required String fileName,
    required DownloadOption option,
    String? title,
    String? thumbnailUrl,
    String? platform,
  }) async {
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    final cancelToken = CancelToken();

    final task = DownloadTask(
      id: taskId,
      url: option.downloadUrl,
      fileName: fileName,
      option: option,
      title: title,
      thumbnailUrl: thumbnailUrl,
      platform: platform,
      cancelToken: cancelToken,
    );

    _activeTasks[taskId] = task;
    notifyListeners();

    // Show initial notification
    final notificationId = taskId.hashCode;
    await NotificationService().showProgressNotification(
      id: notificationId,
      title: 'Downloading $fileName',
      body: 'Starting...',
      progress: 0,
      maxProgress: 100,
    );

    try {
      final filePath = await _repository.downloadFile(
        url: option.downloadUrl,
        fileName: fileName,
        originalUrl: url, // Pass original URL for merged formats
        onProgress: (received, total) {
          if (total > 0) {
            task.progress = received / total;
            notifyListeners();

            // Update notification every 5%
            if ((task.progress * 100).toInt() % 5 == 0) {
              NotificationService().showProgressNotification(
                id: notificationId,
                title: 'Downloading $fileName',
                body: '${(task.progress * 100).toInt()}%',
                progress: (task.progress * 100).toInt(),
                maxProgress: 100,
              );
            }
          }
        },
        cancelToken: cancelToken,
      );

      // Verify file exists (Mobile/Desktop only)
      if (!kIsWeb) {
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('Download finished but file not found at $filePath');
        }
      }

      // Update task success state immediately so UI reflects it
      task.status = 'completed';
      task.filePath = filePath;
      notifyListeners();

      // Show completion notification
      await NotificationService().showCompletionNotification(
        id: notificationId,
        title: 'Download Complete',
        body: '$fileName downloaded successfully',
        filePath: filePath,
      );

      // Get actual file size (safe)
      int fileSize = option.fileSizeApprox ?? 0;
      if (!kIsWeb) {
        try {
          final file = File(filePath);
          fileSize = await file.length();
        } catch (e) {
          debugPrint('Warning: Could not get file size: $e');
        }
      }

      // Save to database (Isolated try-catch)
      try {
        await _repository.saveDownloadRecord(
          DownloadRecord(
            originalUrl: url,
            title: title ?? fileName,
            thumbnailUrl: thumbnailUrl,
            platform: platform,
            localFilePath: filePath,
            fileSize: fileSize,
            downloadDate: DateTime.now(),
          ),
        );
      } catch (dbError) {
        debugPrint('Database Error: $dbError');
        // Do NOT fail the download task if DB fails, just log it.
        // But maybe show a toast?
      }

      notifyListeners();

      // Remove from active tasks after delay
      Future.delayed(const Duration(seconds: 3), () {
        _activeTasks.remove(taskId);
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Download Error: $e');
      task.status = 'failed';
      task.error = _getFriendlyErrorMessage(e);
      notifyListeners();

      // Show failure notification with detailed error
      await NotificationService().showNotification(
        id: notificationId,
        title: 'Download Failed',
        body: task.error ?? 'Unknown error',
      );
    }
  }

  String _getFriendlyErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please checking your internet.';
        case DioExceptionType.badResponse:
          return 'Server error (${error.response?.statusCode}). Please try again.';
        case DioExceptionType.cancel:
          return 'Download cancelled.';
        case DioExceptionType.connectionError:
          return 'No internet connection.';
        default:
          return 'Network error occurred.';
      }
    } else if (error.toString().contains('FileSystemException')) {
      if (error.toString().contains('No space left on device')) {
        return 'Storage full. Please free up space.';
      } else if (error.toString().contains('Permission denied')) {
        return 'Storage permission denied.';
      }
      return 'File system error. Please check storage permissions.';
    }

    return error.toString().length > 50
        ? 'An unexpected error occurred.'
        : error.toString();
  }

  /// Cancel download
  void cancelDownload(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.cancelToken?.cancel('Download cancelled by user');
      task.status = 'cancelled';
      _activeTasks.remove(taskId);

      // Cancel notification
      NotificationService().cancelNotification(taskId.hashCode);

      notifyListeners();
    }
  }

  /// Retry failed download
  Future<void> retryDownload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task != null && task.status == 'failed') {
      task.status = 'downloading';
      task.progress = 0.0;
      task.error = null;
      task.cancelToken = CancelToken();
      notifyListeners();

      // Restart download (simplified - in production, you'd want to preserve more metadata)
      await startDownload(
        url: task.url,
        fileName: task.fileName,
        option: task.option,
        title: task.title,
        thumbnailUrl: task.thumbnailUrl,
        platform: task.platform,
      );
    }
  }

  /// Clear completed downloads
  void clearCompleted() {
    _activeTasks.removeWhere((key, task) => task.status == 'completed');
    notifyListeners();
  }

  /// Get task by ID
  DownloadTask? getTask(String taskId) {
    return _activeTasks[taskId];
  }
}
