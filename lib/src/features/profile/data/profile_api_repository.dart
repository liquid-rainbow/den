import 'package:dio/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

class ProfileApiRepository {
  final Dio _dio;

  ProfileApiRepository(this._dio);

  Options _options(String sessionToken) {
    return Options(headers: {'Authorization': 'Bearer $sessionToken'});
  }

  Future<Map<String, dynamic>> fetchMe(String sessionToken) async {
    final response = await _dio.get('/api/users/me', options: _options(sessionToken));
    return response.data;
  }

  Future<Map<String, dynamic>> updateUsername(String sessionToken, String newUsername) async {
    final response = await _dio.put(
      '/api/users/me/username',
      data: {'username': newUsername},
      options: _options(sessionToken),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> fetchPublicProfile(String username, {String? viewerSessionToken}) async {
    final response = await _dio.get(
      '/api/users/$username',
      options: viewerSessionToken != null ? _options(viewerSessionToken) : null,
    );
    return response.data;
  }

  Future<void> followUser(String sessionToken, String targetUserId) async {
    await _dio.post(
      '/api/users/follow',
      data: {'targetUserId': targetUserId},
      options: _options(sessionToken),
    );
  }

  Future<void> unfollowUser(String sessionToken, String targetUserId) async {
    await _dio.post(
      '/api/users/unfollow',
      data: {'targetUserId': targetUserId},
      options: _options(sessionToken),
    );
  }

  Future<void> updateFaceVerificationStatus(String sessionToken, bool enabled) async {
    await _dio.post('/api/users/me/face-verification-status', data: {'enabled': enabled}, options: _options(sessionToken));
  }

  Future<Map<String, dynamic>> completeOnboarding({required String sessionToken, required Map<String, dynamic> payload}) async {
    final response = await _dio.post(
      '/api/users/me/complete-onboarding',
      data: payload,
      options: _options(sessionToken),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile({required String sessionToken, required Map<String, dynamic> payload}) async {
    final response = await _dio.put(
      '/api/users/me',
      data: payload,
      options: _options(sessionToken),
    );
    return response.data;
  }
}

final profileApiRepositoryProvider = Provider<ProfileApiRepository>((ref) {
  return ProfileApiRepository(ref.watch(dioProvider));
});
