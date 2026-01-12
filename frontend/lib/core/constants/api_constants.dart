/// API Constants for URLens
class ApiConstants {
  // Will be loaded from .env file
  static String baseUrl = '';

  // API Version
  static const String apiVersion = 'v1';

  // Endpoints
  static String get analyzeEndpoint => '$baseUrl/api/$apiVersion/analyze';
  static String get downloadInfoEndpoint =>
      '$baseUrl/api/$apiVersion/download-info';
  static String get proxyDownloadEndpoint =>
      '$baseUrl/api/$apiVersion/proxy-download';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
