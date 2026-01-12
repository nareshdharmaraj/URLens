import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:universal_html/html.dart' as html;
import '../../../core/utils/file_utils.dart';
import '../../../core/constants/api_constants.dart';

/// File manager for download operations
class FileManager {
  final Dio _dio;

  FileManager() : _dio = Dio();

  /// Download file from URL
  Future<String> downloadFile({
    required String url,
    required String fileName,
    required Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      // Use backend proxy endpoint to avoid CORS issues
      final String proxyUrl = ApiConstants.proxyDownloadEndpoint;

      if (kIsWeb) {
        // Web download logic using proxy
        final response = await _dio.get(
          proxyUrl,
          queryParameters: {'url': url, 'filename': fileName},
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            receiveTimeout: const Duration(minutes: 10),
          ),
          onReceiveProgress: onProgress,
        );

        final blob = html.Blob([response.data]);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: blobUrl)
          ..setAttribute('download', fileName)
          ..click();

        html.Url.revokeObjectUrl(blobUrl);
        return fileName; // On web we don't have a real path
      } else {
        // Mobile/Desktop logic
        final downloadsDir = await FileUtils.getDownloadsDirectory();

        // Generate unique filename if file exists
        String finalFileName = fileName;
        String filePath = path.join(downloadsDir.path, finalFileName);

        if (await File(filePath).exists()) {
          finalFileName = FileUtils.generateUniqueFilename(fileName);
          filePath = path.join(downloadsDir.path, finalFileName);
        }

        // Download file using backend proxy
        await _dio.download(
          proxyUrl,
          filePath,
          queryParameters: {'url': url, 'filename': fileName},
          onReceiveProgress: onProgress,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            receiveTimeout: const Duration(minutes: 10),
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        );

        return filePath;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete file
  Future<bool> deleteFile(String filePath) async {
    return await FileUtils.deleteFile(filePath);
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    return await FileUtils.fileExists(filePath);
  }

  /// Get file size
  Future<int> getFileSize(String filePath) async {
    return await FileUtils.getFileSize(filePath);
  }

  /// Open file with default application
  Future<void> openFile(String filePath) async {
    // This will be implemented using open_file package
    // in the presentation layer
  }

  /// Share file
  Future<void> shareFile(String filePath) async {
    // This will be implemented using share_plus package
    // in the presentation layer
  }
}
