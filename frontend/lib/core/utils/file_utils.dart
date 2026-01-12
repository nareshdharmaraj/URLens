import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../constants/storage_constants.dart';

/// File utility functions
class FileUtils {
  /// Get downloads directory based on platform
  static Future<Directory> getDownloadsDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: use app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(
        path.join(directory.path, StorageConstants.appFolderName),
      );

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      return downloadsDir;
    } else {
      // Desktop: use system downloads folder
      final directory = await getDownloadsDirectory();
      final urlensDir = Directory(
        path.join(directory.path, StorageConstants.appFolderName),
      );

      if (!await urlensDir.exists()) {
        await urlensDir.create(recursive: true);
      }

      return urlensDir;
    }
  }

  /// Get file extension from filename
  static String getFileExtension(String filename) {
    return path.extension(filename).toLowerCase().replaceAll('.', '');
  }

  /// Check if file is a video
  static bool isVideo(String filename) {
    final ext = getFileExtension(filename);
    return StorageConstants.videoExtensions.contains(ext);
  }

  /// Check if file is an audio file
  static bool isAudio(String filename) {
    final ext = getFileExtension(filename);
    return StorageConstants.audioExtensions.contains(ext);
  }

  /// Check if file is an image
  static bool isImage(String filename) {
    final ext = getFileExtension(filename);
    return StorageConstants.imageExtensions.contains(ext);
  }

  /// Generate unique filename
  static String generateUniqueFilename(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = path.extension(originalName);
    final nameWithoutExt = path.basenameWithoutExtension(originalName);
    return '${nameWithoutExt}_$timestamp$ext';
  }

  /// Delete file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// Get file size
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }
}
