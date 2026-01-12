import '../data_sources/remote/api_service.dart';
import '../models/media_metadata.dart';
import '../models/download_option.dart';
import '../../core/constants/api_constants.dart';

/// Repository for media-related operations
class MediaRepository {
  final ApiService _apiService;

  MediaRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Analyze URL and get metadata
  Future<MediaMetadata> analyzeUrl(String url) async {
    try {
      final response = await _apiService.post(ApiConstants.analyzeEndpoint, {
        'url': url,
      });

      return MediaMetadata.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to analyze URL: ${e.toString()}');
    }
  }

  /// Get download options for URL
  Future<List<DownloadOption>> getDownloadOptions(String url) async {
    try {
      final response = await _apiService.post(
        ApiConstants.downloadInfoEndpoint,
        {'url': url},
      );

      final List<dynamic> optionsJson = response.data['download_options'];
      return optionsJson.map((json) => DownloadOption.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get download options: ${e.toString()}');
    }
  }
}
