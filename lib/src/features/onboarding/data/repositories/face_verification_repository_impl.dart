import 'package:dio/dio.dart';
import '../../domain/repositories/face_verification_repository.dart';

/// Real HTTP implementation calling POST /api/onboarding/face-liveness/session
/// and POST /api/onboarding/verify-face per docs/04-face-verification-approach.md.
///
/// INTENTIONAL BEHAVIOR NOTE:
/// The Dart backend server does not exist in this phase.
/// Calling createLivenessSession or verifyFace will throw/fail with an HTTP error
/// at runtime until the backend API is deployed. This is expected and correct;
/// do not add a mock fallback.
class FaceVerificationRepositoryImpl implements FaceVerificationRepository {
  final Dio _dio;

  FaceVerificationRepositoryImpl({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'http://localhost:5000',
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  @override
  Future<String> createLivenessSession() async {
    final response = await _dio.post('/api/onboarding/face-liveness/session');
    return response.data['sessionId'] as String;
  }

  @override
  Future<bool> verifyFace({required String sessionId}) async {
    final response = await _dio.post(
      '/api/onboarding/verify-face',
      data: {'sessionId': sessionId},
    );
    return response.data['isLive'] == true;
  }
}
