/// Storage-related constants
class StorageConstants {
  // Folder names
  static const String appFolderName = 'URLens';
  static const String downloadsFolderName = 'Downloads';
  static const String videosFolderName = 'Videos';
  static const String imagesFolderName = 'Images';

  // File extensions
  static const List<String> videoExtensions = [
    'mp4',
    'webm',
    'mkv',
    'avi',
    'mov',
  ];
  static const List<String> audioExtensions = [
    'mp3',
    'm4a',
    'aac',
    'wav',
    'ogg',
  ];
  static const List<String> imageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  // Permissions
  static const String storagePermissionRationale =
      'URLens needs storage permission to save downloaded media files to your device.';
}
