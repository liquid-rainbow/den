import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';

class ProfileApiException implements Exception {
  final String message;

  const ProfileApiException(this.message);

  @override
  String toString() => message;
}

class ProfileApiRepository {
  final Dio _dio;

  ProfileApiRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );

  Options _options(String sessionToken) {
    return Options(headers: {'Authorization': 'Bearer $sessionToken'});
  }

  Future<Map<String, dynamic>> fetchMe(String sessionToken) async {
    final response = await _dio.get(
      '/api/users/me',
      options: _options(sessionToken),
    );
    return Map<String, dynamic>.from(response.data['user'] as Map);
  }

  Future<Map<String, dynamic>> fetchPublicProfile(String username) async {
    final response = await _dio.get('/api/users/by-username/$username');
    return Map<String, dynamic>.from(response.data['user'] as Map);
  }

  Future<Map<String, dynamic>> completeOnboarding({
    required String sessionToken,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        '/api/users/onboarding',
        data: payload,
        options: _options(sessionToken),
      );
      return Map<String, dynamic>.from(response.data['user'] as Map);
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        final message = (data['message'] as String).trim();
        if (message.isNotEmpty) throw ProfileApiException(message);
      }
      throw const ProfileApiException(
        'Failed to complete profile setup. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String sessionToken,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.patch(
      '/api/users/me',
      data: payload,
      options: _options(sessionToken),
    );
    return Map<String, dynamic>.from(response.data['user'] as Map);
  }
}
