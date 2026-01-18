import 'package:flutter/foundation.dart';
import '../../core/utils/error_utils.dart';
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
  String _parseErrorMessage(dynamic error) {
    return ErrorUtils.getFriendlyErrorMessage(error);
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
