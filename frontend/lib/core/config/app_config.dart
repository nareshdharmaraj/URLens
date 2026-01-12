import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';

/// Application configuration
class AppConfig {
  static Future<void> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Set API base URL from environment
    ApiConstants.baseUrl =
        dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  }

  static bool get isProduction => !ApiConstants.baseUrl.contains('localhost');
}
