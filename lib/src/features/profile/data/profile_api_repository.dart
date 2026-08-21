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
    // -------------------------------------------------------------------------
    // TEMPORARY LOCAL TESTING STUB: Remove before final production / final push
    // -------------------------------------------------------------------------
    if (sessionToken.startsWith('test_token_')) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'id': 'test-user-id',
        'phoneNumber': '+918888888888',
        'fullName': 'Raghav',
        'instagramUsername': 'raghav',
        'bio': 'Building events, nights out, and better connections.',
        'location': 'New York, NY',
        'gender': 'Male',
        'heightCm': 178,
        'status': 'active',
        'isVerified': true,
        'photos': [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80',
          'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=900&q=80',
        ],
      };
    }

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
    // -------------------------------------------------------------------------
    // TEMPORARY LOCAL TESTING STUB: Remove before final production / final push
    // -------------------------------------------------------------------------
    if (sessionToken.startsWith('test_token_')) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'id': 'test-new-user-id',
        'phoneNumber': payload['phoneNumber'] ?? '+919999999999',
        'fullName': payload['fullName'] ?? 'New Member',
        'dob': payload['dob'] ?? '2000-01-01',
        'gender': payload['gender'] ?? 'Female',
        'heightCm': payload['heightCm'] ?? 170,
        'location': payload['location'] ?? 'New York, NY',
        'instagramUsername': payload['instagramUsername'] ?? 'newuser',
        'photos': payload['photos'] ?? <String>[],
        'status': 'active',
        'isVerified': false,
      };
    }

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
