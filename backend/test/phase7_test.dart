import 'dart:convert';
import 'package:den_backend/config/database.dart';
import 'package:den_backend/config/env.dart';
import 'package:den_backend/middleware/security_headers.dart';
import 'package:den_backend/modules/auth/auth_controller.dart';
import 'package:den_backend/modules/auth/auth_service.dart';
import 'package:den_backend/modules/biometric/biometric_controller.dart';
import 'package:den_backend/modules/biometric/biometric_service.dart';
import 'package:den_backend/modules/upload/upload_controller.dart';
import 'package:den_backend/modules/upload/upload_service.dart';
import 'package:den_backend/modules/user/user_controller.dart';
import 'package:den_backend/modules/user/user_service.dart';
import 'package:den_backend/shared/aws/face_verification_service.dart';
import 'package:den_backend/shared/aws/photo_storage.dart';
import 'package:den_backend/shared/aws/sms_sender.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

class CapturingSmsSender implements SmsSender {
  final Map<String, String> _lastCodes = {};

  @override
  Future<void> sendOtp(String phoneNumber, String code) async {
    _lastCodes[phoneNumber] = code;
  }

  String? getCode(String phoneNumber) => _lastCodes[phoneNumber];
}

void main() {
  late CapturingSmsSender smsSender;
  late PhotoStorage photoStorage;
  late FaceVerificationService faceVerificationService;

  late AuthService authService;
  late UploadService uploadService;
  late BiometricService biometricService;
  late UserService userService;

  late Handler appHandler;

  setUpAll(() async {
    Env.load();
    await Database.initialize();

    smsSender = CapturingSmsSender();
    photoStorage = LocalPhotoStorage();
    faceVerificationService = StubFaceVerificationService();

    authService = AuthService(smsSender: smsSender);
    uploadService = UploadService(photoStorage: photoStorage);
    biometricService = BiometricService(faceVerificationService: faceVerificationService);
    userService = UserService();

    final authController = AuthController(authService: authService);
    final uploadController = UploadController(uploadService: uploadService);
    final biometricController = BiometricController(biometricService: biometricService);
    final userController = UserController(userService: userService);

    final router = Router();
    router.mount('/api/auth', authController.router.call);
    router.mount('/api/uploads', uploadController.router.call);
    router.mount('/api/onboarding', biometricController.router.call);
    router.mount('/api/users', userController.router.call);

    final pipeline = const Pipeline().addMiddleware(securityHeadersMiddleware()).addHandler(router.call);
    appHandler = pipeline;
  });

  tearDownAll(() async {
    await Database.close();
  });

  Future<Map<String, String>> getAuthDetails(String phoneNumber) async {
    final sendRes = await authService.sendOtp(phoneNumber);
    if (!sendRes.success) {
      throw StateError('Failed to send OTP to $phoneNumber: ${sendRes.message}');
    }
    final code = smsSender.getCode(phoneNumber);
    if (code == null) {
      throw StateError('No captured OTP code found for $phoneNumber');
    }
    final verifyRes = await authService.verifyOtp(phoneNumber, code);
    return {
      'token': verifyRes.sessionToken!,
      'userId': verifyRes.user!['id'] as String,
    };
  }

  Future<void> cleanupUser(String phoneNumber) async {
    final pool = Database.pool;
    await pool.execute('DELETE FROM users WHERE phone_number = \$1', parameters: [phoneNumber]);
    await pool.execute('DELETE FROM auth_otps WHERE phone_number = \$1', parameters: [phoneNumber]);
  }

  group('Phase 7: Profile Onboarding & User Profile Endpoints (/api/users/...)', () {
    final testPhone = '+919876570001';
    late String validToken;
    late String userId;

    setUp(() async {
      final authDetails = await getAuthDetails(testPhone);
      validToken = authDetails['token']!;
      userId = authDetails['userId']!;
    });

    tearDown(() async {
      await cleanupUser(testPhone);
    });

    test('Valid onboarding submission succeeds and updates status to active, GET /api/users/me returns full profile', () async {
      // 1. Get presigned upload URL for photo (creates legitimate user_photos DB row)
      final uploadReq = Request(
        'POST',
        Uri.parse('http://localhost/api/uploads/photo-url'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({'contentType': 'image/jpeg'}),
      );
      final uploadRes = await appHandler(uploadReq);
      final uploadBody = jsonDecode(await uploadRes.readAsString()) as Map<String, dynamic>;
      final publicUrl = uploadBody['publicUrl'] as String;

      // 2. Submit onboarding profile data
      final onboardingReq = Request(
        'POST',
        Uri.parse('http://localhost/api/users/onboarding'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({
          'phoneNumber': testPhone,
          'fullName': 'Aarav Mehta',
          'dob': '2001-05-15',
          'gender': 'Male',
          'heightCm': 178,
          'location': 'Mumbai',
          'instagramUsername': 'aarav_m',
          'photos': [publicUrl],
        }),
      );

      final onboardingRes = await appHandler(onboardingReq);
      expect(onboardingRes.statusCode, equals(201));

      final onboardingBody = jsonDecode(await onboardingRes.readAsString()) as Map<String, dynamic>;
      expect(onboardingBody['success'], isTrue);
      expect(onboardingBody['user'], isNotNull);

      final user = onboardingBody['user'] as Map<String, dynamic>;
      expect(user['fullName'], equals('Aarav Mehta'));
      expect(user['status'], equals('active'));
      expect((user['photos'] as List).length, equals(1));

      // 3. Verify GET /api/users/me returns identical updated active profile & security headers
      final meReq = Request(
        'GET',
        Uri.parse('http://localhost/api/users/me'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
      );

      final meRes = await appHandler(meReq);
      expect(meRes.statusCode, equals(200));

      final meBody = jsonDecode(await meRes.readAsString()) as Map<String, dynamic>;
      expect(meBody['success'], isTrue);
      expect(meBody['user']['status'], equals('active'));
      expect(meBody['user']['fullName'], equals('Aarav Mehta'));

      // Verify CORS and OWASP Security Headers
      expect(meRes.headers['x-content-type-options'], equals('nosniff'));
      expect(meRes.headers['x-frame-options'], equals('DENY'));
      expect(meRes.headers['access-control-allow-origin'], isNotNull);
      expect(meRes.headers['access-control-allow-origin'], isNot(equals('*')));
    });

    test('Fabricated objectKey matching own user-ID prefix but not in database is rejected with 400 (DB-backed IDOR check)', () async {
      final fakeKeyWithOwnPrefix = 'users/$userId/photos/fabricated_nonexistent_photo.jpg';

      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/users/onboarding'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({
          'phoneNumber': testPhone,
          'fullName': 'Fabrication Attacker',
          'dob': '2000-01-01',
          'gender': 'Male',
          'heightCm': 175,
          'location': 'Mumbai',
          'photos': ['https://cdn.denapp.com/$fakeKeyWithOwnPrefix'],
        }),
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(400));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isFalse);
      expect(body['message'], contains('was not legitimately uploaded by this user'));
    });

    test('Under-18 DOB is rejected with 400 Bad Request', () async {
      final seventeenYearsAgo = DateTime.now().subtract(const Duration(days: 17 * 365));
      final dobStr = seventeenYearsAgo.toIso8601String().split('T').first;

      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/users/onboarding'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({
          'phoneNumber': testPhone,
          'fullName': 'Minor User',
          'dob': dobStr,
          'gender': 'Female',
          'heightCm': 165,
          'location': 'Delhi',
          'photos': ['https://cdn.denapp.com/users/dummy/photos/pic.jpg'],
        }),
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(400));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isFalse);
      expect(body['message'], contains('Users must be at least 18 years old'));
    });

    test('Invalid Instagram handle (invalid chars or >30 length) is rejected with 400 Bad Request', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/users/onboarding'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({
          'phoneNumber': testPhone,
          'fullName': 'Test User',
          'dob': '2000-01-01',
          'gender': 'Female',
          'heightCm': 165,
          'location': 'Delhi',
          'instagramUsername': 'invalid_handle_with_@_symbol!',
          'photos': ['https://cdn.denapp.com/users/dummy/photos/pic.jpg'],
        }),
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(400));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isFalse);
      expect(body['message'], contains('Invalid Instagram username'));
    });

    test('Photo object_key belonging to a different user is rejected with 400 Bad Request', () async {
      final otherUserId = 'usr_different_account_9999';
      final victimPhotoKey = 'users/$otherUserId/photos/victim_pic.jpg';

      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/users/onboarding'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({
          'phoneNumber': testPhone,
          'fullName': 'Attacker User',
          'dob': '2000-01-01',
          'gender': 'Male',
          'heightCm': 175,
          'location': 'Bangalore',
          'photos': ['https://cdn.denapp.com/$victimPhotoKey'],
        }),
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(400));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isFalse);
      expect(body['message'], contains('was not legitimately uploaded by this user'));
    });
  });
}
