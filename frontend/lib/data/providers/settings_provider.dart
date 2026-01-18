import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/file_utils.dart';

class SettingsProvider with ChangeNotifier {
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyUseLocalBackend = 'use_local_backend';
  static const String keyDefaultQuality = 'default_quality';
  static const String keyAutoMergeStreams = 'auto_merge_streams';
  static const String keyDownloadPath = 'download_path';

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _useLocalBackend = true; // Default to local
  String _defaultQuality = 'Best Available';
  bool _autoMergeStreams = true;
  String _downloadPath = '/storage/emulated/0/URLens';

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get useLocalBackend => _useLocalBackend;
  String get defaultQuality => _defaultQuality;
  bool get autoMergeStreams => _autoMergeStreams;
  String get downloadPath => _downloadPath;

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

    // Load Download settings
    _defaultQuality = prefs.getString(keyDefaultQuality) ?? 'Best Available';
    _autoMergeStreams = prefs.getBool(keyAutoMergeStreams) ?? true;
    
    String? savedPath = prefs.getString(keyDownloadPath);
    if (savedPath == null) {
      try {
        final dir = await FileUtils.getDownloadsDirectory();
        _downloadPath = dir.path;
      } catch (e) {
        // Fallback for Android if FileUtils fails or we are in a weird state
        _downloadPath = '/storage/emulated/0/URLens';
      }
    } else {
      _downloadPath = savedPath;
    }

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
    
    // Update ApiConstants immediately so changes take effect
    ApiConstants.baseUrl = useLocal
        ? 'http://localhost:8000'
        : 'https://urlens.onrender.com';
        
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyUseLocalBackend, useLocal);
  }

  Future<void> setDefaultQuality(String quality) async {
    _defaultQuality = quality;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyDefaultQuality, quality);
  }

  Future<void> setAutoMergeStreams(bool value) async {
    _autoMergeStreams = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyAutoMergeStreams, value);
  }

  Future<void> setDownloadPath(String path) async {
    _downloadPath = path;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyDownloadPath, path);
  }

  String getBackendUrl() {
    return _useLocalBackend
        ? 'http://localhost:8000'
        : 'https://urlens.onrender.com';
  }
}
