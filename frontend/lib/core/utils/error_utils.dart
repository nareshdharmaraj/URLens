import 'package:dio/dio.dart';

class ErrorUtils {
  /// Maps raw error/exception to a professional user-friendly message
  static String getFriendlyErrorMessage(dynamic error) {
    String errorMsg = error.toString().toLowerCase();

    // 1. Network / Connection Errors
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.badResponse:
           if (error.response?.statusCode == 404) {
             return 'Resource not found. The link might be expired or invalid.';
           }
          return 'Server temporarily unavailable. Please try again later.';
        case DioExceptionType.cancel:
          return 'Operation cancelled.';
        case DioExceptionType.connectionError:
          return 'No internet connection detected.';
        default:
          return 'Network error occurred. Please try again.';
      }
    }
    
    // 2. Specific Backend/Platform Logic
    if (errorMsg.contains('sign in') || errorMsg.contains('bot') || errorMsg.contains('cookies')) {
      return 'Authentication required. This content is age-restricted or requires a login.';
    }

    if (errorMsg.contains('private') || errorMsg.contains('not available')) {
      return 'Content unavailable. It might be private or deleted.';
    }

    if (errorMsg.contains('geo') || errorMsg.contains('restricted')) {
      return 'Content is not available in your region.';
    }

    if (errorMsg.contains('drm') || errorMsg.contains('protected')) {
      return 'This content is protected and cannot be downloaded due to copyright restrictions.';
    }

    if (errorMsg.contains('live') && errorMsg.contains('stream')) {
       return 'Live streams cannot be downloaded while live.';
    }

    // 3. Storage / FileSystem
    if (errorMsg.contains('no space')) {
      return 'Device storage is full. Please free up space and try again.';
    }
    
    if (errorMsg.contains('permission')) {
      return 'Storage permission denied. Please enable permissions in settings.';
    }

    // 4. Default Fail-Safe using generic messages
    if (errorMsg.contains('format') || errorMsg.contains('unsupported')) {
      return 'Unsupported media format or URL.';
    }

    // Catch-all for very long technical errors -> Simplification
    if (error.toString().length > 100) {
      return 'Something went wrong. Please check the URL and try again.';
    }

    // Return as-is if short enough, otherwise default
    return error.toString().isNotEmpty ? error.toString() : 'An unexpected error occurred.';
  }
}
