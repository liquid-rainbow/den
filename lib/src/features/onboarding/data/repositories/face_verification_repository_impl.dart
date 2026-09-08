import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/face_verification_repository.dart';

class FaceVerificationRepositoryImpl implements FaceVerificationRepository {
  final Dio _dio;

  FaceVerificationRepositoryImpl(this._dio);

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

final faceVerificationRepositoryProvider = Provider<FaceVerificationRepositoryImpl>((ref) {
  return FaceVerificationRepositoryImpl(ref.watch(dioProvider));
});
