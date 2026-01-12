import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../data_sources/local/database_helper.dart';
import '../data_sources/local/file_manager.dart';
import '../models/download_record.dart';

/// Repository for download-related operations
class DownloadRepository {
  final DatabaseHelper _databaseHelper;
  final FileManager _fileManager;

  DownloadRepository({DatabaseHelper? databaseHelper, FileManager? fileManager})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
      _fileManager = fileManager ?? FileManager();

  /// Download file
  Future<String> downloadFile({
    required String url,
    required String fileName,
    required Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    return await _fileManager.downloadFile(
      url: url,
      fileName: fileName,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  /// Save download record to database
  Future<int> saveDownloadRecord(DownloadRecord record) async {
    if (kIsWeb) return 0;
    return await _databaseHelper.insertDownload(record);
  }

  /// Get all downloads
  Future<List<DownloadRecord>> getAllDownloads() async {
    if (kIsWeb) return [];
    return await _databaseHelper.getAllDownloads();
  }

  /// Get download by ID
  Future<DownloadRecord?> getDownloadById(int id) async {
    if (kIsWeb) return null;
    return await _databaseHelper.getDownloadById(id);
  }

  /// Search downloads
  Future<List<DownloadRecord>> searchDownloads(String query) async {
    if (kIsWeb) return [];
    return await _databaseHelper.searchDownloads(query);
  }

  /// Filter downloads by platform
  Future<List<DownloadRecord>> getDownloadsByPlatform(String platform) async {
    if (kIsWeb) return [];
    return await _databaseHelper.getDownloadsByPlatform(platform);
  }

  /// Delete download (file + record)
  Future<bool> deleteDownload(int id) async {
    if (kIsWeb) return false;
    final record = await _databaseHelper.getDownloadById(id);

    if (record != null) {
      // Delete file
      await _fileManager.deleteFile(record.localFilePath);

      // Delete database record
      await _databaseHelper.deleteDownload(id);

      return true;
    }

    return false;
  }

  /// Clear all downloads
  Future<void> clearAllDownloads() async {
    if (kIsWeb) return;
    final downloads = await _databaseHelper.getAllDownloads();

    // Delete all files
    for (final download in downloads) {
      await _fileManager.deleteFile(download.localFilePath);
    }

    // Clear database
    await _databaseHelper.clearAllDownloads();
  }

  /// Get download count
  Future<int> getDownloadCount() async {
    if (kIsWeb) return 0;
    return await _databaseHelper.getDownloadCount();
  }
}
