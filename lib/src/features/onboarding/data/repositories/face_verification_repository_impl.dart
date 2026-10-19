import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../domain/repositories/face_verification_repository.dart';

class FaceVerificationApiException implements Exception {
  final String message;

  const FaceVerificationApiException(this.message);

  @override
  String toString() => message;
}

/// Real HTTP implementation calling POST /api/onboarding/face-liveness/session
/// and POST /api/onboarding/verify-face per docs/04-face-verification-approach.md.
///
class FaceVerificationRepositoryImpl implements FaceVerificationRepository {
  final Dio _dio;

  FaceVerificationRepositoryImpl({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );

  @override
  Future<String> createLivenessSession({required String sessionToken}) async {
    try {
      final response = await _dio.post(
        '/api/onboarding/face-liveness/session',
        options: _authorizedOptions(sessionToken),
      );
      return response.data['sessionId'] as String;
    } on DioException catch (error) {
      throw FaceVerificationApiException(_messageFrom(error));
    }
  }

  @override
  Future<FaceVerificationOutcome> verifyFace({
    required String sessionId,
    required String sessionToken,
  }) async {
    try {
      final response = await _dio.post(
        '/api/onboarding/verify-face',
        data: {'sessionId': sessionId},
        options: _authorizedOptions(sessionToken),
      );
      return FaceVerificationOutcome(
        isLive: response.data['isLive'] == true,
        message: response.data['message']?.toString() ?? '',
      );
    } on DioException catch (error) {
      throw FaceVerificationApiException(_messageFrom(error));
    }
  }

  Options _authorizedOptions(String sessionToken) {
    return Options(headers: {'Authorization': 'Bearer $sessionToken'});
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      final message = (data['message'] as String).trim();
      if (message.isNotEmpty) return message;
    }
    return 'Face verification is currently unavailable. Please try again later.';
  }
}
