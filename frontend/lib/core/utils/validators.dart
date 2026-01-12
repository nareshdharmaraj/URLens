/// URL Validator utility
class Validators {
  /// Validate URL format
  static bool isValidUrl(String url) {
    if (url.trim().isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get URL validation error message
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a URL';
    }

    if (!isValidUrl(value)) {
      return 'Please enter a valid URL (http:// or https://)';
    }

    return null;
  }

  /// Validate if URL is from supported platform
  static bool isSupportedPlatform(String url) {
    final lowerUrl = url.toLowerCase();

    final supportedDomains = [
      'youtube.com',
      'youtu.be',
      'instagram.com',
      'twitter.com',
      'x.com',
      'facebook.com',
      'fb.watch',
      'tiktok.com',
      'vimeo.com',
      'dailymotion.com',
      'twitch.tv',
    ];

    return supportedDomains.any((domain) => lowerUrl.contains(domain));
  }
}
