/// Download record model for local database
class DownloadRecord {
  final int? id;
  final String originalUrl;
  final String title;
  final String? thumbnailUrl;
  final String? platform;
  final String localFilePath;
  final int? fileSize;
  final DateTime downloadDate;

  DownloadRecord({
    this.id,
    required this.originalUrl,
    required this.title,
    this.thumbnailUrl,
    this.platform,
    required this.localFilePath,
    this.fileSize,
    required this.downloadDate,
  });

  // Convert from database map
  factory DownloadRecord.fromMap(Map<String, dynamic> map) {
    return DownloadRecord(
      id: map['id'] as int?,
      originalUrl: map['original_url'] as String,
      title: map['title'] as String,
      thumbnailUrl: map['thumbnail_url'] as String?,
      platform: map['platform'] as String?,
      localFilePath: map['local_file_path'] as String,
      fileSize: map['file_size'] as int?,
      downloadDate: DateTime.parse(map['download_date'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'original_url': originalUrl,
      'title': title,
      'thumbnail_url': thumbnailUrl,
      'platform': platform,
      'local_file_path': localFilePath,
      'file_size': fileSize,
      'download_date': downloadDate.toIso8601String(),
    };
  }

  // Copy with method for updates
  DownloadRecord copyWith({
    int? id,
    String? originalUrl,
    String? title,
    String? thumbnailUrl,
    String? platform,
    String? localFilePath,
    int? fileSize,
    DateTime? downloadDate,
  }) {
    return DownloadRecord(
      id: id ?? this.id,
      originalUrl: originalUrl ?? this.originalUrl,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      platform: platform ?? this.platform,
      localFilePath: localFilePath ?? this.localFilePath,
      fileSize: fileSize ?? this.fileSize,
      downloadDate: downloadDate ?? this.downloadDate,
    );
  }
}
