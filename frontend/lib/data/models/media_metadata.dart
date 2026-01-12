/// Media metadata model
class MediaMetadata {
  final String platform;
  final String title;
  final String? thumbnailUrl;

  MediaMetadata({
    required this.platform,
    required this.title,
    this.thumbnailUrl,
  });

  factory MediaMetadata.fromJson(Map<String, dynamic> json) {
    return MediaMetadata(
      platform: json['platform'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'title': title,
      'thumbnail_url': thumbnailUrl,
    };
  }
}
