import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyUseLocalBackend = 'use_local_backend';

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _useLocalBackend = true; // Default to local

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get useLocalBackend => _useLocalBackend;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Theme
    final themeIndex = prefs.getInt(keyThemeMode);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    // Load Notifications
    _notificationsEnabled = prefs.getBool(keyNotifications) ?? true;

    // Load Backend preference (default to local)
    _useLocalBackend = prefs.getBool(keyUseLocalBackend) ?? true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyThemeMode, mode.index);
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotifications, value);
  }

  Future<void> toggleBackend(bool useLocal) async {
    _useLocalBackend = useLocal;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyUseLocalBackend, useLocal);
  }

  String getBackendUrl() {
    return _useLocalBackend
        ? 'http://localhost:8000'
        : 'https://urlens.onrender.com';
  }
}
