import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _keyFirstLaunch = 'is_first_launch';

  /// Check if this is the first time the app is launched.
  /// Returns true if it is, and effectively sets the flag to false for future checks.
  static Future<bool> checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(_keyFirstLaunch) ?? true;

    if (isFirstLaunch) {
      await prefs.setBool(_keyFirstLaunch, false);
    }

    return isFirstLaunch;
  }
}
