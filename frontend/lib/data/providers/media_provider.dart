import 'package:flutter/foundation.dart';
import '../models/media_metadata.dart';
import '../models/download_option.dart';
import '../repositories/media_repository.dart';

/// Provider for media analysis and download options
class MediaProvider with ChangeNotifier {
  final MediaRepository _repository;

  MediaProvider({MediaRepository? repository})
    : _repository = repository ?? MediaRepository();

  // State variables
  bool _isAnalyzing = false;
  bool _isFetchingOptions = false;
  MediaMetadata? _currentMetadata;
  List<DownloadOption>? _downloadOptions;
  String? _error;
  String? _currentUrl;

  // Getters
  bool get isAnalyzing => _isAnalyzing;
  bool get isFetchingOptions => _isFetchingOptions;
  MediaMetadata? get currentMetadata => _currentMetadata;
  List<DownloadOption>? get downloadOptions => _downloadOptions;
  String? get error => _error;
  String? get currentUrl => _currentUrl;
  bool get hasMetadata => _currentMetadata != null;
  bool get hasOptions =>
      _downloadOptions != null && _downloadOptions!.isNotEmpty;

  /// Analyze URL
  Future<void> analyzeUrl(String url) async {
    _isAnalyzing = true;
    _error = null;
    _currentUrl = url;
    _currentMetadata = null;
    _downloadOptions = null;
    notifyListeners();

    try {
      _currentMetadata = await _repository.analyzeUrl(url);
      _error = null;
    } catch (e) {
      _error = _parseErrorMessage(e.toString());
      _currentMetadata = null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Get download options
  Future<void> fetchDownloadOptions(String url) async {
    _isFetchingOptions = true;
    _error = null;
    notifyListeners();

    try {
      _downloadOptions = await _repository.getDownloadOptions(url);
      _error = null;
    } catch (e) {
      _error = _parseErrorMessage(e.toString());
      _downloadOptions = null;
    } finally {
      _isFetchingOptions = false;
      notifyListeners();
    }
  }

  /// Parse error message to show user-friendly text
  String _parseErrorMessage(String error) {
    final errorLower = error.toLowerCase();

    // YouTube bot detection
    if (errorLower.contains('sign in') ||
        errorLower.contains('bot') ||
        errorLower.contains('cookies')) {
      return 'YouTube requires authentication. Please make sure you are signed into YouTube in your Chrome, Firefox, or Edge browser, then restart the backend server.';
    }

    // Private/unavailable content
    if (errorLower.contains('private') ||
        errorLower.contains('not available')) {
      return 'This content is private or unavailable. Please check the URL and try again.';
    }

    // Geo-restricted
    if (errorLower.contains('geo') || errorLower.contains('restricted')) {
      return 'This content is not available in your region.';
    }

    // Network errors
    if (errorLower.contains('network') ||
        errorLower.contains('connection') ||
        errorLower.contains('timeout')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    // Unsupported platform
    if (errorLower.contains('unsupported')) {
      return 'This platform is not supported. Please try a different URL.';
    }

    // Generic error - clean up the message
    String cleanError = error
        .replaceAll('Exception:', '')
        .replaceAll('Failed to analyze URL:', '')
        .replaceAll('Failed to get download options:', '')
        .replaceAll('Error processing URL:', '')
        .trim();

    // If error is too long, show first part
    if (cleanError.length > 200) {
      cleanError = '${cleanError.substring(0, 200)}...';
    }

    return cleanError.isNotEmpty
        ? cleanError
        : 'An unexpected error occurred. Please try again.';
  }

  /// Clear current state
  void clear() {
    _currentMetadata = null;
    _downloadOptions = null;
    _error = null;
    _currentUrl = null;
    _isAnalyzing = false;
    _isFetchingOptions = false;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
