import 'package:dio/dio.dart';

class ProfileApiRepository {
  final Dio _dio;

  ProfileApiRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'http://localhost:5000',
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


    final response = await _dio.post(
      '/api/users/onboarding',
      data: payload,
      options: _options(sessionToken),
    );
    return Map<String, dynamic>.from(response.data['user'] as Map);
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
