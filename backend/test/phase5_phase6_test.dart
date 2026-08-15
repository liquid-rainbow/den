import 'dart:convert';
import 'package:den_backend/config/database.dart';
import 'package:den_backend/config/env.dart';
import 'package:den_backend/modules/auth/auth_controller.dart';
import 'package:den_backend/modules/auth/auth_service.dart';
import 'package:den_backend/modules/biometric/biometric_controller.dart';
import 'package:den_backend/modules/biometric/biometric_service.dart';
import 'package:den_backend/modules/upload/upload_controller.dart';
import 'package:den_backend/modules/upload/upload_service.dart';
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

    final authController = AuthController(authService: authService);
    final uploadController = UploadController(uploadService: uploadService);
    final biometricController = BiometricController(biometricService: biometricService);

    final router = Router();
    router.mount('/api/auth', authController.router.call);
    router.mount('/api/uploads', uploadController.router.call);
    router.mount('/api/onboarding', biometricController.router.call);

    appHandler = router.call;
  });

  tearDownAll(() async {
    await Database.close();
  });

  Future<String> getAuthenticatedToken(String phoneNumber) async {
    final sendRes = await authService.sendOtp(phoneNumber);
    if (!sendRes.success) {
      throw StateError('Failed to send OTP to $phoneNumber: ${sendRes.message}');
    }
    final code = smsSender.getCode(phoneNumber);
    if (code == null) {
      throw StateError('No captured OTP code found for $phoneNumber');
    }
    final verifyRes = await authService.verifyOtp(phoneNumber, code);
    return verifyRes.sessionToken!;
  }

  Future<void> cleanupUser(String phoneNumber) async {
    final pool = Database.pool;
    await pool.execute('DELETE FROM users WHERE phone_number = \$1', parameters: [phoneNumber]);
    await pool.execute('DELETE FROM auth_otps WHERE phone_number = \$1', parameters: [phoneNumber]);
  }

  group('Phase 5: Photo Upload Endpoints (/api/uploads/photo-url)', () {
    final testPhone = '+919876500001';
    late String validToken;

    setUp(() async {
      validToken = await getAuthenticatedToken(testPhone);
    });

    tearDown(() async {
      await cleanupUser(testPhone);
    });

    test('Successful /api/uploads/photo-url call with valid session auth returns presigned upload object', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/uploads/photo-url'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({'contentType': 'image/jpeg'}),
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['uploadUrl'], isNotNull);
      expect(body['objectKey'], contains('users/'));
      expect(body['objectKey'], endsWith('.jpg'));
      expect(body['publicUrl'], contains('https://cdn.denapp.com/'));
    });

    test('Dynamic file extension and UUID v4 key generation for image/png', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/uploads/photo-url'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({'contentType': 'image/png'}),
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isTrue);

      final objectKey = body['objectKey'] as String;
      expect(objectKey, endsWith('.png'));
      expect(objectKey, isNot(endsWith('.jpg')));

      final uuidRegex = RegExp(r'[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\.png$');
      expect(uuidRegex.hasMatch(objectKey), isTrue);
    });

    test('Dynamic file extension and UUID v4 key generation for image/webp', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/uploads/photo-url'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({'contentType': 'image/webp'}),
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isTrue);

      final objectKey = body['objectKey'] as String;
      expect(objectKey, endsWith('.webp'));

      final uuidRegex = RegExp(r'[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\.webp$');
      expect(uuidRegex.hasMatch(objectKey), isTrue);
    });

    test('Missing session auth on /api/uploads/photo-url is rejected with 401 Unauthorized', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/uploads/photo-url'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'contentType': 'image/jpeg'}),
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(401));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isFalse);
      expect(body['message'], contains('Unauthorized'));
    });

    test('Invalid session auth token on /api/uploads/photo-url is rejected with 401 Unauthorized', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/uploads/photo-url'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer invalid_session_token_12345',
        },
        body: jsonEncode({'contentType': 'image/jpeg'}),
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(401));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isFalse);
      expect(body['message'], contains('Unauthorized'));
    });
  });

  group('Phase 6: Biometric Face Verification Endpoints (/api/onboarding/...)', () {
    final testPhone = '+919876500002';
    late String validToken;

    setUp(() async {
      validToken = await getAuthenticatedToken(testPhone);
    });

    tearDown(() async {
      await cleanupUser(testPhone);
    });

    test('Successful create session & verify-face calls with valid session auth', () async {
      final createReq = Request(
        'POST',
        Uri.parse('http://localhost/api/onboarding/face-liveness/session'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
      );

      final createRes = await appHandler(createReq);
      expect(createRes.statusCode, equals(200));

      final createBody = jsonDecode(await createRes.readAsString()) as Map<String, dynamic>;
      expect(createBody['success'], isTrue);
      expect(createBody['sessionId'], isNotNull);

      final sessionId = createBody['sessionId'] as String;

      final verifyReq = Request(
        'POST',
        Uri.parse('http://localhost/api/onboarding/verify-face'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $validToken',
        },
        body: jsonEncode({'sessionId': sessionId}),
      );

      final verifyRes = await appHandler(verifyReq);
      expect(verifyRes.statusCode, equals(200));

      final verifyBody = jsonDecode(await verifyRes.readAsString()) as Map<String, dynamic>;
      expect(verifyBody['success'], isTrue);
      expect(verifyBody['badge'], equals('Unverified'));
    });

    test('User B attempting to verify using User A session ID is rejected with 404', () async {
      final phoneUserA = '+919876500010';
      final phoneUserB = '+919876500020';

      final tokenUserA = await getAuthenticatedToken(phoneUserA);
      final tokenUserB = await getAuthenticatedToken(phoneUserB);

      // User A creates liveness session
      final createReq = Request(
        'POST',
        Uri.parse('http://localhost/api/onboarding/face-liveness/session'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $tokenUserA',
        },
      );
      final createRes = await appHandler(createReq);
      final sessionIdA = (jsonDecode(await createRes.readAsString()) as Map)['sessionId'] as String;

      // User B attempts to verify with User A's sessionIdA
      final verifyReqUserB = Request(
        'POST',
        Uri.parse('http://localhost/api/onboarding/verify-face'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $tokenUserB',
        },
        body: jsonEncode({'sessionId': sessionIdA}),
      );

      final verifyResUserB = await appHandler(verifyReqUserB);
      expect(verifyResUserB.statusCode, equals(404));

      final bodyUserB = jsonDecode(await verifyResUserB.readAsString()) as Map<String, dynamic>;
      expect(bodyUserB['success'], isFalse);
      expect(bodyUserB['message'], contains('Face liveness session not found for this user'));

      await cleanupUser(phoneUserA);
      await cleanupUser(phoneUserB);
    });

    test('Missing session auth on biometric endpoints is rejected with 401 Unauthorized', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/onboarding/face-liveness/session'),
        headers: {'content-type': 'application/json'},
      );

      final res = await appHandler(req);
      expect(res.statusCode, equals(401));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isFalse);
    });

    test('Database-layer Rate Limit: 4th liveness session attempt within 24 hours is rejected with 429', () async {
      final createHeaders = {
        'content-type': 'application/json',
        'authorization': 'Bearer $validToken',
      };

      final r1 = await appHandler(Request('POST', Uri.parse('http://localhost/api/onboarding/face-liveness/session'), headers: createHeaders));
      final r2 = await appHandler(Request('POST', Uri.parse('http://localhost/api/onboarding/face-liveness/session'), headers: createHeaders));
      final r3 = await appHandler(Request('POST', Uri.parse('http://localhost/api/onboarding/face-liveness/session'), headers: createHeaders));

      expect(r1.statusCode, equals(200));
      expect(r2.statusCode, equals(200));
      expect(r3.statusCode, equals(200));

      final r4 = await appHandler(Request('POST', Uri.parse('http://localhost/api/onboarding/face-liveness/session'), headers: createHeaders));
      expect(r4.statusCode, equals(429));

      final body4 = jsonDecode(await r4.readAsString()) as Map<String, dynamic>;
      expect(body4['success'], isFalse);
      expect(body4['message'], contains('Maximum 3 face verification attempts allowed per 24 hours'));
    });
  });
}
