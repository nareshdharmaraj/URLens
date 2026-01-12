import 'package:flutter/foundation.dart';
import '../models/download_record.dart';
import '../repositories/download_repository.dart';

/// Provider for download history
class HistoryProvider with ChangeNotifier {
  final DownloadRepository _repository;

  HistoryProvider({DownloadRepository? repository})
    : _repository = repository ?? DownloadRepository();

  // State variables
  List<DownloadRecord> _downloads = [];
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  String? _platformFilter;

  // Getters
  List<DownloadRecord> get downloads => List.unmodifiable(_downloads);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  String? get platformFilter => _platformFilter;
  bool get hasDownloads => _downloads.isNotEmpty;
  int get downloadCount => _downloads.length;

  /// Load all downloads
  Future<void> loadDownloads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _downloads = await _repository.getAllDownloads();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _downloads = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search downloads
  Future<void> searchDownloads(String query) async {
    _searchQuery = query;
    _platformFilter = null;

    if (query.trim().isEmpty) {
      await loadDownloads();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _downloads = await _repository.searchDownloads(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _downloads = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by platform
  Future<void> filterByPlatform(String? platform) async {
    _platformFilter = platform;
    _searchQuery = null;

    if (platform == null) {
      await loadDownloads();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _downloads = await _repository.getDownloadsByPlatform(platform);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _downloads = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete download
  Future<bool> deleteDownload(int id) async {
    try {
      final success = await _repository.deleteDownload(id);
      if (success) {
        _downloads.removeWhere((record) => record.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear all downloads
  Future<void> clearAll() async {
    try {
      await _repository.clearAllDownloads();
      _downloads = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Refresh downloads
  Future<void> refresh() async {
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      await searchDownloads(_searchQuery!);
    } else if (_platformFilter != null) {
      await filterByPlatform(_platformFilter);
    } else {
      await loadDownloads();
    }
  }

  /// Clear filters
  Future<void> clearFilters() async {
    _searchQuery = null;
    _platformFilter = null;
    await loadDownloads();
  }

  /// Get download by ID
  Future<DownloadRecord?> getDownloadById(int id) async {
    return await _repository.getDownloadById(id);
  }
}
