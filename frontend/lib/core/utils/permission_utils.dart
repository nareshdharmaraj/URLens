import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

/// Permission utility functions
class PermissionUtils {
  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true; // Web doesn't need storage permissions
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need specific permissions
      if (await _isAndroid13OrHigher()) {
        final statuses = await [Permission.photos, Permission.videos].request();

        return statuses.values.every((status) => status.isGranted);
      } else {
        // For older Android versions
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }

    // Desktop platforms don't need storage permissions
    return true;
  }

  /// Check if storage permission is granted
  static Future<bool> isStoragePermissionGranted() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        return await Permission.photos.isGranted &&
            await Permission.videos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }

    return true;
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Check if running on Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      try {
        // Use device_info_plus to get actual Android version
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        return deviceInfo.version.sdkInt >= 33; // Android 13 is API 33
      } catch (e) {
        // Fallback: assume modern Android
        return true;
      }
    }
    return false;
  }
}
