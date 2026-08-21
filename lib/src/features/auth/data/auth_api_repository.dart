import 'package:dio/dio.dart';

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

  AuthApiRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'http://localhost:5000',
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  Future<void> sendOtp({required String phoneNumber}) async {
    // -------------------------------------------------------------------------
    // TEMPORARY LOCAL TESTING STUB: Remove before final production / final push
    // 9999999999 -> New User Flow
    // 8888888888 -> Existing User Profile Flow
    // -------------------------------------------------------------------------
    if (phoneNumber.contains('9999999999') || phoneNumber.contains('8888888888')) {
      await Future.delayed(const Duration(milliseconds: 400));
      return;
    }

    await _dio.post(
      '/api/auth/send-otp',
      data: {'phoneNumber': phoneNumber},
    );
  }

  Future<AuthSessionResult> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    // -------------------------------------------------------------------------
    // TEMPORARY LOCAL TESTING STUB: Remove before final production / final push
    // 9999999999 with OTP 123456 -> New User (leads to onboarding flow)
    // 8888888888 with OTP 123456 -> Existing User (leads to profile page)
    // -------------------------------------------------------------------------
    if (phoneNumber.contains('9999999999')) {
      if (code == '123456') {
        await Future.delayed(const Duration(milliseconds: 400));
        return AuthSessionResult(
          sessionToken: 'test_token_new_user_999',
          user: {
            'id': 'test-new-user-id',
            'phoneNumber': phoneNumber,
            'fullName': '',
            'instagramUsername': '',
            'location': '',
            'gender': '',
            'heightCm': 170,
            'status': 'pending_verification',
            'isVerified': false,
            'photos': <String>[],
          },
        );
      } else {
        throw Exception('Invalid or expired verification code.');
      }
    }

    if (phoneNumber.contains('8888888888')) {
      if (code == '123456') {
        await Future.delayed(const Duration(milliseconds: 400));
        return AuthSessionResult(
          sessionToken: 'test_token_existing_user_888',
          user: {
            'id': 'test-existing-user-id',
            'phoneNumber': phoneNumber,
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
          },
        );
      } else {
        throw Exception('Invalid or expired verification code.');
      }
    }

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
