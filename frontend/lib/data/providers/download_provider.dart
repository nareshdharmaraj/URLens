import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/download_option.dart';
import '../models/download_record.dart';
import '../repositories/download_repository.dart';

/// Download task model
class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  final DownloadOption option;
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
      cancelToken: cancelToken,
    );

    _activeTasks[taskId] = task;
    notifyListeners();

    try {
      final filePath = await _repository.downloadFile(
        url: option.downloadUrl,
        fileName: fileName,
        onProgress: (received, total) {
          if (total > 0) {
            task.progress = received / total;
            notifyListeners();
          }
        },
        cancelToken: cancelToken,
      );

      // Update task
      task.status = 'completed';
      task.filePath = filePath;

      // Get actual file size
      final fileSize = await _repository
          .downloadFile(
            url: option.downloadUrl,
            fileName: fileName,
            onProgress: (_, __) {},
          )
          .then((_) => option.fileSizeApprox ?? 0);

      // Save to database
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

      notifyListeners();

      // Remove from active tasks after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _activeTasks.remove(taskId);
        notifyListeners();
      });
    } catch (e) {
      task.status = 'failed';
      task.error = e.toString();
      notifyListeners();
    }
  }

  /// Cancel download
  void cancelDownload(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.cancelToken?.cancel('Download cancelled by user');
      task.status = 'cancelled';
      _activeTasks.remove(taskId);
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
