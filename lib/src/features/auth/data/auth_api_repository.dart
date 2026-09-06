import 'package:dio/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

class AuthSessionResult {
  final String sessionToken;
  final Map<String, dynamic> user;

  const AuthSessionResult({
    required this.sessionToken,
    required this.user,
  });
}

class AuthApiRepository {
  final Dio _dio;

  AuthApiRepository(this._dio);



  Future<void> sendOtp({required String phoneNumber}) async {


    await _dio.post(
      '/api/auth/send-otp',
      data: {'phoneNumber': phoneNumber},
    );
  }

  Future<AuthSessionResult> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {


    final response = await _dio.post(
      '/api/auth/verify-otp',
      data: {
        'phoneNumber': phoneNumber,
        'code': code,
      },
    );

    return AuthSessionResult(
      sessionToken: response.data['sessionToken'] as String,
      user: Map<String, dynamic>.from(response.data['user'] as Map),
    );
  }
}

final authApiRepositoryProvider = Provider<AuthApiRepository>((ref) {
  return AuthApiRepository(ref.watch(dioProvider));
});
