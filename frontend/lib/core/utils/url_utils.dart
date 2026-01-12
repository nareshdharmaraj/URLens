import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class UrlUtils {
  /// Returns a proxied URL if running on web to avoid CORS issues
  static String getProxiedUrl(String url) {
    if (kIsWeb && url.isNotEmpty) {
      final baseUrl = ApiConstants.baseUrl;
      final apiVersion = ApiConstants.apiVersion;
      return '$baseUrl/api/$apiVersion/proxy?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }
}
