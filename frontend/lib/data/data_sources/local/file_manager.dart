import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:universal_html/html.dart' as html;
import 'package:image_gallery_saver/image_gallery_saver.dart';
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
    String? originalUrl, // Add original URL for merged formats
    required Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      // Check if this is a merged format
      final isMergedFormat = url.startsWith('MERGE:');
      final String proxyUrl = isMergedFormat
          ? '${ApiConstants.baseUrl}/api/${ApiConstants.apiVersion}/download-merged'
          : ApiConstants.proxyDownloadEndpoint;

      if (kIsWeb) {
        // Web download logic using proxy
        final queryParams = isMergedFormat
            ? {
                'original_url': originalUrl ?? url,
                'format_id': url.replaceFirst('MERGE:', ''),
                'filename': fileName,
              }
            : {'url': url, 'filename': fileName};

        final response = await _dio.get(
          proxyUrl,
          queryParameters: queryParams,
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

        // Download file using backend proxy or merged download
        final queryParams = isMergedFormat
            ? {
                'original_url': originalUrl ?? url,
                'format_id': url.replaceFirst('MERGE:', ''),
                'filename': fileName,
              }
            : {'url': url, 'filename': fileName};

        await _dio.download(
          proxyUrl,
          filePath,
          queryParameters: queryParams,
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

        // Save to device gallery for mobile platforms
        if (Platform.isAndroid || Platform.isIOS) {
          try {
            final ext = path.extension(fileName).toLowerCase();

            // Read file as bytes
            final bytes = await File(filePath).readAsBytes();

            // Check file type and save to appropriate gallery
            if ([
              '.mp4',
              '.mov',
              '.avi',
              '.mkv',
              '.webm',
              '.flv',
              '.wmv',
            ].contains(ext)) {
              // Save video to gallery
              final result = await ImageGallerySaver.saveFile(
                filePath,
                name: path.basenameWithoutExtension(fileName),
                isReturnPathOfIOS: true,
              );
              debugPrint('✓ Video saved to gallery: $result');
            } else if ([
              '.jpg',
              '.jpeg',
              '.png',
              '.gif',
              '.webp',
              '.bmp',
            ].contains(ext)) {
              // Save image to gallery
              final result = await ImageGallerySaver.saveImage(
                bytes,
                name: path.basenameWithoutExtension(fileName),
              );
              debugPrint('✓ Image saved to gallery: $result');
            }
          } catch (e) {
            // Don't fail the download if gallery save fails
            debugPrint('Gallery save error (file still downloaded): $e');
          }
        }

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
