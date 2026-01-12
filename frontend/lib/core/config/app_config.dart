import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'db_init/db_init.dart';

/// Application configuration
class AppConfig {
  static Future<void> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Initialize database (Platform specific)
    initializeDatabase();

    // Load backend URL preference from settings
    final prefs = await SharedPreferences.getInstance();
    final useLocal = prefs.getBool('use_local_backend') ?? true;

    ApiConstants.baseUrl = useLocal
        ? 'http://localhost:8000'
        : 'https://urlens.onrender.com';
  }

  static bool get isProduction => !ApiConstants.baseUrl.contains('localhost');
}
